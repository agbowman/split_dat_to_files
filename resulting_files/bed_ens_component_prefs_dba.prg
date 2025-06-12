CREATE PROGRAM bed_ens_component_prefs:dba
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
 FREE SET cpy_request
 RECORD cpy_request(
   1 application = i4
   1 positions[*]
     2 position_code_value = f8
 )
 FREE SET cpy_reply
 RECORD cpy_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET 4411175_nvp_ins
 RECORD 4411175_nvp_ins(
   1 4411175_nvp_ins[*]
     2 parent_id = f8
     2 parent_name = vc
     2 pvc_name = vc
     2 pvc_value = vc
     2 sequence = i4
     2 merge_id = f8
     2 merge_name = vc
     2 pos_code = f8
     2 global_ind = i2
     2 nvp_id = f8
     2 source_nvp_id = f8
 )
 FREE SET 4411175_nvp_del
 RECORD 4411175_nvp_del(
   1 4411175_nvp_del[*]
     2 nvp_id = f8
 )
 FREE SET 4411175_dp_ins
 RECORD 4411175_dp_ins(
   1 4411175_dp_ins[*]
     2 dp_id = f8
     2 view_name = vc
     2 view_seq = i4
     2 comp_name = vc
     2 comp_seq = i4
     2 source_dp_id = f8
     2 pos_code = f8
 )
 FREE SET temp_view_comp_pref
 RECORD temp_view_comp_pref(
   1 view_comp_pref[*]
     2 view_comp_pref_id = f8
     2 vp_count = i4
 )
 FREE SET temp_detail_pref
 RECORD temp_detail_pref(
   1 detail_pref[*]
     2 detail_pref_id = f8
     2 dp_count = i4
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
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 DECLARE pos_cnt = i4 WITH protect
 DECLARE comp_cnt = i4 WITH protect
 DECLARE add_pos_ind = i2 WITH protect
 DECLARE cpy_cnt = i4 WITH protect
 DECLARE nvp_cnt = i4 WITH protect
 DECLARE pref_cnt = i4 WITH protect
 DECLARE new_id = f8 WITH protect
 DECLARE nvp_del_cnt = i4 WITH protect
 DECLARE dp_ins_cnt = i4 WITH protect
 DECLARE position_size = i4 WITH protect
 DECLARE component_size = i4 WITH protect
 DECLARE view_comp_pref_count = i4 WITH protect
 DECLARE detail_pref_count = i4 WITH protect
 DECLARE nvp_count = i4 WITH protect
 DECLARE dp_count = i4 WITH protect
 DECLARE vp_count = i4 WITH protect
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
 SET nvp_cnt = 0
 SET dp_ins_cnt = 0
 SET cpy_request->application = request->application
 FOR (p = 1 TO pos_cnt)
   SET comp_cnt = size(request->positions[p].components,5)
   SET add_pos_ind = 0
   FOR (c = 1 TO comp_cnt)
     IF ((request->positions[p].components[c].view_comp_prefs_id=0))
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat("No VC ID")
      GO TO exit_script
     ENDIF
     SET pref_cnt = size(request->positions[p].components[c].preferences,5)
     IF (pref_cnt > 0)
      IF ((request->positions[p].components[c].global_ind=1))
       IF ((request->positions[p].components[c].target_name="DETAIL_PREFS"))
        IF ((request->positions[p].components[c].target_id > 0))
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = concat("DP ID")
         GO TO exit_script
        ENDIF
        SET new_id = 0.0
        SELECT INTO "NL:"
         j = seq(carenet_seq,nextval)"##################;rp0"
         FROM dual du
         PLAN (du)
         DETAIL
          new_id = cnvtreal(j)
         WITH format, counter
        ;end select
        SET dp_ins_cnt = (dp_ins_cnt+ 1)
        SET stat = alterlist(4411175_dp_ins->4411175_dp_ins,dp_ins_cnt)
        SET 4411175_dp_ins->4411175_dp_ins[dp_ins_cnt].source_dp_id = request->positions[p].
        components[c].view_comp_prefs_id
        SET 4411175_dp_ins->4411175_dp_ins[dp_ins_cnt].pos_code = request->positions[p].
        position_code_value
        SET request->positions[p].components[c].target_id = new_id
        SET 4411175_dp_ins->4411175_dp_ins[dp_ins_cnt].dp_id = new_id
       ELSE
        SET add_pos_ind = 1
       ENDIF
      ENDIF
      SET pref_cnt = size(request->positions[p].components[c].preferences,5)
      FOR (n = 1 TO pref_cnt)
        SET nvp_cnt = (nvp_cnt+ 1)
        SET stat = alterlist(4411175_nvp_ins->4411175_nvp_ins,nvp_cnt)
        SET 4411175_nvp_ins->4411175_nvp_ins[nvp_cnt].global_ind = request->positions[p].components[c
        ].global_ind
        SET 4411175_nvp_ins->4411175_nvp_ins[nvp_cnt].parent_id = request->positions[p].components[c]
        .target_id
        SET 4411175_nvp_ins->4411175_nvp_ins[nvp_cnt].parent_name = request->positions[p].components[
        c].target_name
        SET 4411175_nvp_ins->4411175_nvp_ins[nvp_cnt].pos_code = request->positions[p].
        position_code_value
        SET 4411175_nvp_ins->4411175_nvp_ins[nvp_cnt].source_nvp_id = request->positions[p].
        components[c].preferences[n].name_value_prefs_id
      ENDFOR
     ELSE
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat("No Prefs")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build("No prefs for position: ",
       request->positions[p].position_code_value," and component: ",request->positions[p].components[
       c].target_id)
      GO TO exit_script
     ENDIF
   ENDFOR
   IF (add_pos_ind=1)
    SET cpy_cnt = (cpy_cnt+ 1)
    SET stat = alterlist(cpy_request->positions,cpy_cnt)
    SET cpy_request->positions[cpy_cnt].position_code_value = request->positions[p].
    position_code_value
   ENDIF
 ENDFOR
 IF (cpy_cnt > 0)
  EXECUTE bed_cpy_app_to_pos_prefs  WITH replace("REQUEST",cpy_request), replace("REPLY",cpy_reply)
  IF ((cpy_reply->status_data.status="F"))
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("Copy Failed")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = cpy_reply->status_data.
   subeventstatus[1].targetobjectvalue
   GO TO exit_script
  ENDIF
 ENDIF
 IF (dp_ins_cnt > 0)
  SET num_found = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(dp_ins_cnt)),
    view_comp_prefs p
   PLAN (d)
    JOIN (p
    WHERE (p.view_comp_prefs_id=4411175_dp_ins->4411175_dp_ins[d.seq].source_dp_id))
   ORDER BY d.seq
   HEAD d.seq
    num_found = (num_found+ 1), 4411175_dp_ins->4411175_dp_ins[d.seq].comp_name = p.comp_name,
    4411175_dp_ins->4411175_dp_ins[d.seq].comp_seq = p.comp_seq,
    4411175_dp_ins->4411175_dp_ins[d.seq].view_name = p.view_name, 4411175_dp_ins->4411175_dp_ins[d
    .seq].view_seq = p.view_seq
   WITH nocounter
  ;end select
  IF (num_found != dp_ins_cnt)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("No source DP")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  INSERT  FROM detail_prefs dp,
    (dummyt d  WITH seq = value(dp_ins_cnt))
   SET dp.active_ind = 1, dp.application_number = request->application, dp.comp_name = 4411175_dp_ins
    ->4411175_dp_ins[d.seq].comp_name,
    dp.comp_seq = 4411175_dp_ins->4411175_dp_ins[d.seq].comp_seq, dp.detail_prefs_id = 4411175_dp_ins
    ->4411175_dp_ins[d.seq].dp_id, dp.person_id = 0.0,
    dp.position_cd = 4411175_dp_ins->4411175_dp_ins[d.seq].pos_code, dp.prsnl_id = 0.0, dp.view_name
     = 4411175_dp_ins->4411175_dp_ins[d.seq].view_name,
    dp.view_seq = 4411175_dp_ins->4411175_dp_ins[d.seq].view_seq, dp.updt_applctx = reqinfo->
    updt_applctx, dp.updt_cnt = 0,
    dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id = reqinfo->updt_id, dp.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (dp)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on detail_prefs insert."
    )
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nvp_cnt)),
   name_value_prefs n
  PLAN (d)
   JOIN (n
   WHERE (n.name_value_prefs_id=4411175_nvp_ins->4411175_nvp_ins[d.seq].source_nvp_id))
  ORDER BY d.seq
  HEAD d.seq
   4411175_nvp_ins->4411175_nvp_ins[d.seq].merge_id = n.merge_id, 4411175_nvp_ins->4411175_nvp_ins[d
   .seq].merge_name = n.merge_name, 4411175_nvp_ins->4411175_nvp_ins[d.seq].pvc_name = n.pvc_name,
   4411175_nvp_ins->4411175_nvp_ins[d.seq].pvc_value = n.pvc_value, 4411175_nvp_ins->4411175_nvp_ins[
   d.seq].sequence = n.sequence
  WITH nocounter
 ;end select
 SET nvp_del_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nvp_cnt)),
   name_value_prefs n
  PLAN (d
   WHERE (4411175_nvp_ins->4411175_nvp_ins[d.seq].global_ind=0))
   JOIN (n
   WHERE (n.parent_entity_id=4411175_nvp_ins->4411175_nvp_ins[d.seq].parent_id)
    AND (n.parent_entity_name=4411175_nvp_ins->4411175_nvp_ins[d.seq].parent_name)
    AND trim(n.pvc_name)=trim(4411175_nvp_ins->4411175_nvp_ins[d.seq].pvc_name)
    AND n.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   cnt = 0
  DETAIL
   nvp_del_cnt = (nvp_del_cnt+ 1), stat = alterlist(4411175_nvp_del->4411175_nvp_del,nvp_del_cnt),
   4411175_nvp_del->4411175_nvp_del[nvp_del_cnt].nvp_id = n.name_value_prefs_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nvp_cnt)),
   name_value_prefs n
  PLAN (d
   WHERE (4411175_nvp_ins->4411175_nvp_ins[d.seq].parent_name="DETAIL_PREFS"))
   JOIN (n
   WHERE (n.parent_entity_id=4411175_nvp_ins->4411175_nvp_ins[d.seq].parent_id)
    AND n.parent_entity_name="DETAIL_PREFS"
    AND trim(n.pvc_name)=trim(4411175_nvp_ins->4411175_nvp_ins[d.seq].pvc_name)
    AND n.active_ind=1)
  ORDER BY d.seq, n.name_value_prefs_id
  HEAD n.name_value_prefs_id
   nvp_del_cnt = (nvp_del_cnt+ 1), stat = alterlist(4411175_nvp_del->4411175_nvp_del,nvp_del_cnt),
   4411175_nvp_del->4411175_nvp_del[nvp_del_cnt].nvp_id = n.name_value_prefs_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nvp_cnt)),
   view_comp_prefs dp,
   view_comp_prefs dp2,
   name_value_prefs n
  PLAN (d
   WHERE (4411175_nvp_ins->4411175_nvp_ins[d.seq].global_ind=1)
    AND (4411175_nvp_ins->4411175_nvp_ins[d.seq].parent_name="VIEW_COMP_PREFS"))
   JOIN (dp
   WHERE (dp.view_comp_prefs_id=4411175_nvp_ins->4411175_nvp_ins[d.seq].parent_id))
   JOIN (dp2
   WHERE dp2.view_name=dp.view_name
    AND dp2.view_seq=dp.view_seq
    AND dp2.comp_name=dp.comp_name
    AND dp2.comp_seq=dp.comp_seq
    AND dp2.application_number=dp.application_number
    AND (dp2.position_cd=4411175_nvp_ins->4411175_nvp_ins[d.seq].pos_code)
    AND dp2.prsnl_id=0)
   JOIN (n
   WHERE n.parent_entity_id=outerjoin(dp2.view_comp_prefs_id)
    AND n.parent_entity_name=outerjoin("VIEW_COMP_PREFS")
    AND trim(n.pvc_name)=outerjoin(trim(4411175_nvp_ins->4411175_nvp_ins[d.seq].pvc_name))
    AND n.active_ind=outerjoin(1))
  ORDER BY d.seq, n.name_value_prefs_id
  HEAD d.seq
   4411175_nvp_ins->4411175_nvp_ins[d.seq].parent_id = dp2.view_comp_prefs_id, 4411175_nvp_ins->
   4411175_nvp_ins[d.seq].global_ind = 0
  HEAD n.name_value_prefs_id
   IF (n.name_value_prefs_id > 0)
    nvp_del_cnt = (nvp_del_cnt+ 1), stat = alterlist(4411175_nvp_del->4411175_nvp_del,nvp_del_cnt),
    4411175_nvp_del->4411175_nvp_del[nvp_del_cnt].nvp_id = n.name_value_prefs_id
   ENDIF
  WITH nocounter
 ;end select
 FOR (n = 1 TO nvp_cnt)
   IF ((((4411175_nvp_ins->4411175_nvp_ins[n].global_ind=1)
    AND (4411175_nvp_ins->4411175_nvp_ins[n].parent_name="VIEW_COMP_PREFS")) OR ((4411175_nvp_ins->
   4411175_nvp_ins[n].parent_id=0))) )
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = concat("No Target Found")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("Pos: ",4411175_nvp_ins->
     4411175_nvp_ins[n].pos_code," TargetId: ",4411175_nvp_ins->4411175_nvp_ins[n].parent_id,
     " TargetTable: ",
     4411175_nvp_ins->4411175_nvp_ins[n].parent_name)
    CALL echorecord(4411175_nvp_ins)
    GO TO exit_script
   ENDIF
   SET new_id = 0.0
   SELECT INTO "NL:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual du
    PLAN (du)
    DETAIL
     new_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET 4411175_nvp_ins->4411175_nvp_ins[n].nvp_id = new_id
 ENDFOR
 IF (nvp_del_cnt > 0)
  SET ierrcode = 0
  DELETE  FROM name_value_prefs n,
    (dummyt d  WITH seq = value(nvp_del_cnt))
   SET n.seq = 1
   PLAN (d)
    JOIN (n
    WHERE (n.name_value_prefs_id=4411175_nvp_del->4411175_nvp_del[d.seq].nvp_id))
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
  SET n.name_value_prefs_id = 4411175_nvp_ins->4411175_nvp_ins[d.seq].nvp_id, n.pvc_value =
   4411175_nvp_ins->4411175_nvp_ins[d.seq].pvc_value, n.merge_id = 4411175_nvp_ins->4411175_nvp_ins[d
   .seq].merge_id,
   n.merge_name = 4411175_nvp_ins->4411175_nvp_ins[d.seq].merge_name, n.sequence = 4411175_nvp_ins->
   4411175_nvp_ins[d.seq].sequence, n.active_ind = 1,
   n.parent_entity_id = 4411175_nvp_ins->4411175_nvp_ins[d.seq].parent_id, n.parent_entity_name =
   4411175_nvp_ins->4411175_nvp_ins[d.seq].parent_name, n.pvc_name = 4411175_nvp_ins->
   4411175_nvp_ins[d.seq].pvc_name,
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
    SET component_size = size(request->positions[cntr].components,5)
    FOR (cntr1 = 1 TO component_size)
      SET pref_cnt = size(request->positions[cntr].components[cntr1].preferences,5)
      IF (pref_cnt > 0)
       IF ((request->positions[cntr].components[cntr1].target_name="VIEW_COMP_PREFS"))
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = value(pref_cnt)),
          prsnl p,
          view_comp_prefs v,
          name_value_prefs nvp
         PLAN (d)
          JOIN (p
          WHERE (p.position_cd=request->positions[cntr].position_code_value))
          JOIN (v
          WHERE v.prsnl_id=p.person_id)
          JOIN (nvp
          WHERE nvp.parent_entity_id=v.view_comp_prefs_id
           AND nvp.parent_entity_name="VIEW_COMP_PREFS"
           AND (nvp.pvc_name=
          (SELECT
           pvc_name
           FROM name_value_prefs
           WHERE (name_value_prefs_id=request->positions[cntr].components[cntr1].preferences[d.seq].
           name_value_prefs_id))))
         ORDER BY v.view_comp_prefs_id, nvp.name_value_prefs_id
         HEAD REPORT
          view_comp_pref_count = 0, nvp_count = 0
         HEAD v.view_comp_prefs_id
          view_comp_pref_count = (view_comp_pref_count+ 1), stat = alterlist(temp_view_comp_pref->
           view_comp_pref,view_comp_pref_count), temp_view_comp_pref->view_comp_pref[
          view_comp_pref_count].view_comp_pref_id = v.view_comp_prefs_id
         HEAD nvp.name_value_prefs_id
          nvp_count = (nvp_count+ 1), stat = alterlist(temp_nvp->nvp,nvp_count), temp_nvp->nvp[
          nvp_count].nvp_id = nvp.name_value_prefs_id
         WITH nocounter
        ;end select
       ELSE
        SELECT INTO "nl:"
         FROM (dummyt dt  WITH seq = value(pref_cnt)),
          prsnl p,
          detail_prefs d,
          name_value_prefs nvp
         PLAN (dt)
          JOIN (p
          WHERE (p.position_cd=request->positions[cntr].position_code_value))
          JOIN (d
          WHERE d.prsnl_id=p.person_id)
          JOIN (nvp
          WHERE nvp.parent_entity_id=d.detail_prefs_id
           AND nvp.parent_entity_name="DETAIL_PREFS"
           AND (nvp.pvc_name=
          (SELECT
           pvc_name
           FROM name_value_prefs
           WHERE (name_value_prefs_id=request->positions[cntr].components[cntr1].preferences[dt.seq].
           name_value_prefs_id))))
         ORDER BY d.detail_prefs_id, nvp.name_value_prefs_id
         HEAD REPORT
          detail_pref_count = 0, nvp_count = 0
         HEAD d.detail_prefs_id
          detail_pref_count = (detail_pref_count+ 1), stat = alterlist(temp_detail_pref->detail_pref,
           detail_pref_count), temp_detail_pref->detail_pref[detail_pref_count].detail_pref_id = d
          .detail_prefs_id
         HEAD nvp.name_value_prefs_id
          nvp_count = (nvp_count+ 1), stat = alterlist(temp_nvp->nvp,nvp_count), temp_nvp->nvp[
          nvp_count].nvp_id = nvp.name_value_prefs_id
         WITH nocounter
        ;end select
       ENDIF
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
      IF ((request->positions[cntr].components[cntr1].target_name="DETAIL_PREFS"))
       IF (detail_pref_count > 0)
        SELECT INTO "nl:"
         FROM name_value_prefs nvp,
          (dummyt d  WITH seq = value(detail_pref_count))
         PLAN (d)
          JOIN (nvp
          WHERE (nvp.parent_entity_id=temp_detail_pref->detail_pref[d.seq].detail_pref_id))
         HEAD REPORT
          dp_count = 0
         HEAD nvp.name_value_prefs_id
          dp_count = (dp_count+ 1), temp_detail_pref->detail_pref[d.seq].dp_count = dp_count
         WITH nocounter
        ;end select
        SET ierrcode = 0
        DELETE  FROM detail_prefs dp,
          (dummyt d  WITH seq = value(detail_pref_count))
         SET dp.seq = 1
         PLAN (d
          WHERE (temp_detail_pref->detail_pref[d.seq].dp_count=0))
          JOIN (dp
          WHERE (dp.detail_prefs_id=temp_detail_pref->detail_pref[d.seq].detail_pref_id)
           AND dp.active_ind=1)
         WITH nocounter
        ;end delete
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = concat(
          "Error on detail_prefs delete")
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSE
       IF (view_comp_pref_count > 0)
        SELECT INTO "nl:"
         FROM name_value_prefs nvp,
          (dummyt d  WITH seq = value(view_comp_pref_count))
         PLAN (d)
          JOIN (nvp
          WHERE (nvp.parent_entity_id=temp_view_comp_pref->view_comp_pref[d.seq].view_comp_pref_id))
         HEAD REPORT
          vp_count = 0
         HEAD nvp.name_value_prefs_id
          vp_count = (vp_count+ 1), temp_view_comp_pref->view_comp_pref[d.seq].vp_count = vp_count
         WITH nocounter
        ;end select
        SET ierrcode = 0
        DELETE  FROM view_comp_prefs vp,
          (dummyt d  WITH seq = value(view_comp_pref_count))
         SET d.seq = 1
         PLAN (d
          WHERE (temp_view_comp_pref->view_comp_pref[d.seq].vp_count=0))
          JOIN (vp
          WHERE (vp.view_comp_prefs_id=temp_view_comp_pref->view_comp_pref[d.seq].view_comp_pref_id)
           AND vp.active_ind=1)
         WITH nocounter
        ;end delete
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = concat(
          "Error on view_comp_prefs delete")
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
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
