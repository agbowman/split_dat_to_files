CREATE PROGRAM ccl_get_admin_settings
 RECORD reply(
   1 compile_mode_ind = i2
   1 script_cache_ind = i2
   1 cust_script_objects[*]
     2 ccl_cust_script_objects_id = f8
     2 object_name = vc
     2 group_number = i4
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->script_cache_ind = 1
 SELECT INTO "NL:"
  nvp.pvc_name, nvp.pvc_value
  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="DISCERN_APPS_COMPILEVERSION3"
  DETAIL
   reply->compile_mode_ind = cnvtint(nvp.pvc_value)
  WITH nocounter
 ;end select
 SELECT
  *
  FROM name_value_prefs nvp
  WHERE pvc_name="DISCERN_CUSTOM_CACHE"
  DETAIL
   reply->script_cache_ind = cnvtint(nvp.pvc_value)
  WITH nocounter
 ;end select
 SELECT
  *
  FROM ccl_cust_script_objects ccso
  ORDER BY ccso.object_name
  HEAD REPORT
   stat = alterlist(reply->cust_script_objects,100), count = 0
  DETAIL
   count += 1
   IF (mod(count,100)=1
    AND count > 100)
    stat = alterlist(reply->cust_script_objects,(count+ 99))
   ENDIF
   reply->cust_script_objects[count].ccl_cust_script_objects_id = ccso.ccl_cust_script_objects_id,
   reply->cust_script_objects[count].object_name = ccso.object_name, reply->cust_script_objects[count
   ].group_number = ccso.group_number,
   reply->cust_script_objects[count].active_ind = ccso.active_ind
  FOOT REPORT
   stat = alterlist(reply->cust_script_objects,count)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
