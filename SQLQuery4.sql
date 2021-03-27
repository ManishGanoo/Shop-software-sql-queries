INSERT INTO tblCustomer(Name, telephone, email)
VALUES('fg',12345678, 'tom.brady@gmail.com')

SELECT * FROM tblCustomer

UPDATE tblCustomer
SET balanceDue = 0
WHERE CustID = 1