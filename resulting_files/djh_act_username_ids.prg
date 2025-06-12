CREATE PROGRAM djh_act_username_ids
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
  WHERE ((p.username="Z99999999x") OR (((p.username="*50038*") OR (((p.username="*50077*") OR (((p
  .username="*50143*") OR (((p.username="*50270*") OR (((p.username="*50309*") OR (((p.username=
  "*50334*") OR (((p.username="*50380*") OR (((p.username="*50398*") OR (((p.username="*50428*") OR (
  ((p.username="*50429*") OR (((p.username="*50435*") OR (((p.username="*50462*") OR (((p.username=
  "*50473*") OR (((p.username="*50692*") OR (((p.username="*50693*") OR (((p.username="*50694*") OR (
  ((p.username="*50695*") OR (((p.username="*50696*") OR (((p.username="*51009*") OR (((p.username=
  "*51029*") OR (((p.username="*51031*") OR (((p.username="*51062*") OR (((p.username="*51082*") OR (
  ((p.username="*51155*") OR (((p.username="*51160*") OR (((p.username="*51278*") OR (((p.username=
  "*51283*") OR (((p.username="*51555*") OR (((p.username="*51559*") OR (((p.username="*53011*") OR (
  ((p.username="*53024*") OR (((p.username="*53033*") OR (((p.username="*53042*") OR (((p.username=
  "*53048*") OR (((p.username="*53062*") OR (((p.username="*53087*") OR (((p.username="*53095*") OR (
  ((p.username="*53096*") OR (((p.username="*53147*") OR (((p.username="*53151*") OR (((p.username=
  "*53153*") OR (((p.username="*53156*") OR (((p.username="*53162*") OR (((p.username="*53164*") OR (
  ((p.username="*53168*") OR (((p.username="*53179*") OR (((p.username="*53181*") OR (((p.username=
  "*53183*") OR (((p.username="*53186*") OR (((p.username="*53201*") OR (((p.username="*53202*") OR (
  ((p.username="*53243*") OR (((p.username="*53265*") OR (((p.username="*53268*") OR (((p.username=
  "*53272*") OR (((p.username="*53297*") OR (((p.username="*53306*") OR (((p.username="*53318*") OR (
  ((p.username="*53387*") OR (((p.username="*53397*") OR (((p.username="*53398*") OR (((p.username=
  "*53400*") OR (((p.username="*53402*") OR (((p.username="*53406*") OR (((p.username="*53409*") OR (
  ((p.username="*53422*") OR (((p.username="*53433*") OR (((p.username="*53451*") OR (((p.username=
  "*53452*") OR (((p.username="*53503*") OR (((p.username="*53532*") OR (((p.username="*53541*") OR (
  ((p.username="*53552*") OR (((p.username="*53574*") OR (((p.username="*53589*") OR (((p.username=
  "*53590*") OR (((p.username="*53593*") OR (((p.username="*53597*") OR (((p.username="*53601*") OR (
  ((p.username="*53634*") OR (((p.username="*53638*") OR (((p.username="*53644*") OR (((p.username=
  "*53668*") OR (((p.username="*53705*") OR (((p.username="*53714*") OR (((p.username="*53748*") OR (
  ((p.username="*53760*") OR (((p.username="*53834*") OR (((p.username="*54005*") OR (((p.username=
  "*54015*") OR (((p.username="*54083*") OR (((p.username="*54144*") OR (((p.username="*54169*") OR (
  ((p.username="*54263*") OR (((p.username="*54284*") OR (((p.username="*54339*") OR (((p.username=
  "*54367*") OR (((p.username="*54447*") OR (((p.username="*54599*") OR (((p.username="*54604*") OR (
  ((p.username="*54637*") OR (((p.username="*54869*") OR (((p.username="*54895*") OR (((p.username=
  "*54897*") OR (((p.username="*54898*") OR (((p.username="*54908*") OR (((p.username="*54910*") OR (
  ((p.username="*54912*") OR (((p.username="*54932*") OR (((p.username="*55003*") OR (((p.username=
  "*55040*") OR (((p.username="*55050*") OR (((p.username="*55051*") OR (((p.username="*55206*") OR (
  ((p.username="*55208*") OR (((p.username="*55228*") OR (((p.username="*55328*") OR (((p.username=
  "*55480*") OR (((p.username="*55482*") OR (((p.username="*55485*") OR (((p.username="*55486*") OR (
  ((p.username="*55493*") OR (((p.username="*55533*") OR (((p.username="*55551*") OR (((p.username=
  "*55553*") OR (((p.username="*55559*") OR (((p.username="*56003*") OR (((p.username="*60015*") OR (
  ((p.username="*60091*") OR (((p.username="*60154*") OR (((p.username="*60254*") OR (((p.username=
  "*60261*") OR (((p.username="*60262*") OR (((p.username="*60263*") OR (((p.username="*60265*") OR (
  ((p.username="*60266*") OR (((p.username="*60267*") OR (((p.username="*60268*") OR (((p.username=
  "*60283*") OR (((p.username="*60297*") OR (((p.username="*60298*") OR (((p.username="*60300*") OR (
  ((p.username="*60650*") OR (((p.username="*60666*") OR (((p.username="*60667*") OR (((p.username=
  "*60677*") OR (((p.username="*60678*") OR (((p.username="*60679*") OR (((p.username="*60680*") OR (
  ((p.username="*60681*") OR (((p.username="*60682*") OR (((p.username="*60688*") OR (((p.username=
  "*60706*") OR (((p.username="*60774*") OR (((p.username="*60806*") OR (((p.username="*60908*") OR (
  ((p.username="*60971*") OR (((p.username="*61016*") OR (((p.username="*61026*") OR (((p.username=
  "*61049*") OR (((p.username="*61090*") OR (((p.username="*61134*") OR (((p.username="*61191*") OR (
  ((p.username="*61465*") OR (((p.username="*61467*") OR (((p.username="*61638*") OR (((p.username=
  "*61640*") OR (((p.username="*61641*") OR (((p.username="*61648*") OR (((p.username="*61653*") OR (
  ((p.username="*61654*") OR (((p.username="*61655*") OR (((p.username="*61656*") OR (((p.username=
  "*61657*") OR (((p.username="*61659*") OR (((p.username="*61667*") OR (((p.username="*61669*") OR (
  ((p.username="*61779*") OR (((p.username="*61780*") OR (((p.username="*61782*") OR (((p.username=
  "*61783*") OR (((p.username="*61784*") OR (((p.username="*61961*") OR (((p.username="*61971*") OR (
  ((p.username="*62004*") OR (((p.username="*62028*") OR (((p.username="*62059*") OR (((p.username=
  "*62106*") OR (((p.username="*62139*") OR (((p.username="*62205*") OR (((p.username="*62236*") OR (
  ((p.username="*62342*") OR (((p.username="*62367*") OR (((p.username="*62368*") OR (((p.username=
  "*62470*") OR (((p.username="*62471*") OR (((p.username="*62477*") OR (((p.username="*62491*") OR (
  ((p.username="*62496*") OR (((p.username="*62814*") OR (((p.username="*62815*") OR (((p.username=
  "*62816*") OR (((p.username="*62817*") OR (((p.username="*62818*") OR (((p.username="*62819*") OR (
  ((p.username="*62820*") OR (((p.username="*62825*") OR (((p.username="*62841*") OR (((p.username=
  "*63027*") OR (((p.username="*63039*") OR (((p.username="*63231*") OR (((p.username="*63266*") OR (
  ((p.username="*63394*") OR (((p.username="*63528*") OR (((p.username="*63529*") OR (((p.username=
  "*63556*") OR (((p.username="*63587*") OR (((p.username="*63628*") OR (((p.username="*63638*") OR (
  ((p.username="*63686*") OR (((p.username="*63817*") OR (((p.username="*63919*") OR (((p.username=
  "*64003*") OR (((p.username="*64009*") OR (((p.username="*64102*") OR (((p.username="*64230*") OR (
  ((p.username="*64244*") OR (((p.username="*64431*") OR (((p.username="*64546*") OR (((p.username=
  "*64681*") OR (((p.username="*64682*") OR (((p.username="*64812*") OR (((p.username="*64829*") OR (
  ((p.username="*64837*") OR (((p.username="*64858*") OR (((p.username="*64859*") OR (((p.username=
  "*64865*") OR (((p.username="*64869*") OR (((p.username="*65311*") OR (((p.username="*65376*") OR (
  ((p.username="*65390*") OR (((p.username="*65394*") OR (((p.username="*65395*") OR (((p.username=
  "*65400*") OR (((p.username="*65408*") OR (((p.username="*65447*") OR (((p.username="*65459*") OR (
  ((p.username="*65504*") OR (((p.username="*65552*") OR (((p.username="*65704*") OR (((p.username=
  "*65947*") OR (((p.username="*66200*") OR (((p.username="*66201*") OR (((p.username="*66212*") OR (
  ((p.username="*66220*") OR (((p.username="*66441*") OR (((p.username="*66537*") OR (((p.username=
  "*66670*") OR (((p.username="*66888*") OR (((p.username="*67426*") OR (((p.username="*67432*") OR (
  ((p.username="*67669*") OR (((p.username="*68108*") OR (((p.username="*68122*") OR (((p.username=
  "*68124*") OR (((p.username="*68128*") OR (((p.username="*68215*") OR (((p.username="*68242*") OR (
  ((p.username="*68438*") OR (((p.username="*68462*") OR (((p.username="*68477*") OR (((p.username=
  "*68591*") OR (((p.username="*68695*") OR (((p.username="*68855*") OR (((p.username="*69031*") OR (
  ((p.username="*69095*") OR (((p.username="*69105*") OR (((p.username="*69108*") OR (((p.username=
  "*69257*") OR (((p.username="*69261*") OR (((p.username="*69262*") OR (((p.username="*69264*") OR (
  ((p.username="*69358*") OR (((p.username="*69360*") OR (((p.username="*69369*") OR (((p.username=
  "*69381*") OR (((p.username="*69436*") OR (((p.username="*69459*") OR (((p.username="*69587*") OR (
  ((p.username="*69594*") OR (((p.username="*69805*") OR (((p.username="*69913*") OR (((p.username=
  "*69957*") OR (((p.username="*69997*") OR (((p.username="*70093*") OR (((p.username="*70173*") OR (
  ((p.username="*70196*") OR (((p.username="*70197*") OR (((p.username="*70198*") OR (((p.username=
  "*70199*") OR (((p.username="*70621*") OR (((p.username="*70708*") OR (((p.username="*71062*") OR (
  ((p.username="*71657*") OR (((p.username="*71764*") OR (((p.username="*71783*") OR (((p.username=
  "*71997*") OR (((p.username="*73050*") OR (((p.username="*73083*") OR (((p.username="*73384*") OR (
  ((p.username="*73461*") OR (((p.username="*73507*") OR (((p.username="*73630*") OR (((p.username=
  "*73707*") OR (((p.username="*73786*") OR (((p.username="*73872*") OR (((p.username="*76535*") OR (
  ((p.username="*77110*") OR (((p.username="*77197*") OR (((p.username="*77495*") OR (((p.username=
  "*79434*") OR (((p.username="*90969*") OR (((p.username="*91949*") OR (((p.username="*95002*") OR (
  ((p.username="*95896*") OR (((p.username="*96086*") OR (((p.username="*97961*") OR (((p.username=
  "*98095*") OR (((p.username="*99071*") OR (((p.username="*99195*") OR (((p.username="*99196*") OR (
  ((p.username="*99197*") OR (((p.username="*99200*") OR (p.username="*99201*")) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   AND p.username != "RF*"
  ORDER BY p.active_status_cd, p.username
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
   ousername16 = format(p.username,"################"), namefull30 = format(p.name_full_formatted,
    "##############################"), fupdtm = format(p.updt_dt_tm,"@SHORTDATETIME"),
   fenddtm = format(p.end_effective_dt_tm,"@SHORTDATETIME"), col 1, lncnt"####",
   col + 3, p.active_ind"##", col + 2,
   p.active_status_cd"###", col + 2, physflg"##",
   col 16, ousername16, col + 1,
   namefull30, col + 0, p.person_id"##########",
   col + 1, p_position_disp"################################", col + 1,
   fenddtm, col + 2, fupdtm,
   col + 1, p.updt_id"##########", row + 1
   IF (row > 60)
    BREAK
   ENDIF
   IF (gl_bhs_prod_flag=1)
    xdomain = "PROD"
   ELSEIF (curnode="casdtest")
    xdomain = "BUILD"
   ELSEIF (curnode="casbtest")
    xdomain = "CERT"
   ELSEIF (curnode="casetest")
    xdomain = "TEST"
   ELSE
    xdomain = "??"
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
