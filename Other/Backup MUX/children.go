package main

import (
	"encoding/json"
	"github.com/gorilla/mux"
	"net/http"
)

type Child struct {
	Name     string     `json:"name"`
	Location [2]float64 `json:"location"`
}

func addChild(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	staticID := params["staticID"]

	var child Child
	json.NewDecoder(r.Body).Decode(&child)

	docRef := firestoreClient.Collection("users").Doc(staticID).Collection("children").NewDoc()
	_, err := docRef.Set(r.Context(), child)
	if err != nil {
		http.Error(w, "Failed to add child", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(map[string]string{"status": "Child added successfully"})
}

func getChildren(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	staticID := params["staticID"]

	children := []Child{}
	docs, err := firestoreClient.Collection("users").Doc(staticID).Collection("children").Documents(r.Context()).GetAll()
	if err != nil {
		http.Error(w, "Failed to fetch children", http.StatusInternalServerError)
		return
	}

	for _, doc := range docs {
		var child Child
		doc.DataTo(&child)
		children = append(children, child)
	}

	json.NewEncoder(w).Encode(children)
}
