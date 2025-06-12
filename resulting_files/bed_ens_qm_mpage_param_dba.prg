CREATE PROGRAM bed_ens_qm_mpage_param:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE dp_id = f8
 DECLARE nvp_id = f8
 SET rcnt = size(request->reports,5)
 CALL echo(build("rcnt1: ",rcnt))
 IF ((request->action_flag=1))
  IF ((request->selected_ind=1))
   SET ierrcode = 0
   FREE SET temp_del
   RECORD temp_del(
     1 del[*]
       2 value = vc
   )
   SET temp_cnt = 0
   SELECT INTO "nl:"
    FROM detail_prefs dp,
     name_value_prefs nvp,
     view_prefs vp,
     name_value_prefs nvp1,
     br_name_value br_nv
    PLAN (dp
     WHERE (dp.position_cd=request->position_code_value)
      AND (dp.application_number=request->application_number)
      AND dp.view_name="DISCERNRPT"
      AND dp.comp_name="DISCERNRPT"
      AND dp.active_ind=1)
     JOIN (nvp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name="REPORT_PARAM")
     JOIN (vp
     WHERE vp.prsnl_id=dp.prsnl_id
      AND vp.position_cd=dp.position_cd
      AND vp.application_number=dp.application_number
      AND vp.view_name=dp.view_name
      AND vp.view_seq=dp.view_seq
      AND vp.active_ind=1)
     JOIN (nvp1
     WHERE nvp1.parent_entity_id=vp.view_prefs_id
      AND nvp1.parent_entity_name="VIEW_PREFS"
      AND trim(nvp1.pvc_name)="VIEW_CAPTION")
     JOIN (br_nv
     WHERE br_nv.br_nv_key1="QMMPAGEPARAM"
      AND br_nv.br_name="DETAIL_PREFS"
      AND br_nv.br_value=cnvtstring(dp.detail_prefs_id))
    ORDER BY dp.detail_prefs_id
    HEAD REPORT
     cnt = 0, temp_cnt = 0, stat = alterlist(temp_del->del,100)
    HEAD dp.detail_prefs_id
     cnt = (cnt+ 1), temp_cnt = (temp_cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(temp_del->del,(temp_cnt+ 100)), cnt = 1
     ENDIF
     temp_del->del[temp_cnt].value = cnvtstring(dp.detail_prefs_id)
    FOOT REPORT
     stat = alterlist(temp_del->del,temp_cnt)
    WITH nocounter
   ;end select
   IF (temp_cnt > 0)
    SET ierrcode = 0
    DELETE  FROM br_name_value br_nv,
      (dummyt d  WITH seq = value(temp_cnt))
     SET br_nv.seq = 1
     PLAN (d
      WHERE (temp_del->del[d.seq].value > " "))
      JOIN (br_nv
      WHERE (br_nv.br_value=temp_del->del[d.seq].value)
       AND br_nv.br_nv_key1="QMMPAGEPARAM"
       AND br_nv.br_name="DETAIL_PREFS")
     WITH nocounter
    ;end delete
   ENDIF
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on Delete")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
  FOR (i = 1 TO rcnt)
   SELECT INTO "nl:"
    FROM detail_prefs dp,
     name_value_prefs nvp,
     view_prefs vp,
     name_value_prefs nvp1
    PLAN (dp
     WHERE (dp.position_cd=request->position_code_value)
      AND (dp.application_number=request->application_number)
      AND dp.view_name="DISCERNRPT"
      AND dp.comp_name="DISCERNRPT"
      AND dp.active_ind=1)
     JOIN (nvp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name="REPORT_PARAM")
     JOIN (vp
     WHERE vp.prsnl_id=dp.prsnl_id
      AND vp.position_cd=dp.position_cd
      AND vp.application_number=dp.application_number
      AND vp.view_name=dp.view_name
      AND vp.view_seq=dp.view_seq
      AND vp.active_ind=1)
     JOIN (nvp1
     WHERE nvp1.parent_entity_id=vp.view_prefs_id
      AND nvp1.parent_entity_name="VIEW_PREFS"
      AND trim(nvp1.pvc_name)="VIEW_CAPTION"
      AND (nvp1.pvc_value=request->reports[i].mpage))
    DETAIL
     dp_id = dp.detail_prefs_id, nvp_id = nvp.name_value_prefs_id
    WITH nocounter
   ;end select
   IF ((request->selected_ind=1)
    AND dp_id > 0)
    SET rpt_name = 0
    SELECT INTO "nl:"
     FROM name_value_prefs nvp
     PLAN (nvp
      WHERE nvp.parent_entity_id=dp_id
       AND nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.pvc_name="REPORT_NAME")
     DETAIL
      IF (nvp.pvc_value="DC_MP_OPEN_MPAGE")
       rpt_name = 1
      ELSE
       rpt_name = 2
      ENDIF
     WITH nocounter
    ;end select
    IF (rpt_name=0)
     SET np_id = 0.0
     SELECT INTO "nl:"
      temp = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       np_id = cnvtreal(temp)
      WITH nocounter
     ;end select
     SET ierrcode = 0
     INSERT  FROM name_value_prefs nvp
      SET nvp.name_value_prefs_id = np_id, nvp.parent_entity_id = dp_id, nvp.parent_entity_name =
       "DETAIL_PREFS",
       nvp.pvc_name = "REPORT_NAME", nvp.pvc_value = "DC_MP_OPEN_MPAGE", nvp.active_ind = 1,
       nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name
        = " ",
       nvp.merge_id = 0.0, nvp.sequence = 0
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error on Inserting REPORT_NAME Preference")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ELSEIF (rpt_name=2)
     SET ierrcode = 0
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = "DC_MP_OPEN_MPAGE", nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo
       ->updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.parent_entity_id=dp_id
       AND nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.pvc_name="REPORT_NAME"
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error on updating REPORT_NAME Preference")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
    SET name_value_id = 0.0
    SELECT INTO "nl:"
     y = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      name_value_id = cnvtreal(y)
     WITH format, counter
    ;end select
    SET ierrcode = 0
    INSERT  FROM br_name_value br
     SET br.br_name_value_id = name_value_id, br.br_nv_key1 = "QMMPAGEPARAM", br.br_name =
      "DETAIL_PREFS",
      br.br_value = cnvtstring(dp_id), br.updt_cnt = 0, br.updt_dt_tm = cnvtdatetime(curdate,curtime),
      br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on Inserting Reports")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ELSE
    SET ierrcode = 0
    UPDATE  FROM name_value_prefs nvp
     SET nvp.pvc_value = request->reports[i].parameters, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp
      .updt_id = reqinfo->updt_id,
      nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
      .updt_applctx = reqinfo->updt_applctx
     WHERE nvp.name_value_prefs_id=nvp_id
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error on updating REPORT_PARAM Preference")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
  ENDFOR
 ELSEIF ((request->action_flag=2))
  FOR (i = 1 TO rcnt)
   SELECT INTO "nl:"
    FROM detail_prefs dp,
     name_value_prefs nvp,
     view_prefs vp,
     name_value_prefs nvp1,
     br_name_value br_nv
    PLAN (dp
     WHERE (dp.position_cd=request->position_code_value)
      AND (dp.application_number=request->application_number)
      AND dp.view_name="DISCERNRPT"
      AND dp.comp_name="DISCERNRPT"
      AND dp.active_ind=1)
     JOIN (nvp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name="REPORT_PARAM")
     JOIN (vp
     WHERE vp.prsnl_id=dp.prsnl_id
      AND vp.position_cd=dp.position_cd
      AND vp.application_number=dp.application_number
      AND vp.view_name=dp.view_name
      AND vp.view_seq=dp.view_seq
      AND vp.active_ind=1)
     JOIN (nvp1
     WHERE nvp1.parent_entity_id=vp.view_prefs_id
      AND nvp1.parent_entity_name="VIEW_PREFS"
      AND trim(nvp1.pvc_name)="VIEW_CAPTION"
      AND (nvp1.pvc_value=request->reports[i].mpage))
     JOIN (br_nv
     WHERE br_nv.br_nv_key1="QMMPAGEPARAM"
      AND br_nv.br_name="DETAIL_PREFS"
      AND br_nv.br_value=cnvtstring(dp.detail_prefs_id))
    DETAIL
     dp_id = dp.detail_prefs_id, nvp_id = nvp.name_value_prefs_id
    WITH nocounter
   ;end select
   IF (nvp_id > 0)
    UPDATE  FROM name_value_prefs nvp
     SET nvp.pvc_value = request->reports[i].parameters, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp
      .updt_id = reqinfo->updt_id,
      nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
      .updt_applctx = reqinfo->updt_applctx
     WHERE nvp.name_value_prefs_id=nvp_id
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error on updating REPORT_PARAM Preference")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
