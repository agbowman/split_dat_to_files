CREATE PROGRAM drc_upd_group:dba
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
 SUBROUTINE convert_to_days(number,units_code,from_or_to)
   SET number_of_days = 0.0
   SET number_of_hrs = 0.0
   IF (units_code=years
    AND from_or_to=1
    AND number=1.0)
    SET number_of_days = 360.0
    SET number_of_hrs = (number_of_days * 24.0)
   ELSEIF (units_code=years
    AND from_or_to=1
    AND number=2.0)
    SET number_of_days = 720.0
    SET number_of_hrs = (number_of_days * 24.0)
   ELSEIF (units_code=years
    AND from_or_to=1
    AND number >= 3.0)
    SET number_of_days = round((365.0 * number),1)
    SET number_of_hrs = round(((365.0 * number) * 24.0),2)
   ELSEIF (units_code=years
    AND from_or_to=0
    AND number=1.0)
    SET number_of_days = 359.9
    SET number_of_hrs = ((360.0 * 24.0) - 0.01)
   ELSEIF (units_code=years
    AND from_or_to=0
    AND number=2.0)
    SET number_of_days = 719.9
    SET number_of_hrs = ((720.0 * 24.0) - 0.01)
   ELSEIF (units_code=years
    AND from_or_to=0
    AND number >= 3.0)
    SET number_of_days = round(((365.0 * number) - 0.1),1)
    SET number_of_hrs = round((((365.0 * number) * 24.0) - 0.01),2)
   ELSEIF (units_code=months
    AND from_or_to=1
    AND number=1.0)
    SET number_of_days = 28.0
    SET number_of_hrs = (number_of_days * 24.0)
   ELSEIF (units_code=months
    AND from_or_to=1
    AND number >= 2.0)
    SET number_of_days = round((30.0 * number),1)
    SET number_of_hrs = round(((30.0 * number) * 24.0),2)
   ELSEIF (units_code=months
    AND from_or_to=0
    AND number=1.0)
    SET number_of_days = 27.9
    SET number_of_hrs = ((28.0 * 24.0) - 0.01)
   ELSEIF (units_code=months
    AND from_or_to=0
    AND number >= 2.0)
    SET number_of_days = round(((30.0 * number) - 0.1),1)
    SET number_of_hrs = round((((30.0 * number) * 24.0) - 0.01),2)
   ELSEIF (units_code=weeks
    AND from_or_to=1)
    SET number_of_days = round((7.0 * number),1)
    SET number_of_hrs = round(((7.0 * number) * 24.0),2)
   ELSEIF (units_code=weeks
    AND from_or_to=0)
    SET number_of_days = round(((7.0 * number) - 0.1),1)
    SET number_of_hrs = round((((7.0 * number) * 24.0) - 0.01),2)
   ELSEIF (units_code=days
    AND from_or_to=1)
    SET number_of_days = round(number,1)
    SET number_of_hrs = round((number * 24.0),2)
   ELSEIF (units_code=days
    AND from_or_to=0)
    SET number_of_days = round((number - 0.1),1)
    SET number_of_hrs = round(((number * 24.0) - 0.01),2)
   ELSEIF (units_code=hours
    AND from_or_to=1)
    SET number_of_days = round((number/ 24.0),1)
    SET number_of_hrs = round(number,2)
   ELSEIF (units_code=hours
    AND from_or_to=0)
    SET number_of_days = round(((number/ 24.0) - 0.1),1)
    SET number_of_hrs = round((number - 0.01),2)
   ELSE
    SET number_of_days = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE direct_to_days(number,units_code)
  SET number_of_days = 0.0
  IF (units_code=years
   AND number=1.0)
   SET number_of_days = 360.0
  ELSEIF (units_code=years
   AND number=2.0)
   SET number_of_days = 720.0
  ELSEIF (units_code=years
   AND number >= 3.0)
   SET number_of_days = (365.0 * number)
  ELSEIF (units_code=months
   AND number=1.0)
   SET number_of_days = 28.0
  ELSEIF (units_code=months
   AND number >= 2.0)
   SET number_of_days = (30.0 * number)
  ELSEIF (units_code=weeks)
   SET number_of_days = (7.0 * number)
  ELSEIF (units_code=days)
   SET number_of_days = number
  ELSEIF (units_code=hours)
   SET number_of_days = (number/ 24.0)
  ELSE
   SET number_of_days = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE convert_to_kgs(number,units_code,operator)
  SET number_of_kgs = 0.0
  IF (units_code=kg
   AND operator=1)
   SET number_of_kgs = round((number - 0.00001),5)
  ELSEIF (units_code=kg
   AND ((operator=3) OR (operator=4)) )
   SET number_of_kgs = round(number,5)
  ELSEIF (units_code=kg
   AND operator=2)
   SET number_of_kgs = round((number+ 0.00001),5)
  ELSEIF (units_code=gram
   AND operator=1)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round(((number/ 1000.0) - 0.00001),5)
   ENDIF
  ELSEIF (units_code=gram
   AND ((operator=3) OR (operator=4)) )
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round((number/ 1000.0),5)
   ENDIF
  ELSEIF (units_code=gram
   AND operator=2)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round(((number/ 1000.0)+ 0.00001),5)
   ENDIF
  ELSEIF (units_code=ounce
   AND operator=1)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round((((number/ 16.0) * 0.4545) - 0.00001),5)
   ENDIF
  ELSEIF (units_code=ounce
   AND ((operator=3) OR (operator=4)) )
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round(((number/ 16.0) * 0.4545),5)
   ENDIF
  ELSEIF (units_code=ounce
   AND operator=2)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round((((number/ 16.0) * 0.4545)+ 0.00001),5)
   ENDIF
  ELSEIF (units_code=lbs
   AND operator=1)
   SET number_of_kgs = round(((number * 0.4545) - 0.00001),5)
  ELSEIF (units_code=lbs
   AND ((operator=3) OR (operator=4)) )
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round((number * 0.4545),5)
   ENDIF
  ELSEIF (units_code=lbs
   AND operator=2)
   SET number_of_kgs = round(((number * 0.4545)+ 0.00001),5)
  ELSE
   SET number_of_kgs = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE direct_to_kgs(number,units_code)
  SET number_of_kgs = 0.0
  IF (units_code=kg)
   SET number_of_kgs = number
  ELSEIF (units_code=gram)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = (number/ 1000.0)
   ENDIF
  ELSEIF (units_code=ounce)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = ((number/ 16.0) * 0.4545)
   ENDIF
  ELSEIF (units_code=lbs)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = (number * 0.4545)
   ENDIF
  ELSE
   SET number_of_kgs = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE format_number(number)
   SET number_string = fillstring(255," ")
   SET number_set = false
   SET mod_value = 0.0
   SET mod_value = (number - cnvtint(number))
   IF (mod_value=0.0)
    SET number_string = trim(cnvtstring(number))
    SET number_set = true
   ELSE
    IF (mod((number * 10000),10) != 0
     AND number_set=false)
     SET number_string = trim(format(number,"##########.####"),3)
     SET number_set = true
    ELSEIF (mod((number * 1000),10) != 0
     AND number_set=false)
     SET number_string = trim(format(number,"##########.###"),3)
     SET number_set = true
    ELSEIF (mod((number * 100),10) != 0
     AND number_set=false)
     SET number_string = trim(format(number,"##########.##"),3)
     SET number_set = true
    ELSE
     SET number_string = trim(format(number,"##########.#"),3)
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE nxt_seq = f8 WITH public, noconstant(0.0)
 DECLARE v_ver_seq = i4 WITH public, noconstant(0)
 DECLARE haschanged = i2 WITH public, noconstant(0)
 DECLARE par_prem_cnt = i4 WITH public, noconstant(size(request->parent_premise,5))
 DECLARE premise_cnt = i4 WITH public, noconstant(0)
 DECLARE prem_list_cnt = i4 WITH public, noconstant(0)
 DECLARE dose_range_cnt = i4 WITH public, noconstant(0)
 DECLARE insert_ind = i2 WITH public, noconstant(0)
 DECLARE value_type_flag = i2 WITH public, noconstant(0)
 DECLARE value1_string = vc WITH public, noconstant(" ")
 DECLARE value2_string = vc WITH public, noconstant(" ")
 DECLARE errmsg = c132 WITH public, noconstant(fillstring(132," "))
 DECLARE number_string = vc WITH public, noconstant(fillstring(255," "))
 DECLARE num1 = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET haschanged = false
 SET insert_ind = false
 IF ((request->dose_range_check_id=0.0))
  SET insert_ind = true
  SET nxt_seq = 0
  SET request->dose_range_check_id = get_next_seq(nxt_seq)
  SET request->drc_active_ind = 1
  SET request->drc_build_flag = 2
  CALL echo(build("Inserting into dose_range_check table:",request->dose_range_check_id))
  INSERT  FROM dose_range_check drc
   SET drc.dose_range_check_id = request->dose_range_check_id, drc.dose_range_check_name = trim(
     request->drc_name), drc.build_flag = request->drc_build_flag,
    drc.active_ind = request->drc_active_ind, drc.updt_applctx = reqinfo->updt_applctx, drc.updt_cnt
     = 0,
    drc.updt_dt_tm = cnvtdatetime(curdate,curtime3), drc.updt_id = reqinfo->updt_id, drc.updt_task =
    reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not insert dose_range_check table"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo(build("Searching dose_range_check table:",request->dose_range_check_id))
  SELECT INTO "nl:"
   drc.active_ind, drc.build_flag, drc.content_rule_identifier,
   drc.dose_range_check_name, drc.dose_range_check_id
   FROM dose_range_check drc
   PLAN (drc
    WHERE (drc.dose_range_check_id=request->dose_range_check_id))
   HEAD REPORT
    haschanged = false
   DETAIL
    IF ((((request->drc_active_ind != drc.active_ind)) OR (((trim(request->drc_name) != drc
    .dose_range_check_name) OR ((((request->drc_build_flag != drc.build_flag)) OR ((request->
    drc_content_rule_identifier != drc.content_rule_identifier))) )) )) )
     haschanged = true
    ENDIF
   WITH nocounter, maxread(drc,1)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not find dose_range_check_id"
   SET reply->status_data.subeventstatus[1].operationname = "get"
   GO TO exit_script
  ENDIF
  IF (haschanged=true)
   CALL echo(build("Updating dose_range_check table:",request->dose_range_check_id))
   UPDATE  FROM dose_range_check drc
    SET drc.dose_range_check_name = trim(request->drc_name), drc.build_flag = request->drc_build_flag,
     drc.active_ind = request->drc_active_ind,
     drc.content_rule_identifier = request->drc_content_rule_identifier, drc.updt_applctx = reqinfo->
     updt_applctx, drc.updt_cnt = (drc.updt_cnt+ 1),
     drc.updt_dt_tm = cnvtdatetime(curdate,curtime3), drc.updt_id = reqinfo->updt_id, drc.updt_task
      = reqinfo->updt_task
    WHERE (drc.dose_range_check_id=request->dose_range_check_id)
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->error_string = "Could not update dose_range_check table"
    SET reply->status_data.subeventstatus[1].operationname = "update"
    GO TO exit_script
   ENDIF
  ELSE
   CALL echo(build("Not updating dose_range_check table:",request->dose_range_check_id))
  ENDIF
 ENDIF
 IF (((haschanged=true) OR (insert_ind=true)) )
  SET v_ver_seq = 0
  SELECT INTO "nl:"
   temp_seq = max(drcv.ver_seq)
   FROM dose_range_check_ver drcv
   WHERE (drcv.dose_range_check_id=request->dose_range_check_id)
   DETAIL
    v_ver_seq = (temp_seq+ 1)
   WITH nocounter
  ;end select
  CALL echo(build("Inserting into dose_range_check_ver table:",request->dose_range_check_id))
  CALL echo(build("Version number:",v_ver_seq))
  INSERT  FROM dose_range_check_ver drc
   SET drc.dose_range_check_id = request->dose_range_check_id, drc.dose_range_check_name = trim(
     request->drc_name), drc.build_flag = request->drc_build_flag,
    drc.active_ind = request->drc_active_ind, drc.content_rule_identifier = request->
    drc_content_rule_identifier, drc.ver_seq = v_ver_seq,
    drc.updt_applctx = reqinfo->updt_applctx, drc.updt_cnt = 0, drc.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    drc.updt_id = reqinfo->updt_id, drc.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not insert dose_range_check_ver table"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   GO TO exit_script
  ENDIF
 ENDIF
 SET haschanged = false
 SET insert_ind = false
 IF ((request->drc_form_reltn_id=0.0))
  SET insert_ind = true
  SET nxt_seq = 0
  SET request->drc_form_reltn_id = get_next_seq(nxt_seq)
  SET request->reltn_active_ind = 1
  SET request->reltn_build_flag = 2
  CALL echo(build("Inserting into drc_form_reltn table:",request->drc_form_reltn_id))
  INSERT  FROM drc_form_reltn dfr
   SET dfr.drc_form_reltn_id = request->drc_form_reltn_id, dfr.drc_group_id = request->drc_group_id,
    dfr.dose_range_check_id = request->dose_range_check_id,
    dfr.build_flag = request->reltn_build_flag, dfr.active_ind = request->reltn_active_ind, dfr
    .updt_applctx = reqinfo->updt_applctx,
    dfr.updt_cnt = 0, dfr.updt_dt_tm = cnvtdatetime(curdate,curtime3), dfr.updt_id = reqinfo->updt_id,
    dfr.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not insert into drc_form_reltn table"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo(build("Searching drc_form_reltn table:",request->drc_form_reltn_id))
  SELECT INTO "nl:"
   dfr.active_ind, dfr.build_flag, dfr.dose_range_check_id,
   dfr.drc_group_id
   FROM drc_form_reltn dfr
   PLAN (dfr
    WHERE (dfr.drc_form_reltn_id=request->drc_form_reltn_id))
   HEAD REPORT
    haschanged = false
   DETAIL
    IF ((((request->reltn_active_ind != dfr.active_ind)) OR ((((request->reltn_build_flag != dfr
    .build_flag)) OR ((((request->dose_range_check_id != dfr.dose_range_check_id)) OR ((request->
    drc_group_id != dfr.drc_group_id))) )) )) )
     haschanged = true
    ENDIF
   WITH nocounter, maxread(dfr,1)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not find drc_form_reltn_id"
   SET reply->status_data.subeventstatus[1].operationname = "get"
   GO TO exit_script
  ENDIF
  IF (haschanged=true)
   CALL echo(build("Updating drc_form_reltn table:",request->drc_form_reltn_id))
   UPDATE  FROM drc_form_reltn dfr
    SET dfr.dose_range_check_id = request->dose_range_check_id, dfr.drc_group_id = request->
     drc_group_id, dfr.build_flag = request->reltn_build_flag,
     dfr.active_ind = request->reltn_active_ind, dfr.updt_applctx = reqinfo->updt_applctx, dfr
     .updt_cnt = (dfr.updt_cnt+ 1),
     dfr.updt_dt_tm = cnvtdatetime(curdate,curtime3), dfr.updt_id = reqinfo->updt_id, dfr.updt_task
      = reqinfo->updt_task
    WHERE (dfr.drc_form_reltn_id=request->drc_form_reltn_id)
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->error_string = "Updating drc_form_reltn table"
    SET reply->status_data.subeventstatus[1].operationname = "update"
    GO TO exit_script
   ENDIF
  ELSE
   CALL echo(build("Not updating drc_form_reltn table:",request->drc_form_reltn_id))
  ENDIF
 ENDIF
 IF (((haschanged=true) OR (insert_ind=true)) )
  SET v_ver_seq = 0
  SELECT INTO "nl:"
   temp_seq = max(dfrv.ver_seq)
   FROM drc_form_reltn_ver dfrv
   WHERE (dfrv.drc_form_reltn_id=request->drc_form_reltn_id)
   DETAIL
    v_ver_seq = (temp_seq+ 1)
   WITH nocounter
  ;end select
  CALL echo(build("Inserting into drc_form_reltn_ver table:",request->drc_form_reltn_id))
  CALL echo(build("Version number:",v_ver_seq))
  INSERT  FROM drc_form_reltn_ver dfr
   SET dfr.drc_form_reltn_id = request->drc_form_reltn_id, dfr.drc_group_id = request->drc_group_id,
    dfr.dose_range_check_id = request->dose_range_check_id,
    dfr.build_flag = request->reltn_build_flag, dfr.active_ind = request->reltn_active_ind, dfr
    .ver_seq = v_ver_seq,
    dfr.updt_applctx = reqinfo->updt_applctx, dfr.updt_cnt = 0, dfr.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    dfr.updt_id = reqinfo->updt_id, dfr.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not insert drc_form_reltn_ver table"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (i = 1 TO par_prem_cnt)
   SET haschanged = false
   SET insert_ind = false
   IF ((request->parent_premise[i].parent_premise_id=0.0))
    SET insert_ind = true
    SET nxt_seq = 0
    SET request->parent_premise[i].parent_premise_id = get_next_seq(nxt_seq)
    CALL echo(build("Inserting parent into drc_premise table:",request->parent_premise[i].
      parent_premise_id))
    INSERT  FROM drc_premise dp1
     SET dp1.drc_premise_id = request->parent_premise[i].parent_premise_id, dp1.parent_premise_id =
      0.0, dp1.dose_range_check_id = request->dose_range_check_id,
      dp1.active_ind = request->parent_premise[i].active_ind, dp1.updt_applctx = reqinfo->
      updt_applctx, dp1.updt_cnt = 0,
      dp1.parent_ind = 1, dp1.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp1.updt_id = reqinfo->
      updt_id,
      dp1.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->error_string = "Could not insert parent into drc_premise table"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     GO TO exit_script
    ENDIF
   ELSE
    CALL echo(build("Searching for parent in drc_premise table:",request->parent_premise[i].
      parent_premise_id))
    SELECT INTO "nl:"
     dp.active_ind, dp.dose_range_check_id
     FROM drc_premise dp
     PLAN (dp
      WHERE (dp.drc_premise_id=request->parent_premise[i].parent_premise_id)
       AND dp.parent_ind=1)
     HEAD REPORT
      haschanged = false
     DETAIL
      IF ((((request->parent_premise[i].active_ind != dp.active_ind)) OR ((request->
      dose_range_check_id != dp.dose_range_check_id))) )
       haschanged = true
      ENDIF
     WITH nocounter, maxread(dp,1)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->error_string = "Could not find parent_premise_id"
     SET reply->status_data.subeventstatus[1].operationname = "get"
     GO TO exit_script
    ENDIF
    IF (haschanged=true)
     CALL echo(build("Updating parent into drc_premise table:",request->parent_premise[i].
       parent_premise_id))
     UPDATE  FROM drc_premise dp1
      SET dp1.active_ind = request->parent_premise[i].active_ind, dp1.dose_range_check_id = request->
       dose_range_check_id, dp1.updt_applctx = reqinfo->updt_applctx,
       dp1.updt_cnt = (dp1.updt_cnt+ 1), dp1.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp1.updt_id
        = reqinfo->updt_id,
       dp1.updt_task = reqinfo->updt_task
      WHERE (dp1.drc_premise_id=request->parent_premise[i].parent_premise_id)
       AND dp1.parent_ind=1
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->error_string = "Could not update drc_premise table for parent"
      SET reply->status_data.subeventstatus[1].operationname = "update"
      GO TO exit_script
     ENDIF
    ELSE
     CALL echo(build("Not updating parent in drc_premise table:",request->parent_premise[i].
       parent_premise_id))
    ENDIF
   ENDIF
   IF (((haschanged=true) OR (insert_ind=true)) )
    SET v_ver_seq = 0
    SELECT INTO "nl:"
     temp_seq = max(dpv.ver_seq)
     FROM drc_premise_ver dpv
     WHERE (dpv.drc_premise_id=request->parent_premise[i].parent_premise_id)
      AND dpv.parent_ind=1
     DETAIL
      v_ver_seq = (temp_seq+ 1)
     WITH nocounter
    ;end select
    CALL echo(build("Inserting parent in drc_premise_ver table:",request->parent_premise[i].
      parent_premise_id))
    CALL echo(build("Version number:",v_ver_seq))
    INSERT  FROM drc_premise_ver dp2
     SET dp2.drc_premise_id = request->parent_premise[i].parent_premise_id, dp2.parent_premise_id =
      0.0, dp2.dose_range_check_id = request->dose_range_check_id,
      dp2.parent_ind = 1, dp2.active_ind = request->parent_premise[i].active_ind, dp2.ver_seq =
      v_ver_seq,
      dp2.updt_applctx = reqinfo->updt_applctx, dp2.updt_cnt = 0, dp2.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      dp2.updt_id = reqinfo->updt_id, dp2.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->error_string = "Could not insert into drc_premise_ver table for parent"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     GO TO exit_script
    ENDIF
   ENDIF
   SET premise_cnt = size(request->parent_premise[i].premise,5)
   FOR (j = 1 TO premise_cnt)
     CALL echo(build("Premise # ",j))
     CALL echo(build("Premise # ",j))
     SET request->parent_premise[i].premise[j].value1 = round(request->parent_premise[i].premise[j].
      value1,4)
     SET request->parent_premise[i].premise[j].value2 = round(request->parent_premise[i].premise[j].
      value2,4)
     CALL format_number(request->parent_premise[i].premise[j].value1)
     SET value1_string = number_string
     CALL format_number(request->parent_premise[i].premise[j].value2)
     SET value2_string = number_string
     IF ((request->parent_premise[i].premise[j].premise_type_flag=2))
      SET prem_list_cnt = size(request->parent_premise[i].premise[j].premise_list,5)
      IF (prem_list_cnt=0)
       SET value_type_flag = 3
       SET value1_string = uar_get_code_display(request->parent_premise[i].premise[j].value1)
       SET value2_string = "0"
       CALL echo(build("Premise list not used for this route:",request->parent_premise[i].premise[j].
         drc_premise_id))
      ELSE
       SET value_type_flag = 4
       SET value1_string = "0"
       SET value2_string = "0"
       SET request->parent_premise[i].premise[j].value1 = 0.0
       SET request->parent_premise[i].premise[j].value2 = 0.0
      ENDIF
     ENDIF
     CASE (request->parent_premise[i].premise[j].premise_type_flag)
      OF 1:
       SET value_type_flag = 1
      OF 2:
       IF (value_type_flag=3)
        SET value_type_flag = 3
       ELSE
        SET value_type_flag = 4
        SET request->parent_premise[i].premise[j].relational_operator_flag = 8
       ENDIF
      OF 3:
       SET value_type_flag = 1
      OF 4:
       SET value_type_flag = 1
      OF 5:
       SET value_type_flag = 1
      OF 6:
       SET value_type_flag = 1
      OF 7:
       SET value_type_flag = 0
      ELSE
       SET value_type_flag = 0
     ENDCASE
     SET haschanged = false
     SET insert_ind = false
     CALL echo(build("Drc_premise_id: ",request->parent_premise[i].premise[j].drc_premise_id))
     IF ((request->parent_premise[i].premise[j].drc_premise_id=0.0)
      AND (request->parent_premise[i].premise[j].premise_type_flag != 6))
      SELECT INTO "nl:"
       dp.drc_premise_id
       FROM drc_premise dp
       WHERE (dp.parent_premise_id=request->parent_premise[i].parent_premise_id)
        AND (dp.premise_type_flag=request->parent_premise[i].premise[j].premise_type_flag)
       DETAIL
        request->parent_premise[i].premise[j].drc_premise_id = dp.drc_premise_id
       WITH nocounter
      ;end select
     ENDIF
     CALL echo(build("First attempt at finding drc_premise_id: ",request->parent_premise[i].premise[j
       ].drc_premise_id))
     IF ((request->parent_premise[i].premise[j].drc_premise_id=0.0))
      SET insert_ind = true
      SET nxt_seq = 0
      SET request->parent_premise[i].premise[j].drc_premise_id = get_next_seq(nxt_seq)
      SET prem_active_ind = 1
      CALL echo(build("Inserting child into drc_premise table:",request->parent_premise[i].premise[j]
        .drc_premise_id))
      INSERT  FROM drc_premise dp2
       SET dp2.drc_premise_id = request->parent_premise[i].premise[j].drc_premise_id, dp2
        .parent_premise_id = request->parent_premise[i].parent_premise_id, dp2.dose_range_check_id =
        request->dose_range_check_id,
        dp2.parent_ind = 0, dp2.premise_type_flag = request->parent_premise[i].premise[j].
        premise_type_flag, dp2.relational_operator_flag = request->parent_premise[i].premise[j].
        relational_operator_flag,
        dp2.value_type_flag = value_type_flag, dp2.value_unit_cd = request->parent_premise[i].
        premise[j].value_unit_cd, dp2.concept_cki = trim(request->parent_premise[i].premise[j].
         concept_cki),
        dp2.value1 = request->parent_premise[i].premise[j].value1, dp2.value1_string = value1_string,
        dp2.value2 = request->parent_premise[i].premise[j].value2,
        dp2.value2_string = value2_string, dp2.active_ind = request->parent_premise[i].premise[j].
        active_ind, dp2.updt_applctx = reqinfo->updt_applctx,
        dp2.updt_cnt = 0, dp2.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp2.updt_id = reqinfo->
        updt_id,
        dp2.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = "T"
       SET reply->error_string = "Could not insert into drc_premise table"
       SET reply->status_data.subeventstatus[1].operationname = "insert"
       GO TO exit_script
      ENDIF
     ELSE
      CALL echo(build("Searching for child in drc_premise table:",request->parent_premise[i].premise[
        j].drc_premise_id))
      SELECT INTO "nl:"
       dp.active_ind, dp.dose_range_check_id, dp.parent_premise_id,
       dp.premise_type_flag, dp.relational_operator_flag, dp.concept_cki,
       dp.value1, dp.value1_string, dp.value2,
       dp.value2_string, dp.value_type_flag, dp.value_unit_cd
       FROM drc_premise dp
       PLAN (dp
        WHERE (dp.drc_premise_id=request->parent_premise[i].premise[j].drc_premise_id)
         AND (dp.parent_premise_id=request->parent_premise[i].parent_premise_id)
         AND dp.parent_ind=0)
       HEAD REPORT
        haschanged = false
       DETAIL
        IF ((((request->parent_premise[i].premise[j].active_ind != dp.active_ind)) OR ((((request->
        dose_range_check_id != dp.dose_range_check_id)) OR ((((request->parent_premise[i].
        parent_premise_id != dp.parent_premise_id)) OR ((((request->parent_premise[i].premise[j].
        premise_type_flag != dp.premise_type_flag)) OR ((((request->parent_premise[i].premise[j].
        relational_operator_flag != dp.relational_operator_flag)) OR ((((request->parent_premise[i].
        premise[j].concept_cki != dp.concept_cki)) OR ((((request->parent_premise[i].premise[j].
        value1 != dp.value1)) OR ((((request->parent_premise[i].premise[j].value2 != dp.value2)) OR (
        ((value_type_flag != dp.value_type_flag) OR ((request->parent_premise[i].premise[j].
        value_unit_cd != dp.value_unit_cd))) )) )) )) )) )) )) )) )) )
         haschanged = true
        ENDIF
        IF ((request->parent_premise[i].premise[j].value1 != 0))
         IF (value1_string != dp.value1_string)
          haschanged = true
         ENDIF
        ENDIF
        IF ((request->parent_premise[i].premise[j].value2 != 0))
         IF (value2_string != dp.value2_string)
          haschanged = true
         ENDIF
        ENDIF
       WITH nocounter, maxread(dp,1)
      ;end select
      IF (curqual=0)
       SET failed = "T"
       SET reply->error_string = "Could not find premise_id"
       SET reply->status_data.subeventstatus[1].operationname = "get"
       GO TO exit_script
      ENDIF
      IF (haschanged=true)
       CALL echo(build("Updating child in drc_premise table:",request->parent_premise[i].premise[j].
         drc_premise_id))
       UPDATE  FROM drc_premise dp2
        SET dp2.premise_type_flag = request->parent_premise[i].premise[j].premise_type_flag, dp2
         .relational_operator_flag = request->parent_premise[i].premise[j].relational_operator_flag,
         dp2.value_type_flag = value_type_flag,
         dp2.value_unit_cd = request->parent_premise[i].premise[j].value_unit_cd, dp2.concept_cki =
         trim(request->parent_premise[i].premise[j].concept_cki), dp2.value1 = request->
         parent_premise[i].premise[j].value1,
         dp2.value1_string = value1_string, dp2.value2 = request->parent_premise[i].premise[j].value2,
         dp2.value2_string = value2_string,
         dp2.active_ind = request->parent_premise[i].premise[j].active_ind, dp2.updt_applctx =
         reqinfo->updt_applctx, dp2.updt_cnt = (dp2.updt_cnt+ 1),
         dp2.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp2.updt_id = reqinfo->updt_id, dp2
         .updt_task = reqinfo->updt_task
        WHERE (dp2.drc_premise_id=request->parent_premise[i].premise[j].drc_premise_id)
         AND (dp2.parent_premise_id=request->parent_premise[i].parent_premise_id)
         AND dp2.parent_ind=0
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET failed = "T"
        SET reply->error_string = "Could not update drc_premise table for child"
        SET reply->status_data.subeventstatus[1].operationname = "update"
        GO TO exit_script
       ENDIF
      ELSE
       CALL echo(build("Not updating child in drc_premise table:",request->parent_premise[i].premise[
         j].drc_premise_id))
      ENDIF
     ENDIF
     IF (((haschanged=true) OR (insert_ind=true)) )
      SET v_ver_seq = 0
      SELECT INTO "nl:"
       temp_seq = max(dpv.ver_seq)
       FROM drc_premise_ver dpv
       WHERE (dpv.drc_premise_id=request->parent_premise[i].premise[j].drc_premise_id)
        AND dpv.parent_ind=0
       DETAIL
        v_ver_seq = (temp_seq+ 1)
       WITH nocounter
      ;end select
      CALL echo(build("Inserting child into drc_premise_ver table:",request->parent_premise[i].
        premise[j].drc_premise_id))
      CALL echo(build("Version number:",v_ver_seq))
      INSERT  FROM drc_premise_ver dp2
       SET dp2.drc_premise_id = request->parent_premise[i].premise[j].drc_premise_id, dp2
        .parent_premise_id = request->parent_premise[i].parent_premise_id, dp2.dose_range_check_id =
        request->dose_range_check_id,
        dp2.parent_ind = 0, dp2.premise_type_flag = request->parent_premise[i].premise[j].
        premise_type_flag, dp2.relational_operator_flag = request->parent_premise[i].premise[j].
        relational_operator_flag,
        dp2.value_type_flag = value_type_flag, dp2.value_unit_cd = request->parent_premise[i].
        premise[j].value_unit_cd, dp2.concept_cki = trim(request->parent_premise[i].premise[j].
         concept_cki),
        dp2.value1 = request->parent_premise[i].premise[j].value1, dp2.value1_string = value1_string,
        dp2.value2 = request->parent_premise[i].premise[j].value2,
        dp2.value2_string = value2_string, dp2.active_ind = request->parent_premise[i].premise[j].
        active_ind, dp2.ver_seq = v_ver_seq,
        dp2.updt_applctx = reqinfo->updt_applctx, dp2.updt_cnt = 0, dp2.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        dp2.updt_id = reqinfo->updt_id, dp2.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = "T"
       SET reply->error_string = "Could not insert into drc_premise_ver table for child"
       SET reply->status_data.subeventstatus[1].operationname = "insert"
       GO TO exit_script
      ENDIF
     ENDIF
     IF ((request->parent_premise[i].premise[j].premise_type_flag=2))
      SET prem_list_cnt = size(request->parent_premise[i].premise[j].premise_list,5)
      IF (prem_list_cnt=0)
       SET value_type_flag = 3
       SET value1_string = uar_get_code_display(request->parent_premise[i].premise[j].value1)
       SET value2_string = "0"
       CALL echo(build("Premise list not used for this route:",request->parent_premise[i].premise[j].
         drc_premise_id))
      ELSE
       SET value_type_flag = 4
       SET value1_string = "0"
       SET value2_string = "0"
       SET request->parent_premise[i].premise[j].value1 = 0.0
       SET request->parent_premise[i].premise[j].value2 = 0.0
       SET num = 0
       FOR (k = 1 TO prem_list_cnt)
         SET haschanged = false
         SET insert_ind = false
         IF ((request->parent_premise[i].premise[j].premise_list[k].drc_premise_list_id=0.0))
          SELECT INTO "nl:"
           dpl.drc_premise_list_id
           FROM drc_premise_list dpl
           WHERE (dpl.drc_premise_id=request->parent_premise[i].premise[j].drc_premise_id)
            AND dpl.parent_entity_name="CODE_VALUE"
            AND (dpl.parent_entity_id=request->parent_premise[i].premise[j].premise_list[k].
           parent_entity_id)
           DETAIL
            request->parent_premise[i].premise[j].premise_list[k].drc_premise_list_id = dpl
            .drc_premise_list_id
           WITH nocounter
          ;end select
         ENDIF
         IF ((request->parent_premise[i].premise[j].premise_list[k].drc_premise_list_id=0.0))
          SET insert_ind = true
          SET nxt_seq = 0
          SET request->parent_premise[i].premise[j].premise_list[k].drc_premise_list_id =
          get_next_seq(nxt_seq)
          CALL echo(build("Inserting into drc_premise_list:",request->parent_premise[i].premise[j].
            premise_list[k].drc_premise_list_id))
          INSERT  FROM drc_premise_list dpl
           SET dpl.drc_premise_list_id = request->parent_premise[i].premise[j].premise_list[k].
            drc_premise_list_id, dpl.drc_premise_id = request->parent_premise[i].premise[j].
            drc_premise_id, dpl.parent_entity_name = "CODE_VALUE",
            dpl.parent_entity_id = request->parent_premise[i].premise[j].premise_list[k].
            parent_entity_id, dpl.active_ind = 1, dpl.updt_applctx = reqinfo->updt_applctx,
            dpl.updt_cnt = 0, dpl.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpl.updt_id = reqinfo
            ->updt_id,
            dpl.updt_task = reqinfo->updt_task
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET failed = "T"
           SET reply->error_string = "Could not insert into drc_premise_list table"
           SET reply->status_data.subeventstatus[1].operationname = "insert"
           GO TO exit_script
          ENDIF
         ELSE
          SELECT INTO "nl:"
           dpl.active_ind, dpl.parent_entity_id, dpl.drc_premise_id
           FROM drc_premise_list dpl
           PLAN (dpl
            WHERE (dpl.drc_premise_list_id=request->parent_premise[i].premise[j].premise_list[k].
            drc_premise_list_id))
           HEAD REPORT
            haschanged = false
           DETAIL
            IF ((((request->parent_premise[i].premise[j].premise_list[k].active_ind != dpl.active_ind
            )) OR ((((request->parent_premise[i].premise[j].drc_premise_id != dpl.drc_premise_id))
             OR ((request->parent_premise[i].premise[j].premise_list[k].parent_entity_id != dpl
            .parent_entity_id))) )) )
             haschanged = true
            ENDIF
           WITH nocounter, maxread(dpl,1)
          ;end select
          IF (curqual=0)
           SET failed = "T"
           SET reply->error_string = "Could not find drc_premise_list_id"
           SET reply->status_data.subeventstatus[1].operationname = "get"
           GO TO exit_script
          ENDIF
          IF (haschanged=true)
           CALL echo(build("Updating into drc_premise_list table:",request->parent_premise[i].
             premise[j].premise_list[k].drc_premise_list_id))
           UPDATE  FROM drc_premise_list dpl
            SET dpl.active_ind = request->parent_premise[i].premise[j].premise_list[k].active_ind,
             dpl.drc_premise_id = request->parent_premise[i].premise[j].drc_premise_id, dpl
             .parent_entity_id = request->parent_premise[i].premise[j].premise_list[k].
             parent_entity_id,
             dpl.updt_applctx = reqinfo->updt_applctx, dpl.updt_cnt = (dpl.updt_cnt+ 1), dpl
             .updt_dt_tm = cnvtdatetime(curdate,curtime3),
             dpl.updt_id = reqinfo->updt_id, dpl.updt_task = reqinfo->updt_task
            WHERE (dpl.drc_premise_list_id=request->parent_premise[i].premise[j].premise_list[k].
            drc_premise_list_id)
            WITH nocounter
           ;end update
           IF (curqual=0)
            SET failed = "T"
            SET reply->error_string = "Could not update drc_premise_list table"
            SET reply->status_data.subeventstatus[1].operationname = "update"
            GO TO exit_script
           ENDIF
          ELSE
           CALL echo(build("Not updating in drc_premise_list table:",request->parent_premise[i].
             premise[j].premise_list[k].drc_premise_list_id))
          ENDIF
         ENDIF
         IF (((haschanged=true) OR (insert_ind=true)) )
          SET v_ver_seq = 0
          SELECT INTO "nl:"
           temp_seq = max(dplv.ver_seq)
           FROM drc_premise_list_ver dplv
           WHERE (dplv.drc_premise_list_id=request->parent_premise[i].premise[j].premise_list[k].
           drc_premise_list_id)
           DETAIL
            v_ver_seq = (temp_seq+ 1)
           WITH nocounter
          ;end select
          INSERT  FROM drc_premise_list_ver dpl
           SET dpl.drc_premise_list_id = request->parent_premise[i].premise[j].premise_list[k].
            drc_premise_list_id, dpl.drc_premise_id = request->parent_premise[i].premise[j].
            drc_premise_id, dpl.parent_entity_name = "CODE_VALUE",
            dpl.parent_entity_id = request->parent_premise[i].premise[j].premise_list[k].
            parent_entity_id, dpl.active_ind = request->parent_premise[i].premise[j].premise_list[k].
            active_ind, dpl.ver_seq = v_ver_seq,
            dpl.updt_applctx = reqinfo->updt_applctx, dpl.updt_cnt = 0, dpl.updt_dt_tm = cnvtdatetime
            (curdate,curtime3),
            dpl.updt_id = reqinfo->updt_id, dpl.updt_task = reqinfo->updt_task
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET failed = "T"
           SET reply->error_string = "Could not insert into drc_premise_list_ver table for child"
           SET reply->status_data.subeventstatus[1].operationname = "insert"
           GO TO exit_script
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
   SET dose_range_cnt = size(request->parent_premise[i].dose_range,5)
   FOR (l = 1 TO dose_range_cnt)
     SET haschanged = false
     SET insert_ind = false
     IF ((request->parent_premise[i].dose_range[l].long_text_id=0.0)
      AND trim(request->parent_premise[i].dose_range[l].long_text) > " ")
      SET insert_ind = true
      SELECT INTO "nl:"
       y = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        request->parent_premise[i].dose_range[l].long_text_id = cnvtint(y)
       WITH format, nocounter
      ;end select
      CALL echo(build("Inserting into long_text table:",request->parent_premise[i].dose_range[l].
        long_text_id))
      INSERT  FROM long_text lt
       SET lt.long_text_id = request->parent_premise[i].dose_range[l].long_text_id, lt.long_text =
        trim(request->parent_premise[i].dose_range[l].long_text), lt.active_ind = request->
        parent_premise[i].dose_range[l].active_ind,
        lt.updt_id = reqinfo->updt_id, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = 0,
        lt.updt_task = reqinfo->updt_task, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt
        .parent_entity_name = "DRC_TEXT",
        lt.parent_entity_id = 0, lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt
        .active_status_prsnl_id = reqinfo->updt_id
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = "T"
       SET reply->error_string = "Could not insert into long text table"
       SET reply->status_data.subeventstatus[1].operationname = "insert"
       GO TO exit_script
      ENDIF
     ENDIF
     IF ((request->parent_premise[i].dose_range[l].long_text_id > 0.0)
      AND insert_ind=false)
      CALL echo(build("Searching in long_text table:",request->parent_premise[i].dose_range[l].
        long_text_id))
      SELECT INTO "nl:"
       lt.active_ind, lt.long_text
       FROM long_text lt
       PLAN (lt
        WHERE (lt.long_text_id=request->parent_premise[i].dose_range[l].long_text_id))
       HEAD REPORT
        haschanged = false
       DETAIL
        IF ((((request->parent_premise[i].dose_range[l].active_ind != lt.active_ind)) OR (trim(
         request->parent_premise[i].dose_range[l].long_text) != lt.long_text)) )
         haschanged = true
        ENDIF
       WITH nocounter, maxread(lt,1)
      ;end select
      IF (curqual=0)
       SET failed = "T"
       SET reply->error_string = "Could not find premise_id"
       SET reply->status_data.subeventstatus[1].operationname = "get"
       GO TO exit_script
      ENDIF
      IF (haschanged=true)
       IF (trim(request->parent_premise[i].dose_range[l].long_text) > " ")
        CALL echo(build("Updating in long_text table:",request->parent_premise[i].dose_range[l].
          long_text_id))
        UPDATE  FROM long_text lt
         SET lt.long_text = trim(request->parent_premise[i].dose_range[l].long_text), lt.active_ind
           = request->parent_premise[i].dose_range[l].active_ind, lt.updt_id = reqinfo->updt_id,
          lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_task =
          reqinfo->updt_task,
          lt.updt_dt_tm = cnvtdatetime(curdate,curtime3)
         WHERE (lt.long_text_id=request->parent_premise[i].dose_range[l].long_text_id)
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET failed = "T"
         SET reply->error_string = "Could not update into long text table"
         SET reply->status_data.subeventstatus[1].operationname = "update"
         GO TO exit_script
        ENDIF
       ELSE
        SET request->parent_premise[i].dose_range[l].long_text_id = 0.0
       ENDIF
      ELSE
       CALL echo(build("Not updating in long_text table:",request->parent_premise[i].dose_range[l].
         long_text_id))
      ENDIF
     ENDIF
     SET haschanged = false
     SET insert_ind = false
     IF ((request->parent_premise[i].dose_range[l].drc_dose_range_id=0.0))
      SELECT INTO "nl:"
       ddr.drc_dose_range_id
       FROM drc_dose_range ddr
       WHERE (ddr.drc_premise_id=request->parent_premise[i].parent_premise_id)
        AND (ddr.type_flag=request->parent_premise[i].dose_range[l].type_flag)
        AND (ddr.value_unit_cd=request->parent_premise[i].dose_range[l].value_unit_cd)
       DETAIL
        request->parent_premise[i].dose_range[l].drc_dose_range_id = ddr.drc_dose_range_id
       WITH nocounter
      ;end select
     ENDIF
     IF ((request->parent_premise[i].dose_range[l].drc_dose_range_id=0.0))
      SET insert_ind = true
      SET nxt_seq = 0
      SET request->parent_premise[i].dose_range[l].drc_dose_range_id = get_next_seq(nxt_seq)
      CALL echo(build("Inserting into drc_dose_range table:",request->parent_premise[i].dose_range[l]
        .drc_dose_range_id))
      INSERT  FROM drc_dose_range ddr
       SET ddr.drc_dose_range_id = request->parent_premise[i].dose_range[l].drc_dose_range_id, ddr
        .drc_premise_id = request->parent_premise[i].parent_premise_id, ddr.min_value = request->
        parent_premise[i].dose_range[l].min_value,
        ddr.max_value = request->parent_premise[i].dose_range[l].max_value, ddr.value_unit_cd =
        request->parent_premise[i].dose_range[l].value_unit_cd, ddr.type_flag = request->
        parent_premise[i].dose_range[l].type_flag,
        ddr.long_text_id = request->parent_premise[i].dose_range[l].long_text_id, ddr.active_ind =
        request->parent_premise[i].dose_range[l].active_ind, ddr.dose_days = request->parent_premise[
        i].dose_range[l].dose_days,
        ddr.min_variance_pct = (request->parent_premise[i].dose_range[l].min_value_variance/ 100),
        ddr.max_variance_pct = (request->parent_premise[i].dose_range[l].max_value_variance/ 100),
        ddr.max_dose = request->parent_premise[i].dose_range[l].max_dose,
        ddr.max_dose_unit_cd = request->parent_premise[i].dose_range[l].max_dose_unit_cd, ddr
        .custom_ind = 1, ddr.updt_applctx = reqinfo->updt_applctx,
        ddr.updt_cnt = 0, ddr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ddr.updt_id = reqinfo->
        updt_id,
        ddr.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = "T"
       SET reply->error_string = "Could not insert into drc_dose_range table"
       SET reply->status_data.subeventstatus[1].operationname = "insert"
       GO TO exit_script
      ENDIF
     ELSE
      CALL echo(build("Searching in drc_dose_range table:",request->parent_premise[i].dose_range[l].
        drc_dose_range_id))
      SELECT INTO "nl:"
       ddr.active_ind, ddr.drc_premise_id, ddr.long_text_id,
       ddr.max_value, ddr.max_variance_pct, ddr.min_value,
       ddr.min_variance_pct, ddr.max_dose, ddr.max_dose_unit_cd,
       ddr.type_flag, ddr.value_unit_cd
       FROM drc_dose_range ddr
       PLAN (ddr
        WHERE (ddr.drc_dose_range_id=request->parent_premise[i].dose_range[l].drc_dose_range_id))
       HEAD REPORT
        haschanged = false
       DETAIL
        IF ((((request->parent_premise[i].dose_range[l].active_ind != ddr.active_ind)) OR ((((request
        ->parent_premise[i].parent_premise_id != ddr.drc_premise_id)) OR ((((request->parent_premise[
        i].dose_range[l].long_text_id != ddr.long_text_id)) OR ((((request->parent_premise[i].
        dose_range[l].max_value != ddr.max_value)) OR (((((request->parent_premise[i].dose_range[l].
        max_value_variance/ 100) != ddr.max_variance_pct)) OR ((((request->parent_premise[i].
        dose_range[l].min_value != ddr.min_value)) OR (((((request->parent_premise[i].dose_range[l].
        min_value_variance/ 100) != ddr.min_variance_pct)) OR ((((request->parent_premise[i].
        dose_range[l].max_dose != ddr.max_dose)) OR ((((request->parent_premise[i].dose_range[l].
        max_dose_unit_cd != ddr.max_dose_unit_cd)) OR ((((request->parent_premise[i].dose_range[l].
        type_flag != ddr.type_flag)) OR ((((request->parent_premise[i].dose_range[l].value_unit_cd
         != ddr.value_unit_cd)) OR ((ddr.dose_days != request->parent_premise[i].dose_range[l].
        dose_days))) )) )) )) )) )) )) )) )) )) )) )
         haschanged = true
        ENDIF
       WITH nocounter, maxread(ddr,1)
      ;end select
      IF (curqual=0)
       SET failed = "T"
       SET reply->error_string = "Could not find drc_dose_range_id"
       SET reply->status_data.subeventstatus[1].operationname = "get"
       GO TO exit_script
      ENDIF
      IF (haschanged=true)
       CALL echo(build("Updating in drc_dose_range table:",request->parent_premise[i].dose_range[l].
         drc_dose_range_id))
       UPDATE  FROM drc_dose_range ddr
        SET ddr.min_value = request->parent_premise[i].dose_range[l].min_value, ddr.min_variance_pct
          = (request->parent_premise[i].dose_range[l].min_value_variance/ 100.00), ddr.max_value =
         request->parent_premise[i].dose_range[l].max_value,
         ddr.max_variance_pct = (request->parent_premise[i].dose_range[l].max_value_variance/ 100.00),
         ddr.value_unit_cd = request->parent_premise[i].dose_range[l].value_unit_cd, ddr.max_dose =
         request->parent_premise[i].dose_range[l].max_dose,
         ddr.max_dose_unit_cd = request->parent_premise[i].dose_range[l].max_dose_unit_cd, ddr
         .type_flag = request->parent_premise[i].dose_range[l].type_flag, ddr.long_text_id = request
         ->parent_premise[i].dose_range[l].long_text_id,
         ddr.active_ind = request->parent_premise[i].dose_range[l].active_ind, ddr.drc_premise_id =
         request->parent_premise[i].parent_premise_id, ddr.dose_days = request->parent_premise[i].
         dose_range[l].dose_days,
         ddr.custom_ind = 1, ddr.updt_applctx = reqinfo->updt_applctx, ddr.updt_cnt = (ddr.updt_cnt+
         1),
         ddr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ddr.updt_id = reqinfo->updt_id, ddr
         .updt_task = reqinfo->updt_task
        WHERE (ddr.drc_dose_range_id=request->parent_premise[i].dose_range[l].drc_dose_range_id)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET reply->error_string = "Could not update drc_dose_range table"
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "update"
        GO TO exit_script
       ENDIF
      ELSE
       CALL echo(build("Not updating in drc_dose_range table:",request->parent_premise[i].dose_range[
         l].drc_dose_range_id))
      ENDIF
     ENDIF
     IF (((haschanged=true) OR (insert_ind=true)) )
      SET v_ver_seq = 0
      SELECT INTO "nl:"
       temp_seq = max(ddrv.ver_seq)
       FROM drc_dose_range_ver ddrv
       WHERE (ddrv.drc_dose_range_id=request->parent_premise[i].dose_range[l].drc_dose_range_id)
       DETAIL
        v_ver_seq = (temp_seq+ 1)
       WITH nocounter
      ;end select
      CALL echo(build("Inserting into drc_dose_range_ver table:",request->parent_premise[i].
        dose_range[l].drc_dose_range_id))
      CALL echo(build("Version number:",v_ver_seq))
      INSERT  FROM drc_dose_range_ver ddr
       SET ddr.drc_dose_range_id = request->parent_premise[i].dose_range[l].drc_dose_range_id, ddr
        .drc_premise_id = request->parent_premise[i].parent_premise_id, ddr.min_value = request->
        parent_premise[i].dose_range[l].min_value,
        ddr.min_variance_pct = (request->parent_premise[i].dose_range[1].min_value_variance/ 100),
        ddr.max_value = request->parent_premise[i].dose_range[l].max_value, ddr.max_variance_pct = (
        request->parent_premise[i].dose_range[1].max_value_variance/ 100),
        ddr.value_unit_cd = request->parent_premise[i].dose_range[l].value_unit_cd, ddr.max_dose =
        request->parent_premise[i].dose_range[l].max_dose, ddr.max_dose_unit_cd = request->
        parent_premise[i].dose_range[l].max_dose_unit_cd,
        ddr.type_flag = request->parent_premise[i].dose_range[l].type_flag, ddr.long_text_id =
        request->parent_premise[i].dose_range[l].long_text_id, ddr.active_ind = request->
        parent_premise[i].dose_range[l].active_ind,
        ddr.dose_days = request->parent_premise[i].dose_range[l].dose_days, ddr.ver_seq = v_ver_seq,
        ddr.updt_applctx = reqinfo->updt_applctx,
        ddr.updt_cnt = 0, ddr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ddr.updt_id = reqinfo->
        updt_id,
        ddr.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = "T"
       SET reply->error_string = "Could not insert into drc_dose_range_ver table"
       SET reply->status_data.subeventstatus[1].operationname = "insert"
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM dm_info dm
  WHERE dm.info_domain="KNOWLEDGE INDEX APPLICATIONS"
   AND dm.info_name="DRC_FLEX"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo(build("Checking parents on drc_premise table:",request->dose_range_check_id))
  SELECT INTO "nl:"
   FROM drc_premise dp
   WHERE (dp.dose_range_check_id=request->dose_range_check_id)
    AND dp.parent_ind=1
    AND dp.active_ind=1
   WITH nocounter
  ;end select
  IF (curqual=0)
   UPDATE  FROM drc_facility_r dfac
    SET dfac.active_ind = 0
    WHERE (dfac.dose_range_check_id=request->dose_range_check_id)
     AND dfac.facility_cd > 0.0
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM drc_facility_r dfac
    SET dfac.active_ind = 1
    WHERE (dfac.dose_range_check_id=request->dose_range_check_id)
    WITH nocounter
   ;end update
  ENDIF
 ENDIF
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
#exit_script
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "ErrorMessage"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = substring(1,132,errmsg)
 ENDIF
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET kia_version = "01/12/06 NC011227"
END GO
