CREATE PROGRAM bed_ens_hs_mapping:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 relations[*]
      2 health_sentry_item_relation_id = f8
      2 health_sentry_item_id = f8
      2 code_value = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 RECORD tempdeleterelation(
   1 relation[*]
     2 health_sentry_item_relation_id = f8
 )
 DECLARE relationcount = i4
 DECLARE insertcount = i4
 DECLARE deletecount = i4
 DECLARE relationid = f8
 SET relationcount = size(request->relations,5)
 IF (relationcount=0)
  GO TO exit_script
 ENDIF
 SET insertcount = 0
 SET deletecount = 0
 FOR (i = 1 TO relationcount)
   IF ((request->relations[i].action_flag=1))
    SELECT INTO "nl:"
     tempid = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      relationid = cnvtreal(tempid)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error selecting relation id")
    SET insertcount = (insertcount+ 1)
    SET stat = alterlist(reply->relations,insertcount)
    SET reply->relations[insertcount].code_value = request->relations[i].code_value
    SET reply->relations[insertcount].health_sentry_item_relation_id = relationid
    SET reply->relations[insertcount].health_sentry_item_id = request->relations[i].
    health_sentry_item_id
   ELSEIF ((request->relations[i].action_flag=3))
    SET deletecount = (deletecount+ 1)
    SET stat = alterlist(tempdeleterelation->relation,deletecount)
    SET tempdeleterelation->relation[deletecount].health_sentry_item_relation_id = request->
    relations[i].health_sentry_item_relation_id
   ENDIF
 ENDFOR
 IF (deletecount > 0)
  DELETE  FROM (dummyt d  WITH seq = deletecount),
    br_hlth_sntry_mill_item b
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_hlth_sntry_mill_item_id=tempdeleterelation->relation[d.seq].
    health_sentry_item_relation_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting mapping")
 ENDIF
 IF (insertcount > 0)
  DELETE  FROM (dummyt d  WITH seq = insertcount),
    br_name_value v
   SET v.seq = 1
   PLAN (d)
    JOIN (v
    WHERE v.br_nv_key1="HEALTHSENTIGN"
     AND (cnvtreal(v.br_name)=reply->relations[d.seq].health_sentry_item_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting name value prefs")
  INSERT  FROM (dummyt d  WITH seq = insertcount),
    br_hlth_sntry_mill_item b
   SET b.br_hlth_sntry_mill_item_id = reply->relations[d.seq].health_sentry_item_relation_id, b
    .code_value = reply->relations[d.seq].code_value, b.br_hlth_sntry_item_id = reply->relations[d
    .seq].health_sentry_item_id,
    b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting mapping")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
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
