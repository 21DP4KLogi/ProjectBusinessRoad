import jester
import std/[segfaults, strutils, sysrand, base64]
import norm/[model, postgres, types]
import "../models.nim"

proc accountExists*(database: DbConn, code: string): bool =
  if code.len != 8: return false
  return database.exists(User, "code = $1", code)

# proc generateAuthToken*(): string =
#   let byteseq = urandom(32)
#   for entry in byteseq:
#     result.add(entry.toHex)

proc generateAccount*(): string =
  result = urandom(6).encode(safe = true)

router auth:

  get "/login":
    let code = request.params["code"]
    let remember = request.params["remember"].parseBool
    withDb:
      if code.len == 8 and db.accountExists(code):
        if remember:
          setCookie("code", code, secure = true, httpOnly = true, sameSite = Strict, path="/", expires = daysForward(7))
        else:
          setCookie("code", code, secure = true, httpOnly = true, sameSite = Strict, path="/")
        resp Http200
      else:
        resp Http400

  get "/register":
    let newAccountCode = generateAccount()
    var userQuery = newUser(cd = newPaddedStringOfCap[8](newAccountCode))
    withDb:
      db.insert(userQuery)
    resp newAccountCode

  get "/logout":
    setCookie("code", "", secure = true, httpOnly = true, sameSite = Strict, expires = daysForward(-1), path = "/")
    resp Http200