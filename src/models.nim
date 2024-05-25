import norm/[model, types, postgres]
import std/options
import json

const startingMoney: int = 10000

type
  User* = ref object of Model
    code*: PaddedStringOfCap[8]
    money*: int
  Business* = ref object of Model
    owner*: Option[User]
    field*: string
    value*: int
  Employee* = ref object of Model
    name*: StringOfCap[32]
    workplace*: Option[Business]
    proficiency*: string

func newUser*(): User =
  User(
    code: newPaddedStringOfCap[8](""),
    money: startingMoney,
  )

func newBusiness*(owner: Option[User] = none User): Business =
  Business(
    owner: owner,
    field: "",
    value: 0,
  )

func newEmployee*(workplace: Option[Business] = none Business): Employee =
  Employee(
    name: newStringOfCap[32]("John Employee"),
    workplace: workplace,
    proficiency: "",
  )

const BusinessFields* = [
  "programming",
  "baking",
]

const EmployeeProficiencies* = [
  "taxpayer",
  "usesarchbtw",
  "hungry",
]

# I don't know if opening and closing the DB connection for
# that one line has any meaningful impact on performance.
proc accountExists*(code: string): bool =
  if code.len != 8: return false
  withDb:
    return db.exists(User, "code = $1", code)

proc `%`*(psoc: PaddedStringOfCap): JsonNode =
  result = %($psoc)

proc `%`*(soc: StringOfCap): JsonNode =
  result = %($soc)
