CREATE PROGRAM dl_diet_orders_test:dba
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 order_id = f8
     2 com_ind = i2
     2 comment = vc
     2 c_cnt = i2
     2 c_qual[*]
       3 c_line = vc
     2 date = vc
     2 status = vc
     2 display = vc
     2 disp_cnt = i2
     2 disp_qual[*]
       3 disp_line = vc
     2 mnemonic = vc
     2 m_cnt = i2
     2 m_qual[*]
       3 m_line = vc
     2 oe_format_id = f8
     2 clin_line_ind = i2
     2 stat_ind = i2
     2 d_cnt = i2
     2 d_qual[*]
       3 field_description = vc
       3 label_text = vc
       3 value = vc
       3 field_value = f8
       3 oe_field_meaning_id = f8
       3 group_seq = i4
       3 print_ind = i2
       3 clin_line_ind = i2
       3 label = vc
       3 suffix = i2
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET age = fillstring(15," ")
 SET dob = fillstring(15," ")
 SET sex = fillstring(40," ")
 SET mrn = fillstring(20," ")
 SET fnbr = fillstring(20," ")
 SET date = fillstring(30," ")
 SET attenddoc = fillstring(30," ")
 SET name = fillstring(30," ")
 SET unit = fillstring(20," ")
 SET room = fillstring(20," ")
 SET bed = fillstring(20," ")
 SET location = fillstring(50," ")
 SET person_id = 0
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "ORD COMMENT"
 EXECUTE cpm_get_cd_for_cdf
 SET ord_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET order_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "FUTURE"
 EXECUTE cpm_get_cd_for_cdf
 SET future_cd = code_value
 SET code_set = 6000
 SET cdf_meaning = "DIETARY"
 EXECUTE cpm_get_cd_for_cdf
 SET diet_cd = code_value
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   (dummyt d1  WITH seq = 1),
   person_alias pa,
   (dummyt d2  WITH seq = 1),
   encntr_alias ea,
   (dummyt d3  WITH seq = 1),
   encntr_prsnl_reltn epr,
   prsnl pl
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr_cd
    AND ea.active_ind=1)
   JOIN (d3)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_doc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   age = trim(cnvtage(cnvtdate(p.birth_dt_tm),curdate),3), dob = format(p.birth_dt_tm,"@SHORTDATE"),
   name = substring(1,30,p.name_full_formatted),
   sex = substring(1,40,uar_get_code_display(p.sex_cd)), mrn = substring(1,20,cnvtalias(pa.alias,pa
     .alias_pool_cd)), fnbr = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd)),
   attenddoc = substring(1,30,pl.name_full_formatted), unit = substring(1,20,uar_get_code_display(e
     .loc_nurse_unit_cd)), room = substring(1,10,uar_get_code_display(e.loc_room_cd)),
   bed = substring(1,10,uar_get_code_display(e.loc_bed_cd)), location = concat(trim(unit),"/",trim(
     room),"/",trim(bed)), date = format(e.reg_dt_tm,"@SHORTDATE"),
   person_id = e.person_id
  WITH nocounter, outerjoin = d1, dontcare = pa,
   outerjoin = d2, dontcare = ea, outerjoin = d3,
   dontcare = epr
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND o.order_status_cd IN (order_cd, inprocess_cd, future_cd)
    AND o.template_order_flag IN (0, 1))
  ORDER BY o.orig_order_dt_tm
  HEAD REPORT
   temp->cnt = 0
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].display
    = o.clinical_display_line,
   temp->qual[temp->cnt].order_id = o.order_id, temp->qual[temp->cnt].oe_format_id = o.oe_format_id
   IF (substring(240,10,o.clinical_display_line) > "  ")
    temp->qual[temp->cnt].clin_line_ind = 1
   ELSE
    temp->qual[temp->cnt].clin_line_ind = 0
   ENDIF
   temp->qual[temp->cnt].mnemonic = o.hna_order_mnemonic, temp->qual[temp->cnt].date = format(o
    .orig_order_dt_tm,"@SHORTDATETIME"), temp->qual[temp->cnt].status = uar_get_code_display(o
    .order_status_cd),
   temp->qual[temp->cnt].com_ind = o.order_comment_ind
  WITH nocounter
 ;end select
 CALL echo(build("curqual===",curqual))
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 FOR (y = 1 TO temp->cnt)
   IF ((temp->qual[y].clin_line_ind=1))
    SELECT INTO "nl:"
     FROM order_detail od,
      order_entry_fields of1,
      oe_format_fields oef
     PLAN (od
      WHERE (temp->qual[y].order_id=od.order_id))
      JOIN (oef
      WHERE (oef.oe_format_id=temp->qual[y].oe_format_id)
       AND oef.oe_field_id=od.oe_field_id)
      JOIN (of1
      WHERE of1.oe_field_id=oef.oe_field_id)
     ORDER BY od.order_id, od.oe_field_id, od.action_sequence DESC
     HEAD REPORT
      temp->qual[y].d_cnt = 0
     HEAD od.order_id
      stat = alterlist(temp->qual[y].d_qual,5), temp->qual[y].stat_ind = 0
     HEAD od.oe_field_id
      act_seq = od.action_sequence, odflag = 1
     HEAD od.action_sequence
      IF (act_seq != od.action_sequence)
       odflag = 0
      ENDIF
     DETAIL
      IF (odflag=1)
       temp->qual[y].d_cnt = (temp->qual[y].qual[z].d_cnt+ 1), dc = temp->qual[y].d_cnt
       IF (dc > size(temp->qual[y].d_qual,5))
        stat = alterlist(temp->qual[y].d_qual,(dc+ 5))
       ENDIF
       temp->qual[y].d_qual[dc].label_text = trim(oef.label_text), temp->qual[y].d_qual[dc].
       field_value = od.oe_field_value, temp->qual[y].d_qual[dc].group_seq = oef.group_seq,
       temp->qual[y].d_qual[dc].oe_field_meaning_id = od.oe_field_meaning_id, temp->qual[y].d_qual[dc
       ].value = trim(od.oe_field_display_value), temp->qual[y].d_qual[dc].clin_line_ind = oef
       .clin_line_ind,
       temp->qual[y].d_qual[dc].label = trim(oef.clin_line_label), temp->qual[y].d_qual[dc].suffix =
       oef.clin_suffix_ind
       IF (od.oe_field_display_value > " ")
        temp->qual[y].d_qual[dc].print_ind = 0
       ELSE
        temp->qual[y].d_qual[dc].print_ind = 1
       ENDIF
       IF (((od.oe_field_meaning_id=1100) OR (((od.oe_field_meaning_id=8) OR (((od
       .oe_field_meaning_id=127) OR (od.oe_field_meaning_id=43)) )) ))
        AND trim(cnvtupper(od.oe_field_display_value))="STAT")
        temp->qual[y].stat_ind = 1
       ENDIF
       IF (of1.field_type_flag=7)
        IF (od.oe_field_value=1)
         IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=1)) )
          temp->qual[y].d_qual[dc].value = trim(oef.label_text)
         ELSE
          temp->qual[y].d_qual[dc].clin_line_ind = 0
         ENDIF
        ELSE
         IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=2)) )
          temp->qual[y].d_qual[dc].value = trim(oef.clin_line_label)
         ELSE
          temp->qual[y].d_qual[dc].clin_line_ind = 0
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     FOOT  od.order_id
      stat = alterlist(temp->qual[y].d_qual,dc)
     WITH nocounter
    ;end select
    SET started_build_ind = 0
    FOR (fsub = 1 TO 31)
      FOR (xx = 1 TO temp->qual[y].d_cnt)
        IF ((((temp->qual[y].d_qual[xx].group_seq=fsub)) OR (fsub=31))
         AND (temp->qual[y].d_qual[xx].print_ind=0))
         SET temp->qual[y].d_qual[xx].print_ind = 1
         IF ((temp->qual[y].d_qual[xx].clin_line_ind=1))
          IF (started_build_ind=0)
           SET started_build_ind = 1
           IF ((temp->qual[y].d_qual[xx].suffix=0)
            AND (temp->qual[y].d_qual[xx].label > "  "))
            SET temp->qual[y].display = concat(trim(temp->qual[y].d_qual[xx].label)," ",trim(temp->
              qual[y].d_qual[xx].value))
           ELSEIF ((temp->qual[y].d_qual[xx].suffix=1)
            AND (temp->qual[y].d_qual[xx].label > " "))
            SET temp->qual[y].display = concat(trim(temp->qual[y].d_qual[xx].value)," ",trim(temp->
              qual[y].d_qual[xx].label))
           ELSE
            SET temp->qual[y].display = concat(trim(temp->qual[y].d_qual[xx].value)," ")
           ENDIF
          ELSE
           IF ((temp->qual[y].d_qual[xx].suffix=0)
            AND (temp->qual[y].d_qual[xx].label > "  "))
            SET temp->qual[y].display = concat(trim(temp->qual[y].display),",",trim(temp->qual[y].
              d_qual[xx].label)," ",trim(temp->qual[y].d_qual[xx].value))
           ELSEIF ((temp->qual[y].d_qual[xx].suffix=1)
            AND (temp->qual[y].d_qual[xx].label > " "))
            SET temp->qual[y].display = concat(trim(temp->qual[y].display),",",trim(temp->qual[y].
              d_qual[xx].value)," ",trim(temp->qual[y].d_qual[xx].label))
           ELSE
            SET temp->qual[y].display = concat(trim(temp->qual[y].display),",",trim(temp->qual[y].
              d_qual[xx].value)," ")
           ENDIF
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   SET pt->line_cnt = 0
   SET max_length = 55
   EXECUTE dcp_parse_text value(temp->qual[y].display), value(max_length)
   SET stat = alterlist(temp->qual[y].disp_qual,pt->line_cnt)
   SET temp->qual[y].disp_cnt = pt->line_cnt
   FOR (w = 1 TO pt->line_cnt)
     SET temp->qual[y].disp_qual[w].disp_line = pt->lns[w].line
   ENDFOR
   SET pt->line_cnt = 0
   SET max_length = 25
   EXECUTE dcp_parse_text value(temp->qual[y].mnemonic), value(max_length)
   SET stat = alterlist(temp->qual[y].m_qual,pt->line_cnt)
   SET temp->qual[y].m_cnt = pt->line_cnt
   FOR (w = 1 TO pt->line_cnt)
     SET temp->qual[y].m_qual[w].m_line = pt->lns[w].line
   ENDFOR
   IF ((temp->qual[y].com_ind=1))
    SELECT INTO "nl:"
     FROM order_comment oc,
      long_text lt
     PLAN (oc
      WHERE (oc.order_id=temp->qual[y].order_id)
       AND oc.comment_type_cd=ord_cd)
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
     HEAD REPORT
      blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," ")
     DETAIL
      blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), y1 = size(trim(lt
        .long_text)),
      blob_out = substring(1,y1,lt.long_text),
      CALL uar_rtf(blob_out,y1,blob_out2,32000,32000,0), temp->qual[y].comment = blob_out2
     WITH nocounter
    ;end select
    SET pt->line_cnt = 0
    SET max_length = 55
    IF ((temp->qual[y].comment > "  "))
     SET temp->qual[y].comment = concat("Comment: ",trim(temp->qual[y].comment))
    ENDIF
    EXECUTE dcp_parse_text value(temp->qual[y].comment), value(max_length)
    SET stat = alterlist(temp->qual[y].c_qual,pt->line_cnt)
    SET temp->qual[y].c_cnt = pt->line_cnt
    FOR (x = 1 TO pt->line_cnt)
      SET temp->qual[y].c_qual[x].c_line = pt->lns[x].line
    ENDFOR
   ENDIF
 ENDFOR
 SELECT INTO request->output_device
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   xcol = 0, ycol = 0, scol = 0,
   zcol = 0, line_cnt = 0
  HEAD PAGE
   "{cpi/10}{f/12}", row + 1, "{pos/220/50}{b}DIET ORDERS",
   row + 1, "{cpi/13}{f/8}", row + 1,
   "{pos/30/70}{b}Name: {endb}", name, row + 1,
   "{pos/30/80}{b}MRN: {endb}", mrn, row + 1,
   "{pos/30/90}{b}Location: {endb}", location, row + 1,
   "{pos/30/110}{b}{u}Date", row + 1, "{pos/100/110}{b}{u}Orderable",
   row + 1, "{pos/220/110}{b}{u}Details/Comments", row + 1,
   "{pos/500/110}{b}{u}Status", row + 1, "{cpi/14}",
   row + 1, ycol = 125
  DETAIL
   FOR (x = 1 TO temp->cnt)
     line_cnt = (temp->qual[x].disp_cnt+ temp->qual[x].c_cnt), add_line_ind = 0
     IF ((temp->qual[x].m_cnt > line_cnt))
      line_cnt = temp->qual[x].m_cnt, add_line_ind = 1
     ENDIF
     IF ((((line_cnt * 10)+ ycol) > 710))
      BREAK
     ENDIF
     xcol = 30,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].date,
     row + 1, xcol = 500,
     CALL print(calcpos(xcol,ycol)),
     temp->qual[x].status, row + 1, xcol = 100,
     scol = ycol
     FOR (z = 1 TO temp->qual[x].m_cnt)
       CALL print(calcpos(xcol,ycol)), temp->qual[x].m_qual[z].m_line, row + 1,
       ycol = (ycol+ 10), zcol = ycol
     ENDFOR
     ycol = scol, xcol = 220
     FOR (z = 1 TO temp->qual[x].disp_cnt)
       CALL print(calcpos(xcol,ycol)), temp->qual[x].disp_qual[z].disp_line, row + 1,
       ycol = (ycol+ 10)
     ENDFOR
     FOR (z = 1 TO temp->qual[x].c_cnt)
       CALL print(calcpos(xcol,ycol)), temp->qual[x].c_qual[z].c_line, row + 1,
       ycol = (ycol+ 10)
     ENDFOR
     IF (add_line_ind=1)
      ycol = zcol, ycol = (ycol+ 5)
     ELSE
      ycol = (ycol+ 5)
     ENDIF
   ENDFOR
  FOOT PAGE
   "{pos/200/750}Page: ", curpage"##", row + 1,
   "{pos/275/750}Print Date/Time: ", curdate, " ",
   curtime, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 800
 ;end select
#exit_script
END GO
