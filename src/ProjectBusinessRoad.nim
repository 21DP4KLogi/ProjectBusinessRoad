import jester
import std/[segfaults, strutils, random]
import norm/[model, sqlite]
import checksums/bcrypt

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
  get "/test":
    resp readHtml("test")
  get "/motd":
    resp getRandMOTD()
