CREATE PROGRAM bed_ens_legacy_sr:dba
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
 SET count = size(request->glist,5)
 FOR (x = 1 TO count)
   IF ((request->glist[x].action_flag=2))
    UPDATE  FROM br_legacy_sr b
     SET b.active_ind = request->glist[x].active_ind, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
      updt_applctx
     WHERE cnvtupper(b.service_resource)=cnvtupper(request->glist[x].service_resource)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update ",trim(request->glist[x].service_resource),
      " on the br_legacy_sr table.")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->glist[x].action_flag=3))
    UPDATE  FROM br_legacy_sr b
     SET b.active_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->
      updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
      updt_applctx
     WHERE cnvtupper(b.service_resource)=cnvtupper(request->glist[x].service_resource)
     WITH nocounter
    ;end update
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_LEGACY_SR","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
