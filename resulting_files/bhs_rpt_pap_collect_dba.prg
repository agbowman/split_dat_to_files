CREATE PROGRAM bhs_rpt_pap_collect:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = curdate,
  "End Date" = curdate
  WITH outdev, mf_startdate, mf_enddate
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_auth_verified_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,
   "AUTHVERIFIED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cytology_order_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CYTOLOGYORDERFORM"))
 DECLARE mf_start_dt_tm = f8 WITH protect, noconstant(0)
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(0)
 IF (validate(request->batch_selection,"zzz") != "zzz")
  SET mf_end_dt_tm = datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E")
  SET mf_start_dt_tm = datetimefind(mf_end_dt_tm,"W","B","B")
 ELSE
  SET mf_end_dt_tm =  $MF_ENDDATE
  SET mf_start_dt_tm =  $MF_STARTDATE
 ENDIF
 SELECT INTO  $OUTDEV
  FROM clinical_event ce,
   dm_info di,
   encntr_alias ea,
   encntr_alias ea2,
   person p
  PLAN (di
   WHERE di.info_domain="BHS_RPT_PAP_COLLECT")
   JOIN (ce
   WHERE ce.performed_prsnl_id=di.info_number
    AND ce.event_cd=mf_cytology_order_form_cd
    AND ce.performed_dt_tm BETWEEN cnvtdatetime(cnvtdate(mf_start_dt_tm),0) AND cnvtdatetime(cnvtdate
    (mf_end_dt_tm),235959)
    AND ce.result_status_cd IN (mf_auth_verified_cd, mf_modified_cd)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(ce.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(mf_fin_cd)
    AND ea.active_ind=outerjoin(1))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(ce.encntr_id)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_mrn_cd)
    AND ea2.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.person_id=ce.person_id)
  ORDER BY ce.performed_dt_tm, di.info_name
  HEAD REPORT
   col 0,
   CALL print(concat("Weekly Pap Smear Tracking Report ",format(cnvtdate(mf_start_dt_tm),";;d"),
    " to ",format(cnvtdate(mf_end_dt_tm),";;d"))), row + 2,
   col 0,
   CALL print("Date"), col 10,
   CALL print("MA Name"), col 35,
   CALL print("FIN Number"),
   col 50,
   CALL print("MRN"), col 65,
   CALL print("Patient"), col 100,
   CALL print("Form"),
   row + 1
  DETAIL
   IF (row > 56)
    BREAK
   ENDIF
   col 0, ce.performed_dt_tm, col 10,
   CALL print(trim(substring(1,24,di.info_name),3)), col 35,
   CALL print(trim(ea.alias,3)),
   col 50,
   CALL print(trim(ea2.alias,3)), col 65,
   CALL print(trim(substring(1,34,p.name_full_formatted),3)), col 100,
   CALL print(trim(ce.event_tag,3)),
   row + 1
  WITH nocounter
 ;end select
#exit_prg
END GO
