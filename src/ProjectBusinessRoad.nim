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
  post "/login/submitinfo":
    let loginInfo = parseJson(request.body)
    let nameInput = loginInfo["username"].getStr
    let passInput = loginInfo["password"].getStr
    if nameInput == "" or passInput == "":  # Reject if either input is empty
      resp Http400
    var userLoginAttempt = newUser()
    if dbConn.nameIsAvailable(nameInput):  # Reject if username doesnt exist
      resp Http400
    dbConn.select(userLoginAttempt, "username = ?", nameInput)
    let loginSuccessful = bcrypt.verify(passInput, userLoginAttempt.password)
    if loginSuccessful:
      resp Http200
    else:
      resp Http400
  post "/register/submitinfo":
    let registerInfo = parseJson(request.body)
    if registerInfo["username"].getStr == "":  # Reject if username string is empty
      resp Http400
    if registerInfo["password"].getStr.len < 8:  # Reject if password too short
      resp Http400
    if not dbConn.nameIsAvailable(registerInfo["username"].getStr):  # Reject if username already used
      resp Http400
    let hashedPassword = $bcrypt(registerInfo["password"].getStr, generateSalt(6))  # Low password salt for testing purposes
    var newRegisteredUser = newUser(registerInfo["username"].getStr, hashedPassword)
    dbConn.insert(newRegisteredUser)
    resp Http200
  post "/register/checkname":
    if dbConn.nameIsAvailable(request.body):
      resp Http200
    else:
      resp Http400
  get "/game":
    resp readHtml("game")
  get "/motd":
    resp getRandMOTD()
