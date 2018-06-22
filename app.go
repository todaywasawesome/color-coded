package main

import (
	"os"
	"fmt"
	"net/http"
)

func main() {
	c := os.Getenv("COLOR")
	if len(c) == 0{
		os.Setenv("COLOR", "red")
	} 

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "<html style='background:" + os.Getenv("COLOR") + "'> Requested: %s\n </html>", r.URL.Path)
	})

	http.ListenAndServe(":8080", nil)
}