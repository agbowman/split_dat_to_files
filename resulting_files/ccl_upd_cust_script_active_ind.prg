CREATE PROGRAM ccl_upd_cust_script_active_ind
 RECORD upd_request(
   1 application_number = i4
   1 position_cd = f8
   1 prsnl_id = f8
   1 nv[1]
     2 pvc_name = c32
     2 pvc_value = vc
     2 sequence = i4
     2 merge_id = f8
     2 merge_name = vc
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD upd_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE num = i4
 UPDATE  FROM ccl_cust_script_objects ccso
  SET ccso.active_ind = request->custom_objects[num].active_ind
  WHERE expand(num,1,size(request->custom_objects,5),ccso.ccl_cust_script_objects_id,request->
   custom_objects[num].ccl_cust_script_objects_id)
  WITH expand = 1
 ;end update
 IF ((request->script_cache_ind != ""))
  DECLARE errmsg = c255
  SET errmsg = fillstring(255," ")
  SET reply->status_data.status = "F"
  SET upd_request->position_cd = 0
  SET upd_request->prsnl_id = 0
  SET upd_request->nv[1].sequence = 0
  SET upd_request->nv[1].merge_id = 0
  SET upd_request->nv[1].merge_name = ""
  SET upd_request->application_number = 3010000
  SET upd_request->nv[1].pvc_name = "DISCERN_CUSTOM_CACHE"
  SET upd_request->nv[1].pvc_value = request->script_cache_ind
  EXECUTE dcp_add_app_prefs  WITH replace("REQUEST","UPD_REQUEST"), replace("REPLY","UPD_REPLY")
  IF ((upd_reply->status_data.status="S"))
   COMMIT
  ELSE
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    GO TO exit_script
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 COMMIT
END GO
