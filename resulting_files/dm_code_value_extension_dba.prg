CREATE PROGRAM dm_code_value_extension:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "f"
 SELECT INTO "nl:"
  cse.*
  FROM code_set_extension cse
  WHERE cse.code_set=cnvtint(dmrequest->code_set)
   AND (cse.field_name=dmrequest->field_name)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET ret_code_value = 0.00
  SELECT INTO "nl:"
   a.code_value
   FROM code_value a
   WHERE (a.cki=dmrequest->cki)
    AND (a.code_set=dmrequest->code_set)
   DETAIL
    ret_code_value = a.code_value
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET upd_id = 0
   SET upd_task = 0
   SET upd_applctx = 0
   SET upd_cnt = - (1)
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_value=ret_code_value
     AND (cve.field_name=dmrequest->field_name)
     AND (cve.code_set=dmrequest->code_set)
    DETAIL
     upd_id = cve.updt_id, upd_task = cve.updt_task, upd_applctx = cve.updt_applctx,
     upd_cnt = cve.updt_cnt
    WITH nocounter
   ;end select
   IF (curqual > 0)
    IF (upd_id=111
     AND (upd_task=- (1))
     AND (upd_applctx=- (2))
     AND upd_cnt=0)
     UPDATE  FROM code_value_extension cve
      SET cve.field_type = dmrequest->field_type, cve.field_value = dmrequest->field_value, cve
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       cve.updt_applctx = reqinfo->updt_applctx, cve.updt_id = reqinfo->updt_id, cve.updt_cnt = (cve
       .updt_cnt+ 1),
       cve.updt_task = reqinfo->updt_task
      WHERE cve.code_value=ret_code_value
       AND (cve.field_name=dmrequest->field_name)
       AND (cve.code_set=dmrequest->code_set)
      WITH nocounter
     ;end update
    ENDIF
   ELSE
    INSERT  FROM code_value_extension cve
     SET cve.field_type = dmrequest->field_type, cve.field_value = dmrequest->field_value, cve
      .updt_applctx = reqinfo->updt_applctx,
      cve.updt_dt_tm = cnvtdatetime(curdate,curtime3), cve.updt_id = reqinfo->updt_id, cve.updt_cnt
       = 0,
      cve.updt_task = reqinfo->updt_task, cve.code_value = ret_code_value, cve.field_name = dmrequest
      ->field_name,
      cve.code_set = dmrequest->code_set
     WITH nocounter
    ;end insert
   ENDIF
  ENDIF
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
