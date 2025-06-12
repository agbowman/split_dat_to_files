CREATE PROGRAM djh_l_by_nrsstd_act_ids
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 DECLARE ms_domain = vc WITH protect, noconstant("")
 DECLARE test_vc = vc WITH noconstant(""), protect
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  p.active_ind, p.username, p.active_status_cd,
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.position_cd, p_position_disp =
  uar_get_code_display(p.position_cd),
  p.end_effective_dt_tm, p.updt_dt_tm, p.updt_id,
  p.test_vc
  FROM prsnl p
  WHERE ((p.username="Z99999999x") OR (((p.username="*69381*") OR (((p.username="*68731*") OR (((p
  .username="*71346*") OR (((p.username="*68878*") OR (((p.username="*71347*") OR (((p.username=
  "*71348*") OR (((p.username="*71349*") OR (((p.username="*68875*") OR (((p.username="*68917*") OR (
  ((p.username="*71351*") OR (((p.username="*71352*") OR (((p.username="*68872*") OR (((p.username=
  "*68871*") OR (((p.username="*71354*") OR (((p.username="*71355*") OR (((p.username="*71358*") OR (
  ((p.username="*71403*") OR (((p.username="*71404*") OR (((p.username="*68855*") OR (((p.username=
  "*71406*") OR (((p.username="*71407*") OR (((p.username="*71408*") OR (((p.username="*61641*") OR (
  ((p.username="*64829*") OR (((p.username="*64812*") OR (((p.username="*71409*") OR (((p.username=
  "*71410*") OR (((p.username="*68591*") OR (((p.username="*71411*") OR (((p.username="*70199*") OR (
  ((p.username="*70197*") OR (((p.username="*60444*") OR (((p.username="*71412*") OR (((p.username=
  "*70195*") OR (((p.username="*71581*") OR (((p.username="*71413*") OR (((p.username="*71582*") OR (
  ((p.username="*71583*") OR (((p.username="*71584*") OR (((p.username="*71585*") OR (((p.username=
  "*71585*") OR (((p.username="*71587*") OR (((p.username="*71588*") OR (((p.username="*71737*") OR (
  ((p.username="*71589*") OR (((p.username="*71415*") OR (((p.username="*71590*") OR (((p.username=
  "*71414*") OR (((p.username="*71416*") OR (((p.username="*71591*") OR (((p.username="*71592*") OR (
  ((p.username="*71593*") OR (((p.username="*71462*") OR (((p.username="*71463*") OR (((p.username=
  "*71464*") OR (((p.username="*71594*") OR (((p.username="*71465*") OR (((p.username="*71595*") OR (
  ((p.username="*71466*") OR (((p.username="*71534*") OR (((p.username="*71467*") OR (((p.username=
  "*71706*") OR (((p.username="*71708*") OR (((p.username="*71469*") OR (((p.username="*71470*") OR (
  ((p.username="*71468*") OR (((p.username="*71709*") OR (((p.username="*71471*") OR (((p.username=
  "*71711*") OR (((p.username="*71472*") OR (((p.username="*71473*") OR (((p.username="*71712*") OR (
  ((p.username="*71474*") OR (((p.username="*71475*") OR (((p.username="*71476*") OR (((p.username=
  "*71713*") OR (((p.username="*71736*") OR (((p.username="*71521*") OR (((p.username="*71715*") OR (
  ((p.username="*71535*") OR (((p.username="*71522*") OR (((p.username="*71716*") OR (((p.username=
  "*71523*") OR (((p.username="*71524*") OR (((p.username="*71525*") OR (((p.username="*71528*") OR (
  ((p.username="*71526*") OR (((p.username="*71527*") OR (((p.username="*71529*") OR (((p.username=
  "*71717*") OR (((p.username="*71718*") OR (((p.username="*71721*") OR (((p.username="*71720*") OR (
  ((p.username="*71530*") OR (((p.username="*71531*") OR (((p.username="*71714*") OR (((p.username=
  "*71723*") OR (((p.username="*71532*") OR (p.username="*71533*")) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
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
   IF (gl_bhs_prod_flag=1)
    ms_domain = "PROD"
   ELSEIF (curnode="casdtest")
    ms_domain = "BUILD"
   ELSEIF (curnode="casbtest")
    ms_domain = "CERT"
   ELSE
    ms_domain = "domain?"
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 90,
   curnode, col 100, ms_domain,
   col 130, "Page:", curpage
  WITH maxrec = 1000, maxcol = 160, maxrow = 66,
   seperator = " ", format
 ;end select
END GO
