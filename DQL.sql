
/*
CST 2102 - HOSPITAL ANALYTICS QUERIES
The queries cover:
- Patient activity and demographics
- Doctor workload and availability
- Financial performance and revenue trends
- Clinical operations and appointment analytics
- Pharmacy and prescription trends
- Resource utilization (rooms, staff)
*/

USE HospitalDB;
GO

-- PATIENT AND DEMOGRAPHICS

-- Patient Activity:
-- Average number of appointments per patient in the last 6 months
SELECT AVG(CAST(AppointmentCount AS DECIMAL(10,2))) AS AvgAppointmentsPerPatient
FROM (
    SELECT p.PatientID, COUNT(a.AppointmentID) AS AppointmentCount
    FROM Patient p
    LEFT JOIN Appointment a
        ON p.PatientID = a.PatientID AND a.AppointmentDate >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY p.PatientID
) AS PatientCounts;

-- Patient Demographics:
-- Breakdown by age group and gender
SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, p.Dob, GETDATE()) < 18 THEN 'Youth (Under 18)'
        WHEN DATEDIFF(YEAR, p.Dob, GETDATE()) BETWEEN 18 AND 35 THEN 'Young Adults (18–35)'
        WHEN DATEDIFF(YEAR, p.Dob, GETDATE()) BETWEEN 36 AND 55 THEN 'Middle Age (36–55)'
        ELSE 'Seniors (56+)'
    END AS AgeGroup,
    p.Sex,
    COUNT(DISTINCT p.PatientID) AS PatientCount
FROM Patient p
JOIN Appointment a
    ON p.PatientID = a.PatientID
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, p.Dob, GETDATE()) < 18 THEN 'Youth (Under 18)'
        WHEN DATEDIFF(YEAR, p.Dob, GETDATE()) BETWEEN 18 AND 35 THEN 'Young Adults (18–35)'
        WHEN DATEDIFF(YEAR, p.Dob, GETDATE()) BETWEEN 36 AND 55 THEN 'Middle Age (36–55)'
        ELSE 'Seniors (56+)'
    END,
    p.Sex
ORDER BY AgeGroup, p.Sex;

-- DOCTOR WORKLOAD AND AVAILABILITY

-- Doctor Workload:
-- Patient load vs average working hours
SELECT d.DoctorID, d.FirstName, d.LastName, d.Specialty, dep.DepartmentName, d.Availability AS AvgWorkingHoursPerDay,
    COUNT(a.AppointmentID) AS PatientLoad,
    CAST(COUNT(a.AppointmentID) AS DECIMAL(10,2)) / NULLIF(d.Availability, 0) AS AppointmentsPerHour
FROM Doctor d
JOIN Department dep
    ON d.DepartmentID = dep.DepartmentID
LEFT JOIN Appointment a
    ON d.DoctorID = a.DoctorID AND a.Status = 'Completed'
GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialty, dep.DepartmentName, d.Availability
ORDER BY PatientLoad DESC, AppointmentsPerHour DESC;

-- Doctor Inactivity:
-- Doctors with no completed appointments in the last 30 days
SELECT d.DoctorID, d.FirstName, d.LastName, d.Specialty, dep.DepartmentName
FROM Doctor d
JOIN Department dep
    ON d.DepartmentID = dep.DepartmentID
LEFT JOIN Appointment a
    ON d.DoctorID = a.DoctorID AND a.Status = 'Completed' AND a.AppointmentDate >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialty, dep.DepartmentName
HAVING COUNT(a.AppointmentID) = 0
ORDER BY dep.DepartmentName, d.LastName, d.FirstName;

-- FINANCES

-- Department Revenue:
-- Total revenue by department (last 3 months)
SELECT dep.DepartmentID, dep.DepartmentName, SUM(b.Amount) AS TotalRevenue
FROM Billing b
JOIN Patient p
    ON b.PatientID = p.PatientID
JOIN Appointment a
    ON p.PatientID = a.PatientID
JOIN Department dep
    ON a.DepartmentID = dep.DepartmentID
WHERE b.PaymentDate >= DATEADD(MONTH, -3, CAST(GETDATE() AS DATE)) 
  AND a.AppointmentDate >= DATEADD(MONTH, -3, CAST(GETDATE() AS DATE)) 
  AND b.PayStatus = 'Paid'
GROUP BY dep.DepartmentID, dep.DepartmentName
ORDER BY TotalRevenue DESC;

-- Revenue by Payment Method:
-- Breakdown of collected revenue
SELECT b.PaymentMethod, COUNT(b.BillingID) AS NumberOfPayments, SUM(b.Amount) AS TotalRevenueCollected
FROM Billing b
JOIN Patient p
    ON b.PatientID = p.PatientID
JOIN Appointment a
    ON p.PatientID = a.PatientID
WHERE b.PayStatus = 'Paid'
GROUP BY b.PaymentMethod
ORDER BY TotalRevenueCollected DESC;

-- Billing Trend:
-- Monthly billing trend over the past 12 months
SELECT YEAR(b.PaymentDate) AS BillingYear, MONTH(b.PaymentDate) AS BillingMonth, COUNT(b.BillingID) AS NumberOfBills, SUM(b.Amount) AS TotalBilled
FROM Billing b
JOIN Patient p
    ON b.PatientID = p.PatientID
LEFT JOIN Appointment a
    ON p.PatientID = a.PatientID
WHERE b.PaymentDate >= DATEADD(MONTH, -12, CAST(GETDATE() AS DATE))
GROUP BY YEAR(b.PaymentDate), MONTH(b.PaymentDate)
ORDER BY BillingYear, BillingMonth;

-- CLINICAL OPERATIONS AND APPOINTMENTS

-- Common Diagnoses by Department:
SELECT mr.Diagnosis, dep.DepartmentName, COUNT(mr.RecordID) AS CasesTreated
FROM MedicalRecords mr
JOIN Doctor d
    ON mr.DoctorID = d.DoctorID
JOIN Department dep
    ON d.DepartmentID = dep.DepartmentID
GROUP BY mr.Diagnosis, dep.DepartmentName
ORDER BY CasesTreated DESC, mr.Diagnosis;

-- Demand by Specialty:
SELECT d.Specialty, COUNT(a.AppointmentID) AS TotalAppointments
FROM Appointment a
JOIN Doctor d
    ON a.DoctorID = d.DoctorID
JOIN Department dep
    ON d.DepartmentID = dep.DepartmentID
WHERE a.Status = 'Completed'
GROUP BY d.Specialty
ORDER BY TotalAppointments DESC;

-- Appointment Cancellation Rate:
SELECT dep.DepartmentName, COUNT(a.AppointmentID) AS TotalAppointments,
    SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledAppointments,
    CAST(100.0 * SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END)/ NULLIF(COUNT(a.AppointmentID), 0) AS DECIMAL(5,2)) AS CancellationRatePercent
FROM Appointment a
JOIN Department dep
    ON a.DepartmentID = dep.DepartmentID
JOIN Doctor d
    ON a.DoctorID = d.DoctorID
GROUP BY dep.DepartmentName
ORDER BY CancellationRatePercent DESC;

-- Busiest Appointment Time Slots:
SELECT dep.DepartmentName, DATENAME(WEEKDAY, a.AppointmentDate) AS DayOfWeek, DATEPART(HOUR, a.AppointmentTime) AS HourOfDay, COUNT(a.AppointmentID) AS AppointmentCount
FROM Appointment a
JOIN Department dep
    ON a.DepartmentID = dep.DepartmentID
JOIN Doctor d
    ON a.DoctorID = d.DoctorID
GROUP BY dep.DepartmentName, DATENAME(WEEKDAY, a.AppointmentDate), DATEPART(HOUR, a.AppointmentTime)
ORDER BY AppointmentCount DESC, dep.DepartmentName, DayOfWeek, HourOfDay;

-- PHARMACY AND PRESCRIPTIONS

-- Top Prescribed Medicines:
SELECT TOP 5 m.MedicineID, m.MedicineName, COUNT(pr.PerscriptionID) AS TimesPrescribed
FROM Perscription pr
JOIN Medicine m
    ON pr.MedicineID = m.MedicineID
JOIN MedicalRecords mr
    ON pr.RecordID = mr.RecordID
WHERE mr.VisitDate >= DATEADD(MONTH, -3, CAST(GETDATE() AS DATE))
GROUP BY m.MedicineID, m.MedicineName
ORDER BY TimesPrescribed DESC, m.MedicineName;

-- Diagnoses with Most Prescriptions:
SELECT mr.Diagnosis, COUNT(pr.PerscriptionID) AS TotalPrescriptions
FROM MedicalRecords mr
JOIN Perscription pr
    ON mr.RecordID = pr.RecordID
JOIN Medicine m
    ON pr.MedicineID = m.MedicineID
GROUP BY mr.Diagnosis
ORDER BY TotalPrescriptions DESC;

-- HOSPITAL RESOURCES

-- Room Utilization:
-- Occupancy percentage by room type (last month)
SELECT r.RoomType,
    COUNT(DISTINCT CASE 
        WHEN ra.AdmittedDate <= EOMONTH(GETDATE(), -1)
         AND (rh.DischargeDate IS NULL 
              OR rh.DischargeDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0))
        THEN r.RoomNum
    END) AS OccupiedRooms,
    COUNT(DISTINCT r.RoomNum) AS TotalRooms,
    CAST(
        100.0 * COUNT(DISTINCT CASE 
            WHEN ra.AdmittedDate <= EOMONTH(GETDATE(), -1)
             AND (rh.DischargeDate IS NULL 
                  OR rh.DischargeDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0))
            THEN r.RoomNum
        END) / NULLIF(COUNT(DISTINCT r.RoomNum), 0)
        AS DECIMAL(5,2)
    ) AS OccupancyPercent
FROM Room r
LEFT JOIN RoomAssignment ra
    ON r.RoomNum = ra.RoomNum
LEFT JOIN RoomHistory rh
    ON ra.RoomNum = rh.RoomNum
   AND ra.PatientID = rh.PatientID
GROUP BY r.RoomType
ORDER BY r.RoomType;

-- STAFF

-- Staff Distribution:
-- Headcount by role and department
SELECT dep.DepartmentName, s.Role, COUNT(s.StaffID) AS StaffCount
FROM Staff s
JOIN Department dep
    ON s.DepartmentID = dep.DepartmentID
LEFT JOIN Doctor d
    ON dep.DepartmentID = d.DepartmentID
GROUP BY dep.DepartmentName, s.Role
ORDER BY dep.DepartmentName, StaffCount DESC;