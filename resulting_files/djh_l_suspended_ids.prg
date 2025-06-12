CREATE PROGRAM djh_l_suspended_ids
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.username, p.name_full_formatted, p.position_cd,
  p_position_disp = uar_get_code_display(p.position_cd), p.updt_dt_tm, p.updt_id
  FROM prsnl p
  WHERE p.active_status_cd=194
  ORDER BY p.updt_dt_tm, p.username
  HEAD PAGE
   col 1, "ln", col 10,
   "Act", col 31, "LogIn",
   col 147, "Change", row + 1,
   col 1, "nbr", col 10,
   "ID", col 15, "Stat Code",
   col 31, " ID", col 46,
   "User Name", col 84, "Position Code & Description",
   col 127, "Update / Time", col 147,
   "  ID", row + 1, col 1,
   "---------+---------+---------+---------+---------+---------+---------+---------+", col + 0,
   "---------+---------+---------+---------+---------+---------+---------+---------+",
   row + 1
  DETAIL
   fupdtm = format(p.updt_dt_tm,"@SHORTDATETIME"), lncnt = (lncnt+ 1), col 1,
   lncnt"####", col + 3, p.active_ind"#",
   col + 1, p.active_status_cd"###", col + 1,
   p_active_status_disp"############", col + 1, p.username"###############",
   col + 1, p.name_full_formatted"###################################", col + 1,
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
  WITH maxrec = 100000, maxcol = 162, maxrow = 66,
   seperator = " ", format
 ;end select
END GO
