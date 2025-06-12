CREATE PROGRAM bed_ens_app_prefs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET 4411177_nvp_ins
 RECORD 4411177_nvp_ins(
   1 4411177_nvp_ins[*]
     2 pvc_name = vc
     2 pvc_value = vc
     2 sequence = i4
     2 merge_id = f8
     2 merge_name = vc
     2 pos_code = f8
     2 global_ind = i2
     2 nvp_id = f8
     2 ap_id = f8
     2 source_nvp_id = f8
 )
 FREE SET 4411177_nvp_del
 RECORD 4411177_nvp_del(
   1 4411177_nvp_del[*]
     2 nvp_id = f8
 )
 FREE SET 4411177_ap_insert
 RECORD 4411177_ap_insert(
   1 positions[*]
     2 pos_code = f8
     2 ap_exists_ind = i2
 )
 FREE SET temp_app_pref
 RECORD temp_app_pref(
   1 app_pref[*]
     2 app_pref_id = f8
     2 ap_count = i4
 )
 FREE SET temp_nvp
 RECORD temp_nvp(
   1 nvp[*]
     2 nvp_id = f8
 )
 DECLARE error_flag = vc WITH protect
 DECLARE req_cnt = i4 WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 DECLARE pos_cnt = i4 WITH protect
 DECLARE cpy_cnt = i4 WITH protect
 DECLARE nvp_cnt = i4 WITH protect
 DECLARE pref_cnt = i4 WITH protect
 DECLARE new_id = f8 WITH protect
 DECLARE nvp_del_cnt = i4 WITH protect
 DECLARE ap_cnt = i4 WITH protect
 DECLARE ap_ins_ind = i2 WITH protect
 DECLARE start = i4 WITH protect
 DECLARE num = i4 WITH protect
 DECLARE position_size = i4 WITH protect
 DECLARE nvp_count = i4 WITH protect
 DECLARE app_pref_count = i4 WITH protect
 DECLARE ap_count = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 IF ((request->application=0))
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Aplication = 0")
  GO TO exit_script
 ENDIF
 SET pos_cnt = size(request->positions,5)
 IF (pos_cnt=0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("No positions")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(4411177_ap_insert->positions,pos_cnt)
 FOR (p = 1 TO pos_cnt)
   SET pref_cnt = size(request->positions[p].preferences,5)
   SET 4411177_ap_insert->positions[p].pos_code = request->positions[p].position_code_value
   FOR (n = 1 TO pref_cnt)
     SET nvp_cnt = (nvp_cnt+ 1)
     SET stat = alterlist(4411177_nvp_ins->4411177_nvp_ins,nvp_cnt)
     SET 4411177_nvp_ins->4411177_nvp_ins[nvp_cnt].pos_code = request->positions[p].
     position_code_value
     SET 4411177_nvp_ins->4411177_nvp_ins[nvp_cnt].source_nvp_id = request->positions[p].preferences[
     n].name_value_prefs_id
   ENDFOR
 ENDFOR
 IF (nvp_cnt=0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("No Prefs")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(pos_cnt)),
   app_prefs a
  PLAN (d)
   JOIN (a
   WHERE (a.position_cd=4411177_ap_insert->positions[d.seq].pos_code)
    AND (a.application_number=request->application)
    AND a.prsnl_id=0.0
    AND a.active_ind=1)
  HEAD d.seq
   4411177_ap_insert->positions[d.seq].ap_exists_ind = 1
  WITH nocounter
 ;end select
 SET ierrcode = 0
 INSERT  FROM app_prefs a,
   (dummyt d  WITH seq = value(pos_cnt))
  SET a.active_ind = 1, a.app_prefs_id = seq(carenet_seq,nextval), a.application_number = request->
   application,
   a.position_cd = 4411177_ap_insert->positions[d.seq].pos_code, a.prsnl_id = 0.0, a.updt_applctx =
   reqinfo->updt_applctx,
   a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id,
   a.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (4411177_ap_insert->positions[d.seq].ap_exists_ind=0))
   JOIN (a)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on ap insert")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 CALL echorecord(4411177_ap_insert)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nvp_cnt)),
   name_value_prefs n
  PLAN (d)
   JOIN (n
   WHERE (n.name_value_prefs_id=4411177_nvp_ins->4411177_nvp_ins[d.seq].source_nvp_id))
  ORDER BY d.seq
  HEAD d.seq
   4411177_nvp_ins->4411177_nvp_ins[d.seq].merge_id = n.merge_id, 4411177_nvp_ins->4411177_nvp_ins[d
   .seq].merge_name = n.merge_name, 4411177_nvp_ins->4411177_nvp_ins[d.seq].pvc_name = n.pvc_name,
   4411177_nvp_ins->4411177_nvp_ins[d.seq].pvc_value = n.pvc_value, 4411177_nvp_ins->4411177_nvp_ins[
   d.seq].sequence = n.sequence
  WITH nocounter
 ;end select
 SET nvp_del_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nvp_cnt)),
   app_prefs a,
   name_value_prefs n
  PLAN (d)
   JOIN (a
   WHERE (a.application_number=request->application)
    AND (a.position_cd=4411177_nvp_ins->4411177_nvp_ins[d.seq].pos_code)
    AND a.prsnl_id=0.0
    AND a.active_ind=1)
   JOIN (n
   WHERE n.parent_entity_id=outerjoin(a.app_prefs_id)
    AND n.parent_entity_name=outerjoin("APP_PREFS")
    AND trim(n.pvc_name)=outerjoin(trim(4411177_nvp_ins->4411177_nvp_ins[d.seq].pvc_name))
    AND n.active_ind=outerjoin(1))
  ORDER BY d.seq
  HEAD d.seq
   cnt = 0, 4411177_nvp_ins->4411177_nvp_ins[d.seq].ap_id = a.app_prefs_id
  DETAIL
   IF (n.name_value_prefs_id > 0)
    nvp_del_cnt = (nvp_del_cnt+ 1), stat = alterlist(4411177_nvp_del->4411177_nvp_del,nvp_del_cnt),
    4411177_nvp_del->4411177_nvp_del[nvp_del_cnt].nvp_id = n.name_value_prefs_id
   ENDIF
  WITH nocounter
 ;end select
 SET num = 0
 SET start = 0
 IF (locateval(num,start,nvp_cnt,0.0,4411177_nvp_ins->4411177_nvp_ins[num].ap_id) > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("No AP Found")
  CALL echorecord(4411177_nvp_ins)
  GO TO exit_script
 ENDIF
 IF (nvp_del_cnt > 0)
  SET ierrcode = 0
  DELETE  FROM name_value_prefs n,
    (dummyt d  WITH seq = value(nvp_del_cnt))
   SET n.seq = 1
   PLAN (d)
    JOIN (n
    WHERE (n.name_value_prefs_id=4411177_nvp_del->4411177_nvp_del[d.seq].nvp_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on nvp delete")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = 0
 INSERT  FROM name_value_prefs n,
   (dummyt d  WITH seq = value(nvp_cnt))
  SET n.name_value_prefs_id = seq(carenet_seq,nextval), n.pvc_value = 4411177_nvp_ins->
   4411177_nvp_ins[d.seq].pvc_value, n.merge_id = 4411177_nvp_ins->4411177_nvp_ins[d.seq].merge_id,
   n.merge_name = 4411177_nvp_ins->4411177_nvp_ins[d.seq].merge_name, n.sequence = 4411177_nvp_ins->
   4411177_nvp_ins[d.seq].sequence, n.active_ind = 1,
   n.parent_entity_id = 4411177_nvp_ins->4411177_nvp_ins[d.seq].ap_id, n.parent_entity_name =
   "APP_PREFS", n.pvc_name = 4411177_nvp_ins->4411177_nvp_ins[d.seq].pvc_name,
   n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt = 0, n.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (n)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on nvp insert")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 IF ((request->delete_user_pref_flag=1))
  SET position_size = size(request->positions,5)
  IF (position_size > 0)
   FOR (cntr = 1 TO position_size)
     SET pref_cnt = size(request->positions[cntr].preferences,5)
     IF (pref_cnt > 0)
      SELECT INTO "nl:"
       FROM (dummyt dt  WITH seq = value(pref_cnt)),
        prsnl p,
        app_prefs a,
        name_value_prefs nvp
       PLAN (dt)
        JOIN (p
        WHERE (p.position_cd=request->positions[cntr].position_code_value))
        JOIN (a
        WHERE a.prsnl_id=p.person_id)
        JOIN (nvp
        WHERE nvp.parent_entity_id=a.app_prefs_id
         AND nvp.parent_entity_name="APP_PREFS"
         AND (nvp.pvc_name=
        (SELECT
         pvc_name
         FROM name_value_prefs
         WHERE (name_value_prefs_id=request->positions[cntr].preferences[dt.seq].name_value_prefs_id)
        )))
       ORDER BY a.app_prefs_id, nvp.name_value_prefs_id
       HEAD REPORT
        app_pref_count = 0, nvp_count = 0
       HEAD a.app_prefs_id
        app_pref_count = (app_pref_count+ 1), stat = alterlist(temp_app_pref->app_pref,app_pref_count
         ), temp_app_pref->app_pref[app_pref_count].app_pref_id = a.app_prefs_id
       HEAD nvp.name_value_prefs_id
        nvp_count = (nvp_count+ 1), stat = alterlist(temp_nvp->nvp,nvp_count), temp_nvp->nvp[
        nvp_count].nvp_id = nvp.name_value_prefs_id
       WITH nocounter
      ;end select
     ENDIF
     IF (nvp_count > 0)
      SET ierrcode = 0
      DELETE  FROM name_value_prefs nvp,
        (dummyt d  WITH seq = value(nvp_count))
       SET nvp.seq = 1
       PLAN (d)
        JOIN (nvp
        WHERE (nvp.name_value_prefs_id=temp_nvp->nvp[d.seq].nvp_id)
         AND nvp.active_ind=1)
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on nvp delete")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
     IF (app_pref_count > 0)
      SELECT INTO "nl:"
       FROM name_value_prefs nvp,
        (dummyt d  WITH seq = value(app_pref_count))
       PLAN (d)
        JOIN (nvp
        WHERE (nvp.parent_entity_id=temp_app_pref->app_pref[d.seq].app_pref_id))
       HEAD REPORT
        ap_count = 0
       HEAD nvp.name_value_prefs_id
        ap_count = (ap_count+ 1), temp_app_pref->app_pref[d.seq].ap_count = ap_count
       WITH nocounter
      ;end select
      SET ierrcode = 0
      DELETE  FROM app_prefs ap,
        (dummyt d  WITH seq = value(app_pref_count))
       SET ap.seq = 1
       PLAN (d
        WHERE (temp_app_pref->app_pref[d.seq].ap_count=0))
        JOIN (ap
        WHERE (ap.app_prefs_id=temp_app_pref->app_pref[d.seq].app_pref_id)
         AND ap.active_ind=1)
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on app_prefs delete"
        )
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
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
