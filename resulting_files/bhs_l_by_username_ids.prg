CREATE PROGRAM bhs_l_by_username_ids
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 DECLARE test_vc = vc WITH noconstant(""), protect
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  p.active_ind, p.username, p.active_status_cd,
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.position_cd, p_position_disp =
  uar_get_code_display(p.position_cd),
  p.end_effective_dt_tm, p.updt_dt_tm, p.updt_id,
  p.test_vc
  FROM prsnl p
  WHERE ((p.username="Z99999999x") OR (((p.username="*60544") OR (((p.username="*60545") OR (((p
  .username="*60546") OR (((p.username="*60547") OR (((p.username="*60551") OR (((p.username="*60554"
  ) OR (((p.username="*60564") OR (((p.username="*60565") OR (((p.username="*60568") OR (((p.username
  ="*60569") OR (((p.username="*60571") OR (((p.username="*60579") OR (((p.username="*60580") OR (((p
  .username="*60581") OR (((p.username="*60582") OR (((p.username="*60583") OR (((p.username="*60584"
  ) OR (((p.username="*60585") OR (((p.username="*60586") OR (((p.username="*60587") OR (((p.username
  ="*60588") OR (((p.username="*60591") OR (((p.username="*60594") OR (((p.username="*60595") OR (((p
  .username="*60596") OR (((p.username="*60597") OR (((p.username="*60598") OR (((p.username="*60601"
  ) OR (((p.username="*60602") OR (((p.username="*60604") OR (((p.username="*60606") OR (((p.username
  ="*60610") OR (((p.username="*60611") OR (((p.username="*60615") OR (((p.username="*60618") OR (((p
  .username="*60619") OR (((p.username="*60625") OR (((p.username="*60627") OR (((p.username="*60628"
  ) OR (((p.username="*60629") OR (((p.username="*60630") OR (((p.username="*60633") OR (((p.username
  ="*60638") OR (((p.username="*60645") OR (((p.username="*60646") OR (((p.username="*60647") OR (((p
  .username="*60666") OR (((p.username="*60667") OR (((p.username="*60683") OR (((p.username="*60687"
  ) OR (((p.username="*60693") OR (((p.username="*60695") OR (((p.username="*60696") OR (((p.username
  ="*60698") OR (((p.username="*60699") OR (((p.username="*60700") OR (((p.username="*60701") OR (((p
  .username="*60702") OR (((p.username="*60703") OR (((p.username="*60704") OR (((p.username="*60705"
  ) OR (((p.username="*60706") OR (((p.username="*60707") OR (((p.username="*60708") OR (((p.username
  ="*60710") OR (((p.username="*60711") OR (((p.username="*60712") OR (((p.username="*60715") OR (((p
  .username="*60716") OR (((p.username="*60718") OR (((p.username="*60719") OR (((p.username="*60720"
  ) OR (((p.username="*60721") OR (((p.username="*60727") OR (((p.username="*60728") OR (((p.username
  ="*60732") OR (((p.username="*60737") OR (((p.username="*60738") OR (((p.username="*60745") OR (((p
  .username="*60751") OR (((p.username="*60752") OR (((p.username="*60756") OR (((p.username="*60759"
  ) OR (((p.username="*97354") OR (((p.username="*97355") OR (((p.username="*97356") OR (((p.username
  ="*97358") OR (((p.username="*97359") OR (((p.username="*97363") OR (((p.username="*97404") OR (((p
  .username="*97406") OR (((p.username="*97416") OR (((p.username="*97420") OR (((p.username="*97433"
  ) OR (((p.username="*97437") OR (((p.username="*97449") OR (((p.username="*97451") OR (((p.username
  ="*97460") OR (p.username="*97473")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) ))
   AND p.username != "RF*"
   AND p.username != "TERMMSOPN6089*"
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
    xdomain = "PROD"
   ELSEIF (curnode="casDtest")
    xdomain = "BUILD"
   ELSEIF (curnode="casbtest")
    xdomain = "CERT"
   ELSEIF (curnode="cismock1")
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
