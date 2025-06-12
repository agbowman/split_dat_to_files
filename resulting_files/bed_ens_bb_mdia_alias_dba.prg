CREATE PROGRAM bed_ens_bb_mdia_alias:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET sfailed = "N"
 SET rcnt = 0
 FOR (x = 1 TO size(request->aborh,5))
   IF ((request->aborh[x].ignore_ind=0))
    DELETE  FROM code_value_alias c
     WHERE (c.contributor_source_cd=request->model_code_value)
      AND (c.code_value=request->aborh[x].code_value)
     WITH nocounter
    ;end delete
    SET acnt = size(request->aborh[x].alias,5)
    IF (acnt > 0)
     INSERT  FROM code_value_alias c,
       (dummyt d  WITH seq = value(acnt))
      SET c.contributor_source_cd = request->model_code_value, c.code_value = request->aborh[x].
       code_value, c.alias = request->aborh[x].alias[d.seq].alias,
       c.code_set = 1640, c.primary_ind = 0, c.alias_type_meaning = null,
       c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo->updt_id,
       c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
      PLAN (d)
       JOIN (c)
      WITH nocounter
     ;end insert
    ENDIF
    RECORD temp(
      1 qual[*]
        2 code_value = f8
        2 display_key = vc
    )
    SET tcnt = 0
    SELECT INTO "nl:"
     FROM code_value_extension cve,
      code_value cv
     PLAN (cve
      WHERE cve.code_set=1643
       AND cve.field_name="ABORH_cd"
       AND cve.field_type=1
       AND cve.field_value=cnvtstring(request->aborh[x].code_value))
      JOIN (cv
      WHERE cv.code_value=cve.code_value
       AND cv.active_ind=1)
     DETAIL
      tcnt = (tcnt+ 1), stat = alterlist(temp->qual,tcnt), temp->qual[tcnt].code_value = cv
      .code_value,
      temp->qual[tcnt].display_key = cv.display_key
     WITH nocounter
    ;end select
    IF (tcnt > 0)
     IF (tcnt=1)
      SET found_match = 1
     ELSE
      DECLARE 1640_display_key = vc
      SET 1640_display_key = " "
      SELECT INTO "nl:"
       FROM code_value cv
       WHERE (cv.code_value=request->aborh[x].code_value)
        AND cv.active_ind=1
       DETAIL
        1640_display_key = cv.display_key
       WITH nocounter
      ;end select
      SET found_match = 0
      FOR (t = 1 TO tcnt)
        IF ((temp->qual[t].display_key=1640_display_key))
         SET found_match = t
         SET t = (tcnt+ 1)
        ENDIF
      ENDFOR
     ENDIF
     IF (found_match > 0)
      DELETE  FROM code_value_alias c
       WHERE (c.contributor_source_cd=request->model_code_value)
        AND (c.code_value=temp->qual[found_match].code_value)
       WITH nocounter
      ;end delete
      IF (acnt > 0)
       INSERT  FROM code_value_alias c,
         (dummyt d  WITH seq = value(acnt))
        SET c.contributor_source_cd = request->model_code_value, c.code_value = temp->qual[
         found_match].code_value, c.alias = request->aborh[x].alias[d.seq].alias,
         c.code_set = 1643, c.primary_ind = 0, c.alias_type_meaning = null,
         c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo->updt_id,
         c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
        PLAN (d)
         JOIN (c)
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
    ENDIF
    DELETE  FROM br_name_value b
     PLAN (b
      WHERE b.br_nv_key1="BB_ALIAS_IGNORE"
       AND b.br_name=cnvtstring(request->model_code_value)
       AND b.br_value=cnvtstring(request->aborh[x].code_value))
     WITH nocounter
    ;end delete
   ELSE
    SET found = 0
    SELECT INTO "nl:"
     FROM br_name_value b
     PLAN (d)
      JOIN (b
      WHERE b.br_nv_key1="BB_ALIAS_IGNORE"
       AND b.br_name=cnvtstring(request->model_code_value)
       AND b.br_value=cnvtstring(request->aborh[x].code_value))
     DETAIL
      found = 1
     WITH nocounter
    ;end select
    IF (found=0)
     INSERT  FROM br_name_value b
      SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "BB_ALIAS_IGNORE", b.br_name
        = cnvtstring(request->model_code_value),
       b.br_value = cnvtstring(request->aborh[x].code_value), b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (sfailed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
