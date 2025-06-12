CREATE PROGRAM cps_nomen_get_conceptdef:dba
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
   1 item_cnt = i2
   1 items[*]
     2 definition = vc
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = vc
     2 source_vocabulary_mean = c12
     2 concept_definition_id = f8
   1 searchmsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET searchmsg = fillstring(100," ")
 SET concept_identifier = fillstring(242," ")
 SET concept_identifier = cnvtupper(trim(request->concept_identifier))
 SELECT INTO "nl:"
  FROM concept_definition c
  WHERE c.concept_identifier=concept_identifier
   AND (c.concept_source_cd=request->concept_source_cd)
   AND c.active_ind=1
   AND c.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->items,(count1+ 10))
   ENDIF
   reply->items[count1].definition = c.definition, reply->items[count1].source_vocabulary_cd = c
   .source_vocabulary_cd, reply->items[count1].concept_definition_id = c.concept_definition_id
  WITH nocounter, maxqual(c,100)
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
  SET reply->searchmsg = "There is no concept definition for this concept!"
 ELSEIF (count1 > 0)
  SET reply->status_data.status = "S"
  SET reply->item_cnt = count1
 ELSE
  SET dhtable_name = "CONCEPT_DEFINITION"
  SET failed = select_error
  GO TO error_check
 ENDIF
 SET stat = alterlist(reply->items,count1)
#error_check
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
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
    SET reqinfo->commit_ind = false
    SET reply->status_data.status = "Z"
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NUM"
    SET reqinfo->commit_ind = false
    SET reply->status_data.status = "Z"
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
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "Z"
 ENDIF
END GO
