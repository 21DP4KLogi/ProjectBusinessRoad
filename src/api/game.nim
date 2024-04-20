import jester
import norm/[postgres]
import "../models.nim"

router game:

  get "/money":
    let code = request.cookies["code"]
    if code.len != 8:
      resp Http400
    var userQuery = newUser()
    if not accountExists(code):
      resp Http400
    withDb:
      db.select(userQuery, "code = $1", code)
      resp $userQuery.money
