import jester
import std/[segfaults, strutils, sysrand, base64]
import norm/[model, postgres, types]
import "../models.nim"

proc generateAuthToken*(): string =
  let byteseq = urandom(16)
  for entry in byteseq:
    result.add(entry.toHex)

proc generateAccount*(): string =
  urandom(6).encode(safe = true)

router auth:

  get "/login":
    let code = request.params["code"]
    let remember = request.params["remember"].parseBool
    withDb:
      if db.accountExistsWithCode(code):
        var userQuery = newUser()
        db.select(userQuery, "code = $1", code)
        if $userQuery.token == $newPaddedStringOfCap[32](""):
          userQuery.token = newPaddedStringOfCap[32](generateAuthToken())
          db.update(userQuery)
        if remember:
          setCookie("token", $userQuery.token, secure = true, httpOnly = true, sameSite = Strict, path="/", expires = daysForward(7))
        else:
          setCookie("token", $userQuery.token, secure = true, httpOnly = true, sameSite = Strict, path="/")
        resp Http200
      else:
        resp Http400

  get "/register":
    let newAccountCode = generateAccount()
    var userQuery = newUser()
    userQuery.code = newPaddedStringOfCap[8](newAccountCode) 
    withDb:
      db.insert(userQuery)
    resp newAccountCode

  get "/logout":
    setCookie("token", "", secure = true, httpOnly = true, sameSite = Strict, expires = daysForward(-1), path = "/")
    resp Http200

  get "/secureLogout":
    let token = request.cookies["token"]
    setCookie("token", "", secure = true, httpOnly = true, sameSite = Strict, expires = daysForward(-1), path = "/")
    withDb:
      if db.accountExistsWithToken(token):
        var userQuery = newUser()
        db.select(userQuery, "token = $1", token)
        userQuery.token = newPaddedStringOfCap[32]("")
        db.update(userQuery)
        resp Http200
      else:
        resp Http400

  get "/deleteAccount":
    let code = request.params["code"]
    withDb:
      if db.accountExistsWithCode(code):
        var userQuery = newUser()
        db.select(userQuery, "code = $1", code)

        var businessQuery = @[newBusiness()]
        var employeeQuery = @[newEmployee()]

        if db.exists(Business, "owner = $1", userQuery):
          db.select(businessQuery, "owner = $1", userQuery)
          for biz in businessQuery:

            if db.exists(Employee, "workplace = $1 OR interview = $1", biz):
              db.select(employeeQuery, "workplace = $1 OR interview = $1", biz)
              for emp in employeeQuery:
                emp.workplace = none Business
                emp.interview = none Business

              db.update(employeeQuery)
          db.delete(businessQuery)
        db.delete(userQuery)
        resp Http200
      else:
        resp Http400
