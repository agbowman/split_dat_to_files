CREATE PROGRAM bhs_l_by_lastname
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
  WHERE ((p.username="Z99999999x") OR (((p.name_last_key="LEONARD*"
   AND p.name_first_key="JASON*") OR (((p.name_last_key="ABERDALE*"
   AND p.name_first_key="KARA*") OR (((p.name_last_key="AUDET*"
   AND p.name_first_key="PENNY*") OR (((p.name_last_key="AUGUSTE*"
   AND p.name_first_key="DARNLEY*") OR (((p.name_last_key="BANG*"
   AND p.name_first_key="SAMANTHA*") OR (((p.name_last_key="BRETON*"
   AND p.name_first_key="KELLY*") OR (((p.name_last_key="CASSIDY*"
   AND p.name_first_key="ANDREA*") OR (((p.name_last_key="CLARK*"
   AND p.name_first_key="SARAH*") OR (((p.name_last_key="CONDE*"
   AND p.name_first_key="JENNIFER*") OR (((p.name_last_key="CRANSHAW*"
   AND p.name_first_key="ANGELA*") OR (((p.name_last_key="CROTEAU*"
   AND p.name_first_key="KRISTINE*") OR (((p.name_last_key="CUEVES*"
   AND p.name_first_key="LAISA-SHEILI*") OR (((p.name_last_key="CYR*"
   AND p.name_first_key="ILONA*") OR (((p.name_last_key="CZECH*"
   AND p.name_first_key="JOANNA*") OR (((p.name_last_key="DALEY*"
   AND p.name_first_key="DANIEL*") OR (((p.name_last_key="DELVALLE*"
   AND p.name_first_key="REBECCA*") OR (((p.name_last_key="DIAZ-ALBANO*"
   AND p.name_first_key="MARIA*") OR (((p.name_last_key="LAURENO*"
   AND p.name_first_key="AMY*") OR (((p.name_last_key="GONZALEZ*"
   AND p.name_first_key="CAROL*") OR (((p.name_last_key="GOODCHILD*"
   AND p.name_first_key="JENNIFER*") OR (((p.name_last_key="GRANFIELD*"
   AND p.name_first_key="CHELSEA*") OR (((p.name_last_key="HARRIS*"
   AND p.name_first_key="AALIYAH*") OR (((p.name_last_key="IANNELLO*"
   AND p.name_first_key="CATHERINE*") OR (((p.name_last_key="JACKSON*"
   AND p.name_first_key="CRYSTLE*") OR (((p.name_last_key="JAMES*"
   AND p.name_first_key="ROMA*") OR (((p.name_last_key="JANISIESKI*"
   AND p.name_first_key="RACHAEL*") OR (((p.name_last_key="JARRY*"
   AND p.name_first_key="ELIZABETH*") OR (((p.name_last_key="JAWORSKI*"
   AND p.name_first_key="SONIA*") OR (((p.name_last_key="JORGE*"
   AND p.name_first_key="JESSICA*") OR (((p.name_last_key="KEEFE*"
   AND p.name_first_key="HEIDI*") OR (((p.name_last_key="LAFLAMME*"
   AND p.name_first_key="TINA*") OR (((p.name_last_key="LAGA*"
   AND p.name_first_key="ASHLEY*") OR (((p.name_last_key="LASKEY*"
   AND p.name_first_key="STEPHANIE*") OR (((p.name_last_key="LEFEBVRE*"
   AND p.name_first_key="KELLY*") OR (((p.name_last_key="LEONARD*"
   AND p.name_first_key="IFEYINWA*") OR (((p.name_last_key="LITTLE*"
   AND p.name_first_key="KERRI*") OR (((p.name_last_key="MARTINS*"
   AND p.name_first_key="JENNIFER*") OR (((p.name_last_key="MONAST*"
   AND p.name_first_key="ANGELICA*") OR (((p.name_last_key="MORRIS*"
   AND p.name_first_key="SARAH*") OR (((p.name_last_key="SIANO (NANKIN)*"
   AND p.name_first_key="PATRICIA*") OR (((p.name_last_key="NEWTON*"
   AND p.name_first_key="LOIS*") OR (((p.name_last_key="NIVAR*"
   AND p.name_first_key="SHARON*") OR (((p.name_last_key="NTONI*"
   AND p.name_first_key="STEPHEN*") OR (((p.name_last_key="NUGENT*"
   AND p.name_first_key="AMANDA*") OR (((p.name_last_key="PHELPS*"
   AND p.name_first_key="NICOLE*") OR (((p.name_last_key="POLANCO*"
   AND p.name_first_key="SYLVIA*") OR (((p.name_last_key="POOL*"
   AND p.name_first_key="KARA*") OR (((p.name_last_key="PRYCE*"
   AND p.name_first_key="VONEEN*") OR (((p.name_last_key="QUENNEVILLE*"
   AND p.name_first_key="REBECCA*") OR (((p.name_last_key="ROSARIO*"
   AND p.name_first_key="JOANN*") OR (((p.name_last_key="RUSZCZYK*"
   AND p.name_first_key="AGATA*") OR (((p.name_last_key="SAWYER*"
   AND p.name_first_key="AMY*") OR (((p.name_last_key="SAYKIN*"
   AND p.name_first_key="DINA*") OR (((p.name_last_key="SAYKINA*"
   AND p.name_first_key="YELENA*") OR (((p.name_last_key="SHALYPINA*"
   AND p.name_first_key="MARYNA*") OR (((p.name_last_key="TAGARIELLO*"
   AND p.name_first_key="KACEE*") OR (((p.name_last_key="TANGUAY*"
   AND p.name_first_key="JESSICA*") OR (((p.name_last_key="THAO*"
   AND p.name_first_key="XAI*") OR (((p.name_last_key="THAYER*"
   AND p.name_first_key="JASON*") OR (((p.name_last_key="URSINI-THOMPSON*"
   AND p.name_first_key="LYNETTE*") OR (((p.name_last_key="WALKER*"
   AND p.name_first_key="AMANDA*") OR (((p.name_last_key="WHITING*"
   AND p.name_first_key="WILLIAM*") OR (((p.name_last_key="WILDE*"
   AND p.name_first_key="MICHAELA*") OR (((p.name_last_key="WRIGHT*"
   AND p.name_first_key="LORI-ANN*") OR (((p.name_last_key="ALICEA*"
   AND p.name_first_key="SONIA*") OR (((p.name_last_key="FERNANDES*"
   AND p.name_first_key="JESSICA*") OR (((p.name_last_key="DICKINSON*"
   AND p.name_first_key="STACEY*") OR (((p.name_last_key="WACHTA*"
   AND p.name_first_key="ANETA*") OR (((p.name_last_key="HOWELL*"
   AND p.name_first_key="EMILY*") OR (((p.name_last_key="ORTIZ*"
   AND p.name_first_key="ROSA*") OR (((p.name_last_key="EXANTUS*"
   AND p.name_first_key="MURIELLE*") OR (((p.name_last_key="RUANE*"
   AND p.name_first_key="STEFANI*") OR (((p.name_last_key="THURZ*"
   AND p.name_first_key="KIMBERLY*") OR (((p.name_last_key="MANTOLESKY*"
   AND p.name_first_key="KRISTEN*") OR (p.name_last_key="GETTIS*"
   AND p.name_first_key=" LINDSAY*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   AND p.position_cd=457
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
