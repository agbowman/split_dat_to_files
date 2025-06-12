CREATE PROGRAM bhs_rpt_cis_security:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt_tm, s_end_dt_tm
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cucnt = i4
   1 cusers[*]
     2 f_person_id = f8
     2 s_cname = vc
     2 l_dcnt = i4
     2 date[*]
       3 s_create_dt_tm = vc
       3 l_ucnt = i4
       3 users[*]
         4 s_name = vc
         4 s_username = vc
   1 l_mucnt = i4
   1 musers[*]
     2 f_person_id = f8
     2 s_uname = vc
     2 l_dcnt = i4
     2 date[*]
       3 s_updt_dt_tm = vc
       3 l_ucnt = i4
       3 users[*]
         4 s_name = vc
         4 s_username = vc
   1 l_iucnt = i4
   1 iusers[*]
     2 f_person_id = f8
     2 s_uname = vc
     2 l_dcnt = i4
     2 date[*]
       3 s_end_effective_dt_tm = vc
       3 l_ucnt = i4
       3 users[*]
         4 s_name = vc
         4 s_username = vc
   1 l_fcnt = i4
   1 fax[*]
     2 f_person_id = f8
     2 s_uname = vc
     2 l_dcnt = i4
     2 date[*]
       3 s_updt_dt_tm = vc
       3 l_ucnt = i4
       3 dev[*]
         4 s_name = vc
   1 l_lcnt = i4
   1 loc[*]
     2 f_person_id = f8
     2 s_uname = vc
     2 l_dcnt = i4
     2 date[*]
       3 s_updt_dt_tm = vc
       3 l_ucnt = i4
       3 locs[*]
         4 s_location = vc
         4 s_type = vc
         4 s_org = vc
 ) WITH protect
 FREE RECORD m_rpt
 RECORD m_rpt(
   1 l_rptcnt = i4
   1 rptlst[*]
     2 c_field01 = c255
     2 c_field02 = c255
     2 c_field03 = c255
     2 c_field04 = c255
     2 c_field05 = c255
     2 c_field06 = c255
     2 c_field07 = c255
     2 c_field08 = c255
     2 c_field09 = c255
     2 c_field10 = c255
     2 c_field11 = c255
     2 c_field12 = c255
     2 c_field13 = c255
     2 c_field14 = c255
     2 c_field15 = c255
 ) WITH protect
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
 DECLARE mf_bhsdbanotools_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSDBANOTOOLS"))
 DECLARE mf_dba_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,"DBA"))
 DECLARE mf_dbabhs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,"DBABHS"))
 DECLARE mf_fax_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3000,"FAX"))
 DECLARE ms_beg_dt_tm = vc WITH protect
 DECLARE ms_end_dt_tm = vc WITH protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_cucnt = i4 WITH protect, noconstant(0)
 DECLARE ml_mucnt = i4 WITH protect, noconstant(0)
 DECLARE ml_iucnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ucnt = i4 WITH protect, noconstant(0)
 DECLARE ml_fcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_lcnt = i4 WITH protect, noconstant(0)
 DECLARE mn_ufirst_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_dfirst_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_utot = i4 WITH protect, noconstant(0)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_outstring = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_in = vc WITH protect, noconstant(" ")
 DECLARE md_filename_out = vc WITH protect, noconstant(" ")
 SET ms_beg_dt_tm = format(cnvtdatetime((curdate - 1),0),"DD-MMM-YYYY HH:mm:ss;;D")
 SET ms_end_dt_tm = format(cnvtdatetime(curdate,0),"DD-MMM-YYYY HH:mm:ss;;D")
 CALL echo(ms_beg_dt_tm)
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_address_list =  $OUTDEV
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtdatetime(sysdate),
     "MMDDYYYYHHMMSS;;D"),".csv"))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SELECT INTO "nl:"
  create_date = format(pr.create_dt_tm,"yyyymmdd;;D")
  FROM prsnl pr,
   prsnl pr2
  PLAN (pr
   WHERE pr.create_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND pr.create_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND pr.active_ind=1)
   JOIN (pr2
   WHERE pr2.person_id=pr.create_prsnl_id
    AND pr2.position_cd IN (mf_bhsdbanotools_cd, mf_dba_cd, mf_dbabhs_cd))
  ORDER BY pr2.name_last_key, pr2.name_first_key, pr2.person_id,
   create_date DESC, pr.name_full_formatted
  HEAD REPORT
   ml_cucnt = 0
  HEAD pr2.name_last_key
   null
  HEAD pr2.name_first_key
   null
  HEAD pr2.person_id
   ml_cucnt += 1, m_rec->l_cucnt = ml_cucnt, stat = alterlist(m_rec->cusers,ml_cucnt),
   m_rec->cusers[ml_cucnt].f_person_id = pr2.person_id, m_rec->cusers[ml_cucnt].s_cname = trim(pr2
    .name_full_formatted,3), ml_dcnt = 0
  HEAD create_date
   ml_dcnt += 1, m_rec->cusers[ml_cucnt].l_dcnt = ml_dcnt, stat = alterlist(m_rec->cusers[ml_cucnt].
    date,ml_dcnt),
   m_rec->cusers[ml_cucnt].date[ml_dcnt].s_create_dt_tm = format(pr.create_dt_tm,"mm/dd/yyyy;;D"),
   ml_ucnt = 0
  HEAD pr.name_full_formatted
   ml_ucnt += 1, m_rec->cusers[ml_cucnt].date[ml_dcnt].l_ucnt = ml_ucnt, stat = alterlist(m_rec->
    cusers[ml_cucnt].date[ml_dcnt].users,ml_ucnt),
   m_rec->cusers[ml_cucnt].date[ml_dcnt].users[ml_ucnt].s_name = trim(pr.name_full_formatted,3),
   m_rec->cusers[ml_cucnt].date[ml_dcnt].users[ml_ucnt].s_username = trim(pr.username,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  updt_date = format(pr.updt_dt_tm,"yyyymmdd;;D")
  FROM prsnl pr,
   prsnl pr2
  PLAN (pr
   WHERE pr.updt_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND pr.updt_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND pr.create_dt_tm < cnvtdatetime(ms_beg_dt_tm)
    AND pr.active_ind=1)
   JOIN (pr2
   WHERE pr2.person_id=pr.updt_id
    AND pr2.position_cd IN (mf_bhsdbanotools_cd, mf_dba_cd, mf_dbabhs_cd))
  ORDER BY pr2.name_last_key, pr2.name_first_key, pr2.person_id,
   updt_date DESC, pr.name_full_formatted
  HEAD REPORT
   ml_mucnt = 0
  HEAD pr2.name_last_key
   null
  HEAD pr2.name_first_key
   null
  HEAD pr2.person_id
   ml_mucnt += 1, m_rec->l_mucnt = ml_mucnt, stat = alterlist(m_rec->musers,ml_mucnt),
   m_rec->musers[ml_mucnt].f_person_id = pr2.person_id, m_rec->musers[ml_mucnt].s_uname = trim(pr2
    .name_full_formatted,3), ml_dcnt = 0
  HEAD updt_date
   ml_dcnt += 1, m_rec->musers[ml_mucnt].l_dcnt = ml_dcnt, stat = alterlist(m_rec->musers[ml_mucnt].
    date,ml_dcnt),
   m_rec->musers[ml_mucnt].date[ml_dcnt].s_updt_dt_tm = format(pr.updt_dt_tm,"mm/dd/yyyy;;D"),
   ml_ucnt = 0
  HEAD pr.name_full_formatted
   ml_ucnt += 1, m_rec->musers[ml_mucnt].date[ml_dcnt].l_ucnt = ml_ucnt, stat = alterlist(m_rec->
    musers[ml_mucnt].date[ml_dcnt].users,ml_ucnt),
   m_rec->musers[ml_mucnt].date[ml_dcnt].users[ml_ucnt].s_name = trim(pr.name_full_formatted,3),
   m_rec->musers[ml_mucnt].date[ml_dcnt].users[ml_ucnt].s_username = trim(pr.username,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  end_effective_dt_tm = format(pr.end_effective_dt_tm,"yyyymmdd;;D")
  FROM prsnl pr,
   prsnl pr2
  PLAN (pr
   WHERE pr.end_effective_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (pr2
   WHERE pr2.person_id=pr.updt_id
    AND pr2.position_cd IN (mf_bhsdbanotools_cd, mf_dba_cd, mf_dbabhs_cd)
    AND pr2.person_id > 0)
  ORDER BY pr2.name_last_key, pr2.name_first_key, pr2.person_id,
   end_effective_dt_tm DESC, pr.name_full_formatted
  HEAD REPORT
   ml_iucnt = 0
  HEAD pr2.name_last_key
   null
  HEAD pr2.name_first_key
   null
  HEAD pr2.person_id
   ml_iucnt += 1, m_rec->l_iucnt = ml_iucnt, stat = alterlist(m_rec->iusers,ml_iucnt),
   m_rec->iusers[ml_iucnt].f_person_id = pr2.person_id, m_rec->iusers[ml_iucnt].s_uname = trim(pr2
    .name_full_formatted,3), ml_dcnt = 0
  HEAD end_effective_dt_tm
   ml_dcnt += 1, m_rec->iusers[ml_iucnt].l_dcnt = ml_dcnt, stat = alterlist(m_rec->iusers[ml_iucnt].
    date,ml_dcnt),
   m_rec->iusers[ml_iucnt].date[ml_dcnt].s_end_effective_dt_tm = format(pr.end_effective_dt_tm,
    "mm/dd/yyyy;;D"), ml_ucnt = 0
  HEAD pr.name_full_formatted
   ml_ucnt += 1, m_rec->iusers[ml_iucnt].date[ml_dcnt].l_ucnt = ml_ucnt, stat = alterlist(m_rec->
    iusers[ml_iucnt].date[ml_dcnt].users,ml_ucnt),
   m_rec->iusers[ml_iucnt].date[ml_dcnt].users[ml_ucnt].s_name = trim(pr.name_full_formatted,3),
   m_rec->iusers[ml_iucnt].date[ml_dcnt].users[ml_ucnt].s_username = trim(pr.username,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  updt_date = format(d.updt_dt_tm,"yyyymmdd;;D")
  FROM device d,
   prsnl pr
  PLAN (d
   WHERE d.device_type_cd=mf_fax_cd
    AND d.updt_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND d.updt_dt_tm < cnvtdatetime(ms_end_dt_tm))
   JOIN (pr
   WHERE pr.person_id=d.updt_id
    AND pr.position_cd IN (mf_bhsdbanotools_cd, mf_dba_cd, mf_dbabhs_cd))
  ORDER BY pr.name_last_key, pr.name_first_key, pr.person_id,
   updt_date DESC, d.name
  HEAD REPORT
   ml_fcnt = 0
  HEAD pr.name_last_key
   null
  HEAD pr.name_first_key
   null
  HEAD pr.person_id
   ml_fcnt += 1, m_rec->l_fcnt = ml_fcnt, stat = alterlist(m_rec->fax,ml_fcnt),
   m_rec->fax[ml_fcnt].f_person_id = pr.person_id, m_rec->fax[ml_fcnt].s_uname = trim(pr
    .name_full_formatted,3), ml_dcnt = 0
  HEAD updt_date
   ml_dcnt += 1, m_rec->fax[ml_fcnt].l_dcnt = ml_dcnt, stat = alterlist(m_rec->fax[ml_fcnt].date,
    ml_dcnt),
   m_rec->fax[ml_fcnt].date[ml_dcnt].s_updt_dt_tm = format(d.updt_dt_tm,"mm/dd/yyyy;;D"), ml_ucnt = 0
  HEAD d.name
   ml_ucnt += 1, m_rec->fax[ml_fcnt].date[ml_dcnt].l_ucnt = ml_ucnt, stat = alterlist(m_rec->fax[
    ml_fcnt].date[ml_dcnt].dev,ml_ucnt),
   m_rec->fax[ml_fcnt].date[ml_dcnt].dev[ml_ucnt].s_name = trim(d.name,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  loc_name = trim(uar_get_code_display(l.location_cd),3), updt_date = format(l.updt_dt_tm,
   "yyyymmdd;;D")
  FROM location l,
   organization o,
   prsnl pr
  PLAN (l
   WHERE l.updt_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND l.updt_dt_tm < cnvtdatetime(ms_end_dt_tm))
   JOIN (o
   WHERE o.organization_id=l.organization_id)
   JOIN (pr
   WHERE pr.person_id=l.updt_id
    AND pr.position_cd IN (mf_bhsdbanotools_cd, mf_dba_cd, mf_dbabhs_cd))
  ORDER BY pr.name_last_key, pr.name_first_key, pr.person_id,
   updt_date DESC, loc_name
  HEAD REPORT
   ml_fcnt = 0
  HEAD pr.name_last_key
   null
  HEAD pr.name_first_key
   null
  HEAD pr.person_id
   ml_lcnt += 1, m_rec->l_lcnt = ml_lcnt, stat = alterlist(m_rec->loc,ml_lcnt),
   m_rec->loc[ml_lcnt].f_person_id = pr.person_id, m_rec->loc[ml_lcnt].s_uname = trim(pr
    .name_full_formatted,3), ml_dcnt = 0
  HEAD updt_date
   ml_dcnt += 1, m_rec->loc[ml_lcnt].l_dcnt = ml_dcnt, stat = alterlist(m_rec->loc[ml_lcnt].date,
    ml_dcnt),
   m_rec->loc[ml_lcnt].date[ml_dcnt].s_updt_dt_tm = format(l.updt_dt_tm,"mm/dd/yyyy;;D"), ml_ucnt = 0
  HEAD loc_name
   ml_ucnt += 1, m_rec->loc[ml_lcnt].date[ml_dcnt].l_ucnt = ml_ucnt, stat = alterlist(m_rec->loc[
    ml_lcnt].date[ml_dcnt].locs,ml_ucnt),
   m_rec->loc[ml_lcnt].date[ml_dcnt].locs[ml_ucnt].s_location = trim(uar_get_code_display(l
     .location_cd),3), m_rec->loc[ml_lcnt].date[ml_dcnt].locs[ml_ucnt].s_type = trim(
    uar_get_code_display(l.location_type_cd),3), m_rec->loc[ml_lcnt].date[ml_dcnt].locs[ml_ucnt].
   s_org = trim(o.org_name,3)
  WITH nocounter
 ;end select
 SET m_rpt->l_rptcnt = 0
 SET ml_rptcnt = 0
 IF ((m_rec->l_cucnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_cucnt),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,m_rec->cusers[d1.seq].l_dcnt))
    JOIN (d2
    WHERE maxrec(d3,m_rec->cusers[d1.seq].date[d2.seq].l_ucnt))
    JOIN (d3)
   ORDER BY d1.seq, d2.seq, d3.seq
   HEAD REPORT
    ml_rptcnt = m_rpt->l_rptcnt, ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt,
    stat = alterlist(m_rpt->rptlst,ml_rptcnt), m_rpt->rptlst[ml_rptcnt].c_field01 =
    "Users Created per Day", ml_rptcnt += 1,
    m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt), m_rpt->rptlst[ml_rptcnt].
    c_field01 = "Create User",
    m_rpt->rptlst[ml_rptcnt].c_field02 = "Create Date", m_rpt->rptlst[ml_rptcnt].c_field03 =
    "Users Created Per Day"
   HEAD d1.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field01 = m_rec->cusers[d1.seq].s_cname, mn_ufirst_ind = 1, ml_utot =
    0
   HEAD d2.seq
    IF (mn_ufirst_ind=1)
     mn_ufirst_ind = 0
    ELSE
     ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt)
    ENDIF
    m_rpt->rptlst[ml_rptcnt].c_field02 = m_rec->cusers[d1.seq].date[d2.seq].s_create_dt_tm, m_rpt->
    rptlst[ml_rptcnt].c_field03 = build(m_rec->cusers[d1.seq].date[d2.seq].l_ucnt), m_rpt->rptlst[
    ml_rptcnt].c_field04 = "Name",
    m_rpt->rptlst[ml_rptcnt].c_field05 = "Username", ml_utot += m_rec->cusers[d1.seq].date[d2.seq].
    l_ucnt
   HEAD d3.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field04 = m_rec->cusers[d1.seq].date[d2.seq].users[d3.seq].s_name,
    m_rpt->rptlst[ml_rptcnt].c_field05 = m_rec->cusers[d1.seq].date[d2.seq].users[d3.seq].s_username
   FOOT  d3.seq
    null
   FOOT  d2.seq
    null
   FOOT  d1.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field02 = "User Total:", m_rpt->rptlst[ml_rptcnt].c_field03 = build(
     ml_utot)
   WITH nocounter
  ;end select
 ELSE
  SET ml_rptcnt += 1
  SET m_rpt->l_rptcnt = ml_rptcnt
  SET stat = alterlist(m_rpt->rptlst,ml_rptcnt)
  SET m_rpt->rptlst[ml_rptcnt].c_field01 = ""
  SET ml_rptcnt += 1
  SET m_rpt->l_rptcnt = ml_rptcnt
  SET stat = alterlist(m_rpt->rptlst,ml_rptcnt)
  SET m_rpt->rptlst[ml_rptcnt].c_field01 = "No users created this day."
 ENDIF
 IF ((m_rec->l_mucnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_mucnt),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,m_rec->musers[d1.seq].l_dcnt))
    JOIN (d2
    WHERE maxrec(d3,m_rec->musers[d1.seq].date[d2.seq].l_ucnt))
    JOIN (d3)
   ORDER BY d1.seq, d2.seq, d3.seq
   HEAD REPORT
    ml_rptcnt = m_rpt->l_rptcnt
    IF (ml_rptcnt > 0)
     ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt)
    ENDIF
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field01 = "Users Modified per Day", ml_rptcnt += 1, m_rpt->l_rptcnt =
    ml_rptcnt,
    stat = alterlist(m_rpt->rptlst,ml_rptcnt), m_rpt->rptlst[ml_rptcnt].c_field01 = "Modify User",
    m_rpt->rptlst[ml_rptcnt].c_field02 = "Modify Date",
    m_rpt->rptlst[ml_rptcnt].c_field03 = "Users Modified Per Day"
   HEAD d1.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field01 = m_rec->musers[d1.seq].s_uname, mn_ufirst_ind = 1, ml_utot =
    0
   HEAD d2.seq
    IF (mn_ufirst_ind=1)
     mn_ufirst_ind = 0
    ELSE
     ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt)
    ENDIF
    m_rpt->rptlst[ml_rptcnt].c_field02 = m_rec->musers[d1.seq].date[d2.seq].s_updt_dt_tm, m_rpt->
    rptlst[ml_rptcnt].c_field03 = build(m_rec->musers[d1.seq].date[d2.seq].l_ucnt), m_rpt->rptlst[
    ml_rptcnt].c_field04 = "Name",
    m_rpt->rptlst[ml_rptcnt].c_field05 = "Username", ml_utot += m_rec->musers[d1.seq].date[d2.seq].
    l_ucnt
   HEAD d3.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field04 = m_rec->musers[d1.seq].date[d2.seq].users[d3.seq].s_name,
    m_rpt->rptlst[ml_rptcnt].c_field05 = m_rec->musers[d1.seq].date[d2.seq].users[d3.seq].s_username
   FOOT  d3.seq
    null
   FOOT  d2.seq
    null
   FOOT  d1.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field02 = "User Total:", m_rpt->rptlst[ml_rptcnt].c_field03 = build(
     ml_utot)
   WITH nocounter
  ;end select
 ELSE
  SET ml_rptcnt += 1
  SET m_rpt->l_rptcnt = ml_rptcnt
  SET stat = alterlist(m_rpt->rptlst,ml_rptcnt)
  SET m_rpt->rptlst[ml_rptcnt].c_field01 = ""
  SET ml_rptcnt += 1
  SET m_rpt->l_rptcnt = ml_rptcnt
  SET stat = alterlist(m_rpt->rptlst,ml_rptcnt)
  SET m_rpt->rptlst[ml_rptcnt].c_field01 = "No users modified this day."
 ENDIF
 IF ((m_rec->l_iucnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_iucnt),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,m_rec->iusers[d1.seq].l_dcnt))
    JOIN (d2
    WHERE maxrec(d3,m_rec->iusers[d1.seq].date[d2.seq].l_ucnt))
    JOIN (d3)
   ORDER BY d1.seq, d2.seq, d3.seq
   HEAD REPORT
    ml_rptcnt = m_rpt->l_rptcnt
    IF (ml_rptcnt > 0)
     ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt)
    ENDIF
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field01 = "Users Inactive Per Day", ml_rptcnt += 1, m_rpt->l_rptcnt =
    ml_rptcnt,
    stat = alterlist(m_rpt->rptlst,ml_rptcnt), m_rpt->rptlst[ml_rptcnt].c_field01 = "Inactivate User",
    m_rpt->rptlst[ml_rptcnt].c_field02 = "Inactive Date",
    m_rpt->rptlst[ml_rptcnt].c_field03 = "Users Inactive Per Day"
   HEAD d1.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field01 = m_rec->iusers[d1.seq].s_uname, mn_ifirst_ind = 1, ml_itot =
    0
   HEAD d2.seq
    IF (mn_ifirst_ind=1)
     mn_ifirst_ind = 0
    ELSE
     ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt)
    ENDIF
    m_rpt->rptlst[ml_rptcnt].c_field02 = m_rec->iusers[d1.seq].date[d2.seq].s_end_effective_dt_tm,
    m_rpt->rptlst[ml_rptcnt].c_field03 = build(m_rec->iusers[d1.seq].date[d2.seq].l_ucnt), m_rpt->
    rptlst[ml_rptcnt].c_field04 = "Name",
    m_rpt->rptlst[ml_rptcnt].c_field05 = "Username", ml_itot += m_rec->iusers[d1.seq].date[d2.seq].
    l_ucnt
   HEAD d3.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field04 = m_rec->iusers[d1.seq].date[d2.seq].users[d3.seq].s_name,
    m_rpt->rptlst[ml_rptcnt].c_field05 = m_rec->iusers[d1.seq].date[d2.seq].users[d3.seq].s_username
   FOOT  d3.seq
    null
   FOOT  d2.seq
    null
   FOOT  d1.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field02 = "User Total:", m_rpt->rptlst[ml_rptcnt].c_field03 = build(
     ml_itot)
   WITH nocounter
  ;end select
 ELSE
  SET ml_rptcnt += 1
  SET m_rpt->l_rptcnt = ml_rptcnt
  SET stat = alterlist(m_rpt->rptlst,ml_rptcnt)
  SET m_rpt->rptlst[ml_rptcnt].c_field01 = "No inactive users"
 ENDIF
 IF ((m_rec->l_fcnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_fcnt),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,m_rec->fax[d1.seq].l_dcnt))
    JOIN (d2
    WHERE maxrec(d3,m_rec->fax[d1.seq].date[d2.seq].l_ucnt))
    JOIN (d3)
   ORDER BY d1.seq, d2.seq, d3.seq
   HEAD REPORT
    ml_rptcnt = m_rpt->l_rptcnt
    IF (ml_rptcnt > 0)
     ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt)
    ENDIF
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field01 = "Fax Devices Modified per Day", ml_rptcnt += 1, m_rpt->
    l_rptcnt = ml_rptcnt,
    stat = alterlist(m_rpt->rptlst,ml_rptcnt), m_rpt->rptlst[ml_rptcnt].c_field01 = "Modify User",
    m_rpt->rptlst[ml_rptcnt].c_field02 = "Modify Date",
    m_rpt->rptlst[ml_rptcnt].c_field03 = "Fax Devices Modified Per Day"
   HEAD d1.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field01 = m_rec->fax[d1.seq].s_uname, mn_ufirst_ind = 1, ml_utot = 0
   HEAD d2.seq
    IF (mn_ufirst_ind=1)
     mn_ufirst_ind = 0
    ELSE
     ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt)
    ENDIF
    m_rpt->rptlst[ml_rptcnt].c_field02 = m_rec->fax[d1.seq].date[d2.seq].s_updt_dt_tm, m_rpt->rptlst[
    ml_rptcnt].c_field03 = build(m_rec->fax[d1.seq].date[d2.seq].l_ucnt), m_rpt->rptlst[ml_rptcnt].
    c_field04 = "Fax Device",
    ml_utot += m_rec->fax[d1.seq].date[d2.seq].l_ucnt
   HEAD d3.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field04 = m_rec->fax[d1.seq].date[d2.seq].dev[d3.seq].s_name
   FOOT  d3.seq
    null
   FOOT  d2.seq
    null
   FOOT  d1.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field02 = "User Total:", m_rpt->rptlst[ml_rptcnt].c_field03 = build(
     ml_utot)
   WITH nocounter
  ;end select
 ELSE
  SET ml_rptcnt += 1
  SET m_rpt->l_rptcnt = ml_rptcnt
  SET stat = alterlist(m_rpt->rptlst,ml_rptcnt)
  SET m_rpt->rptlst[ml_rptcnt].c_field01 = ""
  SET ml_rptcnt += 1
  SET m_rpt->l_rptcnt = ml_rptcnt
  SET stat = alterlist(m_rpt->rptlst,ml_rptcnt)
  SET m_rpt->rptlst[ml_rptcnt].c_field01 = "No fax devices created/modified this day."
 ENDIF
 IF ((m_rec->l_lcnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_lcnt),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,m_rec->loc[d1.seq].l_dcnt))
    JOIN (d2
    WHERE maxrec(d3,m_rec->loc[d1.seq].date[d2.seq].l_ucnt))
    JOIN (d3)
   ORDER BY d1.seq, d2.seq, d3.seq
   HEAD REPORT
    ml_rptcnt = m_rpt->l_rptcnt
    IF (ml_rptcnt > 0)
     ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt)
    ENDIF
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field01 = "Locations Modified per Day", ml_rptcnt += 1, m_rpt->
    l_rptcnt = ml_rptcnt,
    stat = alterlist(m_rpt->rptlst,ml_rptcnt), m_rpt->rptlst[ml_rptcnt].c_field01 = "Modify User",
    m_rpt->rptlst[ml_rptcnt].c_field02 = "Modify Date",
    m_rpt->rptlst[ml_rptcnt].c_field03 = "Locations Modified Per Day"
   HEAD d1.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field01 = m_rec->loc[d1.seq].s_uname, mn_ufirst_ind = 1, ml_utot = 0
   HEAD d2.seq
    IF (mn_ufirst_ind=1)
     mn_ufirst_ind = 0
    ELSE
     ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt)
    ENDIF
    m_rpt->rptlst[ml_rptcnt].c_field02 = m_rec->loc[d1.seq].date[d2.seq].s_updt_dt_tm, m_rpt->rptlst[
    ml_rptcnt].c_field03 = build(m_rec->loc[d1.seq].date[d2.seq].l_ucnt), m_rpt->rptlst[ml_rptcnt].
    c_field04 = "Location",
    m_rpt->rptlst[ml_rptcnt].c_field05 = "Location Type", m_rpt->rptlst[ml_rptcnt].c_field06 =
    "Organization", ml_utot += m_rec->loc[d1.seq].date[d2.seq].l_ucnt
   HEAD d3.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field04 = m_rec->loc[d1.seq].date[d2.seq].locs[d3.seq].s_location,
    m_rpt->rptlst[ml_rptcnt].c_field05 = m_rec->loc[d1.seq].date[d2.seq].locs[d3.seq].s_type, m_rpt->
    rptlst[ml_rptcnt].c_field06 = m_rec->loc[d1.seq].date[d2.seq].locs[d3.seq].s_org
   FOOT  d3.seq
    null
   FOOT  d2.seq
    null
   FOOT  d1.seq
    ml_rptcnt += 1, m_rpt->l_rptcnt = ml_rptcnt, stat = alterlist(m_rpt->rptlst,ml_rptcnt),
    m_rpt->rptlst[ml_rptcnt].c_field02 = "User Total:", m_rpt->rptlst[ml_rptcnt].c_field03 = build(
     ml_utot)
   WITH nocounter
  ;end select
 ELSE
  SET ml_rptcnt += 1
  SET m_rpt->l_rptcnt = ml_rptcnt
  SET stat = alterlist(m_rpt->rptlst,ml_rptcnt)
  SET m_rpt->rptlst[ml_rptcnt].c_field01 = ""
  SET ml_rptcnt += 1
  SET m_rpt->l_rptcnt = ml_rptcnt
  SET stat = alterlist(m_rpt->rptlst,ml_rptcnt)
  SET m_rpt->rptlst[ml_rptcnt].c_field01 = "No locations created/modified this day."
 ENDIF
 CALL echorecord(m_rpt)
 IF ((m_rpt->l_rptcnt < 1))
  GO TO exit_script
 ENDIF
 SELECT
  IF (mn_email_ind=1)
   WITH noformat, format = stream, pcformat('"',",",1),
    nocounter
  ELSE
  ENDIF
  INTO value(ms_output_dest)
  field01 = m_rpt->rptlst[d.seq].c_field01, field02 = m_rpt->rptlst[d.seq].c_field02, field03 = m_rpt
  ->rptlst[d.seq].c_field03,
  field04 = m_rpt->rptlst[d.seq].c_field04, field05 = m_rpt->rptlst[d.seq].c_field05, field06 = m_rpt
  ->rptlst[d.seq].c_field06,
  field07 = m_rpt->rptlst[d.seq].c_field07
  FROM (dummyt d  WITH seq = m_rpt->l_rptcnt)
  WITH format, separator = " ", nocounter
 ;end select
 IF (mn_email_ind=1)
  EXECUTE bhs_ma_email_file
  SET ms_subject = concat("CIS Security Report for ",format(cnvtlookbehind("1 D",cnvtdatetime(
      ms_end_dt_tm)),"mm/dd/yyyy;;D"))
  SET ms_filename_out = concat("cis_security_report_",format(cnvtlookbehind("1 D",cnvtdatetime(
      ms_end_dt_tm)),"YYYYMMDD;;D"),".csv")
  CALL emailfile(ms_output_dest,ms_filename_out,ms_address_list,ms_subject,1)
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->ops_event = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].targetobjectname = ""
END GO
