-- Run as: sudo mysql < schema.sql   (change the password first)
CREATE DATABASE IF NOT EXISTS appdb;
CREATE USER IF NOT EXISTS 'appuser'@'localhost' IDENTIFIED BY 'YOUR_DB_PASSWORD';
GRANT ALL ON appdb.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;
USE appdb;
CREATE TABLE IF NOT EXISTS students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50),
  course VARCHAR(30)
);
INSERT INTO students (name, course) VALUES
  ('Nazmeen Ali','MCA'), ('Rahul Sharma','BCA'), ('Priya Singh','MCA');
