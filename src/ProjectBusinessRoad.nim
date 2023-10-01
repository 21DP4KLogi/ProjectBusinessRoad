import jester
import std/segfaults

routes:
  get "/":
    resp readFile("index.html")
