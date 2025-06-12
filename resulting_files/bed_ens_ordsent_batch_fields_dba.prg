CREATE PROGRAM bed_ens_ordsent_batch_fields:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD sorteddetails(
   1 details[*]
     2 old_seq = i4
     2 new_seq = i4
 ) WITH protect
 DECLARE detailseq = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET scnt = 0
 SET scnt = size(request->sentences,5)
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO scnt)
   SET stat = initrec(sorteddetails)
   FREE SET fields
   RECORD fields(
     1 qual[*]
       2 value = vc
       2 group_seq = i4
       2 field_seq = i4
       2 field_id = f8
       2 field_type_flag = i2
       2 clin_line_ind = i2
   )
   SET usage_flag = 0
   SET format_id = 0.0
   SELECT INTO "nl:"
    FROM order_sentence s
    PLAN (s
     WHERE (s.order_sentence_id=request->sentences[x].id))
    DETAIL
     format_id = s.oe_format_id, usage_flag = s.usage_flag
    WITH nocounter
   ;end select
   SET order_cd = 0.0
   IF (usage_flag=2)
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=6003
       AND c.cdf_meaning="DISORDER"
       AND c.active_ind=1)
     DETAIL
      order_cd = c.code_value
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=6003
       AND c.cdf_meaning="ORDER"
       AND c.active_ind=1)
     DETAIL
      order_cd = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   SET fcnt = 0
   SELECT INTO "nl:"
    FROM order_sentence_detail d,
     oe_format_fields f,
     order_entry_fields o
    PLAN (d
     WHERE (d.order_sentence_id=request->sentences[x].id))
     JOIN (f
     WHERE f.oe_format_id=format_id
      AND ((f.action_type_cd+ 0)=order_cd)
      AND ((f.oe_field_id+ 0)=d.oe_field_id))
     JOIN (o
     WHERE o.oe_field_id=f.oe_field_id)
    ORDER BY f.group_seq, f.field_seq
    DETAIL
     IF ((d.oe_field_id=request->oe_field_id))
      IF ((request->value > " "))
       fcnt = (fcnt+ 1), stat = alterlist(fields->qual,fcnt), fields->qual[fcnt].value = request->
       value,
       fields->qual[fcnt].group_seq = f.group_seq, fields->qual[fcnt].field_seq = f.field_seq, fields
       ->qual[fcnt].field_id = f.oe_field_id,
       fields->qual[fcnt].field_type_flag = o.field_type_flag, fields->qual[fcnt].clin_line_ind = f
       .clin_line_ind
      ENDIF
     ELSE
      fcnt = (fcnt+ 1), stat = alterlist(fields->qual,fcnt), fields->qual[fcnt].value = d
      .oe_field_display_value,
      fields->qual[fcnt].group_seq = f.group_seq, fields->qual[fcnt].field_seq = f.field_seq, fields
      ->qual[fcnt].field_id = f.oe_field_id,
      fields->qual[fcnt].field_type_flag = o.field_type_flag, fields->qual[fcnt].clin_line_ind = f
      .clin_line_ind
     ENDIF
    WITH nocounter
   ;end select
   DECLARE order_sentence = vc
   DECLARE os_value = vc
   SET order_sentence = ""
   FOR (y = 1 TO size(fields->qual,5))
     IF ((fields->qual[y].field_type_flag=7))
      IF ((fields->qual[y].value IN ("YES", "1")))
       SET fields->qual[y].value = "Yes"
      ENDIF
      IF ((fields->qual[y].value IN ("NO", "0")))
       SET fields->qual[y].value = "No"
      ENDIF
     ENDIF
     SET os_value = fields->qual[y].value
     SELECT INTO "nl:"
      FROM oe_format_fields o
      PLAN (o
       WHERE o.oe_format_id=format_id
        AND (o.oe_field_id=fields->qual[y].field_id)
        AND o.action_type_cd=order_cd)
      DETAIL
       IF ((fields->qual[y].field_type_flag=7))
        os_value = ""
        IF ((fields->qual[y].value="Yes")
         AND o.disp_yes_no_flag IN (0, 1))
         os_value = o.label_text
        ELSEIF ((fields->qual[y].value="No")
         AND o.disp_yes_no_flag IN (0, 2))
         os_value = o.clin_line_label
        ENDIF
       ELSE
        IF (o.clin_line_label > " ")
         IF (o.clin_suffix_ind=1)
          os_value = concat(trim(fields->qual[y].value)," ",trim(o.clin_line_label))
         ELSE
          os_value = concat(trim(o.clin_line_label)," ",trim(fields->qual[y].value))
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF ( NOT (order_sentence > " "))
      IF ((fields->qual[y].clin_line_ind > 0)
       AND os_value > " ")
       SET order_sentence = trim(os_value)
       SET gseq = fields->qual[y].group_seq
      ENDIF
     ELSE
      IF ((fields->qual[y].clin_line_ind > 0)
       AND os_value > " ")
       IF ((gseq=fields->qual[y].group_seq))
        SET order_sentence = concat(trim(order_sentence)," ",trim(os_value))
       ELSE
        SET order_sentence = concat(trim(order_sentence),", ",trim(os_value))
        SET gseq = fields->qual[y].group_seq
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   SET ierrcode = 0
   UPDATE  FROM order_sentence s
    SET s.order_sentence_display_line = substring(1,255,order_sentence), s.updt_id = reqinfo->updt_id,
     s.updt_dt_tm = cnvtdatetime(curdate,curtime),
     s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
     .updt_cnt+ 1)
    PLAN (s
     WHERE (s.order_sentence_id=request->sentences[x].id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   UPDATE  FROM ord_cat_sent_r r
    SET r.order_sentence_disp_line = substring(1,255,order_sentence), r.updt_id = reqinfo->updt_id, r
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = (r
     .updt_cnt+ 1)
    PLAN (r
     WHERE (r.order_sentence_id=request->sentences[x].id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   UPDATE  FROM pw_comp_os_reltn pcor
    SET pcor.os_display_line = substring(1,255,order_sentence), pcor.updt_applctx = reqinfo->
     updt_applctx, pcor.updt_cnt = (pcor.updt_cnt+ 1),
     pcor.updt_dt_tm = cnvtdatetime(curdate,curtime3), pcor.updt_id = reqinfo->updt_id, pcor
     .updt_task = reqinfo->updt_task
    WHERE (pcor.order_sentence_id=request->sentences[x].id)
     AND pcor.os_display_line > " "
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
   IF ((request->value > " "))
    SET oe_field_value = 0.0
    SET default_id = 0.0
    IF ((request->field_type_flag IN (0, 1, 2, 3, 5,
    7, 11, 14, 15)))
     IF ((request->field_type_flag=5))
      SET oe_field_value = - (99999)
     ELSEIF ((request->field_type_flag=7)
      AND (request->value="Yes"))
      SET oe_field_value = 1
     ELSE
      SET oe_field_value = request->field_value
     ENDIF
    ELSEIF ((request->field_type_flag IN (6, 8, 9, 10, 12,
    13)))
     SET oe_field_value = 0.0
     SET default_id = request->code_value
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM order_sentence_detail d
     SET d.oe_field_value = oe_field_value, d.oe_field_display_value = request->value, d.updt_id =
      reqinfo->updt_id,
      d.updt_dt_tm = cnvtdatetime(curdate,curtime), d.updt_task = reqinfo->updt_task, d.updt_applctx
       = reqinfo->updt_applctx,
      d.updt_cnt = (d.updt_cnt+ 1), d.default_parent_entity_id = default_id
     PLAN (d
      WHERE (d.order_sentence_id=request->sentences[x].id)
       AND ((d.oe_field_id+ 0)=request->oe_field_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ELSE
    SET ierrcode = 0
    DELETE  FROM order_sentence_detail d
     PLAN (d
      WHERE (d.order_sentence_id=request->sentences[x].id)
       AND ((d.oe_field_id+ 0)=request->oe_field_id))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
    SET detailseq = 0
    SET detailsequencecnt = 0
    SELECT INTO "nl:"
     FROM order_sentence_detail d
     PLAN (d
      WHERE (d.order_sentence_id=request->sentences[x].id))
     ORDER BY d.sequence
     DETAIL
      detailsequencecnt = (detailsequencecnt+ 1)
      IF (d.sequence=0)
       detailsequencecnt = 0
      ENDIF
      detailseq = (detailseq+ 1), stat = alterlist(sorteddetails->details,detailseq), sorteddetails->
      details[detailseq].old_seq = d.sequence,
      sorteddetails->details[detailseq].new_seq = detailsequencecnt
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
    IF (detailseq > 0)
     UPDATE  FROM order_sentence_detail d,
       (dummyt dt  WITH seq = detailseq)
      SET d.sequence = sorteddetails->details[dt.seq].new_seq, d.updt_id = reqinfo->updt_id, d
       .updt_dt_tm = cnvtdatetime(curdate,curtime),
       d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d
       .updt_cnt+ 1)
      PLAN (dt)
       JOIN (d
       WHERE (d.order_sentence_id=request->sentences[x].id)
        AND (d.sequence=sorteddetails->details[dt.seq].old_seq))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = "Y"
      SET reply->error_msg = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
