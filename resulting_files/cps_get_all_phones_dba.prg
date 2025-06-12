CREATE PROGRAM cps_get_all_phones:dba
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
   1 phone_qual = i4
   1 phone[*]
     2 phone_id = f8
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 phone_type_cd = f8
     2 phone_type_seq = i4
     2 phone_num = c100
     2 description = c100
     2 extension = c100
     2 operation_hours = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
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
 SET nbr_parent_id_rows = size(request->qual,5)
 IF (trim(request->parent_entity_name)="")
  SELECT INTO "nl:"
   FROM phone p
   PLAN (p
    WHERE p.active_ind=1
     AND p.parent_entity_id > 0
     AND p.parent_entity_id < 2000000000
     AND p.phone_id > 0
     AND p.parent_entity_name IN ("PERSON", "ORGANIZATION", "PLAN_CONTACT", "PLANCONTACT")
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    count += 1
    IF (mod(count,100)=1)
     stat = alterlist(reply->phone,(count+ 100))
    ENDIF
    reply->phone[count].phone_id = p.phone_id, reply->phone[count].parent_entity_name = p
    .parent_entity_name, reply->phone[count].parent_entity_id = p.parent_entity_id,
    reply->phone[count].phone_type_cd = p.phone_type_cd, reply->phone[count].phone_type_seq = p
    .phone_type_seq, reply->phone[count].phone_num = p.phone_num,
    reply->phone[count].description = p.description, reply->phone[count].extension = p.extension,
    reply->phone[count].operation_hours = p.operation_hours,
    reply->phone[count].beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm), reply->phone[count
    ].end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM phone p,
    (dummyt d  WITH seq = value(nbr_parent_id_rows))
   PLAN (d)
    JOIN (p
    WHERE (request->qual[d.seq].parent_entity_id=p.parent_entity_id)
     AND (p.parent_entity_name=request->parent_entity_name)
     AND p.parent_entity_id > 0
     AND p.parent_entity_id < 2000000000
     AND p.active_ind=1
     AND p.phone_id > 0
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    count += 1
    IF (mod(count,100)=1)
     stat = alterlist(reply->phone,(count+ 100))
    ENDIF
    reply->phone[count].phone_id = p.phone_id, reply->phone[count].parent_entity_name = p
    .parent_entity_name, reply->phone[count].parent_entity_id = p.parent_entity_id,
    reply->phone[count].phone_type_cd = p.phone_type_cd, reply->phone[count].phone_type_seq = p
    .phone_type_seq, reply->phone[count].phone_num = p.phone_num,
    reply->phone[count].description = p.description, reply->phone[count].extension = p.extension,
    reply->phone[count].operation_hours = p.operation_hours,
    reply->phone[count].beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm), reply->phone[count
    ].end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm)
   WITH nocounter
  ;end select
 ENDIF
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->phone,count)
 SET reply->phone_qual = count
END GO
