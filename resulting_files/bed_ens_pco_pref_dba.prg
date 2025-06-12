CREATE PROGRAM bed_ens_pco_pref:dba
 FREE SET reply
 RECORD reply(
   1 nlist[*]
     2 name_value_prefs_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET skip_pref = "N"
 SET ncnt = size(request->nlist,5)
 SET stat = alterlist(reply->nlist,ncnt)
 FOR (x = 1 TO ncnt)
   IF ((request->nlist[x].action_flag=1))
    SET new_id = 0.0
    SELECT INTO "NL:"
     j = seq(carenet_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET reply->nlist[x].name_value_prefs_id = new_id
    SET parent_entity_id = 0.0
    IF ((request->nlist[x].parent_entity_name="APP_PREFS"))
     SELECT INTO "NL:"
      FROM app_prefs ap
      WHERE ap.active_ind=1
       AND (ap.application_number=request->nlist[x].application_number)
       AND (ap.position_cd=request->nlist[x].position_code_value)
       AND (ap.prsnl_id=request->nlist[x].prsnl_id)
      DETAIL
       parent_entity_id = ap.app_prefs_id
      WITH nocounter
     ;end select
     IF (parent_entity_id=0)
      SELECT INTO "nl:"
       z = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        parent_entity_id = cnvtreal(z)
       WITH format, nocounter
      ;end select
      INSERT  FROM app_prefs ap
       SET ap.app_prefs_id = parent_entity_id, ap.application_number = request->nlist[x].
        application_number, ap.position_cd = request->nlist[x].position_code_value,
        ap.prsnl_id = request->nlist[x].prsnl_id, ap.active_ind = 1, ap.updt_id = reqinfo->updt_id,
        ap.updt_cnt = 0, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->updt_applctx,
        ap.updt_dt_tm = cnvtdatetime(curdate,curtime)
       WITH nocounter
      ;end insert
      IF (parent_entity_id=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to add app_prefs_id for application number = ",cnvtstring(
         request->nlist[x].application_number),".")
       GO TO exit_script
      ENDIF
     ENDIF
    ELSEIF ((request->nlist[x].parent_entity_name="DETAIL_PREFS"))
     SELECT INTO "NL:"
      FROM detail_prefs d
      WHERE d.active_ind=1
       AND (d.application_number=request->nlist[x].application_number)
       AND (d.position_cd=request->nlist[x].position_code_value)
       AND (d.prsnl_id=request->nlist[x].prsnl_id)
       AND (d.person_id=request->nlist[x].detail_pref.person_id)
       AND (d.comp_name=request->nlist[x].detail_pref.comp_name)
       AND (d.view_name=request->nlist[x].detail_pref.view_name)
      DETAIL
       parent_entity_id = d.detail_prefs_id
      WITH nocounter
     ;end select
     IF (parent_entity_id=0)
      SELECT INTO "nl:"
       z = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        parent_entity_id = cnvtreal(z)
       WITH format, nocounter
      ;end select
      INSERT  FROM detail_prefs dp
       SET dp.detail_prefs_id = parent_entity_id, dp.application_number = request->nlist[x].
        application_number, dp.position_cd = request->nlist[x].position_code_value,
        dp.prsnl_id = request->nlist[x].prsnl_id, dp.person_id = request->nlist[x].detail_pref.
        person_id, dp.view_name = trim(request->nlist[x].detail_pref.view_name),
        dp.view_seq = 0, dp.comp_name = trim(request->nlist[x].detail_pref.comp_name), dp.comp_seq =
        0,
        dp.active_ind = 1, dp.updt_id = reqinfo->updt_id, dp.updt_cnt = 0,
        dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->updt_applctx, dp.updt_dt_tm =
        cnvtdatetime(curdate,curtime)
       WITH nocounter
      ;end insert
      IF (parent_entity_id=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to add detail_prefs for application number = ",cnvtstring(
         request->nlist[x].application_number),".")
       GO TO exit_script
      ENDIF
     ENDIF
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Parent_entity_name must equal APP_PREFS or script needs to be ",
      "modified to handle other parent_entity_names.")
     GO TO exit_script
    ENDIF
    SET skip_pref = "N"
    IF ((request->nlist[x].pvc_name="MUL_REFPELEAFLETDISP"))
     SELECT INTO "nl:"
      FROM name_value_prefs n
      PLAN (n
       WHERE n.parent_entity_id=parent_entity_id
        AND (n.pvc_name=request->nlist[x].pvc_name))
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET skip_pref = "Y"
     ELSE
      SET request->nlist[x].pvc_value = "1"
      SELECT INTO "nl:"
       FROM br_client bc
       DETAIL
        IF (bc.region > " "
         AND bc.region != "USA")
         request->nlist[x].pvc_value = "2"
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    IF (skip_pref="N")
     SET reply->nlist[x].name_value_prefs_id = new_id
     INSERT  FROM name_value_prefs n
      SET n.name_value_prefs_id = new_id, n.parent_entity_id = parent_entity_id, n.parent_entity_name
        = request->nlist[x].parent_entity_name,
       n.pvc_name = request->nlist[x].pvc_name, n.pvc_value = request->nlist[x].pvc_value, n
       .active_ind = 1,
       n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = reqinfo->updt_id, n.updt_task =
       reqinfo->updt_task,
       n.updt_cnt = 0, n.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",trim(request->nlist[x].pvc_name)," with value = ",
       trim(request->list[x].pvc_value)," into the name_value_prefs table.")
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((request->nlist[x].action_flag=2))
    SET reply->nlist[x].name_value_prefs_id = request->nlist[x].name_value_prefs_id
    UPDATE  FROM name_value_prefs n
     SET n.active_ind = 1, n.pvc_value = request->nlist[x].pvc_value, n.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_cnt = (n.updt_cnt+ 1),
      n.updt_applctx = reqinfo->updt_applctx
     WHERE (n.name_value_prefs_id=request->nlist[x].name_value_prefs_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update ",cnvtstring(request->nlist[x].name_value_prefs_id),
      " on the name_value_prefs table.")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->nlist[x].action_flag=3))
    SET reply->nlist[x].name_value_prefs_id = request->nlist[x].name_value_prefs_id
    DELETE  FROM name_value_prefs n
     WHERE (n.name_value_prefs_id=request->nlist[x].name_value_prefs_id)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to delete ",cnvtstring(request->nlist[x].name_value_prefs_id),
      " on the name_value_prefs table.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_PCO_PREF","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
