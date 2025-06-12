CREATE PROGRAM bhs_pc_users:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE disp_line = vc
 SELECT INTO "bhs_pc_users"
  p.name_full_formatted, p.username, p_position_disp = uar_get_code_display(p.position_cd),
  o.start_day, p.active_ind, app =
  IF (o.application_number=600005) "PowerChart"
  ENDIF
  ,
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.beg_effective_dt_tm, p
  .end_effective_dt_tm
  FROM prsnl p,
   omf_app_ctx_day_st o
  PLAN (p
   WHERE p.active_ind=1
    AND p.username > " "
    AND p.end_effective_dt_tm > sysdate
    AND  NOT (p.position_cd IN (441, 457, 786870, 686743, 777650)))
   JOIN (o
   WHERE o.person_id=p.person_id
    AND o.application_number=600005)
  ORDER BY p.name_full_formatted, o.start_day DESC
  HEAD REPORT
   disp_line = build2("Name",char(9),"UserName",char(9),"Position",
    char(9),"CIS ID",char(9),"Application",char(9),
    "Last Login",char(9),"Acc date",char(9)), col 0, disp_line,
   row + 1
  HEAD p.name_full_formatted
   row + 0
  HEAD o.start_day
   d = format(o.start_day,"mm/dd/yy;;d"), d2 = format(p.beg_effective_dt_tm,"mm/dd/yy;;d"), disp_line
    = build2(p.name_full_formatted,char(9),p.username,char(9),p_position_disp,
    char(9),p.person_id,char(9),app,char(9),
    d,char(9),d2,char(9)),
   col 0, disp_line, row + 1
  WITH maxcol = 1000, formfeed = none
 ;end select
 EXECUTE bhs_ma_email_file
 SET email_list = "naser.sanjar2@bhs.org"
 SET subject_line = "PowerChart Usage Report "
 CALL emailfile("bhs_pc_users.dat","bhs_pc_users.csv",email_list,subject_line,1)
END GO
