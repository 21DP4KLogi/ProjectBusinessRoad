import std/[times, os, strutils, terminal, math]
import norm/[postgres, types]
import dotenv

import "models.nim"

overload()  # Load dotenv file
let dbhost = getEnv("DB_HOST")
let dbuser = getEnv("DB_USER")
let dbpass = getEnv("DB_PASS")
let dbname = getEnv("DB_NAME")
let tickInterval = 1 / getEnv("TICKS_PER_SECOND").parseInt

let dbConn = open(dbhost, dbuser, dbpass, dbname)

var lastTick = epochTime()
var currentTime: float

echo "Project Business Road - Game logic computer"

while true:

  currentTime = epochTime()
  if currentTime == lastTick + tickInterval:
    lastTick = currentTime
    stdout.eraseLine()
    stdout.write("Latest tick: " & $lastTick)
    stdout.flushFile()
    
    if dbConn.count(User) == 0:
      continue

    var allUsers = @[newUser()]
    dbConn.selectAll(allUsers)
    for user in allUsers:
      user.money = currentTime.toInt
    dbConn.update(allUsers)
