--Purchases

CREATE PROCEDURE sp_Delete_Purchase
  @id AS INT,
  @ErrorMessage AS VARCHAR(50) OUTPUT
AS
BEGIN
  BEGIN TRY
    IF NOT exists(
      SELECT 1
      FROM tblPurchases
      WHERE Purchase_Invoice_No=@id
    )
      BEGIN
        SET @ErrorMessage='Purchases invoice number does not exist'
        RETURN
      END

    BEGIN TRANSACTION
      DELETE FROM tblPurchases WHERE Purchase_Invoice_No=@id
      SET @ErrorMessage='Deleted'
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    SET @ErrorMessage='Error'
    ROLLBACK TRANSACTION
  END CATCH
END

CREATE TRIGGER tg_CheckStocklevelPurchases
  ON tblPurchases
AFTER UPDATE
  AS
BEGIN
  BEGIN TRY
    DECLARE @Pid AS INT
    SET @Pid=(SELECT Pid FROM INSERTED)

    DECLARE @Min AS INT
    SET @Min=(SELECT MinQtyStock FROM tblProduct WHERE ProductID=@Pid)

    DECLARE @Stock AS INT
    SET @Stock=(SELECT Stock FROM tblProduct WHERE ProductID=@Pid)

    IF (@Stock<=@Min)
      BEGIN
        PRINT 'Stock low'
      END
  END TRY
  BEGIN CATCH
  END CATCH
END

CREATE PROCEDURE sp_NegateStockPurchases
  @Pid AS INT,
  @Sid AS INT
AS
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION
        DECLARE @OldQuan AS INT
        SET @OldQuan=(SELECT quantity FROM tblPurchases WHERE Purchase_Invoice_No=@Sid)

        DECLARE @NewStock AS INT
        SET @NewStock=((SELECT Stock from tblProduct where ProductID=@Pid)-@OldQuan)

        UPDATE tblProduct
          SET Stock=@NewStock
          WHERE ProductID=@Pid
      PRINT 'success'
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    PRINT 'error'
    ROLLBACK TRANSACTION
  END CATCH
END

CREATE PROCEDURE sp_NegateSupBal
  @Sid AS INT,
  @Cid AS INT
AS
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION
        DECLARE @OldBal AS FLOAT
        SET @OldBal=(SELECT Total FROM tblPurchases WHERE Purchase_Invoice_No=@Sid)

        DECLARE @NewBal AS INT
        SET @NewBal=((SELECT balanceDue FROM tblSupplier where SupplierID=@Cid)-@OldBal)

        UPDATE tblSupplier
          SET balanceDue=@NewBal
          WHERE SupplierID=@Cid
      PRINT 'success'
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    PRINT 'error'
    ROLLBACK TRANSACTION
  END CATCH
END

ALTER PROCEDURE sp_ModifyPurchases
  @Purid AS INT,
  @Pid AS INT,
  @quantity AS INT,
  @weight AS FLOAT,
  @Total AS FLOAT,
  @Sid AS INT,
  @ErrorMessage AS VARCHAR(50) OUTPUT
AS
BEGIN
  BEGIN TRY

        IF NOT exists(
          SELECT 1
          FROM tblPurchases
          WHERE Purchase_Invoice_No=@Purid
        )
          BEGIN
            SET @ErrorMessage='Purchases invoice number does not exist'
            RETURN
          END

        IF (@Pid IS NULL )
          BEGIN
            SET @Pid=(SELECT Pid
            FROM tblPurchases
            WHERE Purchase_Invoice_No=@Sid)

            EXEC sp_NegateStockPurchases @Purid,@Pid

          END
        ELSE
          BEGIN
            DECLARE @temp1 AS INT
            SET @temp1=(SELECT Pid FROM tblPurchases WHERE Purchase_Invoice_No=@Purid)
            EXEC sp_NegateStockPurchases @Purid,@temp1
          END

        IF (@quantity IS NULL )
          BEGIN
            SET @quantity=(SELECT quantity
            FROM tblPurchases
            WHERE Purchase_Invoice_No=@Purid)
          END

        DECLARE @NewStock AS INT
        SET @NewStock=((SELECT Stock FROM tblProduct WHERE ProductID=@Pid)+@quantity)
        UPDATE tblProduct
           SET Stock=@NewStock
        WHERE ProductID=@Pid

        IF (@weight IS NULL )
          BEGIN
            SET @weight=(SELECT Weight_Kg
            FROM tblPurchases
            WHERE Purchase_Invoice_No=@Purid)
          END

        IF (@Total IS NULL )
          BEGIN
            DECLARE @Price AS FLOAT

            SET @Price=(SELECT buyingPrice FROM tblProduct WHERE ProductID=@Pid)
            SET @Total=dbo.CalculateTotal(@Price,@weight,null)
          END

        IF (@Sid IS NULL )
          BEGIN
            SET @Sid=(SELECT S_id
            FROM tblPurchases
            WHERE Purchase_Invoice_No=@Purid)

            EXEC sp_NegateSupBal  @Purid,@Sid

          END
        ELSE
          BEGIN
            DECLARE @temp2 AS INT
            SET @temp2=(SELECT Cid FROM tblSales WHERE Sales_Invoice_No=@Sid)
            EXEC sp_NegateSupBal @Purid,@temp2
          END

  BEGIN TRANSACTION
        DECLARE @NewBal AS FLOAT
        SET @NewBal=((SELECT balanceDue FROM tblSupplier WHERE SupplierID=@Sid)+@Total)
        UPDATE tblSupplier
          SET balanceDue=@NewBal
        WHERE SupplierID=@Sid

        DECLARE @Date AS DATE
        SET @Date=(SELECT P_Date FROM tblPurchases WHERE Purchase_Invoice_No=@Purid)

          UPDATE tblPurchases
            SET  P_Date=@Date
                ,Pid=@Pid
                ,quantity=@quantity
                ,Weight_Kg=@weight
                ,Total=@Total
                ,S_id=@Sid
          WHERE Purchase_Invoice_No=@Purid
  COMMIT TRANSACTION


  END TRY
  BEGIN CATCH
    SET @ErrorMessage='error'
    ROLLBACK TRANSACTION
  END CATCH
END


CREATE PROCEDURE spCreatePurchase @pid INT, @quantity INT, @weight_kg DOUBLE PRECISION, @Sid INT

AS
BEGIN
	DECLARE @price DOUBLE PRECISION
	DECLARE @total DOUBLE PRECISION
	SET @price = (SELECT sellingPrice from tblProduct WHERE ProductID = @pid)
	SET @total = @price * @weight_kg

	INSERT INTO tblPurchases(Pid,quantity, Weight_Kg,Total,S_id ) 
	VALUES (@pid, @quantity, @weight_kg, @total, @Sid )


END;

ALTER TRIGGER tg_InsertPurchases
ON tblPurchases
INSTEAD OF INSERT
AS
DECLARE @pid INT
DECLARE @quantity INT
DECLARE @weight_kg DOUBLE PRECISION
DECLARE @total DOUBLE PRECISION
DECLARE @Sid INT

SET @pid = (SELECT Pid FROM INSERTED)
SET @quantity = (SELECT quantity FROM INSERTED)
SET @weight_kg = (SELECT Weight_kg FROM INSERTED)
SET @total = (SELECT Total FROM INSERTED)
SET @Sid = (SELECT S_id FROM INSERTED)


IF(@pid IS NULL)
	BEGIN
		PRINT 'Input a product id'
		RETURN
	END
ELSE IF NOT EXISTS (SELECT ProductID FROM tblProduct WHERE ProductID = @pid)
	BEGIN
		PRINT 'Incorrect product id'
		RETURN
	END

IF(@quantity IS NULL)
	BEGIN
		PRINT 'Quantity cannot be empty'
		RETURN
	END

ELSE IF (@quantity < = 0)
	BEGIN 
		PRINT 'Negative digit for quantity'
		RETURN
	END


IF (@weight_kg < = 0)
	BEGIN
		PRINT 'Negative digit for weight'
		RETURN
	END
IF(@Sid IS NULL)
	BEGIN
		PRINT 'Input supplier id'
		RETURN
	END
ELSE IF NOT EXISTS (SELECT SupplierID FROM tblSupplier WHERE SupplierID = @Sid)
	BEGIN
		PRINT 'Incorrect supplier id'
		RETURN
	END

INSERT INTO tblPurchases(Pid,quantity, Weight_Kg,Total,S_id ) 
SELECT Pid,quantity, Weight_Kg,Total,S_id FROM INSERTED
IF(@@ROWCOUNT = 1)
BEGIN
	PRINT 'Purchase record successfully created'
END

UPDATE tblProduct 
SET Stock = Stock + @quantity
WHERE ProductID = @pid
IF(@@ROWCOUNT = 1)
BEGIN
	PRINT 'Stock successfully incremented'
END

SELECT * FROM tblPurchases
SELECT * FROM tblProduct
SELECT * FROM tblSupplier

UPDATE tblSupplier
SET balanceDue = balanceDue + @total
WHERE SupplierID = @Sid


--view purchase

CREATE INDEX PurchasesIndex
ON tblPurchases(Purchase_Invoice_No)


ALTER VIEW view_Purchases
AS
  SELECT S.Purchase_Invoice_No
		,S.P_Date
        ,P.Name AS Product_Name
        ,S.quantity
        ,S.Weight_Kg
        ,S.Total
        ,C.Name AS Supplier_Name
  FROM tblPurchases S WITH (INDEX(PurchasesIndex))
        INNER JOIN tblProduct P
          ON S.Pid = P.ProductID
        INNER JOIN tblSupplier C
          ON S.S_id = C.SupplierID