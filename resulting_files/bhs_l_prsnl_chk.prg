CREATE PROGRAM bhs_l_prsnl_chk
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE test_vc = vc WITH noconstant(""), protect
 SELECT INTO  $OUTDEV
  p.active_ind, p.username, p.person_id,
  p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd), p.position_cd,
  p_position_disp = uar_get_code_display(p.position_cd), p.end_effective_dt_tm, p.updt_dt_tm,
  p.updt_id, p.test_vc
  FROM prsnl p
  WHERE ((p.username="Z99999999") OR (((p.username="*53033*") OR (((p.username="*53176*") OR (((p
  .username="*53465*") OR (p.username="*53306*")) )) )) ))
  ORDER BY p.username
  HEAD PAGE
   col 1, "Act", col 5,
   "Stat", col 15, "LogIn",
   col 108, "  END Eff", col 144,
   "Change", row + 1, col 1,
   "ID", col 5, "Code",
   col 15, " ID", col 29,
   "User Name", col 64, "Position Code & Description",
   col 108, "Date / Time", col 125,
   "Update / Time", col 144, "  ID",
   row + 1, col 1, "---------+---------+---------+---------+---------+---------+---------+---------+",
   col + 0, "---------+---------+---------+---------+---------+---------+---------+", row + 1
  DETAIL
   IF (p.updt_id=99999999)
    test_vc = "Changed Active Access Codes"
   ELSE
    test_vc = "Not Changed"
   ENDIF
   ousername15 = format(p.username,"###############"), namefull30 = format(p.name_full_formatted,
    "##############################"), fupdtm = format(p.updt_dt_tm,"@SHORTDATETIME"),
   fenddtm = format(p.end_effective_dt_tm,"@SHORTDATETIME"), col 1, p.active_ind"##",
   col + 2, p.active_status_cd"###", col + 5,
   ousername15, col + 1, namefull30,
   col + 0, p.person_id"##########", col + 1,
   p_position_disp"################################", col + 1, fenddtm,
   col + 2, fupdtm, col + 1,
   p.updt_id"##########", row + 1
  WITH maxrec = 1000, maxcol = 160, maxrow = 60,
   seperator = " ", format
 ;end select
END GO
