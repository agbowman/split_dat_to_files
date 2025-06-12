CREATE PROGRAM djh_l_orgs_by_pos_csv
 PROMPT
  "Position Code",
  "Output to File/Printer/MINE" = "MINE"
  WITH poscd, outdev
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
  pr_position_disp = uar_get_code_display(pr.position_cd), pr.physician_ind, pr.active_status_cd"###",
  pr_active_status_disp = uar_get_code_display(pr.active_status_cd)
  FROM prsnl_org_reltn p,
   organization o,
   prsnl pr
  PLAN (p
   WHERE p.end_effective_dt_tm > cnvtdatetime(curdate,235959))
   JOIN (o
   WHERE p.organization_id=o.organization_id)
   JOIN (pr
   WHERE pr.person_id=p.person_id
    AND pr.active_ind=1
    AND pr.active_status_cd=188
    AND (pr.position_cd= $POSCD))
  ORDER BY pr.name_full_formatted, p.person_id, o.org_name
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   , lncntr = 0
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   pr_position_disp1 = substring(1,30,pr_position_disp), poscdint = cnvtint(pr.position_cd), row + 1,
   y_val = ((792 - y_pos) - 59), "{PS/newpath 2 setlinewidth   38 ", y_val,
   " moveto  557 ", y_val, " lineto stroke 38 ",
   y_val, " moveto/}", row + 1,
   CALL print(calcpos(38,(y_pos+ 13))), poscdint,
   CALL print(calcpos(42,(y_pos+ 33))),
   "Person Name", row + 1,
   CALL print(calcpos(115,(y_pos+ 13))),
   pr_position_disp1,
   CALL print(calcpos(218,(y_pos+ 34))), "UserName",
   CALL print(calcpos(280,(y_pos+ 26))), "phys",
   CALL print(calcpos(280,(y_pos+ 35))),
   "flg",
   CALL print(calcpos(310,(y_pos+ 33))), "|----- Standard Orgs ----|",
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(362,(y_pos+ 11))),
   "Active IDs only (Stat CD = 188)",
   CALL print(calcpos(472,(y_pos+ 33))), "Other ORGs",
   CALL print(calcpos(475,(y_pos+ 23))), "Count of", row + 1,
   y_pos = (y_pos+ 38)
  HEAD p.person_id
   IF (((y_pos+ 77) >= 792))
    y_pos = 0, BREAK
   ENDIF
   bmc = "   ", bmcip = "     ", bhs = "   ",
   cctr = "    ", fmc = "   ", fmcip = "     ",
   mlh = "   ", physflg = " ", cntothorgs = 0,
   cntstndorgs = 0, y_pos = (y_pos+ 12)
  DETAIL
   IF (((y_pos+ 108) >= 792))
    y_pos = 0, BREAK
   ENDIF
   prsnid = format(p.person_id,"#########"), orgid = format(o.organization_id,"#########")
   IF (o.organization_id=589743)
    bhs = "BHS", cntstndorgs = (cntstndorgs+ 1)
   ELSEIF (o.organization_id=589744)
    bmc = "BMC", cntstndorgs = (cntstndorgs+ 1)
   ELSEIF (o.organization_id=589763)
    bmcip = "BMCIP", cntstndorgs = (cntstndorgs+ 1)
   ELSEIF (o.organization_id=738833)
    cctr = "CCTR", cntstndorgs = (cntstndorgs+ 1)
   ELSEIF (o.organization_id=589745)
    fmc = "FMC", cntstndorgs = (cntstndorgs+ 1)
   ELSEIF (o.organization_id=589764)
    fmcip = "FMCIP", cntstndorgs = (cntstndorgs+ 1)
   ELSEIF (o.organization_id=589746)
    mlh = "MLH", cntstndorgs = (cntstndorgs+ 1)
   ELSE
    cntothorgs = (cntothorgs+ 1)
   ENDIF
   IF (pr.physician_ind=1)
    physflg = "*"
   ENDIF
  FOOT  p.person_id
   IF (((y_pos+ 78) >= 792))
    y_pos = 0, BREAK
   ENDIF
   name_full_formatted1 = substring(1,35,pr.name_full_formatted), username1 = substring(1,13,pr
    .username), row + 1,
   "{F/0}{CPI/14}",
   CALL print(calcpos(38,(y_pos+ 11))), name_full_formatted1,
   CALL print(calcpos(221,(y_pos+ 11))), username1, row + 1,
   CALL print(calcpos(285,(y_pos+ 11))), physflg, row + 1,
   CALL print(calcpos(314,(y_pos+ 11))), bhs, row + 1,
   CALL print(calcpos(332,(y_pos+ 11))), bmc, row + 1,
   CALL print(calcpos(349,(y_pos+ 11))), bmcip, row + 1,
   CALL print(calcpos(378,(y_pos+ 11))), cctr, row + 1,
   CALL print(calcpos(400,(y_pos+ 11))), fmc, row + 1,
   CALL print(calcpos(419,(y_pos+ 11))), fmcip, row + 1,
   CALL print(calcpos(447,(y_pos+ 11))), mlh, cntothorgs,
   lncntr = (lncntr+ 1)
  FOOT PAGE
   y_pos = 726, row + 1, "{F/0}{CPI/14}",
   row + 1,
   CALL print(calcpos(44,(y_pos+ 11))), curprog,
   row + 1,
   CALL print(calcpos(288,(y_pos+ 12))), curdate,
   row + 1,
   CALL print(calcpos(342,(y_pos+ 11))), "Page:",
   row + 1,
   CALL print(calcpos(362,(y_pos+ 11))), curpage
  FOOT REPORT
   IF (((y_pos+ 62) >= 792))
    y_pos = 0, BREAK
   ELSE
    y_pos = (y_pos+ 36)
   ENDIF
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(54,(y_pos+ 11))),
   "Person Count =", row + 1,
   CALL print(calcpos(125,(y_pos+ 11))),
   lncntr
  WITH maxcol = 300, maxrow = 500, dio = 08,
   noheading, format = variable, time = value(maxsecs)
 ;end select
END GO
