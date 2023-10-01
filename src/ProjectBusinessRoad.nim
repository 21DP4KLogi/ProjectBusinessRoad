import jester
import std/segfaults

settings:
  staticDir = "dist"

proc readHtml(dirName: string): string =
  return readFile("dist/src/" & dirName & "/index.html")

routes:
  get "/":
    resp readHtml("index")
  get "/test":
    resp readHtml("test")
