CREATE PROGRAM drc_upd_route_group:dba
 FREE SET temp_prem
 RECORD temp_prem(
   1 qual[1]
     2 dose_range_check_id = f8
     2 multum_case_id = f8
     2 parent_premise_id = f8
     2 premise_type_flag = i2
     2 relational_operator_flag = i2
     2 value1 = f8
     2 value1_string = vc
     2 value_type_flag = i2
     2 value_unit_cd = f8
 )
 FREE SET temp_prem_list
 RECORD temp_prem_list(
   1 active_ind = i2
   1 drc_premise_list_id = f8
   1 parent_entity_id = f8
 )
 FREE SET prem_list_ids
 RECORD prem_list_ids(
   1 qual[*]
     2 drc_premise_list_id = f8
     2 parent_entity_id = f8
 )
 FREE SET reply
 RECORD reply(
   1 error_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_next_seq(next_seq=f8) = f8
 DECLARE insert_prem_ver(aidx=i4) = null
 DECLARE insert_prem_list_ver(aidx=i4) = null
 DECLARE check_prem_list(aidx=i4) = null
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE nxt_seq = f8 WITH public, noconstant(0.0)
 DECLARE cv_string = vc WITH public, noconstant(" ")
 DECLARE cv_cnt = i4 WITH public, noconstant(size(request->cv_list,5))
 DECLARE pp_cnt = i4 WITH public, noconstant(size(request->qual,5))
 DECLARE dpl_cnt = i4 WITH public, noconstant(0)
 DECLARE v_ver_seq = i4 WITH public, noconstant(0)
 DECLARE num = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 IF (((cv_cnt <= 0) OR (pp_cnt <= 0)) )
  SET failed = "T"
  SET reply->error_string = "Either the CV_LIST or the QUAL list is not populated."
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO pp_cnt)
  IF ((request->qual[x].drc_premise_id <= 0.0))
   SET failed = "T"
   SET reply->error_string = concat("The value for drc_premise_id was equal to zero.")
   GO TO exit_script
  ENDIF
  IF ((request->qual[x].location_ind=0))
   IF (cv_cnt=1)
    SET temp_prem->qual[1].value1_string = uar_get_code_display(request->cv_list[1].code_value)
    CALL echo(build("Updating child in DRC_PREMISE table:",request->qual[x].drc_premise_id))
    UPDATE  FROM drc_premise dp
     SET dp.value_unit_cd = request->cv_list[1].code_value, dp.value1 = request->cv_list[1].
      code_value, dp.value1_string = temp_prem->qual[1].value1_string,
      dp.updt_applctx = reqinfo->updt_applctx, dp.updt_cnt = (dp.updt_cnt+ 1), dp.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      dp.updt_id = reqinfo->updt_id, dp.updt_task = reqinfo->updt_task
     WHERE (dp.drc_premise_id=request->qual[x].drc_premise_id)
      AND dp.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->error_string = "Could not update DRC_PREMISE table for child"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     dp.parent_premise_id, dp.dose_range_check_id
     FROM drc_premise dp
     WHERE (dp.drc_premise_id=request->qual[x].drc_premise_id)
      AND dp.active_ind=1
     DETAIL
      temp_prem->qual[1].dose_range_check_id = dp.dose_range_check_id, temp_prem->qual[1].
      multum_case_id = dp.multum_case_id, temp_prem->qual[1].parent_premise_id = dp.parent_premise_id,
      temp_prem->qual[1].premise_type_flag = dp.premise_type_flag, temp_prem->qual[1].
      relational_operator_flag = dp.relational_operator_flag, temp_prem->qual[1].value1 = request->
      cv_list[1].code_value,
      temp_prem->qual[1].value_type_flag = dp.value_type_flag, temp_prem->qual[1].value_unit_cd =
      request->cv_list[1].code_value
     WITH nocounter
    ;end select
    CALL insert_prem_ver(x)
   ELSEIF (cv_cnt > 1)
    CALL echo(build("Updating child in DRC_PREMISE table:",request->qual[x].drc_premise_id))
    UPDATE  FROM drc_premise dp
     SET dp.value_unit_cd = 0.0, dp.value1 = 0.0, dp.value1_string = "",
      dp.relational_operator_flag = 8, dp.value_type_flag = 4, dp.updt_applctx = reqinfo->
      updt_applctx,
      dp.updt_cnt = (dp.updt_cnt+ 1), dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id =
      reqinfo->updt_id,
      dp.updt_task = reqinfo->updt_task
     WHERE (dp.drc_premise_id=request->qual[x].drc_premise_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->error_string = "Could not update DRC_PREMISE table for child"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     dp.parent_premise_id, dp.dose_range_check_id
     FROM drc_premise dp
     WHERE (dp.drc_premise_id=request->qual[x].drc_premise_id)
      AND dp.active_ind=1
     DETAIL
      temp_prem->qual[1].dose_range_check_id = dp.dose_range_check_id, temp_prem->qual[1].
      multum_case_id = dp.multum_case_id, temp_prem->qual[1].parent_premise_id = dp.parent_premise_id,
      temp_prem->qual[1].premise_type_flag = dp.premise_type_flag, temp_prem->qual[1].
      relational_operator_flag = 8, temp_prem->qual[1].value1 = 0.0,
      temp_prem->qual[1].value1_string = "", temp_prem->qual[1].value_type_flag = 4, temp_prem->qual[
      1].value_unit_cd = 0.0
     WITH nocounter
    ;end select
    CALL insert_prem_ver(x)
    CALL check_prem_list(x)
   ENDIF
  ELSEIF ((request->qual[x].location_ind=1))
   CALL check_prem_list(x)
   SET cv_string = "dpl.parent_entity_id not in ("
   FOR (z = 1 TO cv_cnt)
     SET cv_string = build(cv_string,request->cv_list[z].code_value,",")
   ENDFOR
   SET cv_string = build(substring(1,(size(cv_string,1) - 1),cv_string),")")
   IF (cv_cnt < 1)
    SET cv_string = "1 = 1"
   ENDIF
   SELECT INTO "nl:"
    dpl.drc_premise_list_id, dpl.parent_entity_id
    FROM drc_premise_list dpl
    WHERE dpl.active_ind=1
     AND dpl.parent_entity_name="CODE_VALUE"
     AND (dpl.drc_premise_id=request->qual[x].drc_premise_id)
     AND parser(cv_string)
    HEAD REPORT
     dpl_cnt = 0
    DETAIL
     dpl_cnt = (dpl_cnt+ 1)
     IF (mod(dpl_cnt,10)=1)
      stat = alterlist(prem_list_ids->qual,(dpl_cnt+ 9))
     ENDIF
     prem_list_ids->qual[dpl_cnt].drc_premise_list_id = dpl.drc_premise_list_id, prem_list_ids->qual[
     dpl_cnt].parent_entity_id = dpl.parent_entity_id
    FOOT REPORT
     stat = alterlist(prem_list_ids->qual,dpl_cnt)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL echo(build("Updating into DRC_PREMISE_LIST table"))
    UPDATE  FROM drc_premise_list dpl
     SET dpl.active_ind = 0, dpl.updt_applctx = reqinfo->updt_applctx, dpl.updt_cnt = (dpl.updt_cnt+
      1),
      dpl.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpl.updt_id = reqinfo->updt_id, dpl.updt_task
       = reqinfo->updt_task
     WHERE dpl.active_ind=1
      AND dpl.parent_entity_name="CODE_VALUE"
      AND (dpl.drc_premise_id=request->qual[x].drc_premise_id)
      AND parser(cv_string)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->error_string = "Could not update DRC_PREMISE_LIST table"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     GO TO exit_script
    ENDIF
    FOR (z = 1 TO dpl_cnt)
      SET temp_prem_list->active_ind = 0
      SET temp_prem_list->drc_premise_list_id = prem_list_ids->qual[z].drc_premise_list_id
      SET temp_prem_list->parent_entity_id = prem_list_ids->qual[z].parent_entity_id
      CALL insert_prem_list_ver(x)
    ENDFOR
   ELSE
    CALL echo(build("No extra routes for DRC_PREMISE_ID:",request->qual[x].drc_premise_id))
   ENDIF
  ENDIF
 ENDFOR
 SUBROUTINE get_next_seq(next_seq)
  SELECT INTO "nl:"
   number = seq(drc_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    next_seq = cnvtint(number)
   WITH format, counter
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Failed to get sequence value from reference_seq"
   GO TO exit_script
  ELSE
   RETURN(next_seq)
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_prem_ver(aidx)
   SET v_ver_seq = 0
   SELECT INTO "nl:"
    temp_seq = max(dpv.ver_seq)
    FROM drc_premise_ver dpv
    WHERE (dpv.drc_premise_id=request->qual[aidx].drc_premise_id)
     AND dpv.parent_ind=0
    DETAIL
     v_ver_seq = (temp_seq+ 1)
    WITH nocounter
   ;end select
   CALL echo(build("Inserting child into DRC_PREMISE_VER table:",request->qual[aidx].drc_premise_id))
   CALL echo(build("Version number:",v_ver_seq))
   INSERT  FROM drc_premise_ver dpv
    SET dpv.drc_premise_id = request->qual[aidx].drc_premise_id, dpv.parent_premise_id = temp_prem->
     qual[1].parent_premise_id, dpv.dose_range_check_id = temp_prem->qual[1].dose_range_check_id,
     dpv.parent_ind = 0, dpv.premise_type_flag = temp_prem->qual[1].premise_type_flag, dpv
     .relational_operator_flag = temp_prem->qual[1].relational_operator_flag,
     dpv.value_type_flag = temp_prem->qual[1].value_type_flag, dpv.value_unit_cd = temp_prem->qual[1]
     .value_unit_cd, dpv.value1 = temp_prem->qual[1].value1,
     dpv.value1_string = temp_prem->qual[1].value1_string, dpv.value2 = 0.0, dpv.value2_string = "",
     dpv.active_ind = 1, dpv.multum_case_id = temp_prem->qual[1].multum_case_id, dpv.ver_seq =
     v_ver_seq,
     dpv.updt_applctx = reqinfo->updt_applctx, dpv.updt_cnt = 0, dpv.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     dpv.updt_id = reqinfo->updt_id, dpv.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->error_string = "Could not insert into DRC_PREMISE_VER table for child"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_prem_list_ver(aidx)
   SET v_ver_seq = 0
   SELECT INTO "nl:"
    temp_seq = max(dplv.ver_seq)
    FROM drc_premise_list_ver dplv
    WHERE (dplv.drc_premise_list_id=temp_prem_list->drc_premise_list_id)
    DETAIL
     v_ver_seq = (temp_seq+ 1)
    WITH nocounter
   ;end select
   CALL echo(build("Inserting into DRC_PREMISE_LIST_VER:",temp_prem_list->drc_premise_list_id))
   INSERT  FROM drc_premise_list_ver dpl
    SET dpl.drc_premise_list_id = temp_prem_list->drc_premise_list_id, dpl.drc_premise_id = request->
     qual[aidx].drc_premise_id, dpl.parent_entity_name = "CODE_VALUE",
     dpl.parent_entity_id = temp_prem_list->parent_entity_id, dpl.active_ind = temp_prem_list->
     active_ind, dpl.ver_seq = v_ver_seq,
     dpl.updt_applctx = reqinfo->updt_applctx, dpl.updt_cnt = 0, dpl.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     dpl.updt_id = reqinfo->updt_id, dpl.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->error_string = "Could not insert into DRC_PREMISE_LIST_VER table."
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_prem_list(aidx)
   FOR (y = 1 TO cv_cnt)
    SELECT INTO "nl:"
     dpl.drc_premise_id
     FROM drc_premise_list dpl
     WHERE (dpl.drc_premise_id=request->qual[aidx].drc_premise_id)
      AND (dpl.parent_entity_id=request->cv_list[y].code_value)
      AND dpl.parent_entity_name="CODE_VALUE"
     HEAD REPORT
      temp_prem_list->drc_premise_list_id = 0.0
     DETAIL
      temp_prem_list->drc_premise_list_id = dpl.drc_premise_list_id
     WITH nocounter, nullreport
    ;end select
    IF ((temp_prem_list->drc_premise_list_id=0.0))
     SET nxt_seq = 0
     SET temp_prem_list->drc_premise_list_id = get_next_seq(nxt_seq)
     SET temp_prem_list->active_ind = 1
     SET temp_prem_list->parent_entity_id = request->cv_list[y].code_value
     CALL echo(build("Inserting into DRC_PREMISE_LIST:",temp_prem_list->drc_premise_list_id))
     INSERT  FROM drc_premise_list dpl
      SET dpl.drc_premise_list_id = temp_prem_list->drc_premise_list_id, dpl.drc_premise_id = request
       ->qual[aidx].drc_premise_id, dpl.parent_entity_name = "CODE_VALUE",
       dpl.parent_entity_id = temp_prem_list->parent_entity_id, dpl.active_ind = 1, dpl.updt_applctx
        = reqinfo->updt_applctx,
       dpl.updt_cnt = 0, dpl.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpl.updt_id = reqinfo->
       updt_id,
       dpl.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET reply->error_string = "Could not insert into DRC_PREMISE_LIST table"
      SET reply->status_data.subeventstatus[1].operationname = "insert"
      GO TO exit_script
     ENDIF
     CALL insert_prem_list_ver(aidx)
    ELSE
     SET temp_prem_list->active_ind = 1
     SET temp_prem_list->parent_entity_id = request->cv_list[y].code_value
     CALL echo(build("Activating into DRC_PREMISE_LIST:",temp_prem_list->drc_premise_list_id))
     UPDATE  FROM drc_premise_list dpl
      SET dpl.active_ind = 1, dpl.updt_applctx = reqinfo->updt_applctx, dpl.updt_cnt = (dpl.updt_cnt
       + 1),
       dpl.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpl.updt_id = reqinfo->updt_id, dpl.updt_task
        = reqinfo->updt_task
      WHERE (dpl.drc_premise_list_id=temp_prem_list->drc_premise_list_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->error_string = "Could not update into DRC_PREMISE_LIST table"
      SET reply->status_data.subeventstatus[1].operationname = "insert"
      GO TO exit_script
     ENDIF
     CALL insert_prem_list_ver(aidx)
    ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "ErrorMessage"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = substring(1,132,errmsg)
 ENDIF
 IF (failed="T")
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
