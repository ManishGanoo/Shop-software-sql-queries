--Payment Customer

CREATE PROCEDURE sp_InsertPaymentCustomer
   @Cid AS INT
  ,@Amt AS FLOAT
  ,@ErrorMessage AS VARCHAR(50) OUTPUT
AS
BEGIN
  BEGIN TRY
    IF NOT exists(
      SELECT 1
      FROM tblCustomer
      WHERE CustID=@Cid
    )
      BEGIN
        SET @ErrorMessage='Customer not found'
        RETURN
      END

    IF (@Amt IS NULL )
      BEGIN
        SET @ErrorMessage='Please Enter Amount Paid'
        RETURN
      END

    BEGIN TRANSACTION
      DECLARE @bal AS FLOAT
      SET @bal=(SELECT balanceDue FROM tblCustomer WHERE CustID=@Cid)

      DECLARE @NewBal AS FLOAT
      IF(@Amt>@bal)
        BEGIN
          SET @ErrorMessage='Please Check Amount again'
          RETURN
        END
      ELSE
        BEGIN
          SET @NewBal=@bal-@Amt
        END
      UPDATE tblCustomer
        SET balanceDue=@NewBal
      WHERE CustID=@Cid

      INSERT INTO tblPaymentCust(custID,Date_Paid,Amount_Paid)
        VALUES (@Cid,getdate(),@Amt)
    COMMIT TRANSACTION

  END TRY
  BEGIN CATCH
    SET @ErrorMessage='Error'
    ROLLBACK TRANSACTION
  END CATCH
END

CREATE VIEW view_PaymentCustomer
AS
  SELECT P.PaymentCID,
         C.Name,
         P.Date_Paid,
         P.Amount_Paid
  FROM tblPaymentCust P
    INNER JOIN tblCustomer C
    ON P.custID = C.CustID



DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
EXEC sp_InsertPaymentCustomer 1,10000,@ErrorMsg OUTPUT
PRINT @ErrorMsg

SELECT * FROM view_PaymentCustomer



CREATE PROCEDURE sp_NegateCustPayment
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




ALTER TRIGGER tg_UpdatePaymentCust
ON tblPaymentCust
INSTEAD OF UPDATE
AS
BEGIN
--custID,amt paid
 DECLARE @PaymentCID INT, @custID INT, @custID_Before INT, @Date_Paid DATE, @Amount_Paid DOUBLE PRECISION, @Amount_Paid_Before DOUBLE PRECISION

 SET @PaymentCID = (SELECT PaymentCID FROM DELETED)
 SET @custID = (SELECT custID FROM INSERTED)
 SET @custID_Before = (SELECT custID FROM DELETED)
 SET @Date_Paid = (SELECT Date_Paid FROM DELETED)
 SET @Amount_Paid = (SELECT Amount_Paid FROM INSERTED)
 SET @Amount_Paid_Before = (SELECT Amount_Paid FROM DELETED)

 DECLARE @balanceoldcust DOUBLE PRECISION, @balancenewcust DOUBLE PRECISION
 SET @balancenewcust = (SELECT balanceDue FROM tblCustomer WHERE CustID = @custID)
 SET @balanceoldcust = (SELECT balanceDue FROM tblCustomer WHERE CustID = @custID_Before)

 IF(@custID IS NULL AND @Amount_Paid IS NULL)
 BEGIN
	  PRINT 'Both parameters are empty. Input value(s) to be changed'
	  RETURN
 END

 IF(@custID IS NULL)
 BEGIN
	  PRINT '@custID cannot be null'
	  RETURN
 END

 ELSE --custID not null
 BEGIN 
	  IF NOT EXISTS (SELECT CustID FROM tblCustomer WHERE CustID = @custID)
	  BEGIN
	  PRINT 'Incorrect supplier id'
	  RETURN
	  END
 END

DECLARE @balance DOUBLE PRECISION
SET @balance = (SELECT  balanceDue FROM tblCustomer WHERE CustID = @custID)

IF(@Amount_Paid > @balance)
	BEGIN
		PRINT 'Amount > than Amount Due'
		PRINT 'Balance due = '+ CAST(@balance AS VARCHAR)
		RETURN
	END

 IF(@custID = @custID_Before) --update amount , same sup
 BEGIN
	  UPDATE tblPaymentCust
	  SET Amount_Paid= @Amount_Paid
	  WHERE paymentCID= @PaymentCID

	  UPDATE tblCustomer
	  SET balanceDue = balanceDue + @Amount_Paid_Before - @Amount_Paid
	  WHERE CustID = @custID
 END

 ELSE IF (@custID <> @custID_Before)
 BEGIN
	  IF(@Amount_Paid = @Amount_Paid_Before) --same amount
	  BEGIN
		   --update payment, set new cust
		   UPDATE tblPaymentCust
		   SET custID= @custID
		   WHERE paymentCID= @PaymentCID

		   --add amount to old
		   UPDATE tblCustomer
		   SET balanceDue = balanceDue + @Amount_Paid_Before
		   WHERE CustID = @custID_Before

		   --remove amount from new
		   UPDATE tblCustomer
		   SET balanceDue = balanceDue - @Amount_Paid_Before
		   WHERE CustID = @custID
	  END

	 ELSE --cust change, amt change
	 BEGIN
		   UPDATE tblPaymentCust
		   SET custID= @custID, Amount_Paid=@Amount_Paid
		   WHERE paymentCID= @PaymentCID

		   --add amount to old
		   UPDATE tblCustomer
		   SET balanceDue = balanceDue + @Amount_Paid_Before
		   WHERE CustID = @custID_Before

		   --remove amount from new
		   UPDATE tblCustomer
		   SET balanceDue = balanceDue - @Amount_Paid
		   WHERE CustID = @custID
	END
END

END;