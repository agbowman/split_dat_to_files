CREATE PROGRAM dms_upd_queue:dba
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
 SET reply->status_data.status = "F"
 FREE SET failed
 DECLARE failed = vc WITH noconstant("F")
 FREE SET device_id
 DECLARE device_id = f8 WITH noconstant(0.0)
 FREE SET dms_service_id
 DECLARE dms_service_id = f8 WITH noconstant(0.0)
 SELECT INTO "nl:"
  ds.dms_service_id
  FROM dms_service ds
  WHERE (ds.service_name=request->service_name)
  DETAIL
   dms_service_id = ds.dms_service_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.*
  FROM device d
  WHERE (d.device_cd=request->device_cd)
  WITH nocounter, forupdate(d)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 UPDATE  FROM device d
  SET d.dms_service_id = dms_service_id, d.distribution_flag = request->distribution_flag, d
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1),
   d.updt_applctx = reqinfo->updt_applctx
  WHERE (d.device_cd=request->device_cd)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSEIF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
