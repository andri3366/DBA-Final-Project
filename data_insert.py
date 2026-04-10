from faker import Faker
from faker_healthcare import HealthcareProvider
import random
import csv
import os
import difflib
from rapidfuzz import process
from datetime import datetime, date
from collections import Counter

fake = Faker()
fake.add_provider(HealthcareProvider)

# Max number of Rows for each table
NUM_PATIENT = 586
NUM_DOCTOR = 127
NUM_DEPARTMENT = 30
NUM_BILLING = 786
NUM_APPOINTMENT = 891
NUM_STAFF = 169
NUM_ROOM = 150
NUM_MEDICINE = 252
NUM_PRESCRIPTION = 1780
NUM_MEDICAL_RECORDS = 648
NUM_ROOM_ASSIGNMENT = NUM_ROOM
NUM_ROOM_HISTORY = 346

# Tables
patient = []
doctor = []
department = []
billing = []
appointment = []
staff = []
room = []
medicine = []
prescription = []
medical_records = []
room_assignment = []
room_history = []

# check peds
def calculate_age_appt(dob_string, appt_date):
    dob = datetime.strptime(dob_string, "%Y-%m-%d").date()
    
    age = appt_date.year - dob.year - (
        (appt_date.month, appt_date.day) < (dob.month, dob.day)
    )
    return age

def calculate_age(dob_string):
    dob = datetime.strptime(dob_string, "%Y-%m-%d").date()
    today = date.today()
    return today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day))


def generate_appointment_date(dob_string):
    dob = datetime.strptime(dob_string, "%Y-%m-%d").date()
    today = date.today()

    start = today.replace(year=today.year - 3)
    end = today.replace(year=today.year + 1)

    if dob > start:
        start = dob

    appt_date = fake.date_between(start_date=start, end_date=end)

    while appt_date == dob:
        appt_date = fake.date_between(start_date=start, end_date=today)

    return appt_date

def generate_appointment_time():
    
    hour = random.randint(7,18)
    minute = random.choice([0,15,30,45])

    return hour * 60 + minute

def format_time(minutes):
    hour = minutes // 60
    minute = minutes % 60
    seconds = 00

    return f"{hour:02}:{minute:02}:{seconds:02}"

def generate_visit_date(dob_string):

    dob = datetime.strptime(dob_string, "%Y-%m-%d").date()
    today = date.today()

    start = today.replace(year=today.year - 3)

    if dob > start:
        start = dob

    visit_date = fake.date_between(start_date=start, end_date=today)

    while visit_date == dob:
        visit_date = fake.date_between(start_date=start, end_date=today)

    return visit_date

def classify_treatment(diagnosis):

    diagnosis = diagnosis.lower()

    for treatment, keywords in treatment_keywords.items():

        match = process.extractOne(diagnosis, keywords)

        if match and match[1] > 70:
            return treatment

    return "Medication"

# Patient Table
for i in range(1, NUM_PATIENT + 1):

    fake_fn = fake.first_name()
    lower_fake_fn = fake_fn.lower()
    fake_domain = fake.free_email_domain()
    fake_email = lower_fake_fn + '@' + fake_domain

    patient.append([
        i,
        fake_fn,
        fake.last_name(),
        fake.date_of_birth().isoformat(),
        ## add age date of today - date of birth
        random.choice(["Male", "Female"]),
        fake.street_address(),
        fake.phone_number(),
        fake_email,
        fake.name(),
        fake.phone_number()
    ])

patient_id = [p[0] for p in patient]

# Medicine
for i in range(1, NUM_MEDICINE + 1):

    company = fake.company()
    name_only = company.split(', ', 1)[-1]
    medicine.append([
        i,
        fake.generic_drug(),
        name_only,
        random.randint(10,500),
        round(random.uniform(5,100),2)
    ])

medicine_id = [m[0] for m in medicine]

# Department

department_names = set()

while len(department_names) < NUM_DEPARTMENT:
    department_names.add(fake.hospital_department())

department_names = list(department_names)

wards = ["North", "South", "West", "East"]
# North - critical, East - diagnostic, West - surgical, South - therapy
ward_rules = {
    "North": ["ICU", "CCU", "NICU", "Burn", "Emergency"],
    "East": ["Radiology", "Laboratory", "Endoscopy", "Pharmacy"],
    "West": ["Surgery", "Operating", "PACU"],
    "South": ["Therapy", "Rehabilitation", "Dialysis"]
}

for i, department_name in enumerate(department_names, start=1):

    ward = None

    for w, keywords in ward_rules.items():
        if any(k.lower() in department_name.lower() for k in keywords):
            ward = w
            break

    if ward is None:
        ward = random.choice(wards)

    department.append([
        i,
        department_name,
        ward,
        fake.numerify(text='####')
    ])

department_id = [d[0] for d in department]

# Billing
for i in range(1, NUM_BILLING + 1):
    status = random.choice(["Paid", "Unpaid"])
    insurance = random.choice(["Yes", "No"])
    no_insurance =["Cash", "Credit", "Check"]
    has_insurance = ["Cash", "Credit", "Check", "Insurance"]

    if status == "Paid":
        payment_date = fake.date_this_year().isoformat()
    else:
        payment_date = None

    if insurance == "No":
        payment_method = random.choice(no_insurance)
    else:
        payment_method = random.choice(has_insurance)
    billing.append([
        i,
        random.choice(patient_id),
        round(random.uniform(40, 2000), 2),
        status,
        payment_date,
        payment_method,
        insurance
    ])

# Doctor
department_lookup = {d[1]: d[0] for d in department}
department_list = [d[1] for d in department]

for i in range(1, NUM_DOCTOR + 1):

    doc_fake_fn = fake.first_name()
    lower_doc_fake_fn = doc_fake_fn.lower()
    doc_fake_domain = fake.free_email_domain()
    doc_fake_email = lower_doc_fake_fn + '@' + doc_fake_domain

    specialty = fake.disease_medical_specialty()

    # fuzzy match specialty to department
    match = process.extractOne(specialty, department_list)

    if match:
        dept_name = match[0]
    else:
        dept_name = random.choice(department_list)

    dept_id = department_lookup[dept_name]

    doctor.append([
        i,
        doc_fake_fn,
        fake.last_name(),
        specialty,
        fake.phone_number(),
        doc_fake_email,
        fake.street_address(),
        random.randint(4,12),
        dept_id
    ])
doctor_id = [d[0] for d in doctor]

# Staff

roles = ["Nurse", "Technician", "Receptionist", "Administrator"]
for i in range(1, NUM_STAFF + 1):

    staff_fake_fn = fake.first_name()
    staff_lower_fake_fn = staff_fake_fn.lower()
    staff_fake_domain = fake.free_email_domain()
    staff_fake_email = staff_lower_fake_fn + '@' + staff_fake_domain

    staff.append([
        i,
        staff_fake_fn,
        fake.last_name(),
        random.choice(roles),
        fake.phone_number(),
        staff_fake_email,
        fake.street_address(),
        random.choice(["Day", "Night"]),
        random.choice(department_id)
    ])

# Room

ward_letters = {
    "North": "N",
    "South": "S",
    "East": "E",
    "West": "W"
}

ward_departments = {}

for d in department:
    dept_id = d[0]
    ward = d[2]

    ward_departments.setdefault(ward, []).append(dept_id)

department_lookup = {d[0]: d[1] for d in department}
room_id = 1

for ward, dept_list in ward_departments.items():

    ward_letter = ward_letters[ward]

    for floor, dept_id in enumerate(dept_list, start=1):

        dept_name = department_lookup[dept_id]
        for room_num in range(1, 6):

            room_number = f"{ward_letter}{floor}{room_num:02}"

            status = random.choices(
                ["Available", "Occupied"],
                weights=[0.3, 0.7]
            )[0]

            if "Care Unit" in dept_name:
                room_type = "Care Unit"
            elif "Emergency" in dept_name:
                room_type = "Emergency"
            elif "Operating Room" in dept_name or "Surgery" in dept_name:
                room_type = "Post-Op"
            else :
                room_type = random.choice(["General", "Private"])

            room.append([
                room_number,
                room_type,
                status,
                dept_id
            ])

            room_id += 1

room_num = [r[0] for r in room]

# Room Assignment

baby_keywords = ["Maternity Ward", "Neonatal Intensive Care Unit (NICU)", "Labor and Delivery"]
patient_dob_lookup = {p[0]:p[3] for p in patient}

assigned_pairs = set()
assignment_id = 1

occupied_rooms = [r for r in room if r[2] == "Occupied"]

for r in occupied_rooms:

    r_id = r[0]
    dept_id = r[3]
    dept_name = department_lookup.get(dept_id)

    while True:
        patient_choice = random.choice(patient_id)
        dob = datetime.strptime(patient_dob_lookup[patient_choice], "%Y-%m-%d").date()

        assign_date = fake.date_between(
            start_date=max(dob, date.today().replace(year=date.today().year - 3)),
            end_date="today"
        )
        
        age_days = (assign_date - dob).days
        age_years = calculate_age_appt(patient_dob_lookup[patient_choice], assign_date)
        
        if age_days <= 14:
            if not any(k.lower() in dept_name.lower() for k in baby_keywords):
                continue
        elif age_years < 18:
            if "Pediatrics" not in dept_name:
                continue
        
        pair = (patient_choice, r_id)

        if pair not in assigned_pairs:
            assigned_pairs.add(pair)
            break
    
    room_assignment.append([
        assignment_id,
        assign_date.isoformat(),
        patient_choice,
        r_id
    ])

    assignment_id += 1

# Room History

room_usage = {}
patient_usage = {}

from datetime import timedelta

for i in range(1, NUM_ROOM_HISTORY + 1):

    room_choice = random.choice(room)
    room_id = room_choice[0]
    dept_id = room_choice[3]
    dept_name = department_lookup.get(dept_id)
    patient_choice = random.choice(patient_id)

    today = date.today()
    three_years_ago = today.replace(year=today.year - 3)
    end_limit = today - timedelta(days=30)

    dob = datetime.strptime(patient_dob_lookup[patient_choice], "%Y-%m-%d").date()

    start_limit = max(dob, three_years_ago)

    # if start > end, skip this record
    if start_limit >= end_limit:
        continue

    start_date = fake.date_between(
        start_date=start_limit,
        end_date=end_limit
    )

    end_date = start_date + timedelta(days=random.randint(2,14))

    if end_date <= dob:
        continue

    age_days = (assign_date - dob).days
    age_years = calculate_age_appt(patient_dob_lookup[patient_choice], start_date)
        
    if age_days <= 14:
        if not any(k.lower() in dept_name.lower() for k in baby_keywords):
            continue
    elif age_years < 18:
        if "Pediatrics" not in dept_name:
            continue

    # store usage
    room_usage.setdefault(room_id, []).append((start_date, end_date))
    patient_usage.setdefault(patient_choice, []).append((start_date, end_date))

    room_history.append([
        i,
        room_id,
        patient_choice,
        end_date.isoformat()
    ])

# Appt

# status_list = ["Scheduled", "Completed", "Cancelled"]

patient_schedule = {}
today = date.today()

appointment_id = 1

while appointment_id <= NUM_APPOINTMENT:

    patient_choice = random.choice(patient)

    patient_id_val = patient_choice[0]
    patient_dob = patient_choice[3]

    appt_date = generate_appointment_date(patient_dob)
    patient_age = calculate_age_appt(patient_dob, appt_date)

    doctor_choice = random.choice(doctor)

    doctor_id_val = doctor_choice[0]
    dept_id = doctor_choice[8]

    dept_name = next(d[1] for d in department if d[0] == dept_id)

    age_days = (appt_date - datetime.strptime(patient_dob, "%Y-%m-%d").date()).days

    if age_days <= 14:
        if not any(k.lower() in dept_name.lower() for k in baby_keywords):
            continue
    elif patient_age < 18:
        if "Pediatrics" not in dept_name:
            continue
    else:
        if "Pediatrics" in dept_name:
            continue
    
    appt_time = generate_appointment_time()

    ## patient scheduling 

    patient_day = patient_schedule.setdefault(patient_id_val, {}).setdefault(appt_date, [])
    conflict = False
    
    for t in patient_day:
        if abs(t - appt_time) < 120:
            conflict = True
            break

    if conflict:
        continue

    patient_day.append(appt_time)

    ## appt status rules

    if appt_date < today:
        status = random.choices(["Completed", "Cancelled"], weights=[0.7, 0.3])[0]
    else:
        status = random.choices(["Scheduled", "Cancelled"], weights=[0.7, 0.3])[0]

    appointment.append([
        appointment_id,
        appt_date.isoformat(),
        format_time(appt_time),
        status,
        patient_id_val,
        doctor_id_val,
        dept_id
    ])

    appointment_id += 1

# Medical Records and Prescriptions
record_medications = {}
latest_patient_department = {}

treatment_keywords = {
    "Surgery": [
        "fracture","appendicitis","tumor","rupture","injury",
        "hernia","transplant","lesion", "chronic"
    ],
    "Therapy": [
        "rehabilitation","arthritis","stroke","injury recovery",
        "physical therapy","mobility","chronic pain"
    ],
    "Medication": [
        "infection","diabetes","hypertension","asthma",
        "flu","covid","allergy"
    ]
}

for i in range(1, NUM_MEDICAL_RECORDS + 1):

    scenario = fake.patient_scenario()

    patient_choice = random.choice(patient)
    patient_id_val = patient_choice[0]
    patient_dob = patient_choice[3] 

    visit_date = generate_visit_date(patient_dob)

    age = calculate_age(patient_dob)

    specialty = scenario["medical_specialty"]
    diagnosis = scenario["disease"]

    treatment_plan = classify_treatment(diagnosis)
    # find doctor with matching specialty
    possible_doctors = [
        d for d in doctor if d[3] == specialty
    ]

    valid_doctor = []

    dob_date = datetime.strptime(patient_dob,"%Y-%m-%d").date()

    age_days = (visit_date - dob_date).days
    age_years = calculate_age_appt(patient_dob, visit_date)

    for d in possible_doctors:
        dept_id = d[8]
        dept_name = department_lookup.get(dept_id)

        if age_days <= 14:
            if any(k.lower() in dept_name.lower() for k in baby_keywords):
                valid_doctor.append(d)
        elif age_years < 18:
            if "Pediatrics" in dept_name:
                valid_doctor.append(d)
        else:
            if "Pediatrics" not in dept_name:
                valid_doctor.append(d)
    
    if valid_doctor:
        doctor_choice = random.choice(valid_doctor)
    elif possible_doctors:
        doctor_choice = random.choice(possible_doctors)
    else:
        doctor_choice = random.choice(doctor)

    doctor_id_val = doctor_choice[0]
    doctor_dept = doctor_choice[8]

    latest_patient_department[patient_id_val] = doctor_dept

    medical_records.append([
        i,
        visit_date.isoformat(),
        diagnosis,
        treatment_plan,
        patient_id_val,
        doctor_id_val
    ])

    if treatment_plan == "Therapy":

        num_sessions = random.randint(3,8)

        for n in range(num_sessions):

            follow_up_date = visit_date + timedelta(days=random.randint(14,35))

            if follow_up_date > date.today():
                break
            
            appt_time = generate_appointment_time()
            appointment.append([
                len(appointment)+1,
                follow_up_date.isoformat(),
                format_time(appt_time),
                "Scheduled",
                patient_id_val,
                doctor_id_val,
                doctor_choice[8]
            ])

    # some fake scneraio can have multiple medications assigned to it
    record_medications[i] = scenario["medications"]

record_ids = [r[0] for r in medical_records]
medicine_names = [m[1] for m in medicine]

for rec_id, meds in record_medications.items():

    for med in meds:

        # fuzzy match medicine name
        best_match = process.extractOne(med, medicine_names)

        if not best_match:
            continue
        matched_name = best_match[0]

        med_match = next(
            (m for m in medicine if m[1] == matched_name), None
        )

        if not med_match:
            continue

        prescription.append([
            len(prescription) + 1,
            random.randint(10, 500),
            random.choice(["Once a day", "Twice a day"]),
            random.randint(3, 14),
            rec_id,
            med_match[0]
        ])

## test code

# print("Rooms")
# print(room[:5])
# print("\nAssigned")
# print(room_assignment[:5])
# print("\nHistory")
# print(room_history[:5])

# print("Medical Records")
# print(medical_records[:5])
# print("\nPrescription")
# print(prescription[:5])
# print("\nMedication")
# print(medicine[:5])

# print("Patient")
# print(patient[:5])
# print("\nDoctor")
# print(doctor[:5])
# print("\nDepartment")
# print(department[:5])
data = department
count_wing = Counter(item[2] for item in data)
print(count_wing)
# print("\nAppointment")
# print(appointment[:5])


## Write CSVs

def write_csv(file_name, data, headers):

    folder_name = "csv_output"
    os.makedirs(folder_name, exist_ok=True)
    with open(f"{folder_name}/{file_name}", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        writer.writerows(data)

write_csv(
    "patient.csv",
    patient,
    ["PatientID", "FirstName", "LastName", "DOB", "Sex", "Address", "PhoneNumber", "Email", "EmergencyName", "EmergencyPhoneNumber"]
)

write_csv(
    "medicine.csv",
    medicine,
    ["MedicineID", "MedicineName", "Manufacturer", "Stock", "Price"]
)

write_csv(
    "department.csv",
    department,
    ["DepartmentID", "DepartmentName", "Ward", "PhoneExtension"]
)

write_csv(
    "billing.csv",
    billing,
    ["BillingID","PatientID","Amount","Status","PaymentDate","PaymentMethod","InsuranceStatus"]
)

write_csv(
    "doctor.csv",
    doctor,
    ["DoctorID","FirstName","LastName","Specialty","PhoneNumber","Email","Address","Availability","DepartmentID"]
)

write_csv(
    "staff.csv",
    staff,
    ["StaffID","FirstName","LastName","Role","PhoneNumber","Email","Address", "ShiftHours","DepartmentID"]
)

write_csv(
    "room.csv",
    room,
    ["RoomID","RoomType","Status","DepartmentID"]
)

write_csv(
    "room_assignment.csv",
    room_assignment,
    ["RoomAssignmentID","AdmissionDate","PatientID","RoomID"]
)

write_csv(
    "room_history.csv",
    room_history,
    ["RoomHistoryID","RoomID","PatientID","DischargeDate"]
)

write_csv(
    "appointment.csv",
    appointment,
    ["AppointmentID","AppointmentDate","AppointmentTime","Status","PatientID","DoctorID","DepartmentID"]
)

write_csv(
    "medical_records.csv",
    medical_records,
    ["RecordID","VisitDate","Diagnosis","TreatmentPlan", "PatientID","DoctorID"]
)

write_csv(
    "prescription.csv",
    prescription,
    ["PrescriptionID","Dosage","Frequency","DurationDays","RecordID","MedicineID"]
)