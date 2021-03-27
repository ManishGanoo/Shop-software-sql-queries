USE S_Sandooyea_Shop


--Sales--






--Product--




--Customer--






--Purchases--

--create purchase
--exec spCreatePurchase @pid, @quantity, @weight_kg, @Sid
exec spCreatePurchase @pid, @quantity, @weight_kg, @Sid
exec spCreatePurchase 1, 100, 50,2 --good
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

--update purchase
--exec sp_UpdatePurchase @purchaseinvoiceID, @pid, @quantity, @Weight_kg, @Sid
exec sp_UpdatePurchase null, null,null,null,null --parameter empty
exec sp_UpdatePurchase 1, null,null,null,null --parameter empty
exec sp_UpdatePurchase 1, null,null,null,null




--Payment made to supplier




--Payment made to customer



















DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
----------------------  Name,tel,      email 
EXEC sp_InsertCustomer 'sumida',‎57418521,'email@gmail.com',@ErrorMsg OUTPUT
PRINT @ErrorMsg

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
----------------------Cid,Name,tel,email,              bal
EXEC sp_ModifyCustomer 1, null, null,'sumida@gmail.com',50000,@ErrorMsg OUTPUT
PRINT @ErrorMsg

SELECT *
FROM tblCustomer

PRINT dbo.CalculateTotal(100,5,10)

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
-------------------Pid, Quan,weight,disc,paid,delivered,cid
EXEC sp_InsertSales 1,  50,  100,   null,'y', 'x',      1,@ErrorMsg OUTPUT
PRINT @ErrorMsg

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
EXEC sp_Delete_Sales 2,@ErrorMsg OUTPUT
PRINT @ErrorMsg

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
-------------------Sid,Pid, Quan,weight,disc,total,paid,delivered,cid
EXEC sp_ModifySales 1, 2,15,  200,  null, null,'n',  null,     null,@ErrorMsg OUTPUT
PRINT @ErrorMsg

SELECT * FROM view_Sales

DECLARE @ErrorMsg AS VARCHAR(50)
SET @ErrorMsg='null'
-----------------------------Cid,bal
EXEC sp_InsertPaymentCustomer 1,10000,@ErrorMsg OUTPUT
PRINT @ErrorMsg

SELECT * FROM view_PaymentCustomer