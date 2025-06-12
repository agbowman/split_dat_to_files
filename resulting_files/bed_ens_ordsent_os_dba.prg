CREATE PROGRAM bed_ens_ordsent_os:dba
 FREE SET reply
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
 FREE SET temp_ocs
 RECORD temp_ocs(
   1 syns[*]
     2 syn_id = f8
 )
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
   IF ((request->sentences[x].action_flag=3))
    SET ierrcode = 0
    DELETE  FROM filter_entity_reltn f
     WHERE (f.parent_entity_id=request->sentences[x].id)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM long_text l
     WHERE l.parent_entity_name="ORDER_SENTENCE"
      AND (l.parent_entity_id=request->sentences[x].id)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM order_sentence_detail o
     WHERE (o.order_sentence_id=request->sentences[x].id)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM order_sentence o
     WHERE (o.order_sentence_id=request->sentences[x].id)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM ord_cat_sent_r o
     WHERE (o.order_sentence_id=request->sentences[x].id)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(scnt)),
   ord_cat_sent_r o
  PLAN (d)
   JOIN (o
   WHERE (o.order_sentence_id=request->sentences[d.seq].id))
  ORDER BY o.synonym_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(temp_ocs->syns,100)
  HEAD o.synonym_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_ocs->syns,(tcnt+ 100)), cnt = 1
   ENDIF
   temp_ocs->syns[tcnt].syn_id = o.synonym_id
  FOOT REPORT
   stat = alterlist(temp_ocs->syns,tcnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO tcnt)
   SET sent_id = 0.0
   SET mcnt = 0
   SET mult_ind = 0
   SET ocs_sent_id = 0.0
   SELECT INTO "nl:"
    FROM ord_cat_sent_r o,
     order_catalog_synonym ocs
    PLAN (o
     WHERE (o.synonym_id=temp_ocs->syns[x].syn_id))
     JOIN (ocs
     WHERE ocs.synonym_id=o.synonym_id)
    DETAIL
     mcnt = (mcnt+ 1), sent_id = o.order_sentence_id, mult_ind = ocs.multiple_ord_sent_ind,
     ocs_sent_id = ocs.order_sentence_id
    WITH nocounter
   ;end select
   IF (mcnt=0)
    IF (((mult_ind > 0) OR (ocs_sent_id > 0)) )
     UPDATE  FROM order_catalog_synonym o
      SET o.multiple_ord_sent_ind = 0, o.order_sentence_id = 0, o.updt_id = reqinfo->updt_id,
       o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx
        = reqinfo->updt_applctx,
       o.updt_cnt = (o.updt_cnt+ 1)
      PLAN (o
       WHERE (o.synonym_id=temp_ocs->syns[x].syn_id))
      WITH nocounter
     ;end update
    ENDIF
   ELSEIF (mcnt=1)
    IF (((ocs_sent_id != sent_id) OR (mult_ind=1)) )
     UPDATE  FROM order_catalog_synonym o
      SET o.multiple_ord_sent_ind = 0, o.order_sentence_id = sent_id, o.updt_id = reqinfo->updt_id,
       o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx
        = reqinfo->updt_applctx,
       o.updt_cnt = (o.updt_cnt+ 1)
      PLAN (o
       WHERE (o.synonym_id=temp_ocs->syns[x].syn_id))
      WITH nocounter
     ;end update
    ENDIF
   ELSE
    IF (((ocs_sent_id > 0) OR (mult_ind=0)) )
     UPDATE  FROM order_catalog_synonym o
      SET o.multiple_ord_sent_ind = 1, o.order_sentence_id = 0, o.updt_id = reqinfo->updt_id,
       o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx
        = reqinfo->updt_applctx,
       o.updt_cnt = (o.updt_cnt+ 1)
      PLAN (o
       WHERE (o.synonym_id=temp_ocs->syns[x].syn_id))
      WITH nocounter
     ;end update
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
