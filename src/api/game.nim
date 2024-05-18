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
