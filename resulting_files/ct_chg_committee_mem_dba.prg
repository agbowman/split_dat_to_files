CREATE PROGRAM ct_chg_committee_mem:dba
 RECORD reply(
   1 comt_name = vc
   1 qual[*]
     2 role = vc
     2 name = vc
     2 orgname = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET counter = 0
 SET loop = 0
 UPDATE  FROM committee_member cm
  SET cm.role_cd = request->role, cm.organization_id = request->org_id, cm.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   cm.updt_id = reqinfo->updt_id, cm.updt_task = reqinfo->updt_task, cm.updt_applctx = reqinfo->
   updt_applctx,
   cm.updt_cnt = (cm.updt_cnt+ 1)
  WHERE (cm.committee_member_id=request->cmt_mem_id)
 ;end update
 IF (curqual=0)
  SET failed = "T"
  CALL echo("failed to update row(s)")
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
END GO
