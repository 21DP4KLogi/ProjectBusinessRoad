import jester
import norm/[postgres]
import "../models.nim"
import std/[json, strutils]

router business:

  get "/create/@field":
    let code = request.cookies["code"]
    if not accountExists(code):
      resp Http400
    if not BusinessFields.contains @"field":
      resp Http400
    var userQuery = newUser()
    withDb:
      db.select(userQuery, "code = $1", code)
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
    let code = request.cookies["code"]
    if not accountExists(code):
      resp Http400
    var businessQuery = @[newBusiness()]
    var userQuery = newUser()
    # var businessIdList = newSeq[string]()
    withDb:
      db.select(userQuery, "code = $1", code)
      db.select(businessQuery, "owner = $1", userQuery.id)
      # for business in businessQuery:
      #   businessIdList.add($business.id)
      # How the hell do i just send an array?
    resp(%* businessQuery)

  get "/findemployees/@businessID":
    let code = request.cookies["code"]
    if not accountExists(code):
      resp Http400
    withDb:

      var userQuery = newUser()
      db.select(userQuery, "code = $1", code)

      var businessQuery = newBusiness()
      if not db.exists(Business, "id = $1 AND owner = $2", @"businessID".parseInt(), userQuery.id):
        resp Http400
      db.select(businessQuery, "id = $1 AND owner = $2", @"businessID".parseInt(), userQuery.id)

      var employeeQuery = @[newEmployee()]
      if not db.exists(Employee, "workplace IS NULL"):
        resp(%* [])
      db.select(employeeQuery, "workplace IS NULL LIMIT 5")
      resp(%* employeeQuery)

  get "/hireemployee/@businessID/@employeeID":
    let code = request.cookies["code"]
    if not accountExists(code):
      resp Http400
    withDb:

      var userQuery = newUser()
      db.select(userQuery, "code = $1", code)

      var businessQuery = newBusiness()
      if not db.exists(Business, "id = $1 AND owner = $2", @"businessID".parseInt(), userQuery.id):
        resp Http400
      db.select(businessQuery, "id = $1 AND owner = $2", @"businessID".parseInt(), userQuery.id)
      
      var employeeQuery = newEmployee()
      if not db.exists(Employee, "id = $1 AND workplace IS NULL", @"employeeID".parseInt()):
        resp Http400
      db.select(employeeQuery, "id = $1", @"employeeID".parseInt())
      
      businessQuery.owner = some userQuery
      employeeQuery.workplace = some businessQuery
      db.update(employeeQuery)
      resp Http200
