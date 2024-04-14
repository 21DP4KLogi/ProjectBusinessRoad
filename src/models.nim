import norm/[model, types]

const startingMoney: int = 10000

type
  User* = ref object of Model
    username*: string
    password*: PaddedStringOfCap[60]
    money*: int
    authToken*: string
  Business* = ref object of Model
    owner*: User
    field*: string
    value*: int

func newUser*(un = "", pw = newPaddedStringOfCap[60](""), mn = startingMoney, at = ""): User =
  User(username: un, password: pw, money: mn, authToken: at)

func newBusiness*(us = newUser(), fl = "", vl = 0): Business =
  Business(owner: us, field: fl, value: vl)
