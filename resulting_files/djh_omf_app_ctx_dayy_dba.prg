CREATE PROGRAM djh_omf_app_ctx_dayy:dba
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
   WHERE ((o.person_id=754400) OR (((o.person_id=748565) OR (((o.person_id=6599000) OR (((o.person_id
   =6598999) OR (((o.person_id=748740) OR (((o.person_id=928964) OR (((o.person_id=849478) OR (((o
   .person_id=849527) OR (((o.person_id=749174) OR (((o.person_id=18165192) OR (((o.person_id=
   18085243) OR (((o.person_id=749489) OR (((o.person_id=749552) OR (((o.person_id=749557) OR (((o
   .person_id=749694) OR (((o.person_id=749730) OR (((o.person_id=749795) OR (((o.person_id=6543993)
    OR (((o.person_id=19288558) OR (((o.person_id=751273) OR (((o.person_id=6598993) OR (((o
   .person_id=750144) OR (((o.person_id=750150) OR (((o.person_id=750198) OR (((o.person_id=750223)
    OR (((o.person_id=18233198) OR (((o.person_id=750391) OR (((o.person_id=750437) OR (((o.person_id
   =13366872) OR (((o.person_id=750470) OR (((o.person_id=750472) OR (((o.person_id=750473) OR (((o
   .person_id=928947) OR (((o.person_id=750569) OR (((o.person_id=2366404) OR (((o.person_id=750702)
    OR (((o.person_id=750764) OR (((o.person_id=750864) OR (((o.person_id=18736778) OR (((o.person_id
   =13366871) OR (((o.person_id=751091) OR (((o.person_id=3866502) OR (o.person_id=6015426)) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) ))
    AND o.start_day > cnvtdatetime((curdate - daysback),0))
   JOIN (a
   WHERE o.application_number=a.application_number
    AND a.application_number != 3071000)
   JOIN (p
   WHERE o.person_id=p.person_id)
  ORDER BY o.person_id, o.start_day DESC
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
  HEAD o.person_id
   BREAK
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
