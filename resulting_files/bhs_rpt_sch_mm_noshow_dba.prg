CREATE PROGRAM bhs_rpt_sch_mm_noshow:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Appt Date Start:" = "CURDATE",
  "Appt Date Start:" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 EXECUTE bhs_check_domain
 DECLARE ml_start_dt = i4 WITH protect, noconstant(0)
 DECLARE ml_stop_dt = i4 WITH protect, noconstant(0)
 DECLARE mf_interplang_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "INTERPRETERLANGUAGE"))
 DECLARE mf_cs43_cell_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2510010055"))
 DECLARE mf_cs280_yes_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4114015754"))
 DECLARE mf_cs213_current_name_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"CURRENT"
   ))
 DECLARE mf_cs43_bussphone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"BUSINESS")
  )
 DECLARE mf_cs355_userdefined_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!13752"))
 DECLARE mf_cs356_globalconsent_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "GLOBALCONSENT"))
 DECLARE mf_cs356_glbconsentdt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "GLOBALCONSENTDATE"))
 DECLARE mf_cs100900_yes_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",100900,"YES"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE ml_ftp_ind = i4 WITH protect, noconstant(0)
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 s_pat_fname = vc
     2 s_pat_lname = vc
     2 s_pat_language = vc
     2 s_appt_type = vc
     2 s_pat_phone = vc
     2 s_appt_dt = vc
     2 s_appt_dt_sp = vc
     2 s_appt_day = vc
     2 s_appt_loc = vc
     2 f_appt_loc = f8
     2 s_appt_loc_phone = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM sch_appt sa,
   person_name pn,
   sch_event se,
   code_value cv,
   phone ph,
   phone ph2,
   sch_event_detail sed
  PLAN (sa
   WHERE sa.beg_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND sa.role_meaning="PATIENT"
    AND sa.active_ind=1
    AND sa.version_dt_tm > cnvtdatetime(sysdate)
    AND sa.state_meaning IN ("NOSHOW"))
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id)
   JOIN (cv
   WHERE cv.code_value=se.appt_type_cd
    AND cv.code_set=14230
    AND cv.display_key="MM*")
   JOIN (pn
   WHERE pn.person_id=sa.person_id
    AND pn.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND pn.active_ind=1
    AND pn.name_type_cd=mf_cs213_current_name_cd)
   JOIN (ph
   WHERE ph.parent_entity_id=sa.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd=mf_cs43_cell_cd
    AND ph.active_ind=1
    AND ph.end_effective_dt_tm > sysdate)
   JOIN (ph2
   WHERE (ph2.parent_entity_name= Outerjoin("LOCATION"))
    AND (ph2.parent_entity_id= Outerjoin(sa.appt_location_cd))
    AND (ph2.active_ind= Outerjoin(1))
    AND (ph2.phone_type_cd= Outerjoin(mf_cs43_bussphone_cd)) )
   JOIN (sed
   WHERE (sed.sch_event_id= Outerjoin(se.sch_event_id))
    AND (sed.version_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
    AND (sed.active_ind= Outerjoin(1))
    AND (sed.oe_field_id= Outerjoin(mf_interplang_cd)) )
  ORDER BY sa.sch_event_id, ph.phone_type_seq, ph2.phone_type_seq
  HEAD REPORT
   m_rec->l_cnt = 0
  HEAD sa.sch_event_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_person_id = sa.person_id,
   m_rec->qual[m_rec->l_cnt].s_pat_fname = trim(pn.name_first,3), m_rec->qual[m_rec->l_cnt].
   s_pat_lname = trim(pn.name_last,3), m_rec->qual[m_rec->l_cnt].s_appt_type = trim(
    uar_get_code_display(se.appt_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_pat_phone = replace(replace(replace(trim(ph.phone_num,3),")",""),"(",
     ""),"-",""), m_rec->qual[m_rec->l_cnt].s_appt_dt = format(sa.beg_dt_tm,"MM/DD/YYYY;;q"), m_rec->
   qual[m_rec->l_cnt].s_appt_dt_sp = format(sa.beg_dt_tm,"DD/MM/YYYY;;q"),
   m_rec->qual[m_rec->l_cnt].s_appt_day = trim(format(sa.beg_dt_tm,"wwwwwwwww;;d"),3), m_rec->qual[
   m_rec->l_cnt].s_appt_loc = trim(uar_get_code_display(sa.appt_location_cd),3), m_rec->qual[m_rec->
   l_cnt].f_appt_loc = sa.appt_location_cd
   IF (size(trim(ph2.phone_num,3)) > 0)
    m_rec->qual[m_rec->l_cnt].s_appt_loc_phone = replace(replace(replace(trim(ph2.phone_num,3),")",""
       ),"(",""),"-","")
   ELSE
    m_rec->qual[m_rec->l_cnt].s_appt_loc_phone = "4137942222"
   ENDIF
   IF (sed.oe_field_display_value="Spanish")
    m_rec->qual[m_rec->l_cnt].s_pat_language = "MissedApptSpanish"
   ELSE
    m_rec->qual[m_rec->l_cnt].s_pat_language = "MissedApptEnglish"
   ENDIF
  WITH nocounter
 ;end select
 SET frec->file_name = build(logical("bhscust"),"/ftp/bhs_rpt_sch_mm_noshow/bhs_mm_noshow_appt_",trim
  (cnvtstring(rand(0),20),3),"_",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;d"),
  ".dat")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF (size(trim(m_rec->qual[ml_idx1].s_pat_phone,3)) > 0
    AND trim(m_rec->qual[ml_idx1].s_pat_phone,3) != "0000000000")
    SET frec->file_buf = build(m_rec->qual[ml_idx1].s_pat_phone,"|",m_rec->qual[ml_idx1].s_pat_fname,
     "|",m_rec->qual[ml_idx1].s_pat_lname,
     "|",m_rec->qual[ml_idx1].s_pat_language,"|",m_rec->qual[ml_idx1].s_appt_type,"|",
     m_rec->qual[ml_idx1].s_appt_day,"|",m_rec->qual[ml_idx1].s_appt_dt,"|",m_rec->qual[ml_idx1].
     s_appt_dt_sp,
     "|",m_rec->qual[ml_idx1].s_appt_loc_phone,"|",trim(format(cnvtdatetime(sysdate),"YYYY-MM-DD;;q"),
      3),char(10))
    SET stat = cclio("WRITE",frec)
    SET ml_ftp_ind = 1
   ENDIF
 ENDFOR
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ms_ftp_path = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_host = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_username = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_password = vc WITH protect, noconstant(" ")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 SET stat = cclio("CLOSE",frec)
 IF (ml_ftp_ind=1)
  SET ms_dclcom = concat("cp ",frec->file_name," bhs_mm_noshow_appt.dat ")
  CALL echo(ms_dclcom)
  CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
  IF (gl_bhs_prod_flag=1)
   SET ms_dclcom = concat(
    "$cust_script/bhs_sftp_file.ksh ciscoreftp@transfer.baystatehealth.org:/reminders"," ",
    "bhs_mm_noshow_appt.dat")
   CALL echo(ms_dclcom)
   CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
  ELSE
   SET ms_dclcom = concat(
    "$cust_script/bhs_sftp_file.ksh ciscoreftp@transfer.baystatehealth.org:/reminders"," ",
    "bhs_mm_noshow_appt.dat")
   CALL echo(ms_dclcom)
   CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
  ENDIF
  SET ms_dclcom = concat("rm ","bhs_mm_noshow_appt.dat")
  CALL echo(ms_dclcom)
  CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 ENDIF
#exit_script
END GO
