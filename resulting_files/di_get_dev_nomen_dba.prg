CREATE PROGRAM di_get_dev_nomen:dba
 RECORD reply(
   1 devlist[*]
     2 device_cd = f8
     2 device_disp = c40
     2 device_desc = c60
     2 device_mean = c12
     2 nomenlist[*]
       3 parameter_cd = f8
       3 parameter_disp = c40
       3 parameter_desc = c60
       3 parameter_mean = c12
       3 nomenvaluelist[*]
         4 device_value = c50
         4 alpha_translation = c50
         4 nomenclature_id = f8
         4 active_ind = i2
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
  FROM bmdi_device_nomenclature ddn,
   bmdi_device_parameter bdp,
   strt_bmdi_model_parameter sbmp
  PLAN (ddn
   WHERE ddn.active_ind=1)
   JOIN (bdp
   WHERE bdp.device_parameter_id=ddn.device_parameter_id)
   JOIN (sbmp
   WHERE sbmp.strt_model_parameter_id=bdp.strt_model_parameter_id)
  ORDER BY ddn.device_cd, sbmp.parameter_cd, ddn.nomenclature_id
  HEAD REPORT
   devcnt = 0
  HEAD ddn.device_cd
   devcnt = (devcnt+ 1)
   IF (mod(devcnt,10)=1)
    stat = alterlist(reply->devlist,(devcnt+ 9))
   ENDIF
   reply->devlist[devcnt].device_cd = ddn.device_cd, reply->devlist[devcnt].device_disp =
   uar_get_code_display(ddn.device_cd), reply->devlist[devcnt].device_desc = uar_get_code_description
   (ddn.device_cd),
   reply->devlist[devcnt].device_mean = uar_get_code_meaning(ddn.device_cd), paramcnt = 0
  HEAD sbmp.parameter_cd
   paramcnt = (paramcnt+ 1)
   IF (mod(paramcnt,10)=1)
    stat = alterlist(reply->devlist[devcnt].nomenlist,(paramcnt+ 9))
   ENDIF
   reply->devlist[devcnt].nomenlist[paramcnt].parameter_cd = sbmp.parameter_cd, reply->devlist[devcnt
   ].nomenlist[paramcnt].parameter_disp = uar_get_code_display(sbmp.parameter_cd), reply->devlist[
   devcnt].nomenlist[paramcnt].parameter_desc = uar_get_code_description(sbmp.parameter_cd),
   reply->devlist[devcnt].nomenlist[paramcnt].parameter_mean = uar_get_code_meaning(sbmp.parameter_cd
    ), cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->devlist[devcnt].nomenlist[paramcnt].nomenvaluelist,(cnt+ 9))
   ENDIF
   reply->devlist[devcnt].nomenlist[paramcnt].nomenvaluelist[cnt].device_value = ddn.device_value,
   reply->devlist[devcnt].nomenlist[paramcnt].nomenvaluelist[cnt].nomenclature_id = ddn
   .nomenclature_id, reply->devlist[devcnt].nomenlist[paramcnt].nomenvaluelist[cnt].alpha_translation
    = ddn.alpha_translation,
   reply->devlist[devcnt].nomenlist[paramcnt].nomenvaluelist[cnt].active_ind = ddn.active_ind
  FOOT  sbmp.parameter_cd
   stat = alterlist(reply->devlist[devcnt].nomenlist[paramcnt].nomenvaluelist,cnt), cnt = 0
  FOOT  ddn.device_cd
   stat = alterlist(reply->devlist[devcnt].nomenlist,paramcnt), paramcnt = 0
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "di_get_dev_nomen"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "SELECT"
   SET reply->status_data.subeventstatus[2].operationstatus = "F"
   SET reply->status_data.subeventstatus[2].targetobjectname = "di_get_dev_nomen"
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "di_get_dev_nomen"
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
