package validator

import (
	"net/mail"
	"regexp"
	"strings"
	"unicode"

	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"
)

var (
	phoneRegex      = regexp.MustCompile(`^\+[1-9]\d{6,14}$`)
	nameRegex       = regexp.MustCompile(`^[a-zA-ZÀ-ÿ\s\-']+$`)
	passwordUpper   = regexp.MustCompile(`[A-Z]`)
	passwordLower   = regexp.MustCompile(`[a-z]`)
	passwordDigit   = regexp.MustCompile(`[0-9]`)
	passwordSpecial = regexp.MustCompile(`[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]`)
)

type Validator struct {
	validate *validator.Validate
}

func New() *Validator {
	v := validator.New()

	_ = v.RegisterValidation("phone", validatePhone)
	_ = v.RegisterValidation("password", validatePassword)
	_ = v.RegisterValidation("uuid", validateUUID)
	_ = v.RegisterValidation("name", validateName)
	_ = v.RegisterValidation("role", validateRole)

	return &Validator{validate: v}
}

func (v *Validator) Validate(i interface{}) error {
	return v.validate.Struct(i)
}

func (v *Validator) Var(field interface{}, tag string) error {
	return v.validate.Var(field, tag)
}

func validatePhone(fl validator.FieldLevel) bool {
	return phoneRegex.MatchString(fl.Field().String())
}

func validatePassword(fl validator.FieldLevel) bool {
	pwd := fl.Field().String()
	if len(pwd) < 8 || len(pwd) > 128 {
		return false
	}
	hasUpper := passwordUpper.MatchString(pwd)
	hasLower := passwordLower.MatchString(pwd)
	hasDigit := passwordDigit.MatchString(pwd)
	hasSpecial := passwordSpecial.MatchString(pwd)
	return hasUpper && hasLower && hasDigit && hasSpecial
}

func validateUUID(fl validator.FieldLevel) bool {
	_, err := uuid.Parse(fl.Field().String())
	return err == nil
}

func validateName(fl validator.FieldLevel) bool {
	return nameRegex.MatchString(fl.Field().String())
}

func validateRole(fl validator.FieldLevel) bool {
	role := fl.Field().String()
	validRoles := map[string]bool{
		"voyageur": true,
		"hote":     true,
		"agent":    true,
	}
	return validRoles[role]
}

func IsValidEmail(email string) bool {
	_, err := mail.ParseAddress(email)
	return err == nil
}

func IsValidPhone(phone string) bool {
	return phoneRegex.MatchString(phone)
}

func IsStrongPassword(password string) []string {
	var errors []string

	if len(password) < 8 {
		errors = append(errors, "Doit contenir au moins 8 caractères")
	}
	if len(password) > 128 {
		errors = append(errors, "Doit contenir au maximum 128 caractères")
	}
	if !passwordUpper.MatchString(password) {
		errors = append(errors, "Doit contenir une majuscule")
	}
	if !passwordLower.MatchString(password) {
		errors = append(errors, "Doit contenir une minuscule")
	}
	if !passwordDigit.MatchString(password) {
		errors = append(errors, "Doit contenir un chiffre")
	}
	if !passwordSpecial.MatchString(password) {
		errors = append(errors, "Doit contenir un caractère spécial (!@#$%^&*)")
	}

	return errors
}

func SanitizeString(s string) string {
	s = strings.TrimSpace(s)
	s = strings.ReplaceAll(s, "<", "&lt;")
	s = strings.ReplaceAll(s, ">", "&gt;")
	s = strings.ReplaceAll(s, "'", "&#39;")
	s = strings.ReplaceAll(s, "\"", "&quot;")
	return s
}

func ContainsProfanity(s string) bool {
	profanityList := []string{}
	lower := strings.ToLower(s)
	for _, word := range profanityList {
		if strings.Contains(lower, word) {
			return true
		}
	}
	return false
}

func IsValidName(s string) bool {
	if len(s) < 2 || len(s) > 100 {
		return false
	}
	for _, r := range s {
		if !unicode.IsLetter(r) && !unicode.IsSpace(r) && r != '-' && r != '\'' {
			return false
		}
	}
	return true
}
