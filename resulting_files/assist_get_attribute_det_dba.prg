CREATE PROGRAM assist_get_attribute_det:dba
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
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET hassist_get_attribute_det = 0
 SET istatus = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET table_name = "CODE_VALUE_EXTENSION"
 SET kount = 0
 IF ((request->column_name > " "))
  SELECT DISTINCT INTO "nl:"
   e1.field_value, e2.field_value, e3.field_value,
   e4.field_value, e5.field_value, e6.field_value
   FROM code_value_extension e1,
    code_value_extension e2,
    code_value_extension e3,
    code_value_extension e4,
    code_value_extension e5,
    code_value_extension e6
   WHERE e1.code_set=346
    AND e1.code_value=e1.code_value
    AND e1.field_name="OWNER_NAME"
    AND (e1.field_value=request->owner)
    AND e2.code_value=e1.code_value
    AND e2.field_name="TABLE_NAME"
    AND (e2.field_value=request->table_name)
    AND e3.code_value=e1.code_value
    AND e3.field_name="COLUMN_NAME"
    AND (e3.field_value=request->column_name)
    AND e4.code_value=e1.code_value
    AND e4.field_name="CODE_SET"
    AND e5.code_value=e1.code_value
    AND e5.field_name="PRIMARY_KEY_IND"
    AND e6.code_value=e1.code_value
    AND e6.field_name="OVERRIDE_DATA_LENGTH"
   DETAIL
    kount = (kount+ 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alter(reply->attribute_det,(kount+ 10))
    ENDIF
    reply->owner = e1.field_value, reply->table_name = e2.field_value, reply->attribute_det[kount].
    column_name = e3.field_value,
    reply->attribute_det[kount].code_set = cnvtreal(e4.field_value), reply->attribute_det[kount].
    primary_key_ind = cnvtint(e5.field_value), reply->attribute_det[kount].override_data_length =
    cnvtint(e6.field_value)
   WITH nocounter
  ;end select
  SET reply->attribute_det_qual = kount
 ELSE
  SELECT DISTINCT INTO "nl:"
   e1.field_value, e2.field_value, e3.field_value,
   e4.field_value, e5.field_value, e6.field_value
   FROM code_value_extension e1,
    code_value_extension e2,
    code_value_extension e3,
    code_value_extension e4,
    code_value_extension e5,
    code_value_extension e6
   WHERE e1.code_set=346
    AND e1.code_value=e1.code_value
    AND e1.field_name="OWNER_NAME"
    AND (e1.field_value=request->owner)
    AND e2.code_value=e1.code_value
    AND e2.field_name="TABLE_NAME"
    AND (e2.field_value=request->table_name)
    AND e3.code_value=e1.code_value
    AND e3.field_name="COLUMN_NAME"
    AND e4.code_value=e1.code_value
    AND e4.field_name="CODE_SET"
    AND e5.code_value=e1.code_value
    AND e5.field_name="PRIMARY_KEY_IND"
    AND e6.code_value=e1.code_value
    AND e6.field_name="OVERRIDE_DATA_LENGTH"
   DETAIL
    kount = (kount+ 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alter(reply->attribute_det,(kount+ 10))
    ENDIF
    reply->owner = e1.field_value, reply->table_name = e2.field_value, reply->attribute_det[kount].
    column_name = e3.field_value,
    reply->attribute_det[kount].code_set = cnvtreal(e4.field_value), reply->attribute_det[kount].
    primary_key_ind = cnvtint(e5.field_value), reply->attribute_det[kount].override_data_length =
    cnvtint(e6.field_value)
   WITH nocounter
  ;end select
  SET reply->attribute_det_qual = kount
 ENDIF
 IF (curqual=0)
  SET failed = select_error
  GO TO check_error
 ENDIF
 SET stat = alter(reply->attribute_det,reply->attribute_det_qual)
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
