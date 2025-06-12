CREATE PROGRAM dm_dm_cleanup:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ddc_err_msg = c132
 DECLARE ddc_error(de_emsg=vc,de_target=vc,de_operation=vc) = null
 SET ddc_err_ind = 0
 SET ddc_err_ind = error(ddc_err_msg,1)
 UPDATE  FROM dm_adm_code_value_alias cva
  SET cva.updt_task = 15301
  WHERE (cva.code_set=request->code_set)
   AND cva.schema_date=cnvtdatetime(request->schema_dt)
  WITH nocounter
 ;end update
 CALL ddc_error("ERROR: Cannot update DM_ADM_CODE_VALUE_ALIAS","DM_ADM_CODE_VALUE_ALIAS","UPDATE")
 IF (curqual > 0)
  DELETE  FROM dm_adm_code_value_alias cva
   WHERE (cva.code_set=request->code_set)
    AND cva.schema_date=cnvtdatetime(request->schema_dt)
   WITH nocounter
  ;end delete
  CALL ddc_error("ERROR: Cannot delete from DM_ADM_CODE_VALUE_ALIAS","DM_ADM_CODE_VALUE_ALIAS",
   "DELETE")
 ENDIF
 UPDATE  FROM dm_adm_code_value_group cvg
  SET cvg.updt_task = 15301
  WHERE (cvg.code_set=request->code_set)
   AND cvg.schema_date=cnvtdatetime(request->schema_dt)
  WITH nocounter
 ;end update
 CALL ddc_error("ERROR: Cannot update DM_ADM_CODE_VALUE_GROUP","DM_ADM_CODE_VALUE_GROUP","UPDATE")
 IF (curqual > 0)
  DELETE  FROM dm_adm_code_value_group cvg
   WHERE (cvg.code_set=request->code_set)
    AND cvg.schema_date=cnvtdatetime(request->schema_dt)
   WITH nocounter
  ;end delete
  CALL ddc_error("ERROR: Cannot delete from DM_ADM_CODE_VALUE_GROUP","DM_ADM_CODE_VALUE_GROUP",
   "DELETE")
 ENDIF
 UPDATE  FROM dm_adm_code_value_extension cve
  SET cve.updt_task = 15301
  WHERE (cve.code_set=request->code_set)
   AND cve.schema_date=cnvtdatetime(request->schema_dt)
  WITH nocounter
 ;end update
 CALL ddc_error("ERROR: Cannot update DM_ADM_CODE_VALUE_EXTENSION","DM_ADM_CODE_VALUE_EXT","UPDATE")
 IF (curqual > 0)
  DELETE  FROM dm_adm_code_value_extension cve
   WHERE (cve.code_set=request->code_set)
    AND cve.schema_date=cnvtdatetime(request->schema_dt)
   WITH nocounter
  ;end delete
  CALL ddc_error("ERROR: Cannot delete from DM_ADM_CODE_VALUE_EXTENSION","DM_ADM_CODE_VALUE_EXT",
   "DELETE")
 ENDIF
 UPDATE  FROM dm_adm_code_value cv
  SET cv.updt_task = 15301
  WHERE (cv.code_set=request->code_set)
   AND cv.schema_date=cnvtdatetime(request->schema_dt)
  WITH nocounter
 ;end update
 CALL ddc_error("ERROR: Cannot update DM_ADM_CODE_VALUE","DM_ADM_CODE_VALUE","UPDATE")
 IF (curqual > 0)
  DELETE  FROM dm_adm_code_value cv
   WHERE (cv.code_set=request->code_set)
    AND cv.schema_date=cnvtdatetime(request->schema_dt)
   WITH nocounter
  ;end delete
  CALL ddc_error("ERROR: Cannot delete from DM_ADM_CODE_VALUE","DM_ADM_CODE_VALUE","DELETE")
 ENDIF
 UPDATE  FROM dm_adm_common_data_foundation cdf
  SET cdf.updt_task = 15301
  WHERE (cdf.code_set=request->code_set)
   AND cdf.schema_date=cnvtdatetime(request->schema_dt)
  WITH nocounter
 ;end update
 CALL ddc_error("ERROR: Cannot update DM_ADM_COMMON_DATA_FOUNDATION","DM_ADM_COMMON_DATA_FOU",
  "UPDATE")
 IF (curqual > 0)
  DELETE  FROM dm_adm_common_data_foundation cdf
   WHERE (cdf.code_set=request->code_set)
    AND cdf.schema_date=cnvtdatetime(request->schema_dt)
   WITH nocounter
  ;end delete
  CALL ddc_error("ERROR: Cannot delete from DM_ADM_COMMON_DATA_FOUNDATION","DM_ADM_COMMON_DATA_FOU",
   "DELETE")
 ENDIF
 UPDATE  FROM dm_adm_code_set_extension cse
  SET cse.updt_task = 15301
  WHERE (cse.code_set=request->code_set)
   AND cse.schema_date=cnvtdatetime(request->schema_dt)
  WITH nocounter
 ;end update
 CALL ddc_error("ERROR: Cannot update DM_ADM_CODE_SET_EXTENSION","DM_ADM_CODE_SET_EXTENSION","UPDATE"
  )
 IF (curqual > 0)
  DELETE  FROM dm_adm_code_set_extension cse
   WHERE (cse.code_set=request->code_set)
    AND cse.schema_date=cnvtdatetime(request->schema_dt)
   WITH nocounter
  ;end delete
  CALL ddc_error("ERROR: Cannot delete from DM_ADM_CODE_SET_EXTENSION","DM_ADM_CODE_SET_EXTENSION",
   "DELETE")
 ENDIF
 UPDATE  FROM dm_adm_code_value_set cvs
  SET cvs.updt_task = 15301
  WHERE (cvs.code_set=request->code_set)
   AND cvs.schema_date=cnvtdatetime(request->schema_dt)
  WITH nocounter
 ;end update
 CALL ddc_error("ERROR: Cannot update DM_ADM_CODE_VALUE_SET","DM_ADM_CODE_VALUE_SET","UPDATE")
 IF (curqual > 0)
  DELETE  FROM dm_adm_code_value_set cvs
   WHERE (cvs.code_set=request->code_set)
    AND cvs.schema_date=cnvtdatetime(request->schema_dt)
   WITH nocounter
  ;end delete
  CALL ddc_error("ERROR: Cannot delete from DM_ADM_CODE_VALUE_SET","DM_ADM_CODE_VALUE_SET","DELETE")
 ENDIF
 COMMIT
 SET reply->status_data.status = "S"
 GO TO exit_program
 SUBROUTINE ddc_error(de_emsg,de_target,de_operation)
  SET ddc_err_ind = error(ddc_err_msg,0)
  IF (ddc_err_ind > 0)
   ROLLBACK
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(de_emsg,":",ddc_err_msg)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = de_operation
   SET reply->status_data.subeventstatus[1].targetobjectname = de_target
   GO TO exit_program
  ENDIF
 END ;Subroutine
#exit_program
END GO
