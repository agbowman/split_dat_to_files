CREATE PROGRAM cern_dcp_rpt_diet_sum:dba
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 location = vc
     2 print_ind = i2
     2 encntr_id = f8
     2 name = vc
     2 mrn = vc
     2 cnt = i2
     2 qual[*]
       3 order_id = f8
       3 com_ind = i2
       3 comment = vc
       3 com_ln_cnt = i2
       3 com_tag[*]
         4 com_line = vc
       3 date = vc
       3 display = vc
       3 list_ln_cnt = i2
       3 list_tag[*]
         4 list_line = vc
       3 mnemonic = vc
       3 oe_format_id = f8
       3 clin_line_ind = i2
       3 stat_ind = i2
       3 d_cnt = i2
       3 d_qual[*]
         4 field_description = vc
         4 label_text = vc
         4 value = vc
         4 field_value = f8
         4 oe_field_meaning_id = f8
         4 group_seq = i4
         4 print_ind = i2
         4 clin_line_ind = i2
         4 label = vc
         4 suffix = i2
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET modify = predeclare
 DECLARE mrn_alias_cd = f8 WITH noconstant(0.0)
 DECLARE ord_cd = f8 WITH noconstant(0.0)
 DECLARE order_cd = f8 WITH noconstant(0.0)
 DECLARE inprocess_cd = f8 WITH noconstant(0.0)
 DECLARE future_cd = f8 WITH noconstant(0.0)
 DECLARE census_cd = f8 WITH noconstant(0.0)
 DECLARE diet_cd = f8 WITH noconstant(0.0)
 DECLARE max_length = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 SET mrn_alias_cd = uar_get_code_by("MEANING",319,"MRN")
 SET ord_cd = uar_get_code_by("MEANING",14,"ORD COMMENT")
 SET order_cd = uar_get_code_by("MEANING",6004,"ORDERED")
 SET inprocess_cd = uar_get_code_by("MEANING",6004,"INPROCESS")
 SET future_cd = uar_get_code_by("MEANING",6004,"FUTURE")
 SET census_cd = uar_get_code_by("MEANING",339,"CENSUS")
 SET diet_cd = uar_get_code_by("MEANING",6000,"DIETARY")
 CALL echo(build("unit_cd = ",unit_cd))
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   person p,
   (dummyt d1  WITH seq = 1),
   encntr_alias ea
  PLAN (ed
   WHERE ed.encntr_domain_type_cd=census_cd
    AND ed.loc_nurse_unit_cd=unit_cd
    AND ed.active_ind=1
    AND ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=ed.person_id)
   JOIN (d1)
   JOIN (ea
   WHERE ea.encntr_id=ed.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_cd
    AND ea.active_ind=1)
  ORDER BY ed.loc_nurse_unit_cd, ed.loc_room_cd, ed.loc_bed_cd
  HEAD REPORT
   temp->cnt = 0
  HEAD ed.encntr_id
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].
   encntr_id = ed.encntr_id,
   temp->qual[temp->cnt].print_ind = 0, temp->qual[temp->cnt].name = p.name_full_formatted, temp->
   qual[temp->cnt].mrn = cnvtalias(ea.alias,ea.alias_pool_cd),
   temp->qual[temp->cnt].location = concat(trim(uar_get_code_display(ed.loc_nurse_unit_cd)),"/",trim(
     uar_get_code_display(ed.loc_room_cd)),"/",trim(uar_get_code_display(ed.loc_bed_cd)))
  WITH nocounter, outerjoin = d1, dontcare = ea
 ;end select
 IF ((temp->cnt=0))
  GO TO script_failed
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->cnt)),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=temp->qual[d.seq].encntr_id)
    AND o.order_status_cd IN (order_cd, inprocess_cd, future_cd)
    AND o.catalog_type_cd=diet_cd)
  ORDER BY o.encntr_id, o.orig_order_dt_tm
  HEAD o.encntr_id
   temp->qual[d.seq].print_ind = 1, cnt = 0, offset = 0,
   daylight = 0
  DETAIL
   cnt = (cnt+ 1), temp->qual[d.seq].cnt = cnt, stat = alterlist(temp->qual[d.seq].qual,cnt),
   temp->qual[d.seq].qual[cnt].display = o.clinical_display_line, temp->qual[d.seq].qual[cnt].
   order_id = o.order_id, temp->qual[d.seq].qual[cnt].oe_format_id = o.oe_format_id
   IF (substring(240,10,o.clinical_display_line) > "  ")
    temp->qual[d.seq].qual[cnt].clin_line_ind = 1
   ELSE
    temp->qual[d.seq].qual[cnt].clin_line_ind = 0
   ENDIF
   temp->qual[d.seq].qual[cnt].mnemonic = o.hna_order_mnemonic, temp->qual[d.seq].qual[cnt].date =
   concat(format(datetimezone(o.orig_order_dt_tm,o.orig_order_tz),"@SHORTDATETIME")," ",
    datetimezonebyindex(o.orig_order_tz,offset,daylight,7,o.orig_order_dt_tm)), temp->qual[d.seq].
   qual[cnt].com_ind = o.order_comment_ind
  WITH nocounter
 ;end select
 FOR (y = 1 TO temp->cnt)
   FOR (z = 1 TO temp->qual[y].cnt)
     IF ((temp->qual[y].qual[z].clin_line_ind=1))
      SELECT INTO "nl:"
       FROM order_detail od,
        order_entry_fields of1,
        oe_format_fields oef
       PLAN (od
        WHERE (temp->qual[y].qual[z].order_id=od.order_id))
        JOIN (oef
        WHERE (oef.oe_format_id=temp->qual[y].qual[z].oe_format_id)
         AND oef.oe_field_id=od.oe_field_id)
        JOIN (of1
        WHERE of1.oe_field_id=oef.oe_field_id)
       ORDER BY od.order_id, od.oe_field_id, od.action_sequence DESC
       HEAD REPORT
        temp->qual[y].qual[z].d_cnt = 0
       HEAD od.order_id
        stat = alterlist(temp->qual[y].qual[z].d_qual,5), temp->qual[y].qual[z].stat_ind = 0
       HEAD od.oe_field_id
        act_seq = od.action_sequence, odflag = 1
       HEAD od.action_sequence
        IF (act_seq != od.action_sequence)
         odflag = 0
        ENDIF
       DETAIL
        IF (odflag=1)
         temp->qual[y].qual[z].d_cnt = (temp->qual[y].qual[z].d_cnt+ 1), dc = temp->qual[y].qual[z].
         d_cnt
         IF (dc > size(temp->qual[y].qual[z].d_qual,5))
          stat = alterlist(temp->qual[y].qual[z].d_qual,(dc+ 5))
         ENDIF
         temp->qual[y].qual[z].d_qual[dc].label_text = trim(oef.label_text), temp->qual[y].qual[z].
         d_qual[dc].field_value = od.oe_field_value, temp->qual[y].qual[z].d_qual[dc].group_seq = oef
         .group_seq,
         temp->qual[y].qual[z].d_qual[dc].oe_field_meaning_id = od.oe_field_meaning_id, temp->qual[y]
         .qual[z].d_qual[dc].value = trim(od.oe_field_display_value), temp->qual[y].qual[z].d_qual[dc
         ].clin_line_ind = oef.clin_line_ind,
         temp->qual[y].qual[z].d_qual[dc].label = trim(oef.clin_line_label), temp->qual[y].qual[z].
         d_qual[dc].suffix = oef.clin_suffix_ind
         IF (od.oe_field_display_value > " ")
          temp->qual[y].qual[z].d_qual[dc].print_ind = 0
         ELSE
          temp->qual[y].qual[z].d_qual[dc].print_ind = 1
         ENDIF
         IF (((od.oe_field_meaning_id=1100) OR (((od.oe_field_meaning_id=8) OR (((od
         .oe_field_meaning_id=127) OR (od.oe_field_meaning_id=43)) )) ))
          AND trim(cnvtupper(od.oe_field_display_value))="STAT")
          temp->qual[y].qual[z].stat_ind = 1
         ENDIF
         IF (of1.field_type_flag=7)
          IF (od.oe_field_value=1)
           IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=1)) )
            temp->qual[y].qual[z].d_qual[dc].value = trim(oef.label_text)
           ELSE
            temp->qual[y].qual[z].d_qual[dc].clin_line_ind = 0
           ENDIF
          ELSE
           IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=2)) )
            temp->qual[y].qual[z].d_qual[dc].value = trim(oef.clin_line_label)
           ELSE
            temp->qual[y].qual[z].d_qual[dc].clin_line_ind = 0
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       FOOT  od.order_id
        stat = alterlist(temp->qual[y].qual[z].d_qual,dc)
       WITH nocounter
      ;end select
      SET started_build_ind = 0
      FOR (fsub = 1 TO 31)
        FOR (xx = 1 TO temp->qual[y].qual[z].d_cnt)
          IF ((((temp->qual[y].qual[z].d_qual[xx].group_seq=fsub)) OR (fsub=31))
           AND (temp->qual[y].qual[z].d_qual[xx].print_ind=0))
           SET temp->qual[y].qual[z].d_qual[xx].print_ind = 1
           IF ((temp->qual[y].qual[z].d_qual[xx].clin_line_ind=1))
            IF (started_build_ind=0)
             SET started_build_ind = 1
             IF ((temp->qual[y].qual[z].d_qual[xx].suffix=0)
              AND (temp->qual[y].qual[z].d_qual[xx].label > "  "))
              SET temp->qual[y].qual[z].display = concat(trim(temp->qual[y].qual[z].d_qual[xx].label),
               " ",trim(temp->qual[y].qual[z].d_qual[xx].value))
             ELSEIF ((temp->qual[y].qual[z].d_qual[xx].suffix=1)
              AND (temp->qual[y].qual[z].d_qual[xx].label > " "))
              SET temp->qual[y].qual[z].display = concat(trim(temp->qual[y].qual[z].d_qual[xx].value),
               " ",trim(temp->qual[y].qual[z].d_qual[xx].label))
             ELSE
              SET temp->qual[y].qual[z].display = concat(trim(temp->qual[y].qual[z].d_qual[xx].value),
               " ")
             ENDIF
            ELSE
             IF ((temp->qual[y].qual[z].d_qual[xx].suffix=0)
              AND (temp->qual[y].qual[z].d_qual[xx].label > "  "))
              SET temp->qual[y].qual[z].display = concat(trim(temp->qual[y].qual[z].display),",",trim
               (temp->qual[y].qual[z].d_qual[xx].label)," ",trim(temp->qual[y].qual[z].d_qual[xx].
                value))
             ELSEIF ((temp->qual[y].qual[z].d_qual[xx].suffix=1)
              AND (temp->qual[y].qual[z].d_qual[xx].label > " "))
              SET temp->qual[y].qual[z].display = concat(trim(temp->qual[y].qual[z].display),",",trim
               (temp->qual[y].qual[z].d_qual[xx].value)," ",trim(temp->qual[y].qual[z].d_qual[xx].
                label))
             ELSE
              SET temp->qual[y].qual[z].display = concat(trim(temp->qual[y].qual[z].display),",",trim
               (temp->qual[y].qual[z].d_qual[xx].value)," ")
             ENDIF
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
     SET pt->line_cnt = 0
     SET max_length = 50
     SET modify = nopredeclare
     EXECUTE dcp_parse_text value(temp->qual[y].qual[z].display), value(max_length)
     SET modify = predeclare
     SET stat = alterlist(temp->qual[y].qual[z].list_tag,pt->line_cnt)
     SET temp->qual[y].qual[z].list_ln_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->qual[y].qual[z].list_tag[w].list_line = pt->lns[w].line
     ENDFOR
     IF ((temp->qual[y].qual[z].com_ind=1))
      SELECT INTO "nl:"
       FROM order_comment oc,
        long_text lt
       PLAN (oc
        WHERE (oc.order_id=temp->qual[y].qual[z].order_id)
         AND oc.comment_type_cd=ord_cd)
        JOIN (lt
        WHERE lt.long_text_id=oc.long_text_id)
       HEAD REPORT
        blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," ")
       DETAIL
        blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), y1 = size(trim(lt
          .long_text)),
        blob_out = substring(1,y1,lt.long_text),
        CALL uar_rtf(blob_out,y1,blob_out2,32000,32000,0), temp->qual[y].qual[z].comment = blob_out2
       WITH nocounter
      ;end select
      SET pt->line_cnt = 0
      SET max_length = 50
      IF ((temp->qual[y].qual[z].comment > "  "))
       SET temp->qual[y].qual[z].comment = concat("Comment: ",trim(temp->qual[y].qual[z].comment))
      ENDIF
      SET modify = nopredeclare
      EXECUTE dcp_parse_text value(temp->qual[y].qual[z].comment), value(max_length)
      SET modify = predeclare
      SET stat = alterlist(temp->qual[y].qual[z].com_tag,pt->line_cnt)
      SET temp->qual[y].qual[z].com_ln_cnt = pt->line_cnt
      FOR (x = 1 TO pt->line_cnt)
        SET temp->qual[y].qual[z].com_tag[x].com_line = pt->lns[x].line
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO request->output_device
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   xcol = 0, ycol = 0, line_cnt = 0,
   line = concat("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",
    "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ","- - - - - - - - - - - - -")
  HEAD PAGE
   "{f/9}{cpi/10}", row + 1, "{pos/200/40}Active Diet Orders Summary",
   row + 1, "{f/8}{cpi/14}", row + 1,
   "{pos/30/90}{b}{u}Location", row + 1, "{pos/130/90}{b}{u}Name",
   row + 1, "{pos/250/90}{b}{u}MRN", row + 1,
   "{pos/325/90}{b}{u}Orderable/Details", row + 1, ycol = 102
  DETAIL
   FOR (y = 1 TO temp->cnt)
     IF ((temp->qual[y].print_ind=1))
      FOR (x = 1 TO temp->qual[y].cnt)
        line_cnt = ((temp->qual[y].qual[x].list_ln_cnt+ 1)+ temp->qual[y].qual[x].com_ln_cnt)
        IF ((((line_cnt * 10)+ ycol) > 715))
         BREAK
        ENDIF
        xcol = 30,
        CALL print(calcpos(xcol,ycol)), temp->qual[y].location,
        row + 1, xcol = 130,
        CALL print(calcpos(xcol,ycol)),
        temp->qual[y].name, row + 1, xcol = 250,
        CALL print(calcpos(xcol,ycol)), temp->qual[y].mrn, row + 1,
        xcol = 325,
        CALL print(calcpos(xcol,ycol)), temp->qual[y].qual[x].mnemonic,
        row + 1, ycol = (ycol+ 10)
        FOR (z = 1 TO temp->qual[y].qual[x].list_ln_cnt)
          xcol = 325,
          CALL print(calcpos(xcol,ycol)), temp->qual[y].qual[x].list_tag[z].list_line,
          row + 1, ycol = (ycol+ 10)
        ENDFOR
        IF ((temp->qual[y].qual[x].com_ind=1))
         FOR (z = 1 TO temp->qual[y].qual[x].com_ln_cnt)
           xcol = 325,
           CALL print(calcpos(xcol,ycol)), temp->qual[y].qual[x].com_tag[z].com_line,
           row + 1, ycol = (ycol+ 10)
         ENDFOR
        ENDIF
        xcol = 30,
        CALL print(calcpos(xcol,ycol)), line,
        row + 1, ycol = (ycol+ 8)
      ENDFOR
     ENDIF
   ENDFOR
  FOOT PAGE
   "{pos/200/750}Page: ", curpage"##", row + 1,
   "{pos/275/750}Print Date/Time: ", curdate, " ",
   curtime, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 800
 ;end select
 GO TO exit_script
#script_failed
 SELECT INTO request->output_device
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   xcol = 0, ycol = 0, line_cnt = 0,
   line = concat("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",
    "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ","- - - - - - - - - - - - -")
  HEAD PAGE
   "{f/9}{cpi/10}", row + 1, "{pos/200/40}Active Diet Orders Summary",
   row + 1, "{f/8}{cpi/14}", row + 1,
   "{pos/30/90}{b}{u}Location", row + 1, "{pos/130/90}{b}{u}Name",
   row + 1, "{pos/250/90}{b}{u}MRN", row + 1,
   "{pos/325/90}{b}{u}Orderable/Details", row + 1, ycol = 102,
   "{pos/30/102}{b}Report Failed: Invalid unit_cd or no encounters qualified.", row + 1
  FOOT PAGE
   "{pos/200/750}Page: ", curpage"##", row + 1,
   "{pos/275/750}Print Date/Time: ", curdate, " ",
   curtime, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 800
 ;end select
#exit_script
END GO
