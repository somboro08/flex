package response

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type APIResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
	Error   *APIError   `json:"error,omitempty"`
	Meta    *Meta       `json:"meta,omitempty"`
}

type APIError struct {
	Code    string `json:"code,omitempty"`
	Details string `json:"details,omitempty"`
}

type Meta struct {
	Page       int   `json:"page"`
	PerPage    int   `json:"perPage"`
	Total      int64 `json:"total"`
	TotalPages int   `json:"totalPages"`
}

func Success(c *gin.Context, status int, message string, data interface{}) {
	c.JSON(status, APIResponse{
		Success: true,
		Message: message,
		Data:    data,
	})
}

func Created(c *gin.Context, message string, data interface{}) {
	Success(c, http.StatusCreated, message, data)
}

func OK(c *gin.Context, message string, data interface{}) {
	Success(c, http.StatusOK, message, data)
}

func Paginated(c *gin.Context, data interface{}, page, perPage int, total int64) {
	totalPages := int(total) / perPage
	if int(total)%perPage > 0 {
		totalPages++
	}

	c.JSON(http.StatusOK, APIResponse{
		Success: true,
		Data:    data,
		Meta: &Meta{
			Page:       page,
			PerPage:    perPage,
			Total:      total,
			TotalPages: totalPages,
		},
	})
}

func Error(c *gin.Context, status int, code string, message string) {
	c.JSON(status, APIResponse{
		Success: false,
		Error: &APIError{
			Code:    code,
			Details: message,
		},
	})
}

func BadRequest(c *gin.Context, message string) {
	Error(c, http.StatusBadRequest, "BAD_REQUEST", message)
}

func Unauthorized(c *gin.Context, message string) {
	Error(c, http.StatusUnauthorized, "UNAUTHORIZED", message)
}

func Forbidden(c *gin.Context, message string) {
	Error(c, http.StatusForbidden, "FORBIDDEN", message)
}

func NotFound(c *gin.Context, message string) {
	Error(c, http.StatusNotFound, "NOT_FOUND", message)
}

func Conflict(c *gin.Context, message string) {
	Error(c, http.StatusConflict, "CONFLICT", message)
}

func TooManyRequests(c *gin.Context, message string) {
	Error(c, http.StatusTooManyRequests, "RATE_LIMITED", message)
}

func InternalError(c *gin.Context, message string) {
	Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", message)
}

func ValidationError(c *gin.Context, errors map[string]string) {
	c.JSON(http.StatusUnprocessableEntity, APIResponse{
		Success: false,
		Error: &APIError{
			Code:    "VALIDATION_ERROR",
			Details: "Validation échouée",
		},
		Data: errors,
	})
}
