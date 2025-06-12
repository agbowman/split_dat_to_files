CREATE PROGRAM cps_ina_assessment:dba
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
 SET number_total = size(request->qual,5)
 SET code_value = 0.0
 SET code_set = 48
 SET cdf_meaning = "INACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET inactive = code_value
 UPDATE  FROM dsm_assessment da,
   (dummyt d  WITH seq = value(number_total))
  SET da.seq = 1, da.active_ind = 0, da.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   da.active_status_cd = inactive, da.updt_dt_tm = cnvtdatetime(curdate,curtime3), da.updt_id =
   reqinfo->updt_id,
   da.updt_task = reqinfo->updt_task, da.updt_applctx = reqinfo->updt_applctx, da.updt_cnt = (da
   .updt_cnt+ 1)
  PLAN (d)
   JOIN (da
   WHERE (da.dsm_assessment_id=request->qual[d.seq].dsm_assessment_id))
  WITH nocounter
 ;end update
 IF (curqual=number_total)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
