CREATE PROGRAM assist_ens_attribute_det:dba
 SET trace = debug
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 owner = c30
    1 table_name = c30
    1 attribute_det_qual = i4
    1 attribute_det[10]
      2 column_name = c30
      2 code_set = f8
      2 primary_key_ind = i4
      2 override_data_length = i4
      2 success_ind = i4
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET hassist_ens_attribute_det = 0
 SET istatus = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET cd_found = false
 SET new_code_value = 0
 SET result = alter(reply->attribute_det,request->attribute_det_qual)
 SET reply->status_data.status = "F"
 CASE (request->action_type)
  OF "ADD":
   IF ((request->attribute_det_qual != 0))
    CALL validate_attribute_det(0)
    WHILE (cd_found=true)
     CALL del_attribute_det(0)
     CALL validate_attribute_det(0)
    ENDWHILE
    FOR (inx = 1 TO request->attribute_det_qual)
      CALL add_attribute_det(inx)
    ENDFOR
   ENDIF
  OF "DEL":
   IF ((request->attribute_det_qual != 0))
    FOR (inx = 1 TO request->attribute_det_qual)
     CALL validate_attribute_det(inx)
     IF (new_code_value != 0)
      CALL del_attribute_det(inx)
     ENDIF
    ENDFOR
   ENDIF
  OF "RPL":
   IF ((request->attribute_det_qual != 0))
    FOR (inx = 1 TO request->attribute_det_qual)
      CALL validate_attribute_det(inx)
      IF (new_code_value != 0)
       CALL del_attribute_det(inx)
      ENDIF
      CALL add_attribute_det(inx)
    ENDFOR
   ENDIF
  OF "UPT":
   IF ((request->attribute_det_qual != 0))
    FOR (inx = 1 TO request->attribute_det_qual)
      CALL validate_attribute_det(inx)
      IF (new_code_value != 0)
       CALL del_attribute_det(inx)
      ENDIF
      CALL add_attribute_det(inx)
    ENDFOR
   ENDIF
  ELSE
   SET failed = true
   GO TO check_error
 ENDCASE
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   OF select_error:
    SET reply->status_data.subeventstatus[1].operationname = "GET"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
  CALL echo("FAILED: Table = [",0)
  CALL echo(table_name,0)
  CALL echo("]  failed to [",0)
  SET op_name = reply->status_data.subeventstatus[1].operationname
  CALL echo(op_name,0)
  CALL echo("]  ",1)
  CALL echo("        CCL error = [",0)
  CALL echo(serrmsg,0)
  CALL echo("]",1)
 ENDIF
 GO TO end_program
 SUBROUTINE add_attribute_det(add_qual)
   SET table_name = "CODE_VALUE"
   SET new_code_value = 0
   SET reply->attribute_det[add_qual].success_ind = false
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_code_value = cnvtreal(y)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET failed = gen_nbr_error
    GO TO check_error
   ENDIF
   INSERT  FROM code_value cv
    SET cv.code_value = new_code_value, cv.code_set = 346, cv.cdf_meaning = null,
     cv.display = "ASSIST ATTRIBUTE_DET DATA", cv.display_key = "ASSIST ATTRIBUTE_DET DATA", cv
     .description = "DEFINES ASSIST ATTRIBUTE_DET",
     cv.definition = "", cv.collation_seq = 0, cv.active_type_cd = 1,
     cv.active_ind = true, cv.active_dt_tm = cnvtdatetime(curdate,curtime), cv.inactive_dt_tm = null,
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_id = reqinfo->updt_id, cv.updt_cnt = 1,
     cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = reqinfo->updt_task
    WHERE cv.code_value=new_code_value
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ENDIF
   SET table_name = "CODE_VALUE_EXTENSION"
   INSERT  FROM code_value_extension cve
    SET cve.code_set = 346, cve.field_name = "TABLE_NAME", cve.code_value = new_code_value,
     cve.field_type = 1, cve.field_value = request->table_name, cve.updt_dt_tm = cnvtdatetime(curdate,
      curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=346
     AND cve.field_name="TABLE_NAME"
     AND cve.code_value=new_code_value
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ELSE
    SET reply->table_name = request->table_name
   ENDIF
   SET table_name = "CODE_VALUE_EXTENSION"
   INSERT  FROM code_value_extension cve
    SET cve.code_set = 346, cve.field_name = "OWNER_NAME", cve.code_value = new_code_value,
     cve.field_type = 1, cve.field_value = request->owner, cve.updt_dt_tm = cnvtdatetime(curdate,
      curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=346
     AND cve.field_name="OWNER_NAME"
     AND cve.code_value=new_code_value
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ELSE
    SET reply->owner = request->owner
   ENDIF
   SET table_name = "CODE_VALUE_EXTENSION"
   INSERT  FROM code_value_extension cve
    SET cve.code_set = 346, cve.field_name = "COLUMN_NAME", cve.code_value = new_code_value,
     cve.field_type = 1, cve.field_value = request->attribute_det[add_qual].column_name, cve
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=346
     AND cve.field_name="COLUMN_NAME"
     AND cve.code_value=new_code_value
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ELSE
    SET reply->attribute_det[add_qual].column_name = request->attribute_det[add_qual].column_name
   ENDIF
   SET table_name = "CODE_VALUE_EXTENSION"
   INSERT  FROM code_value_extension cve
    SET cve.code_set = 346, cve.field_name = "CODE_SET", cve.code_value = new_code_value,
     cve.field_type = 1, cve.field_value = cnvtstring(request->attribute_det[add_qual].code_set), cve
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=346
     AND cve.field_name="CODE_SET"
     AND cve.code_value=new_code_value
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ELSE
    SET reply->attribute_det[add_qual].code_set = request->attribute_det[add_qual].code_set
   ENDIF
   SET table_name = "CODE_VALUE_EXTENSION"
   INSERT  FROM code_value_extension cve
    SET cve.code_set = 346, cve.field_name = "PRIMARY_KEY_IND", cve.code_value = new_code_value,
     cve.field_type = 1, cve.field_value = cnvtstring(request->attribute_det[add_qual].
      primary_key_ind), cve.updt_dt_tm = cnvtdatetime(curdate,curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=346
     AND cve.field_name="PRIMARY_KEY_IND"
     AND cve.code_value=new_code_value
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ELSE
    SET reply->attribute_det[add_qual].primary_key_ind = request->attribute_det[add_qual].
    primary_key_ind
   ENDIF
   SET table_name = "CODE_VALUE_EXTENSION"
   INSERT  FROM code_value_extension cve
    SET cve.code_set = 346, cve.field_name = "OVERRIDE_DATA_LENGTH", cve.code_value = new_code_value,
     cve.field_type = 1, cve.field_value = cnvtstring(request->attribute_det[add_qual].
      override_data_length), cve.updt_dt_tm = cnvtdatetime(curdate,curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=346
     AND cve.field_name="OVERRIDE_DATA_LENGTH"
     AND cve.code_value=new_code_value
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ELSE
    SET reply->attribute_det[add_qual].override_data_length = request->attribute_det[add_qual].
    override_data_length
   ENDIF
   SET reply->attribute_det[add_qual].success_ind = true
 END ;Subroutine
 SUBROUTINE del_attribute_det(del_qual)
   IF (new_code_value != 0)
    DELETE  FROM code_value_extension cve
     WHERE cve.code_value=new_code_value
    ;end delete
    DELETE  FROM code_value cv
     WHERE cv.code_value=new_code_value
    ;end delete
   ENDIF
 END ;Subroutine
 SUBROUTINE validate_attribute_det(validate_qual)
   SET table_name = "CODE_VALUE_EXTENSION"
   SET kount = 0
   SET new_code_value = 0
   SELECT INTO "nl:"
    c.code_value
    FROM code_value c,
     code_value_extension e1,
     code_value_extension e2,
     code_value_extension e3
    WHERE c.code_set=346
     AND c.code_value=e1.code_value
     AND e1.field_name="OWNER_NAME"
     AND (e1.field_value=request->owner)
     AND c.code_value=e2.code_value
     AND e2.field_name="TABLE_NAME"
     AND (e2.field_value=request->table_name)
     AND c.code_value=e3.code_value
     AND e3.field_name="COLUMN_NAME"
     AND (e3.field_value=request->attribute_det[validate_qual].column_name)
    DETAIL
     new_code_value = c.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET cd_found = false
   ELSE
    SET cd_found = true
   ENDIF
 END ;Subroutine
#end_program
END GO
