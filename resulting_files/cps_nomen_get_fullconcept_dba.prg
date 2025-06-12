CREATE PROGRAM cps_nomen_get_fullconcept:dba
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
   1 string_count = i2
   1 nomen_string[0]
     2 nomenclature_id = f8
     2 nom_ver_grp_id = f8
     2 source_string = vc
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c20
     2 source_vocabulary_mean = c20
     2 source_identifier = vc
     2 principle_type_cd = f8
     2 principle_type_disp = c20
     2 principle_type_mean = c20
     2 vocab_axis_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET failed = false
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET str_count = 0
 SET table_name = "NOMENCLATURE"
 SELECT INTO "NL:"
  n.nomenclature_id, n.nom_ver_grp_id, n.source_string,
  n.source_vocabulary_cd, n.source_identifier, n.principle_type_cd
  FROM nomenclature n
  PLAN (n
   WHERE (n.concept_identifier=request->concept_identifier)
    AND (n.concept_source_cd=request->concept_source_cd)
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   str_count = (str_count+ 1)
   IF (mod(str_count,10)=1)
    stat = alter(reply->nomen_string,(str_count+ 10))
   ENDIF
   reply->nomen_string[str_count].nomenclature_id = n.nomenclature_id, reply->nomen_string[str_count]
   .nom_ver_grp_id = n.nom_ver_grp_id, reply->nomen_string[str_count].source_string = n.source_string,
   reply->nomen_string[str_count].source_vocabulary_cd = n.source_vocabulary_cd, reply->nomen_string[
   str_count].source_identifier = n.source_identifier, reply->nomen_string[str_count].
   principle_type_cd = n.principle_type_cd,
   reply->nomen_string[str_count].vocab_axis_cd = n.vocab_axis_cd,
   CALL echo(build("nomenclature_id = ",reply->nomen_string[str_count].nomenclature_id))
  WITH nocounter
 ;end select
 CALL echo(build(" curqual = ",curqual))
 IF (curqual > 0)
  SET stat = alter(reply->nomen_string,str_count)
  SET reply->string_count = str_count
  SET reply->status_data.status = "S"
 ELSE
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reply->string_count = 0
  ELSE
   SET reply->status_data.status = "F"
   SET failed = select_error
   GO TO error_check
  ENDIF
 ENDIF
#error_check
 IF (failed != false)
  SET reqinfo->commit_ind = 1
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
