CREATE PROGRAM ct_ens_ruleset_tier:dba
 IF ("Z"=validate(ct_ens_ruleset_tier_vrsn,"Z"))
  DECLARE ct_ens_ruleset_tier_vrsn = vc WITH noconstant("45958.001")
 ENDIF
 SET ct_ens_ruleset_tier_vrsn = "45958.001"
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
   1 ct_ruleset_tier_qual = i2
   1 ct_ruleset_tier[10]
     2 ct_ruleset_tier_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 CALL echo("going through ct_ens_ruleset_tier.prg")
 SET reply->status_data.status = "F"
 SET reply->ct_ruleset_tier_qual = request->ct_ruleset_tier_qual
 SET table_name = "CT_RULESET_TIER"
 IF ((request->ct_ruleset_tier_qual > 0))
  CALL echo("inside if")
  FOR (inx0 = 1 TO request->ct_ruleset_tier_qual)
    CALL echo("inside for")
    CALL echo(inx0)
    CASE (request->ct_ruleset_tier[inx0].action_type)
     OF "ADD":
      SET action_begin = inx0
      SET action_end = inx0
      EXECUTE ct_add_ruleset_tier
      IF (failed != false)
       GO TO check_error
      ENDIF
     OF "UPT":
      SET action_begin = inx0
      SET action_end = inx0
      CALL echo("going through UPT")
      EXECUTE ct_upt_ruleset_tier
      IF (failed != false)
       GO TO check_error
      ENDIF
     OF "DEL":
      SET action_begin = inx0
      SET action_end = inx0
      EXECUTE ct_del_ruleset_tier
      IF (failed != false)
       GO TO check_error
      ENDIF
     ELSE
      SET failed = true
      GO TO check_error
    ENDCASE
  ENDFOR
 ENDIF
 SET stat = alter(reply->ct_ruleset_tier,reply->ct_ruleset_tier_qual)
#check_error
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
#end_program
END GO
