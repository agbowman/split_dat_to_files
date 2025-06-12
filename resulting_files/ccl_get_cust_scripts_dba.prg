CREATE PROGRAM ccl_get_cust_scripts:dba
 DECLARE err_msg = vc WITH noconstant("")
 DECLARE error_code = i4 WITH noconstant(0)
 RECORD reply(
   1 qual[*]
     2 object_name = c30
     2 group = i2
   1 enabled_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE cnt = i4 WITH noconstant(0), private
 SELECT
  nvp.parent_entity_name, nvp.parent_entity_id, nvp.pvc_name,
  nvp.updt_dt_tm"@SHORTDATETIME", nvp.active_ind, nvp.pvc_value
  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="DISCERN_CUSTOM_CACHE"
  DETAIL
   IF (substring(1,1,nvp.pvc_value)="1")
    reply->enabled_ind = 1
   ELSE
    reply->enabled_ind = 0
   ENDIF
  WITH nullreport
 ;end select
 IF (curqual=0)
  SET reply->enabled_ind = 1
 ENDIF
 IF ((reply->enabled_ind=1))
  SELECT INTO "nl:"
   cso.object_name, cso.group_number
   FROM ccl_cust_script_objects cso
   WHERE cso.active_ind > 0
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10000)=1)
     stat = alterlist(reply->qual,(cnt+ 9999))
    ENDIF
    reply->qual[cnt].object_name = cso.object_name, reply->qual[cnt].group = cso.group_number
   FOOT REPORT
    stat = alterlist(reply->qual,cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET error_code = error(err_msg,0)
 IF (error_code != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "ccl_get_cust_scripts"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Error Message"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
 ELSEIF ((reply->enabled_ind=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
