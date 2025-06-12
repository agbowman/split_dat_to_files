CREATE PROGRAM dcp_del_team_mem_ppr_r:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET totalqual = 0
 SET reply->status_data.status = "F"
 FOR (x = 1 TO size(request->qual,5))
  DELETE  FROM team_mem_ppr_reltn tmpr
   WHERE (tmpr.prsnl_group_reltn_id=request->qual[x].prsnl_group_reltn_id)
    AND (tmpr.ppr_cd=request->qual[x].ppr_cd)
   WITH nocounter
  ;end delete
  SET totalqual = (totalqual+ curqual)
 ENDFOR
 IF (totalqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "team_mem_ppr_reltn"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "delete"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to delete from table"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_del_team_mem_ppr_r"
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
