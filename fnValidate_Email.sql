USE S_Sandooyea_Shop2

ALTER FUNCTION Validate_Email(@email VARCHAR(50))
RETURNS INTEGER
AS
BEGIN
	DECLARE @valid INTEGER

	SET @valid = 0

	If @email LIKE '^\S+@\S+\.\S+$'
	SET @valid = 1

	RETURN @valid
END;

ALTER TABLE tblSupplier
DROP COLUMN balanceDue

SELECT * FROM tblSupplier

ALTER TABLE tblSupplier
ADD  balanceDue DOUBLE PRECISION DEFAULT 0.0

ALTER TABLE tblPurchases
DROP COLUMN P_Date

ALTER TABLE tblPurchases
ADD P_Date DATE DEFAULT GETDATE()
