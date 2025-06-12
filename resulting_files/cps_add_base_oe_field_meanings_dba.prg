CREATE PROGRAM cps_add_base_oe_field_meanings:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET success = false
 SET readme_data->message = concat("CPS_ADD_BASE_OE_FIELD_MEANINGS  BEG : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 EXECUTE orm_create_oe_field_meaning 2108, "PHYSICIANADDRESSID", "Physician Address Id",
 0
 EXECUTE orm_create_oe_flds "Physician Address Id", 2108, 2,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_field_meaning 1560, "REQREFILLDATE", "Requested Refill Date",
 0
 EXECUTE orm_create_oe_flds "Requested Refill Date", 1560, 5,
 10, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_field_meaning 1557, "ADDITIONALREFILLS", "Additional Refills",
 0
 EXECUTE orm_create_oe_flds "Additional Refills", 1557, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_field_meaning 1558, "TOTALREFILLS", "Total Refills",
 0
 EXECUTE orm_create_oe_flds "Total Refills", 1558, 1,
 8, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_field_meaning 0140, "PRESCRIPTIONDISPENSEDIND",
 "Prescription Dispensed Indicator",
 0
 EXECUTE orm_create_oe_flds "Prescription Dispensed Indicator", 0140, 7,
 1, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_field_meaning 0138, "ORDEROUTPUTDEST", "Order Output Destination",
 0
 EXECUTE orm_create_oe_flds "Order Output Destination", 0138, 12,
 25, 0, 0,
 0, 0, 0,
 0, 0
 EXECUTE orm_create_oe_field_meaning 0139, "FREETEXTORDERFAXNUMBER", "Freetext Order Fax Number",
 0
 EXECUTE orm_create_oe_flds "Freetext Order Fax Number", 0139, 0,
 25, 0, 0,
 0, 0, 0,
 0, 0
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM oe_field_meaning ofm
  PLAN (ofm
   WHERE ofm.oe_field_meaning IN ("PHYSICIANADDRESSID", "REQREFILLDATE", "ADDITIONALREFILLS",
   "TOTALREFILLS", "PRESCRIPTIONDISPENSEDIND",
   "ORDEROUTPUTDEST", "FREETEXTORDERFAXNUMBER"))
  WITH nocounter
 ;end select
 IF (curqual != 7)
  SET readme_data->message = "ERROR :: Not all required OE_FIELD_MEANINGs are present"
  EXECUTE dm_readme_status
  SET readme_data->status = "F"
 ELSE
  SET readme_data->status = "S"
 ENDIF
 SET readme_data->message = concat("CPS_ADD_BASE_OE_FIELD_MEANINGS  END : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 COMMIT
END GO
