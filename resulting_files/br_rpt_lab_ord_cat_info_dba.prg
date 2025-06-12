CREATE PROGRAM br_rpt_lab_ord_cat_info:dba
 FREE RECORD temp
 RECORD temp(
   1 client = vc
   1 user = vc
   1 acnt = i2
   1 aqual[*]
     2 activity_type = vc
     2 a_ln_cnt = i2
     2 a_ln_qual[*]
       3 a_line = vc
     2 scnt = i2
     2 squal[*]
       3 subtype = vc
       3 s_ln_cnt = i2
       3 s_ln_qual[*]
         4 s_line = vc
       3 fcnt = i2
       3 fqual[*]
         4 format = vc
         4 f_ln_cnt = i2
         4 f_ln_qual[*]
           5 f_line = vc
         4 ocnt = i2
         4 oqual[*]
           5 ord = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD ph(
   1 a_cnt = i2
   1 aln[*]
     2 aline = vc
   1 s_cnt = i2
   1 sln[*]
     2 sline = vc
   1 f_cnt = i2
   1 fln[*]
     2 fline = vc
 )
 DECLARE ord = f8 WITH public, noconstant(0.0)
 DECLARE lab = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6003
    AND cv.cdf_meaning="ORDER")
  DETAIL
   ord = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="GENERAL LAB")
  DETAIL
   lab = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_prsnl bp
  PLAN (bp
   WHERE (bp.br_prsnl_id=reqinfo->updt_id))
  DETAIL
   temp->user = bp.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_entry_format oef,
   code_value cv,
   code_value cv2
  PLAN (oc
   WHERE oc.catalog_type_cd=lab
    AND oc.active_ind=1)
   JOIN (oef
   WHERE oef.oe_format_id=oc.oe_format_id
    AND oef.action_type_cd=ord)
   JOIN (cv
   WHERE cv.code_value=oc.activity_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=oc.activity_subtype_cd)
  ORDER BY oc.activity_type_cd, oc.activity_subtype_cd, oef.oe_format_id,
   oc.description
  HEAD REPORT
   acnt = 0, scnt = 0, fcnt = 0,
   ocnt = 0
  HEAD oc.activity_type_cd
   scnt = 0, fcnt = 0, ocnt = 0,
   acnt = (acnt+ 1), temp->acnt = acnt, stat = alterlist(temp->aqual,acnt),
   temp->aqual[acnt].activity_type = cv.description
  HEAD oc.activity_subtype_cd
   fcnt = 0, ocnt = 0, scnt = (scnt+ 1),
   temp->aqual[acnt].scnt = scnt, stat = alterlist(temp->aqual[acnt].squal,scnt), temp->aqual[acnt].
   squal[scnt].subtype = cv2.description
  HEAD oef.oe_format_id
   ocnt = 0, fcnt = (fcnt+ 1), temp->aqual[acnt].squal[scnt].fcnt = fcnt,
   stat = alterlist(temp->aqual[acnt].squal[scnt].fqual,fcnt), temp->aqual[acnt].squal[scnt].fqual[
   fcnt].format = oef.oe_format_name
  DETAIL
   IF (substring(1,2,oc.description) != "zz")
    ocnt = (ocnt+ 1), temp->aqual[acnt].squal[scnt].fqual[fcnt].ocnt = ocnt, stat = alterlist(temp->
     aqual[acnt].squal[scnt].fqual[fcnt].oqual,ocnt),
    temp->aqual[acnt].squal[scnt].fqual[fcnt].oqual[ocnt].ord = oc.description
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO temp->acnt)
   SET pt->line_cnt = 0
   SET max_length = 22
   EXECUTE dcp_parse_text value(temp->aqual[x].activity_type), value(max_length)
   SET stat = alterlist(temp->aqual[x].a_ln_qual,pt->line_cnt)
   SET temp->aqual[x].a_ln_cnt = pt->line_cnt
   FOR (j = 1 TO pt->line_cnt)
     SET temp->aqual[x].a_ln_qual[j].a_line = pt->lns[j].line
   ENDFOR
   FOR (y = 1 TO temp->aqual[x].scnt)
     SET pt->line_cnt = 0
     SET max_length = 19
     EXECUTE dcp_parse_text value(temp->aqual[x].squal[y].subtype), value(max_length)
     SET stat = alterlist(temp->aqual[x].squal[y].s_ln_qual,pt->line_cnt)
     SET temp->aqual[x].squal[y].s_ln_cnt = pt->line_cnt
     FOR (j = 1 TO pt->line_cnt)
       SET temp->aqual[x].squal[y].s_ln_qual[j].s_line = pt->lns[j].line
     ENDFOR
     FOR (z = 1 TO temp->aqual[x].squal[y].fcnt)
       SET pt->line_cnt = 0
       SET max_length = 19
       EXECUTE dcp_parse_text value(temp->aqual[x].squal[y].fqual[z].format), value(max_length)
       SET stat = alterlist(temp->aqual[x].squal[y].fqual[z].f_ln_qual,pt->line_cnt)
       SET temp->aqual[x].squal[y].fqual[z].f_ln_cnt = pt->line_cnt
       FOR (j = 1 TO pt->line_cnt)
         SET temp->aqual[x].squal[y].fqual[z].f_ln_qual[j].f_line = pt->lns[j].line
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 SET xcol = 0
 SET ycol = 0
 SET save_ycol = 0
 SET a_ycol = 0
 SET s_ycol = 0
 SET f_ycol = 0
 SET print_header = 0
 SELECT INTO  $1
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   xcol = 220, ycol = 25, "{cpi/10}",
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}Bedrock Summary Report",
   row + 1
  HEAD PAGE
   "{cpi/12}", row + 1, xcol = 20
   IF (curpage=1)
    ycol = 47
   ELSE
    ycol = 25
   ENDIF
   CALL print(calcpos(xcol,ycol)), "{b}Report Name: {endb}Laboratory Order Catalog Audit", row + 1,
   ycol = (ycol+ 20)
   IF (print_header=1)
    "{cpi/15}", row + 1, save_col = ycol,
    xcol = 20,
    CALL print(calcpos(xcol,ycol)), "{b}Activity Type:",
    row + 1, xcol = 90
    FOR (q = 1 TO ph->a_cnt)
      CALL print(calcpos(xcol,ycol)), ph->aln[q].aline, row + 1,
      ycol = (ycol+ 10), a_ycol = ycol
    ENDFOR
    xcol = 210, ycol = save_col,
    CALL print(calcpos(xcol,ycol)),
    "{b}Sub-Activity Type:", row + 1, xcol = 300
    FOR (q = 1 TO ph->s_cnt)
      CALL print(calcpos(xcol,ycol)), ph->sln[q].sline, row + 1,
      ycol = (ycol+ 10), s_ycol = ycol
    ENDFOR
    xcol = 400, ycol = save_col,
    CALL print(calcpos(xcol,ycol)),
    "{b}OE Format:", row + 1, xcol = 455
    FOR (q = 1 TO ph->f_cnt)
      CALL print(calcpos(xcol,ycol)), ph->fln[q].fline, row + 1,
      ycol = (ycol+ 10), f_ycol = ycol
    ENDFOR
    ycol = maxval(a_ycol,s_ycol,f_ycol), ycol = (ycol+ 10), print_header = 0
   ENDIF
   "{cpi/15}", row + 1
  DETAIL
   FOR (x = 1 TO temp->acnt)
    FOR (y = 1 TO temp->aqual[x].scnt)
      FOR (z = 1 TO temp->aqual[x].squal[y].fcnt)
        IF (((ycol != 79) OR (ycol != 47)) )
         ycol = (ycol+ 10)
        ENDIF
        save_ycol = ycol, xcol = 20,
        CALL print(calcpos(xcol,ycol)),
        "{b}Activity Type:", row + 1, xcol = 90
        FOR (w = 1 TO temp->aqual[x].a_ln_cnt)
          CALL print(calcpos(xcol,ycol)), temp->aqual[x].a_ln_qual[w].a_line, row + 1,
          ycol = (ycol+ 10), a_ycol = ycol, ph->a_cnt = w,
          stat = alterlist(ph->aln,w), ph->aln[w].aline = temp->aqual[x].a_ln_qual[w].a_line
        ENDFOR
        ycol = save_ycol, xcol = 210,
        CALL print(calcpos(xcol,ycol)),
        "{b}Sub-Activity Type:", row + 1, xcol = 300
        FOR (w = 1 TO temp->aqual[x].squal[y].s_ln_cnt)
          CALL print(calcpos(xcol,ycol)), temp->aqual[x].squal[y].s_ln_qual[w].s_line, row + 1,
          ycol = (ycol+ 10), s_ycol = ycol, ph->s_cnt = w,
          stat = alterlist(ph->sln,w), ph->sln[w].sline = temp->aqual[x].squal[y].s_ln_qual[w].s_line
        ENDFOR
        ycol = save_ycol, xcol = 400,
        CALL print(calcpos(xcol,ycol)),
        "{b}OE Format:", row + 1, xcol = 455
        FOR (w = 1 TO temp->aqual[x].squal[y].fqual[z].f_ln_cnt)
          CALL print(calcpos(xcol,ycol)), temp->aqual[x].squal[y].fqual[z].f_ln_qual[w].f_line, row
           + 1,
          ycol = (ycol+ 10), f_ycol = ycol, ph->f_cnt = w,
          stat = alterlist(ph->fln,w), ph->fln[w].fline = temp->aqual[x].squal[y].fqual[z].f_ln_qual[
          w].f_line
        ENDFOR
        ycol = maxval(a_ycol,s_ycol,f_ycol), ycol = (ycol+ 10)
        FOR (w = 1 TO temp->aqual[x].squal[y].fqual[z].ocnt)
          xcol = 50,
          CALL print(calcpos(xcol,ycol)), temp->aqual[x].squal[y].fqual[z].oqual[w].ord,
          row + 1, ycol = (ycol+ 10)
          IF (ycol > 700)
           IF ((w != temp->aqual[x].squal[y].fqual[z].ocnt))
            print_header = 1
           ENDIF
           BREAK
          ENDIF
        ENDFOR
      ENDFOR
    ENDFOR
    ,
    IF ((x=temp->acnt))
     ycol = (ycol+ 10), xcol = 240,
     CALL print(calcpos(xcol,ycol)),
     "{b}*** End of Report ***", row + 1
    ENDIF
   ENDFOR
  FOOT PAGE
   xcol = 20, ycol = 735,
   CALL print(calcpos(xcol,ycol)),
   "Page: ", curpage"##", row + 1,
   ycol = (ycol+ 10),
   CALL print(calcpos(xcol,ycol)), "Date/Time: ",
   curdate, " ", curtime,
   row + 1, ycol = (ycol+ 10),
   CALL print(calcpos(xcol,ycol)),
   "Printed By: ", temp->user, row + 1,
   ycol = (ycol+ 10)
  WITH nocounter, dio = 08, maxrow = 800,
   maxcol = 800
 ;end select
END GO
