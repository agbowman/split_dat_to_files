CREATE PROGRAM cps_upt_conceptdefinition:dba
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
 SET debug = 0
 IF (debug > 0)
  RECORD reply(
    1 conceptdefcnt = i2
    1 conceptdef[*]
      2 conceptdef_action_ind = i2
      2 concept_identifier = c18
      2 concept_source_cd = f8
      2 source_vocabulary_cd = f8
      2 concept_definition_id = f8
      2 definition = vc
      2 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = c100
  )
  SET reply->conceptdefcnt = request->conceptdefcnt
  SET stat = alterlist(reply->conceptdef,(reply->conceptdefcnt+ 1))
  SET dhtable_name = fillstring(100," ")
  SET serrmsg_error = fillstring(100," ")
 ENDIF
 RECORD cdvalue(
   1 active_status_cd = f8
 )
 SET failed = false
 SET definition = fillstring(1000," ")
 SET concept_identifier = fillstring(132," ")
 SET reqinfo->commit_ind = false
 SELECT INTO "nl:"
  FROM code_value c1
  WHERE c1.code_set=48
   AND c1.cdf_meaning="ACTIVE"
  DETAIL
   cdvalue->active_status_cd = c1.code_value
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
  FROM concept_definition con
  WHERE (con.concept_identifier=request->conceptdef[k].concept_identifier)
   AND (con.concept_definition_id=request->conceptdef[k].concept_definition_id)
  WITH nocounter, forupdate(con)
 ;end select
 IF (curqual=0)
  SET failed = lock_error
  SET dhtable_name = "CONCEPT_DEFINITION"
  SET serrmsg_error = "problem in locking concept_definition table"
  GO TO error_check
 ENDIF
 SET definition = request->conceptdef[k].definition
 SET concept_identifier = request->conceptdef[k].concept_identifier
 SET concept_source_cd = request->conceptdef[k].concept_source_cd
 SET source_vocabulary_cd = request->conceptdef[k].source_vocabulary_cd
 SET concept_definition_id = request->conceptdef[k].concept_definition_id
 UPDATE  FROM concept_definition con
  SET con.concept_identifier = trim(concept_identifier,3), con.concept_source_cd = concept_source_cd,
   con.concept_definition_id = concept_definition_id,
   con.definition = trim(definition,3), con.source_vocabulary_cd = source_vocabulary_cd, con.updt_cnt
    = (con.updt_cnt+ 1),
   con.updt_dt_tm = cnvtdatetime(curdate,curtime3), con.updt_id = reqinfo->updt_id, con.updt_task =
   reqinfo->updt_task,
   con.updt_applctx = reqinfo->updt_applctx, con.active_ind = true, con.active_status_cd = cdvalue->
   active_status_cd,
   con.active_status_dt_tm = cnvtdatetime(curdate,curtime3), con.active_status_prsnl_id = reqinfo->
   updt_id, con.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (con
   WHERE (con.concept_identifier=request->conceptdef[k].concept_identifier)
    AND (con.concept_definition_id=request->conceptdef[k].concept_definition_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = update_error
  SET dhtable_name = "CONCEPT_DEFINITION"
  SET serrmsg_error = "problem in updating data into concept_definition table"
  GO TO error_check
 ENDIF
 SET reply->conceptdef[k].concept_identifier = trim(concept_identifier,3)
 SET reply->conceptdef[k].concept_source_cd = concept_source_cd
 SET reply->conceptdef[k].definition = trim(definition,3)
 SET reply->conceptdef[k].conceptdef_action_ind = request->conceptdef[k].conceptdef_action_ind
 SET reply->conceptdef[k].source_vocabulary_cd = source_vocabulary_cd
 SET reply->conceptdef[k].concept_definition_id = concept_definition_id
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
