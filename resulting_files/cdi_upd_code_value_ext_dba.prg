CREATE PROGRAM cdi_upd_code_value_ext:dba
 IF (validate(gen_nbr_error,- (1)) != 3)
  DECLARE gen_nbr_error = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(insert_error,- (1)) != 4)
  DECLARE insert_error = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(update_error,- (1)) != 5)
  DECLARE update_error = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(replace_error,- (1)) != 6)
  DECLARE replace_error = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(delete_error,- (1)) != 7)
  DECLARE delete_error = i2 WITH protect, noconstant(7)
 ENDIF
 IF (validate(undelete_error,- (1)) != 8)
  DECLARE undelete_error = i2 WITH protect, noconstant(8)
 ENDIF
 IF (validate(remove_error,- (1)) != 9)
  DECLARE remove_error = i2 WITH protect, noconstant(9)
 ENDIF
 IF (validate(attribute_error,- (1)) != 10)
  DECLARE attribute_error = i2 WITH protect, noconstant(10)
 ENDIF
 IF (validate(lock_error,- (1)) != 11)
  DECLARE lock_error = i2 WITH protect, noconstant(11)
 ENDIF
 IF (validate(none_found,- (1)) != 12)
  DECLARE none_found = i2 WITH protect, noconstant(12)
 ENDIF
 IF (validate(select_error,- (1)) != 13)
  DECLARE select_error = i2 WITH protect, noconstant(13)
 ENDIF
 IF (validate(insert_duplicate,- (1)) != 14)
  DECLARE version_insert_error = i2 WITH protect, noconstant(16)
 ENDIF
 IF (validate(uar_error,- (1)) != 20)
  DECLARE uar_error = i2 WITH protect, noconstant(20)
 ENDIF
 IF (validate(failed,- (1)) != 0)
  DECLARE failed = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH protect, noconstant(" ")
 ELSE
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(error_value,"ZZZ")="ZZZ")
  DECLARE error_value = vc WITH protect, noconstant(fillstring(150," "))
 ENDIF
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE number_to_upd = i4 WITH public, noconstant(0)
 DECLARE count1 = i4 WITH public, noconstant(0)
 SET number_to_upd = size(request->qual,5)
 SET count1 = 0
 SET reply->status_data.status = "F"
 UPDATE  FROM code_value_extension c,
   (dummyt d  WITH seq = value(number_to_upd))
  SET c.seq = 1, c.field_value = cnvtupper(request->qual[d.seq].field_value), c.updt_cnt = (c
   .updt_cnt+ 1),
   c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_applctx =
   reqinfo->updt_applctx,
   c.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=request->qual[d.seq].code_value)
    AND (c.code_set=request->qual[d.seq].code_set)
    AND c.field_name=cnvtupper(request->qual[d.seq].field_name))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = update_error
  GO TO exit_script
 ENDIF
 CALL echo("After update")
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  IF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE_EXTENSION"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Failure to update code value extensions"
  SET reqinfo->commit_ind = false
 ENDIF
END GO
