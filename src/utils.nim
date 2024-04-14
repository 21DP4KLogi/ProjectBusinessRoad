import std/[segfaults, strutils, random, sysrand]
import norm/[model, postgres]
import "./models.nim"

proc getRandMOTD*(): string =
  return readFile("src/homepage_messages.txt").splitLines.sample()

proc nameIsAvailable*(database: DbConn, username: string): bool =
  return database.count(User, "*", dist = false, "username = $1", username) == 0

proc generateAuthToken*(): string =
  let byteseq = urandom(32)
  for entry in byteseq:
    result.add(entry.toHex)
