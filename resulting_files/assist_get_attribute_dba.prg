CREATE PROGRAM assist_get_attribute:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 attrib_qual = i4
    1 attrib[10]
      2 column_name = c30
      2 data_type = c9
      2 data_length = i4
      2 data_precision = i4
      2 data_scale = i4
      2 nullable = c1
      2 column_id = f8
      2 default_length = i4
      2 data_default = c500
      2 num_distinct = i4
      2 low_value = c32
      2 high_value = c32
      2 density = i4
      2 code_set = f8
      2 primary_key_ind = i4
      2 show_ind = i4
      2 code_show_ind = i4
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET hassist_get_attribute = 0
 SET istatus = 0
 SET reply->status_data.status = "F"
 SET table_name = "ALL_TAB_COLUMNS"
 SET kount = 0
 IF ((request->view_name > " "))
  SELECT INTO "nl:"
   a.*
   FROM all_tab_columns a,
    code_value cv,
    code_value_extension cve1,
    code_value_extension cve2,
    code_value_extension cve3
   WHERE cv.code_set=344
    AND cve1.code_value=cv.code_value
    AND cve1.field_name="VIEW_NAME"
    AND (cve1.field_value=request->view_name)
    AND cve2.code_value=cv.code_value
    AND cve2.field_name="COLUMN_NAME"
    AND cve3.code_value=cv.code_value
    AND cve3.field_name="CODE_SHOW_IND"
    AND a.column_name=cve2.field_value
    AND (a.owner=request->owner)
    AND (a.table_name=request->table_name)
   ORDER BY a.column_id
   DETAIL
    kount = (kount+ 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alter(reply->attrib,(kount+ 10))
    ENDIF
    reply->attrib[kount].column_name = a.column_name, reply->attrib[kount].data_type = a.data_type,
    reply->attrib[kount].data_length = a.data_length,
    reply->attrib[kount].data_precision = a.data_precision, reply->attrib[kount].data_scale = a
    .data_scale, reply->attrib[kount].nullable = a.nullable,
    reply->attrib[kount].column_id = a.column_id, reply->attrib[kount].default_length = a
    .default_length, reply->attrib[kount].data_default = a.data_default,
    reply->attrib[kount].num_distinct = a.num_distinct, reply->attrib[kount].low_value = a.low_value,
    reply->attrib[kount].high_value = a.high_value,
    reply->attrib[kount].density = a.density, reply->attrib[kount].code_show_ind = cnvtint(cve3
     .field_value), reply->attrib[kount].show_ind = true
   WITH nocounter
  ;end select
  SET reply->attrib_qual = kount
 ELSE
  SELECT INTO "nl:"
   a.*
   FROM all_tab_columns a
   WHERE (a.owner=request->owner)
    AND (a.table_name=request->table_name)
   ORDER BY a.column_id
   DETAIL
    kount = (kount+ 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alter(reply->attrib,(kount+ 10))
    ENDIF
    reply->attrib[kount].column_name = a.column_name, reply->attrib[kount].data_type = a.data_type,
    reply->attrib[kount].data_length = a.data_length,
    reply->attrib[kount].data_precision = a.data_precision, reply->attrib[kount].data_scale = a
    .data_scale, reply->attrib[kount].nullable = a.nullable,
    reply->attrib[kount].column_id = a.column_id, reply->attrib[kount].default_length = a
    .default_length, reply->attrib[kount].data_default = a.data_default,
    reply->attrib[kount].num_distinct = a.num_distinct, reply->attrib[kount].low_value = a.low_value,
    reply->attrib[kount].high_value = a.high_value,
    reply->attrib[kount].density = a.density, reply->attrib[kount].code_show_ind = false, reply->
    attrib[kount].show_ind = true
   WITH nocounter
  ;end select
  SET reply->attrib_qual = kount
 ENDIF
 IF (curqual=0)
  SET failed = select_error
  GO TO check_error
 ELSE
  IF (kount=0)
   SET failed = none_found
  ENDIF
 ENDIF
 IF ((reply->attrib_qual > 0))
  FOR (inx0 = 1 TO reply->attrib_qual)
    SET reply->attrib[inx0].code_set = 0
    SET reply->attrib[inx0].primary_key_ind = false
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
      AND (e3.field_value=reply->attrib[inx0].column_name)
      AND e4.code_value=e1.code_value
      AND e4.field_name="CODE_SET"
      AND e5.code_value=e1.code_value
      AND e5.field_name="PRIMARY_KEY_IND"
      AND e6.code_value=e1.code_value
      AND e6.field_name="OVERRIDE_DATA_LENGTH"
     DETAIL
      reply->attrib[inx0].code_set = cnvtreal(e4.field_value), reply->attrib[inx0].primary_key_ind =
      cnvtint(e5.field_value)
      IF (cnvtint(e6.field_value) != 0)
       reply->attrib[inx0].data_length = cnvtint(e6.field_value)
      ENDIF
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
 IF ((request->view_name > " "))
  SELECT INTO "nl:"
   cve4.*, a.*
   FROM code_value cv,
    code_value_extension cve1,
    code_value_extension cve2,
    code_value_extension cve3,
    code_value_extension cve4,
    all_tab_columns a
   WHERE cv.code_set=346
    AND cve1.code_value=cv.code_value
    AND cve1.field_name="OWNER_NAME"
    AND (cve1.field_value=request->owner)
    AND cve2.code_value=cv.code_value
    AND cve2.field_name="TABLE_NAME"
    AND (cve2.field_value=request->table_name)
    AND cve3.code_value=cv.code_value
    AND cve3.field_name="PRIMARY_KEY_IND"
    AND cve3.field_value > concat(trim(cnvtstring(false),3))
    AND cve4.code_value=cv.code_value
    AND cve4.field_name="COLUMN_NAME"
    AND (a.owner=request->owner)
    AND (a.table_name=request->table_name)
    AND a.column_name=cve4.field_value
   DETAIL
    in_list = false
    FOR (inx0 = 1 TO reply->attrib_qual)
      IF ((reply->attrib[inx0].column_name=cve4.field_value))
       in_list = true
      ENDIF
    ENDFOR
    IF (in_list=false)
     reply->attrib_qual = (reply->attrib_qual+ 1)
     IF (mod(reply->attrib_qual,10)=1
      AND (reply->attrib_qual != 1))
      stat = alter(reply->attrib,(reply->attrib_qual+ 10))
     ENDIF
     reply->attrib[reply->attrib_qual].column_name = a.column_name, reply->attrib[reply->attrib_qual]
     .data_type = a.data_type, reply->attrib[reply->attrib_qual].data_length = a.data_length,
     reply->attrib[reply->attrib_qual].data_precision = a.data_precision, reply->attrib[reply->
     attrib_qual].data_scale = a.data_scale, reply->attrib[reply->attrib_qual].nullable = a.nullable,
     reply->attrib[reply->attrib_qual].column_id = a.column_id, reply->attrib[reply->attrib_qual].
     default_length = a.default_length, reply->attrib[reply->attrib_qual].data_default = a
     .data_default,
     reply->attrib[reply->attrib_qual].num_distinct = a.num_distinct, reply->attrib[reply->
     attrib_qual].low_value = a.low_value, reply->attrib[reply->attrib_qual].high_value = a
     .high_value,
     reply->attrib[reply->attrib_qual].density = a.density, reply->attrib[reply->attrib_qual].
     primary_key_ind = true, reply->attrib[reply->attrib_qual].code_show_ind = false,
     reply->attrib[reply->attrib_qual].show_ind = false
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alter(reply->attrib,reply->attrib_qual)
#check_error
 SET subeventcnt = size(reply->status_data.subeventstatus,5)
 SET subeventcnt = (subeventcnt+ 1)
 SET stat = alter(reply->status_data.subeventstatus,subeventcnt)
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  IF (failed=none_found)
   SET reply->status_data.status = "Z"
   SET reqinfo->commit_ind = true
  ELSE
   CASE (failed)
    OF gen_nbr_error:
     SET reply->status_data.subeventstatus[subeventcnt].operationname = "GEN_NBR"
    OF insert_error:
     SET reply->status_data.subeventstatus[subeventcnt].operationname = "INSERT"
    OF update_error:
     SET reply->status_data.subeventstatus[subeventcnt].operationname = "UPDATE"
    OF replace_error:
     SET reply->status_data.subeventstatus[subeventcnt].operationname = "REPLACE"
    OF delete_error:
     SET reply->status_data.subeventstatus[subeventcnt].operationname = "DELETE"
    OF undelete_error:
     SET reply->status_data.subeventstatus[subeventcnt].operationname = "UNDELETE"
    OF remove_error:
     SET reply->status_data.subeventstatus[subeventcnt].operationname = "REMOVE"
    OF attribute_error:
     SET reply->status_data.subeventstatus[subeventcnt].operationname = "ATTRIBUTE"
    OF lock_error:
     SET reply->status_data.subeventstatus[subeventcnt].operationname = "LOCK"
    OF event_log_error:
     SET reply->status_data.subeventstatus[subeventcnt].operationname = "EVENT_LOG"
    ELSE
     SET reply->status_data.subeventstatus[subeventcnt].operationname = "UNKNOWN"
   ENDCASE
   SET reply->status_data.subeventstatus[subeventcnt].operationstatus = "F"
   SET reply->status_data.subeventstatus[subeventcnt].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[subeventcnt].targetobjectvalue = table_name
   SET reqinfo->commit_ind = false
   SET subeventcnt = (subeventcnt+ 1)
   SET stat = alter(reply->status_data.subeventstatus,subeventcnt)
   SET reply->status_data.subeventstatus[subeventcnt].targetobjectname = "CCL_ERROR"
   SET ierrcode = error(serrmsg,0)
   SET reply->status_data.subeventstatus[subeventcnt].targetobjectvalue = serrmsg
   SET reply->status_data.subeventstatus[subeventcnt].operationname = "RECEIVE"
   SET reply->status_data.subeventstatus[subeventcnt].operationstatus = "S"
   CALL echo("FAILED: Table = [",0)
   CALL echo(table_name,0)
   CALL echo("]  failed to [",0)
   SET op_name = reply->status_data.subeventstatus[(subeventcnt - 1)].operationname
   CALL echo(op_name,0)
   CALL echo("]  ",1)
   CALL echo("        CCL error = [",0)
   CALL echo(serrmsg,0)
   CALL echo("]",1)
  ENDIF
 ENDIF
 GO TO end_program
#end_program
END GO
