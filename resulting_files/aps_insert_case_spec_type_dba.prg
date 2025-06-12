CREATE PROGRAM aps_insert_case_spec_type:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET case_type_cd = 0.0
 SET code_set = 1301
 SET cdf_meaning = request->case_type_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET case_type_cd = code_value
 IF (case_type_cd > 0)
  INSERT  FROM case_specimen_type_r c
   SET c.case_type_cd = case_type_cd, c.specimen_meaning = request->specimen_meaning, c.updt_dt_tm =
    cnvtdatetime(curdate,curtime),
    c.updt_id = reqinfo->updt_id, c.updt_cnt = 0, c.updt_task = reqinfo->updt_task,
    c.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
END GO
