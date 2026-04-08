create database HospitalDB;
use HospitalDB;

create table Patient (
    PatientID int primary key,
    FirstName varchar(15),
    LastName varchar(20),
    Dob date,
    Sex varchar(6),
    Address varchar(100),
    PhoneNumber varchar(25),
    Email varchar(75),
    EmergencyName varchar(50),
    EmergencyPhoneNumber varchar(25)
)

create table Medicine (
    MedicineID int primary key,
    MedicineName varchar(100),
    Manufactuer varchar(100),
    Stock int,
    Price decimal(5,2)
)

create table Department (
    DepartmentID int primary key,
    DepartmentName varchar(40),
    Ward varchar(5),
    PhoneExtension varchar(4)
)

create table Billing (
    BillingID int primary key,
    PatientID int,
    Amount decimal(6,2),
    PayStatus varchar(6),
    PaymentDate date,
    PaymentMethod varchar(9),
    IsInsured varchar(3)
)

create table Doctor (
    DoctorID int primary key,
    FirstName varchar(15),
    LastName varchar(20),
    Specialty varchar(50),
    PhoneNumber varchar(25),
    Email varchar(75),
    Address varchar(100),
    Availability int,
    DepartmentID int,
    foreign key (DepartmentID) references Department(DepartmentID)
)

create table Staff (
    StaffID int primary key,
    FirstName varchar(15),
    LastName varchar(20),
    Role varchar(50),
    PhoneNumber varchar(25),
    Email varchar(75),
    Address varchar(100),
    ShiftHours varchar(13),
    DepartmentID int,
    foreign key (DepartmentID) references Department(DepartmentID)
)

create table Room (
    RoomNum varchar(5) primary key,
    RoomType varchar(9),
    Availability varchar(9),
    DepartmentID int,
    foreign key (DepartmentID) references Department(DepartmentID)    
)

create table RoomAssignment(
    AssignmentID int primary key,
    AdmittedDate date,
    PatientID int,
    RoomNum varchar(5),
    foreign key (PatientID) references Patient(PatientID),
    foreign key (RoomNum) references Room(RoomNum)
)

create table RoomHistory (
    HistoryID int primary key,
    RoomNum varchar(5),
    PatientID int,
    DischargeDate date,
    foreign key (RoomNum) references Room(RoomNum),
    foreign key (PatientID) references Patient(PatientID)
)

create table Appointment (
    AppointmentID int primary key,
    AppointmentDate date,
    AppointmentTime time,
    Status varchar(9),
    PatientID int,
    DoctorID int,
    DepartmentID int,
    foreign key (PatientID) references Patient(PatientID),
    foreign key (DoctorID) references Doctor(DoctorID),
    foreign key (DepartmentID) references Department(DepartmentID)
)

create table MedicalRecords (
    RecordID int primary key,
    VisitDate date,
    Diagnosis varchar(50),
    TreatmentPlan varchar(10),
    PatientID int,
    DoctorID int,
    foreign key (PatientID) references Patient(PatientID),
    foreign key (DoctorID) references Doctor(DoctorID)
)

create table Perscription (
    PerscriptionID int primary key,
    Dosage int,
    Frequency varchar(11),
    DurationDays int,
    RecordID int,
    MedicineID int,
    foreign key (RecordID) references MedicalRecords(RecordID),
    foreign key (MedicineID) references Medicine(MedicineID)
)