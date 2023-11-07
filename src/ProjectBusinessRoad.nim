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

proc nameIsAvailable(database: DbConn, username: string): bool =
  return database.count(User, "*", dist = false, "username = ?", username) == 0

let dbConn = open(":memory:", "", "", "")
dbConn.createTables(newUser())

routes:
  get "/":
    resp readHtml("index")
  get "/login":
    resp readHtml("login")
  post "/login/submitinfo":
    let loginInfo = parseJson(request.body)
    let nameInput = loginInfo["username"].getStr
    let passInput = loginInfo["password"].getStr
    var userLoginAttempt = newUser()
    if dbConn.nameIsAvailable(nameInput):
      resp Http400
    dbConn.select(userLoginAttempt, "username = ?", nameInput)
    let loginSuccessful = bcrypt.verify(passInput, userLoginAttempt.password)
    if loginSuccessful:
      echo "Successful login"
      resp Http200
    else:
      echo "Failed login"
      resp Http400
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
    if not dbConn.nameIsAvailable(request.body):
      resp Http400
    else:
      resp Http200
  get "/test":
    resp readHtml("test")
  get "/motd":
    resp getRandMOTD()
