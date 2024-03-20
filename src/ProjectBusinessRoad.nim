import jester
import std/[segfaults, strutils, random, sysrand, os]
import norm/[model, postgres, types]
import checksums/bcrypt
import json
import zippy
import dotenv

const startingMoney: int = 10000

type
  User = ref object of Model
    username: string
    password: PaddedStringOfCap[60]
    money: int
    authToken: string
  Business = ref object of Model
    owner: User
    field: string
    value: int

func newUser(un = "", pw = newPaddedStringOfCap[60](""), mn = startingMoney, at = ""): User =
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
    let loginSuccessful = bcrypt.verify(sentPassword, $userLoginAttempt.password)
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
    var newRegisteredUser = newUser(sentUsername, newPaddedStringOfCap[60](hashedPassword))
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
    setHeader(responseHeaders, "Content-Encoding", "gzip")
    resp compress(readfile("public/jquery-3.7.1.min.js"), BestSpeed, dfGzip), contentType = "application/javascript"
    # Content-Type added as it would otherwise return as text/html and browsers wont run it
    # Although text/javascript is more recommended, jester uses application/javascript, so i do aswell for consistency

runForever()