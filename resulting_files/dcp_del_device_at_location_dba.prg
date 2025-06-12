CREATE PROGRAM dcp_del_device_at_location:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE devicecnt = i2 WITH noconstant(0)
 DECLARE dcp_device_location_id = f8
 SELECT INTO "nl:"
  d.dcp_device_location_id
  FROM dcp_device_location d
  WHERE (d.location_cd=request->location_cd)
  ORDER BY d.dcp_device_location_id
  DETAIL
   devicecnt = (devicecnt+ 1), dcp_device_location_id = d.dcp_device_location_id
  WITH nocounter
 ;end select
 IF (devicecnt=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_device_location"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Validate"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Device relationship not present."
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (devicecnt > 0)
  UPDATE  FROM dcp_device_location d
   SET d.active_ind = 0, d.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1),
    d.updt_applctx = reqinfo->updt_applctx
   WHERE d.dcp_device_location_id=dcp_device_location_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_device_location"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to update into table"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
