CREATE PROGRAM bhs_l_updt_id_754400
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = curdate,
  "End Date" = curdate
  WITH outdev, st_dt, end_dt
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.username, p.name_full_formatted, p.position_cd,
  p_position_disp = uar_get_code_display(p.position_cd), p.updt_dt_tm, p.updt_id
  FROM prsnl p
  WHERE p.updt_id=754400
   AND p.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate( $ST_DT),0) AND cnvtdatetime(cnvtdate( $END_DT),
   2400)
  ORDER BY p.name_full_formatted
  HEAD PAGE
   col 1, "ln", col 7,
   "Act", col 11, "   Stat",
   col 26, " LogIn", col 142,
   "Change", row + 1, col 1,
   "nbr", col 7, "ID",
   col 11, "Code/Desc", col 26,
   "  ID", col 41, "User Name",
   col 80, "Position Code & Description", col 122,
   "Update / Time", col 142, "  ID",
   row + 1, col 1, "---------+---------+---------+---------+---------+---------+---------+---------+",
   col + 0, "---------+---------+---------+---------+---------+---------+---------+", row + 1
  DETAIL
   fupdtm = format(p.updt_dt_tm,"@SHORTDATETIME"), lncnt = (lncnt+ 1)
   IF (p.physician_ind=1)
    physflg = "**"
   ELSE
    physflg = " "
   ENDIF
   col 1, lncnt"####", col + 3,
   p.active_ind"#", col + 1, p.active_status_cd"###",
   col + 1, p_active_status_disp"##########", col + 0,
   physflg"##", col + 0, p.username"###############",
   col + 0, p.name_full_formatted"###################################", col + 0,
   p.position_cd"##########", col + 1, p_position_disp"################################",
   col + 1, fupdtm, col + 1,
   p.updt_id"##########", row + 1
   IF (row > 60)
    BREAK
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 130,
   "Page:", curpage
  WITH maxrec = 10000, maxcol = 160, maxrow = 60,
   seperator = " ", format
 ;end select
END GO
