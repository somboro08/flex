package handlers

import (
	"context"
	"fmt"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/cloudinary/cloudinary-go/v2"
	"github.com/cloudinary/cloudinary-go/v2/api/uploader"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/rs/zerolog/log"
	"github.com/somboro08/flex-api/internal/config"
	"github.com/somboro08/flex-api/pkg/response"
)

type UploadHandler struct {
	uploadDir string
	cld       *cloudinary.Cloudinary
}

func NewUploadHandler(uploadDir string, cldCfg config.CloudinaryConfig) *UploadHandler {
	if uploadDir == "" {
		uploadDir = "./uploads"
	}
	_ = os.MkdirAll(uploadDir, 0755)

	var cld *cloudinary.Cloudinary
	if cldCfg.CloudName != "" && cldCfg.APIKey != "" && cldCfg.APISecret != "" {
		c, err := cloudinary.NewFromParams(cldCfg.CloudName, cldCfg.APIKey, cldCfg.APISecret)
		if err == nil {
			cld = c
			log.Info().Str("cloud_name", cldCfg.CloudName).Msg("Cloudinary SDK initialisé avec succès")
		} else {
			log.Error().Err(err).Msg("Erreur d'initialisation de Cloudinary")
		}
	} else {
		log.Warn().Msg("Cloudinary non configuré, stockage local activé")
	}

	return &UploadHandler{
		uploadDir: uploadDir,
		cld:       cld,
	}
}

// Upload traite le téléversement d'images/fichiers vers Cloudinary (ou fallback local)
func (h *UploadHandler) Upload(c *gin.Context) {
	form, err := c.MultipartForm()
	if err != nil {
		response.BadRequest(c, "Formulaire multipart invalide")
		return
	}

	files := form.File["files"]
	if len(files) == 0 {
		if singleFile, err := c.FormFile("file"); err == nil {
			files = []*multipart.FileHeader{singleFile}
		} else if photoFile, err := c.FormFile("photo"); err == nil {
			files = []*multipart.FileHeader{photoFile}
		}
	}

	if len(files) == 0 {
		response.BadRequest(c, "Aucun fichier fourni")
		return
	}

	var fileURLs []string
	allowedExts := map[string]bool{
		".jpg": true, ".jpeg": true, ".png": true, ".webp": true, ".gif": true, ".pdf": true,
	}

	for _, file := range files {
		ext := strings.ToLower(filepath.Ext(file.Filename))
		if !allowedExts[ext] {
			response.BadRequest(c, fmt.Sprintf("Extension %s non supportée", ext))
			return
		}

		// 10 MB limit
		if file.Size > 10*1024*1024 {
			response.BadRequest(c, fmt.Sprintf("Le fichier %s dépasse la taille maximale (10 Mo)", file.Filename))
			return
		}

		// Si Cloudinary est configuré, on upload vers Cloudinary CDN
		if h.cld != nil {
			fileReader, err := file.Open()
			if err == nil {
				defer fileReader.Close()
				uploadRes, err := h.cld.Upload.Upload(context.Background(), fileReader, uploader.UploadParams{
					Folder: "flex_uploads",
				})
				if err == nil && uploadRes.SecureURL != "" {
					log.Info().Str("url", uploadRes.SecureURL).Msg("Fichier téléversé sur Cloudinary CDN")
					fileURLs = append(fileURLs, uploadRes.SecureURL)
					continue
				} else if err != nil {
					log.Error().Err(err).Msg("Échec de l'upload Cloudinary, bascule vers stockage local")
				}
			}
		}

		// Fallback stockage local
		newFilename := fmt.Sprintf("%d_%s%s", time.Now().UnixNano(), uuid.New().String()[:8], ext)
		dst := filepath.Join(h.uploadDir, newFilename)

		if err := c.SaveUploadedFile(file, dst); err != nil {
			response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Échec d'enregistrement du fichier")
			return
		}

		fileURL := fmt.Sprintf("/uploads/%s", newFilename)
		fileURLs = append(fileURLs, fileURL)
	}

	response.Created(c, "Fichier(s) téléversé(s) avec succès", gin.H{
		"urls": fileURLs,
		"url":  fileURLs[0],
	})
}
