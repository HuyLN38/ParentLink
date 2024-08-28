package main

import (
	"cloud.google.com/go/firestore"
	"context"
	firebase "firebase.google.com/go"
	"firebase.google.com/go/auth"
	"google.golang.org/api/option"
	"log"
)

var (
	authClient      *auth.Client
	firestoreClient *firestore.Client
)

func initFirebase() {
	ctx := context.Background()
	opt := option.WithCredentialsFile("serviceAccountKey.json")
	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}

	authClient, err = app.Auth(ctx)
	if err != nil {
		log.Fatalf("error initializing auth client: %v\n", err)
	}

	firestoreClient, err = app.Firestore(ctx)
	if err != nil {
		log.Fatalf("error initializing firestore client: %v\n", err)
	}

}
