CREATE PROGRAM bed_ens_ado_ord_list:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 options[*]
      2 option_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE error_flag = vc WITH protect, noconstant("")
 DECLARE o = i2 WITH protect, noconstant(0)
 DECLARE dcnt = i2 WITH protect, noconstant(0)
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE detail_id = f8 WITH protect, noconstant(0)
 DECLARE option_id = f8 WITH protect, noconstant(0)
 DECLARE ol_cnt = i2 WITH protect, noconstant(0)
 DECLARE scenario_mean = vc
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET o = 0
 SELECT INTO "nl:"
  FROM br_ado_topic_scenario ts
  WHERE (ts.br_ado_topic_scenario_id=request->topic_scenario_id)
  DETAIL
   scenario_mean = ts.scenario_mean
  WITH nocounter
 ;end select
 SET dcnt = size(request->details,5)
 FOR (x = 1 TO dcnt)
   SET detail_id = 0.0
   SELECT INTO "nl:"
    FROM br_ado_detail d
    PLAN (d
     WHERE d.scenario_mean=scenario_mean
      AND (d.br_ado_category_id=request->details[x].category_id)
      AND (d.facility_cd=request->facility_code_value))
    DETAIL
     detail_id = d.br_ado_detail_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     temp = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      detail_id = cnvtreal(temp)
     WITH nocounter
    ;end select
    SET ierrcode = 0
    INSERT  FROM br_ado_detail d
     SET d.br_ado_detail_id = detail_id, d.scenario_mean = scenario_mean, d.br_ado_category_id =
      request->details[x].category_id,
      d.facility_cd = request->facility_code_value, d.note_txt = request->details[x].notes, d
      .select_ind = request->details[x].select_ind,
      d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id,
      d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d
      .scenario_category_seq = request->details[x].category_seq
     PLAN (d)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Error on insert 1"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET op_cnt = size(request->details[x].options,5)
    CALL echo(build("op: ",op_cnt))
    FOR (y = 1 TO op_cnt)
      IF ((request->details[x].options[y].action_flag=1))
       SET option_id = 0.0
       SELECT INTO "nl:"
        temp = seq(bedrock_seq,nextval)
        FROM dual
        DETAIL
         option_id = cnvtreal(temp),
         CALL echo(build("option2: ",option_id))
        WITH nocounter
       ;end select
       SET ierrcode = 0
       INSERT  FROM br_ado_option o
        SET o.br_ado_option_id = option_id, o.br_ado_detail_id = detail_id, o.preselect_ind = request
         ->details[x].options[y].preselect_ind,
         o.option_seq = request->details[x].options[y].sequence, o.note_txt = request->details[x].
         options[y].notes, o.updt_cnt = 0,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         reqinfo->updt_task,
         o.updt_applctx = reqinfo->updt_applctx
        PLAN (o)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = "Error on insert 2"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
       SET ol_cnt = size(request->details[x].options[y].ord_list,5)
       IF (ol_cnt > 0)
        SET ierrcode = 0
        INSERT  FROM br_ado_ord_list ol,
          (dummyt d  WITH seq = value(ol_cnt))
         SET ol.br_ado_ord_list_id = seq(bedrock_seq,nextval), ol.br_ado_option_id = option_id, ol
          .br_ado_detail_id = detail_id,
          ol.synonym_id = request->details[x].options[y].ord_list[d.seq].synonym_id, ol.sentence_id
           = request->details[x].options[y].ord_list[d.seq].new_sentence_id, ol.synonym_seq = request
          ->details[x].options[y].ord_list[d.seq].sequence,
          ol.updt_cnt = 0, ol.updt_dt_tm = cnvtdatetime(curdate,curtime3), ol.updt_id = reqinfo->
          updt_id,
          ol.updt_task = reqinfo->updt_task, ol.updt_applctx = reqinfo->updt_applctx
         PLAN (d
          WHERE (request->details[x].options[y].ord_list[d.seq].action_flag=1))
          JOIN (ol)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = "Error on insert 3"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      SET o = (o+ 1)
      SET stat = alterlist(reply->options,o)
      SET reply->options[o].option_id = option_id
      CALL echo(build("option1: ",option_id))
    ENDFOR
   ELSE
    SET ierrcode = 0
    UPDATE  FROM br_ado_detail d
     SET d.note_txt = request->details[x].notes, d.select_ind = request->details[x].select_ind, d
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
      updt_applctx,
      d.updt_cnt = (d.updt_cnt+ 1), d.scenario_category_seq = request->details[x].category_seq
     WHERE d.br_ado_detail_id=detail_id
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Error on update 1"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET op_cnt = size(request->details[x].options,5)
    FOR (y = 1 TO op_cnt)
      IF ((request->details[x].options[y].action_flag=1))
       SET option_id = 0.0
       SELECT INTO "nl:"
        temp = seq(bedrock_seq,nextval)
        FROM dual
        DETAIL
         option_id = cnvtreal(temp)
        WITH nocounter
       ;end select
       CALL echo(build("op: ",option_id))
       SET ierrcode = 0
       INSERT  FROM br_ado_option o
        SET o.br_ado_option_id = option_id, o.br_ado_detail_id = detail_id, o.preselect_ind = request
         ->details[x].options[y].preselect_ind,
         o.option_seq = request->details[x].options[y].sequence, o.note_txt = request->details[x].
         options[y].notes, o.updt_cnt = 0,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         reqinfo->updt_task,
         o.updt_applctx = reqinfo->updt_applctx
        PLAN (o)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = "Error on insert 4"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
       SET ol_cnt = size(request->details[x].options[y].ord_list,5)
       IF (ol_cnt > 0)
        SET ierrcode = 0
        INSERT  FROM br_ado_ord_list ol,
          (dummyt d  WITH seq = value(ol_cnt))
         SET ol.br_ado_ord_list_id = seq(bedrock_seq,nextval), ol.br_ado_option_id = option_id, ol
          .br_ado_detail_id = detail_id,
          ol.synonym_id = request->details[x].options[y].ord_list[d.seq].synonym_id, ol.sentence_id
           = request->details[x].options[y].ord_list[d.seq].new_sentence_id, ol.synonym_seq = request
          ->details[x].options[y].ord_list[d.seq].sequence,
          ol.updt_cnt = 0, ol.updt_dt_tm = cnvtdatetime(curdate,curtime3), ol.updt_id = reqinfo->
          updt_id,
          ol.updt_task = reqinfo->updt_task, ol.updt_applctx = reqinfo->updt_applctx
         PLAN (d)
          JOIN (ol)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = "Error on insert 5"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
       SET o = (o+ 1)
       SET stat = alterlist(reply->options,o)
       SET reply->options[o].option_id = option_id
      ELSEIF ((request->details[x].options[y].action_flag=2))
       SET option_id = request->details[x].options[y].option_id
       SET ierrcode = 0
       UPDATE  FROM br_ado_option o
        SET o.preselect_ind = request->details[x].options[y].preselect_ind, o.option_seq = request->
         details[x].options[y].sequence, o.note_txt = request->details[x].options[y].notes,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         reqinfo->updt_task,
         o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o.updt_cnt+ 1)
        WHERE o.br_ado_option_id=option_id
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = "Error on update 2"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
       SET ol_cnt = size(request->details[x].options[y].ord_list,5)
       IF (ol_cnt > 0)
        SET ierrcode = 0
        INSERT  FROM br_ado_ord_list ol,
          (dummyt d  WITH seq = value(ol_cnt))
         SET ol.br_ado_ord_list_id = seq(bedrock_seq,nextval), ol.br_ado_option_id = option_id, ol
          .br_ado_detail_id = detail_id,
          ol.synonym_id = request->details[x].options[y].ord_list[d.seq].synonym_id, ol.sentence_id
           = request->details[x].options[y].ord_list[d.seq].new_sentence_id, ol.synonym_seq = request
          ->details[x].options[y].ord_list[d.seq].sequence,
          ol.updt_cnt = 0, ol.updt_dt_tm = cnvtdatetime(curdate,curtime3), ol.updt_id = reqinfo->
          updt_id,
          ol.updt_task = reqinfo->updt_task, ol.updt_applctx = reqinfo->updt_applctx
         PLAN (d
          WHERE (request->details[x].options[y].ord_list[d.seq].action_flag=1))
          JOIN (ol)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = "Error on insert 6"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
        SET ierrcode = 0
        UPDATE  FROM br_ado_ord_list ol,
          (dummyt d  WITH seq = value(ol_cnt))
         SET ol.synonym_seq = request->details[x].options[y].ord_list[d.seq].sequence, ol.updt_cnt =
          0, ol.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          ol.updt_id = reqinfo->updt_id, ol.updt_task = reqinfo->updt_task, ol.updt_applctx = reqinfo
          ->updt_applctx
         PLAN (d)
          JOIN (ol
          WHERE ol.br_ado_option_id=option_id
           AND ol.br_ado_detail_id=detail_id
           AND (ol.synonym_id=request->details[x].options[y].ord_list[d.seq].synonym_id)
           AND (ol.sentence_id=request->details[x].options[y].ord_list[d.seq].new_sentence_id)
           AND (request->details[x].options[y].ord_list[d.seq].action_flag=2))
         WITH nocounter
        ;end update
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = "Error on update 6"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
        SET ierrcode = 0
        DELETE  FROM br_ado_ord_list ol,
          (dummyt d  WITH seq = value(ol_cnt))
         SET ol.seq = 1
         PLAN (d
          WHERE (request->details[x].options[y].ord_list[d.seq].action_flag=3))
          JOIN (ol
          WHERE ol.br_ado_option_id=option_id
           AND (ol.synonym_id=request->details[x].options[y].ord_list[d.seq].synonym_id)
           AND (ol.sentence_id=request->details[x].options[y].ord_list[d.seq].old_sentence_id))
         WITH nocounter
        ;end delete
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = "Error on delete 1"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF ((request->details[x].options[y].action_flag=3))
       SET option_id = request->details[x].options[y].option_id
       SET ol_cnt = size(request->details[x].options[y].ord_list,5)
       SET ierrcode = 0
       DELETE  FROM br_ado_ord_list ol
        WHERE ol.br_ado_option_id=option_id
        WITH nocounter
       ;end delete
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = "Error on delete 2"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
       SET ierrcode = 0
       DELETE  FROM br_ado_option o
        WHERE o.br_ado_option_id=option_id
        WITH nocounter
       ;end delete
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = "Error on delete 3"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ELSE
       SET option_id = request->details[x].options[y].option_id
       SET ol_cnt = size(request->details[x].options[y].ord_list,5)
       IF (ol_cnt > 0)
        INSERT  FROM br_ado_ord_list ol,
          (dummyt d  WITH seq = value(ol_cnt))
         SET ol.br_ado_ord_list_id = seq(bedrock_seq,nextval), ol.br_ado_detail_id = detail_id, ol
          .br_ado_option_id = option_id,
          ol.synonym_id = request->details[x].options[y].ord_list[d.seq].synonym_id, ol.sentence_id
           = request->details[x].options[y].ord_list[d.seq].new_sentence_id, ol.synonym_seq = request
          ->details[x].options[y].ord_list[d.seq].sequence,
          ol.updt_cnt = 0, ol.updt_dt_tm = cnvtdatetime(curdate,curtime3), ol.updt_id = reqinfo->
          updt_id,
          ol.updt_task = reqinfo->updt_task, ol.updt_applctx = reqinfo->updt_applctx
         PLAN (d
          WHERE (request->details[x].options[y].ord_list[d.seq].action_flag=1))
          JOIN (ol)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = "Error on insert 7"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
        SET ierrcode = 0
        UPDATE  FROM br_ado_ord_list ol,
          (dummyt d  WITH seq = value(ol_cnt))
         SET ol.synonym_seq = request->details[x].options[y].ord_list[d.seq].sequence, ol.updt_cnt =
          0, ol.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          ol.updt_id = reqinfo->updt_id, ol.updt_task = reqinfo->updt_task, ol.updt_applctx = reqinfo
          ->updt_applctx
         PLAN (d)
          JOIN (ol
          WHERE ol.br_ado_option_id=option_id
           AND ol.br_ado_detail_id=detail_id
           AND (ol.synonym_id=request->details[x].options[y].ord_list[d.seq].synonym_id)
           AND (ol.sentence_id=request->details[x].options[y].ord_list[d.seq].new_sentence_id)
           AND (request->details[x].options[y].ord_list[d.seq].action_flag=2))
         WITH nocounter
        ;end update
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = "Error on update 7"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
        SET ierrcode = 0
        DELETE  FROM br_ado_ord_list ol,
          (dummyt d  WITH seq = value(ol_cnt))
         SET ol.seq = 1
         PLAN (d
          WHERE (request->details[x].options[y].ord_list[d.seq].action_flag=3))
          JOIN (ol
          WHERE ol.br_ado_option_id=option_id
           AND (ol.synonym_id=request->details[x].options[y].ord_list[d.seq].synonym_id)
           AND (ol.sentence_id=request->details[x].options[y].ord_list[d.seq].old_sentence_id))
         WITH nocounter
        ;end delete
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = "Error on Delete 4"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
