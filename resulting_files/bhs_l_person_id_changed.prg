CREATE PROGRAM bhs_l_person_id_changed
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE test_vc = vc WITH noconstant(""), protect
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  p.active_ind, p.username, p.active_status_cd,
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.position_cd, p_position_disp =
  uar_get_code_display(p.position_cd),
  p.end_effective_dt_tm, p.updt_dt_tm, p.updt_id,
  p.test_vc, p.person_id
  FROM prsnl p
  WHERE ((p.username="Z99999999") OR (((p.person_id=748848) OR (((p.person_id=748849) OR (((p
  .person_id=749374) OR (((p.person_id=749810) OR (((p.person_id=750392) OR (((p.person_id=949372)
   OR (((p.person_id=751020) OR (((p.person_id=750399) OR (((p.person_id=749548) OR (((p.person_id=
  944649) OR (((p.person_id=941823) OR (((p.person_id=942618) OR (((p.person_id=5790196) OR (((p
  .person_id=5790274) OR (((p.person_id=5790396) OR (((p.person_id=5790446) OR (((p.person_id=946432)
   OR (((p.person_id=5790203) OR (((p.person_id=5790431) OR (((p.person_id=5790407) OR (((p.person_id
  =5790250) OR (((p.person_id=5790230) OR (((p.person_id=3547650) OR (((p.person_id=589851) OR (((p
  .person_id=950896) OR (((p.person_id=748527) OR (p.person_id=941755)) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  ORDER BY p.name_full_formatted
  HEAD PAGE
   col 1, " ln", col 8,
   "Act", col 12, "Stat",
   col 20, "LogIn", col 67,
   "Person", col 111, "  END Eff",
   col 148, "Change", row + 1,
   col 1, " nbr", col 8,
   "ID", col 12, "Code",
   col 20, " ID", col 34,
   "User Name", col 67, "  ID",
   col 74, "Position Description", col 111,
   "Date / Time", col 129, "Update / Time",
   col 148, "  ID", row + 1,
   col 1, "---------+---------+---------+---------+---------+---------+---------+---------+", col + 0,
   "---------+---------+---------+---------+---------+---------+---------+-------", row + 1
  DETAIL
   lncnt = (lncnt+ 1)
   IF (p.updt_id=99999999)
    test_vc = "Changed Active Access Codes"
   ELSE
    test_vc = "Not Changed"
   ENDIF
   IF (p.physician_ind=1)
    physflg = "**"
   ELSE
    physflg = " "
   ENDIF
   ousername15 = format(p.username,"###############"), namefull30 = format(p.name_full_formatted,
    "##############################"), fupdtm = format(p.updt_dt_tm,"@SHORTDATETIME"),
   fenddtm = format(p.end_effective_dt_tm,"@SHORTDATETIME"), col 1, lncnt"####",
   col + 3, p.active_ind"##", col + 2,
   p.active_status_cd"###", col + 2, physflg"##",
   col + 0, ousername15, col + 0,
   namefull30, col + 0, p.person_id"#########",
   col + 1, p_position_disp"################################", col + 1,
   fenddtm, col + 2, fupdtm,
   col + 1, p.updt_id"##########", row + 1
   IF (row > 60)
    BREAK
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 130,
   "Page:", curpage
  WITH maxrec = 1000, maxcol = 160, maxrow = 66,
   seperator = " ", format
 ;end select
END GO
