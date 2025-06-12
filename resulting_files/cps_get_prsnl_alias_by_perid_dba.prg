CREATE PROGRAM cps_get_prsnl_alias_by_perid:dba
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
 RECORD reply(
   1 prsnl_alias_qual = i4
   1 prsnl_alias[*]
     2 updt_cnt = i4
     2 prsnl_alias_id = f8
     2 person_id = f8
     2 alias_pool_cd = f8
     2 prsnl_alias_type_cd = f8
     2 alias = c200
     2 prsnl_alias_sub_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET nbr_id_rows = size(request->qual,5)
 SELECT INTO "nl:"
  FROM prsnl_alias s,
   (dummyt d  WITH seq = value(nbr_id_rows))
  PLAN (d)
   JOIN (s
   WHERE (request->qual[d.seq].prsnl_id=s.person_id)
    AND s.active_ind=1)
  DETAIL
   count += 1
   IF (mod(count,100)=1)
    stat = alterlist(reply->prsnl_alias,(count+ 100))
   ENDIF
   reply->prsnl_alias[count].prsnl_alias_id = s.prsnl_alias_id, reply->prsnl_alias[count].updt_cnt =
   s.updt_cnt, reply->prsnl_alias[count].person_id = s.person_id,
   reply->prsnl_alias[count].alias_pool_cd = s.alias_pool_cd, reply->prsnl_alias[count].
   prsnl_alias_type_cd = s.prsnl_alias_type_cd, reply->prsnl_alias[count].alias = s.alias,
   reply->prsnl_alias[count].prsnl_alias_sub_type_cd = s.prsnl_alias_sub_type_cd
  WITH nocounter
 ;end select
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->prsnl_alias,count)
 SET reply->prsnl_alias_qual = count
END GO
