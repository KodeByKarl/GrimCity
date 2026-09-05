CREATE TABLE IF NOT EXISTS university_students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    student_id VARCHAR(20) NOT NULL UNIQUE,
    dob DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    address VARCHAR(255) NOT NULL,
    guardian VARCHAR(255) NOT NULL,
    contact VARCHAR(50) NOT NULL,
    grade INT NOT NULL,
    hasAllergies ENUM('Yes', 'No') NOT NULL,
    medical TEXT,
    emergencyName VARCHAR(255),
    emergencyNumber VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS university_teachers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    teacher_id VARCHAR(20) NOT NULL UNIQUE,
    dob DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    address VARCHAR(255) NOT NULL,
    contact VARCHAR(50) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    qualifications TEXT,
    emergencyName VARCHAR(255),
    emergencyNumber VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS university_announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);