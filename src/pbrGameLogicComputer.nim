import std/[times, os, strutils, terminal, random]
import norm/[postgres]
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
  if currentTime < lastTick + tickInterval:
    # Sleep timer added to prevent using 100% of thread during downtime, of which there is a lot
    # Side effect is that the intervals are no longer exactly 1 second, but about 1.001 seconds
    sleep((((lastTick + tickInterval) - currentTime) * 1000).toInt)
    continue

  lastTick = currentTime
  stdout.eraseLine()
  stdout.write("Latest tick: " & $lastTick)
  stdout.flushFile()
  
  let userCount = dbConn.count(User)
  if userCount == 0:
    continue

  var allUsers = @[newUser()]
  dbConn.selectAll(allUsers)
  for user in allUsers:
    if not dbConn.exists(Business, "owner = $1", user.id):
      continue
    var businessQuery = @[newBusiness()]
    dbConn.select(businessQuery, "owner = $1", user.id)

    for business in businessQuery:
      var employeeQuery = @[newEmployee()]

      if not dbConn.exists(Employee, "workplace = $1", business.id):
        continue
      dbConn.select(employeeQuery, "workplace = $1", business.id)

      for employee in employeeQuery:
        # BUG: Since money is an Int, a tickrate that is too high might round it to zero
        user.money += (5 * tickInterval).toInt

  dbConn.update(allUsers)
  

  let employeeCount = dbConn.count(Employee)
  
  if employeeCount < userCount * 2:
    for i in (employeeCount + 1)..(userCount * 2):
      var employeeQuery = newEmployee()
      employeeQuery.proficiency = EmployeeProficiencies.sample()
      dbConn.insert(employeeQuery)
