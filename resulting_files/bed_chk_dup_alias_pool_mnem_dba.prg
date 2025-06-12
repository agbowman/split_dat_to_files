CREATE PROGRAM bed_chk_dup_alias_pool_mnem:dba
 FREE SET reply
 RECORD reply(
   1 alias_pool_code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE apcode = f8
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET reply->status_data.status = "F"
 SET apcode = 0.0
 SELECT INTO "nl:"
  FROM code_value_extension cve,
   alias_pool ap
  PLAN (cve
   WHERE cve.code_set=263
    AND cve.field_name="MNEMONIC"
    AND cnvtupper(trim(cve.field_value))=cnvtupper(trim(request->mnemonic)))
   JOIN (ap
   WHERE ap.alias_pool_cd=cve.code_value
    AND ap.active_ind=1)
  DETAIL
   apcode = cve.code_value
  WITH nocounter
 ;end select
 SET reply->alias_pool_code_value = apcode
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_CHK_DUP_ALIAS_POOL_MNEM  >> ERROR MESSAGE: ",
   error_msg)
 ELSEIF (apcode=0.0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
