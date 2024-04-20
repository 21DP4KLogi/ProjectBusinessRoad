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

proc accountExists*(database: DbConn, code: string): bool =
  if code.len != 8: return false
  return database.exists(User, "code = $1", code)
