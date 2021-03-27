--Sales

CREATE TRIGGER tg_Stock_Level
  ON tblSales
INSTEAD OF INSERT
  AS
  BEGIN
    DECLARE @Min AS INT
    SET @Min=(SELECT MinQtyStock FROM tblProduct)

    DECLARE @CurrentStock AS INT
    SET @CurrentStock=(SELECT Stock FROM tblProduct)

    DECLARE @Amt AS INT
    SET @Amt =(SELECT quantity FROM INSERTED)

    IF (@Amt>@CurrentStock)
      BEGIN
        PRINT 'Quantity being sold exceed current stock level'
        RETURN
      END
    ELSE
      BEGIN
        DECLARE @new AS INT
        SET @new=@CurrentStock-@Amt

        DECLARE @Pid AS INT
        SET @Pid=(SELECT Pid FROM INSERTED)

        DECLARE @weight AS FLOAT
        SET @weight=(SELECT Weight_Kg FROM INSERTED)

        DECLARE @total AS FLOAT
        SET @total=(SELECT Total FROM INSERTED)

        DECLARE @Paid AS CHAR
        SET @Paid=(SELECT Paid FROM INSERTED)

        DECLARE @Delivered AS VARCHAR(50)
        SET @Delivered=(SELECT DeliveredBy FROM INSERTED)

        DECLARE @Cid AS INT
        SET @Cid=(SELECT Cid FROM INSERTED)



        UPDATE tblProduct
        SET Stock=@new
        WHERE ProductID=@Pid

        IF (@new<@Min)
          BEGIN
            PRINT 'Stock level low'
          END

        INSERT INTO tblSales(sDate, Pid, quantity, Weight_Kg, Total, Paid, DeliveredBy, Cid)
        VALUES (getdate(),@Pid,@Amt,@weight,@total,@Paid,@Delivered,@Cid)

      DECLARE @OldBal AS FLOAT
      DECLARE @NewBal AS FLOAT

      SET @OldBal=(SELECT balanceDue FROM tblCustomer WHERE CustID=@Cid)
      SET @NewBal=@OldBal+@Total

      UPDATE tblCustomer
        SET balanceDue=@NewBal
		WHERE CustID=@Cid

      END

  END

CREATE FUNCTION CalculateTotal(
  @Price AS FLOAT,
  @Weight AS FLOAT,
  @Discount AS FLOAT
)
  RETURNS FLOAT

AS
  BEGIN
  DECLARE @Total AS FLOAT
  SET @Total=0

      IF (@Discount IS NOT NULL )
        BEGIN
          SET @Total=(@Price-@Discount)*@Weight
        END
      ELSE
        BEGIN
          SET @Total=@Price*@Weight
        END

    RETURN @Total
  END

CREATE VIEW view_Sales
AS
  SELECT S.Sales_Invoice_No
        ,S.sDate
        ,P.Name AS Product_Name
        ,S.quantity
        ,S.Weight_Kg
        ,S.Total
        ,S.Paid
        ,S.DeliveredBy
        ,C.Name AS Customer_Name
  FROM tblSales S
        INNER JOIN tblProduct P
          ON S.Pid = P.ProductID
        INNER JOIN tblCustomer C
          ON S.Cid = C.CustID

CREATE PROCEDURE sp_InsertSales
  @Pid AS INT,
  @quantity AS INT,
  @weight AS FLOAT,
  @Discount AS FLOAT,
  @Paid AS CHAR,
  @Delivered AS VARCHAR(50),
  @Cid AS INT,
  @ErrorMessage AS VARCHAR(50) OUTPUT
AS
BEGIN
  DECLARE @Total AS FLOAT
  SET @Total=0

  BEGIN TRY
    IF NOT EXISTS(
        SELECT 1
        FROM tblProduct
        WHERE ProductID=@Pid
    )
      BEGIN
        SET @ErrorMessage='Product not found'
        RETURN
      END


    IF ((@quantity IS NOT NULL )AND (@weight IS NOT NULL ))
      BEGIN
        DECLARE @Price AS FLOAT

        SET @Price=(SELECT sellingPrice FROM tblProduct WHERE ProductID=@Pid)
        SET @Total=dbo.CalculateTotal(@Price,@weight,@Discount)
      END
    ELSE
      BEGIN
        SET @ErrorMessage='wrong quantity and weight'
        RETURN
      END


    IF (@Paid IS NULL )
      BEGIN
        SET @ErrorMessage='Paid missing'
        RETURN
      END

    IF (@Delivered IS NULL )
      BEGIN
        SET @ErrorMessage='Delivered missing'
        RETURN
      END

    IF NOT EXISTS(
        SELECT 1
        FROM tblCustomer
        WHERE CustID=@Cid)
      BEGIN
        SET @ErrorMessage='Customer not found'
        RETURN
      END

    BEGIN TRANSACTION
      INSERT INTO tblSales(sDate, Pid, quantity, Weight_Kg, Total, Paid, DeliveredBy, Cid)
        VALUES (getdate(),@Pid,@quantity,@weight,@Total,@Paid,@Delivered,@Cid)
    COMMIT TRANSACTION

  END TRY
  BEGIN CATCH
    SET @ErrorMessage='error'
    ROLLBACK TRANSACTION
  END CATCH
END

CREATE PROCEDURE sp_Delete_Sales
  @id AS INT,
  @ErrorMessage AS VARCHAR(50) OUTPUT
AS
BEGIN
  BEGIN TRY
    IF NOT exists(
      SELECT 1
      FROM tblSales
      WHERE Sales_Invoice_No=@id
    )
      BEGIN
        SET @ErrorMessage='Sales invoice number does not exist'
        RETURN
      END

    BEGIN TRANSACTION
      DELETE FROM tblSales WHERE Sales_Invoice_No=@id
      SET @ErrorMessage='Deleted'
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    SET @ErrorMessage='Error'
    ROLLBACK TRANSACTION
  END CATCH
END

CREATE TRIGGER tg_CheckStocklevel
  ON tblSales
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

ALTER PROCEDURE sp_NegateStock
  @Pid AS INT,
  @Sid AS INT
AS
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION
        DECLARE @OldQuan AS INT
        SET @OldQuan=(SELECT quantity FROM tblSales WHERE Sales_Invoice_No=@Sid)

        DECLARE @NewStock AS INT
        DECLARE @OldStock AS INT
        SET @OldStock=(SELECT Stock from tblProduct where ProductID=@Pid)
        SET @NewStock=(@OldStock+@OldQuan)

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
CREATE PROCEDURE sp_NegateCustBal
  @Sid AS INT,
  @Cid AS INT
AS
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION
        DECLARE @OldBal AS FLOAT
        SET @OldBal=(SELECT Total FROM tblSales WHERE Sales_Invoice_No=@Sid)

        DECLARE @NewBal AS INT
        SET @NewBal=((SELECT balanceDue FROM tblCustomer where CustID=@Cid)-@OldBal)

        UPDATE tblCustomer
          SET balanceDue=@NewBal
          WHERE CustID=@Cid
      PRINT 'success'
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    PRINT 'error'
    ROLLBACK TRANSACTION
  END CATCH
END

ALTER PROCEDURE sp_ModifySales
  @Sid AS INT,
  @Pid AS INT,
  @quantity AS INT,
  @weight AS FLOAT,
  @Discount AS FLOAT,
  @Total AS FLOAT,
  @Paid AS CHAR,
  @Delivered AS VARCHAR(50),
  @Cid AS INT,
  @ErrorMessage AS VARCHAR(50) OUTPUT
AS
BEGIN
  BEGIN TRY


    IF NOT exists(
      SELECT 1
      FROM tblSales
      WHERE Sales_Invoice_No=@Sid
    )
      BEGIN
        SET @ErrorMessage='Sales invoice number does not exist'
        RETURN
      END

    IF (@Pid IS NULL )
      BEGIN
        SET @Pid=(SELECT Pid
        FROM tblSales
        WHERE Sales_Invoice_No=@Sid)

        DECLARE @OldQuann AS INT
        SET @OldQuann=(SELECT quantity FROM tblSales WHERE Sales_Invoice_No=@Sid)

        DECLARE @NewStocks AS INT
        DECLARE @OldStocks AS INT
        SET @OldStocks=(SELECT Stock from tblProduct where ProductID=@Pid)
        SET @NewStocks=(@OldStocks+@OldQuann)

        UPDATE tblProduct
          SET Stock=@NewStocks
          WHERE ProductID=@Pid

      END
    ELSE
      BEGIN
        IF NOT exists(
          SELECT 1
          FROM tblProduct
          WHERE ProductID=@Pid
        )
          BEGIN
            SET @ErrorMessage='null'
            RETURN
          END
        DECLARE @temp1 AS INT
        SET @temp1=(SELECT Pid FROM tblSales WHERE Sales_Invoice_No=@Sid)



        DECLARE @OldQuannn AS INT
        SET @OldQuannn=(SELECT quantity FROM tblSales WHERE Sales_Invoice_No=@Sid)

        DECLARE @NewStockss AS INT
        DECLARE @OldStockss AS INT
        SET @OldStockss=(SELECT Stock from tblProduct where ProductID=@temp1)
        SET @NewStockss=(@OldStockss+@OldQuannn)

        UPDATE tblProduct
          SET Stock=@NewStockss
          WHERE ProductID=@temp1
      END

    IF (@quantity IS NULL )
      BEGIN
        SET @quantity=(SELECT quantity
        FROM tblSales
        WHERE Sales_Invoice_No=@Sid)
      END

    DECLARE @NewStock AS INT
    DECLARE @OldStock AS INT
    SET @OldStock=(SELECT Stock FROM tblProduct WHERE ProductID=@Pid)
    IF (@quantity>@OldStock)
      BEGIN
        SET @ErrorMessage='Quantity > Stock'
        RETURN
      END
    SET @NewStock=(@OldStock-@quantity)
    UPDATE tblProduct
       SET Stock=@NewStock
    WHERE ProductID=@Pid

    IF (@weight IS NULL )
      BEGIN
        SET @weight=(SELECT Weight_Kg
        FROM tblSales
        WHERE Sales_Invoice_No=@Sid)
      END

    IF (@Total IS NULL )
      BEGIN
        DECLARE @Price AS FLOAT

        SET @Price=(SELECT sellingPrice FROM tblProduct WHERE ProductID=@Pid)
        SET @Total=dbo.CalculateTotal(@Price,@weight,@Discount)
      END

    IF (@Paid IS NULL )
      BEGIN
        SET @Paid=(SELECT Paid
        FROM tblSales
        WHERE Sales_Invoice_No=@Sid)
      END

    IF (@Delivered IS NULL )
      BEGIN
        SET @Delivered=(SELECT DeliveredBy
        FROM tblSales
        WHERE Sales_Invoice_No=@Sid)
      END

    IF (@Cid IS NULL )
      BEGIN
        SET @Cid=(SELECT Cid
        FROM tblSales
        WHERE Sales_Invoice_No=@Sid)

        EXEC sp_NegateCustBal @Sid,@Cid

      END
    ELSE
      BEGIN
        DECLARE @temp2 AS INT
        SET @temp2=(SELECT Cid FROM tblSales WHERE Sales_Invoice_No=@Sid)
        EXEC sp_NegateCustBal @Sid,@temp2
      END
  BEGIN TRANSACTION

    DECLARE @NewBal AS FLOAT
    SET @NewBal=((SELECT balanceDue FROM tblCustomer WHERE CustID=@Cid)+@Total)
    UPDATE tblCustomer
      SET balanceDue=@NewBal
    WHERE CustID=@Cid

    DECLARE @Date AS DATE
    SET @Date=(SELECT sDate FROM tblSales WHERE Sales_Invoice_No=@Sid)

      UPDATE tblSales
        SET  sDate=@Date
            ,Pid=@Pid
            ,quantity=@quantity
            ,Weight_Kg=@weight
            ,Total=@Total
            ,Paid=@Paid
            ,DeliveredBy=@Delivered
            ,Cid=@Cid
      WHERE Sales_Invoice_No=@Sid

    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    SET @ErrorMessage='error'
    ROLLBACK TRANSACTION
  END CATCH
END

PRINT dbo.CalculateTotal(100,5,10)

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
EXEC sp_InsertSales 1,10,100,null,'y','x',1,@ErrorMsg OUTPUT
PRINT @ErrorMsg

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
EXEC sp_Delete_Sales 2,@ErrorMsg OUTPUT
PRINT @ErrorMsg

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
-------------------Sid,Pid, Quan,weight,disc,total,paid,delivered,cid
EXEC sp_ModifySales 1, null,15,  150,  null, null,'n',  null,     null,@ErrorMsg OUTPUT
PRINT @ErrorMsg

SELECT * FROM view_Sales

CREATE INDEX SalesIndex
ON tblSales(Sales_Invoice_No)