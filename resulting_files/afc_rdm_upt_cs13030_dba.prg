CREATE PROGRAM afc_rdm_upt_cs13030:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
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
 DECLARE rdm_errmsg = c132 WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE dnodebit = f8 WITH public, noconstant(0.0)
 SET afc_rdm_upt_cs13030_vrsn = 0
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting afc_rdm_upt_cs13030.prg script"
 CALL echo("calling upt_columns")
 CALL upt_columns(1)
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
 SUBROUTINE upt_columns(dummyvar)
   CALL echo("in upt_column")
   DECLARE upt_code_value = f8
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=13030
     AND cv.cdf_meaning="NODEBIT"
     AND cv.active_ind=1
    DETAIL
     dnodebit = cv.code_value
    WITH nocounter
   ;end select
   CALL echo(build("dNODEBIT: ",dnodebit))
   SET errcode = error(rdm_errmsg,0)
   IF (errcode != 0)
    SET failed = update_error
   ENDIF
   UPDATE  FROM code_value_extension cve
    SET cve.field_value = "1", cve.updt_task = reqinfo->updt_task, cve.updt_dt_tm = cnvtdatetime(
      sysdate),
     cve.updt_id = reqinfo->updt_id, cve.updt_applctx = reqinfo->updt_applctx, cve.updt_cnt = (cve
     .updt_cnt+ 1)
    WHERE cve.code_set=13030
     AND cve.code_value=dnodebit
     AND cve.field_name="SKIP_CHARGING_SERVER"
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
  SET readme_data->status = "S"
  SET readme_data->message = "Code_value_extension for NODEBIT Updated."
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = reply->status_data.subeventstatus[1].operationname
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
