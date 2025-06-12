CREATE PROGRAM cps_add_nomen_axis:dba
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 RECORD reply(
   1 exception_errmsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE kia_version = vc
 SET kia_version = "04-03-2003"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET table_name = "CODE_VALUE_GROUP"
 SET failed = false
 SET knt = 0
 SET nbr_to_insert = size(request->group,5)
 SELECT INTO "nl:"
  cvg.parent_code_value, cvg.code_set
  FROM code_value_group cvg
  PLAN (cvg
   WHERE (cvg.parent_code_value=request->source_vocabulary_cd)
    AND (cvg.code_set=request->group[1].code_set))
  HEAD REPORT
   knt = 0
  DETAIL
   knt = (knt+ 1)
  WITH nocounter, forupdate(cvg)
 ;end select
 IF (curqual < 1)
  SET reply->exception_errmsg = "LOCKED 0 ROWS"
 ELSE
  DELETE  FROM code_value_group cvg
   WHERE (cvg.parent_code_value=request->source_vocabulary_cd)
    AND (cvg.code_set=request->group[1].code_set)
   WITH nocounter
  ;end delete
  IF (curqual != knt)
   SET failed = delete_error
   GO TO error_check
  ENDIF
 ENDIF
 IF (nbr_to_insert=0)
  SELECT INTO "nl:"
   cvg.parent_code_value, cvg.code_set
   FROM code_value_group cvg
   PLAN (cvg
    WHERE (cvg.parent_code_value=request->source_vocabulary_cd)
     AND cvg.code_set=15849)
   HEAD REPORT
    knt = 0
   DETAIL
    knt = (knt+ 1)
   WITH nocounter, forupdate(cvg)
  ;end select
  IF (curqual < 1)
   SET reply->exception_errmsg = "LOCKED 0 ROWS"
  ELSE
   DELETE  FROM code_value_group cvg
    WHERE (cvg.parent_code_value=request->source_vocabulary_cd)
     AND cvg.code_set=15849
    WITH nocounter
   ;end delete
   IF (curqual != knt)
    SET failed = delete_error
    GO TO error_check
   ENDIF
  ENDIF
 ENDIF
 IF (nbr_to_insert > 0
  AND (request->group[1].source_vocabulary_axis_cd != - (1)))
  INSERT  FROM code_value_group cvg,
    (dummyt d  WITH seq = value(nbr_to_insert))
   SET cvg.parent_code_value = request->source_vocabulary_cd, cvg.child_code_value = request->group[d
    .seq].source_vocabulary_axis_cd, cvg.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cvg.updt_id = reqinfo->updt_id, cvg.updt_task = reqinfo->updt_task, cvg.updt_applctx = reqinfo->
    updt_applctx,
    cvg.updt_cnt = 0, cvg.code_set = request->group[d.seq].code_set
   PLAN (d)
    JOIN (cvg)
   WITH nocounter
  ;end insert
  IF (curqual != nbr_to_insert)
   SET failed = insert_error
  ENDIF
 ENDIF
#error_check
 IF (failed=false)
  IF (nbr_to_insert > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
  SET reply->exception_errmsg = "SUCCESS"
  SET reqinfo->commit_ind = true
 ELSE
  SET reqinfo->commit_ind = false
  CASE (failed)
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->exception_errmsg = "FAILED TO DELETE"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->exception_errmsg = "FAILED TO INSERT"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->exception_errmsg = "FAILED UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ENDIF
END GO
