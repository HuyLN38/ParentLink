package main

import (
	"github.com/gin-gonic/gin"
	"github.com/gorilla/handlers"
	"log"
	"net/http"
	"os"
)

func CORSMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}

func main() {
	// Initialize Firebase
	initFirebase()

	// Create a new router
	router := gin.Default()
	router.Use(CORSMiddleware())

	// Define routes
	router.POST("/register", registerHandler)
	router.POST("/login", loginHandler)
	router.POST("/users/:staticID/children", addChild)
	router.GET("/users/:staticID/children", getChildren)
	router.DELETE("/users/:staticID", deleteUser)
	router.POST("/changePassword", changePassword)

	// Configure CORS
	corsHandler := handlers.CORS(
		handlers.AllowedOrigins([]string{"*"}),                                       // Allow all origins; change "*" to specific origins in production
		handlers.AllowedMethods([]string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}), // Allow specific methods
		handlers.AllowedHeaders([]string{"Content-Type", "Authorization"}),           // Allow specific headers
	)

	// Wrap the router with the CORS handler
	http.Handle("/", corsHandler(router))

	// Get the port from the environment variable
	port := os.Getenv("PORT")
	if port == "" {
		port = "8000" // Default port if not specified
	}

	// Start the server
	log.Printf("Server is starting on port %s...", port)
	log.Fatal(router.Run(":" + port))
}
