CREATE PROGRAM djh_l_email_chk
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
  p.email, p.test_vc
  FROM prsnl p
  WHERE p.email > " "
   AND p.active_status_cd=188
  ORDER BY p.name_full_formatted
  HEAD PAGE
   col 1, " ln", col 8,
   "Act", col 12, "Stat",
   col 20, "LogIn", row + 1,
   col 1, " nbr", col 8,
   "ID", col 12, "Code",
   col 20, " ID", col 34,
   "User Name", col 70, "eMail Address",
   col 138, "Update / Time", row + 1,
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
    physflg = "*"
   ELSE
    physflg = " "
   ENDIF
   ousername15 = format(p.username,"###############"), namefull30 = format(p.name_full_formatted,
    "##############################"), fupdtm = format(p.updt_dt_tm,"@SHORTDATETIME"),
   fenddtm = format(p.end_effective_dt_tm,"@SHORTDATETIME"), col 1, lncnt"####",
   col + 3, p.active_ind"##", col + 2,
   p.active_status_cd"###", col + 2, physflg"##",
   col + 0, ousername15, col + 0,
   namefull30, col 70, p.email"############################################################",
   col 138, fupdtm, row + 1
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
  WITH maxcol = 160, maxrow = 66, seperator = " ",
   format
 ;end select
END GO
