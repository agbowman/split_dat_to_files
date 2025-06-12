CREATE PROGRAM bhs_rpt_nursing_compass:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_fin = vc
     2 s_mrn = vc
     2 s_dob = vc
     2 f_encntr_type_cd = f8
     2 s_encntr_type_disp = vc
     2 s_cost_center = vc
     2 f_unit_cd = f8
     2 s_unit_disp = vc
     2 s_census_dt_tm = vc
     2 s_census_hr = vc
     2 s_checkin_dt_tm = vc
     2 s_checkout_dt_tm = vc
 ) WITH protect
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_ed_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_eshld_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ESHLD"))
 DECLARE mf_bmc_hof_trk_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16370,
   "BMCEDHOFTRACKINGGROUP"))
 DECLARE mf_bfmc_trk_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16370,
   "BFMCEDTRACKINGGROUP"))
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_output2 = vc WITH protect, noconstant(" ")
 DECLARE ml_hour = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp2 = vc WITH protect, noconstant(" ")
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_ftp_path = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_dcl_cmd = vc WITH protect, noconstant(" ")
 DECLARE ml_dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE mn_prod_ind = i2 WITH protect, noconstant(0)
 IF (((validate(request->batch_selection)) OR (mn_ops=1)) )
  SET mn_ops = 1
  SET ml_hour = hour(sysdate)
  IF (ml_hour=12)
   SET ms_tmp = concat(trim(cnvtstring(ml_hour)),"pm")
  ELSEIF (ml_hour > 12)
   SET ms_tmp = concat(trim(cnvtstring((ml_hour - 12))),"pm")
  ELSEIF (ml_hour < 12)
   SET ms_tmp = concat(trim(cnvtstring(ml_hour)),"am")
  ENDIF
  SET ms_tmp2 = concat(ms_tmp,"_",trim(format(sysdate,"yyyymmdd;;d")))
  SET ms_tmp = concat(ms_tmp,"_",trim(format(sysdate,"mmddyy;;d")))
  CALL echo(ms_tmp)
  CALL echo(ms_tmp2)
  SET ms_output = build(logical("bhscust"),"/ftp/bhs_rpt_nursing_compass/file1/edvisits_snp_",ms_tmp,
   ".csv")
  SET ms_output2 = build(logical("bhscust"),"/ftp/bhs_rpt_nursing_compass/file2/edvisits_snp_",
   ms_tmp2,".csv")
  CALL echo(ms_output)
  CALL echo(ms_output2)
 ENDIF
 SELECT INTO "nl:"
  FROM tracking_checkin tc,
   tracking_item ti,
   encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (tc
   WHERE tc.checkin_dt_tm < sysdate
    AND ((tc.checkout_dt_tm BETWEEN sysdate AND cnvtdatetime("31-DEC-2100 00:00:00")) OR (tc
   .checkout_dt_tm=null))
    AND tc.tracking_group_cd IN (mf_bmc_hof_trk_cd, mf_bfmc_trk_cd))
   JOIN (ti
   WHERE ti.tracking_id=tc.tracking_id
    AND ti.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ti.encntr_id
    AND e.encntr_type_cd=mf_ed_type_cd
    AND e.loc_nurse_unit_cd != mf_eshld_cd
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm> Outerjoin(sysdate))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_mrn_cd)) )
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1, stat = alterlist(m_rec->pat,pl_cnt), m_rec->pat[pl_cnt].s_census_dt_tm = trim(format(
     sysdate,"yyyy-mm-dd hh:mm:ss;;d")),
   m_rec->pat[pl_cnt].s_census_hr = substring(12,8,m_rec->pat[pl_cnt].s_census_dt_tm), m_rec->pat[
   pl_cnt].f_encntr_id = e.encntr_id, m_rec->pat[pl_cnt].f_person_id = e.person_id,
   m_rec->pat[pl_cnt].s_dob = trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),
     "dd-mmm-yyyy;;d")), m_rec->pat[pl_cnt].f_encntr_type_cd = e.encntr_type_cd, m_rec->pat[pl_cnt].
   s_encntr_type_disp = trim(uar_get_code_display(e.encntr_type_cd)),
   m_rec->pat[pl_cnt].f_unit_cd = e.loc_nurse_unit_cd, m_rec->pat[pl_cnt].s_unit_disp = trim(
    uar_get_code_display(e.loc_nurse_unit_cd)), m_rec->pat[pl_cnt].s_fin = trim(ea1.alias),
   m_rec->pat[pl_cnt].s_mrn = trim(ea2.alias), m_rec->pat[pl_cnt].s_checkin_dt_tm = trim(format(tc
     .checkin_dt_tm,"mm/dd/yy hh:mm;;d")), m_rec->pat[pl_cnt].s_checkout_dt_tm = trim(format(tc
     .checkout_dt_tm,"mm/dd/yy hh:mm;;d"))
  WITH nocounter
 ;end select
 IF (size(m_rec->pat,5) > 0)
  IF (mn_ops=0)
   SELECT INTO value(ms_output)
    census_date_time = m_rec->pat[d.seq].s_census_dt_tm, fin = m_rec->pat[d.seq].s_fin, mrn = m_rec->
    pat[d.seq].s_mrn,
    cost_center = "B740", unit_code = trim(cnvtstring(m_rec->pat[d.seq].f_unit_cd)), unit_disp =
    m_rec->pat[d.seq].s_unit_disp,
    encounter_type = m_rec->pat[d.seq].s_encntr_type_disp, census_hour = m_rec->pat[d.seq].
    s_census_hr, patient_dob = m_rec->pat[d.seq].s_dob,
    checkin = m_rec->pat[d.seq].s_checkin_dt_tm, checkout = m_rec->pat[d.seq].s_checkout_dt_tm
    FROM (dummyt d  WITH seq = value(size(m_rec->pat,5)))
    PLAN (d)
    WITH nocounter, format, separator = " ",
     maxrow = 1, maxcol = 1000
   ;end select
  ELSEIF (mn_ops=1)
   SELECT INTO value(ms_output)
    FROM (dummyt d  WITH seq = value(size(m_rec->pat,5)))
    PLAN (d)
    HEAD REPORT
     ms_tmp = concat(
      '"census_date_time","FIN","MRN","cost_center","unit_code","unit_disp","encounter_type",',
      '"census_hour","patient_dob"'), col 0, ms_tmp
    DETAIL
     row + 1, ms_tmp = trim(concat('"',trim(m_rec->pat[d.seq].s_census_dt_tm),'",','"',trim(m_rec->
        pat[d.seq].s_fin),
       '",','"',trim(m_rec->pat[d.seq].s_mrn),'",','"B740",',
       '"',trim(cnvtstring(m_rec->pat[d.seq].f_unit_cd)),'",','"',trim(m_rec->pat[d.seq].s_unit_disp),
       '",','"',trim(m_rec->pat[d.seq].s_encntr_type_disp),'",','"',
       trim(m_rec->pat[d.seq].s_census_hr),'",','"',trim(m_rec->pat[d.seq].s_dob),'"'),3), col 0,
     ms_tmp
    WITH nocounter, format = variable, maxrow = 1
   ;end select
   IF (gl_bhs_prod_flag=1)
    SET mn_prod_ind = 1
    SET ms_ftp_path = "CISCORE/NursingCompassEDSnap/PROD"
   ELSE
    SET ms_ftp_path = "CISCORE/NursingCompassEDSnap/NONPROD"
   ENDIF
   SET ms_ftp_cmd = concat("put ",ms_output)
   IF (mn_prod_ind=1)
    CALL echo("copy file")
    SET ms_dcl_cmd = concat("cp ",ms_output," ",ms_output2)
    CALL echo(ms_dcl_cmd)
    CALL dcl(ms_dcl_cmd,size(ms_dcl_cmd),ml_dcl_stat)
    CALL echo(build2("status: ",ml_dcl_stat))
   ENDIF
  ENDIF
 ELSE
  CALL echo("no records found")
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
