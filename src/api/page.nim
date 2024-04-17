import jester
import std/[random, strutils]
import zippy

proc getRandMOTD*(): string =
  return readFile("src/homepage_messages.txt").splitLines.sample()

router page:

  get "/motd":
    resp getRandMOTD()

  get "/jquery.js":
    setHeader(responseHeaders, "Content-Encoding", "gzip")
    resp compress(readfile("public/jquery-3.7.1.min.js"), BestSpeed, dfGzip), contentType = "application/javascript"
    # Content-Type added as it would otherwise return as text/html and browsers wont run it
    # Although text/javascript is more recommended, jester uses application/javascript, so i do aswell for consistency
