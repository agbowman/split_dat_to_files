CREATE PROGRAM cps_get_nomen:dba
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
   1 nomen_qual = i4
   1 source_string = vc
   1 source_identifier = vc
   1 principle_type_cd = f8
   1 principle_type_disp = c40
   1 principle_type_mean = c12
   1 active_ind = i2
   1 active_status_dt_tm = dq8
   1 active_status_cd = f8
   1 active_status_disp = c40
   1 active_status_mean = c12
   1 contributor_system_cd = f8
   1 contributor_system_disp = c40
   1 contributor_system_mean = c12
   1 vocab_axis_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = false
 SET reply->nomen_qual = 0
 SELECT INTO "nl:"
  n.source_string, n.source_identifier, n.principle_type_cd,
  n.active_ind, n.active_status_dt_tm, n.active_status_cd,
  n.contributor_system_cd
  FROM nomenclature n
  PLAN (n
   WHERE (n.nomenclature_id=request->nomenclature_id))
  DETAIL
   reply->source_string = n.source_string, reply->source_identifier = n.source_identifier, reply->
   principle_type_cd = n.principle_type_cd,
   reply->active_ind = n.active_ind, reply->active_status_dt_tm = n.active_status_dt_tm, reply->
   active_status_cd = n.active_status_cd,
   reply->contributor_system_cd = n.contributor_system_cd, reply->vocab_axis_cd = n.vocab_axis_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->nomen_qual = 0
  SET reply->status_data.status = "Z"
 ELSE
  IF (curqual < 0)
   SET reply->status_data.status = "F"
   SET failed = select_error
  ELSE
   SET reply->nomen_qual = 1
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 CALL echo(build("nomen_qual = ",reply->nomen_qual))
 GO TO error_check
#error_check
 IF (failed=false)
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
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
 ENDIF
 GO TO end_program
#end_program
END GO
