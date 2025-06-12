CREATE PROGRAM bhs_rpt_pc_usage:dba
 FREE RECORD t_record
 RECORD t_record(
   1 user_cnt = i4
   1 user_qual[*]
     2 user_id = f8
     2 user_name = vc
 )
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE t_line = vc
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind=1
    AND p.active_status_cd=active_cd
    AND p.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND p.username != null)
  ORDER BY p.person_id
  HEAD p.person_id
   t_record->user_cnt = (t_record->user_cnt+ 1)
   IF (mod(t_record->user_cnt,1000)=1)
    stat = alterlist(t_record->user_qual,(t_record->user_cnt+ 999))
   ENDIF
   t_record->user_qual[t_record->user_cnt].user_id = p.person_id, t_record->user_qual[t_record->
   user_cnt].user_name = p.username
  FOOT REPORT
   stat = alterlist(t_record->user_qual,t_record->user_cnt)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "pc_usage_rpt.xls"
  FROM (dummyt d  WITH seq = t_record->user_cnt),
   omf_app_ctx_day_st o,
   prsnl p
  PLAN (d)
   JOIN (o
   WHERE (o.person_id=t_record->user_qual[d.seq].user_id)
    AND ((o.application_number+ 0)=600005))
   JOIN (p
   WHERE p.person_id=o.person_id)
  ORDER BY p.name_full_formatted, p.person_id, o.start_day DESC
  HEAD REPORT
   t_line = "Power Chart Usage Report", col 0, t_line,
   row + 1, t_line = concat("Name",char(9),"Username",char(9),"Position",
    char(9),"Physician Ind",char(9),"Account Begin Effective Date",char(9),
    "Last Power Chart Login",char(9),"Person ID"), col 0,
   t_line, row + 1
  HEAD p.person_id
   t_line = concat(p.name_full_formatted,char(9),p.username,char(9),uar_get_code_display(p
     .position_cd),
    char(9),trim(cnvtstring(p.physician_ind)),char(9),format(p.beg_effective_dt_tm,"mm-dd-yyyy;;q"),
    char(9),
    format(o.start_day,"mm-dd-yyyy;;q"),char(9),trim(cnvtstring(p.person_id))), col 0, t_line,
   row + 1
  WITH maxcol = 1000, formfeed = none
 ;end select
 SELECT INTO "pco_usage_rpt.xls"
  FROM (dummyt d  WITH seq = t_record->user_cnt),
   omf_app_ctx_day_st o,
   prsnl p
  PLAN (d)
   JOIN (o
   WHERE (o.person_id=t_record->user_qual[d.seq].user_id)
    AND ((o.application_number+ 0)=961000))
   JOIN (p
   WHERE p.person_id=o.person_id)
  ORDER BY p.name_full_formatted, p.person_id, o.start_day DESC
  HEAD REPORT
   t_line = "Power Chart Office Usage Report", col 0, t_line,
   row + 1, t_line = concat("Name",char(9),"Username",char(9),"Position",
    char(9),"Physician Ind",char(9),"Account Begin Effective Date",char(9),
    "Last Power Chart Login",char(9),"Person ID"), col 0,
   t_line, row + 1
  HEAD p.person_id
   t_line = concat(p.name_full_formatted,char(9),p.username,char(9),uar_get_code_display(p
     .position_cd),
    char(9),trim(cnvtstring(p.physician_ind)),char(9),format(p.beg_effective_dt_tm,"mm-dd-yyyy;;q"),
    char(9),
    format(o.start_day,"mm-dd-yyyy;;q"),char(9),trim(cnvtstring(p.person_id))), col 0, t_line,
   row + 1
  WITH maxcol = 1000, formfeed = none
 ;end select
 DECLARE dclcom = vc
 IF (findfile("pc_usage_rpt.xls")=1
  AND findfile("pco_usage_rpt.xls")=1)
  SET dclcom = "gzip pc_usage_rpt.xls"
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET dclcom = "gzip pco_usage_rpt.xls"
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET email_list = "anthony.jacobson@bhs.org"
  SET subject_line = "Power Chart PN Usage Reports"
  SET dclcom = concat('echo " " | mailx -s "',subject_line,'" ','-a "pc_usage_rpt.xls.gz" ',
   '-a "pco_usage_rpt.xls.gz" ',
   email_list)
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET stat = remove("pc_usage_rpt.xls")
  SET stat = remove("pco_usage_rpt.xls")
  SET stat = remove("pc_usage_rpt.xls.gz")
  SET stat = remove("pco_usage_rpt.xls.gz")
 ENDIF
END GO
