CREATE PROGRAM bhs_rpt_spir_monthly:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Output to screen:" = 0,
  "Send to email" = 0,
  "Enter email address:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  n_chk_screen, n_chk_email, s_email
 DECLARE ml_no_data = i4 WITH noconstant(0), protect
 SET out_of_range = 0
 IF (datetimediff(cnvtdatetime( $S_END_DT),cnvtdatetime( $S_BEG_DT)) > 35.0)
  SET out_of_range = 1
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is Greater than 35 days .", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime( $S_END_DT),cnvtdatetime( $S_BEG_DT)) < 0.0)
  SET out_of_range = 1
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is Negative days .", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_script
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_religion = vc
     2 s_marital_status = vc
     2 s_language = vc
     2 s_race = vc
     2 s_dob = vc
     2 s_gender = vc
     2 s_deceased = vc
     2 f_encounter = f8
   1 nurs[*]
     2 f_nurse_unit_cd = f8
     2 s_disp = vc
 ) WITH protect
 DECLARE ms_expired = f8 WITH constant(uar_get_code_by("DISPLAYKEY",268,"EXPIRED")), protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION"))
 DECLARE mf_expiredobv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV")), protect
 DECLARE mf_expiredip = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP")), protect
 DECLARE mf_expiredes = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES")), protect
 DECLARE mf_expireddaystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDDAYSTAY")),
 protect
 DECLARE mf_dischobv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV")), protect
 DECLARE mf_dischip = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP")), protect
 DECLARE mf_disches = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES")), protect
 DECLARE mf_dischdaystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHDAYSTAY")), protect
 DECLARE mf_ed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_day_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_spir_consult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTSPIRITUALSERVICES"))
 DECLARE ms_beg_dt_tm = vc WITH protect
 DECLARE ms_end_dt_tm = vc WITH protect
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "PENDINGCOMPLETE"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE ms_output = vc WITH protect, constant( $OUTDEV)
 DECLARE mn_screen_out = i2 WITH protect, constant( $N_CHK_SCREEN)
 DECLARE mn_email_out = i2 WITH protect, constant( $N_CHK_EMAIL)
 DECLARE ms_email_to = vc WITH protect, constant(trim( $S_EMAIL))
 DECLARE ms_email_file = vc WITH protect, constant(concat("bhs_demog_",trim(format(sysdate,
     "mmddyy_hhmm;;d")),".csv"))
 DECLARE ms_email_file_zip = vc WITH protect, constant(concat("bhs_demog_",trim(format(sysdate,
     "mmddyy_hhmm;;d")),".csv.gz"))
 DECLARE mf_belief_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELIGIOUSSPIRITUALBELIEFS"))
 DECLARE mf_practices_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELIGIOUSSPIRITUALPRACTICES"))
 DECLARE mf_support_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REQUESTSSPIRITUALSUPPORT"))
 DECLARE mf_prefs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELIGIOUSSPIRITUALPREFERENCE"))
 DECLARE mf_reason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "SPIRITUALSERVICESREASON"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_bmc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bmc_psych_cd = f8 WITH protect, noconstant(0.0)
 IF (validate(request->batch_selection))
  SET ms_beg_dt_tm = format(datetimefind(cnvtlookbehind("1M",cnvtdatetime(curdate,0)),"M","B","B"),
   ";;Q")
  SET ms_end_dt_tm = format(datetimefind(cnvtlookbehind("1M",cnvtdatetime(curdate,0)),"M","E","E"),
   ";;Q")
  CALL echo("operations")
  CALL echo(ms_beg_dt_tm)
  CALL echo(ms_end_dt_tm)
 ELSE
  SET ms_beg_dt_tm = concat(trim( $S_BEG_DT)," 00:00:00")
  SET ms_end_dt_tm = concat(trim( $S_END_DT)," 23:59:59")
  CALL echo("prompt")
  CALL echo(ms_beg_dt_tm)
  CALL echo(ms_end_dt_tm)
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.display_key IN ("BMC", "BMCINPTPSYCH")
    AND cv.active_ind=1
    AND cv.cdf_meaning="FACILITY"
    AND cv.begin_effective_dt_tm <= sysdate
    AND cv.end_effective_dt_tm > sysdate
    AND cv.data_status_cd=mf_auth_cd)
  HEAD cv.display_key
   IF (cv.display_key="BMC")
    mf_bmc_cd = cv.code_value
   ELSEIF (cv.display_key="BMCINPTPSYCH")
    mf_bmc_psych_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get nurse units")
 SELECT INTO "nl:"
  lg2.child_loc_cd, ps_disp = uar_get_code_display(lg2.child_loc_cd)
  FROM location_group lg1,
   location_group lg2,
   code_value cv
  PLAN (lg1
   WHERE lg1.parent_loc_cd IN (mf_bmc_cd, mf_bmc_psych_cd)
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=lg1.child_loc_cd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg2.child_loc_cd
    AND cv.cdf_meaning="NURSEUNIT"
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
  ORDER BY ps_disp
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1, stat = alterlist(m_rec->nurs,pl_cnt), m_rec->nurs[pl_cnt].f_nurse_unit_cd = cv
   .code_value,
   m_rec->nurs[pl_cnt].s_disp = trim(cv.display)
  WITH nocounter
 ;end select
 CALL echo("get patients")
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   encntr_domain ed,
   encntr_loc_hist elh,
   encounter e,
   person p
  PLAN (ed
   WHERE ed.loc_facility_cd IN (mf_bmc_cd, mf_bmc_psych_cd)
    AND expand(ml_cnt,1,size(m_rec->nurs,5),ed.loc_nurse_unit_cd,m_rec->nurs[ml_cnt].f_nurse_unit_cd)
    AND ((ed.active_ind+ 0)=1)
    AND ed.beg_effective_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND ed.end_effective_dt_tm > cnvtdatetime(ms_beg_dt_tm))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (mf_inpt_cd, mf_obs_cd, mf_ed_cd, mf_day_cd, mf_expiredobv,
   mf_expiredip, mf_expiredes, mf_expireddaystay, mf_dischobv, mf_dischip,
   mf_disches, mf_dischdaystay)
    AND e.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.active_ind=1
    AND elh.loc_nurse_unit_cd=ed.loc_nurse_unit_cd
    AND elh.beg_effective_dt_tm <= cnvtdatetime(ms_end_dt_tm))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_mrn_cd)) )
  ORDER BY p.person_id
  HEAD REPORT
   pl_per = 0
  HEAD p.person_id
   pl_per += 1
   IF (pl_per > size(m_rec->pat,5))
    stat = alterlist(m_rec->pat,(pl_per+ 10))
   ENDIF
   m_rec->pat[pl_per].f_person_id = p.person_id, m_rec->pat[pl_per].f_encounter = e.encntr_id, m_rec
   ->pat[pl_per].s_pat_name = trim(p.name_full_formatted),
   m_rec->pat[pl_per].s_religion = trim(uar_get_code_display(p.religion_cd)), m_rec->pat[pl_per].
   s_marital_status = trim(uar_get_code_display(p.marital_type_cd)), m_rec->pat[pl_per].s_language =
   trim(uar_get_code_display(p.language_cd)),
   m_rec->pat[pl_per].s_race = trim(uar_get_code_display(p.race_cd)), m_rec->pat[pl_per].s_mrn = trim
   (ea.alias), m_rec->pat[pl_per].s_dob = trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
       .birth_tz),1),"dd-mmm-yyyy hh:mm;;d")),
   m_rec->pat[pl_per].s_gender = substring(1,1,uar_get_code_display(p.sex_cd))
   IF (p.deceased_cd=ms_expired)
    m_rec->pat[pl_per].s_deceased = "Yes"
   ELSE
    m_rec->pat[pl_per].s_deceased = "No"
   ENDIF
  FOOT  p.person_id
   null
  FOOT REPORT
   stat = alterlist(m_rec->pat,pl_per)
 ;end select
 SET pl_per = 0 WITH nocounter
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 CALL echorecord(m_rec)
 IF (mn_email_out=1)
  CALL echo("email is checked")
  SELECT INTO value(ms_email_file)
   pf_person_id = m_rec->pat[d1.seq].f_person_id, ps_pat_name = m_rec->pat[d1.seq].s_pat_name
   FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5)))
   PLAN (d1)
   ORDER BY ps_pat_name
   HEAD REPORT
    pl_cnt = 0, pl_maxrow = 0, ms_tmp = concat(
     "Patient_Name,MRN,DOB,Gender,Marital_Status,Language_Spoken,Race,Religion,Deceased"),
    col 0, row 0, ms_tmp,
    pl_maxrow = size(m_rec->pat,5)
    IF (pl_maxrow > 0)
     FOR (pl_cnt = 1 TO pl_maxrow)
       ms_tmp = concat('"',m_rec->pat[pl_cnt].s_pat_name,'","',m_rec->pat[pl_cnt].s_mrn,'","',
        m_rec->pat[pl_cnt].s_dob,'","',m_rec->pat[pl_cnt].s_gender,'","',m_rec->pat[pl_cnt].
        s_marital_status,
        '","',m_rec->pat[pl_cnt].s_language,'","',m_rec->pat[pl_cnt].s_race,'","',
        m_rec->pat[pl_cnt].s_religion,'","',m_rec->pat[pl_cnt].s_deceased,'"'), col 0, row + 1,
       ms_tmp
     ENDFOR
    ENDIF
   WITH nocounter, maxrow = 1, maxcol = 10000,
    format, separator = " "
  ;end select
  IF (findfile(trim(ms_email_file))=1)
   SET dclcom = concat("gzip -c9 $CCLUSERDIR/",ms_email_file," | ","uuencode ",ms_email_file_zip,
    " | ","mail -s ","'","Spiritual Services Demographics - ",trim(format(sysdate,"mm-dd-yy hh:mm;;d"
      )),
    "' ",ms_email_to)
   CALL echo(dclcom)
   SET len = size(trim(dclcom))
   SET status = 0
   SET stat = dcl(dclcom,len,status)
   SET stat = remove(trim(ms_email_file))
   IF (stat=0)
    CALL echo("File could not be removed")
   ELSE
    CALL echo("File was removed")
   ENDIF
  ENDIF
  IF (mn_screen_out=0)
   SELECT INTO  $OUTDEV
    HEAD REPORT
     col 0, "Emailed file ", ms_email_file_zip,
     " to ", ms_email_to
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (curqual=0)
  SET ml_no_data = 1
  GO TO exit_script
 ENDIF
 IF (mn_screen_out=1)
  SELECT INTO value(ms_output)
   pf_person_id = m_rec->pat[d1.seq].f_person_id, ps_pat_name = m_rec->pat[d1.seq].s_pat_name
   FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5)))
   PLAN (d1)
   ORDER BY ps_pat_name
   HEAD REPORT
    pl_col = 0, pl_cnt = 0, pl_maxrow = 0,
    col pl_col, "Patient_Name", pl_col += 50,
    col pl_col, "MRN", pl_col += 50,
    col pl_col, "Date_of_Birth", pl_col += 50,
    col pl_col, "Gender", pl_col += 50,
    col pl_col, "Marital_Status", pl_col += 50,
    col pl_col, "Language_Spoken", pl_col += 50,
    col pl_col, "Race", pl_col += 50,
    col pl_col, "Religion", pl_col += 50,
    col pl_col, "Deceased", pl_col += 50,
    pl_maxrow = size(m_rec->pat,5)
    IF (pl_maxrow > 0)
     FOR (pl_cnt = 1 TO pl_maxrow)
       row + 1, pl_col = 0, col pl_col,
       m_rec->pat[pl_cnt].s_pat_name, pl_col += 50, col pl_col,
       m_rec->pat[pl_cnt].s_mrn, pl_col += 50, col pl_col,
       m_rec->pat[pl_cnt].s_dob, pl_col += 50, col pl_col,
       m_rec->pat[pl_cnt].s_gender, pl_col += 50, col pl_col,
       m_rec->pat[pl_cnt].s_marital_status, pl_col += 50, col pl_col,
       m_rec->pat[pl_cnt].s_language, pl_col += 50, col pl_col,
       m_rec->pat[pl_cnt].s_race, pl_col += 50, col pl_col,
       m_rec->pat[pl_cnt].s_religion, pl_col += 50, col pl_col,
       m_rec->pat[pl_cnt].s_deceased, pl_col += 50
     ENDFOR
    ENDIF
   WITH nocounter, maxrow = 1, maxcol = 10000,
    format, separator = " "
  ;end select
  SELECT INTO "nl:"
   DETAIL
    row + 0
   WITH skipreport = value(1)
  ;end select
 ENDIF
#exit_script
 IF (ml_no_data=1)
  SELECT INTO  $OUTDEV
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", y_pos = 18,
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))),
    "No data qualified of for date range"
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
 FREE RECORD m_rec
END GO
