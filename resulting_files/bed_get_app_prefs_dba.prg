CREATE PROGRAM bed_get_app_prefs:dba
 DECLARE app_prefs_list_expand_size = i4
 DECLARE appprefscount = i4
 DECLARE error_flag = vc
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 app_prefs[*]
      2 app_prefs_id = f8
      2 name_value_prefs_id = f8
      2 pvc_name = vc
      2 pvc_value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  GO TO fail_exit
 ENDIF
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET app_prefs_list_expand_size = 10
 SELECT INTO "nl:"
  FROM app_prefs ap,
   name_value_prefs nvp
  PLAN (ap
   WHERE (ap.application_number=request->application_number)
    AND (ap.position_cd=request->position_code_value)
    AND ap.active_ind=1
    AND ap.prsnl_id=0)
   JOIN (nvp
   WHERE nvp.parent_entity_name="APP_PREFS"
    AND nvp.parent_entity_id=ap.app_prefs_id
    AND nvp.active_ind=1)
  HEAD REPORT
   stat = alterlist(reply->app_prefs,app_prefs_list_expand_size), appprefscount = 0
  DETAIL
   appprefscount = (appprefscount+ 1)
   IF (mod(appprefscount,10)=0)
    stat = alterlist(reply->app_prefs,(appprefscount+ app_prefs_list_expand_size))
   ENDIF
   reply->app_prefs[appprefscount].app_prefs_id = ap.app_prefs_id, reply->app_prefs[appprefscount].
   name_value_prefs_id = nvp.name_value_prefs_id, reply->app_prefs[appprefscount].pvc_name = nvp
   .pvc_name,
   reply->app_prefs[appprefscount].pvc_value = nvp.pvc_value
  FOOT REPORT
   stat = alterlist(reply->app_prefs,appprefscount)
  WITH format, separator = " "
 ;end select
#success_exit
 CALL echorecord(reply)
 SET reply->status_data.status = "S"
 GO TO exit_program
#fail_exit
 SET reply->status_data.status = "F"
 SET reply->error_msg = error_msg
#exit_program
END GO
