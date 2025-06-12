CREATE PROGRAM bed_ens_iview_units:dba
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
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = size(request->codes,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO cnt)
   SET field_value = 0
   SET add_ext = 0
   SET dd_exist = 0
   IF ((request->codes[x].action_flag=1))
    SELECT INTO "nl:"
     FROM code_value_extension e
     PLAN (e
      WHERE (e.code_value=request->codes[x].code_value)
       AND e.field_name="PHARM_UNIT"
       AND e.code_set=54)
     DETAIL
      field_value = cnvtint(e.field_value)
      IF (band(field_value,96) > 0)
       dd_exist = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET add_ext = 1
    ENDIF
    IF (add_ext=1)
     INSERT  FROM code_value_extension e
      SET e.code_value = request->codes[x].code_value, e.code_set = 54, e.field_name = "PHARM_UNIT",
       e.field_type = 1, e.field_value = "96", e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       e.updt_id = reqinfo->updt_id, e.updt_cnt = 0, e.updt_task = reqinfo->updt_task,
       e.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
    IF (add_ext=0
     AND dd_exist=0)
     SET field_value = (field_value+ 96)
     UPDATE  FROM code_value_extension e
      SET e.field_value = cnvtstring(field_value), e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e
       .updt_id = reqinfo->updt_id,
       e.updt_cnt = (e.updt_cnt+ 1), e.updt_task = reqinfo->updt_task, e.updt_applctx = reqinfo->
       updt_applctx
      PLAN (e
       WHERE (e.code_value=request->codes[x].code_value)
        AND e.field_name="PHARM_UNIT"
        AND e.code_set=54)
      WITH nocounter
     ;end update
    ENDIF
   ELSEIF ((request->codes[x].action_flag=3))
    SELECT INTO "nl:"
     FROM code_value_extension e
     PLAN (e
      WHERE (e.code_value=request->codes[x].code_value)
       AND e.field_name="PHARM_UNIT"
       AND e.code_set=54)
     DETAIL
      field_value = cnvtint(e.field_value)
      IF (band(field_value,96) > 0)
       dd_exist = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (dd_exist=1)
     SET field_value = (field_value - 96)
     UPDATE  FROM code_value_extension e
      SET e.field_value = cnvtstring(field_value), e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e
       .updt_id = reqinfo->updt_id,
       e.updt_cnt = (e.updt_cnt+ 1), e.updt_task = reqinfo->updt_task, e.updt_applctx = reqinfo->
       updt_applctx
      PLAN (e
       WHERE (e.code_value=request->codes[x].code_value)
        AND e.field_name="PHARM_UNIT"
        AND e.code_set=54)
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (failed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
