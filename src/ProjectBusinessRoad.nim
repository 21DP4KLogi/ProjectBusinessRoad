import jester
import std/[segfaults, strutils, os]
import norm/[model, postgres, types]
import checksums/bcrypt
import json
import zippy
import dotenv
import "api/auth.nim"
import "models.nim"
import "utils.nim"


overload()  # Load dotenv file
let dbhost = getEnv("DB_HOST")
let dbuser = getEnv("DB_USER")
let dbpass = getEnv("DB_PASS")
let dbname = getEnv("DB_NAME")

let dbConn = open(dbhost, dbuser, dbpass, dbname)
dbConn.createTables(newUser())
dbConn.createTables(newBusiness())

routes:

  get "/":
    resp readFile("src/index.html")

  extend auth, "/auth"

  get "/motd":
    resp getRandMOTD()
    
  post "/player/money":
    let sentToken = request.body
    if sentToken == "":
      resp Http400
    var playerQuery = newUser()
    if not dbConn.exists(User, "authToken = $1", sentToken):
      resp Http404
    dbConn.select(playerQuery, "authToken = $1", sentToken)
    resp $playerQuery.money
  
  get "/jquery.js":
    setHeader(responseHeaders, "Content-Encoding", "gzip")
    resp compress(readfile("public/jquery-3.7.1.min.js"), BestSpeed, dfGzip), contentType = "application/javascript"
    # Content-Type added as it would otherwise return as text/html and browsers wont run it
    # Although text/javascript is more recommended, jester uses application/javascript, so i do aswell for consistency

runForever()
