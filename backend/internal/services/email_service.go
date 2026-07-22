package services

import (
	"crypto/tls"
	"fmt"
	"net/smtp"
	"strings"

	"github.com/rs/zerolog/log"
	"github.com/somboro08/flex-api/internal/config"
)

type EmailService struct {
	cfg config.EmailConfig
}

func NewEmailService(cfg config.EmailConfig) *EmailService {
	return &EmailService{cfg: cfg}
}

type EmailMessage struct {
	To      []string
	Subject string
	Body    string
	IsHTML  bool
}

func (s *EmailService) Send(msg EmailMessage) error {
	if s.cfg.SMTPHost == "" || s.cfg.Username == "" || s.cfg.Password == "" {
		log.Warn().Msg("SMTP not configured, skipping email")
		return nil
	}

	auth := smtp.PlainAuth("", s.cfg.Username, s.cfg.Password, s.cfg.SMTPHost)

	headers := make(map[string]string)
	headers["From"] = s.cfg.FromAddress
	headers["To"] = strings.Join(msg.To, ", ")
	headers["Subject"] = msg.Subject
	headers["MIME-Version"] = "1.0"

	if msg.IsHTML {
		headers["Content-Type"] = "text/html; charset=\"UTF-8\""
	} else {
		headers["Content-Type"] = "text/plain; charset=\"UTF-8\""
	}

	var emailBody strings.Builder
	for k, v := range headers {
		emailBody.WriteString(fmt.Sprintf("%s: %s\r\n", k, v))
	}
	emailBody.WriteString("\r\n")
	emailBody.WriteString(msg.Body)

	addr := fmt.Sprintf("%s:%d", s.cfg.SMTPHost, s.cfg.SMTPPort)

	tlsConfig := &tls.Config{
		ServerName: s.cfg.SMTPHost,
	}

	conn, err := tls.Dial("tcp", addr, tlsConfig)
	if err != nil {
		return fmt.Errorf("failed to connect to SMTP server: %w", err)
	}
	defer conn.Close()

	client, err := smtp.NewClient(conn, s.cfg.SMTPHost)
	if err != nil {
		return fmt.Errorf("failed to create SMTP client: %w", err)
	}
	defer client.Close()

	if err := client.Auth(auth); err != nil {
		return fmt.Errorf("SMTP auth failed: %w", err)
	}

	if err := client.Mail(s.cfg.FromAddress); err != nil {
		return fmt.Errorf("failed to set sender: %w", err)
	}

	for _, to := range msg.To {
		if err := client.Rcpt(to); err != nil {
			return fmt.Errorf("failed to set recipient %s: %w", to, err)
		}
	}

	w, err := client.Data()
	if err != nil {
		return fmt.Errorf("failed to start data: %w", err)
	}

	_, err = w.Write([]byte(emailBody.String()))
	if err != nil {
		return fmt.Errorf("failed to write email body: %w", err)
	}

	if err := w.Close(); err != nil {
		return fmt.Errorf("failed to close data writer: %w", err)
	}

	client.Quit()

	log.Info().Strs("to", msg.To).Str("subject", msg.Subject).Msg("email sent")
	return nil
}

func (s *EmailService) SendVerificationEmail(to, code string) error {
	body := fmt.Sprintf(`
		<h2>Vérification Flex</h2>
		<p>Votre code de vérification : <strong>%s</strong></p>
		<p>Ce code expire dans 10 minutes.</p>
	`, code)

	return s.Send(EmailMessage{
		To:      []string{to},
		Subject: "Flex - Vérification de votre compte",
		Body:    body,
		IsHTML:  true,
	})
}

func (s *EmailService) SendWelcomeEmail(to, prenom string) error {
	body := fmt.Sprintf(`
		<h2>Bienvenue sur Flex !</h2>
		<p>Bonjour %s,</p>
		<p>Votre compte a été créé avec succès.</p>
		<p>Vous pouvez maintenant réserver des logements certifiés partout en Afrique de l'Ouest.</p>
	`, prenom)

	return s.Send(EmailMessage{
		To:      []string{to},
		Subject: "Bienvenue sur Flex",
		Body:    body,
		IsHTML:  true,
	})
}
