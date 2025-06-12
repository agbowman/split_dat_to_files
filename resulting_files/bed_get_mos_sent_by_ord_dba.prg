CREATE PROGRAM bed_get_mos_sent_by_ord:dba
 FREE SET reply
 RECORD reply(
   1 sentences[*]
     2 sentence_id = f8
     2 display = vc
     2 usage_flag = i2
     2 comment_id = f8
     2 comment_txt = vc
     2 encntr_group_code_value = f8
     2 ext_identifier = vc
     2 details[*]
       3 oe_field_id = f8
       3 oe_field_label = vc
       3 field_disp_value = vc
       3 field_code_value = f8
     2 full_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SET action_code = 0.0
 IF ((request->usage_flag=2))
  SET action_code = uar_get_code_by("MEANING",6003,"DISORDER")
 ELSE
  SET action_code = uar_get_code_by("MEANING",6003,"ORDER")
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   ord_cat_sent_r ocsr,
   order_sentence os,
   long_text l
  PLAN (ocs
   WHERE (ocs.catalog_cd=request->catalog_code_value)
    AND (ocs.oe_format_id=request->oe_format_id))
   JOIN (ocsr
   WHERE ocsr.synonym_id=ocs.synonym_id
    AND ocsr.active_ind=1)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND (os.usage_flag=request->usage_flag))
   JOIN (l
   WHERE l.long_text_id=outerjoin(os.ord_comment_long_text_id))
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->sentences,10)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->sentences,(tot_cnt+ 10)), cnt = 1
   ENDIF
   reply->sentences[tot_cnt].sentence_id = os.order_sentence_id, reply->sentences[tot_cnt].display =
   os.order_sentence_display_line, reply->sentences[tot_cnt].usage_flag = os.usage_flag,
   reply->sentences[tot_cnt].encntr_group_code_value = os.order_encntr_group_cd, reply->sentences[
   tot_cnt].comment_id = os.ord_comment_long_text_id, reply->sentences[tot_cnt].comment_txt = l
   .long_text,
   reply->sentences[tot_cnt].ext_identifier = os.external_identifier
  FOOT REPORT
   stat = alterlist(reply->sentences,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt=0)
  GO TO exit_script
 ENDIF
 DECLARE order_sentence = vc
 DECLARE order_sentence_full = vc
 DECLARE os_value = vc
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tot_cnt)),
   order_sentence_detail osd,
   order_entry_fields oef,
   oe_format_fields off
  PLAN (d)
   JOIN (osd
   WHERE (osd.order_sentence_id=reply->sentences[d.seq].sentence_id))
   JOIN (oef
   WHERE oef.oe_field_id=osd.oe_field_id)
   JOIN (off
   WHERE off.oe_field_id=oef.oe_field_id
    AND off.action_type_cd=action_code
    AND (off.oe_format_id=request->oe_format_id))
  ORDER BY d.seq, off.group_seq, off.field_seq
  HEAD d.seq
   dcnt = 0, dtcnt = 0, stat = alterlist(reply->sentences[d.seq].details,10)
  DETAIL
   dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
   IF (dcnt > 10)
    stat = alterlist(reply->sentences[d.seq].details,(dtcnt+ 10)), dcnt = 1
   ENDIF
   reply->sentences[d.seq].details[dtcnt].field_code_value = osd.oe_field_value, reply->sentences[d
   .seq].details[dtcnt].field_disp_value = osd.oe_field_display_value, reply->sentences[d.seq].
   details[dtcnt].oe_field_id = osd.oe_field_id,
   reply->sentences[d.seq].details[dtcnt].oe_field_label = oef.description
   IF (oef.field_type_flag=7)
    IF ((reply->sentences[d.seq].details[dtcnt].field_disp_value IN ("YES", "1")))
     reply->sentences[d.seq].details[dtcnt].field_disp_value = "Yes"
    ENDIF
    IF ((reply->sentences[d.seq].details[dtcnt].field_disp_value IN ("NO", "0")))
     reply->sentences[d.seq].details[dtcnt].field_disp_value = "No"
    ENDIF
   ENDIF
   os_value = reply->sentences[d.seq].details[dtcnt].field_disp_value
   IF (oef.field_type_flag=7)
    IF ((reply->sentences[d.seq].details[dtcnt].field_disp_value="Yes"))
     IF (off.disp_yes_no_flag IN (0, 1))
      os_value = off.label_text
     ELSE
      os_value = ""
     ENDIF
    ELSEIF ((reply->sentences[d.seq].details[dtcnt].field_disp_value="No"))
     IF (off.disp_yes_no_flag IN (0, 2))
      os_value = off.clin_line_label
     ELSE
      os_value = ""
     ENDIF
    ENDIF
   ELSE
    IF (off.clin_line_label > " ")
     IF (off.clin_suffix_ind=1)
      os_value = concat(trim(reply->sentences[d.seq].details[dtcnt].field_disp_value)," ",trim(off
        .clin_line_label))
     ELSE
      os_value = concat(trim(off.clin_line_label)," ",trim(reply->sentences[d.seq].details[dtcnt].
        field_disp_value))
     ENDIF
    ENDIF
   ENDIF
   IF (dtcnt=1)
    order_sentence_full = trim(os_value)
    IF (off.clin_line_ind=1)
     order_sentence = trim(os_value)
    ENDIF
    gseq = off.group_seq
   ELSE
    IF (os_value > " ")
     IF (gseq=off.group_seq)
      order_sentence_full = concat(trim(order_sentence_full)," ",trim(os_value))
      IF (off.clin_line_ind=1)
       order_sentence = concat(trim(order_sentence)," ",trim(os_value))
      ENDIF
     ELSE
      order_sentence_full = concat(trim(order_sentence_full),", ",trim(os_value))
      IF (off.clin_line_ind=1)
       order_sentence = concat(trim(order_sentence),", ",trim(os_value))
      ENDIF
      gseq = off.group_seq
     ENDIF
    ENDIF
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->sentences[d.seq].details,dtcnt), reply->sentences[d.seq].display = trim(
    order_sentence,3), reply->sentences[d.seq].full_display = trim(order_sentence_full,3)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
