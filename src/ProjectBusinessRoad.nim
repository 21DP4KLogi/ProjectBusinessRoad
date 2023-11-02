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
    if registerInfo["password"].getStr.len < 8:
      resp(Http400, "Password too short")
    echo("Username: " & registerInfo["username"].getStr &
    "\nBCrypted password: " & $bcrypt(registerInfo["password"].getStr, generateSalt(6)))  # Low salt level for testing purposes
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
