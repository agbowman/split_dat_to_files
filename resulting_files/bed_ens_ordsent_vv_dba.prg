CREATE PROGRAM bed_ens_ordsent_vv:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET ordsent_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=30620
   AND cv.cdf_meaning="ORDERSENT"
   AND cv.active_ind=1
  DETAIL
   ordsent_cd = cv.code_value
  WITH nocounter
 ;end select
 SET scnt = size(request->sentences,5)
 SET fcnt = size(request->facilities,5)
 IF ((request->ensure_mode=1))
  IF ((request->facilities[1].code_value=0))
   FOR (s = 1 TO scnt)
     SET row_cnt = 0
     SELECT INTO "NL:"
      FROM filter_entity_reltn fer
      WHERE (fer.parent_entity_id=request->sentences[s].id)
       AND fer.parent_entity_name="ORDER_SENTENCE"
       AND fer.filter_entity1_name="LOCATION"
      DETAIL
       row_cnt = (row_cnt+ 1)
      WITH nocounter
     ;end select
     IF (row_cnt=0)
      SET ierrcode = 0
      INSERT  FROM filter_entity_reltn fer
       SET fer.filter_entity_reltn_id = seq(reference_seq,nextval), fer.parent_entity_id = request->
        sentences[s].id, fer.filter_entity1_id = 0,
        fer.parent_entity_name = "ORDER_SENTENCE", fer.filter_entity1_name = "LOCATION", fer
        .filter_entity2_name = null,
        fer.filter_entity2_id = 0, fer.filter_entity3_name = null, fer.filter_entity3_id = 0,
        fer.filter_entity4_name = null, fer.filter_entity4_id = 0, fer.filter_entity5_name = null,
        fer.filter_entity5_id = 0, fer.filter_type_cd = ordsent_cd, fer.exclusion_filter_ind = null,
        fer.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), fer.end_effective_dt_tm =
        cnvtdatetime("31-dec-2100 00:00:00.00"), fer.updt_applctx = reqinfo->updt_applctx,
        fer.updt_cnt = 0, fer.updt_dt_tm = cnvtdatetime(curdate,curtime), fer.updt_id = reqinfo->
        updt_id,
        fer.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET stat = alterlist(reply->status_data.subeventstatus,1)
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Error inserting into filter_entity_reltn")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
  ELSE
   IF (scnt > 0)
    SET ierrcode = 0
    DELETE  FROM filter_entity_reltn fer,
      (dummyt d  WITH seq = scnt)
     SET fer.seq = 1
     PLAN (d)
      JOIN (fer
      WHERE (fer.parent_entity_id=request->sentences[d.seq].id)
       AND fer.filter_entity1_id=0
       AND fer.parent_entity_name="ORDER_SENTENCE"
       AND fer.filter_entity1_name="LOCATION")
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET stat = alterlist(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error deleting from filter_entity_reltn")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   IF (scnt > fcnt
    AND scnt > 0)
    FOR (f = 1 TO fcnt)
      SET ierrcode = 0
      DELETE  FROM filter_entity_reltn fer,
        (dummyt d  WITH seq = scnt)
       SET fer.seq = 1
       PLAN (d)
        JOIN (fer
        WHERE (fer.parent_entity_id=request->sentences[d.seq].id)
         AND (fer.filter_entity1_id=request->facilities[f].code_value)
         AND fer.parent_entity_name="ORDER_SENTENCE"
         AND fer.filter_entity1_name="LOCATION")
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET stat = alterlist(reply->status_data.subeventstatus,1)
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Error deleting from filter_entity_reltn")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
    ENDFOR
    FOR (f = 1 TO fcnt)
      SET ierrcode = 0
      INSERT  FROM filter_entity_reltn fer,
        (dummyt d  WITH seq = scnt)
       SET fer.filter_entity_reltn_id = seq(reference_seq,nextval), fer.parent_entity_id = request->
        sentences[d.seq].id, fer.filter_entity1_id = request->facilities[f].code_value,
        fer.parent_entity_name = "ORDER_SENTENCE", fer.filter_entity1_name = "LOCATION", fer
        .filter_entity2_name = null,
        fer.filter_entity2_id = 0, fer.filter_entity3_name = null, fer.filter_entity3_id = 0,
        fer.filter_entity4_name = null, fer.filter_entity4_id = 0, fer.filter_entity5_name = null,
        fer.filter_entity5_id = 0, fer.filter_type_cd = ordsent_cd, fer.exclusion_filter_ind = null,
        fer.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), fer.end_effective_dt_tm =
        cnvtdatetime("31-dec-2100 00:00:00.00"), fer.updt_applctx = reqinfo->updt_applctx,
        fer.updt_cnt = 0, fer.updt_dt_tm = cnvtdatetime(curdate,curtime), fer.updt_id = reqinfo->
        updt_id,
        fer.updt_task = reqinfo->updt_task
       PLAN (d)
        JOIN (fer)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET stat = alterlist(reply->status_data.subeventstatus,1)
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Error inserting into filter_entity_reltn")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
    ENDFOR
   ELSEIF (fcnt > 0)
    FOR (s = 1 TO scnt)
      SET ierrcode = 0
      DELETE  FROM filter_entity_reltn fer,
        (dummyt d  WITH seq = fcnt)
       SET fer.seq = 1
       PLAN (d)
        JOIN (fer
        WHERE (fer.parent_entity_id=request->sentences[s].id)
         AND (fer.filter_entity1_id=request->facilities[d.seq].code_value)
         AND fer.parent_entity_name="ORDER_SENTENCE"
         AND fer.filter_entity1_name="LOCATION")
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET stat = alterlist(reply->status_data.subeventstatus,1)
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Error deleting from filter_entity_reltn")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
    ENDFOR
    FOR (s = 1 TO scnt)
      SET ierrcode = 0
      INSERT  FROM filter_entity_reltn fer,
        (dummyt d  WITH seq = fcnt)
       SET fer.filter_entity_reltn_id = seq(reference_seq,nextval), fer.parent_entity_id = request->
        sentences[s].id, fer.filter_entity1_id = request->facilities[d.seq].code_value,
        fer.parent_entity_name = "ORDER_SENTENCE", fer.filter_entity1_name = "LOCATION", fer
        .filter_entity2_name = null,
        fer.filter_entity2_id = 0, fer.filter_entity3_name = null, fer.filter_entity3_id = 0,
        fer.filter_entity4_name = null, fer.filter_entity4_id = 0, fer.filter_entity5_name = null,
        fer.filter_entity5_id = 0, fer.filter_type_cd = ordsent_cd, fer.exclusion_filter_ind = null,
        fer.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), fer.end_effective_dt_tm =
        cnvtdatetime("31-dec-2100 00:00:00.00"), fer.updt_applctx = reqinfo->updt_applctx,
        fer.updt_cnt = 0, fer.updt_dt_tm = cnvtdatetime(curdate,curtime), fer.updt_id = reqinfo->
        updt_id,
        fer.updt_task = reqinfo->updt_task
       PLAN (d)
        JOIN (fer)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET stat = alterlist(reply->status_data.subeventstatus,1)
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Error inserting into filter_entity_reltn")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
 ELSEIF ((request->ensure_mode=2))
  IF (scnt > 0)
   SET ierrcode = 0
   DELETE  FROM filter_entity_reltn fer,
     (dummyt d  WITH seq = scnt)
    SET fer.seq = 1
    PLAN (d)
     JOIN (fer
     WHERE (fer.parent_entity_id=request->sentences[d.seq].id)
      AND fer.parent_entity_name="ORDER_SENTENCE"
      AND fer.filter_entity1_name="LOCATION")
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET stat = alterlist(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = concat(
     "Error deleting from filter_entity_reltn")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
  IF (scnt > fcnt
   AND scnt > 0)
   FOR (f = 1 TO fcnt)
     SET ierrcode = 0
     INSERT  FROM filter_entity_reltn fer,
       (dummyt d  WITH seq = scnt)
      SET fer.filter_entity_reltn_id = seq(reference_seq,nextval), fer.parent_entity_id = request->
       sentences[d.seq].id, fer.filter_entity1_id = request->facilities[f].code_value,
       fer.parent_entity_name = "ORDER_SENTENCE", fer.filter_entity1_name = "LOCATION", fer
       .filter_entity2_name = null,
       fer.filter_entity2_id = 0, fer.filter_entity3_name = null, fer.filter_entity3_id = 0,
       fer.filter_entity4_name = null, fer.filter_entity4_id = 0, fer.filter_entity5_name = null,
       fer.filter_entity5_id = 0, fer.filter_type_cd = ordsent_cd, fer.exclusion_filter_ind = null,
       fer.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), fer.end_effective_dt_tm =
       cnvtdatetime("31-dec-2100 00:00:00.00"), fer.updt_applctx = reqinfo->updt_applctx,
       fer.updt_cnt = 0, fer.updt_dt_tm = cnvtdatetime(curdate,curtime), fer.updt_id = reqinfo->
       updt_id,
       fer.updt_task = reqinfo->updt_task
      PLAN (d)
       JOIN (fer)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET stat = alterlist(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error inserting into filter_entity_reltn")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
   ENDFOR
  ELSEIF (fcnt > 0)
   FOR (s = 1 TO scnt)
     SET ierrcode = 0
     INSERT  FROM filter_entity_reltn fer,
       (dummyt d  WITH seq = fcnt)
      SET fer.filter_entity_reltn_id = seq(reference_seq,nextval), fer.parent_entity_id = request->
       sentences[s].id, fer.filter_entity1_id = request->facilities[d.seq].code_value,
       fer.parent_entity_name = "ORDER_SENTENCE", fer.filter_entity1_name = "LOCATION", fer
       .filter_entity2_name = null,
       fer.filter_entity2_id = 0, fer.filter_entity3_name = null, fer.filter_entity3_id = 0,
       fer.filter_entity4_name = null, fer.filter_entity4_id = 0, fer.filter_entity5_name = null,
       fer.filter_entity5_id = 0, fer.filter_type_cd = ordsent_cd, fer.exclusion_filter_ind = null,
       fer.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), fer.end_effective_dt_tm =
       cnvtdatetime("31-dec-2100 00:00:00.00"), fer.updt_applctx = reqinfo->updt_applctx,
       fer.updt_cnt = 0, fer.updt_dt_tm = cnvtdatetime(curdate,curtime), fer.updt_id = reqinfo->
       updt_id,
       fer.updt_task = reqinfo->updt_task
      PLAN (d)
       JOIN (fer)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET stat = alterlist(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error inserting into filter_entity_reltn")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
   ENDFOR
  ENDIF
 ELSEIF ((request->ensure_mode=3))
  IF ((request->facilities[1].code_value=0))
   IF (scnt > 0)
    SET ierrcode = 0
    DELETE  FROM filter_entity_reltn fer,
      (dummyt d  WITH seq = scnt)
     SET fer.seq = 1
     PLAN (d)
      JOIN (fer
      WHERE (fer.parent_entity_id=request->sentences[d.seq].id)
       AND fer.parent_entity_name="ORDER_SENTENCE"
       AND fer.filter_entity1_name="LOCATION")
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET stat = alterlist(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error deleting from filter_entity_reltn")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
  ELSE
   IF (scnt > fcnt
    AND scnt > 0)
    FOR (f = 1 TO fcnt)
      SET ierrcode = 0
      DELETE  FROM filter_entity_reltn fer,
        (dummyt d  WITH seq = scnt)
       SET fer.parent_entity_id = fer.parent_entity_id
       PLAN (d)
        JOIN (fer
        WHERE (fer.parent_entity_id=request->sentences[d.seq].id)
         AND (fer.filter_entity1_id=request->facilities[f].code_value)
         AND fer.parent_entity_name="ORDER_SENTENCE"
         AND fer.filter_entity1_name="LOCATION")
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET stat = alterlist(reply->status_data.subeventstatus,1)
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Error deleting from filter_entity_reltn")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
    ENDFOR
   ELSEIF (fcnt > 0)
    FOR (s = 1 TO scnt)
      SET ierrcode = 0
      DELETE  FROM filter_entity_reltn fer,
        (dummyt d  WITH seq = fcnt)
       SET fer.parent_entity_id = fer.parent_entity_id
       PLAN (d)
        JOIN (fer
        WHERE (fer.parent_entity_id=request->sentences[s].id)
         AND (fer.filter_entity1_id=request->facilities[d.seq].code_value)
         AND fer.parent_entity_name="ORDER_SENTENCE"
         AND fer.filter_entity1_name="LOCATION")
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET stat = alterlist(reply->status_data.subeventstatus,1)
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Error deleting from filter_entity_reltn")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
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
