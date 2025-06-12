CREATE PROGRAM cps_ens_plan_contact:dba
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
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET table_name = "PLAN_CONTACT"
 SET stat = alterlist(reply->plan_contact,request->plan_contact_qual)
 IF ((request->plan_contact_qual > 0))
  FOR (inx0 = 1 TO request->plan_contact_qual)
    CASE (request->plan_contact[inx0].action_type)
     OF "ADD":
      SET action_begin = inx0
      SET action_end = inx0
      SET ens_plan_contact_id = 0
      SELECT INTO "nl:"
       FROM plan_contact p
       WHERE (p.parent_contact_id=request->plan_contact[inx0].parent_contact_id)
        AND (p.carrier_id=request->plan_contact[inx0].carrier_id)
        AND (p.health_plan_id=request->plan_contact[inx0].health_plan_id)
        AND (p.name_last=request->plan_contact[inx0].name_last)
        AND (p.name_first=request->plan_contact[inx0].name_first)
        AND (p.name_middle=request->plan_contact[inx0].name_middle)
        AND (p.title=request->plan_contact[inx0].title)
       DETAIL
        ens_plan_contact_id = p.plan_contact_id
       WITH nocounter
      ;end select
      IF (curqual=0)
       EXECUTE cps_add_plan_contact
      ELSE
       SET request->plan_contact[inx0].plan_contact_id = ens_plan_contact_id
       EXECUTE cps_upt_plan_contact
      ENDIF
      IF (failed != false)
       GO TO check_error
      ENDIF
     OF "UPT":
      SET action_begin = inx0
      SET action_end = inx0
      EXECUTE cps_upt_plan_contact
      IF (failed != false)
       GO TO check_error
      ENDIF
     OF "DEL":
      SET action_begin = inx0
      SET action_end = inx0
      EXECUTE cps_del_plan_contact
      IF (failed != false)
       GO TO check_error
      ENDIF
     ELSE
      SET failed = true
      GO TO check_error
    ENDCASE
  ENDFOR
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reply->plan_contact_qual = request->plan_contact_qual
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
#end_program
END GO
