import jester
import std/[segfaults, strutils, random]
import norm/[model, sqlite]
import checksums/bcrypt
import json

type
  User = ref object of Model
    username: string
    email: string
    password: string

func newUser(un = "", em = "", pw = ""): User =
  User(username: un, email: em, password: pw)

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
  post "/login":
    var userList: seq[User] = @[newUser()]
    var newLoggedUser = newUser($request.body, $request.body, $bcrypt($request.body, generateSalt(8)))
    dbConn.insert(newLoggedUser)
    dbConn.selectAll(userList)
    for i in userList:
      echo $i.id & " " & i.username
      echo i.password
    resp(Http200, "POST req. received")
  get "/register":
    resp readHtml("register")
  post "/register/submitinfo":
    let registerInfo = parseJson(request.body)
    if registerInfo["username"].len < 8:
      resp Http400
    echo("Username: " & $registerInfo["username"] &
    "\nBCrypted password: " & $bcrypt($registerInfo["password"], generateSalt(6)))  # Low salt level for testing purposes
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
