CREATE PROGRAM bhs_l_by_pid
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
  p.test_vc, p.name_last, p.name_last_key
  FROM prsnl p
  WHERE ((p.person_id=754400) OR (p.name_last_key="UNKNOWN"))
   AND p.active_status_cd=188
  ORDER BY p.username
  HEAD PAGE
   col 1, " ln", col 8,
   "Act", col 12, "Stat",
   col 20, "LogIn", col 67,
   "Person", row + 1, col 1,
   " nbr", col 8, "ID",
   col 12, "Code", col 20,
   " ID", col 34, "User Name",
   col 67, "  ID", col 75,
   "p.name_last", col 96, "p.name_last_key",
   row + 1, col 1, "---------+---------+---------+---------+---------+---------+---------+---------+",
   col + 0, "---------+---------+---------+---------+---------+---------+---------+-------", row + 1
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
   namefull30, col + 0, p.person_id"##########",
   col + 1, p.name_last"####################", col + 1,
   p.name_last_key"####################", row + 1
   IF (row > 60)
    BREAK
   ENDIF
   IF (curnode="casDtest")
    xdomain = "BUILD"
   ENDIF
   IF (curnode="casbtest")
    xdomain = "CERT"
   ENDIF
   IF (((curnode="cis1") OR (((curnode="cis3") OR (curnode="cis5")) )) )
    xdomain = "PROD"
   ENDIF
   IF (curnode="cismock1")
    xdomain = "MOCK"
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 90,
   curnode, col 100, xdomain,
   col 130, "Page:", curpage
  WITH maxrec = 1000, maxcol = 160, maxrow = 66,
   seperator = " ", format
 ;end select
END GO
