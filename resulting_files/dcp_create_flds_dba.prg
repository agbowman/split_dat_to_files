CREATE PROGRAM dcp_create_flds:dba
 EXECUTE orm_create_oe_flds "Freetext Orderable", 0001, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Consulting Physician", 0002, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Accession number", 0007, 14,
 20, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Reporting Priority", 0008, 6,
 25, 0, 1,
 1905, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Specimen Type", 0009, 12,
 25, 0, 1,
 2052, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Required Radiology Order Format Field", 0009, 12,
 25, 0, 1,
 2052, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Source Mnemonic", 0009, 6,
 25, 0, 1,
 2052, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Accession Id", 0010, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Isolation Code", 0012, 6,
 25, 0, 1,
 70, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Rendering Physician", 0014, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Indication", 0015, 6,
 25, 0, 1,
 1028, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Objective", 0016, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Packet Routing", 0017, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Performing Location", 0018, 9,
 25, 0, 1,
 220, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "ICD9 Code", 0020, 10,
 999, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Device", 0021, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Gas Percentage", 0022, 0,
 5, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "FIO2", 0023, 0,
 5, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Vent Mode", 0024, 6,
 25, 0, 1,
 2054, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Tidal Volume", 0025, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "PEEP", 0026, 1,
 5, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Pressure Support", 0027, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Minute Volume", 0028, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "IE Ratio", 0029, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Body Site", 0030, 6,
 25, 0, 1,
 1028, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Currently Administered Medication", 0031, 0,
 50, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Source Comment", 0032, 0,
 255, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Outbreak/Episode Number", 0033, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Frozen Section Requested", 0035, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Blood Products Requested", 0036, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "XRay Requested", 0038, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Bill Flag", 0041, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Collected By", 0042, 13,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Collection Priority", 0043, 12,
 25, 0, 1,
 2054, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Laboratory Location", 0045, 6,
 25, 0, 1,
 4008, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Order Location", 0046, 9,
 25, 0, 1,
 220, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Print Label", 0047, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Research Account", 0048, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Label Printer", 0049, 11,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Collection Method", 0050, 6,
 25, 0, 1,
 2058, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Requested Start Date/Time", 0051, 5,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Suspend Date and Time", 0051, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Resume Date and Time", 0051, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Discontinue Date and Time", 0051, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Side", 0053, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Payor/Ins Approval Nbr", 0054, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Pregnant", 0055, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "LNMP", 0056, 6,
 25, 0, 1,
 4003, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Quantity", 0057, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Under  ing Chemo/Radiation Therapy", 0058, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Mode", 0066, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Number of Refills", 0067, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Percent O2", 0068, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Acuity Level", 0070, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Unit Type", 0075, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Equipment ID", 0082, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Inventory Location", 0086, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Payment Method", 0091, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Number of Labels", 0093, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Patient Fasting?", 0096, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Patient Has IV?", 0097, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Patient on Oxygen?", 0098, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Weight", 0099, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Weight Unit", 0100, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Patient's Owm Meds", 0101, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Referring Physician", 0106, 0,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Specimen Available", 0109, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Scheduled Date/Time", 0110, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Scheduled Date/Time - Approximate", 0113, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Continuous IV", 0114, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Constant Indicator", 0114, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Label Comment", 0116, 0,
 50, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "IV Site", 0117, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Infuse Over", 0118, 2,
 8, 0, 0,
 0, 0, 0,
 0, 1
 EXECUTE orm_create_oe_flds "Freetext Provider", 0119, 0,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Future Order", 0120, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Schedule Indicator", 0121, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Hold Processing Indicator", 0122, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Scheduling Instructions", 0123, 12,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Authorization Number", 0124, 0,
 30, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Hold Until Collected", 0125, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Encounter Type", 0126, 6,
 25, 0, 0,
 71, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Priority", 0127, 6,
 25, 0, 0,
 1304, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Supplies", 0128, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Diagnosis", 0129, 10,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Anesthesia Personnel Id", 0130, 8,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Add On", 0131, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "CPT Modifier", 0132, 6,
 25, 0, 0,
 17769, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Discern Ordering Physician", 0133, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Suspected Pathogens", 0134, 6,
 25, 0, 1,
 1021, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Media Label Printer", 0135, 11,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Print Media Label Y/N", 0136, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Override Share Y/N", 0137, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Reason for Consult", 0201, 6,
 25, 0, 1,
 6100, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Start Meal", 0202, 6,
 25, 0, 1,
 6101, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dietary Modifiers", 0203, 6,
 25, 0, 1,
 6102, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Beverage Modifiers", 0204, 6,
 25, 0, 1,
 6103, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dietary Restrictions", 0205, 6,
 25, 0, 1,
 6104, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dietary Calories", 0206, 1,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dietary Fluid Permitted", 0207, 1,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Total Fluid Permitted", 0208, 1,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Fluid Restriction Interval", 0209, 6,
 25, 0, 1,
 6105, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dietary Sodium", 0210, 1,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dietary Fat", 0211, 1,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dietary Potassium", 0212, 1,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dietary Protein", 0213, 1,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "NPO Exception", 0214, 6,
 25, 0, 1,
 6106, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dietary Supplements", 0215, 6,
 25, 0, 1,
 6107, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dietary Snacks", 0216, 6,
 25, 0, 1,
 6108, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Pediatric Formula", 0217, 6,
 25, 0, 1,
 6109, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Nutritional Route", 0218, 6,
 25, 0, 1,
 4001, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dietary Fortifier/Additive", 0219, 6,
 25, 0, 1,
 6110, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Activity Assistance Level", 0220, 6,
 25, 0, 1,
 6111, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Ventilator Rate", 0221, 1,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Special Instructions", 1103, 0,
 255, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Cancel Reason", 1105, 6,
 25, 0, 1,
 1309, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Suspend Reason", 1107, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Nurse Collect", 1108, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Resume Reason", 1110, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Discontinue Reason", 1112, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Review Location", 1113, 9,
 25, 0, 1,
 220, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Review Provider", 1114, 8,
 25, 0, 1,
 333, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Cosign Provider", 1115, 8,
 25, 0, 1,
 333, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Titrate Instructions", 1118, 0,
 255, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Take Home Med", 1119, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Take Home Quantity", 1120, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Specimen Description", 1124, 0,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Specimen Precautions", 1125, 0,
 255, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Charge Start Date/Time", 1126, 5,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Charge Stop Date/Time", 1127, 5,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Transport Mode", 1500, 6,
 25, 0, 1,
 10300, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Reason For Exam", 1501, 0,
 255, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Reason For Exam - DCP", 1501, 12,
 999, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Last Refill Dt Tm", 1550, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Refills Remaining", 1551, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Quantity On Hand", 1552, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Additional Refills", 1557, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Total Refills", 1558, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Rx Expired Date", 1559, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Requested Refill Date", 1560, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Original Order Id", 1561, 2,
 12, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Component Cost", 2005, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dispense From Location", 2006, 6,
 25, 0, 1,
 220, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dispense Cate  ry", 2007, 6,
 25, 0, 1,
 4008, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Component Dispense Cate  ry", 2008, 6,
 25, 0, 1,
 4008, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Frequency", 2011, 12,
 25, 0, 1,
 4003, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Component Frequency", 2012, 12,
 25, 0, 1,
 4003, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Drug Form", 2014, 6,
 25, 0, 1,
 4002, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dispense Quantity", 2015, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Refill Quantity", 2016, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "DAW", 2017, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Samples Given", 2018, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Samply Quantity", 2019, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "No Renewals Allowed", 2020, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "SIG", 2021, 0,
 50, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "RX Quantity", 2022, 1,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "ABN Status", 2023, 6,
 25, 0, 0,
 17969, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Next Dispense Date/Time", 2024, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Scheduled / PRN", 2037, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Rate", 2043, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Rate Unit", 2044, 6,
 25, 0, 1,
 54, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Collection Route", 2045, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Start Bag", 2047, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Component Start Bag", 2048, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Route of Administration", 2050, 6,
 25, 0, 1,
 4001, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Stop Bag", 2053, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Stop Type", 2055, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Strength Dose", 2056, 1,
 7, 0, 3,
 0, 0, 0,
 1999999, 0
 EXECUTE orm_create_oe_flds "Strength Dose Unit", 2057, 6,
 25, 0, 1,
 54, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Volume Dose", 2058, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Volume Dose Unit", 2059, 6,
 25, 0, 1,
 54, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Total Volume", 2060, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Duration", 2061, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Duration Unit", 2062, 6,
 25, 0, 1,
 54, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Freetext Dose", 2063, 0,
 50, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Infuse Over Unit", 2064, 6,
 25, 0, 1,
 54, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Diluent Id", 2065, 1,
 50, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Diluent Volume", 2066, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "PAR Doses", 2067, 1,
 5, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Replace Every", 2068, 2,
 5, 0, 3,
 0, 0, 0,
 500, 0
 EXECUTE orm_create_oe_flds "Replace Every Unit", 2069, 6,
 8, 0, 1,
 54, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Pharmacy Order Type", 2070, 1,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Adhoc Frequency Instance", 2071, 1,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Price Schedule", 2072, 2,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Stop Date/Time", 2073, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "DC Display Days", 2074, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Total Dispense Doses", 2076, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Print Indicator", 2077, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Titrate Indicator", 2078, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "IV Seq", 2079, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Number of bags in IV seq", 2080, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Next IV Sequence", 2081, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Order Price", 2082, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Order Cost", 2083, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Pass Medication Indicator", 2084, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Floor Stock Indicator", 2089, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "FS Override", 2090, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dose Quantity", 2091, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dose Quantity Unit", 2092, 6,
 25, 0, 1,
 54, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Write Order Dispense Flag", 2093, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Frequency Schedule Id", 2094, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Display Only Frequency", 2095, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Next Dose Dt Tm", 2096, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Difference in Minutes", 2097, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "IV Set Shell Item Id", 2098, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Initial Dose Override", 2099, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Drug Formulation", 2100, 12,
 30, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "PRN Instructions", 2101, 0,
 255, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Dispense Quantity Unit", 2102, 6,
 25, 0, 1,
 54, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Sample Quantity Unit", 2103, 6,
 25, 0, 1,
 54, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Freetext Rate", 2104, 0,
 50, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Don't Print Rx Reason", 2105, 6,
 25, 0, 1,
 24169, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Physician Address", 2106, 0,
 255, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Print DEA Number", 2107, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Physician Address Id", 2108, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Diet Type", 3100, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Activity Type", 3200, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Anesthesia Type", 3300, 6,
 25, 0, 0,
 10130, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Primary Procedure", 3301, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Procedure duration", 3302, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Primary Surgeon", 3303, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "First Assistant", 3304, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Second Assistant", 3305, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Specialty", 3306, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Procedure Modifier1", 3307, 6,
 25, 0, 0,
 14045, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Procedure Modifier2", 3308, 6,
 25, 0, 0,
 14045, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Procedure Modifier3", 3309, 6,
 25, 0, 0,
 14045, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Concurrent", 3310, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surgeon - Other", 3311, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surgical Resident", 3312, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Anesthesiologist", 3313, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Anesthesiologist - Other", 3314, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Anesthesia Resident", 3315, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Nurse Anesthetist", 3316, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "RN First Assistant", 3317, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "RN Practitioner", 3318, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Setup Duration", 3319, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Cleanup Duration", 3320, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Procedure Sequence", 3321, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "CRNA", 3322, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Anesthesiologist Assistant", 3323, 8,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surgical Procedure Text", 3324, 0,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Arrival Duration", 3327, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Surg Recovery Duration", 3328, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Schedule on Requested Date", 3329, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Callback Phone Ind", 3350, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Callback Phone Number", 3351, 0,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Callback Extension", 3352, 0,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Callback Fax Ind", 3353, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Callback Fax Number", 3354, 0,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Callback Phone Id", 3355, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "ABN Reason", 3356, 6,
 25, 0, 1,
 2217, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Consulting Med Service", 3500, 6,
 25, 0, 1,
 34, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Specimen Received Date and Time", 6000, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Specimen Received By", 6001, 13,
 100, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Specimen Received Location", 6002, 9,
 25, 0, 1,
 220, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Container Type", 6003, 6,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Container Volume", 6004, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Container Id", 6005, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Collected Y/N", 6006, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_flds "Print Label By Order Location", 6007, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 COMMIT
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
END GO
