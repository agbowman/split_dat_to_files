CREATE PROGRAM bed_ens_org_work:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET org_cnt = size(request->org_list,5)
 FOR (x = 1 TO org_cnt)
  SET error_flag = "N"
  IF ((request->org_list[x].action_flag=2))
   UPDATE  FROM br_org_work b
    SET b.status_ind = request->org_list[x].status_ind, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     b.updt_id = (reqinfo->updt_id+ 1),
     b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
    WHERE (b.organization_id=request->org_list[x].org_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to update ",cnvtstring(request->org_list[x].org_id),
     " on the br_org_work table.")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_ORG_WORK","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
