import jester
import std/[segfaults, strutils, random, sysrand]
import norm/[model, postgres]
import checksums/bcrypt
import json
import zippy

const startingMoney: int = 10000

type
  User = ref object of Model
    username: string
    password: string
    money: int
    authToken: string
  Business = ref object of Model
    owner: User
    field: string
    value: int

func newUser(un = "", pw = "", mn = startingMoney, at = ""): User =
  User(username: un, password: pw, money: mn, authToken: at)

func newBusiness(us = newUser(), fl = "", vl = 0): Business =
  Business(owner: us, field: fl, value: vl)

proc getRandMOTD(): string =
  return readFile("src/homepage_messages.txt").splitLines.sample()

proc nameIsAvailable(database: DbConn, username: string): bool =
  return database.count(User, "*", dist = false, "username = $1", username) == 0

proc generateAuthToken(): string =
  let byteseq = urandom(32)
  for entry in byteseq:
    result.add(entry.toHex)

let dbConn = open("localhost", "postgres", "postgres", "PBRdata")
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
    if dbConn.nameIsAvailable(sentUsername):  # Reject if username doesnt exist
      resp "NameNotFound"
    var userLoginAttempt = newUser()
    dbConn.select(userLoginAttempt, "username = $1", sentUsername)
    let loginSuccessful = bcrypt.verify(sentPassword, userLoginAttempt.password)
    if loginSuccessful:
      userLoginAttempt.authToken = generateAuthToken()
      dbConn.update(userLoginAttempt)
      resp $userLoginAttempt.authToken
    else:
      resp "Failure"

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
      resp "NameAlreadyTaken"
    let
      generatedSalt = generateSalt(6)
      hashedPassword = $bcrypt(sentPassword, generatedSalt)  # Low password salt for testing purposes
    var newRegisteredUser = newUser(sentUsername, hashedPassword)
    dbConn.insert(newRegisteredUser)
    resp "Success"

  post "/register/checkname":
    if dbConn.nameIsAvailable(request.body):
      resp "NameIsAvailable"
    else:
      resp "NameIsTaken"

  post "/logout":
    # Removes authtoken from account, requiring a new log in
    let sentToken = request.body
    if not dbConn.exists(User, "authToken = $1", sentToken):
      resp Http404
    var playerQuery = newUser()
    dbConn.select(playerQuery, "authToken = $1", sentToken)
    playerQuery.authToken = ""
    dbConn.update(playerQuery)
    resp Http200

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
    setHeader(responseHeaders, "Content-Encoding", "g-zip")
    resp compress(readfile("public/jquery-3.7.1.min.js"), BestSpeed, dfGzip)

runForever()