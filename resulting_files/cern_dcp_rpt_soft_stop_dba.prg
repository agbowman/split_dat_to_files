CREATE PROGRAM cern_dcp_rpt_soft_stop:dba
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 display = vc
     2 mnemonic = vc
     2 m_cnt = i2
     2 m_qual[*]
       3 m_line = vc
     2 disp_cnt = i2
     2 disp_qual[*]
       3 disp_line = vc
     2 start_date = vc
     2 soft_stop_date = vc
     2 comment_ind = i2
     2 iv_ind = i2
     2 order_id = f8
     2 blob_out = vc
     2 c_cnt = i2
     2 c_qual[*]
       3 c_line = vc
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
 SET lf = concat(char(13),char(10))
 SET person_id = 0
 SET location = fillstring(25," ")
 SET room = fillstring(20," ")
 SET unit = fillstring(20," ")
 SET bed = fillstring(20," ")
 SET name = fillstring(30," ")
 SET admitdoc = fillstring(30," ")
 SET sex = fillstring(10," ")
 SET mrn = fillstring(20," ")
 SET finnbr = fillstring(20," ")
 SET age = fillstring(10," ")
 SET date = fillstring(20," ")
 SET dob = fillstring(20," ")
 SET serv = fillstring(20," ")
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET ord_cd = 0
 SET code_value = 0
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "ORD COMMENT"
 EXECUTE cpm_get_cd_for_cdf
 SET ord_cd = code_value
 SET last_col = 765
 SET mrn_alias_cd = 0
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET attend_doc_cd = 0
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET finnbr_cd = 0
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
 SET new_order_cd = 0
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET new_order_cd = code_value
 SET inprocess_cd = 0
 SET code_set = 6004
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 SET code_set = 16389
 SET cdf_meaning = "IVSOLUTIONS"
 EXECUTE cpm_get_cd_for_cdf
 SET iv_cd = code_value
 SET mnem_disp_level = "1"
 SET iv_disp_level = "0"
 DECLARE tz_index = i4 WITH protect, noconstant(0)
 DECLARE offset = i2 WITH protect, noconstant(0)
 DECLARE daylight = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM name_value_prefs n
  PLAN (n
   WHERE n.pvc_name IN ("MNEM_DISP_LEVEL", "IV_DISP_LEVEL"))
  DETAIL
   IF (n.pvc_name="MNEM_DISP_LEVEL"
    AND n.pvc_value IN ("0", "1", "2"))
    mnem_disp_level = n.pvc_value
   ELSEIF (n.pvc_name="IV_DISP_LEVEL"
    AND n.pvc_value IN ("0", "1"))
    iv_disp_level = n.pvc_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   (dummyt d1  WITH seq = 1),
   person_alias pa,
   (dummyt d2  WITH seq = 1),
   encntr_prsnl_reltn epr,
   (dummyt d3  WITH seq = 1),
   encntr_alias ea,
   prsnl pl,
   encntr_loc_hist elh,
   time_zone_r t
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id)
   JOIN (t
   WHERE t.parent_entity_id=outerjoin(elh.loc_facility_cd)
    AND t.parent_entity_name=outerjoin("LOCATION"))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1)
   JOIN (d2)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_doc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (d3)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr_cd)
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   person_id = p.person_id, name = substring(1,30,p.name_full_formatted), age = cnvtage(cnvtdate(p
     .birth_dt_tm),curdate),
   mrn = substring(1,20,cnvtalias(pa.alias,pa.alias_pool_cd)), finnbr = substring(1,20,cnvtalias(ea
     .alias,ea.alias_pool_cd)), admitdoc = substring(1,30,pl.name_full_formatted),
   unit = substring(1,20,uar_get_code_display(e.loc_nurse_unit_cd)), room = substring(1,20,
    uar_get_code_display(e.loc_room_cd)), bed = substring(1,20,uar_get_code_display(e.loc_bed_cd)),
   sex = substring(1,10,uar_get_code_display(p.sex_cd)), dob = concat(format(datetimezone(p
      .birth_dt_tm,p.birth_tz),"@SHORTDATE")," ",datetimezonebyindex(p.birth_tz,offset,daylight,7,p
     .birth_dt_tm)), tz_index = datetimezonebyname(trim(t.time_zone)),
   date = concat(format(datetimezone(e.reg_dt_tm,tz_index),"@SHORTDATE")," ",datetimezonebyindex(
     tz_index,offset,daylight,7,e.reg_dt_tm)), serv = substring(1,20,uar_get_code_display(e
     .med_service_cd)), location = concat(trim(unit),"/",trim(room),"/",trim(bed))
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   dontcare = pa, dontcare = epr, outerjoin = d3,
   dontcare = ea
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND o.catalog_type_cd=pharmacy_cd
    AND o.order_status_cd IN (new_order_cd, inprocess_cd)
    AND o.template_order_flag != 2
    AND o.template_order_flag != 4
    AND o.soft_stop_dt_tm < cnvtdatetime((curdate+ 1),curtime))
  ORDER BY cnvtdatetime(o.soft_stop_dt_tm)
  HEAD REPORT
   temp->cnt = 0
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].display
    = o.clinical_display_line
   IF (((mnem_disp_level="0"
    AND o.iv_ind != 1) OR (iv_disp_level="0"
    AND o.iv_ind=1)) )
    temp->qual[temp->cnt].mnemonic = trim(o.hna_order_mnemonic)
   ENDIF
   IF (((mnem_disp_level="1"
    AND o.iv_ind != 1) OR (iv_disp_level="1"
    AND o.iv_ind=1)) )
    IF (o.hna_order_mnemonic=o.ordered_as_mnemonic)
     temp->qual[temp->cnt].mnemonic = trim(o.hna_order_mnemonic)
    ELSE
     temp->qual[temp->cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"(",trim(o
       .ordered_as_mnemonic),")")
    ENDIF
   ENDIF
   IF (mnem_disp_level="2"
    AND o.iv_ind != 1)
    IF (o.hna_order_mnemonic=o.ordered_as_mnemonic)
     temp->qual[temp->cnt].mnemonic = trim(o.hna_order_mnemonic)
    ELSE
     temp->qual[temp->cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"(",trim(o
       .ordered_as_mnemonic),")")
    ENDIF
    IF (o.order_mnemonic != o.ordered_as_mnemonic)
     temp->qual[temp->cnt].mnemonic = concat(trim(temp->qual[temp->cnt].mnemonic),"(",trim(o
       .order_mnemonic),")")
    ENDIF
   ENDIF
   temp->qual[temp->cnt].start_date = concat(format(datetimezone(o.current_start_dt_tm,o
      .current_start_tz),"@SHORTDATETIME")," ",datetimezonebyindex(o.current_start_tz,offset,daylight,
     7,o.current_start_dt_tm)), temp->qual[temp->cnt].comment_ind = o.order_comment_ind, temp->qual[
   temp->cnt].order_id = o.order_id,
   temp->qual[temp->cnt].soft_stop_date = concat(format(datetimezone(o.soft_stop_dt_tm,o.soft_stop_tz
      ),"@SHORTDATETIME")," ",datetimezonebyindex(o.soft_stop_tz,offset,daylight,7,o.soft_stop_dt_tm)
    ), temp->qual[temp->cnt].iv_ind = o.iv_ind
   IF (o.dcp_clin_cat_cd=iv_cd)
    temp->qual[temp->cnt].iv_ind = 1
   ENDIF
   temp->qual[temp->cnt].oe_format_id = o.oe_format_id
   IF (substring(245,10,o.clinical_display_line) > "  ")
    temp->qual[temp->cnt].clin_line_ind = 1
   ELSE
    temp->qual[temp->cnt].clin_line_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 FOR (y = 1 TO temp->cnt)
   IF ((temp->qual[y].iv_ind=1))
    SELECT INTO "nl:"
     FROM order_ingredient oi
     PLAN (oi
      WHERE (oi.order_id=temp->qual[y].order_id))
     ORDER BY oi.action_sequence, oi.comp_sequence
     HEAD oi.action_sequence
      mnemonic_line = fillstring(1000," "), first_time = "Y"
     DETAIL
      IF (first_time="Y")
       IF (oi.ordered_as_mnemonic > " ")
        mnemonic_line = concat(trim(oi.ordered_as_mnemonic),", ",trim(oi.order_detail_display_line))
       ELSE
        mnemonic_line = concat(trim(oi.order_mnemonic),", ",trim(oi.order_detail_display_line))
       ENDIF
       first_time = "N"
      ELSE
       IF (oi.ordered_as_mnemonic > " ")
        mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.ordered_as_mnemonic),", ",trim(oi
          .order_detail_display_line))
       ELSE
        mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.order_mnemonic),", ",trim(oi
          .order_detail_display_line))
       ENDIF
      ENDIF
     FOOT REPORT
      temp->qual[y].mnemonic = mnemonic_line
     WITH nocounter
    ;end select
   ENDIF
   SET pt->line_cnt = 0
   SET max_length = 33
   EXECUTE dcp_parse_text value(temp->qual[y].mnemonic), value(max_length)
   SET stat = alterlist(temp->qual[y].m_qual,pt->line_cnt)
   SET temp->qual[y].m_cnt = pt->line_cnt
   FOR (w = 1 TO pt->line_cnt)
     SET temp->qual[y].m_qual[w].m_line = pt->lns[w].line
   ENDFOR
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
       temp->qual[y].d_cnt = (temp->qual[y].d_cnt+ 1), dc = temp->qual[y].d_cnt
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
   SET max_length = 75
   SET a = findstring(lf,temp->qual[y].display)
   WHILE (a > 0)
    SET stat = movestring("  ",1,temp->qual[y].display,a,2)
    SET a = findstring(lf,temp->qual[y].display)
   ENDWHILE
   EXECUTE dcp_parse_text value(temp->qual[y].display), value(max_length)
   SET stat = alterlist(temp->qual[y].disp_qual,pt->line_cnt)
   SET temp->qual[y].disp_cnt = pt->line_cnt
   FOR (w = 1 TO pt->line_cnt)
     SET temp->qual[y].disp_qual[w].disp_line = pt->lns[w].line
   ENDFOR
   IF ((temp->qual[y].comment_ind=1))
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
      CALL uar_rtf(blob_out,y1,blob_out2,32000,32000,0), temp->qual[y].blob_out = blob_out2
     WITH nocounter
    ;end select
    SET a = findstring(lf,temp->qual[y].blob_out)
    WHILE (a > 0)
     SET stat = movestring("  ",1,temp->qual[y].blob_out,a,2)
     SET a = findstring(lf,temp->qual[y].blob_out)
    ENDWHILE
    SET pt->line_cnt = 0
    SET max_length = 75
    IF ((temp->qual[y].blob_out > " "))
     SET temp->qual[y].blob_out = concat("Comment: ",trim(temp->qual[y].blob_out))
     EXECUTE dcp_parse_text value(temp->qual[y].blob_out), value(max_length)
     SET stat = alterlist(temp->qual[y].c_qual,pt->line_cnt)
     SET temp->qual[y].c_cnt = pt->line_cnt
     FOR (x = 1 TO pt->line_cnt)
       SET temp->qual[y].c_qual[x].c_line = pt->lns[x].line
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO request->output_device
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   xcol = 0, ycol = 0, scol = 0,
   zcol = 0, line_cnt = 0
  HEAD PAGE
   "{cpi/10}{f/12}", row + 1, "{pos/200/50}{b}SOFT STOP ORDERS",
   row + 1, "{cpi/13}{f/8}", row + 1,
   "{pos/30/70}{b}Name: {endb}", name, row + 1,
   "{pos/30/80}{b}MRN: {endb}", mrn, row + 1,
   "{pos/30/90}{b}Location: {endb}", location, row + 1,
   "{pos/30/110}{b}{u}Stop Date", row + 1, "{pos/130/110}{b}{u}Orderable",
   row + 1, "{pos/280/110}{b}{u}Details/Comments", row + 1,
   "{cpi/14}", row + 1, ycol = 125
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
     CALL print(calcpos(xcol,ycol)), temp->qual[x].soft_stop_date,
     row + 1, xcol = 130, scol = ycol
     FOR (z = 1 TO temp->qual[x].m_cnt)
       CALL print(calcpos(xcol,ycol)), temp->qual[x].m_qual[z].m_line, row + 1,
       ycol = (ycol+ 10), zcol = ycol
     ENDFOR
     ycol = scol, xcol = 280
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
  WITH nocounter, maxrow = 200, maxcol = 500,
   dio = postscript
 ;end select
#exit_script
END GO
