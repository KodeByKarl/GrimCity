-- Create table for university students
CREATE TABLE IF NOT EXISTS university_students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL COMMENT 'Stores the player identifier (ESX or QBCore)',
    name VARCHAR(255) NOT NULL COMMENT 'Student full name',
    student_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Unique student ID',
    dob DATE NOT NULL COMMENT 'Date of birth',
    gender ENUM('Male', 'Female', 'Other') NOT NULL COMMENT 'Gender of the student',
    address VARCHAR(255) NOT NULL COMMENT 'Residential address',
    guardian VARCHAR(255) NOT NULL COMMENT 'Guardian name',
    contact VARCHAR(50) NOT NULL COMMENT 'Contact number',
    grade INT NOT NULL COMMENT 'Grade or year level',
    hasAllergies ENUM('Yes', 'No') NOT NULL COMMENT 'Whether the student has allergies',
    medical TEXT COMMENT 'Medical information or notes',
    emergencyName VARCHAR(255) COMMENT 'Emergency contact name',
    emergencyNumber VARCHAR(50) COMMENT 'Emergency contact number'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create table for university teachers
CREATE TABLE IF NOT EXISTS university_teachers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL COMMENT 'Stores the player identifier (ESX or QBCore)',
    name VARCHAR(255) NOT NULL COMMENT 'Teacher full name',
    teacher_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Unique teacher ID',
    dob DATE NOT NULL COMMENT 'Date of birth',
    gender ENUM('Male', 'Female', 'Other') NOT NULL COMMENT 'Gender of the teacher',
    address VARCHAR(255) NOT NULL COMMENT 'Residential address',
    contact VARCHAR(50) NOT NULL COMMENT 'Contact number',
    subject VARCHAR(255) NOT NULL COMMENT 'Subject taught',
    qualifications TEXT COMMENT 'Educational qualifications or certifications',
    emergencyName VARCHAR(255) COMMENT 'Emergency contact name',
    emergencyNumber VARCHAR(50) COMMENT 'Emergency contact number'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create table for university announcements
CREATE TABLE IF NOT EXISTS university_announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id VARCHAR(255) NOT NULL COMMENT 'Stores the player identifier (ESX or QBCore) for the sender',
    sender_name VARCHAR(255) NOT NULL COMMENT 'Human-readable name of the sender',
    message TEXT NOT NULL COMMENT 'Announcement message content',
    category VARCHAR(50) NOT NULL COMMENT 'Announcement category (e.g., General, Emergency)',
    priority VARCHAR(50) NOT NULL COMMENT 'Announcement priority (e.g., Low, Medium, High, Critical)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Time the announcement was created'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Add the 'school' job to ESX jobs table if it doesn't exist
INSERT IGNORE INTO jobs (name, label) VALUES ('school', 'University of Los Santos');

-- Add job grades for the 'school' job
INSERT IGNORE INTO job_grades (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
    ('school', 0, 'student', 'Student', 10, '{}', '{}'),
    ('school', 1, 'professor', 'Professor', 30, '{}', '{}'),
    ('school', 2, 'director', 'Director', 125, '{}', '{}');