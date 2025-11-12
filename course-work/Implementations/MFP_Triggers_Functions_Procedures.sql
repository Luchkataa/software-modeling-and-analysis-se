Use MyFitnessPalDB
GO

--Vkarva hranene

CREATE PROCEDURE LogMeal
    @UserID INT,
    @Date DATE,
    @MealType NVARCHAR(50),
    @FoodID INT,
    @QuantityGrams FLOAT
AS
BEGIN

    DECLARE @MealID INT;

    SELECT @MealID = MealID
    FROM Meals
    WHERE UserID = @UserID AND Date = @Date AND MealType = @MealType;

    IF @MealID IS NULL
    BEGIN

        INSERT INTO Meals (UserID, Date, MealType, TotalCalories)
        VALUES (@UserID, @Date, @MealType, 0);

        SET @MealID = SCOPE_IDENTITY();
    END

    INSERT INTO MealsFoods (MealID, FoodID, QuantityGrams)
    VALUES (@MealID, @FoodID, @QuantityGrams);


    SELECT @MealID AS LoggedMealID;
END
GO

--Spravka za hraneniqta, trenirovkite i postignatite celi za denq
CREATE PROCEDURE GetDailySummary
    @UserID INT,
    @SummaryDate DATE
AS
BEGIN
    SELECT
        ISNULL(SUM(f.CaloriesPer100g * mf.QuantityGrams / 100.0), 0) AS TotalIntakeCalories,
        ISNULL(SUM(f.Protein * mf.QuantityGrams / 100.0), 0) AS TotalProtein,
        ISNULL(SUM(f.Carbs * mf.QuantityGrams / 100.0), 0) AS TotalCarbs,
        ISNULL(SUM(f.Fat * mf.QuantityGrams / 100.0), 0) AS TotalFat
    FROM Meals m
    JOIN MealsFoods mf ON m.MealID = mf.MealID
    JOIN Foods f ON mf.FoodID = f.FoodID
    WHERE m.UserID = @UserID AND m.Date = @SummaryDate;

    SELECT
        ISNULL(SUM(TotalCaloriesBurned), 0) AS TotalBurnedCalories
    FROM Workouts
    WHERE UserID = @UserID AND Date = @SummaryDate;

    SELECT TOP 1
        CaloriesTargetPerDay,
        ProteinTargetPerDay
    FROM Goals
    WHERE UserID = @UserID
    ORDER BY GoalID DESC;
END
GO

--Izchislqva telesnata masa
CREATE FUNCTION CalculateBMI
(
    @UserID INT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @HeightM FLOAT;
    DECLARE @WeightKG FLOAT;
    DECLARE @BMI FLOAT;

    SELECT @HeightM = Height / 100.0,
           @WeightKG = Weight
    FROM Users
    WHERE UserID = @UserID;

    IF @HeightM IS NULL OR @WeightKG IS NULL OR @HeightM = 0
        RETURN NULL;

    SET @BMI = @WeightKG / POWER(@HeightM, 2);

    RETURN @BMI;
END
GO

--Smenq kaloriite na hranene
CREATE TRIGGER tr_UpdateMealTotalCalories
ON MealsFoods
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MealIDs TABLE (MealID INT);
    INSERT INTO @MealIDs (MealID)
    SELECT MealID FROM INSERTED
    UNION
    SELECT MealID FROM DELETED;

    UPDATE m
    SET TotalCalories = ISNULL(
        (SELECT
            SUM(f.CaloriesPer100g * mf.QuantityGrams / 100.0)
         FROM MealsFoods mf
         JOIN Foods f ON mf.FoodID = f.FoodID
         WHERE mf.MealID = m.MealID
        ), 0)
    FROM Meals m
    JOIN @MealIDs mid ON m.MealID = mid.MealID;
END
GO

--Smenq izgorenite kalorii za trenirovka
CREATE TRIGGER tr_UpdateWorkoutTotalCalories
ON WorkoutExercises
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @WorkoutIDs TABLE (WorkoutID INT);
    INSERT INTO @WorkoutIDs (WorkoutID)
    SELECT WorkoutID FROM INSERTED
    UNION
    SELECT WorkoutID FROM DELETED;

    UPDATE w
    SET TotalCaloriesBurned = ISNULL(
        (SELECT
            SUM(e.CaloriesPerMinute * we.Duration)
         FROM WorkoutExercises we
         JOIN Exercises e ON we.ExerciseID = e.ExerciseID
         WHERE we.WorkoutID = w.WorkoutID
        ), 0)
    FROM Workouts w
    JOIN @WorkoutIDs wid ON w.WorkoutID = wid.WorkoutID;
END
GO

--Testove
EXEC LogMeal
    @UserID = 1,
    @Date = '2025-11-12',
    @MealType = N'????',
    @FoodID = 7,
    @QuantityGrams = 150;

EXEC GetDailySummary
    @UserID = 1,
    @SummaryDate = '2025-11-07';

SELECT dbo.CalculateBMI(2) AS [BMI_Maria_Georgieva];
SELECT dbo.CalculateBMI(3) AS [BMI_Georgi_Ivanov];