package repository

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/models"
	"gorm.io/gorm"
)

var (
	ErrUserNotFound      = errors.New("user not found")
	ErrUserAlreadyExists = errors.New("user already exists")
	ErrUserLocked        = errors.New("user account is locked")
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Create(ctx context.Context, user *models.User) error {
	return r.db.WithContext(ctx).Create(user).Error
}

func (r *UserRepository) FindByID(ctx context.Context, id uuid.UUID) (*models.User, error) {
	var user models.User
	err := r.db.WithContext(ctx).Where("id = ? AND deleted_at IS NULL", id).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) FindByTelephone(ctx context.Context, telephone string) (*models.User, error) {
	var user models.User
	err := r.db.WithContext(ctx).Where("telephone = ? AND deleted_at IS NULL", telephone).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) FindByEmail(ctx context.Context, email string) (*models.User, error) {
	var user models.User
	err := r.db.WithContext(ctx).Where("email = ? AND deleted_at IS NULL", email).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) Update(ctx context.Context, user *models.User) error {
	return r.db.WithContext(ctx).Save(user).Error
}

func (r *UserRepository) UpdateFields(ctx context.Context, id uuid.UUID, fields map[string]interface{}) error {
	return r.db.WithContext(ctx).Model(&models.User{}).Where("id = ?", id).Updates(fields).Error
}

func (r *UserRepository) SoftDelete(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Where("id = ?", id).Delete(&models.User{}).Error
}

func (r *UserRepository) IncrementLoginAttempts(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Model(&models.User{}).Where("id = ?", id).
		UpdateColumn("failed_login_attempts", gorm.Expr("failed_login_attempts + 1")).Error
}

func (r *UserRepository) LockAccount(ctx context.Context, id uuid.UUID, durationMinutes int) error {
	// Lock for X minutes
	return r.db.WithContext(ctx).Model(&models.User{}).Where("id = ?", id).
		UpdateColumn("failed_login_attempts", 0).
		UpdateColumn("locked_until", gorm.Expr("NOW() + INTERVAL '? minutes'", durationMinutes)).Error
}

func (r *UserRepository) ResetLoginAttempts(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Model(&models.User{}).Where("id = ?", id).
		Updates(map[string]interface{}{
			"failed_login_attempts": 0,
			"locked_until":          nil,
		}).Error
}

func (r *UserRepository) UpdateRefreshToken(ctx context.Context, id uuid.UUID, token string) error {
	return r.db.WithContext(ctx).Model(&models.User{}).Where("id = ?", id).
		UpdateColumn("refresh_token", token).Error
}
