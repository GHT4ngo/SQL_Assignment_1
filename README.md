# Swedish Personal Identity Number Validator

> This project has moved to
> [`sql-assignments/assignment-01-personnummer`](https://github.com/GHT4ngo/sql-assignments/tree/main/assignment-01-personnummer).
> This repository is retained as a read-only archive.

A small SQL Server function that validates Swedish personal identity numbers
(`personnummer`). It checks the format, birth date and Luhn checksum.

## Supported formats

```text
YYMMDDXXXX
YYMMDD-XXXX
YYMMDD+XXXX
YYYYMMDDXXXX
YYYYMMDD-XXXX
YYYYMMDD+XXXX
```

`-` is used when the person is under 100 years old. `+` is used when the person
is at least 100 years old. For a 10-digit number, the century is inferred from
the current date and separator.

## Return value

- `1` means valid.
- `0` means invalid, empty or `NULL`.

The function validates the number's structure. It cannot confirm that the
Swedish Tax Agency issued it. Coordination numbers (`samordningsnummer`) are
not supported.

## Installation

Requires SQL Server 2016 or later and permission to create functions. Run
[`ControlPersonalNumber.sql`](ControlPersonalNumber.sql) in the database:

```sql
SELECT dbo.ControlPersonalNumber('4707059376');
-- 1
```

## Testing

After installing the function, run [`tests.sql`](tests.sql). Every row should
show `PASS`.

## Author

Christofer Lindholm<br>
SQL_1_Assignment, DE25<br>
2025-11-16

## License

MIT License. See [`LICENSE`](LICENSE).
