CREATE PROGRAM ct_chg_committee_info:dba
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
 UPDATE  FROM committee cmt
  SET cmt.sponsoring_org_id = request->spons_org_id, cmt.committee_type_cd = request->cmt_type, cmt
   .committee_name = request->cmt_name,
   cmt.email_address = request->email, cmt.updt_dt_tm = cnvtdatetime(curdate,curtime3), cmt.updt_id
    = reqinfo->updt_id,
   cmt.updt_task = reqinfo->updt_task, cmt.updt_applctx = reqinfo->updt_applctx, cmt.updt_cnt = (cmt
   .updt_cnt+ 1)
  WHERE (cmt.committee_id=request->cmt_id)
 ;end update
 IF (curqual=0)
  SET failed = "T"
  CALL echo("failed to update row in committee table")
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
END GO
