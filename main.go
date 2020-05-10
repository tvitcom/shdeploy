//Simple File server on Go.
package main

import (
	"net/http"
	"time"
  "fmt"
  "crypto/md5"
  "io"
  "os"
  "strconv"
  "html/template"
)

const (
	PORT = ":3000"
)

var (
	publicDir string = "./pub"
)

type (

)

func init() {
  //Test of sync files
}

func main() {
  println("Serving files on HTTP port: "+PORT)
  http.Handle("/", changeHeaderThenServe(http.FileServer(http.Dir(publicDir))))
  http.HandleFunc("/nunaupload", upload) // secret link
  panic(http.ListenAndServe(PORT, nil)) 
}

func changeHeaderThenServe(h http.Handler) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
      // Set some header
      w.Header().Add("Server", "SAMBA Server")
      h.ServeHTTP(w, r)
      // Some log activity:
      println(time.Now().UTC().String(),r.RemoteAddr, r.UserAgent(), r.URL.Path)
    }
}

// upload logic
func upload(w http.ResponseWriter, r *http.Request) {
       fmt.Println("method:", r.Method)
       if r.Method == "GET" {
           crutime := time.Now().Unix()
           h := md5.New()
           io.WriteString(h, strconv.FormatInt(crutime, 10))
           token := fmt.Sprintf("%x", h.Sum(nil))

           t, _ := template.ParseFiles("./tpl/form.htmlt")
           t.Execute(w, token)
       } else {
            if err := r.ParseMultipartForm(1024 << 20); err != nil {
              http.Error(w, err.Error(), http.StatusBadRequest)
              return
            }
           file, handler, err := r.FormFile("uploadfile")
           if err != nil {
               fmt.Println(err)
               return
           }
           defer file.Close()
           fmt.Fprintf(w, "%v", handler.Header)
           f, err := os.OpenFile("./uploaded/"+handler.Filename, os.O_WRONLY|os.O_CREATE, 0666)
           if err != nil {
               fmt.Println(err)
               return
           }
           defer f.Close()
           io.Copy(f, file)
       }
}