-- Christofer Lindholm, SQL_1_Assignment, DE25, 2025-11-16
/*
    Funktion: dbo.ControlPersonalNumber

    Validerar ett svenskt personnummer genom att kontrollera format,
    födelsedatum och kontrollsiffra enligt Luhn-algoritmen.

    Giltiga format:
        YYMMDDXXXX
        YYMMDD-XXXX
        YYMMDD+XXXX
        YYYYMMDDXXXX
        YYYYMMDD-XXXX
        YYYYMMDD+XXXX

    Avgränsare:
        '-' används när personen är yngre än 100 år.
        '+' används när personen är 100 år eller äldre.

    Parameter:
        @pn VARCHAR(20) - personnumret som ska kontrolleras.

    Returnerar:
        1 = giltigt personnummer
        0 = ogiltigt, tomt eller NULL

    Funktionen kontrollerar inte om personnumret verkligen har utfärdats
    av Skatteverket. Samordningsnummer stöds inte.
*/

CREATE OR ALTER FUNCTION dbo.ControlPersonalNumber (@pn VARCHAR(20))
RETURNS BIT
AS
BEGIN
    -- Tomma värden kan inte vara giltiga personnummer.
    IF @pn IS NULL OR @pn = '' RETURN 0;

    -- Kontrollera längd och att en eventuell avgränsare ligger rätt.
    DECLARE @Length INT = LEN(@pn);
    DECLARE @Separator CHAR(1) = '';
    IF @Length = 11 SET @Separator = SUBSTRING(@pn, 7, 1);
    IF @Length = 13 SET @Separator = SUBSTRING(@pn, 9, 1);

    IF NOT (@Length IN (10, 12)
        OR (@Length = 11 AND @Separator IN ('-', '+'))
        OR (@Length = 13 AND @Separator IN ('-', '+'))) RETURN 0;

    -- Ta bort avgränsaren och kontrollera att resten endast består av siffror.
    DECLARE @Digits VARCHAR(12) = REPLACE(REPLACE(@pn, '-', ''), '+', '');
    IF LEN(@Digits) NOT IN (10, 12) OR @Digits LIKE '%[^0-9]%' RETURN 0;

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    DECLARE @BirthDate DATE;

    IF LEN(@Digits) = 12
        SET @BirthDate = TRY_CONVERT(DATE, LEFT(@Digits, 8), 112);
    ELSE
    BEGIN
        -- Utgå från det senaste århundradet som inte ger ett framtida årtal.
        DECLARE @FullYear INT = (YEAR(@Today) / 100) * 100
                              + CAST(LEFT(@Digits, 2) AS INT);
        IF @FullYear > YEAR(@Today) SET @FullYear = @FullYear - 100;

        SET @BirthDate = TRY_CONVERT(
            DATE, CONCAT(@FullYear, SUBSTRING(@Digits, 3, 4)), 112);

        -- Ett plustecken flyttar datumet ett århundrade bakåt vid behov.
        IF @Separator = '+' AND @BirthDate IS NOT NULL
           AND DATEADD(YEAR, 100, @BirthDate) > @Today
        BEGIN
            SET @FullYear = @FullYear - 100;
            SET @BirthDate = TRY_CONVERT(
                DATE, CONCAT(@FullYear, SUBSTRING(@Digits, 3, 4)), 112);
        END
    END

    IF @BirthDate IS NULL OR @BirthDate > @Today RETURN 0;
    IF @Separator = '-' AND DATEADD(YEAR, 100, @BirthDate) <= @Today RETURN 0;
    IF @Separator = '+' AND DATEADD(YEAR, 100, @BirthDate) > @Today RETURN 0;

    -- Luhn använder de sista tio siffrorna, även när århundrade anges.
    DECLARE @LuhnDigits VARCHAR(10) = RIGHT(@Digits, 10);
    DECLARE @Position INT = 1;
    DECLARE @Sum INT = 0;
    DECLARE @Value INT;

    WHILE @Position <= 10
    BEGIN
        -- Multiplicera växelvis med 2 och 1. Tvåsiffriga resultat minskas med 9.
        SET @Value = CAST(SUBSTRING(@LuhnDigits, @Position, 1) AS INT)
                   * CASE WHEN @Position % 2 = 1 THEN 2 ELSE 1 END;
        IF @Value > 9 SET @Value = @Value - 9;
        SET @Sum = @Sum + @Value;
        SET @Position = @Position + 1;
    END

    IF @Sum % 10 = 0 RETURN 1;
    RETURN 0;
END;
GO
