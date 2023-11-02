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
  post "/login/submitinfo":
    echo "Login request received"
    resp Http200
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
