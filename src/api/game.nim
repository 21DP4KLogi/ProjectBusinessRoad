import jester
import norm/[postgres]
import "../models.nim"

router game:

  post "/player/money":
    let sentToken = request.body
    if sentToken == "":
      resp Http400
    var playerQuery = newUser()
    withDb:
      if not db.exists(User, "authToken = $1", sentToken):
        resp Http404
      db.select(playerQuery, "authToken = $1", sentToken)
    resp $playerQuery.money
