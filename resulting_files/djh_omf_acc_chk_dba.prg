CREATE PROGRAM djh_omf_acc_chk:dba
 PROMPT
  "Days Back" = 30,
  "Output to File/Printer/MINE" = "MINE"
  WITH prompt3, outdev
 SET lncnt = 0
 SET daysback =  $PROMPT3
 SELECT INTO  $OUTDEV
  o.person_id, p_position_disp = uar_get_code_display(p.position_cd)
  FROM omf_app_ctx_day_st o,
   application a,
   prsnl p
  PLAN (o
   WHERE ((o.person_id=19564751) OR (o.person_id=945864))
    AND o.start_day > cnvtdatetime((curdate - daysback),0))
   JOIN (a
   WHERE o.application_number=a.application_number)
   JOIN (p
   WHERE o.person_id=p.person_id)
  ORDER BY p.person_id, o.start_day DESC
  HEAD PAGE
   col 10, "Person_ID:", o.person_id"##########",
   col 35, p.username"################", col + 1,
   p.name_full_formatted"##############################", col 100, "Last ",
   daysback, " days", row + 1,
   col 10, "CIS Position Assigned:", col 33,
   p.position_cd"############", col 52, p_position_disp,
   row + 2, col 1, " ln",
   col 9, " APPL", col 113,
   "Log", col 26, " LogIn",
   col 119, "Time", row + 1,
   col 1, " nbr", col 9,
   "NUMBER", col 20, "Application Description",
   col 67, "Object Name", col 104,
   "Freq", col 113, "Ins",
   col 118, "(mins)", col 127,
   "Date", row + 1, col 1,
   "---------+---------+---------+---------+---------+---------+---------+---------+", col + 0,
   "---------+---------+---------+---------+---------+---------+---------+---------+",
   row + 1
  DETAIL
   lncnt = (lncnt+ 1), col 1, lncnt"####",
   col 5, o.application_number"##########", col 16,
   a.description"##################################################", col + 1, a.object_name
   "##############################",
   col + 1, o.frequency, col + 2,
   o.log_ins"#####", col + 2, o.minutes"#####",
   col + 2, o.start_day"mm-dd-yyyy", row + 1
   IF (row >= 60)
    BREAK
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 130,
   "Page:", curpage
  WITH maxcol = 162, maxrow = 66, seperator = " ",
   format
 ;end select
END GO
