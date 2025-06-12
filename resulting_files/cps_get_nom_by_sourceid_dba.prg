CREATE PROGRAM cps_get_nom_by_sourceid:dba
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
   1 nomenclature_string_cnt = i2
   1 nomenclature[2]
     2 nomenclature_id = f8
     2 principle_type_cd = f8
     2 source_string = vc
     2 source_identifier = vc
     2 string_identifier = c18
     2 string_status_cd = f8
     2 term_id = f8
     2 language_cd = f8
     2 source_vocabulary_cd = f8
     2 nom_ver_grp_id = f8
     2 short_string = vc
     2 mnemonic = c15
     2 concept_identifier = c18
     2 concept_source_cd = f8
     2 string_source_cd = f8
     2 vocab_axis_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET table_name = "NOMENCLATURE"
 SET nom_count = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->principle_type_cd > 0))INTO "NL:"
   n.nomenclature_id
   FROM nomenclature n
   PLAN (n
    WHERE (n.source_vocabulary_cd=request->source_vocabulary_cd)
     AND (n.source_identifier=request->source_identifier)
     AND (n.principle_type_cd=request->principle_type_cd)
     AND n.active_ind=1
     AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ELSE INTO "NL:"
   n.nomenclature_id
   FROM nomenclature n
   PLAN (n
    WHERE (n.source_vocabulary_cd=request->source_vocabulary_cd)
     AND (n.source_identifier=request->source_identifier)
     AND n.active_ind=1
     AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ENDIF
  DETAIL
   nom_count = (nom_count+ 1)
   IF (mod(nom_count,2)=1)
    stat = alter(reply->nomenclature,(nom_count+ 2))
   ENDIF
   reply->nomenclature[nom_count].nomenclature_id = n.nomenclature_id, reply->nomenclature[nom_count]
   .principle_type_cd = n.principle_type_cd, reply->nomenclature[nom_count].source_string = n
   .source_string,
   reply->nomenclature[nom_count].source_identifier = n.source_identifier, reply->nomenclature[
   nom_count].string_identifier = n.string_identifier, reply->nomenclature[nom_count].
   string_status_cd = n.string_status_cd,
   reply->nomenclature[nom_count].term_id = n.term_id, reply->nomenclature[nom_count].language_cd = n
   .language_cd, reply->nomenclature[nom_count].source_vocabulary_cd = n.source_vocabulary_cd,
   reply->nomenclature[nom_count].nom_ver_grp_id = n.nom_ver_grp_id, reply->nomenclature[nom_count].
   short_string = n.short_string, reply->nomenclature[nom_count].mnemonic = n.mnemonic,
   reply->nomenclature[nom_count].concept_identifier = n.concept_identifier, reply->nomenclature[
   nom_count].concept_source_cd = n.concept_source_cd, reply->nomenclature[nom_count].
   string_source_cd = n.string_source_cd,
   reply->nomenclature[nom_count].vocab_axis_cd = n.vocab_axis_cd
  WITH nocounter
 ;end select
 SET reply->nomenclature_string_cnt = nom_count
 IF (curqual > 0)
  SET stat = alter(reply->nomenclature,nom_count)
 ELSE
  SET failed = none_found
  GO TO error_check
 ENDIF
 GO TO error_check
#error_check
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF select_error:
    SET reply->status_data.subeventstatus[1].operationname = "GET"
   OF none_found:
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET stat = alter(reply->status_data.subeventstatus,2)
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
 ENDIF
 GO TO end_program
#end_program
END GO
