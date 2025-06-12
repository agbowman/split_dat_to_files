CREATE PROGRAM cps_upt_concept:dba
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
 RECORD cdvalue(
   1 concept_source_cd = f8
   1 review_status_cd = f8
   1 active_status_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value c1,
   code_value c2,
   code_value c3
  PLAN (c1
   WHERE c1.code_set=12100
    AND c1.cdf_meaning="CERNER")
   JOIN (c2
   WHERE c2.code_set=12101
    AND c2.cdf_meaning="REVIEWED")
   JOIN (c3
   WHERE c3.code_set=48
    AND c3.cdf_meaning="ACTIVE")
  DETAIL
   cdvalue->concept_source_cd = c1.code_value, cdvalue->review_status_cd = c2.code_value, cdvalue->
   active_status_cd = c3.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = select_error
  SET dhtable_name = "CODE_VALUE"
  SET serrmsg_error = "problem in reading code_value table"
  GO TO error_check
 ENDIF
 SELECT INTO "nl:"
  con.*
  FROM concept con
  WHERE (con.concept_identifier=request->concept[k].concept_identifier)
  WITH nocounter, forupdate(con)
 ;end select
 IF (curqual=0)
  SET failed = lock_error
  SET dhtable_name = "CONCEPT"
  SET serrmsg_error = "problem in reading concept table"
  GO TO error_check
 ENDIF
 UPDATE  FROM concept con
  SET con.concept_identifier = request->concept[k].concept_identifier, con.concept_source_cd =
   IF ((request->concept[k].concept_source_cd > 0)) request->concept[k].concept_source_cd
   ELSE cdvalue->concept_source_cd
   ENDIF
   , con.concept_name = request->concept[k].concept_name,
   con.review_status_cd =
   IF ((request->concept[k].review_status_cd > 0)) request->concept[k].review_status_cd
   ELSE cdvalue->review_status_cd
   ENDIF
   , con.updt_cnt = (con.updt_cnt+ 1), con.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   con.updt_id = reqinfo->updt_id, con.updt_task = reqinfo->updt_task, con.updt_applctx = reqinfo->
   updt_applctx,
   con.active_ind = true, con.active_status_cd =
   IF ((request->concept[k].active_status_cd > 0)) request->concept[k].active_status_cd
   ELSE cdvalue->active_status_cd
   ENDIF
   , con.active_status_dt_tm =
   IF (cnvtdatetime(request->concept[k].active_status_dt_tm) > 0) cnvtdatetime(request->concept[k].
     active_status_dt_tm)
   ELSE cnvtdatetime(curdate,curtime3)
   ENDIF
   ,
   con.active_status_prsnl_id = reqinfo->updt_id, con.beg_effective_dt_tm =
   IF (cnvtdatetime(request->concept[k].beg_effective_dt_tm) > 0) cnvtdatetime(request->concept[k].
     beg_effective_dt_tm)
   ELSE cnvtdatetime(curdate,curtime3)
   ENDIF
   , con.data_status_cd =
   IF ((request->concept[k].data_status_cd > 0)) request->concept[k].data_status_cd
   ELSE 0
   ENDIF
   ,
   con.data_status_dt_tm =
   IF (cnvtdatetime(request->concept[k].data_status_dt_tm) > 0) cnvtdatetime(request->concept[k].
     data_status_dt_tm)
   ELSE cnvtdatetime(curdate,curtime3)
   ENDIF
   , con.data_status_prsnl_id = reqinfo->updt_id
  PLAN (con
   WHERE (con.concept_identifier=request->concept[k].concept_identifier))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = update_error
  SET dhtable_name = "CONCEPT"
  SET serrmsg_error = "problem in inserting data into concept table"
  GO TO error_check
 ENDIF
 SET reply->concept[k].concept_identifier = request->concept[k].concept_identifier
 IF ((request->concept[k].concept_source_cd > 0))
  SET reply->concept[k].concept_source_cd = request->concept[k].concept_source_cd
 ELSE
  SET reply->concept[k].concept_source_cd = cdvalue->concept_source_cd
 ENDIF
 SET reply->concept[k].concept_name = request->concept[k].concept_name
#error_check
 IF (failed=false)
  SET reqinfo->commit_ind = true
  EXECUTE cps_ens_commit
  SET reply->status_data.status = "S"
 ELSE
  CASE (failed)
   OF select_error:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.status = "Z"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.status = "Z"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.status = "Z"
    SET reqinfo->commit_ind = false
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.status = "Z"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = dhtable_name
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg_error
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = false
 ENDIF
END GO
