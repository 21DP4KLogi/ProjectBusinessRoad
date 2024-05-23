import jester
import norm/[postgres]
import "../models.nim"
import std/json

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
