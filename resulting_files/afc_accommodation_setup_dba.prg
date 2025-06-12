CREATE PROGRAM afc_accommodation_setup:dba
 RECORD request(
   1 nbr_of_recs = i4
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 ext_owner_cd = f8
     2 ext_description = c100
     2 workload_only_ind = i2
     2 ext_short_desc = c50
     2 careset_ind = i2
     2 price_qual = i2
     2 prices[*]
       3 price_sched_id = f8
       3 price = f8
     2 billcode_qual = i2
     2 billcodes[*]
       3 billcode_sched_cd = f8
       3 billcode = c25
     2 child_qual = i2
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
       3 ext_description = c100
       3 ext_short_desc = c50
       3 ext_owner_cd = f8
 )
 RECORD reply(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
   1 qual[*]
     2 bill_item_id = f8
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 price_sched_id = f8
     2 price_sched_items_id = f8
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[10]
     2 bill_item_mod_id = f8
   1 actioncnt = i2
   1 actionlist[*]
     2 action1 = vc
     2 action2 = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c20
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
 DECLARE g_accom_cd = f8
 DECLARE g_owner_cd = f8
 SET serrmsg = fillstring(132," ")
 SET reply->status_data.status = "F"
 SET accom_codeset = 10
 SET g_accom_cd = 0.0
 SET g_owner_cd = 0.0
#main
 SET failed = false
 IF (failed=false)
  CALL get_contrib_codes(0)
 ENDIF
 IF (failed=false)
  CALL get_owner_code(0)
 ENDIF
 IF (failed=false)
  CALL get_accommodations(0)
 ENDIF
 IF (failed=false)
  EXECUTE afc_add_reference_api
 ENDIF
 CALL check_error(0)
#main_exit
 GO TO end_program
 SUBROUTINE get_contrib_codes(l_dummy)
   CALL echo("inside GET_CONTRIB_CODES")
   SET stat = uar_get_meaning_by_codeset(13016,"ACCOM",1,g_accom_cd)
   IF (stat=0)
    CALL echo(build("the contrib code value is: ",g_accom_cd))
   ELSE
    CALL echo("Failure retrieving contrib code value.")
    SET failed = true
   ENDIF
 END ;Subroutine
 SUBROUTINE get_owner_code(l_dummy)
   CALL echo("inside GET_OWNER_CODE")
   SET stat = uar_get_meaning_by_codeset(106,"PM",1,g_owner_cd)
   IF (stat=0)
    CALL echo(build("the owner code value is: ",g_owner_cd))
   ELSE
    CALL echo("Failure retrieving owner code value.")
    SET failed = true
   ENDIF
 END ;Subroutine
 SUBROUTINE get_accommodations(l_dummy)
   CALL echo("inside GET_ACCOMMODATIONS")
   SET count = 0
   SET i = 0
   SELECT INTO "nl:"
    cv.code_value, cv.display
    FROM code_value cv
    WHERE cv.code_set=accom_codeset
     AND cv.active_ind=1
    HEAD REPORT
     stat = alterlist(request->qual,10)
    DETAIL
     count += 1
     IF (mod(count,10)=1
      AND count != 1)
      stat = alterlist(request->qual,(count+ 10))
     ENDIF
     request->qual[count].action = 1, request->qual[count].ext_id = cv.code_value, request->qual[
     count].ext_contributor_cd = g_accom_cd,
     request->qual[count].parent_qual_ind = 1, request->qual[count].ext_owner_cd = g_owner_cd,
     request->qual[count].ext_description = concat("ROOM/BED: ",cv.display),
     request->qual[count].ext_short_desc = cv.display, request->qual[count].ext_short_desc = cv
     .display, request->qual[count].child_qual = 0,
     request->qual[count].price_qual = 0, request->qual[count].billcode_qual = 0
    WITH nocounter
   ;end select
   SET stat = alterlist(request->qual,count)
   SET request->nbr_of_recs = count
   IF (curqual=0)
    SET failed = select_error
    SET reply->status_data.subeventstatus[1].operationname = "Select"
    SET reply->status_data.subeventstatus[1].operationstatus = "s"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE4"
    SET reply->status_data.status = "Z"
   ENDIF
 END ;Subroutine
 SUBROUTINE dump_request(l_dummy)
   CALL echo("inside DUMP_REQUEST")
   SET i = 0
   SET j = 0
   FOR (i = 1 TO cnvtint(request->nbr_of_recs))
     CALL echo(build("Parent==>"," ext_id: ",request->qual[i].ext_id," ext_contributor_cd: ",request
       ->qual[i].ext_contributor_cd,
       " ext_description:",request->qual[i].ext_description," ext_short_desc:",request->qual[i].
       ext_short_desc," ext_owner_cd: ",
       request->qual[i].ext_owner_cd))
   ENDFOR
 END ;Subroutine
 SUBROUTINE check_error(l_dummy)
   IF (failed=false)
    SET reply->status_data.status = "S"
    SET reqinfo->commit_ind = true
   ELSE
    CASE (failed)
     OF gen_nbr_error:
      SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
     OF insert_error:
      SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     OF update_error:
      SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     OF replace_error:
      SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
     OF delete_error:
      SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     OF undelete_error:
      SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
     OF remove_error:
      SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
     OF attribute_error:
      SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
     OF lock_error:
      SET reply->status_data.subeventstatus[1].operationname = "LOCK"
     ELSE
      SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    ENDCASE
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
    SET reqinfo->commit_ind = false
   ENDIF
 END ;Subroutine
#end_program
END GO
