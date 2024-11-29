CREATE DATABASE Fitness_Center_Management; 
USE Fitness_Center_Management;
CREATE TABLE members (
  member_id INT PRIMARY KEY,
  name VARCHAR(100),
  membership_type VARCHAR(50),
  join_date DATE
);

CREATE TABLE classes (
  class_id INT PRIMARY KEY,
  class_name VARCHAR(100),
  instructor VARCHAR(100),
  schedule DATETIME
);

CREATE TABLE attendance (
  attendance_id INT PRIMARY KEY,
  member_id INT,
  class_id INT,
  attendance_date DATE,
  FOREIGN KEY (member_id) REFERENCES members(member_id),
  FOREIGN KEY (class_id) REFERENCES classes(class_id)
);

-- Sample Data for Members
INSERT INTO members (member_id, name, membership_type, join_date) VALUES
(1, 'John Doe', 'Gold', '2024-11-01'),
(2, 'Jane Smith', 'Silver', '2024-10-15');

-- Sample Data for Classes
INSERT INTO classes (class_id, class_name, instructor, schedule) VALUES
(1, 'Yoga', 'Alice Johnson', '2024-11-22 10:00:00'),
(2, 'Pilates', 'Bob Brown', '2024-11-23 12:00:00');

-- Sample Data for Attendance
INSERT INTO attendance (attendance_id, member_id, class_id, attendance_date) VALUES
(1, 1, 1, '2024-11-22'),
(2, 2, 2, '2024-11-23');	

-- Retrieve attendance records for a specific class
SELECT * FROM attendance WHERE class_id = 1;

-- Get member details based on membership type
SELECT * FROM members WHERE membership_type = 'Gold';

-- Calculate total attendance per class
SELECT class_id, COUNT(*) as total_attendance FROM attendance GROUP BY class_id;

-- List members who attended a specific class
SELECT members.name FROM members JOIN attendance ON members.member_id = attendance.member_id WHERE attendance.class_id = 1;

-- Identify the most popular classes based on attendance
SELECT class_name, COUNT(*) as attendance_count FROM classes JOIN attendance ON classes.class_id = attendance.class_id GROUP BY class_name ORDER BY attendance_count DESC;

-- Retrieve membership details for a specific member
SELECT * FROM members WHERE member_id = 1;

-- Count the number of classes offered by month
SELECT MONTH(schedule) as month, COUNT(*) as total_classes FROM classes GROUP BY month;

-- Get members who have not attended any classes in the last month
SELECT * FROM members WHERE member_id NOT IN (SELECT member_id FROM attendance WHERE attendance_date >= DATEADD(MONTH, -1, GETDATE()));

-- Find members with upcoming renewals
SELECT * FROM members WHERE join_date BETWEEN DATEADD(YEAR, -1, GETDATE()) AND GETDATE();

-- List all members with upcoming rewards
SELECT * FROM members WHERE join_date BETWEEN DATEADD(MONTH, -6, GETDATE()) AND GETDATE();
-- Count the number of classes offered by month
SELECT 
    MONTH(schedule) as class_month, 
    COUNT(*) as total_classes 
FROM classes 
GROUP BY MONTH(schedule);

-- Create views for membership and class popularity
CREATE VIEW membership_view AS SELECT membership_type, COUNT(*) as total_members FROM members GROUP BY membership_type;
CREATE VIEW class_popularity_view AS SELECT class_name, COUNT(*) as total_attendance FROM classes JOIN attendance ON classes.class_id = attendance.class_id GROUP BY class_name;

-- Develop stored procedures for class registration
CREATE PROCEDURE register_class
    @member_id INT,
    @class_id INT
AS
BEGIN
    INSERT INTO attendance (member_id, class_id, attendance_date)
    VALUES (@member_id, @class_id, GETDATE());
END;
GO


-- Implement functions to calculate attendance rates
CREATE FUNCTION attendance_rate (@class_id INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @total_attendance INT;
    DECLARE @total_classes INT;
    DECLARE @attendance_rate FLOAT;

    -- Calculate total attendance for the class
    SELECT @total_attendance = COUNT(*)
    FROM attendance
    WHERE class_id = @class_id;

    -- Calculate total number of classes
    SELECT @total_classes = COUNT(*)
    FROM classes
    WHERE class_id = @class_id;

    -- Calculate attendance rate
    IF @total_classes > 0
    BEGIN
        SET @attendance_rate = (@total_attendance / CAST(@total_classes AS FLOAT)) * 100;
    END
    ELSE
    BEGIN
        SET @attendance_rate = 0;
    END

    RETURN @attendance_rate;
END;
GO


-- Send notifications for membership renewal reminders (Pseudo-code)
CREATE PROCEDURE membership_renewal_reminder
AS
BEGIN
    SELECT * 
    FROM members 
    WHERE join_date BETWEEN DATEADD(MONTH, -11, GETDATE()) AND DATEADD(MONTH, -10, GETDATE());

    -- Logic to send email notifications can be implemented using SQL Server Agent Jobs or an external application.
END;
GO


-- Design timetable-related functions for class recommendations (Pseudo-code)
CREATE FUNCTION recommended_classes (@member_id INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @recommended_classes_list VARCHAR(MAX);

    -- Create the list of recommended classes
    SELECT @recommended_classes_list = STRING_AGG(class_name, ', ')
    FROM classes
    WHERE class_id NOT IN (SELECT class_id FROM attendance WHERE member_id = @member_id);

    RETURN @recommended_classes_list;
END;
GO