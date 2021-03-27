CREATE PROCEDURE sp_NegateStock
  @Pid AS INT,
  @Sid AS INT
AS
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION
        DECLARE @OldQuan AS INT
        SET @OldQuan=(SELECT quantity FROM tblSales WHERE Sales_Invoice_No=@Sid)

        DECLARE @NewStock AS INT
        SET @NewStock=((SELECT Stock from tblProduct where ProductID=@Pid)+@OldQuan)

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

