CREATE PROGRAM cps_get_person_by_id:dba
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
   1 person_qual = i4
   1 person[*]
     2 person_id = f8
     2 updt_cnt = i4
     2 name_last = c200
     2 name_first = c200
     2 name_full_formatted = c100
     2 name_middle = c200
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 name_degree = c100
     2 name_suffix = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET nbr_id_rows = size(request->qual,5)
 SET name_type_cd_value = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=213
   AND c.cdf_meaning="CURRENT"
  DETAIL
   name_type_cd_value = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person p,
   person_name n,
   (dummyt d  WITH seq = value(nbr_id_rows))
  PLAN (d)
   JOIN (p
   WHERE (request->qual[d.seq].person_id=p.person_id))
   JOIN (n
   WHERE p.person_id=n.person_id
    AND n.name_type_cd=name_type_cd_value)
  DETAIL
   count1 += 1
   IF (mod(count1,100)=1)
    stat = alterlist(reply->person,(count1+ 100))
   ENDIF
   reply->person[count1].person_id = p.person_id, reply->person[count1].updt_cnt = p.updt_cnt, reply
   ->person[count1].name_last = p.name_last,
   reply->person[count1].name_first = p.name_first, reply->person[count1].name_middle = p.name_middle,
   reply->person[count1].name_full_formatted = p.name_full_formatted,
   reply->person[count1].beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm), reply->person[
   count1].end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm), reply->person[count1].
   name_degree = n.name_degree,
   reply->person[count1].name_suffix = n.name_suffix
  WITH nocounter, outerjoin = n
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->person,count1)
 SET reply->person_qual = count1
END GO
