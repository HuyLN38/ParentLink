package main

import (
	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
	"log"
	"net/http"
	"os"
)

func main() {
	// Initialize Firebase
	initFirebase()

	// Create a new router
	router := mux.NewRouter()

	// Define routes
	router.HandleFunc("/register", registerHandler).Methods("POST")
	router.HandleFunc("/login", loginHandler).Methods("POST")
	router.HandleFunc("/users/{staticID}/children", addChild).Methods("POST")
	router.HandleFunc("/users/{staticID}/children", getChildren).Methods("GET")
	router.HandleFunc("/users/{staticID}", deleteUser).Methods("DELETE")
	router.HandleFunc("/changePassword", changePassword).Methods("POST")

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
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
