CREATE PROGRAM cdi_del_ac_batchclass:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(value(size(request->batchclass,5))), public
 DECLARE child_cnt = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(1)
 SET reply->status_data.status = "F"
 IF (count > 0)
  UPDATE  FROM cdi_ac_batchclass acb
   SET acb.active_ind = 0, acb.updt_cnt = (acb.updt_cnt+ 1), acb.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    acb.updt_task = reqinfo->updt_task, acb.updt_id = reqinfo->updt_id, acb.updt_applctx = reqinfo->
    updt_applctx
   WHERE expand(num,1,count,acb.cdi_ac_batchclass_id,request->batchclass[num].cdi_ac_batchclass_id)
    AND acb.cdi_ac_batchclass_id > 0
  ;end update
  IF (curqual != count)
   SET ecode = 0
   SET emsg = fillstring(132," ")
   SET ecode = error(emsg,1)
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_AC_BATCHCLASS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
