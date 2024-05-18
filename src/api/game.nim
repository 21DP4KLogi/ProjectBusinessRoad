import jester
import norm/[postgres]
import "../models.nim"

router game:

  get "/money":
    let code = request.cookies["code"]
    if not accountExists(code):
      resp Http400
    var userQuery = newUser()
    withDb:
      db.select(userQuery, "code = $1", code)
      resp $userQuery.money

  get "/foundBusiness/@field":
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
