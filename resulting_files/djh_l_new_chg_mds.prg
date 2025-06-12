CREATE PROGRAM djh_l_new_chg_mds
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  p.active_ind, p.physician_ind, p.name_full_formatted,
  p.beg_effective_dt_tm, p.end_effective_dt_tm, p.updt_dt_tm,
  p.position_cd, p_position_disp = uar_get_code_display(p.position_cd), p.username,
  p.person_id, p.updt_id
  FROM prsnl p
  PLAN (p
   WHERE p.physician_ind=1
    AND p.active_ind=1
    AND p.position_cd > 0
    AND p.position_cd != 441
    AND p.position_cd != 786870
    AND p.position_cd != 686743
    AND p.username > " "
    AND p.username != "SI*"
    AND p.updt_dt_tm >= cnvtdatetime((curdate - 8),0)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,0))
  ORDER BY p.name_full_formatted
  HEAD PAGE
   col 30, "Weekly New / Change Physician CIS ID Report", row + 2,
   col 6, "log-in", col 55,
   "Begin     Change     End     Physician", row + 1, col 1,
   " ln    ID", col 23, "Physician Name                   Date      Date      Date    Position",
   row + 1, col 1, "---------+---------+---------+---------+---------+---------+---------+---------+",
   col + 0, "---------+---------+---------+---------+---------+---------+---------+---------+", row
    + 1
  DETAIL
   lncnt = (lncnt+ 1), col + 1, lncnt"###",
   col + 2, p.username"###############", col + 2,
   p.name_full_formatted"#############################", col + 2, p.beg_effective_dt_tm,
   col + 2, p.updt_dt_tm, col + 2,
   p.end_effective_dt_tm, col + 2, p_position_disp,
   row + 1
   IF (row > 60)
    BREAK
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 130,
   "Page:", curpage
  WITH maxrec = 20, maxcol = 162, maxrow = 66,
   seperator = " ", format
 ;end select
END GO
