CREATE PROGRAM dcp_inactivate_section:dba
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
 DECLARE instance_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM dcp_section_ref dsr
  WHERE (dsr.dcp_section_ref_id=request->dcp_section_ref_id)
   AND (dsr.updt_cnt=request->updt_cnt)
   AND dsr.active_ind=1
  DETAIL
   instance_id = dsr.dcp_section_instance_id
  WITH maxqual(dsr,1), nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dcp_section_ref dsr
  SET dsr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), dsr.active_ind = 0, dsr.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   dsr.updt_id = reqinfo->updt_id, dsr.updt_task = reqinfo->updt_task, dsr.updt_applctx = reqinfo->
   updt_applctx,
   dsr.updt_cnt = (request->updt_cnt+ 1)
  WHERE dsr.dcp_section_instance_id=instance_id
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
END GO
