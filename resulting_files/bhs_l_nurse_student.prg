CREATE PROGRAM bhs_l_nurse_student
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "stdt" = curdate,
  "enddt" = curdate
  WITH outdev, stdt, enddt
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.username, p.name_full_formatted, p.position_cd,
  p_position_disp = uar_get_code_display(p.position_cd), p.updt_dt_tm, p.updt_id
  FROM prsnl p
  WHERE p.position_cd=457
   AND p.active_ind=1
   AND p.active_status_cd=188
   AND p.username != "NRSSTDTMPL"
   AND p.username != "NSGSTUDENT"
   AND p.username != "NURSESTUD"
   AND p.create_dt_tm BETWEEN cnvtdate( $STDT,0) AND cnvtdate( $ENDDT,235959)
  ORDER BY p.username
  HEAD PAGE
   col 45, "Position Code = 457 - Nursing Students", row + 2,
   col 1, "  ln", col 10,
   "Act", col 18, "Stat",
   col 30, "LogIn", col 78,
   " Begin", col 90, "  End",
   col 123, "Change", row + 1,
   col 1, "  nbr", col 10,
   "ID", col 18, "Code",
   col 30, " ID", col 42,
   "User Name", col 78, "  Date",
   col 90, "  Date", col 103,
   "Update / Time", col 123, "  ID",
   row + 1, col 1, "----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+",
   col + 0, "----+----+----+----+----+----+----+----+----+----+", row + 1
  DETAIL
   fbegddtm = format(p.beg_effective_dt_tm,"mm-dd-yyyy"), fenddtm = format(p.end_effective_dt_tm,
    "mm-dd-yyyy"), fupdtm = format(p.updt_dt_tm,"@SHORTDATETIME"),
   lncnt = (lncnt+ 1), col 1, lncnt"####",
   col 12, p.active_ind"#", col + 2,
   p.active_status_cd"###", col + 1, p_active_status_disp"#########",
   col + 1, p.username"############", col + 1,
   p.name_full_formatted"###################################", col + 1, fbegddtm,
   col + 2, fenddtm, col + 2,
   fupdtm, col + 1, p.updt_id"##########",
   row + 1
   IF (row > 54)
    BREAK
   ENDIF
  FOOT PAGE
   row + 5, col 1, "================================================================================",
   col + 0, "==================================================", row + 1,
   col 1, curprog, col 70,
   curdate, col 100, "Page:",
   curpage
  WITH maxrec = 10000, maxcol = 140, maxrow = 66,
   seperator = " ", format
 ;end select
END GO
