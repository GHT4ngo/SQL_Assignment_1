-- Run ControlPersonalNumber.sql before this file.

DECLARE @Tests TABLE
(
    TestName VARCHAR(50),
    PersonalNumber VARCHAR(20),
    Expected BIT
);

INSERT INTO @Tests (TestName, PersonalNumber, Expected)
VALUES
    ('Valid number',              '4707059376',   1),
    ('Valid number with dash',    '470705-9376',  1),
    ('Valid number with century', '194707059376', 1),
    ('Invalid checksum',          '4707059377',   0),
    ('Invalid date',              '9902301234',   0),
    ('Invalid character',         '470705-93X6',  0),
    ('Wrong separator position',  '47070-59376',  0),
    ('Too short',                 '123',          0),
    ('Empty input',               '',             0),
    ('NULL input',                NULL,           0);

SELECT
    TestName,
    PersonalNumber,
    Expected,
    dbo.ControlPersonalNumber(PersonalNumber) AS Actual,
    CASE WHEN dbo.ControlPersonalNumber(PersonalNumber) = Expected
         THEN 'PASS' ELSE 'FAIL' END AS Result
FROM @Tests;
