import jester
import norm/[postgres]
import std/[json, strutils, random, times]
import "../models.nim"
import "./business.nim"

router game:

  extend business, "/business"

  get "/money":
    let token = request.cookies["token"]
    withDb:
      if db.accountExistsWithToken(token):
        var userQuery = newUser()
        db.select(userQuery, "token = $1", token)
        resp $userQuery.money
      else:
        resp Http400

