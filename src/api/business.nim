import jester
import norm/[postgres]
import "../models.nim"
import std/[json, strutils, random, times]

router business:

  get "/create/@field":
    let token = request.cookies["token"]
    withDb:
      if not db.accountExistsWithToken(token):
        resp Http400
      if not BusinessFields.contains @"field":
        resp Http400
      var userQuery = newUser()
      db.select(userQuery, "token = $1", token)
      if userQuery.money >= 5000:
        var businessQuery = newBusiness()
        businessQuery.owner = some userQuery
        businessQuery.field = @"field"
        businessQuery.value = 5000
        userQuery.money -= 5000
        db.insert(businessQuery)
        db.update(userQuery)
      resp Http200 
  
  get "/list":
    let token = request.cookies["token"]
    withDb:
      if not db.accountExistsWithToken(token):
        resp Http400
      var businessQuery = @[newBusiness()]
      var userQuery = newUser()
      db.select(userQuery, "token = $1", token)
      db.select(businessQuery, "owner = $1", userQuery)
      resp(%* {"businesses": businessQuery})

  get "/inspectbusiness/@businessID":
    let token = request.cookies["token"]
    withDb:
      if not db.accountExistsWithToken(token):
        resp Http400

      var userQuery = newUser()
      var businessQuery = newBusiness()
      var employeeQueryWorking = @[newEmployee()]
      var employeeQueryPotential = @[newEmployee()]

      db.select(userQuery, "token = $1", token)
      if not db.exists(Business, "id = $1 AND owner = $2", @"businessID".parseInt, userQuery):
        resp Http400
      db.select(businessQuery, "id = $1", @"businessID".parseInt)

      if db.exists(Employee, "workplace = $1", businessQuery):
        db.select(employeeQueryWorking, "workplace = $1", businessQuery)
      else:
        employeeQueryWorking = @[]

      if db.exists(Employee, "interview = $1", businessQuery):
        db.select(employeeQueryPotential, "interview = $1", businessQuery)
      else:
        employeeQueryPotential = @[]

      resp(%* {"business": businessQuery, "employees": employeeQueryWorking, "interviewees": employeeQueryPotential})

  get "/findemployees/@businessID":
    let token = request.cookies["token"]
    withDb:
      if not db.accountExistsWithToken(token):
        resp Http400

      var userQuery = newUser()
      db.select(userQuery, "token = $1", token)

      var businessQuery = newBusiness()
      if not db.exists(Business, "id = $1 AND owner = $2", @"businessID".parseInt(), userQuery.id):
        resp Http400
      db.select(businessQuery, "id = $1 AND owner = $2", @"businessID".parseInt(), userQuery.id)

      var employeeQuery = @[newEmployee()]
      if not db.exists(Employee, "workplace IS NULL"):
        resp(%* [])
      db.select(employeeQuery, "workplace IS NULL LIMIT 15")
      
      var availableWorkers = newSeq[Employee]()
      for i in 1..3:
        var randomEmployee = employeeQuery.sample()
        availableWorkers.add randomEmployee
        randomEmployee.interview = some businessQuery
        db.update(randomEmployee)

      businessQuery.workerSearch = epochTime()
      businessQuery.owner = some userQuery
      db.update(businessQuery)

      resp(%* {"interviewees": availableWorkers})

  get "/hireemployee/@businessID/@employeeID":
    let token = request.cookies["token"]
    withDb:
      if not db.accountExistsWithToken(token):
        resp Http400

      var userQuery = newUser()
      db.select(userQuery, "token = $1", token)

      var businessQuery = newBusiness()
      if not db.exists(Business, "id = $1 AND owner = $2", @"businessID".parseInt(), userQuery.id):
        resp Http400
      db.select(businessQuery, "id = $1 AND owner = $2", @"businessID".parseInt(), userQuery.id)
      
      var employeeQuery = newEmployee()
      if not db.exists(Employee, "id = $1 AND interview = $2", @"employeeID".parseInt(), businessQuery):
        resp Http400
      db.select(employeeQuery, "id = $1", @"employeeID".parseInt())
      
      businessQuery.owner = some userQuery
      employeeQuery.workplace = some businessQuery
      employeeQuery.interview = none Business
      db.update(employeeQuery)
      resp Http200
