CREATE PROGRAM assist_get_filter:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 filter_qual = i4
    1 filter[10]
      2 column_name = c30
      2 operation = c9
      2 compare_value = c100
      2 compare_value_data_type = c9
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET hassist_get_filter = 0
 SET istatus = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET table_name = "CODE_VALUE_EXTENSION"
 SET kount = 0
 CASE (request->filter_type)
  OF "F":
   SELECT INTO "nl:"
    e4.field_value, e5.field_value, e6.field_value,
    e7.field_value
    FROM code_value c,
     code_value_extension e1,
     code_value_extension e2,
     code_value_extension e3,
     code_value_extension e4,
     code_value_extension e5,
     code_value_extension e6,
     code_value_extension e7
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
     AND c.code_value=e5.code_value
     AND e5.field_name="OPERATION"
     AND e5.field_value != "ORDER BY"
     AND c.code_value=e6.code_value
     AND e6.field_name="COMPARE_VALUE"
     AND c.code_value=e7.code_value
     AND e7.field_name="COMPARE_VALUE_DATA_TYPE"
    ORDER BY cnvtint(e5.field_value)
    DETAIL
     kount = (kount+ 1)
     IF (mod(kount,10)=1
      AND kount != 1)
      stat = alter(reply->filter,(kount+ 10))
     ENDIF
     reply->filter[kount].column_name = e4.field_value, reply->filter[kount].operation = e5
     .field_value, reply->filter[kount].compare_value = e6.field_value,
     reply->filter[kount].compare_value_data_type = e7.field_value
    WITH nocounter
   ;end select
  OF "O":
   SELECT INTO "nl:"
    e4.field_value, e5.field_value
    FROM code_value c,
     code_value_extension e1,
     code_value_extension e2,
     code_value_extension e3,
     code_value_extension e4,
     code_value_extension e5
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
     AND c.code_value=e5.code_value
     AND e5.field_name="OPERATION"
     AND e5.field_value="ORDER BY"
    DETAIL
     kount = (kount+ 1)
     IF (mod(kount,10)=1
      AND kount != 1)
      stat = alter(reply->filter,(kount+ 10))
     ENDIF
     reply->filter[kount].column_name = e4.field_value, reply->filter[kount].operation = e5
     .field_value
    WITH nocounter
   ;end select
 ENDCASE
 SET reply->filter_qual = kount
 SET stat = alter(reply->filter,reply->filter_qual)
 IF (curqual=0)
  SET failed = select_error
  GO TO check_error
 ENDIF
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
#end_program
END GO
