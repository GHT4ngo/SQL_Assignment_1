SQL_1_Assignment – Personal Number Validation

Author: Christofer Lindholm
Course: DE25
Date: 2025-11-16

Overview

This project contains a SQL Server function:

dbo.ControlPersonalNumber


The purpose of the function is to validate Swedish personal identity numbers (personnummer) according to defined structural and logical rules.

The function returns:

1 → Valid personal identity number

0 → Invalid personal identity number


Function Specification

Function Name

dbo.ControlPersonalNumber

Parameter
@pn VARCHAR(20)


A string representing a Swedish personal identity number.


Accepted Formats

The function supports the following formats:

YYMMDDXXXX
YYMMDD-XXXX
YYMMDD+XXXX
YYYYMMDDXXXX
YYYYMMDD-XXXX
YYYYMMDD+XXXX

Allowed Characters

Digits (0-9)

Hyphen (-)

Plus sign (+)

No other characters are permitted.


Validation Logic

The function validates the input in several steps:


1 Character Validation

Ensures only allowed characters are used.

Rejects any string containing invalid symbols.


2 Format & Length Validation

Verifies correct string length.

Ensures optional - or + appears in the correct position.


3 Date Validation

Ensures century is either 19 or 20.

Confirms that the date portion represents a valid calendar date.

Ensures the date is not in the future.


4 Luhn Algorithm Check

Validates the control digit using the Luhn algorithm.

Project Purpose

This assignment demonstrates:

Input validation in SQL

String manipulation

Date validation logic

Implementation of the Luhn algorithm

Structured function design in T-SQL

How to Use

Create the function in SQL Server.

Execute:

SELECT dbo.ControlPersonalNumber('19900101-1234');


The function will return:

1  -- valid
0  -- invalid
