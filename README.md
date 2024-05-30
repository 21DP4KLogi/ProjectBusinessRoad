# Project Business Road

Welcome to the Business Road! A game about business, money and uh... other stuff once i implement it.

## !!! Experimental software !!!

Cannot yet gurantee compliance with modern security, privacy or efficiency standards.

## Setup

This program is made using the Nim programming language and therefore requires its compiler, which is available at https://nim-lang.org.
This program also requires a PostgreSQL database.

Once Nim is installed, you will need to use its package manager to install the needed libraries and build the project.

To install the needed libraries, run:
`nimble install -d`

To build the project, run:
`nimble build`

Make sure to set up your database and the enviroment by creating a .env file from the template and using your desired values.

Should now be ready, just run both pbrWebServer and pbrGameLogicComputer.
