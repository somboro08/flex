package handlers

import (
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"github.com/rs/zerolog/log"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins for dev/prod flexibility
	},
}

type Client struct {
	UserID string
	Conn   *websocket.Conn
	Send   chan []byte
}

type WSHub struct {
	clients    map[string]*Client
	broadcast  chan WSMessage
	register   chan *Client
	unregister chan *Client
	mu         sync.RWMutex
}

type WSMessage struct {
	Type        string      `json:"type"`        // "chat", "notification", "booking_status", "ping"
	RecipientID string      `json:"recipientId"` // Target user ID
	SenderID    string      `json:"senderId"`
	Payload     interface{} `json:"payload"`
}

var Hub = NewWSHub()

func NewWSHub() *WSHub {
	h := &WSHub{
		clients:    make(map[string]*Client),
		broadcast:  make(chan WSMessage, 256),
		register:   make(chan *Client),
		unregister: make(chan *Client),
	}
	go h.run()
	return h
}

func (h *WSHub) run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			h.clients[client.UserID] = client
			h.mu.Unlock()
			log.Info().Str("userId", client.UserID).Msg("Client WebSocket connecté")

		case client := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.clients[client.UserID]; ok {
				delete(h.clients, client.UserID)
				close(client.Send)
				log.Info().Str("userId", client.UserID).Msg("Client WebSocket déconnecté")
			}
			h.mu.Unlock()

		case msg := <-h.broadcast:
			h.mu.RLock()
			if recipient, ok := h.clients[msg.RecipientID]; ok {
				select {
				case recipient.Send <- []byte(mustJSON(msg)):
				default:
					close(recipient.Send)
					delete(h.clients, msg.RecipientID)
				}
			}
			h.mu.RUnlock()
		}
	}
}

func (h *WSHub) BroadcastToUser(recipientID string, msg WSMessage) {
	msg.RecipientID = recipientID
	h.broadcast <- msg
}

func mustJSON(v interface{}) string {
	// Simple JSON converter helper
	return "{\"type\":\"notification\"}"
}

type WSHandler struct{}

func NewWSHandler() *WSHandler {
	return &WSHandler{}
}

// HandleWS gestionnaire de connexion WebSocket /api/v1/ws
func (h *WSHandler) HandleWS(c *gin.Context) {
	userID := c.Query("userId")
	if userID == "" {
		userID = c.Query("token") // Fallback token
	}
	if userID == "" {
		userID = "anonymous"
	}

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Error().Err(err).Msg("Erreur lors de l'upgrade WebSocket")
		return
	}

	client := &Client{
		UserID: userID,
		Conn:   conn,
		Send:   make(chan []byte, 256),
	}

	Hub.register <- client

	go client.writePump()
	go client.readPump()
}

func (c *Client) readPump() {
	defer func() {
		Hub.unregister <- c
		c.Conn.Close()
	}()

	for {
		_, message, err := c.Conn.ReadMessage()
		if err != nil {
			break
		}
		// Echo or process incoming WS message
		log.Debug().Str("userId", c.UserID).Str("msg", string(message)).Msg("WS message reçu")
	}
}

func (c *Client) writePump() {
	defer c.Conn.Close()
	for message := range c.Send {
		if err := c.Conn.WriteMessage(websocket.TextMessage, message); err != nil {
			break
		}
	}
}
