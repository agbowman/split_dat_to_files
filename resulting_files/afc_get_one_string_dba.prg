CREATE PROGRAM afc_get_one_string:dba
 RECORD reply(
   1 nomenclature_qual = f8
   1 nomenclature[*]
     2 source_identifier = vc
     2 source_string = vc
     2 source_vocabulary_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
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
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SET count1 = 0
 SET 400meaning = fillstring(10," ")
 SET codeset400 = 400
 SET code_value_returned = 0.0
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=codeset400
   AND (cv.cdf_meaning=request->meaning)
  DETAIL
   code_value_returned = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  n.source_identifier, n.source_string, n.source_vocabulary_cd
  FROM nomenclature n
  WHERE (n.source_identifier=request->source_identifier)
   AND n.source_vocabulary_cd=code_value_returned
  ORDER BY n.source_identifier
  HEAD REPORT
   stat = alterlist(reply->nomenclature,10)
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->nomenclature,(count1+ 10))
   ENDIF
   reply->nomenclature[count1].source_identifier = n.source_identifier, reply->nomenclature[count1].
   source_string = n.source_string, reply->nomenclature[count1].source_vocabulary_cd = n
   .source_vocabulary_cd
  WITH orahint("Index (Nomenclature Nomenclature_1)"), nocounter, maxqual(n,1)
 ;end select
 SET stat = alterlist(reply->nomenclature,count1)
 SET reply->nomenclature_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOMENCLATURE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
