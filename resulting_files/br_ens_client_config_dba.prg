CREATE PROGRAM br_ens_client_config:dba
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
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 IF ((request->action_flag > 0))
  SELECT INTO "nl:"
   FROM br_client bc
   PLAN (bc
    WHERE bc.br_client_id=1)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM br_client bc
    SET bc.br_client_name = request->client_name, bc.client_mnemonic = request->client_mnemonic, bc
     .region = request->region,
     bc.updt_dt_tm = cnvtdatetime(curdate,curtime), bc.updt_id = reqinfo->updt_id, bc.updt_task =
     reqinfo->updt_task,
     bc.updt_applctx = reqinfo->updt_applctx, bc.updt_id = (bc.updt_id+ 1)
    WHERE bc.br_client_id=1
    WITH nocounter
   ;end update
  ELSE
   INSERT  FROM br_client bc
    SET bc.br_client_id = 1, bc.br_client_name = request->client_name, bc.client_mnemonic = request->
     client_mnemonic,
     bc.region = request->region, bc.active_ind = 1, bc.active_status_dt_tm = cnvtdatetime(curdate,
      curtime),
     bc.updt_dt_tm = cnvtdatetime(curdate,curtime), bc.updt_id = reqinfo->updt_id, bc.updt_task =
     reqinfo->updt_task,
     bc.updt_applctx = reqinfo->updt_applctx, bc.updt_id = 0
    WITH nocounter
   ;end insert
  ENDIF
  UPDATE  FROM br_name_value bnv
   SET bnv.br_value =
    IF ((request->unknown_age_ind=1)) "1"
    ELSE "0"
    ENDIF
    , bnv.updt_cnt = (bnv.updt_cnt+ 1), bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task = reqinfo
    ->updt_task
   WHERE bnv.br_nv_key1="SYSTEMPARAM"
    AND bnv.br_name="UNKNOWNAGEIND"
    AND bnv.br_client_id=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM br_name_value bnv
    SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "SYSTEMPARAM", bnv.br_name
      = "UNKNOWNAGEIND",
     bnv.br_value =
     IF ((request->unknown_age_ind=1)) "1"
     ELSE "0"
     ENDIF
     , bnv.updt_cnt = 0, bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
     reqinfo->updt_task,
     bnv.br_client_id = 1
    WITH nocounter
   ;end insert
  ENDIF
  UPDATE  FROM br_name_value bnv
   SET bnv.br_value =
    IF ((request->unknown_sex_ind=1)) "1"
    ELSE "0"
    ENDIF
    , bnv.updt_cnt = (bnv.updt_cnt+ 1), bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task = reqinfo
    ->updt_task
   WHERE bnv.br_nv_key1="SYSTEMPARAM"
    AND bnv.br_name="UNKNOWNSEXIND"
    AND bnv.br_client_id=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM br_name_value bnv
    SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "SYSTEMPARAM", bnv.br_name
      = "UNKNOWNSEXIND",
     bnv.br_value =
     IF ((request->unknown_sex_ind=1)) "1"
     ELSE "0"
     ENDIF
     , bnv.updt_cnt = 0, bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
     reqinfo->updt_task,
     bnv.br_client_id = 1
    WITH nocounter
   ;end insert
  ENDIF
  UPDATE  FROM br_name_value bnv
   SET bnv.br_value = evaluate(request->apply_org_security_ind,1,"1","0"), bnv.updt_cnt = (bnv
    .updt_cnt+ 1), bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task = reqinfo
    ->updt_task
   WHERE bnv.br_nv_key1="SYSTEMPARAM"
    AND bnv.br_name="APPLYORGSECURITYIND"
    AND bnv.br_client_id=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM br_name_value bnv
    SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "SYSTEMPARAM", bnv.br_name
      = "APPLYORGSECURITYIND",
     bnv.br_value = evaluate(request->apply_org_security_ind,1,"1","0"), bnv.updt_cnt = 0, bnv
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
     reqinfo->updt_task,
     bnv.br_client_id = 1
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 SET solcnt = 0
 SET solcnt = size(request->sollist,5)
 FOR (x = 1 TO solcnt)
   IF ((request->sollist[x].action_flag > 0))
    IF ((request->sollist[x].live_in_prod_ind=0))
     DELETE  FROM br_name_value bnv
      PLAN (bnv
       WHERE bnv.br_nv_key1="SOLUTION_STATUS"
        AND bnv.br_name="LIVE_IN_PROD"
        AND (bnv.br_value=request->sollist[x].step_cat_mean))
      WITH nocounter
     ;end delete
    ELSE
     SELECT INTO "nl:"
      FROM br_name_value bnv
      PLAN (bnv
       WHERE bnv.br_nv_key1="SOLUTION_STATUS"
        AND bnv.br_name="LIVE_IN_PROD"
        AND (bnv.br_value=request->sollist[x].step_cat_mean))
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM br_name_value bnv
       SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "SOLUTION_STATUS", bnv
        .br_name = "LIVE_IN_PROD",
        bnv.br_value = request->sollist[x].step_cat_mean, bnv.br_client_id = 1, bnv.updt_cnt = 0,
        bnv.updt_dt_tm = cnvtdatetime(curdate,curtime), bnv.updt_id = reqinfo->updt_id, bnv.updt_task
         = reqinfo->updt_task,
        bnv.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
    IF ((request->sollist[x].going_live_ind=0))
     DELETE  FROM br_name_value bnv
      PLAN (bnv
       WHERE bnv.br_nv_key1="SOLUTION_STATUS"
        AND bnv.br_name="GOING_LIVE"
        AND (bnv.br_value=request->sollist[x].step_cat_mean))
      WITH nocounter
     ;end delete
    ELSE
     SELECT INTO "nl:"
      FROM br_name_value bnv
      PLAN (bnv
       WHERE bnv.br_nv_key1="SOLUTION_STATUS"
        AND bnv.br_name="GOING_LIVE"
        AND (bnv.br_value=request->sollist[x].step_cat_mean))
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM br_name_value bnv
       SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "SOLUTION_STATUS", bnv
        .br_name = "GOING_LIVE",
        bnv.br_value = request->sollist[x].step_cat_mean, bnv.br_client_id = 1, bnv.updt_cnt = 0,
        bnv.updt_dt_tm = cnvtdatetime(curdate,curtime), bnv.updt_id = reqinfo->updt_id, bnv.updt_task
         = reqinfo->updt_task,
        bnv.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET liccnt = 0
 SET liccnt = size(request->liclist,5)
 FOR (x = 1 TO liccnt)
   IF ((request->liclist[x].action_flag > 0))
    UPDATE  FROM br_name_value bnv
     SET bnv.default_selected_ind = request->liclist[x].default_selected_ind, bnv.updt_cnt = (bnv
      .updt_cnt+ 1), bnv.updt_id = reqinfo->updt_id,
      bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_dt_tm =
      cnvtdatetime(curdate,curtime)
     WHERE bnv.br_nv_key1="LICENSE"
      AND (bnv.br_name=request->liclist[x].license_mean)
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM br_name_value bnv
      SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "LICENSE", bnv.br_name =
       request->liclist[x].license_mean,
       bnv.br_value = request->liclist[x].license_display, bnv.default_selected_ind = request->
       liclist[x].default_selected_ind, bnv.updt_cnt = 0,
       bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo
       ->updt_applctx,
       bnv.updt_dt_tm = cnvtdatetime(curdate,curtime)
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
 ENDFOR
 SET rptcnt = 0
 SET rptcnt = size(request->rptlist,5)
 FOR (x = 1 TO rptcnt)
   UPDATE  FROM br_report br
    SET br.sequence = request->rptlist[x].sequence, br.updt_cnt = (br.updt_cnt+ 1), br.updt_id =
     reqinfo->updt_id,
     br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->updt_applctx, br.updt_dt_tm =
     cnvtdatetime(curdate,curtime)
    WHERE (br.br_report_id=request->rptlist[x].br_report_id)
    WITH nocounter
   ;end update
 ENDFOR
 IF ((request->nav_action_flag=0))
  GO TO exit_script
 ENDIF
 DELETE  FROM br_client_sol_step s
  PLAN (s
   WHERE s.solution_mean IN (
   (SELECT
    r.item_mean
    FROM br_client_item_reltn r
    WHERE r.solution_type_flag=0)))
  WITH nocounter
 ;end delete
 DELETE  FROM br_client_item_reltn bcir
  WHERE bcir.item_type IN ("SOLUTION", "STEP")
   AND bcir.solution_type_flag=0
  WITH nocounter
 ;end delete
 SET navcnt = 0
 SET navcnt = size(request->navlist,5)
 FOR (x = 1 TO navcnt)
   SET sol_found = 0
   SELECT INTO "nl:"
    FROM br_client_item_reltn b
    PLAN (b
     WHERE b.item_type="SOLUTION"
      AND (b.item_mean=request->navlist[x].solution_mean))
    DETAIL
     sol_found = 1
    WITH nocounter
   ;end select
   IF (sol_found=0)
    INSERT  FROM br_client_item_reltn bcir
     SET bcir.br_client_item_reltn_id = seq(bedrock_seq,nextval), bcir.br_client_id = 1, bcir
      .item_type = "SOLUTION",
      bcir.item_mean = request->navlist[x].solution_mean, bcir.item_display = request->navlist[x].
      solution_display, bcir.solution_seq = request->navlist[x].sequence,
      bcir.updt_dt_tm = cnvtdatetime(curdate,curtime), bcir.updt_id = reqinfo->updt_id, bcir
      .updt_task = reqinfo->updt_task,
      bcir.updt_applctx = reqinfo->updt_applctx, bcir.updt_cnt = 0
     WITH nocounter
    ;end insert
   ENDIF
   SET wizcnt = 0
   SET wizcnt = size(request->navlist[x].steplist,5)
   FOR (y = 1 TO wizcnt)
     SET step_chg = "N"
     SELECT INTO "nl:"
      FROM br_step bs
      PLAN (bs
       WHERE (bs.step_mean=request->navlist[x].steplist[y].step_mean))
      DETAIL
       IF ((bs.step_disp=request->navlist[x].steplist[y].step_name)
        AND (bs.step_type=request->navlist[x].steplist[y].step_type)
        AND (bs.step_cat_mean=request->navlist[x].steplist[y].step_cat_mean)
        AND (bs.step_cat_disp=request->navlist[x].steplist[y].step_cat_disp))
        step_chg = "N"
       ELSE
        step_chg = "Y"
       ENDIF
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM br_step bs
       SET bs.step_mean = request->navlist[x].steplist[y].step_mean, bs.step_disp = substring(1,40,
         request->navlist[x].steplist[y].step_name), bs.step_type = request->navlist[x].steplist[y].
        step_type,
        bs.step_cat_mean = request->navlist[x].steplist[y].step_cat_mean, bs.step_cat_disp = request
        ->navlist[x].steplist[y].step_cat_disp, bs.est_min_to_complete = request->navlist[x].
        steplist[y].est_min_to_complete,
        bs.default_seq = request->navlist[x].steplist[y].sequence, bs.updt_dt_tm = cnvtdatetime(
         curdate,curtime), bs.updt_task = reqinfo->updt_task,
        bs.updt_id = reqinfo->updt_id, bs.updt_applctx = reqinfo->updt_applctx, bs.updt_cnt = 0
       WITH nocounter
      ;end insert
     ELSEIF (step_chg="Y")
      UPDATE  FROM br_step bs
       SET bs.step_disp = substring(1,40,request->navlist[x].steplist[y].step_name), bs.step_type =
        request->navlist[x].steplist[y].step_type, bs.step_cat_mean = request->navlist[x].steplist[y]
        .step_cat_mean,
        bs.step_cat_disp = request->navlist[x].steplist[y].step_cat_disp, bs.est_min_to_complete =
        request->navlist[x].steplist[y].est_min_to_complete, bs.default_seq = request->navlist[x].
        steplist[y].sequence,
        bs.updt_dt_tm = cnvtdatetime(curdate,curtime), bs.updt_task = reqinfo->updt_task, bs.updt_id
         = reqinfo->updt_id,
        bs.updt_applctx = reqinfo->updt_applctx, bs.updt_cnt = (bs.updt_cnt+ 1)
       WHERE (bs.step_mean=request->navlist[x].steplist[y].step_mean)
       WITH nocounter
      ;end update
     ENDIF
     SET step_found = 0
     SELECT INTO "nl:"
      FROM br_client_item_reltn b
      PLAN (b
       WHERE b.item_type="STEP"
        AND (b.item_mean=request->navlist[x].steplist[y].step_mean))
      DETAIL
       step_found = 1
      WITH nocounter
     ;end select
     IF (step_found=0)
      INSERT  FROM br_client_item_reltn bcir
       SET bcir.br_client_item_reltn_id = seq(bedrock_seq,nextval), bcir.br_client_id = 1, bcir
        .item_type = "STEP",
        bcir.item_mean = request->navlist[x].steplist[y].step_mean, bcir.item_display = request->
        navlist[x].steplist[y].step_name, bcir.status_flag = request->navlist[x].steplist[y].
        status_flag,
        bcir.status_id = reqinfo->updt_id, bcir.status_dt_tm = cnvtdatetime(curdate,curtime), bcir
        .step_cat_mean = request->navlist[x].steplist[y].step_cat_mean,
        bcir.step_cat_disp = request->navlist[x].steplist[y].step_cat_disp, bcir.updt_dt_tm =
        cnvtdatetime(curdate,curtime), bcir.updt_id = reqinfo->updt_id,
        bcir.updt_task = reqinfo->updt_task, bcir.updt_applctx = reqinfo->updt_applctx, bcir.updt_cnt
         = 0
       WITH nocounter
      ;end insert
      INSERT  FROM br_client_sol_step bcss
       SET bcss.br_client_id = 1, bcss.solution_mean = request->navlist[x].solution_mean, bcss
        .step_mean = request->navlist[x].steplist[y].step_mean,
        bcss.sequence = request->navlist[x].steplist[y].sequence, bcss.updt_dt_tm = cnvtdatetime(
         curdate,curtime), bcss.updt_id = reqinfo->updt_id,
        bcss.updt_task = reqinfo->updt_task, bcss.updt_applctx = reqinfo->updt_applctx, bcss.updt_cnt
         = 0
       WITH nocounter
      ;end insert
     ENDIF
   ENDFOR
 ENDFOR
 DECLARE lh_cnt = i4 WITH protect
 IF (validate(request->lighthouse))
  SET lh_cnt = size(request->lighthouse,5)
 ENDIF
 FREE SET lh_wiz
 RECORD lh_wiz(
   1 wiz[*]
     2 action_flag = i2
     2 step_name = vc
     2 step_mean = vc
     2 step_type = vc
     2 sequence = i4
     2 step_cat_mean = vc
     2 step_cat_disp = vc
     2 solution_mean = vc
     2 step_action = i2
 )
 FREE SET lh_sol
 RECORD lh_sol(
   1 sols[*]
     2 action = i2
     2 sol_mean = vc
     2 solution_display = vc
     2 sequence = i4
 )
 DECLARE wiz_cnt = i4 WITH protect
 DECLARE sol_cnt = i4 WITH protect
 FOR (x = 1 TO lh_cnt)
   SET del_ind = 0
   SET wiz_size = size(request->lighthouse[x].lh_steplist,5)
   SET sol_cnt = (sol_cnt+ 1)
   SET stat = alterlist(lh_sol->sols,sol_cnt)
   SET lh_sol->sols[sol_cnt].sol_mean = request->lighthouse[x].solution_mean
   SET lh_sol->sols[sol_cnt].sequence = request->lighthouse[x].sequence
   SET lh_sol->sols[sol_cnt].solution_display = request->lighthouse[x].solution_display
   SET lh_sol->sols[sol_cnt].action = 1
   FOR (y = 1 TO wiz_size)
     SET wiz_cnt = (wiz_cnt+ 1)
     SET stat = alterlist(lh_wiz->wiz,wiz_cnt)
     SET lh_wiz->wiz[wiz_cnt].action_flag = request->lighthouse[x].lh_steplist[y].action_flag
     SET lh_wiz->wiz[wiz_cnt].step_name = request->lighthouse[x].lh_steplist[y].step_name
     SET lh_wiz->wiz[wiz_cnt].step_mean = request->lighthouse[x].lh_steplist[y].step_mean
     SET lh_wiz->wiz[wiz_cnt].step_type = request->lighthouse[x].lh_steplist[y].step_type
     SET lh_wiz->wiz[wiz_cnt].sequence = request->lighthouse[x].lh_steplist[y].sequence
     SET lh_wiz->wiz[wiz_cnt].step_cat_mean = request->lighthouse[x].lh_steplist[y].step_cat_mean
     SET lh_wiz->wiz[wiz_cnt].step_cat_disp = request->lighthouse[x].lh_steplist[y].step_cat_disp
     SET lh_wiz->wiz[wiz_cnt].solution_mean = request->lighthouse[x].solution_mean
     SET lh_wiz->wiz[wiz_cnt].step_action = 1
     IF ((request->lighthouse[x].lh_steplist[y].action_flag=3))
      SET del_ind = 1
     ENDIF
   ENDFOR
   IF (del_ind=1)
    SET lh_sol->sols[sol_cnt].action = 3
   ENDIF
 ENDFOR
 IF (wiz_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(wiz_cnt)),
    br_step bs
   PLAN (d)
    JOIN (bs
    WHERE (bs.step_mean=lh_wiz->wiz[d.seq].step_mean))
   DETAIL
    IF ((bs.step_disp=lh_wiz->wiz[d.seq].step_name)
     AND (bs.step_type=lh_wiz->wiz[d.seq].step_type)
     AND (bs.step_cat_mean=lh_wiz->wiz[d.seq].step_cat_mean)
     AND (bs.step_cat_disp=lh_wiz->wiz[d.seq].step_cat_disp))
     lh_wiz->wiz[d.seq].step_action = 0
    ELSE
     lh_wiz->wiz[d.seq].step_action = 2
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("Step Check Error")
  INSERT  FROM br_step bs,
    (dummyt d  WITH seq = value(wiz_cnt))
   SET bs.step_mean = lh_wiz->wiz[d.seq].step_mean, bs.step_disp = substring(1,40,lh_wiz->wiz[d.seq].
     step_name), bs.step_type = lh_wiz->wiz[d.seq].step_type,
    bs.step_cat_mean = lh_wiz->wiz[d.seq].step_cat_mean, bs.step_cat_disp = lh_wiz->wiz[d.seq].
    step_cat_disp, bs.est_min_to_complete = 0,
    bs.default_seq = lh_wiz->wiz[d.seq].sequence, bs.updt_dt_tm = cnvtdatetime(curdate,curtime), bs
    .updt_task = reqinfo->updt_task,
    bs.updt_id = reqinfo->updt_id, bs.updt_applctx = reqinfo->updt_applctx, bs.updt_cnt = 0
   PLAN (d
    WHERE (lh_wiz->wiz[d.seq].step_action=1))
    JOIN (bs)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Step Insert Error")
  UPDATE  FROM br_step bs,
    (dummyt d  WITH seq = value(wiz_cnt))
   SET bs.step_disp = substring(1,40,lh_wiz->wiz[d.seq].step_name), bs.step_type = lh_wiz->wiz[d.seq]
    .step_type, bs.step_cat_mean = lh_wiz->wiz[d.seq].step_cat_mean,
    bs.step_cat_disp = lh_wiz->wiz[d.seq].step_cat_disp, bs.default_seq = lh_wiz->wiz[d.seq].sequence,
    bs.updt_dt_tm = cnvtdatetime(curdate,curtime),
    bs.updt_task = reqinfo->updt_task, bs.updt_id = reqinfo->updt_id, bs.updt_applctx = reqinfo->
    updt_applctx,
    bs.updt_cnt = (bs.updt_cnt+ 1)
   PLAN (d
    WHERE (lh_wiz->wiz[d.seq].step_action=2))
    JOIN (bs
    WHERE (bs.step_mean=lh_wiz->wiz[d.seq].step_mean))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Step Update Error")
  INSERT  FROM br_client_item_reltn bcir,
    (dummyt d  WITH seq = value(wiz_cnt))
   SET bcir.br_client_item_reltn_id = seq(bedrock_seq,nextval), bcir.br_client_id = 1, bcir.item_type
     = "STEP",
    bcir.item_mean = lh_wiz->wiz[d.seq].step_mean, bcir.item_display = lh_wiz->wiz[d.seq].step_name,
    bcir.status_flag = 0,
    bcir.status_id = reqinfo->updt_id, bcir.solution_type_flag = 1, bcir.status_dt_tm = cnvtdatetime(
     curdate,curtime),
    bcir.step_cat_mean = lh_wiz->wiz[d.seq].step_cat_mean, bcir.step_cat_disp = lh_wiz->wiz[d.seq].
    step_cat_disp, bcir.updt_dt_tm = cnvtdatetime(curdate,curtime),
    bcir.updt_id = reqinfo->updt_id, bcir.updt_task = reqinfo->updt_task, bcir.updt_applctx = reqinfo
    ->updt_applctx,
    bcir.updt_cnt = 0
   PLAN (d
    WHERE (lh_wiz->wiz[d.seq].action_flag=1))
    JOIN (bcir)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Client Insert Error")
  INSERT  FROM br_client_sol_step bcss,
    (dummyt d  WITH seq = value(wiz_cnt))
   SET bcss.br_client_id = 1, bcss.solution_mean = lh_wiz->wiz[d.seq].solution_mean, bcss.step_mean
     = lh_wiz->wiz[d.seq].step_mean,
    bcss.sequence = lh_wiz->wiz[d.seq].sequence, bcss.updt_dt_tm = cnvtdatetime(curdate,curtime),
    bcss.updt_id = reqinfo->updt_id,
    bcss.updt_task = reqinfo->updt_task, bcss.updt_applctx = reqinfo->updt_applctx, bcss.updt_cnt = 0
   PLAN (d
    WHERE (lh_wiz->wiz[d.seq].action_flag=1))
    JOIN (bcss)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Client Sol Insert Error")
  DELETE  FROM br_client_sol_step s,
    (dummyt d  WITH seq = value(wiz_cnt))
   SET s.seq = 1
   PLAN (d
    WHERE (lh_wiz->wiz[d.seq].action_flag=3))
    JOIN (s
    WHERE (s.solution_mean=lh_wiz->wiz[d.seq].solution_mean)
     AND (s.step_mean=lh_wiz->wiz[d.seq].step_mean))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Client Delete Error")
  DELETE  FROM br_client_item_reltn bcir,
    (dummyt d  WITH seq = value(wiz_cnt))
   SET bcir.seq = 1
   PLAN (d
    WHERE (lh_wiz->wiz[d.seq].action_flag=3))
    JOIN (bcir
    WHERE bcir.item_type="STEP"
     AND (bcir.item_mean=lh_wiz->wiz[d.seq].step_mean)
     AND bcir.solution_type_flag=1)
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Client Sol Delete1 Error")
 ENDIF
 IF (sol_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(sol_cnt)),
    br_client_item_reltn b
   PLAN (d)
    JOIN (b
    WHERE b.item_type="SOLUTION"
     AND (b.item_mean=lh_sol->sols[d.seq].sol_mean))
   DETAIL
    IF ((lh_sol->sols[d.seq].action != 3))
     lh_sol->sols[d.seq].action = 2
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("Sol Check Error")
  INSERT  FROM br_client_item_reltn bcir,
    (dummyt d  WITH seq = value(sol_cnt))
   SET bcir.br_client_item_reltn_id = seq(bedrock_seq,nextval), bcir.br_client_id = 1, bcir.item_type
     = "SOLUTION",
    bcir.solution_type_flag = 1, bcir.item_mean = lh_sol->sols[d.seq].sol_mean, bcir.item_display =
    lh_sol->sols[d.seq].solution_display,
    bcir.solution_seq = lh_sol->sols[d.seq].sequence, bcir.updt_dt_tm = cnvtdatetime(curdate,curtime),
    bcir.updt_id = reqinfo->updt_id,
    bcir.updt_task = reqinfo->updt_task, bcir.updt_applctx = reqinfo->updt_applctx, bcir.updt_cnt = 0
   PLAN (d
    WHERE (lh_sol->sols[d.seq].action=1))
    JOIN (bcir)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Sol Insert Error")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(sol_cnt)),
    br_client_sol_step b
   PLAN (d
    WHERE (lh_sol->sols[d.seq].action=3))
    JOIN (b
    WHERE (b.solution_mean=lh_sol->sols[d.seq].sol_mean))
   DETAIL
    lh_sol->sols[d.seq].action = 0
   WITH nocounter
  ;end select
  CALL bederrorcheck("Sol Check Error")
  DELETE  FROM br_client_item_reltn bcir,
    (dummyt d  WITH seq = value(sol_cnt))
   SET bcir.seq = 1
   PLAN (d
    WHERE (lh_sol->sols[d.seq].action=3))
    JOIN (bcir
    WHERE bcir.item_type="SOLUTION"
     AND (bcir.item_mean=lh_sol->sols[d.seq].sol_mean)
     AND bcir.solution_type_flag=1)
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Client Sol Delete Error")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
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
