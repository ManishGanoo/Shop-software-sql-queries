--Product

CREATE TRIGGER tg_ProductInsert
  ON tblProduct
  INSTEAD OF INSERT

  AS
  BEGIN
    DECLARE @Name AS VARCHAR(25)
    DECLARE @Min AS INT
    DECLARE @bp AS FLOAT
    DECLARE @sp AS FLOAT

    SET @Name = (SELECT Name FROM INSERTED)
    IF (@Name IS NULL )
      BEGIN
        PRINT 'Please Insert a product name'
        RETURN
      END

    SET @Min = (SELECT MinQtyStock FROM INSERTED)
    IF (@Min IS NULL )
      BEGIN
        PRINT 'Minimum stock level not entered'
        RETURN
      END

    SET @bp = (SELECT buyingPrice FROM INSERTED)
    IF (@bp IS NULL )
      BEGIN
        PRINT 'Enter Buying price'
        RETURN
      END

    SET @sp = (SELECT sellingPrice FROM INSERTED)
    IF (@sp IS NULL )
      BEGIN
        PRINT 'Enter Selling Price'
        RETURN
      END

    INSERT INTO tblProduct(Name,MinQtyStock,Stock,buyingPrice,sellingPrice)
      VALUES (@Name,@Min,0,@bp,@sp)

  END

CREATE PROCEDURE sp_InsertProduct
  @Name AS VARCHAR(25),
  @Min AS INT,
  @bp AS FLOAT,
  @sp AS FLOAT

AS
 BEGIN
   BEGIN TRY
     BEGIN TRANSACTION
       INSERT INTO tblProduct(Name,MinQtyStock,buyingPrice,sellingPrice)
        VALUES (@Name,@Min,@bp,@sp)
     COMMIT TRANSACTION
   END TRY
   BEGIN CATCH
     ROLLBACK TRANSACTION
   END CATCH
 END

CREATE PROCEDURE sp_ModifyProduct
  @id AS INT,
  @Name AS VARCHAR(25),
  @Min AS INT,
  @Stock AS INT,
  @bp AS FLOAT,
  @sp AS FLOAT,
  @ErrorMessage AS VARCHAR(50)

AS
 BEGIN
   BEGIN TRY
     IF NOT exists(
       SELECT 1
       FROM tblProduct
       WHERE ProductID=@id
     )
       BEGIN
         SET @ErrorMessage='Product does not exist'
        RETURN
       END

     IF (@Name IS NULL )
      BEGIN
        SET @Name=(
          SELECT Name
          FROM tblProduct
          WHERE ProductID=@id
        )
      END

     IF (@Min IS NULL )
      BEGIN
        SET @Min=(
          SELECT MinQtyStock
          FROM tblProduct
          WHERE ProductID=@id
        )
      END

     IF (@Stock IS NULL )
      BEGIN
        SET @Stock=(
          SELECT Stock
          FROM tblProduct
          WHERE ProductID=@id
        )
      END

     IF (@bp IS NULL )
      BEGIN
        SET @bp=(
          SELECT buyingPrice
          FROM tblProduct
          WHERE ProductID=@id
        )
      END

     IF (@sp IS NULL )
      BEGIN
        SET @sp=(
          SELECT sellingPrice
          FROM tblProduct
          WHERE ProductID=@id
        )
      END

     BEGIN TRANSACTION
       UPDATE tblProduct
         SET Name=@Name
            ,MinQtyStock=@Min
            ,Stock=@Stock
            ,buyingPrice=@bp
            ,sellingPrice=@sp
        WHERE ProductID=@id
     COMMIT TRANSACTION
   END TRY
   BEGIN CATCH
     ROLLBACK TRANSACTION
     SET @ErrorMessage='Error'
   END CATCH
 END

EXEC sp_InsertProduct 'whole chicken',10,86,100

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
EXEC sp_ModifyProduct 1,null,null,50,null,null,@ErrorMsg
PRINT @ErrorMsg

SELECT *
FROM tblProduct;