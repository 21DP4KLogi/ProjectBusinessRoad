import norm/[model, types, postgres]

const startingMoney: int = 10000

type
  User* = ref object of Model
    code*: PaddedStringOfCap[8]
    money*: int
  # Business* = ref object of Model
  #   owner*: User
  #   field*: string
  #   value*: int

func newUser*(cd = newPaddedStringOfCap[8](""), mn = startingMoney): User =
  User(code: cd, money: mn)

# func newBusiness*(us = newUser(), fl = "", vl = 0): Business =
  # Business(owner: us, field: fl, value: vl)

# I don't know if opening and closing the DB connection for
# that one line has any meaningful impact on performance.
proc accountExists*(code: string): bool =
  if code.len != 8: return false
  withDb:
    return db.exists(User, "code = $1", code)
