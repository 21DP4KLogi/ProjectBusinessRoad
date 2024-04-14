import jester
import std/[segfaults, strutils]
import norm/[model, postgres, types]
import checksums/bcrypt
import json
import "../models.nim"
import "../utils.nim"

router auth:

  post "/login/submitinfo":
    let
      requestBody = parseJson(request.body)
      sentUsername = requestBody["username"].getStr
      sentPassword = requestBody["password"].getStr
    if sentUsername == "" or sentPassword == "":  # Reject if either input is empty
      resp Http400
    withDb:
      if db.nameIsAvailable(sentUsername):  # Reject if username doesnt exist
        resp "NameNotFound"
      var userLoginAttempt = newUser()
      db.select(userLoginAttempt, "username = $1", sentUsername)
      let loginSuccessful = bcrypt.verify(sentPassword, $userLoginAttempt.password)
      if loginSuccessful:
        userLoginAttempt.authToken = generateAuthToken()
        db.update(userLoginAttempt)
        resp $userLoginAttempt.authToken
      else:
        resp "Failure"

  post "/register/submitinfo":
    let
      requestBody = parseJson(request.body)
      sentUsername = requestBody["username"].getStr
      sentPassword = requestBody["password"].getStr
    if sentUsername == "":  # Reject if username string is empty
      resp Http400
    if sentPassword.len < 8:  # Reject if password too short
      resp Http400
    withDb:
      if not db.nameIsAvailable(sentUsername):  # Reject if username already used
        resp "NameAlreadyTaken"
      let
        generatedSalt = generateSalt(6)
        hashedPassword = $bcrypt(sentPassword, generatedSalt)  # Low password salt for testing purposes
      var newRegisteredUser = newUser(sentUsername, newPaddedStringOfCap[60](hashedPassword))
      db.insert(newRegisteredUser)
      resp "Success"

  post "/register/checkname":
    withDb:
      if db.nameIsAvailable(request.body):
        resp "NameIsAvailable"
      else:
        resp "NameIsTaken"

  post "/logout":
    # Removes authtoken from account, requiring a new log in
    withDB:
      let sentToken = request.body
      if not db.exists(User, "authToken = $1", sentToken):
        resp Http404
      var playerQuery = newUser()
      db.select(playerQuery, "authToken = $1", sentToken)
      playerQuery.authToken = ""
      db.update(playerQuery)
    resp Http200
