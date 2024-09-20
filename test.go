package main

import (
	"log"
	"net/smtp"
)

func main() {
	send("hello there")
}

func send(body string) {
	from := "vanphucprince@gmail.com"
	pass := "ojlw acez nxdz pngu"
	to := "duynhu586@gmail.com"

	msg := "From: " + "ParentLink" + "\n" +
		"To: " + to + "\n" +
		"Subject: Register verification\n\n" +
		body

	err := smtp.SendMail("smtp.gmail.com:587",
		smtp.PlainAuth("", from, pass, "smtp.gmail.com"),
		from, []string{to}, []byte(msg))

	if err != nil {
		log.Printf("smtp error: %s", err)
		return
	}

	log.Print("sent, visit http://foobarbazz.mailinator.com")
}
