CREATE PROGRAM afc_readme_bill_org_payor:dba
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
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 RECORD tiergroups(
   1 qual[*]
     2 code_value = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET table_exists = "F"
 SELECT INTO "NL:"
  FROM user_tab_columns utc
  WHERE utc.table_name="BILL_ORG_PAYOR"
  DETAIL
   table_exists = "T"
  WITH nocounter
 ;end select
 IF (table_exists="F")
  SET readme_data->status = "S"
  SET readme_data->message = "New table, readme not needed to remove duplicates."
  GO TO exit_script
 ENDIF
 DECLARE rdm_errmsg = c132 WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE count = i4
 DECLARE workload_cd = f8
 DECLARE bill_perf_cd = f8
 CALL upt_tier_groups(count)
 CALL upt_standards(count)
 CALL upt_organization(count)
 IF (failed != false)
  CALL echo("failed upt_columns")
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
  SET readme_data->status = "S"
 ELSE
  SET readme_data->status = "F"
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
 GO TO end_program
 SUBROUTINE upt_tier_groups(dummyvar)
   SET count = 0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=13031
     AND ((cv.cdf_meaning="TIERGROUP") OR (cv.cdf_meaning="CLTTIERGROUP"))
     AND cv.active_ind=1
    DETAIL
     count += 1, stat = alterlist(tiergroups->qual,count), tiergroups->qual[count].code_value = cv
     .code_value
    WITH nocounter
   ;end select
   UPDATE  FROM bill_org_payor bop,
     (dummyt d  WITH seq = value(size(tiergroups->qual,5)))
    SET bop.parent_entity_name = "CODE_VALUE"
    PLAN (d)
     JOIN (bop
     WHERE (bop.bill_org_type_cd=tiergroups->qual[d.seq].code_value))
    WITH nocounter
   ;end update
   SET errcode = error(rdm_errmsg,0)
   IF (errcode != 0)
    SET failed = update_error
   ENDIF
 END ;Subroutine
 SUBROUTINE upt_standards(dummyvar)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=13031
     AND cv.cdf_meaning="STANDARD"
     AND cv.active_ind=1
    DETAIL
     workload_cd = cv.code_value
    WITH nocounter
   ;end select
   UPDATE  FROM bill_org_payor bop
    SET bop.parent_entity_name = "WORKLOAD_STANDARD"
    WHERE bop.bill_org_type_cd=workload_cd
    WITH nocounter
   ;end update
   SET errcode = error(rdm_errmsg,0)
   IF (errcode != 0)
    SET failed = update_error
   ENDIF
 END ;Subroutine
 SUBROUTINE upt_organization(dummyvar)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=13031
     AND cv.cdf_meaning="BILLPERFORG"
     AND cv.active_ind=1
    DETAIL
     bill_perf_cd = cv.code_value
    WITH nocounter
   ;end select
   UPDATE  FROM bill_org_payor bop
    SET bop.parent_entity_name = "ORGANIZATION"
    WHERE bop.bill_org_type_cd=bill_perf_cd
    WITH nocounter
   ;end update
   SET errcode = error(rdm_errmsg,0)
   IF (errcode != 0)
    SET failed = update_error
   ENDIF
 END ;Subroutine
 SUBROUTINE upt_all_other(dummyvar)
   DECLARE client_bill_cd = f8
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=13031
     AND cv.cdf_meaning="CLIENTBILL"
    DETAIL
     client_bill_cd = cv.code_value
    WITH nocounter
   ;end select
   UPDATE  FROM bill_org_payor bop
    SET bop.parent_entity_name = ""
    WHERE bop.bill_org_type_cd=client_bill_cd
    WITH nocounter
   ;end update
   SET errcode = error(rdm_errmsg,0)
   IF (errcode != 0)
    SET failed = update_error
   ENDIF
 END ;Subroutine
#end_program
 CALL echo("end of program")
 CALL echorecord(reply)
 IF ((reply->status_data.status="S"))
  CALL echo("status is successfull")
  SET readme_data->status = "S"
  SET readme_data->message = "PARENT_ENTITY_NAME updated successfully"
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = reply->status_data.subeventstatus[1].operationname
 ENDIF
 COMMIT
#exit_script
 EXECUTE dm_readme_status
 FREE SET tiergroups
END GO
