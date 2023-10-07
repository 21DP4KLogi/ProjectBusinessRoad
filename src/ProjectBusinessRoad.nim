import jester
import std/[segfaults, strutils, random]

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
  get "/register":
    resp readHtml("register")
  get "/test":
    resp readHtml("test")
  get "/motd":
    resp getRandMOTD()
