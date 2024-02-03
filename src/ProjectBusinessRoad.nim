import jester
import std/[segfaults, strutils, random]
import norm/[model, sqlite]
import checksums/bcrypt
import json

const startingMoney: int = 10000

type
  User = ref object of Model
    username: string
    password: string
    money: int
  Business = ref object of Model
    owner: User
    field: string
    value: int

func newUser(un = "", pw = "", mn = startingMoney): User =
  User(username: un, password: pw, money: mn)

func newBusiness(us = newUser(), fl = "", vl = 0): Business =
  Business(owner: us, field: fl, value: vl)

proc getRandMOTD(): string =
  return readFile("src/homepage_messages.txt").splitLines.sample()

proc nameIsAvailable(database: DbConn, username: string): bool =
  return database.count(User, "*", dist = false, "username = ?", username) == 0

let dbConn = open("PBRdata.db", "", "", "")
dbConn.createTables(newUser())
dbConn.createTables(newBusiness())

routes:

  get "/":
    resp readFile("src/index.html")

  post "/login/submitinfo":
    let
      requestBody = parseJson(request.body)
      sentUsername = requestBody["username"].getStr
      sentPassword = requestBody["password"].getStr
    if sentUsername == "" or sentPassword == "":  # Reject if either input is empty
      resp Http400
    var userLoginAttempt = newUser()
    if dbConn.nameIsAvailable(sentUsername):  # Reject if username doesnt exist
      resp Http400
    dbConn.select(userLoginAttempt, "username = ?", sentUsername)
    let loginSuccessful = bcrypt.verify(sentPassword, userLoginAttempt.password)
    if loginSuccessful:
      resp Http200
    else:
      resp Http400

  post "/register/submitinfo":
    let
      requestBody = parseJson(request.body)
      sentUsername = requestBody["username"].getStr
      sentPassword = requestBody["password"].getStr
    if sentUsername == "":  # Reject if username string is empty
      resp Http400
    if sentPassword.len < 8:  # Reject if password too short
      resp Http400
    if not dbConn.nameIsAvailable(sentUsername):  # Reject if username already used
      resp Http400
    let
      generatedSalt = generateSalt(6)
      hashedPassword = $bcrypt(sentPassword, generatedSalt)  # Low password salt for testing purposes
    var newRegisteredUser = newUser(sentUsername, hashedPassword)
    dbConn.insert(newRegisteredUser)
    resp Http200

  post "/register/checkname":
    if dbConn.nameIsAvailable(request.body):
      resp Http200
    else:
      resp Http400

  get "/motd":
    resp getRandMOTD()
    
  post "/player/money":
    let
      requestBody = parseJson(request.body)
      sentUsername = requestBody["username"].getStr
    # Need code to verify that user token matches one of an authorized user, for now just lets through
    if dbConn.nameIsAvailable(sentUsername):
      resp Http400
    var playerQuery = newUser()
    dbConn.select(playerQuery, "username = ?", sentUsername)
    resp $playerQuery.money

runForever()