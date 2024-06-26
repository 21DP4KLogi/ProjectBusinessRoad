import jester
import std/[random, strutils]
import zippy

const MOTDs* = [
  "A donation a day keeps the tax audit away!",
  "moneymoneymoneymoneymoneymoneymoneymoneymoneymoney",
  "Finest business simulator since UNDEFINED!",
  "Budget does not exceed 17 Yen",
  "Generates interest!",
  "Free (as in Libre) money!",
  "Hey, nice credit card number!",
  "Nice profi- Aaaaand, its gone!",
  "Noticeably Fungible (legal-)Tender",
  "In this economy!",
  "Whatd'ya buyin'?",
  "Making dough at the bakery",
  "INSERT QUARTER",
  "[$ @ $]",
  "\";UPDATE \"User\" SET money = 1000000 WHERE TRUE;--",
]

router page:

  get "/motd":
    resp MOTDs.sample()

  get "/jquery.js":
    setHeader(responseHeaders, "Content-Encoding", "gzip")
    resp compress(readfile("public/jquery-3.7.1.min.js"), BestSpeed, dfGzip), contentType = "application/javascript"
    # Content-Type added as it would otherwise return as text/html and browsers wont run it
    # Although text/javascript is more recommended, jester uses application/javascript, so i do aswell for consistency
