import jester
import std/[segfaults, strutils, random]
import json
import checksums/bcrypt

settings:
  staticDir = "dist"

proc readHtml(dirName: string): string =
  return readFile("dist/src/" & dirName & "/index.html")

proc getRandMOTD(): string =
  return readFile("src/homepage_messages.txt").splitLines.sample()

routes:
  get "/":
    resp readHtml("index")
  get "/login":
    resp readHtml("login")
  post "/login":
    echo "POST received: " & $request.body
    resp(Http200, "POST req. received")
  get "/register":
    resp readHtml("register")
  post "/register":
    let registerInfo = parseJson(request.body)
    if registerInfo["username"].len < 8:
      resp Http400
    echo("Username: " & $registerInfo["username"] &
    "\nBCrypted password: " & $bcrypt($registerInfo["password"], generateSalt(6)))  # Low salt level for testing purposes
    resp Http200
  get "/test":
    resp readHtml("test")
  get "/motd":
    resp getRandMOTD()
