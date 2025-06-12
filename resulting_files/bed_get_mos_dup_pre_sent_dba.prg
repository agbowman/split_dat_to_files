CREATE PROGRAM bed_get_mos_dup_pre_sent:dba
 FREE SET reply
 RECORD reply(
   1 sentences[*]
     2 synonym_id = f8
     2 sentence_id = f8
     2 sent_display = vc
     2 sent_display_full = vc
     2 oe_format_id = f8
     2 dup_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->sentences,5)
 SET action_code = uar_get_code_by("MEANING",6003,"ORDER")
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET prn_id = 0.0
 SELECT INTO "nl:"
  FROM oe_field_meaning o
  WHERE o.oe_field_meaning="SCH/PRN"
  DETAIL
   prn_id = o.oe_field_meaning_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->sentences,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->sentences[x].synonym_id = request->sentences[x].synonym_id
   SET reply->sentences[x].sentence_id = request->sentences[x].sentence_id
   SET reply->sentences[x].sent_display = request->sentences[x].sent_display
   SET reply->sentences[x].sent_display_full = request->sentences[x].sent_display_full
   SET reply->sentences[x].oe_format_id = request->sentences[x].oe_format_id
 ENDFOR
 IF (req_cnt > 0)
  DECLARE temp_field_disp_value = vc
  DECLARE temp_oe_field_label = vc
  DECLARE order_sentence = vc
  DECLARE order_sentence_full = vc
  DECLARE os_value = vc
  SELECT DISTINCT INTO "nl:"
   os.order_sentence_id
   FROM (dummyt d  WITH seq = value(req_cnt)),
    ord_cat_sent_r ocsr,
    order_sentence os,
    order_sentence_detail osd,
    order_entry_fields oef,
    oe_format_fields off
   PLAN (d)
    JOIN (ocsr
    WHERE (ocsr.synonym_id=request->sentences[d.seq].synonym_id)
     AND ((ocsr.order_sentence_id+ 0) != request->sentences[d.seq].sentence_id)
     AND ocsr.active_ind=1)
    JOIN (os
    WHERE os.order_sentence_id=ocsr.order_sentence_id
     AND ((os.oe_format_id+ 0)=request->sentences[d.seq].oe_format_id)
     AND os.usage_flag=2)
    JOIN (osd
    WHERE osd.order_sentence_id=os.order_sentence_id)
    JOIN (oef
    WHERE oef.oe_field_id=osd.oe_field_id)
    JOIN (off
    WHERE off.oe_field_id=oef.oe_field_id
     AND off.action_type_cd=action_code
     AND ((off.oe_format_id+ 0)=request->sentences[d.seq].oe_format_id))
   ORDER BY os.order_sentence_id, off.group_seq, off.field_seq
   HEAD os.order_sentence_id
    temp_field_code_value = 0, temp_field_disp_value = "", order_sentence = "",
    order_sentence_full = "", gseq = 0, os_value = "",
    dtcnt = 0
   DETAIL
    temp_field_code_value = osd.oe_field_value, temp_field_disp_value = osd.oe_field_display_value,
    dtcnt = (dtcnt+ 1)
    IF (oef.field_type_flag=7)
     IF (temp_field_disp_value IN ("YES", "1"))
      temp_field_disp_value = "Yes"
     ENDIF
     IF (temp_field_disp_value IN ("NO", "0"))
      temp_field_disp_value = "No"
     ENDIF
    ENDIF
    os_value = temp_field_disp_value
    IF (oef.field_type_flag=7)
     IF (temp_field_disp_value="Yes")
      IF (oef.oe_field_meaning_id=prn_id)
       os_value = "PRN"
      ELSE
       IF (off.disp_yes_no_flag IN (0, 1))
        os_value = off.label_text
       ELSE
        os_value = ""
       ENDIF
      ENDIF
     ELSEIF (temp_field_disp_value="No")
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
       os_value = concat(trim(temp_field_disp_value)," ",trim(off.clin_line_label))
      ELSE
       os_value = concat(trim(off.clin_line_label)," ",trim(temp_field_disp_value))
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
   FOOT  os.order_sentence_id
    IF ((((trim(order_sentence_full,3)=request->sentences[d.seq].sent_display_full)) OR ((os
    .order_sentence_display_line=request->sentences[d.seq].sent_display))) )
     reply->sentences[d.seq].dup_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
