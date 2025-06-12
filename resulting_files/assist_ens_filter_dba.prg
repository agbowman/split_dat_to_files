CREATE PROGRAM assist_ens_filter:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 owner = c30
    1 table_name = c30
    1 view_name = c100
    1 filter_qual = i4
    1 filter[10]
      2 column_name = c30
      2 operation = c9
      2 compare_value = c100
      2 compare_value_data_type = c9
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
 SET hassist_ens_filter = 0
 SET istatus = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET cd_found = false
 SET new_code_value = 0
 SET result = alter(reply->filter,request->filter_qual)
 SET reply->status_data.status = "F"
 CASE (request->action_type)
  OF "ADD":
   IF ((request->filter_qual != 0))
    CALL validate_view(0)
    WHILE (cd_found=true)
     CALL del_view(0)
     CALL validate_view(0)
    ENDWHILE
    FOR (inx = 1 TO request->filter_qual)
      CALL add_view(inx)
    ENDFOR
   ENDIF
  OF "DEL":
   CALL validate_view(0)
   WHILE (cd_found=true)
    CALL del_view(0)
    CALL validate_view(0)
   ENDWHILE
  OF "RPL":
   IF ((request->filter_qual != 0))
    CALL validate_view(0)
    WHILE (cd_found=true)
     CALL del_view(0)
     CALL validate_view(0)
    ENDWHILE
    FOR (inx = 1 TO request->filter_qual)
      CALL add_view(inx)
    ENDFOR
   ENDIF
  OF "UPT":
   IF ((request->filter_qual != 0))
    FOR (inx = 1 TO request->filter_qual)
      CALL validate_view_det(inx)
      IF (new_code_value != 0)
       CALL del_view(inx)
      ENDIF
      CALL add_view(inx)
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
 SUBROUTINE add_view(add_qual)
   SET table_name = "CODE_VALUE"
   SET new_code_value = 0
   SET reply->filter[add_qual].success_ind = false
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
    SET cv.code_value = new_code_value, cv.code_set = 347, cv.cdf_meaning = null,
     cv.display = "ASSIST FILTER DATA", cv.display_key = "ASSIST FILTER DATA", cv.description =
     "DEFINES ASSIST FILTER",
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
    SET cve.code_set = 347, cve.field_name = "VIEW_NAME", cve.code_value = new_code_value,
     cve.field_type = 1, cve.field_value = request->view_name, cve.updt_dt_tm = cnvtdatetime(curdate,
      curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=347
     AND cve.field_name="VIEW_NAME"
     AND cve.code_value=new_code_value
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ELSE
    SET reply->view_name = request->view_name
   ENDIF
   SET table_name = "CODE_VALUE_EXTENSION"
   INSERT  FROM code_value_extension cve
    SET cve.code_set = 347, cve.field_name = "TABLE_NAME", cve.code_value = new_code_value,
     cve.field_type = 1, cve.field_value = request->table_name, cve.updt_dt_tm = cnvtdatetime(curdate,
      curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=347
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
    SET cve.code_set = 347, cve.field_name = "OWNER_NAME", cve.code_value = new_code_value,
     cve.field_type = 1, cve.field_value = request->owner, cve.updt_dt_tm = cnvtdatetime(curdate,
      curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=347
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
    SET cve.code_set = 347, cve.field_name = "COLUMN_NAME", cve.code_value = new_code_value,
     cve.field_type = 1, cve.field_value = request->filter[add_qual].column_name, cve.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=347
     AND cve.field_name="COLUMN_NAME"
     AND cve.code_value=new_code_value
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ELSE
    SET reply->filter[add_qual].column_name = request->filter[add_qual].column_name
   ENDIF
   SET table_name = "CODE_VALUE_EXTENSION"
   INSERT  FROM code_value_extension cve
    SET cve.code_set = 347, cve.field_name = "OPERATION", cve.code_value = new_code_value,
     cve.field_type = 1, cve.field_value = request->filter[add_qual].operation, cve.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=347
     AND cve.field_name="OPERATION"
     AND cve.code_value=new_code_value
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ELSE
    SET reply->filter[add_qual].operation = request->filter[add_qual].operation
   ENDIF
   SET table_name = "CODE_VALUE_EXTENSION"
   INSERT  FROM code_value_extension cve
    SET cve.code_set = 347, cve.field_name = "COMPARE_VALUE", cve.code_value = new_code_value,
     cve.field_type = 1, cve.field_value = request->filter[add_qual].compare_value, cve.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=347
     AND cve.field_name="COMPARE_VALUE"
     AND cve.code_value=new_code_value
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ELSE
    SET reply->filter[add_qual].compare_value = request->filter[add_qual].compare_value
   ENDIF
   SET table_name = "CODE_VALUE_EXTENSION"
   INSERT  FROM code_value_extension cve
    SET cve.code_set = 347, cve.field_name = "COMPARE_VALUE_DATA_TYPE", cve.code_value =
     new_code_value,
     cve.field_type = 1, cve.field_value = request->filter[add_qual].compare_value_data_type, cve
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 1, cve.updt_task = reqinfo->updt_task,
     cve.updt_applctx = reqinfo->updt_applctx
    WHERE cve.code_set=347
     AND cve.field_name="COMPARE_VALUE_DATA_TYPE"
     AND cve.code_value=new_code_value
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ELSE
    SET reply->filter[add_qual].compare_value_data_type = request->filter[add_qual].
    compare_value_data_type
   ENDIF
   SET reply->filter[add_qual].success_ind = false
 END ;Subroutine
 SUBROUTINE del_view(del_qual)
   IF (new_code_value)
    DELETE  FROM code_value_extension cve
     WHERE cve.code_value=new_code_value
    ;end delete
    DELETE  FROM code_value cv
     WHERE cv.code_value=new_code_value
    ;end delete
   ENDIF
 END ;Subroutine
 SUBROUTINE validate_view(validate_qual)
   SET table_name = "CODE_VALUE_EXTENSION"
   SET kount = 0
   SET new_code_value = 0
   CASE (request->filter_type)
    OF "F":
     SELECT INTO "nl:"
      c.code_value
      FROM code_value c,
       code_value_extension e1,
       code_value_extension e2,
       code_value_extension e3,
       code_value_extension e4
      WHERE c.code_set=347
       AND c.code_value=e1.code_value
       AND e1.field_name="OWNER_NAME"
       AND (e1.field_value=request->owner)
       AND c.code_value=e2.code_value
       AND e2.field_name="TABLE_NAME"
       AND (e2.field_value=request->table_name)
       AND c.code_value=e3.code_value
       AND e3.field_name="VIEW_NAME"
       AND (e3.field_value=request->view_name)
       AND c.code_value=e4.code_value
       AND e4.field_name="OPERATION"
       AND e4.field_value != "ORDER BY"
      DETAIL
       new_code_value = c.code_value
      WITH nocounter
     ;end select
    OF "O":
     SELECT INTO "nl:"
      c.code_value
      FROM code_value c,
       code_value_extension e1,
       code_value_extension e2,
       code_value_extension e3,
       code_value_extension e4
      WHERE c.code_set=347
       AND c.code_value=e1.code_value
       AND e1.field_name="OWNER_NAME"
       AND (e1.field_value=request->owner)
       AND c.code_value=e2.code_value
       AND e2.field_name="TABLE_NAME"
       AND (e2.field_value=request->table_name)
       AND c.code_value=e3.code_value
       AND e3.field_name="VIEW_NAME"
       AND (e3.field_value=request->view_name)
       AND c.code_value=e4.code_value
       AND e4.field_name="OPERATION"
       AND e4.field_value="ORDER BY"
      DETAIL
       new_code_value = c.code_value
      WITH nocounter
     ;end select
   ENDCASE
   IF (curqual=0)
    SET cd_found = false
   ELSE
    SET cd_found = true
   ENDIF
 END ;Subroutine
 SUBROUTINE validate_view_det(validate_qual)
   SET table_name = "CODE_VALUE_EXTENSION"
   SET kount = 0
   SET new_code_value = 0
   SELECT INTO "nl:"
    c.code_value
    FROM code_value c,
     code_value_extension e1,
     code_value_extension e2,
     code_value_extension e3,
     code_value_extension e4
    WHERE c.code_set=347
     AND c.code_value=e1.code_value
     AND e1.field_name="OWNER_NAME"
     AND (e1.field_value=request->owner)
     AND c.code_value=e2.code_value
     AND e2.field_name="TABLE_NAME"
     AND (e2.field_value=request->table_name)
     AND c.code_value=e3.code_value
     AND e3.field_name="VIEW_NAME"
     AND (e3.field_value=request->view_name)
     AND c.code_value=e4.code_value
     AND e4.field_name="COLUMN_NAME"
     AND (e4.field_value=request->filter[validate_qual].column_name)
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
