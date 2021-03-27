--Procedure to record a supplier

CREATE  PROCEDURE sp_InsertSupplier
   @Name AS VARCHAR(25)
  ,@tel AS INT
  ,@email AS VARCHAR(50)
AS
BEGIN
  BEGIN TRY
	IF(@Name IS NULL AND @tel IS NULL AND @email IS NULL)
	BEGIN
		PRINT 'Parameters cannot be empty'
	END
    IF (@Name IS NULL )
      BEGIN
        PRINT 'Name not entered'
        RETURN
      END

    IF (@tel IS NULL )
      BEGIN
        PRINT 'Telephone number not entered not entered'
        RETURN
      END

    IF ((len(@tel)<7) OR (len(@tel)>8))
      BEGIN
        PRINT 'Telephone number invalid'
        RETURN
      END

    IF ((@email IS NOT NULL ) AND (@email NOT LIKE '%@%'))
      BEGIN
        PRINT 'Email invalid'
        RETURN
      END

    BEGIN TRANSACTION
      INSERT INTO tblSupplier(Name, telephone, email)
        VALUES (@Name,@tel,@email)
		IF(@@ROWCOUNT = 1)
		BEGIN
			PRINT 'Supplier record inserted'
		END
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
	PRINT 'error'
    ROLLBACK TRANSACTION
  END CATCH
END


-------------------------------------------


--Procedure to modify a supplier record
CREATE PROCEDURE sp_ModifySupplier
   @id AS INT
  ,@Name AS VARCHAR(25)
  ,@tel AS INT
  ,@email AS VARCHAR(50)
  ,@bal AS DOUBLE PRECISION
AS
BEGIN
  BEGIN TRY
	IF (@id IS NULL)
		BEGIN
			PRINT 'Supplier id missing'
			RETURN
		END


	IF(@Name IS NULL AND @tel IS NULL AND @email IS NULL AND @bal IS NULL)
	BEGIN
		PRINT 'Input parameters to be updated'
		RETURN
	END

    IF NOT exists(
      SELECT 1
      FROM tblSupplier
      WHERE SupplierID=@id
    )
      BEGIN
        PRINT 'SupplierID not found'
        RETURN
      END

    IF (@Name IS NULL )
      BEGIN
        SET @Name=(
			SELECT Name
			FROM tblSupplier
			WHERE SupplierID=@id
        )
      END

    IF (@tel IS NULL )
      BEGIN
        SET @tel=(
			SELECT telephone
			FROM tblSupplier
			WHERE SupplierID=@id
        )
      END
    ELSE IF (@tel IS NOT NULL )
      BEGIN
      IF ((len(@tel)<7) OR (len(@tel)>8))
       BEGIN
        PRINT 'Telephone number invalid'
        RETURN
       END
      END

    IF (@email IS NULL )
      BEGIN
        SET @email=(
			SELECT email
			FROM tblSupplier
			WHERE SupplierID=@id
        )
      END
    ELSE
      BEGIN
      IF (@email NOT LIKE '%@%')
        BEGIN
        PRINT 'Email invalid'
        RETURN
        END
      END

    IF (@bal IS NULL )
      BEGIN
        SET @bal=(
			SELECT balanceDue
			FROM tblSupplier
			WHERE SupplierID=@id
        )
      END

    BEGIN TRANSACTION
      UPDATE tblSupplier
        SET  Name=@Name
            ,telephone=@tel
            ,email=@email
            ,balanceDue=@bal
     WHERE SupplierID=@id
	 IF (@@ROWCOUNT = 1)
	 BEGIN
		PRINT 'Supplier record successfully updated'
	 END
    COMMIT TRANSACTION

  END TRY
  BEGIN CATCH
    PRINT 'Error'
    ROLLBACK TRANSACTION
  END CATCH
END


-----------------


CREATE TRIGGER tg_InsertSupplier
ON tblSupplier
INSTEAD OF INSERT
AS
DECLARE @supName VARCHAR(25)
DECLARE @supTel INT
DECLARE @supEmail VARCHAR(50)

SET @supName = (SELECT Name FROM INSERTED)

IF(@supName IS NULL)
	BEGIN
		PRINT 'Please enter supplier name'
		RETURN
	END
ELSE IF(len(@supName) >25)
	BEGIN
		PRINT 'Name > 25 Characters'
		RETURN
	END

SET @supTel = (SELECT telephone FROM INSERTED)
SET @supEmail = (SELECT email FROM INSERTED)

IF(@supTel IS NULL AND @supEmail IS NULL)
	BEGIN 
		PRINT 'Please enter either a telephone number or email address'
		RETURN
	END

IF (@supTel IS NOT NULL AND len(@supTel) <7 OR len(@supTel)>8)
	BEGIN
		PRINT 'Phone number should be between 7 and 8 digits'
		RETURN
	END

DECLARE @valid INT
SET @valid = dbo.Validate_Email(@supEmail)
IF( @supEmail IS NOT NULL AND @valid <> 1 )
	BEGIN
		PRINT 'Invalid email'
		RETURN
	END


INSERT INTO tblSupplier(Name, telephone, email) 
SELECT Name, telephone, email FROM INSERTED