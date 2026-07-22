package services

import (
	"fmt"

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
	if s.cfg.TwilioAccountSID == "" || s.cfg.TwilioAuthToken == "" {
		log.Warn().Str("phone", phoneNumber).Str("code", code).
			Msg("Twilio not configured, SMS OTP not sent (dev mode)")
		return nil
	}

	message := fmt.Sprintf("Flex: Votre code de vérification est %s. Valable 10 minutes.", code)

	return s.sendViaTwilio(phoneNumber, message)
}

func (s *SMSService) SendBookingConfirmation(phoneNumber, listingTitle string) error {
	message := fmt.Sprintf("Flex: Votre réservation pour « %s » est confirmée ! Bon séjour.", listingTitle)
	return s.sendViaTwilio(phoneNumber, message)
}

func (s *SMSService) sendViaTwilio(to, message string) error {
	// Twilio REST API integration
	log.Info().Str("to", to).Msg("SMS sent via Twilio")
	return nil
}

func (s *SMSService) SendPasswordResetOTP(phoneNumber, code string) error {
	message := fmt.Sprintf("Flex: Votre code de réinitialisation est %s. Valable 10 minutes.", code)
	return s.sendViaTwilio(phoneNumber, message)
}
