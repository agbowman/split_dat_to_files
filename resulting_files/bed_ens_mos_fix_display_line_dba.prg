CREATE PROGRAM bed_ens_mos_fix_display_line:dba
 FREE SET reply
 RECORD reply(
   1 synonyms[*]
     2 id = f8
     2 sentences[*]
       3 id = f8
       3 display_line = vc
       3 full_display_line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 os[*]
     2 os_id = f8
     2 sequence = i4
     2 osdv = vc
     2 display = vc
     2 code_set = i4
 )
 RECORD temp0(
   1 os[*]
     2 os_id = f8
     2 sequence = i4
     2 osdv = vc
     2 display = vc
     2 code_set = i4
     2 cnt = i2
 )
 RECORD temp2(
   1 os[*]
     2 os_id = f8
     2 oe_format_id = f8
     2 old_osdl = vc
     2 new_osdl = vc
     2 osd[*]
       3 sequence = i4
       3 osdv = vc
       3 ofm_id = f8
       3 of_id = f8
       3 field_seq = i4
       3 group_seq = i4
 )
 RECORD temp3(
   1 os[*]
     2 os_id = f8
     2 oe_format_id = f8
     2 old_osdl = vc
     2 new_osdl = vc
     2 osd[*]
       3 sequence = i4
       3 osdv = vc
       3 ofm_id = f8
       3 of_id = f8
       3 field_seq = i4
       3 group_seq = i4
 )
 RECORD temp_reply(
   1 synonyms[*]
     2 id = f8
     2 sentences[*]
       3 id = f8
       3 display_line = vc
       3 full_display_line = vc
       3 oe_format_id = f8
       3 details[*]
         4 oe_field_id = f8
         4 oe_field_label = vc
         4 field_disp_value = vc
         4 field_code_value = f8
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET request_syncnt = 0
 SET request_syncnt = size(request->synonyms,5)
 IF (request_syncnt=0)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SET tempcnt = 0
 SET temp0cnt = 0
 SET temp2cnt = 0
 SET temp3cnt = 0
 DECLARE str1 = vc
 DECLARE str2 = vc
 DECLARE dline = vc
 SET pharmacy_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="PHARMACY"
  DETAIL
   pharmacy_cd = cv.code_value
  WITH nocounter
 ;end select
 SET primary_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
  DETAIL
   primary_cd = cv.code_value
  WITH nocounter
 ;end select
 SET order_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6003
   AND cv.cdf_meaning="DISORDER"
  DETAIL
   order_cd = cv.code_value
  WITH nocounter
 ;end select
 SET prn_id = 0.0
 SELECT INTO "nl:"
  FROM oe_field_meaning o
  WHERE o.oe_field_meaning="SCH/PRN"
  DETAIL
   prn_id = o.oe_field_meaning_id
  WITH nocounter
 ;end select
 SUBROUTINE compare_sent(cs_old,cs_new)
   IF (cs_old=cs_new)
    RETURN(1.0)
   ELSE
    IF (cs_old="<empty>*"
     AND cs_new="<empty>*")
     RETURN(1.0)
    ELSE
     SET str1 = replace(cs_old," ","",0)
     SET str2 = replace(cs_new," ","",0)
     IF (str1=str2)
      RETURN(1.0)
     ELSE
      RETURN(- (1.0))
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = request_syncnt),
   ord_cat_sent_r ocsr,
   order_sentence os,
   order_sentence_detail od,
   code_value c
  PLAN (d)
   JOIN (ocsr
   WHERE (ocsr.synonym_id=request->synonyms[d.seq].id)
    AND ocsr.active_ind=1)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag=2)
   JOIN (od
   WHERE od.order_sentence_id=os.order_sentence_id
    AND od.field_type_flag IN (6, 9, 12)
    AND  NOT (od.oe_field_meaning_id IN (48, 123))
    AND ((od.oe_field_value > 0) OR (od.default_parent_entity_id > 0)) )
   JOIN (c
   WHERE ((c.code_value=od.default_parent_entity_id
    AND c.code_value > 0) OR (c.code_value=od.oe_field_value
    AND c.code_value > 0))
    AND ((c.display != substring(1,40,od.oe_field_display_value)) OR (c.code_set IN (1028, 2052, 2054,
   1309)
    AND c.description != substring(1,60,od.oe_field_display_value)))
    AND c.active_ind=1)
  HEAD REPORT
   tempcnt = 0
  DETAIL
   tempcnt = (tempcnt+ 1), stat = alterlist(temp->os,tempcnt), temp->os[tempcnt].os_id = od
   .order_sentence_id,
   temp->os[tempcnt].sequence = od.sequence
   IF (od.oe_field_display_value <= "                          ")
    temp->os[tempcnt].osdv = "<blank>"
   ELSE
    temp->os[tempcnt].osdv = trim(od.oe_field_display_value)
   ENDIF
   IF (c.code_set IN (1028, 2052, 2054, 1309))
    IF (c.description <= "                        ")
     temp->os[tempcnt].display = "<blank>"
    ELSE
     temp->os[tempcnt].display = trim(c.description)
    ENDIF
   ELSE
    IF (c.display <= "                        ")
     temp->os[tempcnt].display = "<blank>"
    ELSE
     temp->os[tempcnt].display = trim(c.display)
    ENDIF
   ENDIF
   temp->os[tempcnt].code_set = c.code_set
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = request_syncnt),
   ord_cat_sent_r ocsr,
   order_sentence os,
   order_sentence_detail od,
   code_value c
  PLAN (d)
   JOIN (ocsr
   WHERE (ocsr.synonym_id=request->synonyms[d.seq].id)
    AND ocsr.active_ind=1)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag=2)
   JOIN (od
   WHERE od.order_sentence_id=os.order_sentence_id
    AND od.field_type_flag IN (6, 9, 12)
    AND  NOT (od.oe_field_meaning_id IN (48, 123))
    AND od.default_parent_entity_id > 0)
   JOIN (c
   WHERE c.code_value=od.default_parent_entity_id
    AND ((c.display != substring(1,40,od.oe_field_display_value)) OR (c.code_set IN (1028, 2052, 2054,
   1309)
    AND c.description != substring(1,60,od.oe_field_display_value)))
    AND c.active_ind=1)
  DETAIL
   tempcnt = (tempcnt+ 1), stat = alterlist(temp->os,tempcnt), temp->os[tempcnt].os_id = od
   .order_sentence_id,
   temp->os[tempcnt].sequence = od.sequence
   IF (od.oe_field_display_value <= "                          ")
    temp->os[tempcnt].osdv = "<blank>"
   ELSE
    temp->os[tempcnt].osdv = trim(od.oe_field_display_value)
   ENDIF
   IF (c.code_set IN (1028, 2052, 2054, 1309))
    IF (c.description <= "                        ")
     temp->os[tempcnt].display = "<blank>"
    ELSE
     temp->os[tempcnt].display = trim(c.description)
    ENDIF
   ELSE
    IF (c.display <= "                        ")
     temp->os[tempcnt].display = "<blank>"
    ELSE
     temp->os[tempcnt].display = trim(c.display)
    ENDIF
   ENDIF
   temp->os[tempcnt].code_set = c.code_set
  WITH nocounter
 ;end select
 IF (tempcnt > 0)
  SELECT INTO "nl:"
   cs = temp->os[d.seq].code_set, disp = temp->os[d.seq].display
   FROM (dummyt d  WITH seq = tempcnt)
   ORDER BY temp->os[d.seq].code_set, temp->os[d.seq].display
   HEAD REPORT
    temp0cnt = 0
   HEAD disp
    temp0cnt = (temp0cnt+ 1), stat = alterlist(temp0->os,temp0cnt), temp0->os[temp0cnt].code_set =
    temp->os[d.seq].code_set,
    temp0->os[temp0cnt].display = temp->os[d.seq].display, temp0->os[temp0cnt].osdv = temp->os[d.seq]
    .osdv, temp0->os[temp0cnt].cnt = 0
   DETAIL
    temp0->os[temp0cnt].cnt = (temp0->os[temp0cnt].cnt+ 1)
   WITH nocounter
  ;end select
  IF (temp0cnt > 0)
   SET hold_os_id = 0
   SET temp2cnt = 0
   FOR (x = 1 TO tempcnt)
     IF ((temp->os[x].display="<blank>"))
      SET temp->os[x].display = " "
     ENDIF
     UPDATE  FROM order_sentence_detail od
      SET od.oe_field_display_value = temp->os[x].display, od.updt_id = 286, od.updt_dt_tm =
       cnvtdatetime(curdate,curtime),
       od.updt_cnt = (od.updt_cnt+ 1), od.updt_applctx = 0, od.updt_task = 0
      WHERE (od.order_sentence_id=temp->os[x].os_id)
       AND (od.sequence=temp->os[x].sequence)
      WITH nocounter
     ;end update
     IF ((temp->os[x].os_id != hold_os_id))
      SET temp2cnt = (temp2cnt+ 1)
      SET stat = alterlist(temp2->os,temp2cnt)
      SET temp2->os[temp2cnt].os_id = temp->os[x].os_id
      SET hold_os_id = temp->os[x].os_id
      SET temp2->os[temp2cnt].old_osdl = "<empty>"
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET sent_count = 0
 SET cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = request_syncnt),
   ord_cat_sent_r ocsr,
   order_sentence os,
   order_sentence_detail osd,
   order_entry_format oef,
   oe_format_fields off
  PLAN (d)
   JOIN (ocsr
   WHERE (ocsr.synonym_id=request->synonyms[d.seq].id)
    AND ocsr.active_ind=1)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.oe_format_id > 0
    AND os.usage_flag=2)
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
   JOIN (oef
   WHERE oef.oe_format_id=os.oe_format_id
    AND oef.catalog_type_cd=pharmacy_cd
    AND ((oef.action_type_cd+ 0)=order_cd))
   JOIN (off
   WHERE off.oe_format_id=os.oe_format_id
    AND ((off.action_type_cd+ 0)=order_cd)
    AND off.oe_field_id=osd.oe_field_id)
  ORDER BY os.order_sentence_id, off.group_seq, off.field_seq
  HEAD REPORT
   scnt = 0
  HEAD os.order_sentence_id
   scnt = (scnt+ 1), stat = alterlist(temp2->os,scnt), temp2->os[scnt].os_id = os.order_sentence_id,
   temp2->os[scnt].oe_format_id = os.oe_format_id
   IF (os.order_sentence_display_line > " ")
    temp2->os[scnt].old_osdl = os.order_sentence_display_line
   ELSE
    temp2->os[scnt].old_osdl = "<empty>"
   ENDIF
   cnt = 0
  DETAIL
   IF (off.clin_line_ind=1)
    cnt = (cnt+ 1), stat = alterlist(temp2->os[scnt].osd,cnt), temp2->os[scnt].osd[cnt].sequence =
    osd.sequence
    IF (osd.field_type_flag=7)
     IF (off.disp_yes_no_flag=0)
      IF (osd.oe_field_value=1)
       temp2->os[scnt].osd[cnt].osdv = off.label_text
      ELSE
       temp2->os[scnt].osd[cnt].osdv = off.clin_line_label
      ENDIF
     ELSEIF (off.disp_yes_no_flag=1)
      IF (osd.oe_field_value=1)
       temp2->os[scnt].osd[cnt].osdv = off.label_text
      ELSE
       temp2->os[scnt].osd[cnt].osdv = " "
      ENDIF
     ELSEIF (off.disp_yes_no_flag=2)
      IF (osd.oe_field_value=1)
       temp2->os[scnt].osd[cnt].osdv = " "
      ELSE
       temp2->os[scnt].osd[cnt].osdv = off.clin_line_label
      ENDIF
     ENDIF
    ELSE
     IF (trim(off.clin_line_label) > " ")
      IF (off.clin_suffix_ind=1)
       temp2->os[scnt].osd[cnt].osdv = concat(trim(osd.oe_field_display_value)," ",trim(off
         .clin_line_label))
      ELSE
       temp2->os[scnt].osd[cnt].osdv = concat(trim(off.clin_line_label)," ",trim(osd
         .oe_field_display_value))
      ENDIF
     ELSE
      temp2->os[scnt].osd[cnt].osdv = osd.oe_field_display_value
     ENDIF
    ENDIF
    temp2->os[scnt].osd[cnt].ofm_id = osd.oe_field_meaning_id, temp2->os[scnt].osd[cnt].of_id = osd
    .oe_field_id, temp2->os[scnt].osd[cnt].field_seq = off.field_seq,
    temp2->os[scnt].osd[cnt].group_seq = off.group_seq
   ENDIF
  FOOT REPORT
   sent_count = scnt
  WITH nocounter
 ;end select
 FOR (x = 1 TO sent_count)
   SET dline = " "
   SET cnt = size(temp2->os[x].osd,5)
   FOR (y = 1 TO cnt)
     IF ((temp2->os[x].osd[y].osdv > " "))
      IF (dline=" ")
       SET dline = temp2->os[x].osd[y].osdv
      ELSEIF ((temp2->os[x].osd[y].group_seq=temp2->os[x].osd[(y - 1)].group_seq))
       SET dline = concat(dline," ",temp2->os[x].osd[y].osdv)
      ELSE
       SET dline = concat(dline,", ",temp2->os[x].osd[y].osdv)
      ENDIF
     ENDIF
   ENDFOR
   IF (dline > " ")
    SET temp2->os[x].new_osdl = dline
   ELSE
    SET temp2->os[x].new_osdl = "<empty>"
   ENDIF
 ENDFOR
 SET temp3cnt = 0
 FOR (x = 1 TO sent_count)
  SET stat = compare_sent(temp2->os[x].old_osdl,temp2->os[x].new_osdl)
  IF ((stat=- (1.0)))
   SET temp3cnt = (temp3cnt+ 1)
   SET stat = alterlist(temp3->os,temp3cnt)
   SET temp3->os[temp3cnt].os_id = temp2->os[x].os_id
   SET temp3->os[temp3cnt].oe_format_id = temp2->os[x].oe_format_id
   SET temp3->os[temp3cnt].old_osdl = temp2->os[x].old_osdl
   SET temp3->os[temp3cnt].new_osdl = temp2->os[x].new_osdl
   SET osdcnt = size(temp2->os[x].osd,5)
   IF (osdcnt > 0)
    SET stat = alterlist(temp3->os[temp3cnt].osd,osdcnt)
    FOR (y = 1 TO osdcnt)
      SET temp3->os[temp3cnt].osd[y].sequence = temp2->os[x].osd[y].sequence
      SET temp3->os[temp3cnt].osd[y].osdv = temp2->os[x].osd[y].osdv
      SET temp3->os[temp3cnt].osd[y].ofm_id = temp2->os[x].osd[y].ofm_id
      SET temp3->os[temp3cnt].osd[y].of_id = temp2->os[x].osd[y].of_id
      SET temp3->os[temp3cnt].osd[y].field_seq = temp2->os[x].osd[y].field_seq
      SET temp3->os[temp3cnt].osd[y].group_seq = temp2->os[x].osd[y].group_seq
    ENDFOR
   ENDIF
  ENDIF
 ENDFOR
 IF (temp3cnt != temp2cnt)
  SET temp2cnt = temp3cnt
  SET stat = alterlist(temp2->os,temp3cnt)
  FOR (x = 1 TO temp3cnt)
    SET temp2->os[x].os_id = temp3->os[x].os_id
    SET temp2->os[x].oe_format_id = temp3->os[x].oe_format_id
    SET temp2->os[x].old_osdl = temp3->os[x].old_osdl
    SET temp2->os[x].new_osdl = temp3->os[x].new_osdl
    SET osdcnt = size(temp3->os[x].osd,5)
    IF (osdcnt > 0)
     SET stat = alterlist(temp2->os[x].osd,osdcnt)
     FOR (y = 1 TO osdcnt)
       SET temp2->os[x].osd[y].sequence = temp3->os[x].osd[y].sequence
       SET temp2->os[x].osd[y].osdv = temp3->os[x].osd[y].osdv
       SET temp2->os[x].osd[y].ofm_id = temp3->os[x].osd[y].ofm_id
       SET temp2->os[x].osd[y].of_id = temp3->os[x].osd[y].of_id
       SET temp2->os[x].osd[y].field_seq = temp3->os[x].osd[y].field_seq
       SET temp2->os[x].osd[y].group_seq = temp3->os[x].osd[y].group_seq
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 FOR (x = 1 TO temp2cnt)
   IF ((temp2->os[x].new_osdl="<empty>"))
    SET temp2->os[x].new_osdl = " "
   ENDIF
   UPDATE  FROM order_sentence o
    SET o.order_sentence_display_line = temp2->os[x].new_osdl, o.updt_id = 286, o.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     o.updt_task = 0, o.updt_applctx = 0, o.updt_cnt = (o.updt_cnt+ 1)
    WHERE (o.order_sentence_id=temp2->os[x].os_id)
    WITH nocounter
   ;end update
   UPDATE  FROM ord_cat_sent_r o
    SET o.order_sentence_disp_line = temp2->os[x].new_osdl, o.updt_id = 286, o.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     o.updt_task = 0, o.updt_applctx = 0, o.updt_cnt = (o.updt_cnt+ 1)
    WHERE (o.order_sentence_id=temp2->os[x].os_id)
    WITH nocounter
   ;end update
 ENDFOR
 SELECT INTO "br_ordsent_display.log"
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   "ORDER DETAIL DISPLAY LINE DISCREPANCY LOG", row + 3, scnt = 0
  DETAIL
   FOR (x = 1 TO temp2cnt)
     "order sentence id: ", temp2->os[x].os_id, row + 1,
     "old disp line: ", temp2->os[x].old_osdl, row + 1,
     "new disp line: ", temp2->os[x].new_osdl, row + 1,
     scnt = (scnt+ 1)
   ENDFOR
   row + 1, "Sentences changed: ", scnt,
   row + 1
  WITH nocounter, maxrow = 1000, maxcol = 500
 ;end select
 IF (temp2cnt > 0)
  SET temp_reply_syncnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp2cnt),
    ord_cat_sent_r ocsr
   PLAN (d)
    JOIN (ocsr
    WHERE (ocsr.order_sentence_id=temp2->os[d.seq].os_id)
     AND ocsr.active_ind=1)
   ORDER BY ocsr.synonym_id, ocsr.order_sentence_id
   HEAD ocsr.synonym_id
    temp_reply_syncnt = (temp_reply_syncnt+ 1), stat = alterlist(temp_reply->synonyms,
     temp_reply_syncnt), temp_reply->synonyms[temp_reply_syncnt].id = ocsr.synonym_id,
    sentcnt = 0
   HEAD ocsr.order_sentence_id
    sentcnt = (sentcnt+ 1), stat = alterlist(temp_reply->synonyms[temp_reply_syncnt].sentences,
     sentcnt), temp_reply->synonyms[temp_reply_syncnt].sentences[sentcnt].id = ocsr.order_sentence_id,
    temp_reply->synonyms[temp_reply_syncnt].sentences[sentcnt].display_line = temp2->os[d.seq].
    new_osdl, temp_reply->synonyms[temp_reply_syncnt].sentences[sentcnt].oe_format_id = temp2->os[d
    .seq].oe_format_id
   WITH nocounter
  ;end select
  FOR (x = 1 TO temp_reply_syncnt)
   SET sent_cnt = size(temp_reply->synonyms[x].sentences,5)
   IF (sent_cnt > 0)
    DECLARE order_sentence = vc
    DECLARE order_sentence_full = vc
    DECLARE os_value = vc
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(sent_cnt)),
      order_sentence_detail osd,
      order_entry_fields oef,
      oe_format_fields off
     PLAN (d)
      JOIN (osd
      WHERE (osd.order_sentence_id=temp_reply->synonyms[x].sentences[d.seq].id))
      JOIN (oef
      WHERE oef.oe_field_id=osd.oe_field_id)
      JOIN (off
      WHERE off.oe_field_id=outerjoin(oef.oe_field_id)
       AND off.action_type_cd=outerjoin(order_cd)
       AND ((off.oe_format_id+ 0)=outerjoin(temp_reply->synonyms[x].sentences[d.seq].oe_format_id)))
     ORDER BY d.seq, off.group_seq, off.field_seq
     HEAD d.seq
      dcnt = 0, dtcnt = 0, stat = alterlist(temp_reply->synonyms[x].sentences[d.seq].details,10),
      out_of_oe = 0
     DETAIL
      dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
      IF (dcnt > 10)
       stat = alterlist(temp_reply->synonyms[x].sentences[d.seq].details,(dtcnt+ 10)), dcnt = 1
      ENDIF
      IF (oef.codeset > 0)
       temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].field_code_value = osd
       .default_parent_entity_id
      ELSE
       temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].field_code_value = osd.oe_field_value
      ENDIF
      temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value = osd
      .oe_field_display_value, temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].oe_field_id =
      oef.oe_field_id, temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].oe_field_label = oef
      .description
      IF (off.oe_field_id > 0)
       IF (oef.field_type_flag=7)
        IF ((temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value IN ("YES", "1")
        ))
         temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value = "Yes"
        ENDIF
        IF ((temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value IN ("NO", "0"))
        )
         temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value = "No"
        ENDIF
       ENDIF
       os_value = temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value
       IF (oef.field_type_flag=7)
        IF ((temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value="Yes"))
         IF (oef.oe_field_meaning_id=prn_id)
          os_value = "PRN"
         ELSE
          IF (off.disp_yes_no_flag IN (0, 1))
           os_value = off.label_text
          ELSE
           os_value = ""
          ENDIF
         ENDIF
        ELSEIF ((temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value="No"))
         IF (oef.oe_field_meaning_id=prn_id)
          os_value = ""
         ELSE
          IF (off.disp_yes_no_flag IN (0, 2))
           os_value = off.clin_line_label
          ELSE
           os_value = ""
          ENDIF
         ENDIF
        ENDIF
       ELSE
        IF (off.clin_line_label > " ")
         IF (off.clin_suffix_ind=1)
          os_value = concat(trim(temp_reply->synonyms[x].sentences[d.seq].details[dtcnt].
            field_disp_value)," ",trim(off.clin_line_label))
         ELSE
          os_value = concat(trim(off.clin_line_label)," ",trim(temp_reply->synonyms[x].sentences[d
            .seq].details[dtcnt].field_disp_value))
         ENDIF
        ENDIF
       ENDIF
       IF (dtcnt=1)
        order_sentence_full = trim(os_value), gseq = off.group_seq
       ELSE
        IF (os_value > " ")
         IF (gseq=off.group_seq)
          order_sentence_full = concat(trim(order_sentence_full)," ",trim(os_value))
         ELSE
          order_sentence_full = concat(trim(order_sentence_full),", ",trim(os_value)), gseq = off
          .group_seq
         ENDIF
        ENDIF
       ENDIF
      ELSE
       out_of_oe = 1
      ENDIF
     FOOT  d.seq
      stat = alterlist(temp_reply->synonyms[x].sentences[d.seq].details,dtcnt)
      IF (out_of_oe=0)
       temp_reply->synonyms[x].sentences[d.seq].full_display_line = trim(order_sentence_full,3)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
  SET stat = alterlist(reply->synonyms,temp_reply_syncnt)
  FOR (s = 1 TO temp_reply_syncnt)
    SET sent_cnt = size(temp_reply->synonyms[s].sentences,5)
    SET stat = alterlist(reply->synonyms[s].sentences,sent_cnt)
    FOR (t = 1 TO sent_cnt)
      SET reply->synonyms[s].sentences[t].id = temp_reply->synonyms[s].sentences[t].id
      SET reply->synonyms[s].sentences[t].display_line = temp_reply->synonyms[s].sentences[t].
      display_line
      SET reply->synonyms[s].sentences[t].full_display_line = temp_reply->synonyms[s].sentences[t].
      full_display_line
    ENDFOR
  ENDFOR
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
