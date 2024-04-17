import jester
import std/[segfaults, strutils, os]
import norm/[postgres, types]
import zippy
import dotenv

import "models.nim"

import "api/auth.nim"
import "api/page.nim"
import "api/game.nim"

overload()  # Load dotenv file
let dbhost = getEnv("DB_HOST")
let dbuser = getEnv("DB_USER")
let dbpass = getEnv("DB_PASS")
let dbname = getEnv("DB_NAME")

let dbConn = open(dbhost, dbuser, dbpass, dbname)
dbConn.createTables(newUser())
# dbConn.createTables(newBusiness())

routes:

  get "/":
    resp readFile("src/index.html")

  extend auth, "/auth"

  extend page, "/page"
    
  extend game, "/game" 

runForever()
