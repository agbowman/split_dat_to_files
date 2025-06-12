CREATE PROGRAM dd_refresh_pref_to_app_prefs:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure: dd_refresh_pref_to_app_prefs"
 DECLARE the_pvc_name = vc WITH protect, constant("DYNDOC_REFRESH_DOC_COMP")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE num_failed = i4 WITH protect, noconstant(0)
 DECLARE num_succeeded = i4 WITH protect, noconstant(0)
 DECLARE getexistingappprefprsnl(app_number=i4,app_pref_data=vc(ref)) = null
 SUBROUTINE getexistingappprefprsnl(app_number,app_pref_data)
   DECLARE prsnl_cnt = i4
   SET prsnl_cnt = 0
   SELECT INTO "nl:"
    FROM name_value_prefs nvp,
     app_prefs ap
    PLAN (nvp
     WHERE nvp.active_ind=1
      AND nvp.parent_entity_name="APP_PREFS"
      AND nvp.pvc_name=the_pvc_name)
     JOIN (ap
     WHERE nvp.parent_entity_id=ap.app_prefs_id
      AND ap.application_number=app_number
      AND ap.prsnl_id != 0.0)
    ORDER BY ap.prsnl_id
    HEAD nvp.name_value_prefs_id
     prsnl_cnt = (prsnl_cnt+ 1), stat = alterlist(app_pref_data->prsnl_ids,prsnl_cnt), app_pref_data
     ->prsnl_ids[prsnl_cnt].id = ap.prsnl_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to query app prefs: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 DECLARE getcurrentdetailprefs(app_number=i4,prsnl_id_blacklist=vc(ref),detail_pref_data=vc(ref)) =
 null
 SUBROUTINE getcurrentdetailprefs(app_number,prsnl_id_blacklist,detail_pref_data)
   DECLARE prsnl_cnt = i4
   DECLARE pref_list_cnt = i4
   DECLARE idx = i4
   SET prsnl_cnt = size(prsnl_id_blacklist->prsnl_ids,5)
   SET pref_list_cnt = 0
   SELECT INTO "nl:"
    FROM name_value_prefs nvp,
     detail_prefs dp
    PLAN (nvp)
     JOIN (dp
     WHERE nvp.active_ind=1
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name=the_pvc_name
      AND nvp.parent_entity_id=dp.detail_prefs_id
      AND dp.application_number=app_number)
    ORDER BY nvp.name_value_prefs_id
    HEAD nvp.name_value_prefs_id
     pos = locatevalsort(idx,1,prsnl_cnt,dp.prsnl_id,prsnl_id_blacklist->prsnl_ids[idx].id)
     IF (pos <= 0)
      pref_list_cnt = (pref_list_cnt+ 1), stat = alterlist(detail_pref_data->pref_list,pref_list_cnt),
      detail_pref_data->pref_list[pref_list_cnt].application_number = dp.application_number,
      detail_pref_data->pref_list[pref_list_cnt].position_cd = dp.position_cd, detail_pref_data->
      pref_list[pref_list_cnt].prsnl_id = dp.prsnl_id, stat = alterlist(detail_pref_data->pref_list[
       pref_list_cnt].nv,1),
      detail_pref_data->pref_list[pref_list_cnt].nv[1].pvc_name = the_pvc_name, detail_pref_data->
      pref_list[pref_list_cnt].nv[1].pvc_value = nvp.pvc_value, detail_pref_data->pref_list[
      pref_list_cnt].nv[1].nvp_id = nvp.name_value_prefs_id
     ENDIF
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to query detail prefs: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 DECLARE calladdappprefs(app_number=i4,pref_data=vc(ref)) = null
 SUBROUTINE calladdappprefs(app_number,pref_data)
   FREE RECORD dcp_add_app_prefs_req
   RECORD dcp_add_app_prefs_req(
     1 application_number = i4
     1 position_cd = f8
     1 prsnl_id = f8
     1 nv[*]
       2 pvc_name = c32
       2 pvc_value = vc
       2 sequence = i2
       2 merge_id = f8
       2 merge_name = vc
   )
   FREE RECORD dcp_add_app_prefs_reply
   RECORD dcp_add_app_prefs_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   DECLARE pref_count = i4
   SET pref_count = size(pref_data->pref_list,5)
   FOR (i = 1 TO pref_count)
     SET dcp_add_app_prefs_req->application_number = app_number
     SET dcp_add_app_prefs_req->position_cd = pref_data->pref_list[i].position_cd
     SET dcp_add_app_prefs_req->prsnl_id = pref_data->pref_list[i].prsnl_id
     SET stat = alterlist(dcp_add_app_prefs_req->nv,1)
     SET dcp_add_app_prefs_req->nv[1].pvc_name = the_pvc_name
     SET dcp_add_app_prefs_req->nv[1].pvc_value = pref_data->pref_list[i].nv[1].pvc_value
     EXECUTE dcp_add_app_prefs  WITH replace("REQUEST",dcp_add_app_prefs_req), replace("REPLY",
      dcp_add_app_prefs_reply)
     IF (error(errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed executing dcp_add_app_prefs: ",errmsg)
      GO TO exit_script
     ENDIF
     IF ((dcp_add_app_prefs_reply->status_data.status="F"))
      SET num_failed = (num_failed+ 1)
      SET pref_data->pref_list[i].nv[1].status = - (1)
     ELSE
      SET num_succeeded = (num_succeeded+ 1)
      SET pref_data->pref_list[i].nv[1].status = 1
     ENDIF
   ENDFOR
   FREE RECORD dcp_add_app_prefs_req
   FREE RECORD dcp_add_app_prefs_reply
 END ;Subroutine
 DECLARE deleteconvertedprefs(pref_data=vc(ref)) = null
 SUBROUTINE deleteconvertedprefs(pref_data)
   FREE RECORD dcp_del_name_value_req
   RECORD dcp_del_name_value_req(
     1 nv_cnt = i4
     1 nv[*]
       2 name_value_prefs_id = f8
   )
   DECLARE pref_count = i4
   SET pref_count = size(pref_data->pref_list,5)
   FOR (i = 1 TO pref_count)
     IF ((pref_data->pref_list[i].nv[1].status=1))
      SET dcp_del_name_value_req->nv_cnt = (dcp_del_name_value_req->nv_cnt+ 1)
      SET stat = alterlist(dcp_del_name_value_req->nv,dcp_del_name_value_req->nv_cnt)
      SET dcp_del_name_value_req->nv[dcp_del_name_value_req->nv_cnt].name_value_prefs_id = pref_data
      ->pref_list[i].nv[1].nvp_id
     ENDIF
   ENDFOR
   IF (pref_count != 0)
    EXECUTE dcp_del_name_value  WITH replace("REQUEST",dcp_del_name_value_req)
   ENDIF
   FREE RECORD dcp_del_name_value_req
 END ;Subroutine
 SUBROUTINE convertprefs(app_number)
   FREE RECORD app_pref_data
   RECORD app_pref_data(
     1 prsnl_ids[*]
       2 id = f8
   )
   CALL getexistingappprefprsnl(app_number,app_pref_data)
   FREE RECORD detail_pref_data
   RECORD detail_pref_data(
     1 pref_list[*]
       2 application_number = i4
       2 position_cd = f8
       2 prsnl_id = f8
       2 nv[*]
         3 pvc_name = c32
         3 pvc_value = vc
         3 sequence = i2
         3 merge_id = f8
         3 merge_name = vc
         3 nvp_id = f8
         3 status = i2
   )
   CALL getcurrentdetailprefs(app_number,app_pref_data,detail_pref_data)
   CALL calladdappprefs(app_number,detail_pref_data)
   CALL deleteconvertedprefs(detail_pref_data)
   FREE RECORD app_pref_data
   FREE RECORD detail_pref_data
 END ;Subroutine
 SUBROUTINE main(null)
   DECLARE num_succeeded_str = vc
   DECLARE num_failed_str = vc
   CALL convertprefs(600005)
   CALL convertprefs(820000)
   CALL convertprefs(4250111)
   CALL convertprefs(610000)
   COMMIT
   SET readme_data->status = "S"
   IF (num_failed=0)
    SET readme_data->message = "Success: Readme performed all required tasks"
   ELSE
    SET num_succeeded_str = cnvtstring(num_succeeded)
    SET num_failed_str = cnvtstring(num_failed)
    SET readme_data->message = concat(num_succeeded_str," succeeded; ",num_failed_str," failed")
   ENDIF
 END ;Subroutine
 CALL main(null)
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
