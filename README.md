# Swedish Personal Number Validator

A SQL Server function that validates Swedish personal identification numbers (personnummer) according to official standards and the Luhn algorithm.

## Overview

This project contains a SQL Server function `dbo.ControlPersonalNumber` that performs comprehensive validation of Swedish personal numbers, including format checking, date validation, and checksum verification using the Luhn algorithm.

## Function Details

### Syntax
```sql
dbo.ControlPersonalNumber(@pn VARCHAR(20))
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `@pn` | VARCHAR(20) | A string representing a Swedish personal number |

### Return Value

| Value | Description |
|-------|-------------|
| `1` | Valid personal number |
| `0` | Invalid personal number |
| `NULL` | Error in processing |

## Supported Formats

The function accepts personal numbers in the following formats:
```
YYMMDDXXXX
YYMMDD-XXXX
YYMMDD+XXXX
YYYYMMDDXXXX
YYYYMMDD-XXXX
YYYYMMDD+XXXX
```

**Valid characters:** Digits (0-9), plus sign (+), minus sign (-)

**Note:** The plus sign (+) is used for individuals over 100 years old, while the minus sign (-) is the standard separator.

## Validation Rules

The function performs the following validation checks:

### 1. Character Validation
- Only allows digits, plus signs, and minus signs
- Rejects any other characters

### 2. Length Validation
- Minimum length: 10 characters
- Maximum length: 13 characters

### 3. Format Validation
- For 11-character format: separator (+/-) must be at position 7
- For 13-character format: separator (+/-) must be at position 9
- Century prefix (if present) must be '19' or '20'

### 4. Date Validation
- Verifies that the date portion represents a valid calendar date
- Ensures the date is not in the future
- Supports both YY and YYYY century formats

### 5. Luhn Algorithm Verification
- Applies the Luhn checksum algorithm to the last 10 digits
- Validates the check digit according to Swedish standards

## Usage Examples

### Basic Usage
```sql
-- Valid personal number
SELECT dbo.ControlPersonalNumber('9001011234');
-- Returns: 1

-- Invalid personal number
SELECT dbo.ControlPersonalNumber('9001011235');
-- Returns: 0
```

### Different Formats
```sql
-- With separator
SELECT dbo.ControlPersonalNumber('900101-1234');

-- With century prefix
SELECT dbo.ControlPersonalNumber('19900101-1234');

-- Person over 100 years old
SELECT dbo.ControlPersonalNumber('1901011234');
```

### Batch Validation
```sql
-- Validate multiple personal numbers
SELECT 
    PersonalNumber,
    dbo.ControlPersonalNumber(PersonalNumber) AS IsValid
FROM 
    Customers;
```

## Installation

### Prerequisites

- SQL Server 2016 or later (uses TRY_CONVERT function)
- Database with permission to create functions

### Installation Steps

1. Connect to your SQL Server database
2. Execute the SQL script to create the function:
```sql
-- Run the entire script from the SQL file
-- The function will be created or altered if it already exists
```

3. Verify the installation:
```sql
SELECT dbo.ControlPersonalNumber('9001011234');
```

## Implementation Details

### Algorithm Flow
```
1. Input Validation
   ├── Check for invalid characters
   ├── Verify length (10-13 characters)
   ├── Validate separator position
   └── Check century prefix

2. Date Extraction and Validation
   ├── Remove separators (+/-)
   ├── Extract date portion (6 or 8 digits)
   ├── Convert to DATE type
   └── Verify date is not in future

3. Luhn Algorithm Calculation
   ├── Extract last 10 digits
   ├── Multiply alternating digits by 2 and 1
   ├── Subtract 9 from results > 9
   ├── Sum all calculated values
   └── Check if sum is divisible by 10

4. Return Result
   └── 1 if valid, 0 if invalid
```

### Luhn Algorithm Implementation

The function implements the Luhn algorithm as follows:
```sql
Position:  1  2  3  4  5  6  7  8  9  10
Multiply:  2  1  2  1  2  1  2  1  2  1
```

- Each digit is multiplied by either 2 or 1
- If the result exceeds 9, subtract 9
- Sum all results
- Valid if sum is divisible by 10

## Testing

### Test Cases
```sql
-- Valid formats
PRINT dbo.ControlPersonalNumber('9001011234');      -- 1
PRINT dbo.ControlPersonalNumber('900101-1234');     -- 1
PRINT dbo.ControlPersonalNumber('19900101-1234');   -- 1

-- Invalid formats
PRINT dbo.ControlPersonalNumber('900101-123X');     -- 0
PRINT dbo.ControlPersonalNumber('990230-1234');     -- 0 (invalid date)
PRINT dbo.ControlPersonalNumber('9001011235');      -- 0 (wrong checksum)

-- Edge cases
PRINT dbo.ControlPersonalNumber('');                -- 0
PRINT dbo.ControlPersonalNumber('123');             -- 0
PRINT dbo.ControlPersonalNumber('18990101-1234');   -- 0 (century not 19/20)
```

## Limitations

- Does not validate coordination numbers (samordningsnummer)
- Does not verify that the personal number is actually issued by Swedish authorities
- Century validation only accepts 19XX and 20XX dates
- Future dates are rejected, even if otherwise valid

## Technical Notes

- Uses `TRY_CONVERT` for safe date conversion without errors
- Implements bitwise logic for efficient odd/even toggling
- Returns BIT type for optimal storage and performance
- Uses `CREATE OR ALTER` for easy updates

## Author

**Christofer Lindholm**
- Assignment: SQL_1_Assignment
- Course: DE25
- Date: 2025-11-16

## License

This project is part of an educational assignment. Please check with the author for usage rights.

## References

- [Swedish Personal Identity Number (Wikipedia)](https://en.wikipedia.org/wiki/Personal_identity_number_(Sweden))
- [Luhn Algorithm](https://en.wikipedia.org/wiki/Luhn_algorithm)
- [Swedish Tax Agency - Personal Identity Numbers](https://skatteverket.se/servicelankar/otherlanguages/inenglish/individualsandemployees/movingtosweden/personalidentitynumberandcoordinationnumber.4.2cf1b5cd163796a5c8b4295.html)
