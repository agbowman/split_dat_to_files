CREATE PROGRAM bed_ens_prefs_for_rel_res:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET acnt = size(request->applications,5)
 IF (acnt=0)
  GO TO exit_script
 ENDIF
 RECORD temp(
   1 applications[*]
     2 application_id = i4
     2 position_code_value = f8
     2 config_ind = i2
     2 initial_load_value = vc
     2 addtl_load_value = vc
     2 app_prefs_id = f8
     2 detail_prefs_id = f8
     2 config_pref_id = f8
     2 config_pref_value = vc
     2 initial_pref_id = f8
     2 initial_pref_value = vc
     2 addtl_pref_id = f8
     2 addtl_pref_value = vc
 )
 SET stat = alterlist(temp->applications,acnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = acnt)
  PLAN (d)
  DETAIL
   temp->applications[d.seq].application_id = request->applications[d.seq].application_id, temp->
   applications[d.seq].position_code_value = request->applications[d.seq].position_code_value, temp->
   applications[d.seq].config_ind = request->applications[d.seq].config_ind,
   temp->applications[d.seq].initial_load_value = request->applications[d.seq].initial_load_value,
   temp->applications[d.seq].addtl_load_value = request->applications[d.seq].addtl_load_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = acnt),
   app_prefs ap
  PLAN (d)
   JOIN (ap
   WHERE (ap.application_number=temp->applications[d.seq].application_id)
    AND (ap.position_cd=temp->applications[d.seq].position_code_value)
    AND ap.prsnl_id=0
    AND ap.active_ind=1)
  DETAIL
   temp->applications[d.seq].app_prefs_id = ap.app_prefs_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = acnt),
   detail_prefs dp
  PLAN (d)
   JOIN (dp
   WHERE (dp.application_number=request->applications[d.seq].application_id)
    AND (dp.position_cd=request->applications[d.seq].position_code_value)
    AND dp.prsnl_id=0
    AND dp.person_id=0
    AND dp.view_name="DPRESULTVIEW"
    AND dp.comp_name="DETAILPANE"
    AND dp.active_ind=1)
  DETAIL
   temp->applications[d.seq].detail_prefs_id = dp.detail_prefs_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = acnt),
   name_value_prefs nvp
  PLAN (d
   WHERE (temp->applications[d.seq].app_prefs_id > 0))
   JOIN (nvp
   WHERE (nvp.parent_entity_id=temp->applications[d.seq].app_prefs_id)
    AND nvp.parent_entity_name="APP_PREFS"
    AND nvp.pvc_name="RELATED_RESULTS_CONFIG"
    AND nvp.active_ind=1)
  DETAIL
   temp->applications[d.seq].config_pref_id = nvp.name_value_prefs_id, temp->applications[d.seq].
   config_pref_value = nvp.pvc_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = acnt),
   name_value_prefs nvp
  PLAN (d
   WHERE (temp->applications[d.seq].detail_prefs_id > 0))
   JOIN (nvp
   WHERE (nvp.parent_entity_id=temp->applications[d.seq].detail_prefs_id)
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.pvc_name IN ("RELATED_RESULTS_INITIAL_LOAD", "RELATED_RESULTS_ADDITIONAL_LOAD")
    AND nvp.active_ind=1)
  DETAIL
   IF (nvp.pvc_name="RELATED_RESULTS_INITIAL_LOAD")
    temp->applications[d.seq].initial_pref_id = nvp.name_value_prefs_id, temp->applications[d.seq].
    initial_pref_value = nvp.pvc_value
   ENDIF
   IF (nvp.pvc_name="RELATED_RESULTS_ADDITIONAL_LOAD")
    temp->applications[d.seq].addtl_pref_id = nvp.name_value_prefs_id, temp->applications[d.seq].
    addtl_pref_value = nvp.pvc_value
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = 0
 INSERT  FROM app_prefs ap,
   (dummyt d  WITH seq = acnt)
  SET ap.app_prefs_id = seq(carenet_seq,nextval), ap.application_number = request->applications[d.seq
   ].application_id, ap.position_cd = request->applications[d.seq].position_code_value,
   ap.prsnl_id = 0, ap.active_ind = 1, ap.updt_id = reqinfo->updt_id,
   ap.updt_cnt = 0, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->updt_applctx,
   ap.updt_dt_tm = cnvtdatetime(curdate,curtime)
  PLAN (d
   WHERE (temp->applications[d.seq].app_prefs_id=0))
   JOIN (ap)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on app_prefs insert")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = acnt),
   app_prefs ap
  PLAN (d
   WHERE (temp->applications[d.seq].app_prefs_id=0))
   JOIN (ap
   WHERE (ap.application_number=temp->applications[d.seq].application_id)
    AND (ap.position_cd=temp->applications[d.seq].position_code_value)
    AND ap.prsnl_id=0
    AND ap.active_ind=1)
  DETAIL
   temp->applications[d.seq].app_prefs_id = ap.app_prefs_id
  WITH nocounter
 ;end select
 SET ierrcode = 0
 INSERT  FROM detail_prefs dp,
   (dummyt d  WITH seq = acnt)
  SET dp.detail_prefs_id = seq(carenet_seq,nextval), dp.application_number = request->applications[d
   .seq].application_id, dp.position_cd = request->applications[d.seq].position_code_value,
   dp.prsnl_id = 0, dp.person_id = 0, dp.view_name = "DPRESULTVIEW",
   dp.comp_name = "DETAILPANE", dp.view_seq = 1, dp.comp_seq = 1,
   dp.active_ind = 1, dp.updt_id = reqinfo->updt_id, dp.updt_cnt = 0,
   dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->updt_applctx, dp.updt_dt_tm =
   cnvtdatetime(curdate,curtime)
  PLAN (d
   WHERE (temp->applications[d.seq].detail_prefs_id=0))
   JOIN (dp)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on detail_prefs insert")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = acnt),
   detail_prefs dp
  PLAN (d
   WHERE (temp->applications[d.seq].detail_prefs_id=0))
   JOIN (dp
   WHERE (dp.application_number=request->applications[d.seq].application_id)
    AND (dp.position_cd=request->applications[d.seq].position_code_value)
    AND dp.prsnl_id=0
    AND dp.person_id=0
    AND dp.view_name="DPRESULTVIEW"
    AND dp.comp_name="DETAILPANE"
    AND dp.active_ind=1)
  DETAIL
   temp->applications[d.seq].detail_prefs_id = dp.detail_prefs_id
  WITH nocounter
 ;end select
 SET ierrcode = 0
 INSERT  FROM name_value_prefs nvp,
   (dummyt d  WITH seq = acnt)
  SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "APP_PREFS", nvp
   .parent_entity_id = temp->applications[d.seq].app_prefs_id,
   nvp.pvc_name = "RELATED_RESULTS_CONFIG", nvp.pvc_value = cnvtstring(temp->applications[d.seq].
    config_ind), nvp.merge_id = 0,
   nvp.merge_name = "", nvp.sequence = 0, nvp.active_ind = 1,
   nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   nvp.updt_id = reqinfo->updt_id, nvp.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (temp->applications[d.seq].config_pref_id=0))
   JOIN (nvp)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on name_value_prefs insert for config pref")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM name_value_prefs nvp,
   (dummyt d  WITH seq = acnt)
  SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "DETAIL_PREFS",
   nvp.parent_entity_id = temp->applications[d.seq].detail_prefs_id,
   nvp.pvc_name = "RELATED_RESULTS_INITIAL_LOAD", nvp.pvc_value = temp->applications[d.seq].
   initial_load_value, nvp.merge_id = 0,
   nvp.merge_name = "", nvp.sequence = 0, nvp.active_ind = 1,
   nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   nvp.updt_id = reqinfo->updt_id, nvp.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (temp->applications[d.seq].initial_pref_id=0))
   JOIN (nvp)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on name_value_prefs insert for initial load pref")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM name_value_prefs nvp,
   (dummyt d  WITH seq = acnt)
  SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "DETAIL_PREFS",
   nvp.parent_entity_id = temp->applications[d.seq].detail_prefs_id,
   nvp.pvc_name = "RELATED_RESULTS_ADDITIONAL_LOAD", nvp.pvc_value = temp->applications[d.seq].
   addtl_load_value, nvp.merge_id = 0,
   nvp.merge_name = "", nvp.sequence = 0, nvp.active_ind = 1,
   nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   nvp.updt_id = reqinfo->updt_id, nvp.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (temp->applications[d.seq].addtl_pref_id=0))
   JOIN (nvp)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on name_value_prefs insert for addtl load pref")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM name_value_prefs nvp,
   (dummyt d  WITH seq = acnt)
  SET nvp.pvc_value = cnvtstring(temp->applications[d.seq].config_ind), nvp.updt_id = reqinfo->
   updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp
   .updt_cnt+ 1)
  PLAN (d
   WHERE (temp->applications[d.seq].config_pref_id > 0))
   JOIN (nvp
   WHERE (nvp.name_value_prefs_id=temp->applications[d.seq].config_pref_id)
    AND nvp.pvc_value != cnvtstring(temp->applications[d.seq].config_ind))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on name_value_prefs update for config pref")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM name_value_prefs nvp,
   (dummyt d  WITH seq = acnt)
  SET nvp.pvc_value = temp->applications[d.seq].initial_load_value, nvp.updt_id = reqinfo->updt_id,
   nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp
   .updt_cnt+ 1)
  PLAN (d
   WHERE (temp->applications[d.seq].initial_pref_id > 0))
   JOIN (nvp
   WHERE (nvp.name_value_prefs_id=temp->applications[d.seq].initial_pref_id)
    AND (nvp.pvc_value != temp->applications[d.seq].initial_load_value))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on name_value_prefs update for initial load pref")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM name_value_prefs nvp,
   (dummyt d  WITH seq = acnt)
  SET nvp.pvc_value = temp->applications[d.seq].addtl_load_value, nvp.updt_id = reqinfo->updt_id, nvp
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp
   .updt_cnt+ 1)
  PLAN (d
   WHERE (temp->applications[d.seq].addtl_pref_id > 0))
   JOIN (nvp
   WHERE (nvp.name_value_prefs_id=temp->applications[d.seq].addtl_pref_id)
    AND (nvp.pvc_value != temp->applications[d.seq].addtl_load_value))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on name_value_prefs update for addtl load pref")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
