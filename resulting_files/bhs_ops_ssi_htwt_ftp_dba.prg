CREATE PROGRAM bhs_ops_ssi_htwt_ftp:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg date:" = "CURDATE",
  "End date:" = "CURDATE",
  "Email:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_recipients
 FREE RECORD m_row_rec
 RECORD m_row_rec(
   1 l_row_cnt = i4
   1 rows[*]
     2 s_fin = vc
     2 s_ssi_facility_cd = vc
     2 s_height = vc
     2 s_weight = vc
 ) WITH protect
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 EXECUTE bhs_hlp_ftp
 EXECUTE bhs_ma_email_file
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE gf_inerror1_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE gf_inerror2_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE gf_inerror3_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE gf_inerror4_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE gf_inprogress_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE gf_unauth_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE gf_not_done_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE gf_anticipated_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"ANTICIPATED"))
 DECLARE gf_cancelled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"CANCELLED"))
 DECLARE gf_c_transcribe_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"C_TRANSCRIBE"))
 DECLARE gf_in_lab_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"IN LAB"))
 DECLARE gf_rejected_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"REJECTED"))
 DECLARE gf_superseded_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"SUPERSEDED"))
 DECLARE gf_unknown_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"UNKNOWN"))
 DECLARE gf_dictated_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"DICTATED"))
 DECLARE gf_transcribed_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"TRANSCRIBED"))
 DECLARE mf_dischip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_dischobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE mf_dischdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHDAYSTAY"))
 DECLARE mf_height_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 DECLARE mf_weight_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE mf_killogram_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",54,"KG"))
 DECLARE mf_centimeter_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",54,"CM"))
 DECLARE mf_bfmc_facility_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE FRANKLIN MEDICAL CENTER"))
 DECLARE mf_bmc_facility_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER"))
 DECLARE mf_bmlh_facility_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MARY LANE HOSPITAL"))
 DECLARE mf_bwh_facility_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE WING HOSPITAL"))
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),"/"))
 DECLARE ms_rem_dir = vc WITH protect, constant("SSIHeightWeight")
 DECLARE ms_ftp_host = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_username = vc WITH protect, constant('"bhs\udpxb03"')
 DECLARE ms_ftp_password = vc WITH protect, constant("golfs")
 DECLARE ms_file_name = vc WITH protect, constant(build("ssi-",trim(format(sysdate,"yyyymmdd-hhmm;;d"
     )),".txt"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients = vc WITH protect, noconstant(" ")
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom = vc WITH protect, noconstant(" ")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 IF (validate(request->batch_selection,"NOTOPS") != "NOTOPS")
  SET mn_ops = 1
  SET ms_beg_dt_tm = concat(trim(format((curdate - 1),"dd-mmm-yyyy ;;d"),3)," 00:00:00")
  SET ms_end_dt_tm = concat(trim(format((curdate - 1),"dd-mmm-yyyy ;;d"),3)," 23:59:59")
  SET reply->status_data[1].status = "F"
 ELSE
  SET ms_beg_dt_tm = concat(trim( $S_BEG_DT)," 00:00:00")
  SET ms_end_dt_tm = concat(trim( $S_END_DT)," 23:59:59")
  IF (datetimediff(cnvtdatetime(ms_end_dt_tm),cnvtdatetime(ms_beg_dt_tm)) > 31)
   CALL echo("Date range > 31")
   SET ms_temp = "Your date range is larger than 31 days. Please retry."
   GO TO exit_script
  ELSEIF (datetimediff(cnvtdatetime(ms_end_dt_tm),cnvtdatetime(ms_beg_dt_tm)) < 0)
   CALL echo("Date range < 0")
   SET ms_temp = "Your beginning date is after end date. Please, correct the date range and retry."
   GO TO exit_script
  ENDIF
  SET ms_recipients = trim( $S_RECIPIENTS)
  IF (((findstring("@",ms_recipients)=0
   AND textlen(ms_recipients) > 0) OR (textlen(ms_recipients) < 10)) )
   SET ms_temp = "Recipient email is invalid"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  e.encntr_id, ce.event_cd, ce.event_end_dt_tm
  FROM encntr_alias ea,
   encounter e,
   clinical_event ce,
   person p
  PLAN (e
   WHERE e.encntr_type_cd IN (mf_dischip_cd, mf_dischobv_cd, mf_dischdaystay_cd)
    AND e.loc_facility_cd IN (mf_bfmc_facility_cd, mf_bmc_facility_cd, mf_bmlh_facility_cd,
   mf_bwh_facility_cd)
    AND e.disch_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.person_id=e.person_id
    AND  NOT (ce.result_status_cd IN (gf_inerror1_cd, gf_inerror2_cd, gf_inerror3_cd, gf_inerror4_cd,
   gf_inprogress_cd,
   gf_unauth_cd, gf_not_done_cd, gf_anticipated_cd, gf_cancelled_cd, gf_c_transcribe_cd,
   gf_in_lab_cd, gf_inprogress_cd, gf_rejected_cd, gf_superseded_cd, gf_unknown_cd))
    AND ce.event_cd IN (mf_height_cd, mf_weight_cd)
    AND ce.result_units_cd IN (mf_killogram_cd, mf_centimeter_cd)
    AND ce.event_end_dt_tm BETWEEN e.arrive_dt_tm AND e.disch_dt_tm)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_fin_cd)) )
  ORDER BY e.encntr_id, ce.event_cd, ce.event_end_dt_tm
  HEAD REPORT
   stat = alterlist(m_row_rec->rows,100), m_row_rec->l_row_cnt = 0
  HEAD e.encntr_id
   m_row_rec->l_row_cnt += 1
   IF ((m_row_rec->l_row_cnt > size(m_row_rec->rows,5)))
    stat = alterlist(m_row_rec->rows,(m_row_rec->l_row_cnt+ 10))
   ENDIF
   m_row_rec->rows[m_row_rec->l_row_cnt].s_fin = format(trim(ea.alias,3),"##########;p0")
  HEAD ce.event_cd
   CASE (e.loc_facility_cd)
    OF mf_bmc_facility_cd:
     m_row_rec->rows[m_row_rec->l_row_cnt].s_ssi_facility_cd = "1"
    OF mf_bfmc_facility_cd:
     m_row_rec->rows[m_row_rec->l_row_cnt].s_ssi_facility_cd = "2"
    OF mf_bmlh_facility_cd:
     m_row_rec->rows[m_row_rec->l_row_cnt].s_ssi_facility_cd = "3"
    OF mf_bwh_facility_cd:
     m_row_rec->rows[m_row_rec->l_row_cnt].s_ssi_facility_cd = "4"
   ENDCASE
   CASE (ce.event_cd)
    OF mf_height_cd:
     m_row_rec->rows[m_row_rec->l_row_cnt].s_height = cnvtstring(round((cnvtreal(ce.result_val)/ 100),
       3),20,3)
    OF mf_weight_cd:
     m_row_rec->rows[m_row_rec->l_row_cnt].s_weight = cnvtstring(round(cnvtreal(ce.result_val),2),20,
      2)
   ENDCASE
  FOOT REPORT
   stat = alterlist(m_row_rec->rows,m_row_rec->l_row_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  IF (mn_ops=0)
   SET ms_temp = build("No discharged patients found for range: ",ms_beg_dt_tm," --- ",ms_end_dt_tm,
    " Email will not be sent.")
  ENDIF
  GO TO exit_script
 ELSE
  SELECT INTO value(concat("bhscust:",ms_file_name))
   FROM (dummyt d  WITH seq = value(size(m_row_rec->rows,5)))
   PLAN (d)
   DETAIL
    ms_temp = build("SSI|",trim(m_row_rec->rows[d.seq].s_ssi_facility_cd),"|",trim(m_row_rec->rows[d
      .seq].s_fin),"|",
     m_row_rec->rows[d.seq].s_height,"|",trim(m_row_rec->rows[d.seq].s_weight)), col 0, ms_temp,
    row + 1
   WITH nocounter, format = variable, formfeed = none,
    maxcol = 500
  ;end select
  IF (mn_ops=0)
   CALL emailfile(concat(ms_loc_dir,ms_file_name),ms_file_name,ms_recipients,ms_file_name,1)
   SET ms_temp = build(m_row_rec->l_row_cnt," discharged patients found for range: ",ms_beg_dt_tm,
    " --- ",ms_end_dt_tm,
    " Email is sent.")
  ELSE
   SET ms_dclcom = concat("mv ",ms_loc_dir,ms_file_name," ",ms_loc_dir,
    "midas/ssi/",ms_file_name)
   CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
  ENDIF
 ENDIF
#exit_script
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, ms_temp
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD m_row_rec
END GO
