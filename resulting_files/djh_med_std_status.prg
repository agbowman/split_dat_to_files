CREATE PROGRAM djh_med_std_status
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 DECLARE ms_domain = vc WITH protect, noconstant("")
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.username, p.name_full_formatted,
  p_position_disp = uar_get_code_display(p.position_cd), p.beg_effective_dt_tm, p.end_effective_dt_tm,
  p.updt_dt_tm
  FROM prsnl p
  WHERE ((p.position_cd=777650
   AND p.active_status_cd=188) OR (p.position_cd=777650
   AND p.end_effective_dt_tm >= cnvtdatetime((curdate - 45),000)))
   AND p.username != "MEDICALSTUDENT"
   AND p.username != "VT*"
  ORDER BY p.username
  HEAD PAGE
   col 71, "                             1         1         1         1         1", col 141,
   "         1         1", row + 1, col 1,
   "         1         2         3         4         5         6         7", col 71,
   "         8         9         0         1         2         3         4",
   col 141, "         5         6", row + 1,
   col 1, "1234567890123456789012345678901234567890123456789012345678901234567890", col 71,
   "1234567890123456789012345678901234567890123456789012345678901234567890", col 141,
   "12345678901234567890",
   row + 1, col 1, "---------+---------+---------+---------+---------+---------+---------+---------+",
   col + 0, "---------+---------+---------+---------+---------+---------+---------+---------+", row
    + 1
  DETAIL
   lncnt = (lncnt+ 1)
   IF (p.physician_ind=1)
    physflg = "**"
   ELSE
    physflg = " "
   ENDIF
   col 1, lncnt"####", col + 1,
   p_active_status_disp"##########", col + 0, physflg"##",
   col + 1, p.username"###############", col + 0,
   p.name_full_formatted"##############################", col + 1, p.beg_effective_dt_tm,
   row + 1
   IF (row > 60)
    BREAK
   ENDIF
   IF (gl_bhs_prod_flag=1)
    ms_domain = "PROD"
   ELSEIF (curnode="casdtest")
    ms_domain = "BUILD"
   ELSEIF (curnode="casbtest")
    ms_domain = "CERT"
   ELSEIF (curnode="casetest")
    ms_domain = "TEST"
   ELSE
    ms_domain = "? ? ?"
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 90,
   curnode, col 100, ms_domain,
   col 130, "Page:", curpage
  WITH maxrec = 10, maxcol = 162, maxrow = 66,
   seperator = " ", format
 ;end select
END GO
