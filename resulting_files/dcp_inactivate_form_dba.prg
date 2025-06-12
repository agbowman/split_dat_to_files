CREATE PROGRAM dcp_inactivate_form:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 DECLARE instance_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  WHERE (dfr.dcp_forms_ref_id=request->dcp_forms_ref_id)
   AND (dfr.updt_cnt=request->updt_cnt)
   AND dfr.active_ind=1
  DETAIL
   instance_id = dfr.dcp_form_instance_id
  WITH maxqual(dsr,1), nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dcp_forms_ref dfr
  SET dfr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), dfr.active_ind = 0, dfr.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   dfr.updt_id = reqinfo->updt_id, dfr.updt_task = reqinfo->updt_task, dfr.updt_applctx = reqinfo->
   updt_applctx,
   dfr.updt_cnt = (request->updt_cnt+ 1)
  WHERE dfr.dcp_form_instance_id=instance_id
  WITH nocounter
 ;end update
 UPDATE  FROM dcp_forms_def dfd
  SET dfd.active_ind = 0, dfd.updt_dt_tm = cnvtdatetime(curdate,curtime3), dfd.updt_id = reqinfo->
   updt_id,
   dfd.updt_task = reqinfo->updt_task, dfd.updt_applctx = reqinfo->updt_applctx, dfd.updt_cnt = (
   request->updt_cnt+ 1)
  WHERE dfd.dcp_form_instance_id=instance_id
  WITH nocounter
 ;end update
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
