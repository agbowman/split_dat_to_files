CREATE PROGRAM bhs_rss_ed_wait_times2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = "BFMC",
  "send email" = 0,
  "BMC Pedi" = 0
  WITH outdev, s_facility, n_email,
  n_bmc_pedi
 EXECUTE bhs_check_domain:dba
 EXECUTE bhs_hlp_ccl
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 amb[*]
     2 f_cd = f8
     2 s_disp = vc
   1 pat[*]
     2 s_tracking_id = vc
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_name = vc
     2 s_checkin = vc
     2 s_checkout = vc
     2 s_contact = vc
     2 l_pat_wait = i4
     2 n_waiting = i2
     2 l_wait = i4
     2 evnt[*]
       3 s_disp = vc
       3 s_time = vc
 ) WITH protect
 FREE RECORD m_pedi_rooms
 RECORD m_pedi_rooms(
   1 l_cnt = i4
   1 qual[*]
     2 f_cd = f8
     2 s_disp = vc
 ) WITH protect
 DECLARE ms_facility = vc WITH protect, constant(cnvtupper(trim( $S_FACILITY)))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_event_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6202,"EVENT"))
 DECLARE mf_ambulatory_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"AMBULATORY"))
 DECLARE mn_is_pedi_unit = i2 WITH protect, noconstant( $N_BMC_PEDI)
 DECLARE mf_facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_ems_hand_dcp_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_doc_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_pub_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_day_of_week = vc WITH protect, noconstant(" ")
 DECLARE mf_avg_wait = f8 WITH protect, noconstant(0.0)
 DECLARE mf_avg_wait_orig = f8 WITH protect, noconstant(0.0)
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_waiting_pat_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_prod = i2 WITH protect, noconstant(0)
 DECLARE ml_expnd_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_parse = vc WITH protect, noconstant(" ")
 DECLARE ms_xml_file = vc WITH protect, noconstant(" ")
 DECLARE dclcom = vc WITH protect, noconstant("")
 DECLARE mf_tot_wait_done_only = f8 WITH protect, noconstant(0.0)
 CALL bhs_sbr_log("start","",0,"",0.0,
  "","Begin Script","")
 IF (ms_facility="BMLH")
  SET mf_facility_cd = uar_get_code_by("DISPLAYKEY",16370,"BMLHEDTRACKINGGROUP")
 ELSEIF (ms_facility="BFMC")
  SET mf_facility_cd = uar_get_code_by("DISPLAYKEY",16370,"BFMCEDTRACKINGGROUP")
 ELSEIF (ms_facility="BMC")
  SET mf_facility_cd = uar_get_code_by("DISPLAYKEY",16370,"BMCEDHOFTRACKINGGROUP")
 ELSEIF (ms_facility="BWH")
  SET mf_facility_cd = uar_get_code_by("DISPLAYKEY",16370,"BWHEDTRACKINGGROUP")
 ELSEIF (ms_facility="BNH")
  SET mf_facility_cd = uar_get_code_by("DISPLAYKEY",16370,"BNHEDTRACKINGGROUP")
 ENDIF
 IF (mf_facility_cd <= 0)
  CALL bhs_sbr_log("log","",0,"",0.0,
   concat("Invalid Facility Param",ms_facility),"Only BMLH, BFMC, BMC accepted","F")
  GO TO exit_script
 ENDIF
 IF (mn_is_pedi_unit=1)
  IF (ms_facility="BMC")
   SET ms_xml_file = concat(cnvtlower(ms_facility),"_pedi_ed_avg_wait2.xml")
   SET ms_parse = concat(" tl.tracking_id = ti.tracking_id",
    " and expand(ml_expnd_cnt,1,size(m_pedi_rooms->qual, 5)",
    ",tl.loc_room_cd, m_pedi_rooms->qual[ml_expnd_cnt].f_cd)")
  ELSE
   CALL bhs_sbr_log("log","",0,"",0.0,
    concat("Invalid Pediatric Param",ms_facility),"Only BMC Pedi ED is supported","F")
   GO TO exit_script
  ENDIF
 ELSE
  SET ms_xml_file = concat(cnvtlower(ms_facility),"_ed_avg_wait2.xml")
  SET ms_parse = concat(" tl.tracking_id = ti.tracking_id",
   " and not expand(ml_expnd_cnt,1,size(m_pedi_rooms->qual, 5)",
   ",tl.loc_room_cd, m_pedi_rooms->qual[ml_expnd_cnt].f_cd)")
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=68
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.display_key="*AMBUL*"
  ORDER BY cv.code_value
  HEAD REPORT
   pl_cnt = 0
  HEAD cv.code_value
   pl_cnt += 1,
   CALL alterlist(m_rec->amb,pl_cnt), m_rec->amb[pl_cnt].f_cd = cv.code_value,
   m_rec->amb[pl_cnt].s_disp = trim(cv.display)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM location l,
   location_group lg1,
   code_value cv
  PLAN (cv
   WHERE cv.display_key="ESP"
    AND cv.cdf_meaning="AMBULATORY"
    AND cv.code_set=220)
   JOIN (l
   WHERE l.location_cd=cv.code_value
    AND l.active_ind=1)
   JOIN (lg1
   WHERE lg1.parent_loc_cd=l.location_cd
    AND lg1.active_ind=1
    AND lg1.location_group_type_cd=mf_ambulatory_cd)
  ORDER BY lg1.child_loc_cd
  HEAD REPORT
   m_pedi_rooms->l_cnt = 0
  HEAD lg1.child_loc_cd
   m_pedi_rooms->l_cnt += 1
   IF (mod(m_pedi_rooms->l_cnt,100)=1)
    CALL alterlist(m_pedi_rooms->qual,(m_pedi_rooms->l_cnt+ 99))
   ENDIF
   m_pedi_rooms->qual[m_pedi_rooms->l_cnt].f_cd = lg1.child_loc_cd, m_pedi_rooms->qual[m_pedi_rooms->
   l_cnt].s_disp = uar_get_code_display(lg1.child_loc_cd)
  FOOT REPORT
   CALL alterlist(m_pedi_rooms->qual,m_pedi_rooms->l_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM location l,
   location_group lg1,
   code_value cv,
   code_value cv1
  PLAN (cv
   WHERE cv.display_key="ESW"
    AND cv.cdf_meaning="AMBULATORY"
    AND cv.code_set=220)
   JOIN (l
   WHERE l.location_cd=cv.code_value
    AND l.active_ind=1)
   JOIN (lg1
   WHERE lg1.parent_loc_cd=l.location_cd
    AND lg1.active_ind=1
    AND lg1.location_group_type_cd=mf_ambulatory_cd)
   JOIN (cv1
   WHERE cv1.code_value=lg1.child_loc_cd
    AND cv1.cdf_meaning="WAITROOM"
    AND cv1.display_key="WRPEDI")
  ORDER BY lg1.child_loc_cd
  HEAD lg1.child_loc_cd
   m_pedi_rooms->l_cnt += 1,
   CALL alterlist(m_pedi_rooms->qual,(m_pedi_rooms->l_cnt+ 1)), m_pedi_rooms->qual[m_pedi_rooms->
   l_cnt].f_cd = lg1.child_loc_cd,
   m_pedi_rooms->qual[m_pedi_rooms->l_cnt].s_disp = uar_get_code_display(lg1.child_loc_cd)
  FOOT REPORT
   CALL alterlist(m_pedi_rooms->qual,m_pedi_rooms->l_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  WHERE dfr.description="ED EMS Handover"
   AND dfr.active_ind=1
  ORDER BY dfr.updt_dt_tm DESC
  HEAD dfr.dcp_forms_ref_id
   mf_ems_hand_dcp_id = dfr.dcp_forms_ref_id,
   CALL echo(build2("mf_ems_hand_dcp_id: ",mf_ems_hand_dcp_id))
  WITH nocounter
 ;end select
 SET ms_end_dt_tm = trim(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
 SET ms_beg_dt_tm = trim(format(cnvtlookbehind("1,MIN",cnvtdatetime(ms_end_dt_tm)),
   "dd-mmm-yyyy hh:mm:ss;;d"))
 CALL echo(concat(ms_beg_dt_tm," ",ms_end_dt_tm))
 SELECT INTO "nl:"
  tc.checkin_dt_tm, tracking_event_type = uar_get_code_display(tc.tracking_event_type_cd), tre
  .display,
  arrival_mode = trim(uar_get_code_display(e.admit_mode_cd))
  FROM tracking_checkin tc,
   tracking_event te,
   tracking_item ti,
   tracking_locator tl,
   encounter e,
   encntr_alias ea,
   track_event tre,
   person p
  PLAN (tc
   WHERE tc.checkin_dt_tm > cnvtlookbehind("12,H",sysdate)
    AND tc.tracking_group_cd=mf_facility_cd
    AND tc.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    te2.tracking_id
    FROM tracking_event te2,
     track_event tre2
    WHERE te2.tracking_id=tc.tracking_id
     AND te2.complete_dt_tm <= sysdate
     AND tre2.track_event_id=te2.track_event_id
     AND tre2.tracking_group_cd=tc.tracking_group_cd
     AND tre2.active_ind=1
     AND tre2.display_key="PROVPTCONTACT")))
    AND  NOT ( EXISTS (
   (SELECT
    te3.tracking_id
    FROM tracking_event te3,
     track_event tre3
    WHERE te3.tracking_id=tc.tracking_id
     AND tre3.track_event_id=te3.track_event_id
     AND tre3.tracking_group_cd=tc.tracking_group_cd
     AND tre3.active_ind=1
     AND tre3.display_key="LWBSFORM"))))
   JOIN (te
   WHERE te.tracking_id=tc.tracking_id
    AND te.active_ind=1)
   JOIN (tre
   WHERE tre.track_event_id=te.track_event_id
    AND tre.tracking_group_cd=tc.tracking_group_cd
    AND tre.active_ind=1)
   JOIN (ti
   WHERE ti.tracking_id=te.tracking_id)
   JOIN (tl
   WHERE parser(ms_parse))
   JOIN (e
   WHERE e.encntr_id=ti.encntr_id
    AND  NOT (expand(ml_exp,1,size(m_rec->amb,5),e.admit_mode_cd,m_rec->amb[ml_exp].f_cd))
    AND  NOT ( EXISTS (
   (SELECT
    dfa.encntr_id
    FROM dcp_forms_activity dfa
    WHERE dfa.person_id=e.person_id
     AND dfa.encntr_id=e.encntr_id
     AND dfa.dcp_forms_ref_id=mf_ems_hand_dcp_id
     AND dfa.active_ind=1
    ORDER BY dfa.encntr_id
    WITH nocounter))))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
  ORDER BY tc.tracking_id, te.complete_dt_tm, te.tracking_event_id,
   tl.tracking_locator_id DESC
  HEAD REPORT
   pl_wait_over_mins = 0, pl_tot_wait_over_mins = 0, pl_waiting_mins = 0,
   pl_tot_waiting_mins = 0, pl_cnt = 0, pl_waiting_pats = 0,
   pl_avg_pat_cnt = 0, pf_avg_wait = 0.0,
   CALL echo("tracking id, checkin, event disp, event complete, checkout")
  HEAD tc.tracking_id
   ms_doc_dt_tm = "", pl_cnt += 1,
   CALL alterlist(m_rec->pat,pl_cnt),
   m_rec->pat[pl_cnt].s_tracking_id = trim(cnvtstring(tc.tracking_id))
  HEAD te.complete_dt_tm
   null
  HEAD te.tracking_event_id
   CALL echo(concat(substring(1,30,p.name_full_formatted)," ",substring(1,10,uar_get_code_display(tl
      .loc_room_cd))," ",trim(cnvtstring(tc.tracking_id)),
    " ",trim(format(tc.checkin_dt_tm,"mm/dd/yy hh:mm:ss;;d"))," ",substring(1,20,tre.display_key)," ",
    trim(format(te.complete_dt_tm,"mm/dd/yy hh:mm:ss;;d"))," ",trim(format(tc.checkout_dt_tm,
      "mm/dd/yy hh:mm;;d"))))
   IF (textlen(trim(ms_doc_dt_tm))=0
    AND tre.display_key="PROVPTCONTACT")
    ms_doc_dt_tm = trim(format(te.complete_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
   ENDIF
  FOOT  tc.tracking_id
   CALL echo(concat("provcontact time: ",trim(cnvtstring(tc.tracking_id))," ",ms_doc_dt_tm)), m_rec->
   pat[pl_cnt].f_encntr_id = e.encntr_id, m_rec->pat[pl_cnt].f_person_id = e.person_id,
   m_rec->pat[pl_cnt].s_checkin = trim(format(tc.checkin_dt_tm,"mm/dd/yy hh:mm:ss;;d")), m_rec->pat[
   pl_cnt].s_checkout = trim(format(tc.checkout_dt_tm,"mm/dd/yy hh:mm:ss;;d")), m_rec->pat[pl_cnt].
   s_name = trim(p.name_full_formatted)
   IF (tc.checkout_dt_tm <= sysdate)
    pl_cnt -= 1,
    CALL alterlist(m_rec->pat,pl_cnt)
   ELSE
    pl_waiting_pats += 1, pl_waiting_mins = datetimediff(sysdate,tc.checkin_dt_tm,4),
    pl_tot_waiting_mins += pl_waiting_mins,
    m_rec->pat[pl_cnt].l_pat_wait = pl_waiting_mins, m_rec->pat[pl_cnt].n_waiting = 1, m_rec->pat[
    pl_cnt].l_wait = pl_waiting_mins,
    CALL echo(concat("wait to curtime  : ",trim(cnvtstring(pl_waiting_mins))))
   ENDIF
  FOOT REPORT
   ml_waiting_pat_cnt = pl_waiting_pats,
   CALL echo(concat("tot pat count: ",trim(cnvtstring(pl_cnt))," tot mins: ",trim(cnvtstring((
      pl_tot_wait_over_mins+ pl_tot_waiting_mins))))), pf_avg_wait = (cnvtreal((pl_tot_wait_over_mins
    + pl_tot_waiting_mins))/ cnvtreal(pl_cnt)),
   CALL echo(concat("tot avg wait: ",trim(cnvtstring(pf_avg_wait))," mins")),
   CALL echo(concat("pat count still waiting: ",trim(cnvtstring(pl_waiting_pats))," tot mins: ",trim(
     cnvtstring(pl_tot_waiting_mins)))), mf_avg_wait = (cnvtreal(pl_tot_waiting_mins)/ cnvtreal(
    pl_waiting_pats)),
   CALL echo(concat("avg wait for currently waiting patients: ",trim(cnvtstring(mf_avg_wait))))
  WITH nocounter
 ;end select
 SET pl_tot_waiting_mins = 0
 FOR (ml_loop = 1 TO size(m_rec->pat,5))
   IF ((m_rec->pat[ml_loop].n_waiting=1))
    IF ((m_rec->pat[ml_loop].l_wait > mf_avg_wait))
     SET pl_tot_waiting_mins += m_rec->pat[ml_loop].l_wait
    ELSE
     SET pl_tot_waiting_mins += mf_avg_wait
    ENDIF
   ENDIF
 ENDFOR
 SET mf_avg_wait_orig = mf_avg_wait
 SET mf_avg_wait = (cnvtreal(pl_tot_waiting_mins)/ cnvtreal(ml_waiting_pat_cnt))
 CALL echo(concat("weighted avg wait for currently waiting patients: ",trim(cnvtstring(mf_avg_wait)))
  )
 IF (size(m_rec->pat,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(m_rec->pat,5)))
   PLAN (d)
   HEAD REPORT
    CALL echo("name, room, checkin, wait, still waiting")
   HEAD d.seq
    CALL echo(concat(substring(1,30,m_rec->pat[d.seq].s_name)," ",m_rec->pat[d.seq].s_checkin," ",
     trim(cnvtstring(m_rec->pat[d.seq].l_pat_wait))))
   WITH nocounter
  ;end select
  SELECT INTO value( $OUTDEV)
   facility_avg_wait = trim(cnvtstring(mf_avg_wait)), patient_wait_mins = substring(1,5,trim(
     cnvtstring(m_rec->pat[d1.seq].l_pat_wait))), name = substring(1,30,m_rec->pat[d1.seq].s_name),
   event = substring(1,20,m_rec->pat[d1.seq].evnt[d2.seq].s_disp), checkin = m_rec->pat[d1.seq].
   s_checkin, event_tm = m_rec->pat[d1.seq].evnt[d2.seq].s_time
   FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
    dummyt d2
   PLAN (d1
    WHERE maxrec(d2,size(m_rec->pat[d1.seq].evnt,5)))
    JOIN (d2)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 SET ms_tmp = cnvtstring(weekday(sysdate))
 CASE (ms_tmp)
  OF "0":
   SET ms_day_of_week = "Sun"
  OF "1":
   SET ms_day_of_week = "Mon"
  OF "2":
   SET ms_day_of_week = "Tue"
  OF "3":
   SET ms_day_of_week = "Wed"
  OF "4":
   SET ms_day_of_week = "Thu"
  OF "5":
   SET ms_day_of_week = "Fri"
  OF "6":
   SET ms_day_of_week = "Sat"
 ENDCASE
 SET ms_pub_dt_tm = concat(ms_day_of_week," ",trim(format(sysdate,"dd mmm yyyy hh:mm:ss;;d")),
  " -0400")
 SET ms_tmp = concat('<rss version = "2.0">',char(10),"<channel>",char(10))
 IF (mn_is_pedi_unit=1)
  SET ms_tmp = concat(ms_tmp,"  <title>",ms_facility," Pedi Wait Times</title>",char(10))
 ELSE
  SET ms_tmp = concat(ms_tmp,"  <title>",ms_facility," Wait Times</title>",char(10))
 ENDIF
 SET ms_tmp = concat(ms_tmp,"  <pubDate>",ms_pub_dt_tm,"</pubDate>",char(10),
  "  <link>http://www.itriagehealth.com</link>",char(10),
  "  <category>iTriage Wait Time Directory</category>",char(10),
  "  <description>ED Wait Times for each of the facilities</description>",
  char(10),"  <language>en-us</language>",char(10),"  <ttl>15</ttl>",char(10),
  "  <item>",char(10),"    <title>",ms_facility,"</title>",
  char(10),"    <link>http://www.baystatehealth.org/edwaitftp/",ms_xml_file,"</link>",char(10),
  "    <category>Massachusetts</category>",char(10),"    <pubDate>",ms_pub_dt_tm,"</pubDate>",
  char(10),"    <description>",trim(cnvtstring(mf_avg_wait)),"</description>",char(10),
  "  </item>",char(10),"</channel>",char(10),"</rss>")
 CALL echo(ms_tmp)
 SELECT INTO value(ms_xml_file)
  FROM dummyt d
  HEAD REPORT
   col 0, ms_tmp
  WITH nocounter, maxcol = 1000
 ;end select
 IF (gl_bhs_prod_flag=1)
  SET mn_prod = 1
 ENDIF
 CALL echo(concat("prod ind: ",trim(cnvtstring(mn_prod))))
 IF (mn_prod=1)
  SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",ms_xml_file,
   " bsmobwebp01 edwaitftp waitEDftp1 edwaitftp")
  CALL echo(dclcom)
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
  SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",ms_xml_file,
   " zxswatmbwbpr01 edwaitftp waitEDftp1 edwaitftp")
  CALL echo(dclcom)
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
 ENDIF
 CALL pause(5)
 CALL echo("deleting email file")
 SET stat = remove(ms_xml_file)
 IF (((stat=0) OR (findfile(ms_xml_file)=1)) )
  CALL echo("unable to delete file")
 ELSE
  CALL echo("file deleted")
 ENDIF
 CALL echo(concat("avg wait: ",trim(cnvtstring(mf_avg_wait))))
 SET ms_tmp = concat(ms_facility," WAITS",char(13),"Avg wait calculation one with no adjustment: ",
  trim(cnvtstring(mf_avg_wait_orig)),
  char(13),char(13),"Official Avg wait to report out (2nd avg calc with adjustments)  : ",trim(
   cnvtstring(mf_avg_wait)),char(13),
  char(13),"Current patient info in calculation:",char(13),substring(1,6,"Wait"),substring(1,24,
   "Name"),
  substring(1,20,"Checkin"),substring(1,20,"Contact"),char(13))
 FOR (ml_loop = 1 TO size(m_rec->pat,5))
   IF ((((m_rec->pat[ml_loop].n_waiting=0)) OR ((((m_rec->pat[ml_loop].l_pat_wait >
   mf_tot_wait_done_only)) OR (size(m_rec->pat,5)=ml_waiting_pat_cnt)) )) )
    SET ms_tmp = concat(ms_tmp,format(m_rec->pat[ml_loop].l_wait,"###;P0"),"   ",substring(1,24,m_rec
      ->pat[ml_loop].s_name),char(13),
     "      checkin ",substring(1,14,m_rec->pat[ml_loop].s_checkin),"      contact ",substring(1,17,
      m_rec->pat[ml_loop].s_contact),char(13),
     char(13))
   ELSE
    SET ms_tmp = concat(ms_tmp,format(m_rec->pat[ml_loop].l_wait,"###;P0"),"   ",substring(1,24,m_rec
      ->pat[ml_loop].s_name),char(13),
     "      checkin ",substring(1,14,m_rec->pat[ml_loop].s_checkin),"      contact ",substring(1,17,
      m_rec->pat[ml_loop].s_contact),char(13),
     char(13))
   ENDIF
 ENDFOR
 IF (( $N_EMAIL=1))
  CALL uar_send_mail(nullterm("Rakesh.Talati@bhs.org"),nullterm(concat(ms_facility," ED Waits ",trim(
      format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(ms_tmp),nullterm("Prod"),1,
   nullterm("IPM.NOTE"))
 ENDIF
#exit_script
 IF (( $N_EMAIL=1))
  IF (ms_facility="BFMC")
   EXECUTE bhs_rss_ed_wait_times2 "nl:", "BMLH", 1,
   0
  ELSEIF (ms_facility="BMLH")
   EXECUTE bhs_rss_ed_wait_times2 "nl:", "BMC", 1,
   0
  ENDIF
 ENDIF
 SET reply->status_data[1].status = "S"
 CALL bhs_sbr_log("log","",0,"avg_wait",mf_avg_wait,
  ms_facility,"Avg Wait in Mins",reply->status_data[1].status)
 CALL bhs_sbr_log("stop","",0,"",0.0,
  concat("Average Wait"),concat(ms_facility,": ",ms_pub_dt_tm,": ",trim(cnvtstring(mf_avg_wait)),
   " mins"),reply->status_data[1].status)
END GO
