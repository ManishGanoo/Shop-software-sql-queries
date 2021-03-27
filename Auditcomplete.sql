USE S_Sandooyea


--Audit table
CREATE TABLE dbo.tblAudit(
AuditId INTEGER IDENTITY(1,1)PRIMARY KEY,
TableName NVARCHAR(255),
EventType NVARCHAR(128),
UpdatedBy NVARCHAR(128),
UpdatedOn DATETIME
);

--trigger for tblCustomer
CREATE TRIGGER AuditTriggerCUST ON tblCustomer
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
DECLARE @Type VARCHAR(20)
 
 if exists (SELECT * FROM inserted)
		if exists (SELECT * FROM deleted)
			SELECT @Type = 'UPDATED'
		else
			SELECT @Type = 'INSERTED'
	else
		SELECT @Type = 'DELETED'
		

  INSERT INTO dbo.tblAudit(TableName, EventType, UpdatedBy, UpdatedOn )
  VALUES('tblCustomer',@Type,SUSER_SNAME(), getdate());
  
END

INSERT INTO S_Sandooyea.dbo.tblCustomer (Name,telephone,email,balanceDue)
VALUES('sam',12345678,'asdfdsfdsf',2800);

DELETE FROM tblCustomer
WHERE CustID = 12; 

--triger for table tblProduct

CREATE TRIGGER AuditTriggerPROD ON tblProduct
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
DECLARE @Type VARCHAR(20)
 
 if exists (SELECT * FROM inserted)
		if exists (SELECT * FROM deleted)
			SELECT @Type = 'UPDATED'
		else
			SELECT @Type = 'INSERTED'
	else
		SELECT @Type = 'DELETED'
		

  INSERT INTO dbo.tblAudit(TableName, EventType, UpdatedBy, UpdatedOn )
  VALUES('tblProduct',@Type,SUSER_SNAME(), getdate());
  
END

--triger for table tblPurchases

CREATE TRIGGER AuditTriggerPURCHASE ON tblPurchases
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
DECLARE @Type VARCHAR(20)
 
 if exists (SELECT * FROM inserted)
		if exists (SELECT * FROM deleted)
			SELECT @Type = 'UPDATED'
		else
			SELECT @Type = 'INSERTED'
	else
		SELECT @Type = 'DELETED'
		

  INSERT INTO dbo.tblAudit(TableName, EventType, UpdatedBy, UpdatedOn )
  VALUES('tblPurchases',@Type,SUSER_SNAME(), getdate());
  
END

--triger for table tblSales

CREATE TRIGGER AuditTriggerSALE ON tblSales
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
DECLARE @Type VARCHAR(20)
 
 if exists (SELECT * FROM inserted)
		if exists (SELECT * FROM deleted)
			SELECT @Type = 'UPDATED'
		else
			SELECT @Type = 'INSERTED'
	else
		SELECT @Type = 'DELETED'
		

  INSERT INTO dbo.tblAudit(TableName, EventType, UpdatedBy, UpdatedOn )
  VALUES('tblSales',@Type,SUSER_SNAME(), getdate());
  
END

--triger for table tblSupplier

CREATE TRIGGER AuditTriggerPROD ON tblSupplier
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
DECLARE @Type VARCHAR(20)
 
 if exists (SELECT * FROM inserted)
		if exists (SELECT * FROM deleted)
			SELECT @Type = 'UPDATED'
		else
			SELECT @Type = 'INSERTED'
	else
		SELECT @Type = 'DELETED'
		

  INSERT INTO dbo.tblAudit(TableName, EventType, UpdatedBy, UpdatedOn )
  VALUES('tblSupplier',@Type,SUSER_SNAME(), getdate());
  
END

--triger for table tblPaymentCust

CREATE TRIGGER AuditTriggerPayCust ON tblPaymentCust
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
DECLARE @Type VARCHAR(20)
 
 if exists (SELECT * FROM inserted)
		if exists (SELECT * FROM deleted)
			SELECT @Type = 'UPDATED'
		else
			SELECT @Type = 'INSERTED'
	else
		SELECT @Type = 'DELETED'
		

  INSERT INTO dbo.tblAudit(TableName, EventType, UpdatedBy, UpdatedOn )
  VALUES('tblPaymentCust',@Type,SUSER_SNAME(), getdate());
  
END

--triger for table tblPaymentSup

CREATE TRIGGER AuditTriggerPayCust ON tblPaymentSup
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
DECLARE @Type VARCHAR(20)
 
 if exists (SELECT * FROM inserted)
		if exists (SELECT * FROM deleted)
			SELECT @Type = 'UPDATED'
		else
			SELECT @Type = 'INSERTED'
	else
		SELECT @Type = 'DELETED'
		

  INSERT INTO dbo.tblAudit(TableName, EventType, UpdatedBy, UpdatedOn )
  VALUES('tblPaymentSup',@Type,SUSER_SNAME(), getdate());
  
END