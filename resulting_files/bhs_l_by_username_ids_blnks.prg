CREATE PROGRAM bhs_l_by_username_ids_blnks
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
  WHERE p.position_cd <= 0
   AND ((p.username="Z99999999x") OR (((p.username="EN45689") OR (((p.username="EN00867") OR (((p
  .username="PN53634") OR (((p.username="EN04808") OR (((p.username="EN08513") OR (((p.username=
  "EN41463") OR (((p.username="EN42450") OR (((p.username="EN47605") OR (((p.username="EN03033") OR (
  ((p.username="EN05820") OR (((p.username="EN40986") OR (((p.username="EN00368") OR (((p.username=
  "EN43823") OR (((p.username="EN41648") OR (((p.username="PN53644") OR (((p.username="EN45339") OR (
  ((p.username="EN07181") OR (((p.username="EN46170") OR (((p.username="EN47651") OR (((p.username=
  "EN47546") OR (((p.username="EN47708") OR (((p.username="EN09250") OR (((p.username="EN07947") OR (
  ((p.username="EN45823") OR (((p.username="EN01613") OR (((p.username="EN47775") OR (((p.username=
  "EN02398") OR (((p.username="EN06941") OR (((p.username="EN44508") OR (((p.username="EN47243") OR (
  ((p.username="EN02029") OR (((p.username="EN02558") OR (((p.username="EN04901") OR (((p.username=
  "EN43444") OR (((p.username="EN43728") OR (((p.username="EN44481") OR (((p.username="EN44175") OR (
  ((p.username="EN00592") OR (((p.username="EN46379") OR (((p.username="EN20965") OR (((p.username=
  "EN41897") OR (((p.username="EN07023") OR (((p.username="EN08815") OR (((p.username="EN40461") OR (
  ((p.username="EN47797") OR (((p.username="EN45968") OR (((p.username="EN47557") OR (((p.username=
  "EN47371") OR (((p.username="EN02264") OR (((p.username="EN40967") OR (((p.username="EN42698") OR (
  ((p.username="EN43724") OR (((p.username="EN02647") OR (((p.username="EN43720") OR (((p.username=
  "EN46060") OR (((p.username="EN47087") OR (((p.username="EN08050") OR (((p.username="EN47619") OR (
  ((p.username="EN04599") OR (((p.username="EN04763") OR (((p.username="EN40474") OR (((p.username=
  "EN06571") OR (((p.username="EN47300") OR (((p.username="EN41507") OR (((p.username="EN46988") OR (
  ((p.username="EN44825") OR (((p.username="EN46784") OR (((p.username="EN47646") OR (((p.username=
  "EN43979") OR (((p.username="EN42635") OR (((p.username="EN43583") OR (((p.username="EN47370") OR (
  ((p.username="EN02266") OR (((p.username="EN46428") OR (((p.username="EN04628") OR (((p.username=
  "EN44077") OR (((p.username="EN04219") OR (((p.username="EN26767") OR (((p.username="EN05781") OR (
  ((p.username="EN40206") OR (((p.username="EN47204") OR (((p.username="EN47360") OR (((p.username=
  "EN47200") OR (((p.username="EN43939") OR (((p.username="EN47458") OR (((p.username="EN48756") OR (
  ((p.username="PN55306") OR (((p.username="EN43521") OR (((p.username="EN11185") OR (((p.username=
  "EN00714") OR (((p.username="PN53015") OR (p.username="EN46736")) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   AND p.active_status_cd=188
  ORDER BY p.username
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
   col 75, "Position Description", col 111,
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
   namefull30, col + 0, p.person_id"##########",
   col + 1, p_position_disp"################################", col + 1,
   fenddtm, col + 2, fupdtm,
   col + 1, p.updt_id"##########", row + 1
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
