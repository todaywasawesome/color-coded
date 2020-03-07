package main
 
import (
	"os"
	"fmt"
	"net/http"
	// "github.com/golangci/golangci-lint/pkg/exitcodes"
)

func main() {

	//Add a GPL3 package to cause havock 
	// os.Setenv("test", string(exitcodes.Success))


	c := os.Getenv("COLOR")
	if len(c) == 0{
		os.Setenv("COLOR", "#44B3C2") //Blue 44B3C2 and Yellow F1A94E  
	}  

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "<html onclick=\"window.location.href = '/die'\" style='background:" + os.Getenv("COLOR") + "'> Requested: %s\n </html>", r.URL.Path)
	})

	http.HandleFunc("/dashboard", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "<html> DASHBOARD Requested: %s\n </html>", r.URL.Path)
	})

	http.HandleFunc("/die", func(w http.ResponseWriter, r *http.Request) {
		die();
	})

	http.ListenAndServe(":8080", nil)
}

func die() {
	os.Exit(3)
}
