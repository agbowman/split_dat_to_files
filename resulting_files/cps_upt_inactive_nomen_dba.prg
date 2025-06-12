CREATE PROGRAM cps_upt_inactive_nomen:dba
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
   1 nomenclature_id = f8
   1 source_identifier = vc
   1 source_vocabulary_cd = f8
   1 exception_errmsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD list(
   1 qual[*]
     2 id = f8
     2 chg_date = i2
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET table_name = "NOMENCLATURE"
 SET failed = false
 SET knt = 0
 SET nbr_to_update = 0
 SET reply->nomenclature_id = request->nomenclature_id
 SET reply->source_identifier = request->source_identifier
 SET reply->source_vocabulary_cd = request->source_vocabulary_cd
 SET code_value = 0
 SET code_set = 48
 SET cdf_meaning = "INACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET active_status_cd = code_value
 IF ((request->nomenclature_id > 0))
  SELECT INTO "nl:"
   n.nomenclature_id
   FROM nomenclature n
   WHERE (n.nomenclature_id=request->nomenclature_id)
    AND n.active_ind=true
   HEAD REPORT
    knt = 0, stat = alterlist(list->qual,10)
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(list->qual,(knt+ 9))
    ENDIF
    list->qual[knt].id = n.nomenclature_id, date_flag = datetimecmp(n.end_effective_dt_tm,
     cnvtdatetime(curdate,curtime3))
    IF (date_flag < 0)
     list->qual[knt].chg_date = false
    ELSE
     list->qual[knt].chg_date = true
    ENDIF
   FOOT REPORT
    stat = alterlist(list->qual,knt)
   WITH nocounter, forupdate(n)
  ;end select
  IF (curqual != 1)
   SET failed = lock_error
   GO TO error_check
  ELSE
   SET nbr_to_update = size(list->qual,5)
   UPDATE  FROM nomenclature n,
     (dummyt d  WITH seq = value(nbr_to_update))
    SET d.seq = 1, n.active_ind = false, n.end_effective_dt_tm =
     IF ((list->qual[d.seq].chg_date=false)) n.end_effective_dt_tm
     ELSE cnvtdatetime(curdate,curtime3)
     ENDIF
     ,
     n.active_status_cd = active_status_cd, n.active_status_dt_tm = cnvtdatetime(curdate,curtime3), n
     .active_status_prsnl_id = reqinfo->updt_id,
     n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = reqinfo
     ->updt_id,
     n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (n
     WHERE (n.nomenclature_id=list->qual[d.seq].id))
    WITH nocounter
   ;end update
   IF (curqual != 1)
    SET failed = update_error
    GO TO error_check
   ENDIF
  ENDIF
 ELSEIF ((request->source_identifier > " "))
  SELECT INTO "nl:"
   n.nomenclature_id
   FROM nomenclature n
   WHERE (n.source_vocabulary_cd=request->source_vocabulary_cd)
    AND (n.source_identifier=request->source_identifier)
    AND n.active_ind=true
   HEAD REPORT
    knt = 0, stat = alterlist(list->qual,10)
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(list->qual,(knt+ 9))
    ENDIF
    list->qual[knt].id = n.nomenclature_id, date_flag = datetimecmp(n.end_effective_dt_tm,
     cnvtdatetime(curdate,curtime3))
    IF (date_flag < 0)
     list->qual[knt].chg_date = false
    ELSE
     list->qual[knt].chg_date = true
    ENDIF
   FOOT REPORT
    stat = alterlist(list->qual,knt)
   WITH nocounter, forupdate(n)
  ;end select
  IF (curqual < 1)
   SET failed = lock_error
   GO TO error_check
  ELSE
   SET nbr_to_update = size(list->qual,5)
   UPDATE  FROM nomenclature n,
     (dummyt d  WITH seq = value(nbr_to_update))
    SET d.seq = 1, n.active_ind = false, n.end_effective_dt_tm =
     IF ((list->qual[d.seq].chg_date=false)) n.end_effective_dt_tm
     ELSE cnvtdatetime(curdate,curtime3)
     ENDIF
     ,
     n.active_status_cd = active_status_cd, n.active_status_dt_tm = cnvtdatetime(curdate,curtime3), n
     .active_status_prsnl_id = reqinfo->updt_id,
     n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = reqinfo
     ->updt_id,
     n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (n
     WHERE (n.nomenclature_id=list->qual[d.seq].id))
    WITH nocounter
   ;end update
   IF (curqual != nbr_to_update)
    SET failed = update_error
    GO TO error_check
   ENDIF
  ENDIF
 ELSE
  SET failed = attribute_error
  GO TO error_check
 ENDIF
#error_check
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reply->exception_errmsg = "SUCCESS"
  SET reqinfo->commit_ind = true
 ELSE
  SET reqinfo->commit_ind = false
  CASE (failed)
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->exception_errmsg = "FAILED TO DELETE"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->exception_errmsg = "FAILED TO UPDATE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "NONE"
    SET reply->exception_errmsg = "FAILURE : INVALID NOMENCLATURE_ID AND SOURCE_IDENTIFIER"
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
