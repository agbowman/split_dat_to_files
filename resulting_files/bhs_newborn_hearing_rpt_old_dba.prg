CREATE PROGRAM bhs_newborn_hearing_rpt_old:dba
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 uname = vc
     2 pat[*]
       3 ptname = vc
       3 acc = vc
       3 dt = vc
 )
 DECLARE printer_name = vc
 DECLARE unit_name = vc
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO "nl:"
  en_loc_nurse_unit_disp = uar_get_code_display(en.loc_nurse_unit_cd)
  FROM eks_module_audit em,
   eks_module_audit_det e,
   encounter en,
   encntr_alias ea,
   person p
  PLAN (em
   WHERE em.begin_dt_tm > cnvtlookbehind("12,H")
    AND em.end_dt_tm < sysdate
    AND em.module_name="BHS_ASY_NEWBORN_HEARING")
   JOIN (e
   WHERE e.module_audit_id=em.rec_id
    AND e.template_name="EKS_CE_RESULTA_INCOMING_REQ_L"
    AND e.encntr_id > 0)
   JOIN (en
   WHERE en.encntr_id=e.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(en.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(1077))
   JOIN (p
   WHERE p.person_id=en.person_id)
  ORDER BY en_loc_nurse_unit_disp
  HEAD REPORT
   cnt = 0, cnt2 = 0
  HEAD en_loc_nurse_unit_disp
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].uname = trim(
    en_loc_nurse_unit_disp)
  DETAIL
   cnt2 = (cnt2+ 1), stat = alterlist(temp->qual[cnt].pat,cnt2), temp->qual[cnt].pat[cnt2],
   uname = trim(en_loc_nurse_unit_disp), temp->qual[cnt].pat[cnt2].acc = trim(ea.alias), temp->qual[
   cnt].pat[cnt2].dt = format(em.begin_dt_tm,"mm/dd/yy hh:mm;;q"),
   temp->qual[cnt].pat[cnt2].ptname = substring(1,40,trim(p.name_full_formatted))
  FOOT  en_loc_nurse_unit_disp
   cnt2 = 0
  WITH nocounter
 ;end select
 CALL echorecord(temp)
 FOR (x = 1 TO size(temp->qual,5))
   SET unit_name = temp->qual[x].uname
   CASE (unit_name)
    OF "NICU":
     SET printer_name = "bmcww2nicu3"
    OF "NCCN":
     SET printer_name = "bmcww2nicu2"
    OF "NNURA":
     SET printer_name = "bmcww1ldrp5"
    OF "NNURB":
     SET printer_name = "bmcww1idrp6"
    OF "NNURC":
     SET printer_name = "bmcww1ldrp2"
    OF "NNURD":
     SET printer_name = "bmcww2baby1"
    OF "NURS":
     SET printer_name = "mlhdv4women1"
    OF "NSY":
     SET printer_name = "fmcfl3obgyn1"
    OF "OBGN":
     SET printer_name = "fmcfl3obgyn1"
    ELSE
     GO TO exit_report
   ENDCASE
   CALL echo(printer_name)
   SELECT INTO value(printer_name)
    unit = temp->qual[x].uname, ptname = temp->qual[x].pat[d.seq].ptname, dt = temp->qual[x].pat[d
    .seq].dt,
    acc = temp->qual[x].pat[d.seq].acc
    FROM (dummyt d  WITH seq = value(size(temp->qual[x].pat,5)))
    PLAN (d
     WHERE d.seq > 0)
    ORDER BY unit
    HEAD REPORT
     y_pos = 18,
     SUBROUTINE offset(yval)
       CALL print(format((y_pos+ yval),"###"))
     END ;Subroutine report
     , row + 1,
     "{F/1}{CPI/11}",
     CALL print(calcpos(216,(y_pos+ 11))), "Newborn Hearing Screening (ALGO)",
     row + 1, y_pos = (y_pos+ 24)
    HEAD PAGE
     IF (curpage > 1)
      y_pos = 18
     ENDIF
    HEAD unit
     IF (((y_pos+ 113) >= 792))
      y_pos = 0, BREAK
     ENDIF
     row + 1, "{F/1}{CPI/14}",
     CALL print(calcpos(20,(y_pos+ 11))),
     "Unit:", row + 1, "{F/0}",
     row + 1,
     CALL print(calcpos(54,(y_pos+ 11))), unit,
     row + 1, row + 1, "{F/1}",
     row + 1,
     CALL print(calcpos(20,(y_pos+ 29))), "Report Date / Time:",
     row + 1, "{F/0}", d = format(cnvtdatetime(curdate,curtime3),"mm/dd/yy hh:mm;;q"),
     row + 1,
     CALL print(calcpos(144,(y_pos+ 29))), d,
     row + 1, row + 1,
     CALL print(calcpos(20,(y_pos+ 47))),
     "Pt Name",
     CALL print(calcpos(198,(y_pos+ 47))), "Acc#",
     CALL print(calcpos(360,(y_pos+ 47))), "Date / Time Form Completed", row + 1,
     y_pos = (y_pos+ 59)
    DETAIL
     IF (((y_pos+ 97) >= 792))
      y_pos = 0, BREAK
     ENDIF
     name_full_formatted1 = substring(1,40,ptname), alias1 = acc, row + 1,
     "{F/0}{CPI/14}",
     CALL print(calcpos(20,(y_pos+ 11))), name_full_formatted1,
     CALL print(calcpos(198,(y_pos+ 11))), alias1, row + 1,
     CALL print(calcpos(360,(y_pos+ 11))), dt, y_pos = (y_pos+ 13)
    FOOT  unit
     y_pos = (y_pos+ 0)
    FOOT PAGE
     y_pos = 726, row + 1, "{F/0}{CPI/14}",
     CALL print(calcpos(270,(y_pos+ 11))), "Page:", row + 1,
     CALL print(calcpos(306,(y_pos+ 11))), curpage"##;l"
    FOOT REPORT
     IF (((y_pos+ 62) >= 792))
      y_pos = 0, BREAK
     ELSE
      y_pos = (y_pos+ 36)
     ENDIF
     row + 1, "{F/0}{CPI/14}",
     CALL print(calcpos(20,(y_pos+ 11))),
     "Program name:", row + 1,
     CALL print(calcpos(90,(y_pos+ 11))),
     curprog, row + 1,
     CALL print(calcpos(272,(y_pos+ 11))),
     "End of Report"
    WITH maxrec = 100, nullreport, maxcol = 300,
     maxrow = 500, dio = 08
   ;end select
 ENDFOR
#exit_report
END GO
