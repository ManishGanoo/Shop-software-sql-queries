

------------PRODUCT-----------------------



SELECT *
FROM tblProduct;

--Insert Product--
--exec sp_InsertProduct @Name, @MinStock, @buyingprice, @sellingprice
exec sp_InsertProduct  @Name, @MinStock, @buyingprice, @sellingprice
exec sp_InsertProduct  'Eggs', 10, 90 , 150 --inserted
exec sp_InsertProduct null,10,90,150 --product name missing
exec sp_InsertProduct 'Eggs',null,90,150 --Minimum stock level
exec sp_InsertProduct  'Eggs', 10, null , 150 --buying price missing
exec sp_InsertProduct  'Eggs', 10, 90 , null --selling price missing
exec sp_InsertProduct  null, null, null , null --product name missing
EXEC sp_InsertProduct 'wings',10,86,100--inserted

SELECT * FROM tblProduct

--Modify Product--
--exec sp_ModifyProduct @id, @Name, @minstock, @currentStock, @buyingprice, @sellingprice, @errormessage
exec sp_ModifyProduct @id, @Name, @minstock, @currentStock, @buyingprice, @sellingprice, @errormessage
exec sp_ModifyProduct 3, null, null, 50, null, null,@ErrorMsg --working stock updated
exec sp_ModifyProduct 3, null, null, null, null, null,@ErrorMsg --parameters missing


DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
---------------------Pid,Name,Min,Stock,bp,sp
--EXEC sp_ModifyProduct 1,null  ,null,50, null,null,@ErrorMsg
exec sp_ModifyProduct 3, null, null, null, null, null,@ErrorMsg 
PRINT @ErrorMsg






---------------------------SUPPLIER--------------------------------------------------------------------

--Supplier--
--Insert Supplier--
--exec sp_InsertSupplier @Name, @tel, @email
exec sp_InsertSupplier 'Chill Meat Son' , 57654321, null --good
exec sp_InsertSupplier 'Chill Meat Daughter' , 57654321, null --good
exec sp_InsertSupplier 'Chill Meat' , null, null --phone not entered
exec sp_InsertSupplier null , 57654321, null --name not entered

SELECT * FROM tblSupplier

--UpdateSupplier--
--exec sp_ModifySupplier @id, @Name, @tel, @email, @bal
exec sp_ModifySupplier 1, null, null, null, null --no parameters entered
exec sp_ModifySupplier 1, null, null, 'Chill@chillmail.com', null --work
exec sp_ModifySupplier 1, null, null, null, 5000 --work




---------------------------------------------CLIENT-------------------------------------

SELECT * FROM tblCustomer
--Insert Customer--
--exec sp_InsertCustomer @Name, @tel, @email, @ErrorMessage
exec sp_InsertCustomer @Name, @tel, @email, @ErrorMessage

DECLARE @ErrorMessage AS VARCHAR(50)
SET @ErrorMessage = 'null'

exec sp_InsertCustomer 'Tom', 57654321,'Tom@gmaiom',@ErrorMessage OUTPUT --email invalid

PRINT @ErrorMessage

exec sp_InsertCustomer 'Jim', 57654321,null,null --email optional
exec sp_InsertCustomer 'Jim', null,'Jim@gmail.com',null --phone number mandatory
exec sp_InsertCustomer null, null, null, null 
exec sp_InsertCustomer 'Jim', 123, null, '' -- not returning error messages

SELECT * FROM tblCustomer

--Modify Customer--
--exec sp_ModifyCustomer @id, @Name, @tel, @email, @bal, @ErrorMessage
exec sp_ModifyCustomer @id, @Name, @tel, @email, @bal, @ErrorMessage OUTPUT

DECLARE @ErrorMessage AS VARCHAR(50)
exec sp_ModifyCustomer 1, 'Tomas', null, null, null, @ErrorMessage OUTPUT--work
--exec sp_ModifyCustomer null, null, null, null, null, @ErrorMessage OUTPUT

PRINT @ErrorMessage


exec sp_ModifyCustomer 1, null, null, null, null, @ErrorMessage OUTPUT--error
exec sp_ModifyCustomer 1, 'Tom', null, null, null, @ErrorMessage OUTPUT--work
exec sp_ModifyCustomer 5, 'Tom', null, null, null, @ErrorMessage OUTPUT--id doesnt exist


------------------------------------PURCHASE-------------------------------------------------------------------
--create purchase
--exec spCreatePurchase @pid, @quantity, @weight_kg, @Sid
exec spCreatePurchase @pid, @quantity, @weight_kg, @Sid
exec spCreatePurchase 1, 10000, 50,2 --good
exec spCreatePurchase null, null,null,null 
exec spCreatePurchase null, 100, 50,1 --pid empty
exec spCreatePurchase 1, 100, 50,null --sid empty
exec spCreatePurchase 5, 100, 50,1 --pid doesnt exist
exec spCreatePurchase 1, 100, 50,5 --sid doesnt exist
exec spCreatePurchase 1, -100, 50,5 -- quantity negative
exec spCreatePurchase 1, -100, -50,5 --weight negative

SELECT * FROM tblPurchases
SELECT * FROM tblProduct
SELECT * FROM tblSupplier

SELECT * FROM tblAudit
SELECT * FROM view_Purchases

--update purchase
--exec sp_ModifyPurchases @purchaseinvoiceID, @pid, @quantity,@Total, @Weight_kg, @Sid, @ErrorMessage
exec sp_ModifyPurchases null, null,null,null,null,null,@ErrorMessage OUTPUT--parameter empty
exec sp_ModifyPurchases 1, null,null,null,null,null,@ErrorMessage OUTPUT--parameter empty
exec sp_ModifyPurchases 1, 2,null,null,null,null,@ErrorMessage OUTPUT

DECLARE @ErrorMessage AS VARCHAR(50)
SET @ErrorMessage = 'null'
--exec sp_ModifyPurchases 1, null,null,null,null,null,@ErrorMessage OUTPUT--parameter empty
exec sp_ModifyPurchases 1, 3,null,null,null,null,@ErrorMessage OUTPUT

PRINT @ErrorMessage

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
EXEC sp_ModifyPurchases null,null,null,null,null,null,@ErrorMsg OUTPUT
PRINT @ErrorMsg


--delete purchase
--exec sp_Delete_Purchase  @id ,@ErrorMessage
SELECT * FROM tblPurchases

DECLARE @ErrorMessage AS VARCHAR(50)
SET @ErrorMessage = 'null'
	exec sp_Delete_Purchase  1 ,@ErrorMessage OUTPUT
PRINT @ErrorMessage


--------------------------------------------------------------SALES---------------------------------------------------------
SELECT * FROM tblProduct
SELECT * FROM tblSales
SELECT * FROM tblCustomer

UPDATE tblProduct
SET Stock = 10
WHERE ProductID = 2

--Insert Sales--
--exec sp_InsertSales @pid,@quantity,@weight,@Discount,@Paid,@Delivered,@Cid,@ErrorMessage
exec sp_InsertSales @pid,@quantity,@weight,@Discount,@Paid,@Delivered,@Cid,@ErrorMessage

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
-------------------Pid, Quan,weight,disc,paid,delivered,cid
EXEC sp_InsertSales 2,  5,  100,   null,'y', 'x', 3,@ErrorMsg OUTPUT
PRINT @ErrorMsg


--Delete Sales--
--exec sp_Delete_Sales @id, @ErrorMessage
exec sp_Delete_Sales @id, @ErrorMessage

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
EXEC sp_Delete_Sales 2,@ErrorMsg OUTPUT
PRINT @ErrorMsg


SELECT * FROM tblProduct
SELECT * FROM tblSales

--Modify Sales--
--exec sp_ModifySales @Date, @id, @Pid, @quantity, @weight, @Discount, @Total, @Paid, @Delivered, @Cid, @ErrorMessage
exec sp_ModifySales @Date, @id, @Pid, @quantity, @weight, @Discount, @Total, @Paid, @Delivered, @Cid, @ErrorMessage

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
-------------------Sid,Pid, Quan,weight,disc,total,paid,delivered,cid
--EXEC sp_ModifySales 1, 2,15,  200,  null, null,'n',  null,     null,@ErrorMsg OUTPUT
EXEC sp_ModifySales 4, 2,null,  null,  null, null,null,  null,     null,@ErrorMsg OUTPUT
PRINT @ErrorMsg

UPDATE tblProduct
SET Stock = 13
WHERE ProductID = 2 

UPDATE tblSales
SET quantity = 5
WHERE Sales_Invoice_No = 4

--View Sales--
SELECT * FROM view_Sales

----------------------------------------------------PAYMENT CUSTOMER--------------------------------------------------------------

--Create Payment to Customer
--@cid @amount @errormessage
exec sp_InsertPaymentCustomer 2, 500, null

SELECT * FROM tblPaymentCust
SELECT * FROM tblCustomer

--Update Payment to Customer

UPDATE tblPaymentCust
SET Amount_Paid = 300
WHERE PaymentID = 15 --current amount 500 supid = 2 change to amount 300.. increase balanceDue in tblSupplier by 200..balance Due will become 700 for supid 2

UPDATE tblPaymentCust
SET CustID = 2
WHERE PaymentCID = 1 --current amount 100 supid = 3 change to supid 2.. increase balanceDue in tblSupplier by 100..balanceDue for supid = 2 becomes 600, balance Due for supid increases by 100 becomes 1000

UPDATE tblPaymentCust
SET CustID = 3, Amount_Paid = 100
WHERE PaymentCID = 17 


---------------------------------------------------------PAYMENT SUPPLIER-----------------------------------------------------------------------

--Create Payment to supplier
--exec spCreatePaymentSupplier @supID, @Date_Paid, @Amount_Paid
exec spCreatePaymentSupplier null,  null, null --null values not accepted for date paid and amount paid
exec spCreatePaymentSupplier 1,  '2017-03-17', 0 --amount paid <= 0 
exec spCreatePaymentSupplier 1,  '2017-05-17', 0 --date paid in the futur
exec spCreatePaymentSupplier 1, '2017-03-17', 5 --amount > amount due (amount due = 0 for supid 1)
exec spCreatePaymentSupplier 5, '2017-03-17', 5 --incorrect supid
exec spCreatePaymentSupplier null, '2017-03-17', 5 --empty supid
exec spCreatePaymentSupplier 2,  '2017-03-17', 500 --balance was 1000 now 500 in tblSupplier working!
exec spCreatePaymentSupplier 1,  '2017-03-17', 300 

SELECT * FROM tblPaymentSup
SELECT * FROM tblSupplier


--Update Payment to supplier
--exec sp_UpdatePaymentSup @PaymentID, @supID, @Date_Paid, @Amount_Paid

UPDATE tblPaymentSup
SET Amount_Paid = 3000
WHERE PaymentID = 1 --current amount 500 supid = 2 change to amount 300.. increase balanceDue in tblSupplier by 200..balance Due will become 700 for supid 2

UPDATE tblPaymentSup
SET supID = 2
WHERE PaymentID = 1 --current amount 100 supid = 3 change to supid 2.. increase balanceDue in tblSupplier by 100..balanceDue for supid = 2 becomes 600, balance Due for supid increases by 100 becomes 1000

UPDATE tblPaymentSup
SET supID = 3, Amount_Paid = 100
WHERE PaymentID = 17 --current amount = 300 supid = 4 change amount to 100 change supid to 3
					--tblsupplier
					--increase balanceDue for supid = 4 by 300 becomes 2000
					--decrease balanceDue for supid = 3 by 100 becomes 900