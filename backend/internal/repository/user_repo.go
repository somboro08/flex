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

func (r *UserRepository) AddFavorite(ctx context.Context, userID, listingID uuid.UUID) error {
	return r.db.WithContext(ctx).Exec(
		`UPDATE users SET favorites = array_append(favorites, ?::text)
		 WHERE id = ? AND NOT (?::text = ANY(favorites))`,
		listingID, userID, listingID,
	).Error
}

func (r *UserRepository) RemoveFavorite(ctx context.Context, userID, listingID uuid.UUID) error {
	return r.db.WithContext(ctx).Exec(
		`UPDATE users SET favorites = array_remove(favorites, ?::text) WHERE id = ?`,
		listingID, userID,
	).Error
}

func (r *UserRepository) IsFavorite(ctx context.Context, userID, listingID uuid.UUID) (bool, error) {
	var favorites models.StringArray
	err := r.db.WithContext(ctx).Model(&models.User{}).
		Select("favorites").Where("id = ?", userID).Scan(&favorites).Error
	if err != nil {
		return false, err
	}
	for _, f := range favorites {
		if f == listingID.String() {
			return true, nil
		}
	}
	return false, nil
}

func (r *UserRepository) FindPendingIdentities(ctx context.Context) ([]models.User, error) {
	var users []models.User
	err := r.db.WithContext(ctx).
		Where("deleted_at IS NULL AND (id_card_url IS NOT NULL AND id_card_url != '' OR verification_status = 'pending')").
		Order("updated_at DESC").
		Find(&users).Error
	return users, err
}

func (r *UserRepository) VerifyIdentity(ctx context.Context, id uuid.UUID, status string) error {
	isVerified := status == "verified"
	return r.db.WithContext(ctx).Model(&models.User{}).Where("id = ?", id).Updates(map[string]interface{}{
		"verification_status": status,
		"is_verified":         isVerified,
	}).Error
}

