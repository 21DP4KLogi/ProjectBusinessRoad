import jester
import std/[segfaults, strutils, sysrand, base64, os, json]
import norm/[model, postgres, types]
import nimcrypto/[sha2, hmac]
import "../models.nim"
import dotenv

overload()
echo getEnv("ALTCHA_COMPLEXITY")
const complexity* = 100000
const hmacKey* = getEnv("ALTCHA_HMACKEY")

proc generateAuthToken*(): string =
  let byteseq = urandom(16)
  for entry in byteseq:
    result.add(entry.toHex)

proc generateAccount*(): string =
  urandom(6).encode(safe = true)

proc isAltchaSolved*(payload: string): bool =
  let data = decode(payload).parseJson()

  let alg_ok = data["algorithm"].getStr == "SHA-256"
  let challenge_ok = data["challenge"].getStr == toLower($sha256.digest(data["salt"].getStr & $data["number"].getInt))
  let signature_ok = data["signature"].getStr == toLower($sha256.hmac(hmacKey, data["challenge"].getStr))
  
  if alg_ok and challenge_ok and signature_ok:
    return true

  else:
    return false

router auth:

  get "/login":
    if not isAltchaSolved(request.params["altcha"]):
      resp Http400
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
    if not isAltchaSolved(request.params["altcha"]):
      resp Http400
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
    if not isAltchaSolved(request.params["altcha"]):
      resp Http400
    let code = request.params["code"]
    withDb:
      if db.accountExistsWithCode(code):
        var userQuery = newUser()
        db.select(userQuery, "code = $1", code)

        var businessQuery = @[newBusiness()]

        if db.exists(Business, "owner = $1", userQuery):
          db.select(businessQuery, "owner = $1", userQuery)
          for biz in businessQuery:
            db.exec(sql "UPDATE \"Employee\" SET workplace = NULL WHERE workplace = $1", dbValue(biz))
            db.exec(sql "UPDATE \"Employee\" SET interview = NULL WHERE interview = $1", dbValue(biz))

          db.delete(businessQuery)
        db.delete(userQuery)
        resp Http200
      else:
        resp Http400
  
  get "/getAltcha":

    let saltRandomBytes = urandom(5)
    var salt: string
    for i in saltRandomBytes:
      salt.add i.toHex
    salt = salt.toLower()
    
    let numRandomBytes = urandom(8)
    var randomNumber: uint
    for i in 0..(numRandomBytes.len - 1):
      randomNumber += numRandomBytes[i]
      randomNumber = randomNumber shl 8
    let secretNumber = randomNumber mod complexity

    let challenge = toLower($sha256.digest(salt & $secretNumber))

    let signature = toLower($sha256.hmac(hmacKey, challenge))

    resp(%* {
      "algorithm": "SHA-256",
      "challenge": challenge,
      "salt": salt,
      "signature": signature,
    })
