CREATE PROGRAM dcp_upd_plan_cat_active:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  *
  FROM pathway_catalog pwc
  WHERE (pwc.pathway_catalog_id=request->pathway_catalog_id)
   AND (pwc.updt_cnt=request->updt_cnt)
  WITH nocounter, forupdate(pc)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 UPDATE  FROM pathway_catalog pc
  SET pc.active_ind = request->active_ind, pc.updt_cnt = (pc.updt_cnt+ 1), pc.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->
   updt_applctx
  WHERE (pc.pathway_catalog_id=request->pathway_catalog_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
