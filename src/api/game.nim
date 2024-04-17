import jester
import norm/[postgres]
import "../models.nim"

# TODO: Don't make this function appear both here and in auth.nim
proc accountExistsTwo*(database: DbConn, code: string): bool =
  if code.len > 8: return false
  return database.exists(User, "code = $1", code)

router game:

  get "/money":
    let code = request.cookies["code"]
    if code.len != 8:
      resp Http400
    var userQuery = newUser()
    withDb:
      if not db.accountExistsTwo(code):
        resp Http400
      db.select(userQuery, "code = $1", code)
      resp $userQuery.money
