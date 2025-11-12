CREATE DATABASE MyFitnessPalDB;
GO
USE MyFitnessPalDB;
GO

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) UNIQUE NOT NULL,
    Password NVARCHAR(200) NOT NULL,
    Age INT,
    Gender NVARCHAR(10),
    Height FLOAT,
    Weight FLOAT,
    JoinDate DATE NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Workouts (
    WorkoutID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    WorkoutName NVARCHAR(100),
    Date DATE NOT NULL,
    DurationMinutes INT,
    TotalCaloriesBurned INT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE Exercises (
    ExerciseID INT IDENTITY(1,1) PRIMARY KEY,
    Category NVARCHAR(100),
    Name NVARCHAR(100) NOT NULL,
    Equipment NVARCHAR(100),
    CaloriesPerMinute FLOAT
);

CREATE TABLE WorkoutExercises (
    WorkoutID INT NOT NULL,
    ExerciseID INT NOT NULL,
    Sets INT,
    Reps INT,
    Duration INT,
    PRIMARY KEY (WorkoutID, ExerciseID),
    FOREIGN KEY (WorkoutID) REFERENCES Workouts(WorkoutID),
    FOREIGN KEY (ExerciseID) REFERENCES Exercises(ExerciseID)
);

CREATE TABLE Goals (
    GoalID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Category NVARCHAR(100),
    CaloriesTargetPerDay INT,
    ProteinTargetPerDay FLOAT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE Meals (
    MealID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Date DATE NOT NULL,
    MealType NVARCHAR(50),
    TotalCalories INT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE Foods (
    FoodID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Category NVARCHAR(100),
    CaloriesPer100g FLOAT,
    Protein FLOAT,
    Carbs FLOAT,
    Fat FLOAT,
    CreatedAt DATE NOT NULL DEFAULT GETDATE()
);

CREATE TABLE MealsFoods (
    MealID INT NOT NULL,
    FoodID INT NOT NULL,
    QuantityGrams FLOAT,
    PRIMARY KEY (MealID, FoodID),
    FOREIGN KEY (MealID) REFERENCES Meals(MealID),
    FOREIGN KEY (FoodID) REFERENCES Foods(FoodID)
);

