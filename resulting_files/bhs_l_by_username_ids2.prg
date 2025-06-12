CREATE PROGRAM bhs_l_by_username_ids2
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
  p.test_vc
  FROM prsnl p
  WHERE ((p.username="Z99999999x") OR (((p.username="EN60510") OR (((p.username="EN67135") OR (((p
  .username="SN77464") OR (((p.username="EN96210") OR (((p.username="SN70458") OR (((p.username=
  "EN68302") OR (((p.username="EN63999Y0612") OR (((p.username="EN79653") OR (((p.username="EN70985")
   OR (((p.username="EN69111") OR (((p.username="EN71782") OR (((p.username="EN97559") OR (((p
  .username="EN69114") OR (((p.username="SN97560") OR (((p.username="EN91786") OR (((p.username=
  "SN99163") OR (((p.username="EN90961") OR (((p.username="EN71710") OR (((p.username="EN63016") OR (
  ((p.username="EN64566") OR (((p.username="EN70869") OR (((p.username="EN70553") OR (((p.username=
  "EN70710") OR (((p.username="SN70345") OR (((p.username="SN60069") OR (((p.username="EN76983") OR (
  ((p.username="SN50610") OR (((p.username="SN96200") OR (p.username="SN50068")) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  ORDER BY p.username
  HEAD PAGE
   col 1, " ln", col 8,
   "Act", col 12, "Stat",
   col 20, "LogIn", col 111,
   "  END Eff", col 148, "Change",
   row + 1, col 1, " nbr",
   col 8, "ID", col 12,
   "Code", col 20, " ID",
   col 34, "User Name", col 67,
   "Position Code & Description", col 111, "Date / Time",
   col 129, "Update / Time", col 148,
   "  ID", row + 1, col 1,
   "---------+---------+---------+---------+---------+---------+---------+---------+", col + 0,
   "---------+---------+---------+---------+---------+---------+---------+-------",
   row + 1
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
   namefull30, col + 0, p.position_cd"##########",
   col + 1, p_position_disp"################################", col + 1,
   fenddtm, col + 2, fupdtm,
   col + 1, p.updt_id"##########", row + 1
   IF (row > 60)
    BREAK
   ENDIF
   IF (curnode="casatest")
    xdomain = "BUILD"
   ENDIF
   IF (curnode="casbtest")
    xdomain = "CERT"
   ENDIF
   IF (((curnode="cis1") OR (((curnode="cis3") OR (curnode="cis5")) )) )
    xdomain = "PROD"
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
