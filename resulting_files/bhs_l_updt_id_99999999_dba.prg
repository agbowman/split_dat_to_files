CREATE PROGRAM bhs_l_updt_id_99999999:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, st_dt, end_dt
 EXECUTE bhs_check_domain:dba
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.username, p.name_full_formatted, p.position_cd,
  p_position_disp = uar_get_code_display(p.position_cd), p.end_effective_dt_tm, p.updt_dt_tm,
  p.updt_id
  FROM prsnl p
  WHERE p.updt_id=99999999
   AND p.username != "Z99999999"
   AND p.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate( $ST_DT),0) AND cnvtdatetime(cnvtdate( $END_DT),
   2400)
   AND p.active_ind=1
  ORDER BY p.username
  HEAD PAGE
   col 1, " ln", col 7,
   "Act", col 11, "   Stat",
   col 116, " END", col 144,
   "Change", row + 1, col 1,
   " nbr", col 7, "ID",
   col 12, "Code/Desc", col 25,
   "Log  ID", col 44, "Person's Name",
   col 74, "Position Code & Description", col 116,
   "Eff-DT", col 125, "Update / Time",
   col 145, "ID", row + 1,
   col 1, "---------+---------+---------+---------+---------+---------+---------+---------+", col + 0,
   "---------+---------+---------+---------+---------+---------+---------+---------+", row + 1
  DETAIL
   fupdtm = format(p.updt_dt_tm,"@SHORTDATETIME"), fenddttm = format(p.end_effective_dt_tm,"mmddyy"),
   lncnt = (lncnt+ 1)
   IF (p.physician_ind=1)
    physflg = "*"
   ELSE
    physflg = " "
   ENDIF
   col 1, lncnt"####", col + 1,
   p.active_ind"#", col + 1, p.active_status_cd"###",
   col + 1, p_active_status_disp"##########", col 20,
   physflg"#", col + 0, p.username"####################",
   col 42, p.name_full_formatted"##############################", col + 0,
   p.position_cd"##########", col + 1, p_position_disp"################################",
   col + 1, fenddttm, col + 1,
   fupdtm, col + 1, p.updt_id"###########",
   row + 1
   IF (row > 60)
    BREAK
   ENDIF
   IF (gl_bhs_prod_flag=1)
    xdomain = "PROD"
   ELSEIF (curnode="casDtest")
    xdomain = "BUILD"
   ELSEIF (curnode="casbtest")
    xdomain = "CERT"
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 90,
   curnode, col 100, xdomain,
   col 130, "Page:", curpage
  WITH maxrec = 10000, maxcol = 162, maxrow = 66,
   seperator = " ", format
 ;end select
END GO
