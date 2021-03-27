--customer

ALTER PROCEDURE sp_InsertCustomer
   @Name AS VARCHAR(25)
  ,@tel AS INT
  ,@email AS VARCHAR(50)
  ,@ErrorMessage AS VARCHAR(50) OUTPUT
AS
BEGIN
  BEGIN TRY
    IF (@Name IS NULL )
      BEGIN
        SET @ErrorMessage ='Name not entered'
        RETURN
      END

    IF (@tel IS NULL )
      BEGIN
        SET @ErrorMessage ='telephone number not entered not entered'
        RETURN
      END

    IF ((len(@tel)<7) OR (len(@tel)>8))
      BEGIN
        SET @ErrorMessage ='Telephone number invalid'
        RETURN
      END

	DECLARE @valid INT
	SET @valid =  dbo.Validate_Email(@email)
    IF ((@email IS NOT NULL ) AND (@valid <> 1))
      BEGIN
        SET @ErrorMessage ='Email invalid'
        RETURN
      END

    BEGIN TRANSACTION
      INSERT INTO tblCustomer(Name, telephone, email)
        VALUES (@Name,@tel,@email)
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    SET @ErrorMessage='error'
    ROLLBACK TRANSACTION
  END CATCH
END

ALTER PROCEDURE sp_ModifyCustomer
   @id AS INT
  ,@Name AS VARCHAR(25)
  ,@tel AS INT
  ,@email AS VARCHAR(50)
  ,@bal AS FLOAT
  ,@ErrorMessage AS VARCHAR(50) OUTPUT
AS
BEGIN
  BEGIN TRY
    IF NOT exists(
      SELECT 1
      FROM tblCustomer
      WHERE CustID=@id
    )
      BEGIN
        SET @ErrorMessage='Customer not found'
        RETURN
      END

    IF (@Name IS NULL )
      BEGIN
        SET @Name=(
          SELECT Name
          FROM tblCustomer
          WHERE CustID=@id
        )
      END

    IF (@tel IS NULL )
      BEGIN
        SET @tel=(
          SELECT telephone
          FROM tblCustomer
          WHERE CustID=@id
        )
      END
    ELSE IF (@tel IS NOT NULL )
      BEGIN
      IF ((len(@tel)<7) OR (len(@tel)>8))
       BEGIN
        SET @ErrorMessage ='Telephone number invalid'
        RETURN
       END
      END

    IF (@email IS NULL )
      BEGIN
        SET @email=(
          SELECT email
          FROM tblCustomer
          WHERE CustID=@id
        )
      END
    ELSE
      BEGIN
		DECLARE @valid INT
		SET @valid =  dbo.Validate_Email(@email)
		IF ((@email IS NOT NULL ) AND (@valid <> 1))
		  BEGIN
			SET @ErrorMessage ='Email invalid'
			RETURN
		  END
      END


    IF (@bal IS NULL )
      BEGIN
        SET @bal=(
          SELECT balanceDue
          FROM tblCustomer
          WHERE CustID=@id
        )
      END

    BEGIN TRANSACTION
      UPDATE tblCustomer
        SET  Name=@Name
            ,telephone=@tel
            ,email=@email
            ,balanceDue=@bal
      WHERE CustID=@id
    COMMIT TRANSACTION

  END TRY
  BEGIN CATCH
    SET @ErrorMessage='Error'
    ROLLBACK TRANSACTION
  END CATCH
END

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
EXEC sp_InsertCustomer 'sumida',57418521,'email@gmail.com',@ErrorMsg OUTPUT
PRINT @ErrorMsg

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
EXEC sp_ModifyCustomer 1,null,null,'sumida@gmail.com',50000,@ErrorMsg OUTPUT
PRINT @ErrorMsg


SELECT *
FROM tblCustomer