CREATE PROGRAM di_get_dev_params:dba
 RECORD reply(
   1 devlist[*]
     2 device_cd = f8
     2 device_disp = c40
     2 device_desc = c60
     2 device_mean = c12
     2 paramlist[*]
       3 device_parameter_id = f8
       3 result_type_cd = f8
       3 result_type_disp = c40
       3 result_type_desc = c60
       3 result_type_mean = c12
       3 parameter_cd = f8
       3 parameter_disp = c40
       3 parameter_desc = c60
       3 parameter_mean = c12
       3 parameter_alias = c60
       3 units_cd = f8
       3 units_disp = c40
       3 units_desc = c60
       3 units_mean = c12
       3 event_cd = f8
       3 event_disp = c40
       3 event_desc = c60
       3 event_mean = c12
       3 task_assay_cd = f8
       3 task_assay_disp = c40
       3 task_assay_desc = c60
       3 task_assay_mean = c12
       3 decimal_precision = i4
       3 alarm_high = c20
       3 alarm_low = c20
       3 active_ind = i2
       3 sequence_nbr = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET sfailed = "S"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM bmdi_device_parameter ddp,
   strt_bmdi_model_parameter sbmp
  PLAN (ddp
   WHERE ddp.active_ind=1)
   JOIN (sbmp
   WHERE sbmp.strt_model_parameter_id=ddp.strt_model_parameter_id)
  ORDER BY ddp.device_cd, ddp.sequence_nbr
  HEAD REPORT
   devcnt = 0
  HEAD ddp.device_cd
   devcnt += 1
   IF (mod(devcnt,10)=1)
    stat = alterlist(reply->devlist,(devcnt+ 9))
   ENDIF
   reply->devlist[devcnt].device_cd = ddp.device_cd, reply->devlist[devcnt].device_disp =
   uar_get_code_display(ddp.device_cd), reply->devlist[devcnt].device_desc = uar_get_code_description
   (ddp.device_cd),
   reply->devlist[devcnt].device_mean = uar_get_code_meaning(ddp.device_cd), cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->devlist[devcnt].paramlist,(cnt+ 9))
   ENDIF
   reply->devlist[devcnt].paramlist[cnt].device_parameter_id = ddp.device_parameter_id, reply->
   devlist[devcnt].paramlist[cnt].parameter_cd = sbmp.parameter_cd, reply->devlist[devcnt].paramlist[
   cnt].parameter_disp = uar_get_code_display(sbmp.parameter_cd),
   reply->devlist[devcnt].paramlist[cnt].parameter_desc = uar_get_code_description(sbmp.parameter_cd),
   reply->devlist[devcnt].paramlist[cnt].parameter_mean = uar_get_code_meaning(sbmp.parameter_cd),
   reply->devlist[devcnt].paramlist[cnt].parameter_alias = ddp.parameter_alias,
   reply->devlist[devcnt].paramlist[cnt].result_type_cd = ddp.result_type_cd, reply->devlist[devcnt].
   paramlist[cnt].result_type_disp = uar_get_code_display(ddp.result_type_cd), reply->devlist[devcnt]
   .paramlist[cnt].result_type_desc = uar_get_code_description(ddp.result_type_cd),
   reply->devlist[devcnt].paramlist[cnt].result_type_mean = uar_get_code_meaning(ddp.result_type_cd),
   reply->devlist[devcnt].paramlist[cnt].event_cd = ddp.event_cd, reply->devlist[devcnt].paramlist[
   cnt].event_disp = uar_get_code_display(ddp.event_cd),
   reply->devlist[devcnt].paramlist[cnt].event_desc = uar_get_code_description(ddp.event_cd), reply->
   devlist[devcnt].paramlist[cnt].event_mean = uar_get_code_meaning(ddp.event_cd), reply->devlist[
   devcnt].paramlist[cnt].task_assay_cd = ddp.task_assay_cd,
   reply->devlist[devcnt].paramlist[cnt].task_assay_disp = uar_get_code_display(ddp.task_assay_cd),
   reply->devlist[devcnt].paramlist[cnt].task_assay_desc = uar_get_code_description(ddp.task_assay_cd
    ), reply->devlist[devcnt].paramlist[cnt].task_assay_mean = uar_get_code_meaning(ddp.task_assay_cd
    ),
   reply->devlist[devcnt].paramlist[cnt].units_cd = ddp.units_cd, reply->devlist[devcnt].paramlist[
   cnt].units_disp = uar_get_code_display(ddp.units_cd), reply->devlist[devcnt].paramlist[cnt].
   units_desc = uar_get_code_description(ddp.units_cd),
   reply->devlist[devcnt].paramlist[cnt].units_mean = uar_get_code_meaning(ddp.units_cd), reply->
   devlist[devcnt].paramlist[cnt].parameter_alias = ddp.parameter_alias, reply->devlist[devcnt].
   paramlist[cnt].decimal_precision = ddp.decimal_precision,
   reply->devlist[devcnt].paramlist[cnt].alarm_high = ddp.alarm_high, reply->devlist[devcnt].
   paramlist[cnt].alarm_low = ddp.alarm_low, reply->devlist[devcnt].paramlist[cnt].active_ind = ddp
   .active_ind,
   reply->devlist[devcnt].paramlist[cnt].sequence_nbr = ddp.sequence_nbr
  FOOT  ddp.device_cd
   stat = alterlist(reply->devlist[devcnt].paramlist,cnt), cnt = 0
  FOOT REPORT
   stat = alterlist(reply->devlist,devcnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  SET sfailed = "T"
  IF (ierrcode > 0)
   SET stat = alter(reply->status_data.subeventstatus,2)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data Retrieval failed!"
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "No data matching request"
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "di_get_dev_params"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "SELECT"
   SET reply->status_data.subeventstatus[2].operationstatus = "F"
   SET reply->status_data.subeventstatus[2].targetobjectname = "di_get_dev_params"
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
 GO TO exit_script
#no_valid_ids
 IF (sfailed="I")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "di_get_dev_params"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid identifier in request"
  GO TO exit_script
 ENDIF
#exit_script
 IF (sfailed="T")
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSEIF (sfailed="I")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
