CREATE PROGRAM djh_l_infoscan_orgs
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  hp1.alias, hp.alias, h.health_plan_id,
  hp.health_plan_id, h.plan_name, hp.updt_dt_tm,
  hp1.health_plan_id, hp_alias_pool_disp = uar_get_code_display(hp.alias_pool_cd),
  hp1_alias_pool_disp = uar_get_code_display(hp1.alias_pool_cd),
  expr1 = curprog
  FROM health_plan h,
   health_plan_alias hp,
   health_plan_alias hp1
  PLAN (hp
   WHERE hp.alias_pool_cd=99494459)
   JOIN (h
   WHERE h.health_plan_id=hp.health_plan_id)
   JOIN (hp1
   WHERE hp1.health_plan_id=h.health_plan_id
    AND hp1.alias_pool_cd=674680)
  HEAD REPORT
   y_pos = 18, printpsheader = 0, col 0,
   "{PS/792 0 translate 90 rotate/}", row + 1,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36
   IF (printpsheader)
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   printpsheader = 1, row + 1, "{F/0}{CPI/14}",
   row + 1,
   CALL print(calcpos(20,(y_pos+ 0))), curdate,
   row + 1,
   CALL print(calcpos(361,(y_pos+ 0))), "InfoScan ORGs",
   row + 1,
   CALL print(calcpos(20,(y_pos+ 24))), "IntrFace",
   row + 1, y_val = ((792 - y_pos) - 58), "{PS/newpath 2 setlinewidth   19 ",
   y_val, " moveto  729 ", y_val,
   " lineto stroke 19 ", y_val, " moveto/}",
   CALL print(calcpos(28,(y_pos+ 33))), "Code",
   CALL print(calcpos(71,(y_pos+ 24))),
   "InfoScan",
   CALL print(calcpos(79,(y_pos+ 32))), "Code",
   CALL print(calcpos(141,(y_pos+ 30))), "Plan ID",
   CALL print(calcpos(222,(y_pos+ 29))),
   "Plan Name",
   CALL print(calcpos(473,(y_pos+ 35))), "|     Date    |",
   CALL print(calcpos(473,(y_pos+ 27))), "Change / Update",
   CALL print(calcpos(571,(y_pos+ 34))),
   "Created / Changed by", row + 1, y_pos = (y_pos+ 60)
  DETAIL
   IF (((y_pos+ 98) >= 612))
    y_pos = 0, BREAK
   ENDIF
   alias1 = substring(1,6,hp1.alias), alias2 = substring(1,6,hp.alias), plan_name1 = substring(1,30,h
    .plan_name),
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 0))),
   alias1,
   CALL print(calcpos(78,(y_pos+ 1))), alias2,
   CALL print(calcpos(127,(y_pos+ 1))), h.health_plan_id,
   CALL print(calcpos(210,(y_pos+ 1))),
   plan_name1,
   CALL print(calcpos(486,(y_pos+ 1))), hp.updt_dt_tm,
   y_pos = (y_pos+ 14)
  FOOT PAGE
   y_pos = 546, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 0))), "Prgm:", row + 1,
   CALL print(calcpos(47,(y_pos+ 0))), curprog, row + 1,
   CALL print(calcpos(504,(y_pos+ 0))), "Page", cntpg = format(curpage,"###"),
   row + 1,
   CALL print(calcpos(527,(y_pos+ 0))), cntpg
  FOOT REPORT
   IF (((y_pos+ 62) >= 612))
    y_pos = 0, BREAK
   ELSE
    y_pos = (y_pos+ 36)
   ENDIF
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(361,(y_pos+ 0))),
   "End of Report"
  WITH maxcol = 300, maxrow = 500, dio = 08,
   landscape, noheading, format = variable,
   time = value(maxsecs)
 ;end select
END GO
