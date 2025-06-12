CREATE PROGRAM cps_get_nomen_axis:dba
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
   1 vocab_qual = i2
   1 vocab[*]
     2 source_vocabulary_cd = f8
     2 group_qual = i2
     2 group[*]
       3 child_code_value = f8
       3 child_cd = f8
       3 child_disp = vc
       3 child_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE kia_version = vc
 SET kia_version = "04-02-2002"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET table_name = "CODE_VALUE_GROUP"
 SET failed = false
 SET vocab_knt = 0
 SET grp_knt = 0
 SET nbr_to_get = size(request->vocab,5)
 SELECT INTO "nl:"
  cvg.parent_code_value, cvg.child_code_value
  FROM code_value_group cvg,
   (dummyt d  WITH seq = value(nbr_to_get))
  PLAN (d)
   JOIN (cvg
   WHERE (cvg.parent_code_value=request->vocab[d.seq].source_vocabulary_cd)
    AND (cvg.code_set=request->vocab[d.seq].code_set))
  ORDER BY cvg.parent_code_value, cvg.child_code_value
  HEAD REPORT
   vocab_knt = 0, stat = alterlist(reply->vocab,10)
  HEAD cvg.parent_code_value
   vocab_knt = (vocab_knt+ 1)
   IF (mod(vocab_knt,10)=1
    AND vocab_knt != 1)
    stat = alterlist(reply->vocab,(vocab_knt+ 9))
   ENDIF
   grp_knt = 0, stat = alterlist(reply->vocab[vocab_knt].group,10), reply->vocab[vocab_knt].
   source_vocabulary_cd = cvg.parent_code_value
  DETAIL
   grp_knt = (grp_knt+ 1)
   IF (mod(grp_knt,10)=1
    AND grp_knt != 1)
    stat = alterlist(reply->vocab[vocab_knt].group,(grp_knt+ 9))
   ENDIF
   reply->vocab[vocab_knt].group[grp_knt].child_code_value = cvg.child_code_value, reply->vocab[
   vocab_knt].group[grp_knt].child_cd = cvg.child_code_value
  FOOT  cvg.parent_code_value
   stat = alterlist(reply->vocab[vocab_knt].group,grp_knt), reply->vocab[vocab_knt].group_qual =
   grp_knt
  FOOT REPORT
   stat = alterlist(reply->vocab,vocab_knt), reply->vocab_qual = vocab_knt
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET failed = select_error
  SET reply->status_data.status = "Z"
 ENDIF
#error_check
 IF (failed=false)
  SET reply->status_data.status = "S"
 ELSE
  CASE (failed)
   OF select_error:
    SET reply->status_data.subeventstatus[1].operationname = "GET"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ENDIF
END GO
