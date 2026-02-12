
--===================================================================--
--=     Christofer Lindholm                 2025-11-16              =--
--=     SQL_1_Assignment                    DE25                    =--
--===================================================================--
/*
    Funktion:       dbo.ControlPersonalNumber
    Parameter:      @pn (VARCHAR(20))
                    En sträng som representerar ett svenskt personnummer.

    Giltiga format:
        YYMMDDXXXX
        YYMMDD-XXXX
        YYMMDD+XXXX
        YYYYMMDDXXXX
        YYYYMMDD-XXXX
        YYYYMMDD+XXXX

    Tillåtna tecken:
        Endast siffror samt '+' eller '-'.

    Syfte:
        Att validera ett svenskt personnummer i den mån det går genom att:

        *   Kontrollera att strängen inte innehåller ogiltiga tecken.
        *   Kontrollera att formatet och längden är korrekt.
        *   Kontrollera att ev. +/- ligger på rätt position.
        *   Kontrollera datumdelen:
               - Att århundrandet är 19 eller 20  
               - Att datumet är giltigt
               - Att datumet inte ligger i framtiden
        *   Kontrollera personnumret mot Luhn-algoritmen.

    Returnerar:
        1 = giltigt personnummer
        0 = ogiltigt personnummer
*/


-- PRINT dbo.ControlPersonalNumber('4707059376') 




CREATE OR ALTER FUNCTION dbo.ControlPersonalNumber (@pn VARCHAR(20))
RETURNS BIT                                                                 -- Returerar 0,1 eller NULL
AS
BEGIN
    DECLARE @Date DATE;                                                     -- Datumvariabel som används för att kontrollera om det är ett datum
    
    IF @pn NOT LIKE '%[^0-9+\-]%' AND                                       -- Får inte innehålla annat än siffror eller +/- tecken
        LEN(@pn) BETWEEN 10 AND 13 AND                                      -- Minst 10 tecken, max 13
        (LEN(@pn) <> 11 OR SUBSTRING(@pn, 7, 1) IN ('+', '-')) AND          -- +/- på rätt plats om det är 11 tecken                         
        (LEN(@pn) <> 13 OR SUBSTRING(@pn, 9, 1) IN ('+', '-')) AND          -- +/- på rätt plats om det är 13 tecken, med århundrande
        (LEN(@pn) <= 11 OR SUBSTRING(@pn, 1, 2) IN ('19','20'))             -- Århundrade måste vara 19 eller 20
    
    BEGIN                                                            
        SET @pn = REPLACE(REPLACE(@pn, '-', ''), '+', '')                   -- Tar bort ev. + och - från personnummret
        
        IF LEN(@pn) = 10                                                    
            SET @Date = TRY_CONVERT(DATETIME2, LEFT(@pn, 6), 12);           -- Försöker konvertera till datum
        ELSE                                                                 
            SET @Date = TRY_CONVERT(DATETIME2, LEFT(@pn, 8), 112);          -- 10 siffror mot yymmdd, annars yyyymmdd
        IF @Date IS NULL --OR @Date > GETDATE()                               -- Om siffrorna inte är ett godkännt datum, 
        BEGIN                                                               -- eller om det är i framtiden,
            RETURN 0;                                                       -- Så avslutas testet
        END
    END 
    ELSE
    BEGIN
        RETURN 0;                                                           -- 0: Klarade inte de första testet
    END

    DECLARE @Pos INT = 1;                                                   -- Variabel för vilken siffra i personnummret som vi räknar på
    DECLARE @Luhn INT = 0;                                                  -- Variabel för spara Luhn-uträkningen
    DECLARE @Calc INT;                                                      -- Variabel för att genomföra Luhn-uträkningen
    DECLARE @OddEven INT = 2;                                               -- Variabel för veta om det ska multipliceras med 1 eller 2
    SET @pn = RIGHT(@pn, 10);                                               -- Ta bort ev. århundrande
    
    WHILE @Pos <= 10                                                        -- Fortsätt att räkna tills alla tio siffrorna har varit med
        BEGIN
            SET @Calc = CAST(SUBSTRING(@pn, @Pos, 1)AS INT) * @OddEven;     -- Multiplicera siffran med 1 eller 2 
            IF @Calc > 9                                                    -- Om resultatet är högre än 9, ta bort 9
                SET @Calc = @Calc - 9;
                
            SET @OddEven = 3 - @OddEven;                                    -- Ändra 2 -> 1, eller 1 -> 2

            SET @Luhn = @Luhn + @Calc;                                      -- Lägg till kalkuleringen till Luhn-uträkningen

            SET @Pos = @Pos + 1;                                            -- Gå vidare till nästa siffra
        END
    IF @Luhn % 10 = 0                                                       -- Om Luhn-uträkningen är delbar med 10 så är det godkännt
        RETURN 1;                                                           -- Klarade alla tester! Giltigt personnummer
         
RETURN 0;                                                                   -- Klarade inte alla tester, Ogiltigt personnummer 
END;
GO
