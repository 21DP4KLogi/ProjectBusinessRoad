# Package

version       = "0.1.0"
author        = "21DP4KLogi"
description   = "A new awesome nimble package"
license       = "AGPL-3.0-or-later"
srcDir        = "src"
bin           = @["ProjectBusinessRoad"]


# Dependencies

requires "nim >= 2.0.0"
# Httpbeast is a dependency of jester, but I am specifying version here as older versions give me a memory leak
requires "httpbeast >= 0.4.2"
requires "jester"
requires "norm"
requires "zippy"
requires "dotenv"
