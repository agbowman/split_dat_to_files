CREATE PROGRAM cps_get_plan_contact:dba
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
   1 plan_contact_qual = i4
   1 plan_contact[*]
     2 plan_contact_id = f8
     2 health_plan_id = f8
     2 carrier_id = f8
     2 parent_contact_id = f8
     2 person_id = f8
     2 person_contact_ind = i2
     2 name_last = vc
     2 name_first = vc
     2 name_middle = vc
     2 title = vc
     2 tier = i4
     2 display_order = i4
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
 SET count = 0
 SELECT INTO "nl:"
  FROM plan_contact p
  WHERE p.active_ind=1
  DETAIL
   count += 1
   IF (mod(count,100)=1)
    stat = alterlist(reply->plan_contact,(count+ 100))
   ENDIF
   reply->plan_contact[count].plan_contact_id = p.plan_contact_id, reply->plan_contact[count].
   health_plan_id = p.health_plan_id, reply->plan_contact[count].carrier_id = p.carrier_id,
   reply->plan_contact[count].parent_contact_id = p.parent_contact_id, reply->plan_contact[count].
   person_id = p.person_id, reply->plan_contact[count].person_contact_ind = p.person_contact_ind,
   reply->plan_contact[count].name_last = p.name_last, reply->plan_contact[count].name_first = p
   .name_first, reply->plan_contact[count].name_middle = p.name_middle,
   reply->plan_contact[count].title = p.title, reply->plan_contact[count].display_order = p
   .display_order, reply->plan_contact[count].beg_effective_dt_tm = p.beg_effective_dt_tm,
   reply->plan_contact[count].end_effective_dt_tm = p.end_effective_dt_tm
  WITH nocounter
 ;end select
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->plan_contact,count)
 SET reply->plan_contact_qual = count
END GO
