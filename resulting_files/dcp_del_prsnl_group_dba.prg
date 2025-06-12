CREATE PROGRAM dcp_del_prsnl_group:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD group_reltn(
   1 qual[*]
     2 prsnl_group_reltn_id = f8
 )
 SET x = 0
 SET reltn_cnt = 0
 SET stat = 0
 FOR (x = 1 TO size(request->qual,5))
   SELECT INTO "NL:"
    tmpr.prsnl_group_reltn_id
    FROM prsnl_group_reltn pgr,
     team_mem_ppr_reltn tmpr
    PLAN (pgr
     WHERE (pgr.prsnl_group_id=request->qual[x].prsnl_group_id))
     JOIN (tmpr
     WHERE tmpr.prsnl_group_reltn_id=pgr.prsnl_group_reltn_id)
    HEAD tmpr.prsnl_group_reltn_id
     reltn_cnt = (reltn_cnt+ 1), stat = alterlist(group_reltn->qual,(reltn_cnt+ 10)), group_reltn->
     qual[reltn_cnt].prsnl_group_reltn_id = tmpr.prsnl_group_reltn_id
    FOOT REPORT
     stat = alterlist(group_reltn->qual,reltn_cnt)
    WITH nocounter
   ;end select
 ENDFOR
 FOR (x = 1 TO reltn_cnt)
  CALL echo(build("deleting from team_mem_ppr, prsnl_group_reltn_id=",group_reltn->qual[x].
    prsnl_group_reltn_id))
  DELETE  FROM team_mem_ppr_reltn tmpr
   WHERE (tmpr.prsnl_group_reltn_id=group_reltn->qual[x].prsnl_group_reltn_id)
   WITH nocounter
  ;end delete
 ENDFOR
#delete_reltn
 FOR (x = 1 TO size(request->qual,5))
   DELETE  FROM dcp_pl_custom_entry d
    WHERE (d.prsnl_group_id=request->qual[x].prsnl_group_id)
    WITH nocounter
   ;end delete
   CALL echo(build("deleting from prsnl_group, prsnl_group_id=",request->qual[x].prsnl_group_id))
   DELETE  FROM prsnl_group p
    WHERE (p.prsnl_group_id=request->qual[x].prsnl_group_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "prsnl_group"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "delete"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to delete from table"
    SET reqinfo->commit_ind = 0
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_del_prsnl_group"
    SET reply->status_data.status = "F"
   ELSE
    SET reqinfo->commit_ind = 1
    SET reply->status_data.status = "S"
   ENDIF
   CALL echo(build("deleting from prsnl_group_reltn, prsnl_group_id=",request->qual[x].prsnl_group_id
     ))
   DELETE  FROM prsnl_group_reltn pgr
    WHERE (pgr.prsnl_group_id=request->qual[x].prsnl_group_id)
    WITH nocounter
   ;end delete
 ENDFOR
END GO
