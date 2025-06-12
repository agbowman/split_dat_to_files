CREATE PROGRAM bhs_rpt_cardiac_monitor_job:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "Stop Date:" = "CURDATE",
  "Run Type: " = ""
  WITH outdev, ms_rpt_start, ms_rpt_stop,
  ms_run_ind
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cardiacmonitor_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CARDIACMONITOR"))
 DECLARE mf_cardiacmonitoredonly_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CARDIACMONITOREDONLY"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
  )
 DECLARE mf_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_dischip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_preadmitip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITIP"))
 DECLARE mf_expiredip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP"))
 DECLARE mf_dischobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE mf_preadmitdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PREADMITDAYSTAY"))
 DECLARE mf_dischdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHDAYSTAY"))
 DECLARE mf_expiredes_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES"))
 DECLARE mf_disches_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES"))
 DECLARE mf_expiredobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV"))
 DECLARE mf_expireddaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "EXPIREDDAYSTAY"))
 DECLARE mf_admitdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE mf_hvcc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_sicu_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_micu_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nicu_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nccn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_picu_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_ldrpa_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_ldrpb_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_ldrpc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nnura_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nnurb_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nnurc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nnurd_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nsy_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nurs_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_icu_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_iccu_cd = f8 WITH protect, noconstant(0.0)
 FREE RECORD prsnl
 RECORD prsnl(
   1 ml_cnt = i4
   1 qual[*]
     2 ms_name = vc
     2 mf_prsnl_id = f8
     2 ml_card_cnt = f8
     2 ml_admt_cnt = f8
 ) WITH protect
 FREE RECORD output_prsnl
 RECORD output_prsnl(
   1 ml_cnt = i4
   1 qual[*]
     2 ms_name = vc
     2 mf_prsnl_id = f8
     2 ml_card_cnt = f8
     2 ml_admt_cnt = f8
 ) WITH protect
 DECLARE ml_ph_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_ph_idx = i4 WITH protect, noconstant(0)
 DECLARE ms_file_name = vc WITH protect, noconstant("")
 DECLARE ms_tmp = vc WITH protect, noconstant("")
 DECLARE ms_recipients = vc WITH protect, noconstant("")
 DECLARE ml_email_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning="NURSEUNIT"
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.display_key IN ("HVCC", "SICU", "MICU", "NICU", "NCCN",
  "PICU", "LDRPA", "LDRPB", "LDRPC", "NNURA",
  "NNURB", "NNURC", "NNURD", "NSY", "NURS",
  "ICU", "ICCU")
  DETAIL
   CASE (cv.display_key)
    OF "HVCC":
     mf_hvcc_cd = cv.code_value
    OF "SICU":
     mf_sicu_cd = cv.code_value
    OF "MICU":
     mf_micu_cd = cv.code_value
    OF "NICU":
     mf_nicu_cd = cv.code_value
    OF "NCCN":
     mf_nccn_cd = cv.code_value
    OF "PICU":
     mf_picu_cd = cv.code_value
    OF "LDRPA":
     mf_ldrpa_cd = cv.code_value
    OF "LDRPB":
     mf_ldrpb_cd = cv.code_value
    OF "LDRPC":
     mf_ldrpc_cd = cv.code_value
    OF "NNURA":
     mf_nnura_cd = cv.code_value
    OF "NNURB":
     mf_nnurb_cd = cv.code_value
    OF "NNURC":
     mf_nnurc_cd = cv.code_value
    OF "NNURD":
     mf_nnurd_cd = cv.code_value
    OF "NSY":
     mf_nsy_cd = cv.code_value
    OF "NURS":
     mf_nurs_cd = cv.code_value
    OF "ICU":
     mf_icu_cd = cv.code_value
    OF "ICCU":
     mf_iccu_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 IF (trim( $MS_RUN_IND,3) != "1")
  SET mf_start_dt = cnvtdatetime(build( $MS_RPT_START," 00:00:00"))
  SET mf_stop_dt = cnvtdatetime(build( $MS_RPT_STOP," 23:59:59"))
 ELSE
  SET mf_stop_dt = datetimefind(cnvtdatetime(curdate,0),"M","B","B")
  SET mf_start_dt = cnvtlookbehind("1 M",cnvtdatetime(mf_stop_dt))
 ENDIF
 DECLARE ml_cnt = i4
 SELECT INTO "nl:"
  FROM orders o,
   encounter e,
   encntr_prsnl_reltn epr,
   person p
  WHERE o.catalog_cd IN (mf_cardiacmonitor_cd, mf_cardiacmonitoredonly_cd)
   AND o.orig_order_dt_tm >= cnvtdatetime(mf_start_dt)
   AND o.orig_order_dt_tm < cnvtdatetime(mf_stop_dt)
   AND e.encntr_id=o.encntr_id
   AND e.encntr_type_cd IN (mf_inpatient_cd, mf_daystay_cd, mf_observation_cd, mf_emergency_cd,
  mf_dischip_cd,
  mf_preadmitip_cd, mf_expiredip_cd, mf_dischobv_cd, mf_preadmitdaystay_cd, mf_dischdaystay_cd,
  mf_expiredes_cd, mf_disches_cd, mf_expiredobv_cd, mf_expireddaystay_cd)
   AND  NOT (e.loc_nurse_unit_cd IN (mf_hvcc_cd, mf_sicu_cd, mf_micu_cd, mf_nicu_cd, mf_nccn_cd,
  mf_picu_cd, mf_ldrpa_cd, mf_ldrpb_cd, mf_ldrpc_cd, mf_nnura_cd,
  mf_nnurb_cd, mf_nnurc_cd, mf_nnurd_cd, mf_nsy_cd, mf_nurs_cd,
  mf_icu_cd, mf_iccu_cd))
   AND epr.encntr_id=e.encntr_id
   AND epr.encntr_prsnl_r_cd=mf_admitdoc_cd
   AND p.person_id=epr.prsnl_person_id
   AND p.name_last_key != "NOTONSTAFF"
   AND p.person_id != 0
  ORDER BY epr.prsnl_person_id, epr.encntr_id
  HEAD epr.prsnl_person_id
   prsnl->ml_cnt = (prsnl->ml_cnt+ 1), stat = alterlist(prsnl->qual,prsnl->ml_cnt), prsnl->qual[prsnl
   ->ml_cnt].mf_prsnl_id = epr.prsnl_person_id,
   prsnl->qual[prsnl->ml_cnt].ms_name = p.name_full_formatted
  HEAD epr.encntr_id
   prsnl->qual[prsnl->ml_cnt].ml_card_cnt = (prsnl->qual[prsnl->ml_cnt].ml_card_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_prsnl_reltn epr,
   person p
  WHERE e.reg_dt_tm >= cnvtdatetime(mf_start_dt)
   AND e.reg_dt_tm < cnvtdatetime(mf_stop_dt)
   AND e.encntr_type_cd IN (mf_inpatient_cd, mf_daystay_cd, mf_observation_cd, mf_emergency_cd,
  mf_dischip_cd,
  mf_preadmitip_cd, mf_expiredip_cd, mf_dischobv_cd, mf_preadmitdaystay_cd, mf_dischdaystay_cd,
  mf_expiredes_cd, mf_disches_cd, mf_expiredobv_cd, mf_expireddaystay_cd)
   AND  NOT (e.loc_nurse_unit_cd IN (mf_hvcc_cd, mf_sicu_cd, mf_micu_cd, mf_nicu_cd, mf_nccn_cd,
  mf_picu_cd, mf_ldrpa_cd, mf_ldrpb_cd, mf_ldrpc_cd, mf_nnura_cd,
  mf_nnurb_cd, mf_nnurc_cd, mf_nnurd_cd, mf_nsy_cd, mf_nurs_cd,
  mf_icu_cd, mf_iccu_cd))
   AND epr.encntr_id=e.encntr_id
   AND epr.encntr_prsnl_r_cd=mf_admitdoc_cd
   AND p.person_id=epr.prsnl_person_id
   AND p.name_last_key != "NOTONSTAFF"
   AND p.person_id != 0
  ORDER BY epr.prsnl_person_id, epr.encntr_id
  HEAD epr.prsnl_person_id
   ml_ph_loc = 0, ml_ph_idx = 0, ml_ph_loc = locateval(ml_ph_idx,1,prsnl->ml_cnt,epr.prsnl_person_id,
    prsnl->qual[ml_ph_idx].mf_prsnl_id)
   IF (ml_ph_loc=0)
    prsnl->ml_cnt = (prsnl->ml_cnt+ 1), ml_ph_loc = prsnl->ml_cnt, stat = alterlist(prsnl->qual,prsnl
     ->ml_cnt),
    prsnl->qual[prsnl->ml_cnt].mf_prsnl_id = p.person_id, prsnl->qual[prsnl->ml_cnt].ms_name = p
    .name_full_formatted
   ENDIF
  HEAD epr.encntr_id
   IF (ml_ph_loc > 0)
    prsnl->qual[ml_ph_loc].ml_admt_cnt = (prsnl->qual[ml_ph_loc].ml_admt_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (trim( $MS_RUN_IND,3) != "1")
  SELECT INTO  $OUTDEV
   physician_name = concat("'",trim(substring(1,100,prsnl->qual[d.seq].ms_name)),"'"),
   cardiac_monitor_encounters = prsnl->qual[d.seq].ml_card_cnt, admit_encounters = prsnl->qual[d.seq]
   .ml_admt_cnt,
   percent = ((prsnl->qual[d.seq].ml_card_cnt/ prsnl->qual[d.seq].ml_admt_cnt) * 100.00)
   FROM (dummyt d  WITH seq = prsnl->ml_cnt)
   PLAN (d
    WHERE d.seq > 0)
   ORDER BY physician_name
   WITH nocounter, maxcol = 20000, format,
    separator = " ", memsort
  ;end select
 ELSE
  SET ms_file_name = concat("cardiacmonitor_",format(cnvtdatetime(mf_start_dt),"YYYYMMDDHHMMSS;;q"),
   "_",format(cnvtdatetime(mf_stop_dt),"YYYYMMDDHHMMSS;;q"),".csv")
  SELECT INTO "nl:"
   physician_name = trim(substring(1,100,prsnl->qual[d.seq].ms_name))
   FROM (dummyt d  WITH seq = prsnl->ml_cnt)
   PLAN (d
    WHERE d.seq > 0)
   ORDER BY physician_name
   HEAD REPORT
    output_prsnl->ml_cnt = 0
   DETAIL
    output_prsnl->ml_cnt = (output_prsnl->ml_cnt+ 1), stat = alterlist(output_prsnl->qual,
     output_prsnl->ml_cnt), output_prsnl->qual[output_prsnl->ml_cnt].ms_name = prsnl->qual[d.seq].
    ms_name,
    output_prsnl->qual[output_prsnl->ml_cnt].mf_prsnl_id = prsnl->qual[d.seq].mf_prsnl_id,
    output_prsnl->qual[output_prsnl->ml_cnt].ml_admt_cnt = prsnl->qual[d.seq].ml_admt_cnt,
    output_prsnl->qual[output_prsnl->ml_cnt].ml_card_cnt = prsnl->qual[d.seq].ml_card_cnt
   WITH nocounter
  ;end select
  SELECT INTO value(ms_file_name)
   FROM dummyt
   HEAD REPORT
    col 0, "Physician Name,", "Cardiac Monitor Count,",
    "Admit Encounters Count,", "Percent"
   DETAIL
    FOR (ml_ph_idx = 1 TO output_prsnl->ml_cnt)
      ms_temp = concat('"',output_prsnl->qual[ml_ph_idx].ms_name,'","',trim(cnvtstring(output_prsnl->
         qual[ml_ph_idx].ml_card_cnt,20)),'","',
       trim(cnvtstring(output_prsnl->qual[ml_ph_idx].ml_admt_cnt,20)),'","',trim(cnvtstring(((
         output_prsnl->qual[ml_ph_idx].ml_card_cnt/ output_prsnl->qual[ml_ph_idx].ml_admt_cnt) * 100),
         20,2)),'"'), row + 1, col 0,
      ms_temp
    ENDFOR
   WITH nocounter, format = variable, formfeed = none,
    maxcol = 2000
  ;end select
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_CARDIAC_MONITOR"
   ORDER BY di.info_name
   HEAD REPORT
    ml_email_cnt = 0
   DETAIL
    ml_email_cnt = (ml_email_cnt+ 1)
    IF (ml_email_cnt=1)
     ms_recipients = di.info_name
    ELSE
     ms_recipients = concat(ms_recipients,",",di.info_name)
    ENDIF
   WITH nocounter
  ;end select
  IF (textlen(ms_recipients) > 0)
   EXECUTE bhs_ma_email_file
   SET ms_tmp = concat("Cardiac Monitor Report ",format(cnvtdatetime(mf_start_dt),"YYYYMMDDHHMMSS;;q"
     )," - ",format(cnvtdatetime(mf_stop_dt),"YYYYMMDDHHMMSS;;q"))
   CALL emailfile(value(ms_file_name),ms_file_name,ms_recipients,ms_tmp,1)
  ENDIF
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echo(reply)
END GO
