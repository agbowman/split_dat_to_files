CREATE PROGRAM bhs_rpt_triage_enc_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 EXECUTE bhs_ma_email_file
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
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_triage_enc_type = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"TRIAGE"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE mf_egate_person_id = f8 WITH protect, noconstant(0.00)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_out = vc WITH protect, noconstant(" ")
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 IF (( $OUTDEV="OPS"))
  SET ms_beg_dt_tm = format(cnvtdatetime((curdate - 1),0),"DD-MMM-YYYY HH:mm:ss;;D")
  SET ms_end_dt_tm = format(cnvtdatetime(curdate,0),"DD-MMM-YYYY HH:mm:ss;;D")
  SET mn_email_ind = 1
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtlookbehind("1 D",
      cnvtdatetime(ms_end_dt_tm)),"YYYYMMDD;;D"),".csv"))
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="BHS_RPT_TRIAGE_ENC_AUDIT"
     AND di.info_char="EMAIL")
   HEAD REPORT
    ms_address_list = " "
   DETAIL
    IF (ms_address_list=" ")
     ms_address_list = trim(di.info_name)
    ELSE
     ms_address_list = concat(ms_address_list," ",trim(di.info_name))
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET ms_beg_dt_tm = concat( $S_BEG_DT," 00:00:00")
  SET ms_end_dt_tm = format(cnvtlookahead("1 D",cnvtdatetime(concat( $S_END_DT," 00:00:00"))),
   "DD-MMM-YYYY HH:mm:ss;;D")
  IF (findstring("@", $OUTDEV) > 0)
   SET mn_email_ind = 1
   SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtlookbehind("1 D",
       cnvtdatetime(ms_end_dt_tm)),"YYYYMMDD;;D"),".csv"))
   SET ms_address_list =  $OUTDEV
  ELSEIF (cnvtupper( $OUTDEV)="EMAIL")
   SET mn_email_ind = 1
   SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtlookbehind("1 D",
       cnvtdatetime(ms_end_dt_tm)),"YYYYMMDD;;D"),".csv"))
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain="BHS_RPT_TRIAGE_ENC_AUDIT"
      AND di.info_char="EMAIL")
    HEAD REPORT
     ms_address_list = " "
    DETAIL
     IF (ms_address_list=" ")
      ms_address_list = trim(di.info_name)
     ELSE
      ms_address_list = concat(ms_address_list," ",trim(di.info_name))
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SET mn_email_ind = 0
   SET ms_output_dest =  $OUTDEV
  ENDIF
 ENDIF
 SET ms_subject = concat("Triage Encounter Audit for ",format(cnvtlookbehind("1 D",cnvtdatetime(
     ms_end_dt_tm)),"mm/dd/yyyy;;D"))
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE pr.name_last_key="CONTRIBUTORSYSTEM"
    AND pr.name_first_key="ADTEAGATE"
    AND pr.active_ind=1)
  HEAD REPORT
   mf_egate_person_id = pr.person_id
  WITH nocounter
 ;end select
 SELECT
  IF (mn_email_ind=1)
   WITH format, format = stream, pcformat('"',",",1),
    nocounter
  ELSE
  ENDIF
  DISTINCT INTO value(ms_output_dest)
  position = trim(uar_get_code_display(pr.position_cd),3), user = trim(pr.name_full_formatted,3),
  facility = uar_get_code_display(e.loc_facility_cd),
  nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), fin = trim(ea.alias,3), mrn = trim(
   pa.alias,3),
  patient = trim(p.name_full_formatted,3), p.birth_dt_tm, encntr_type = trim(uar_get_code_display(e
    .encntr_type_cd),3),
  e.reg_dt_tm"@SHORTDATETIME"
  FROM encounter e,
   person p,
   prsnl pr,
   encntr_alias ea,
   person_alias pa,
   dummyt d1
  PLAN (e
   WHERE e.reg_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND e.reg_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND e.encntr_type_cd=mf_triage_enc_type
    AND e.reg_prsnl_id != mf_egate_person_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pr
   WHERE pr.person_id=e.reg_prsnl_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mf_mrn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (d1
   WHERE substring(1,1,trim(uar_get_code_display(e.loc_nurse_unit_cd),3)) != "\*")
  ORDER BY nurse_unit DESC, pr.name_full_formatted
  WITH format, separator = " ", nocounter
 ;end select
 IF (mn_email_ind=1)
  SET ms_filename_out = concat("Triage_Encounter_Audit_",format(cnvtlookbehind("1 D",cnvtdatetime(
      ms_end_dt_tm)),"YYYYMMDD;;D"),".csv")
  CALL emailfile(ms_output_dest,ms_filename_out,ms_address_list,ms_subject,0)
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->ops_event = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].targetobjectname = ""
END GO
