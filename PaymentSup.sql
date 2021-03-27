CREATE PROCEDURE spCreatePaymentSupplier @supId INT, @Date_Paid DATE, @Amount_Paid DOUBLE PRECISION
AS
BEGIN
	INSERT INTO tblPaymentSup(supID, Date_Paid, Amount_Paid)
	VALUES (@supId, @Date_Paid, @Amount_Paid)

END;


-------------------------


CREATE PROCEDURE sp_UpdatePaymentSup @PaymentID INT, @supID INT, @Date_Paid DATE, @Amount_Paid DOUBLE PRECISION
AS
BEGIN
	UPDATE tblPaymentSup 
	SET supID = @supID , Date_Paid = @Date_Paid, Amount_Paid = @Amount_Paid 
	WHERE PaymentID = @PaymentID
END;
				 
exec sp_UpdatePaymentSup 1, null, null, null

SELECT * FROM tblPaymentSup

-------------------------


CREATE TRIGGER tg_CreatePaymentSup
ON tblPaymentSup
INSTEAD OF INSERT
AS

DECLARE @supID INT
DECLARE @Date_Paid DATE
DECLARE @Amount_Paid DOUBLE PRECISION

SET @supID = (SELECT supID FROM INSERTED)
SET @Date_Paid = (SELECT Date_Paid FROM INSERTED)
SET @Amount_Paid = (SELECT Amount_Paid FROM INSERTED)

IF(@supID IS NULL)
	BEGIN
		PRINT 'Input supplier id'
		RETURN
	END
ELSE IF NOT EXISTS (SELECT SupplierID FROM tblSupplier WHERE SupplierID = @supID)
	BEGIN
		PRINT 'Incorrect supplier id'
		RETURN
	END

IF(@Date_Paid > GETDATE())
	BEGIN
		PRINT 'Date paid cannot be in the futur'
		RETURN
	END

IF(@Amount_Paid <= 0)
	BEGIN 
		PRINT 'Amount paid cannot be <= 0'
		RETURN
	END

DECLARE @balance DOUBLE PRECISION
SET @balance = (SELECT  balanceDue FROM tblSupplier WHERE SupplierID = @supID)

IF(@Amount_Paid > @balance)
	BEGIN
		PRINT 'Amount > than Amount Due'
		PRINT 'Balance due = '+ CAST(@balance AS VARCHAR)
		RETURN
	END

INSERT INTO tblPaymentSup(supID,Date_Paid,Amount_Paid) 
SELECT supID,Date_Paid,Amount_Paid FROM INSERTED

UPDATE tblSupplier
SET balanceDue = balanceDue - @Amount_Paid
WHERE SupplierID = @supID



---------------------------


ALTER TRIGGER tg_UpdatePaymentSup
ON tblPaymentSup
INSTEAD OF UPDATE
AS
BEGIN
--supid,amt paid
 DECLARE @PaymentID INT, @supID INT, @supID_Before INT, @Date_Paid DATE, @Amount_Paid DOUBLE PRECISION, @Amount_Paid_Before DOUBLE PRECISION

 SET @PaymentID = (SELECT PaymentID FROM DELETED)
 SET @supID = (SELECT supID FROM INSERTED)
 SET @supID_Before = (SELECT supID FROM DELETED)

 SET @Date_Paid = (SELECT Date_Paid FROM DELETED)
 SET @Amount_Paid = (SELECT Amount_Paid FROM INSERTED)
 SET @Amount_Paid_Before = (SELECT Amount_Paid FROM DELETED)

 DECLARE @balanceoldsup DOUBLE PRECISION, @balancenewsup DOUBLE PRECISION
 SET @balancenewsup = (SELECT balanceDue FROM tblSupplier WHERE SupplierID = @supID)
 SET @balanceoldsup = (SELECT balanceDue FROM tblSupplier WHERE SupplierID = @supID_Before)

 IF(@supID IS NULL AND @Amount_Paid IS NULL)
 BEGIN
	  PRINT 'Both parameters are empty. Input value(s) to be changed'
	  RETURN
 END

 IF(@supID IS NULL)
 BEGIN
	  PRINT 'SupID cannot be null'
	  RETURN
 END

 ELSE --supID not null
 BEGIN 
	  IF NOT EXISTS (SELECT SupplierID FROM tblSupplier WHERE SupplierID = @supID)
	  BEGIN
	  PRINT 'Incorrect supplier id'
	  RETURN
	  END
 END

 IF(@supID = @supID_Before) --update amount , same sup
 BEGIN
	  UPDATE tblPaymentSup
	  SET Amount_Paid= @Amount_Paid
	  WHERE paymentID= @PaymentID

	  UPDATE tblSupplier
	  SET balanceDue = balanceDue + @Amount_Paid_Before - @Amount_Paid
	  WHERE SupplierID = @supID
 END

 ELSE IF (@supID <> @supID_Before)
 BEGIN
	  IF(@Amount_Paid = @Amount_Paid_Before) --same amount
	  BEGIN
		   --update payment, set new supp
		   UPDATE tblPaymentSup
		   SET supID= @supID
		   WHERE paymentID= @PaymentID

		   --add amount to old
		   UPDATE tblSupplier
		   SET balanceDue = balanceDue + @Amount_Paid_Before
		   WHERE SupplierID = @supID_Before

		   --remove amount from new
		   UPDATE tblSupplier
		   SET balanceDue = balanceDue - @Amount_Paid_Before
		   WHERE SupplierID = @supID
	  END


	 ELSE --sup change, amt change
	 BEGIN
		   UPDATE tblPaymentSup
		   SET SupId= SupID, Amount_Paid=@Amount_Paid
		   WHERE paymentID= @PaymentID

		   --add amount to old
		   UPDATE tblSupplier
		   SET balanceDue = balanceDue + @Amount_Paid_Before
		   WHERE SupplierID = @supID_Before

		   --remove amount from new
		   UPDATE tblSupplier
		   SET balanceDue = balanceDue - @Amount_Paid
		   WHERE SupplierID = @supID
	END
END

END;