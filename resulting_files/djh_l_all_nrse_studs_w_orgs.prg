CREATE PROGRAM djh_l_all_nrse_studs_w_orgs
 PROMPT
  "Output to File/Printer/MINE" = mine
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
  pr.name_full_formatted, pr.username, p.active_ind,
  p.beg_effective_dt_tm, p.end_effective_dt_tm, p.organization_id,
  p.person_id, p.prsnl_org_reltn_id, o.organization_id,
  o.org_name, pr.active_ind, pr.position_cd,
  pr_position_disp = uar_get_code_display(pr.position_cd)
  FROM prsnl_org_reltn p,
   organization o,
   prsnl pr
  PLAN (p)
   JOIN (o
   WHERE p.organization_id=o.organization_id)
   JOIN (pr
   WHERE pr.person_id=p.person_id
    AND pr.active_ind=1
    AND pr.position_cd=457)
  ORDER BY pr.name_full_formatted, p.person_id, o.org_name
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   , "{F/0}{CPI/14}",
   lncntr = 0, row + 1, "{F/1}{CPI/11}",
   CALL print(calcpos(185,(y_pos+ 36))), "List All Nurse Students and ORGS", row + 1,
   y_pos = (y_pos+ 50)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   pr_position_disp1 = substring(1,30,pr_position_disp),
   CALL print(calcpos(20,(y_pos+ 14))), "Person Name",
   row + 1, y_val = ((792 - y_pos) - 38), "{PS/newpath 2 setlinewidth   20 ",
   y_val, " moveto  556 ", y_val,
   " lineto stroke 20 ", y_val, " moveto/}",
   row + 1, "{F/0}{CPI/14}", fposcd = format(pr.position_cd,"##########"),
   row + 1,
   CALL print(calcpos(175,(y_pos+ 11))), fposcd,
   row + 1,
   CALL print(calcpos(254,(y_pos+ 12))), pr_position_disp1,
   CALL print(calcpos(532,(y_pos+ 12))), "ln #", row + 1,
   y_pos = (y_pos+ 18)
  HEAD p.person_id
   IF (((y_pos+ 77) >= 792))
    y_pos = 0, BREAK
   ENDIF
   bmc = "   ", bmcip = "     ", bhs = "   ",
   cctr = "    ", fmc = "   ", fmcip = "     ",
   mlh = "   ", y_pos = (y_pos+ 12)
  DETAIL
   IF (((y_pos+ 108) >= 792))
    y_pos = 0, BREAK
   ENDIF
   prsnid = format(p.person_id,"#########"), orgid = format(o.organization_id,"#########")
   IF (o.organization_id=589743)
    bhs = "BHS"
   ELSEIF (o.organization_id=589744)
    bmc = "BMC"
   ELSEIF (o.organization_id=589763)
    bmcip = "BMCIP"
   ELSEIF (o.organization_id=738833)
    cctr = "CCTR"
   ELSEIF (o.organization_id=589745)
    fmc = "FMC"
   ELSEIF (o.organization_id=589764)
    fmcip = "FMCIP"
   ELSEIF (o.organization_id=589746)
    mlh = "MLH"
   ENDIF
  FOOT  p.person_id
   IF (((y_pos+ 77) >= 792))
    y_pos = 0, BREAK
   ENDIF
   name_full_formatted1 = substring(1,30,pr.name_full_formatted), username1 = substring(1,12,pr
    .username), row + 1,
   "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 11))), name_full_formatted1,
   CALL print(calcpos(182,(y_pos+ 11))), username1, row + 1,
   CALL print(calcpos(244,(y_pos+ 11))), bhs, row + 1,
   CALL print(calcpos(263,(y_pos+ 11))), bmc, row + 1,
   CALL print(calcpos(280,(y_pos+ 11))), bmcip, row + 1,
   CALL print(calcpos(308,(y_pos+ 11))), cctr, row + 1,
   CALL print(calcpos(332,(y_pos+ 11))), fmc, row + 1,
   CALL print(calcpos(350,(y_pos+ 11))), fmcip, row + 1,
   CALL print(calcpos(378,(y_pos+ 11))), mlh, lncntr = (lncntr+ 1),
   row + 1,
   CALL print(calcpos(500,(y_pos+ 11))), lncntr
  FOOT PAGE
   y_pos = 726, row + 1, "{F/0}{CPI/14}",
   row + 1,
   CALL print(calcpos(26,(y_pos+ 11))), curprog,
   row + 1,
   CALL print(calcpos(324,(y_pos+ 11))), "Page:",
   row + 1,
   CALL print(calcpos(344,(y_pos+ 11))), curpage
  WITH maxcol = 300, maxrow = 500, dio = 08,
   noheading, format = variable, time = value(maxsecs)
 ;end select
END GO
