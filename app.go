package main

import (
	"fmt"
	"net/http"
  "os"
)

func handler(w http.ResponseWriter, r *http.Request) {
  name, err := os.Hostname()
	if err != nil {
		panic(err)
	}

	fmt.Fprintf(w, "hostname : %s ", name)
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}
