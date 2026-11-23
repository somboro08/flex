package services

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strings"

	"github.com/rs/zerolog/log"
	"github.com/somboro08/flex-api/internal/config"
)

type SMSService struct {
	cfg config.SMSConfig
}

func NewSMSService(cfg config.SMSConfig) *SMSService {
	return &SMSService{cfg: cfg}
}

func (s *SMSService) SendOTP(phoneNumber, code string) error {
	message := fmt.Sprintf("Flex: Votre code de vérification est %s. Valable 10 minutes.", code)
	return s.sendViaTwilio(phoneNumber, message)
}

func (s *SMSService) SendBookingConfirmation(phoneNumber, listingTitle string) error {
	message := fmt.Sprintf("Flex: Votre réservation pour « %s » est confirmée ! Bon séjour avec Flex.", listingTitle)
	return s.sendViaTwilio(phoneNumber, message)
}

func (s *SMSService) SendPasswordResetOTP(phoneNumber, code string) error {
	message := fmt.Sprintf("Flex: Votre code de réinitialisation est %s. Valable 10 minutes.", code)
	return s.sendViaTwilio(phoneNumber, message)
}

func (s *SMSService) sendViaTwilio(to, message string) error {
	if s.cfg.TwilioAccountSID == "" || s.cfg.TwilioAuthToken == "" || s.cfg.TwilioAccountSID == "your-twilio-sid" {
		log.Warn().Str("to", to).Str("message", message).
			Msg("[DEV SMS] Twilio non configuré. SMS simule avec succès.")
		return nil
	}

	apiURL := fmt.Sprintf("https://api.twilio.com/2010-04-01/Accounts/%s/Messages.json", s.cfg.TwilioAccountSID)

	v := url.Values{}
	v.Set("To", to)
	v.Set("From", s.cfg.TwilioPhone)
	v.Set("Body", message)

	req, err := http.NewRequest("POST", apiURL, strings.NewReader(v.Encode()))
	if err != nil {
		return err
	}

	req.SetBasicAuth(s.cfg.TwilioAccountSID, s.cfg.TwilioAuthToken)
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Error().Err(err).Str("to", to).Msg("Erreur lors de l'envoi du SMS Twilio")
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 200 && resp.StatusCode < 300 {
		log.Info().Str("to", to).Msg("SMS Twilio envoyé avec succès")
		return nil
	}

	var resMap map[string]interface{}
	_ = json.NewDecoder(resp.Body).Decode(&resMap)
	log.Error().Interface("twilio_res", resMap).Msg("Twilio a retourné une erreur")
	return fmt.Errorf("erreur Twilio HTTP %d", resp.StatusCode)
}
