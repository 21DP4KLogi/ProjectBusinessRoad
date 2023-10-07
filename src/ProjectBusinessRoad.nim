import jester
import std/segfaults

settings:
  staticDir = "dist"

proc readHtml(dirName: string): string =
  return readFile("dist/src/" & dirName & "/index.html")

routes:
  get "/":
    resp readHtml("index")
  get "/login":
    resp readHtml("login")
  get "/register":
    resp readHtml("register")
  get "/test":
    resp readHtml("test")
