CREATE TABLE tblCustomer (
  CustID	INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  Name		VARCHAR(25),
  telephone	INT,
  email		VARCHAR(50),
  balanceDue	DOUBLE PRECISION DEFAULT 0.0
);


CREATE TABLE tblProduct (
  ProductID	 INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  Name		 VARCHAR(25),
  MinQtyStock 	 INT NOT NULL,
  Stock		 INT NOT NULL,
  buyingPrice	 DOUBLE PRECISION NOT NULL,
  sellingPrice 	 DOUBLE PRECISION NOT NULL
);

CREATE TABLE tblSupplier (
  SupplierID	INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  Name		VARCHAR(25),
  telephone	INT,
  email		VARCHAR(50),
  balanceDue	DOUBLE PRECISION  DEFAULT 0.0
);

CREATE TABLE tblSales (
  Sales_Invoice_No  INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  sDate		DATE DEFAULT GETDATE(),
  Pid		INT NOT NULL,
  quantity	INT NOT NULL,
  Weight_Kg	DOUBLE PRECISION NOT NULL,
  Total		DOUBLE PRECISION NOT NULL,
  Paid		CHAR(1),
  DeliveredBy	VARCHAR(50),
  Cid		INT NOT NULL
);

ALTER TABLE tblSales
  ADD CONSTRAINT fk_Sales
FOREIGN KEY (Pid)
REFERENCES tblProduct(ProductID)

ALTER TABLE tblSales
  ADD CONSTRAINT fk_Sales_Cust
FOREIGN KEY (Cid)
REFERENCES tblCustomer(CustID)

CREATE TABLE tblPurchases (
  Purchase_Invoice_No  INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  P_Date		DATE DEFAULT GETDATE(),
  Pid			INT NOT NULL,
  quantity	INT NOT NULL,
  Weight_Kg	DOUBLE PRECISION NOT NULL,
  Total		DOUBLE PRECISION NOT NULL,
  S_id		INT NOT NULL
);

ALTER TABLE tblPurchases
  ADD CONSTRAINT fk_Purchase_Pr
FOREIGN KEY (Pid)
REFERENCES tblProduct(ProductID)

ALTER TABLE tblPurchases
  ADD CONSTRAINT fk_Purchase_Sp
FOREIGN KEY (S_id)
REFERENCES tblSupplier(SupplierID)



CREATE TABLE tblPaymentSup(
  PaymentID	INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  supID			INT,
  Date_Paid	DATE NOT NULL,
  Amount_Paid DOUBLE PRECISION NOT NULL
);

CREATE TABLE tblPaymentCust(
  PaymentCID	INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  custID			INT,
  Date_Paid	DATE NOT NULL,
  Amount_Paid DOUBLE PRECISION NOT NULL
);

ALTER TABLE tblPaymentCust
  ADD CONSTRAINT fk_Customer
FOREIGN KEY (custID)
REFERENCES tblCustomer(CustID)

ALTER TABLE tblPaymentSup
  ADD CONSTRAINT fk_Supplier
FOREIGN KEY (supID)
REFERENCES tblSupplier(SupplierID)