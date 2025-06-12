CREATE PROGRAM bhs_ops_gwn_staff_assign:dba
 PROMPT
  "Begin Date" = "CURDATE"
  WITH s_beg_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_encntr_id = f8
     2 s_patient_name = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_cmrn = vc
     2 s_pat_fac_disp = vc
     2 s_pat_fac_cd = vc
     2 s_pat_unit = vc
     2 s_pat_room = vc
     2 s_pat_bed = vc
     2 s_staff_name = vc
     2 s_staff_username = vc
     2 s_staff_prsnl_id = vc
     2 s_assignment_type = vc
     2 s_assigned_reltn = vc
     2 s_staff_pos_from_sa = vc
     2 s_prsnl_user_pos = vc
     2 s_staff_assign_unit = vc
     2 s_beg_effective_dt_tm = vc
     2 s_end_effective_dt_tm = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_buf = "w"
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs4_cmrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_cs73_adtegate = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"ADTEGATE"))
 DECLARE ms_loc_dir = vc WITH protect, constant("$CCLUSERDIR")
 DECLARE ms_ftp_host = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_user = vc WITH protect, constant('"cisftp3"')
 DECLARE ms_ftp_pass = vc WITH protect, constant("pT60vm8")
 DECLARE ms_file_name = vc WITH protect, constant(concat("bhs_rpt_staff_assign_",trim(format(sysdate,
     "mmddyyhhmm;;d"),3),".csv"))
 DECLARE ms_info_domain = vc WITH protect, noconstant("BHS_OPS_GWN_STAFF_ASSIGN")
 DECLARE ms_info_name = vc WITH protect, constant("LAST_STOP_DT_TM")
 DECLARE mf_cs259571_nur = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",259571,"NURSING"))
 DECLARE mf_cs259571_pct = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",259571,
   "PATIENTCARETECHNICIAN"))
 DECLARE ms_rem_dir = vc WITH protect, noconstant("cisstaffassignprod")
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(trim(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"),3)
  )
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
 EXECUTE bhs_hlp_ftp
 EXECUTE bhs_check_domain
 IF (validate(request->batch_selection)=0)
  IF (textlen(trim( $S_BEG_DT,3))=0)
   SET ms_log = "Both dates must be filled out"
   GO TO exit_script
  ENDIF
  SET ms_beg_dt_tm = concat(trim( $S_BEG_DT,3)," 00:00:00")
 ELSE
  CALL echo("run from ops")
  SET mn_ops = 1
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain=ms_info_domain
    AND d.info_name=ms_info_name
   DETAIL
    CALL echo("DETAIL"), ms_beg_dt_tm = trim(format(d.info_date,"dd-mmm-yyyy hh:mm;;d")),
    CALL echo(build2("ms_beg_dt_tm: ",ms_beg_dt_tm))
   WITH nocounter
  ;end select
  IF (((curqual < 1) OR (textlen(trim(ms_beg_dt_tm,3))=0)) )
   CALL echo("insert")
   SET ms_beg_dt_tm = trim(format(cnvtlookbehind("12,H",sysdate),"dd-mmm-yyyy hh:mm;;d"),3)
   INSERT  FROM dm_info d
    SET d.info_domain = ms_info_domain, d.info_name = ms_info_name, d.info_date = sysdate,
     d.updt_dt_tm = sysdate, d.updt_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   COMMIT
  ENDIF
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm))
 SELECT INTO "nl:"
  FROM dcp_shift_assignment dsa,
   prsnl pr,
   person p,
   encntr_alias ea1,
   encntr_alias ea2,
   person_alias pa,
   encounter e,
   code_value_outbound cvo
  PLAN (dsa
   WHERE dsa.updt_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND dsa.assign_type_cd IN (mf_cs259571_nur, mf_cs259571_pct))
   JOIN (pr
   WHERE pr.person_id=dsa.prsnl_id)
   JOIN (p
   WHERE p.person_id=dsa.person_id)
   JOIN (e
   WHERE e.encntr_id=dsa.encntr_id)
   JOIN (cvo
   WHERE cvo.code_value=e.loc_nurse_unit_cd
    AND cvo.code_set=220
    AND cvo.contributor_source_cd=mf_cs73_adtegate)
   JOIN (ea1
   WHERE ea1.encntr_id=dsa.encntr_id
    AND ea1.active_ind=1
    AND ea1.encntr_alias_type_cd=mf_cs319_fin
    AND ea1.end_effective_dt_tm > sysdate)
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(dsa.encntr_id))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_cs319_mrn))
    AND (ea2.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.active_ind= Outerjoin(1))
    AND (pa.end_effective_dt_tm> Outerjoin(sysdate))
    AND (pa.person_alias_type_cd= Outerjoin(mf_cs4_cmrn)) )
  ORDER BY p.name_last, p.person_id, ea1.alias
  HEAD REPORT
   pl_cnt = 0
  HEAD p.name_last
   null
  HEAD p.person_id
   null
  DETAIL
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->pat,5))
    CALL alterlist(m_rec->pat,(pl_cnt+ 10))
   ENDIF
   m_rec->pat[pl_cnt].f_encntr_id = dsa.encntr_id, m_rec->pat[pl_cnt].s_patient_name = trim(p
    .name_full_formatted,3), m_rec->pat[pl_cnt].s_fin = trim(ea1.alias,3),
   m_rec->pat[pl_cnt].s_mrn = trim(ea2.alias,3), m_rec->pat[pl_cnt].s_cmrn = trim(pa.alias,3), m_rec
   ->pat[pl_cnt].s_pat_fac_disp = trim(uar_get_code_display(e.loc_facility_cd),3),
   m_rec->pat[pl_cnt].s_pat_fac_cd = trim(cnvtstring(e.loc_facility_cd),3), m_rec->pat[pl_cnt].
   s_pat_unit = trim(cvo.alias,3), m_rec->pat[pl_cnt].s_pat_room = trim(uar_get_code_display(e
     .loc_room_cd),3),
   m_rec->pat[pl_cnt].s_pat_bed = trim(uar_get_code_display(e.loc_bed_cd),3), m_rec->pat[pl_cnt].
   s_staff_name = trim(pr.name_full_formatted,3), m_rec->pat[pl_cnt].s_staff_username = trim(pr
    .username,3),
   m_rec->pat[pl_cnt].s_staff_prsnl_id = trim(cnvtstring(pr.person_id),3), m_rec->pat[pl_cnt].
   s_assignment_type = trim(uar_get_code_display(dsa.assign_type_cd),3), m_rec->pat[pl_cnt].
   s_assigned_reltn = trim(uar_get_code_display(dsa.assigned_reltn_type_cd),3),
   m_rec->pat[pl_cnt].s_staff_pos_from_sa = trim(uar_get_code_display(dsa.assignment_pos_cd),3),
   m_rec->pat[pl_cnt].s_prsnl_user_pos = trim(uar_get_code_display(pr.position_cd),3), m_rec->pat[
   pl_cnt].s_staff_assign_unit = trim(uar_get_code_display(dsa.loc_unit_cd),3),
   m_rec->pat[pl_cnt].s_beg_effective_dt_tm = trim(format(dsa.beg_effective_dt_tm,
     "mm/dd/yyyy hh:mm;;d"),3), m_rec->pat[pl_cnt].s_end_effective_dt_tm = trim(format(dsa
     .end_effective_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
  FOOT REPORT
   CALL alterlist(m_rec->pat,pl_cnt)
  WITH nocounter
 ;end select
 IF (size(m_rec->pat,5)=0)
  CALL echo("no recs found")
 ENDIF
 IF (size(m_rec->pat,5) > 0)
  CALL echo("CCLIO")
  SET frec->file_name = concat(ms_file_name)
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat(
   "patient|encntr_id|FIN|MRN|CMRN|pt_facility_disp|pt_facility_cd|pt_unit|",
   "pt_room|pt_bed|staff_name|staff_username|staff_prsnl_id|assignment_type|",
   "assigned_reltn|staff_position_from_shift_assignment|personnel_user_position|",
   "staff_assign_unit|beg_effective_dt_tm|end_effective_dt_tm",char(13),
   char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_loop = 1 TO size(m_rec->pat,5))
   SET frec->file_buf = concat(m_rec->pat[ml_loop].s_patient_name,"|",trim(cnvtstring(m_rec->pat[
      ml_loop].f_encntr_id),3),"|",m_rec->pat[ml_loop].s_fin,
    "|",m_rec->pat[ml_loop].s_mrn,"|",m_rec->pat[ml_loop].s_cmrn,"|",
    m_rec->pat[ml_loop].s_pat_fac_disp,"|",m_rec->pat[ml_loop].s_pat_fac_cd,"|",m_rec->pat[ml_loop].
    s_pat_unit,
    "|",m_rec->pat[ml_loop].s_pat_room,"|",m_rec->pat[ml_loop].s_pat_bed,"|",
    m_rec->pat[ml_loop].s_staff_name,"|",m_rec->pat[ml_loop].s_staff_username,"|",m_rec->pat[ml_loop]
    .s_staff_prsnl_id,
    "|",m_rec->pat[ml_loop].s_assignment_type,"|",m_rec->pat[ml_loop].s_assigned_reltn,"|",
    m_rec->pat[ml_loop].s_staff_pos_from_sa,"|",m_rec->pat[ml_loop].s_prsnl_user_pos,"|",m_rec->pat[
    ml_loop].s_staff_assign_unit,
    "|",m_rec->pat[ml_loop].s_beg_effective_dt_tm,"|",m_rec->pat[ml_loop].s_end_effective_dt_tm,char(
     13),
    char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  CALL echo("FTP the file")
  IF (gl_bhs_prod_flag=1)
   SET ms_dcl = concat(
    "$cust_script/bhs_sftp_file.ksh ciscoreftp3@transfer.baystatehealth.org:/cisstaffassignprod ",
    trim(cnvtlower(ms_file_name),3))
  ELSE
   CALL echo("set dcl for test")
   SET ms_dcl = concat(
    "$cust_script/bhs_sftp_file.ksh ciscoreftp3@transfer.baystatehealth.org:/cisstaffassigntest ",
    trim(cnvtlower(ms_file_name),3))
  ENDIF
  CALL echo(ms_dcl)
  CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
  CALL pause(5)
  SET ms_dcl = concat("rm -f ",build(substring(1,(size(ms_file_name) - 4),ms_file_name),"*"))
  CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
 ENDIF
 IF (mn_ops=1)
  UPDATE  FROM dm_info d
   SET d.info_date = cnvtlookahead("1,S",cnvtdatetime(ms_end_dt_tm)), d.updt_dt_tm = sysdate, d
    .updt_id = reqinfo->updt_id
   WHERE d.info_domain=ms_info_domain
    AND d.info_name=ms_info_name
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 SET reply->status_data[1].status = "S"
 CALL echo("status S")
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
