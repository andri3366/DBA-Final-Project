use HospitalDB;

Bulk insert Patient
from 'C:\DBA_FinalProject\csv_output\patient.csv'
with (
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '\n',
    tablock
);

Bulk insert Medicine
from 'C:\DBA_FinalProject\csv_output\medicine.csv'
with (
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '\n'
);

Bulk insert Department
from 'C:\DBA_FinalProject\csv_output\department.csv'
with (
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '\n',
    tablock
);

Bulk insert Billing
from 'C:\DBA_FinalProject\csv_output\billing.csv'
with (
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '\n',
    tablock
);

Bulk insert Doctor
from 'C:\DBA_FinalProject\csv_output\doctor.csv'
with (
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '\n',
    tablock
);

Bulk insert Staff
from 'C:\DBA_FinalProject\csv_output\staff.csv'
with (
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '\n',
    tablock
);

Bulk insert Room
from 'C:\DBA_FinalProject\csv_output\room.csv'
with (
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '\n',
    tablock
);

Bulk insert RoomAssignment
from 'C:\DBA_FinalProject\csv_output\room_assignment.csv'
with (
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '\n',
    tablock
);

Bulk insert RoomHistory
from 'C:\DBA_FinalProject\csv_output\room_history.csv'
with (
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '\n',
    tablock
);

Bulk insert Appointment
from 'C:\DBA_FinalProject\csv_output\appointment.csv'
with (
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '\n',
    tablock
);

Bulk insert MedicalRecords
from 'C:\DBA_FinalProject\csv_output\medical_records.csv'
with (
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '\n',
    tablock
);

Bulk insert Perscription
from 'C:\DBA_FinalProject\csv_output\prescription.csv'
with (
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '\n',
    tablock
);