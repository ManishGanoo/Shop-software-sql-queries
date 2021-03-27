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