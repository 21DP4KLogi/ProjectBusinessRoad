import norm/[model, types, postgres]
import std/options
import json

const startingMoney: int = 10000

type
  User* = ref object of Model
    code*: PaddedStringOfCap[8]
    money*: int
    token*: PaddedStringOfCap[32]
  Business* = ref object of Model
    owner*: Option[User]
    field*: string
    value*: int
    workerSearch*: float
  Employee* = ref object of Model
    name*: StringOfCap[32]
    workplace*: Option[Business]
    proficiency*: string
    interview*: Option[Business]

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
    workerSearch: 0.0,
  )

func newEmployee*(workplace: Option[Business] = none Business): Employee =
  Employee(
    name: newStringOfCap[32]("John Employee"),
    workplace: workplace,
    proficiency: "",
    interview: none Business,
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

# proc isaValidCode*(code: string): bool =
#   code.len == 8

# proc isaValidToken*(token: string): bool =
#   token.len == 32 and token != $PaddedStringOfCap[32]("")

proc accountExistsWithCode*(db: DbConn, code: string): bool =
  db.exists(User, "code = $1", code)

proc accountExistsWithToken*(db: DbConn, token: string): bool =
  token != $newPaddedStringOfCap[32]("") and db.exists(User, "token = $1", token)

proc `%`*(psoc: PaddedStringOfCap): JsonNode =
  result = %($psoc)

proc `%`*(soc: StringOfCap): JsonNode =
  result = %($soc)
