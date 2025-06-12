CREATE PROGRAM bhs_l_updt_id_by_anybody
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, st_dt, end_dt
 SELECT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.username, p.name_full_formatted, p.position_cd,
  p_position_disp = uar_get_code_display(p.position_cd), p.updt_dt_tm, p.updt_id
  FROM prsnl p
  WHERE p.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate( $ST_DT),0) AND cnvtdatetime(cnvtdate( $END_DT),
   2400)
  ORDER BY p.username
  HEAD PAGE
   col 1, "Act", col 5,
   "Stat", col 20, "LogIn",
   col 136, "Change", row + 1,
   col 1, "ID", col 5,
   "Code", col 20, " ID",
   col 36, "User Name", col 75,
   "Position Code & Description", col 117, "Update / Time",
   col 136, "  ID", row + 1,
   col 1, "---------+---------+---------+---------+---------+---------+---------+---------+", col + 0,
   "---------+---------+---------+---------+---------+---------+---------+", row + 1
  DETAIL
   fupdtm = format(p.updt_dt_tm,"@SHORTDATETIME"), col 1, p.active_ind"#",
   col + 1, p.active_status_cd"###", col + 1,
   p_active_status_disp"############", col + 1, p.username"###############",
   col + 1, p.name_full_formatted"###################################", col + 0,
   p.position_cd"##########", col + 1, p_position_disp"################################",
   col + 1, fupdtm, col + 1,
   p.updt_id"##########", row + 1
  WITH maxrec = 10000, maxcol = 160, maxrow = 60,
   seperator = " ", format
 ;end select
END GO
