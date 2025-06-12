CREATE PROGRAM daily_disch_attemp_w_phys_pos
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD disch_data
 RECORD disch_data(
   1 qual[*]
     2 physician = vc
     2 physician_position = vc
     2 patient = vc
     2 mrn = vc
     2 fin = vc
     2 admit_date = vc
     2 discharge_date = vc
     2 discharge_status = vc
     2 facility = vc
     2 encounter_type = vc
     2 department = vc
     2 nursing_unit = vc
     2 provider_title = vc
     2 provider_status = vc
     2 sms_alias = i4
 )
 DECLARE attending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN"))
 DECLARE inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_output = vc WITH protect, noconstant("daily_discharge.csv")
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(reply->status_data.status,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_address_list =  $OUTDEV
  SET ms_output_dest = concat("daily_discharge_",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;D"),
   ".csv")
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SELECT INTO "nl:"
  physician = pr.name_full_formatted, physician_position = uar_get_code_display(pr.position_cd),
  patient = p.name_full_formatted,
  mrn = ea1.alias, fin = ea2.alias, admit_date = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm:ss;;q"),
  discharge_date = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm:ss;;q"), discharge_status =
  uar_get_code_display(e.disch_disposition_cd), facility = uar_get_code_display(e.loc_facility_cd),
  encounter_type = uar_get_code_display(e.encntr_type_cd), department =
  IF (bpd.dept > " ")
   IF (((bpd.dept="PED") OR (((bpd.dept="MPD") OR (bpd.dept="Pediatrics")) )) ) "Pediatrics"
   ELSEIF (bpd.dept="Psychiatry") "Psychiatry"
   ELSEIF (((bpd.dept="MED") OR (((bpd.dept="CAR") OR (((bpd.dept="EMS") OR (((bpd.dept="OBG") OR (((
   bpd.dept="SRG") OR (bpd.dept="Medicine")) )) )) )) )) ) "Medicine"
   ELSE "Medicine"
   ENDIF
  ELSEIF (uar_get_code_display(pr.position_cd) IN ("BHS Neonatal MD", "BHS General Pediatrics MD",
  "BHS Physician - Pediatrics")) "Pediatrics"
  ELSEIF (uar_get_code_display(pr.position_cd) IN ("BHS Psychiatry MD", "BHS Physician - Psychiatry")
  ) "Psychiatry"
  ELSEIF (pr.position_cd IN (0.0, null)) "Other"
  ELSE "Medicine"
  ENDIF
  , nursing_unit = uar_get_code_display(e.loc_nurse_unit_cd),
  provider_title = bpd.title, provider_status = bpd.status, sms_alias = bpd.sms_alias
  FROM encounter e,
   person p,
   encntr_prsnl_reltn epr,
   prsnl pr,
   encntr_alias ea1,
   encntr_alias ea2,
   code_value cv,
   code_value cv2,
   bhs_provider_dept bpd
  PLAN (e
   WHERE e.disch_dt_tm != null
    AND e.disch_dt_tm BETWEEN cnvtdatetime((curdate - 2),0) AND cnvtdatetime((curdate - 2),235959)
    AND e.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=e.encntr_type_cd
    AND cv.display_key IN ("INPATIENT", "DISCHIP", "EXPIREDIP", "PREADMITIP", "IPHOSPICE",
   "EXPIREDHOSPICE", "DCHOSPICE", "OBSERVATION", "DISCHOBV", "EXPIREDOBV",
   "DAYSTAY", "DISCHDAYSTAY", "EXPIREDDAYSTAY", "PREADMITDAYSTAY", "ER",
   "EMERGENCY", "DISCHES", "EXPIREDES", "DOWNTIMEED", "RECURRINGOP",
   "DISCHRECURRINGOP", "OUTPATIENTRECURRING", "SNSTANDARD", "SNDAYSTAY", "SN23HOURDAYSTAY",
   "SNINHOUSE", "SNSHORTSTAYPROCEDURE", "SNEARLYMORNINGADMIT", "SNSPECIALPROCEDURE",
   "SNCARDIACINPATIENT",
   "SNVASCULARINPATIENT", "SNPERIPHERALVASCULARINPT", "SNTAVRINPATIENT", "SNVASCULAR23HRDSP"))
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.encntr_alias_type_cd=mrn_cd
    AND ea1.active_ind=1)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=fin_cd
    AND ea2.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (epr
   WHERE (epr.encntr_id= Outerjoin(e.encntr_id))
    AND (epr.active_ind= Outerjoin(1))
    AND (epr.end_effective_dt_tm> Outerjoin(sysdate))
    AND (epr.encntr_prsnl_r_cd= Outerjoin(attending_cd)) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(epr.prsnl_person_id))
    AND (pr.active_ind= Outerjoin(1))
    AND (pr.position_cd> Outerjoin(0)) )
   JOIN (cv2
   WHERE (cv2.code_value= Outerjoin(pr.position_cd)) )
   JOIN (bpd
   WHERE (bpd.person_id= Outerjoin(pr.person_id))
    AND (bpd.active_ind= Outerjoin(1))
    AND (bpd.end_effective_dt_tm> Outerjoin(sysdate)) )
  ORDER BY facility, department, physician,
   patient
  HEAD REPORT
   ml_idx = 0
  DETAIL
   ml_idx += 1, stat = alterlist(disch_data->qual,ml_idx), disch_data->qual[ml_idx].physician =
   physician,
   disch_data->qual[ml_idx].physician_position = physician_position, disch_data->qual[ml_idx].patient
    = patient, disch_data->qual[ml_idx].mrn = mrn,
   disch_data->qual[ml_idx].fin = fin, disch_data->qual[ml_idx].admit_date = admit_date, disch_data->
   qual[ml_idx].discharge_date = discharge_date,
   disch_data->qual[ml_idx].discharge_status = discharge_status, disch_data->qual[ml_idx].facility =
   facility, disch_data->qual[ml_idx].encounter_type = encounter_type,
   disch_data->qual[ml_idx].department = department, disch_data->qual[ml_idx].nursing_unit =
   nursing_unit, disch_data->qual[ml_idx].provider_title = provider_title,
   disch_data->qual[ml_idx].provider_status = provider_status, disch_data->qual[ml_idx].sms_alias =
   sms_alias
  WITH nocounter
 ;end select
 SELECT
  IF (mn_email_ind=0)
   WITH format, separator = " "
  ELSE
   WITH pcformat('"',",",1), format = stream, format,
    skipreport = 1
  ENDIF
  INTO value(ms_output_dest)
  physician = substring(1,100,disch_data->qual[d1.seq].physician), physician_position = substring(1,
   100,disch_data->qual[d1.seq].physician_position), patient = substring(1,100,disch_data->qual[d1
   .seq].patient),
  mrn = substring(1,50,disch_data->qual[d1.seq].mrn), fin = substring(1,50,disch_data->qual[d1.seq].
   fin), admit_date = substring(1,50,disch_data->qual[d1.seq].admit_date),
  discharge_date = substring(1,50,disch_data->qual[d1.seq].discharge_date), discharge_status =
  substring(1,50,disch_data->qual[d1.seq].discharge_status), facility = substring(1,50,disch_data->
   qual[d1.seq].facility),
  encounter_type = substring(1,50,disch_data->qual[d1.seq].encounter_type), department = substring(1,
   50,disch_data->qual[d1.seq].department), nursing_unit = substring(1,50,disch_data->qual[d1.seq].
   nursing_unit)
  FROM (dummyt d1  WITH seq = size(disch_data->qual,5))
  PLAN (d1
   WHERE d1.seq > 0)
 ;end select
 IF (mn_email_ind=1)
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_output_dest,ms_output_dest,ms_address_list,"Daily Discharge Report",1)
 ENDIF
 IF (validate(reply->status_data.status))
  SET reply->status_data.status = "S"
  SET reply->ops_event = "Ops Job completed successfully"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
 ENDIF
#exit_script
END GO
