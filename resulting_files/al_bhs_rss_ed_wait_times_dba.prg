CREATE PROGRAM al_bhs_rss_ed_wait_times:dba
 PROMPT
  "Facility" = ""
  WITH s_facility
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 DECLARE ms_facility = vc WITH protect, constant(cnvtupper(trim( $S_FACILITY)))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ms_xml_file = vc WITH protect, constant(concat(cnvtlower(ms_facility),"_ed_avg_wait.xml"))
 DECLARE mf_facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_doc_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_pub_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_day_of_week = vc WITH protect, noconstant(" ")
 DECLARE mf_avg_wait = f8 WITH protect, noconstant(0.0)
 DECLARE dclcom = vc WITH protect, noconstant("")
 IF (ms_facility="BMLH")
  SET mf_facility_cd = uar_get_code_by("DISPLAYKEY",16370,"BMLHEDTRACKINGGROUP")
 ELSEIF (ms_facility="BFMC")
  SET mf_facility_cd = uar_get_code_by("DISPLAYKEY",16370,"BFMCEDTRACKINGGROUP")
 ELSEIF (ms_facility="BWH")
  SET mf_facility_cd = uar_get_code_by("DISPLAYKEY",16370,"BWHEDTRACKINGGROUP")
 ELSEIF (ms_facility="BNH")
  SET mf_facility_cd = uar_get_code_by("DISPLAYKEY",16370,"BNHEDTRACKINGGROUP")
 ENDIF
 IF (mf_facility_cd <= 0)
  GO TO exit_script
 ENDIF
 SET ms_end_dt_tm = trim(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
 SET ms_beg_dt_tm = trim(format(cnvtlookbehind("1,H",cnvtdatetime(ms_end_dt_tm)),
   "dd-mmm-yyyy hh:mm:ss;;d"))
 SELECT INTO "nl:"
  tc.checkin_dt_tm, tracking_event_type = uar_get_code_display(tc.tracking_event_type_cd), tre
  .display
  FROM tracking_checkin tc,
   tracking_event te,
   track_event tre,
   tracking_item ti,
   encntr_alias ea
  PLAN (tc
   WHERE tc.checkin_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND tc.tracking_group_cd=mf_facility_cd
    AND tc.active_ind=1)
   JOIN (te
   WHERE te.tracking_id=tc.tracking_id
    AND te.active_ind=1)
   JOIN (tre
   WHERE tre.track_event_id=te.track_event_id
    AND tre.tracking_group_cd=tc.tracking_group_cd
    AND tre.active_ind=1
    AND tre.display_key="DOCASSIGN")
   JOIN (ti
   WHERE ti.tracking_id=te.tracking_id)
   JOIN (ea
   WHERE ea.encntr_id=ti.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
  ORDER BY tc.tracking_checkin_id, tc.tracking_id, ea.alias,
   te.complete_dt_tm
  HEAD REPORT
   pl_cur_wait = 0, pl_tot_mins = 0, pl_cnt = 0
  HEAD tc.tracking_id
   ms_doc_dt_tm = ""
  DETAIL
   IF (ms_doc_dt_tm="")
    ms_doc_dt_tm = trim(format(te.complete_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
   ELSEIF (cnvtdatetime(ms_doc_dt_tm) > te.complete_dt_tm)
    ms_doc_dt_tm = trim(format(te.complete_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
   ENDIF
  FOOT  tc.tracking_id
   pl_cur_wait = datetimediff(cnvtdatetime(ms_doc_dt_tm),tc.checkin_dt_tm,4)
   IF (pl_cur_wait > 0)
    pl_cnt += 1, pl_tot_mins += pl_cur_wait
   ENDIF
  FOOT REPORT
   CALL echo(concat("count: ",trim(cnvtstring(pl_cnt))," tot mins: ",trim(cnvtstring(pl_tot_mins)))),
   mf_avg_wait = (cnvtreal(pl_tot_mins)/ cnvtreal(pl_cnt)),
   CALL echo(concat("avg wait: ",trim(cnvtstring(mf_avg_wait))," mins"))
  WITH nocounter
 ;end select
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
 SET ms_tmp = concat('<rss version = "2.0">',char(10),"<channel>",char(10),"  <title>",
  ms_facility," Wait Times</title>",char(10),"  <pubDate>",ms_pub_dt_tm,
  "</pubDate>",char(10),"  <link>http://www.itriagehealth.com</link>",char(10),
  "  <category>iTriage Wait Time Directory</category>",
  char(10),"  <description>ED Wait Times for each of the facilities</description>",char(10),
  "  <language>en-us</language>",char(10),
  "  <ttl>15</ttl>",char(10),"  <item>",char(10),"    <title>",
  ms_facility,"</title>",char(10),"    <link>http://www.baystatehealth.org/edwaitftp/",cnvtlower(
   ms_facility),
  "_ed_avg_wait.xml</link>",char(10),"    <category>Massachusetts</category>",char(10),
  "    <pubDate>",
  ms_pub_dt_tm,"</pubDate>",char(10),"    <description>",trim(cnvtstring(mf_avg_wait)),
  "</description>",char(10),"  </item>",char(10),"</channel>",
  char(10),"</rss>")
 CALL echo(ms_tmp)
 SELECT INTO value(ms_xml_file)
  FROM dummyt d
  HEAD REPORT
   col 0, ms_tmp
  WITH nocounter, maxcol = 1000
 ;end select
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
 CALL pause(5)
 CALL echo("deleting email file")
 SET stat = remove(ms_xml_file)
 IF (((stat=0) OR (findfile(ms_xml_file)=1)) )
  CALL echo("unable to delete file")
 ELSE
  CALL echo("file deleted")
 ENDIF
#exit_script
 SET reply->status_data[1].status = "S"
END GO
