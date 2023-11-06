import jester
import std/[segfaults, strutils, random]
import norm/[model, sqlite]
import checksums/bcrypt
import json

type
  User = ref object of Model
    username: string
    password: string

func newUser(un = "", pw = ""): User =
  User(username: un, password: pw)

settings:
  staticDir = "dist"

proc readHtml(dirName: string): string =
  return readFile("dist/src/" & dirName & "/index.html")

proc getRandMOTD(): string =
  return readFile("src/homepage_messages.txt").splitLines.sample()

let dbConn = open(":memory:", "", "", "")
dbConn.createTables(newUser())

routes:
  get "/":
    resp readHtml("index")
  get "/login":
    resp readHtml("login")
  post "/login/submitinfo":
    
    resp(Http200, "POST req. received")
  get "/register":
    resp readHtml("register")
  post "/register/submitinfo":
    let registerInfo = parseJson(request.body)
    if registerInfo["password"].getStr.len < 8:
      resp Http400
    let hashedPassword = $bcrypt(registerInfo["password"].getStr, generateSalt(6))  # Low password salt for testing purposes
    var newRegisteredUser = newUser(registerInfo["username"].getStr, hashedPassword)
    dbConn.insert(newRegisteredUser)
    resp Http200
  post "/register/checkname":
    if request.body.len == 0:
      resp Http400
    else:
      # Code for checking availability
      resp Http200
  get "/test":
    resp readHtml("test")
  get "/motd":
    resp getRandMOTD()
