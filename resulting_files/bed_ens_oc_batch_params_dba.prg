CREATE PROGRAM bed_ens_oc_batch_params:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ocnt = 0
 SET ocnt = size(request->olist,5)
 SET dcnt = 0
 SET dcnt = size(request->dlist,5)
 SET scnt = 0
 SET scnt = size(request->slist,5)
 IF ((request->dup_check_ind=1))
  SET ignore_cd = 0.0
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.code_set=6001
    AND cv.cdf_meaning="IGNORE"
   DETAIL
    ignore_cd = cv.code_value
   WITH nocounter
  ;end select
  FOR (o = 1 TO ocnt)
    SET level_1_exists = 0
    SET level_2_exists = 0
    SET level_3_exists = 0
    SET level_1_status = 0
    SET level_2_status = 0
    SET level_3_status = 0
    SELECT INTO "NL:"
     FROM dup_checking dc
     WHERE (dc.catalog_cd=request->olist[o].catalog_cd)
     DETAIL
      IF (dc.dup_check_seq=1)
       level_1_exists = 1, level_1_status = dc.active_ind
      ELSEIF (dc.dup_check_seq=2)
       level_2_exists = 1, level_2_status = dc.active_ind
      ELSEIF (dc.dup_check_seq=3)
       level_3_exists = 1, level_3_status = dc.active_ind
      ENDIF
     WITH nocounter
    ;end select
    SET level_1_updated = 0
    SET level_2_updated = 0
    SET level_3_updated = 0
    FOR (d = 1 TO dcnt)
     IF ((((request->dlist[d].dup_check_level=1)
      AND level_1_exists) OR ((((request->dlist[d].dup_check_level=2)
      AND level_2_exists) OR ((request->dlist[d].dup_check_level=3)
      AND level_3_exists)) )) )
      UPDATE  FROM dup_checking dc
       SET dc.min_behind_action_cd = request->dlist[d].look_behind_action_cd, dc.min_behind = request
        ->dlist[d].look_behind_minutes, dc.min_ahead_action_cd = request->dlist[d].
        look_ahead_action_cd,
        dc.min_ahead = request->dlist[d].look_ahead_minutes, dc.exact_hit_action_cd = request->dlist[
        d].exact_match_action_cd, dc.active_ind = 1,
        dc.updt_cnt = (dc.updt_cnt+ 1), dc.updt_id = reqinfo->updt_id, dc.updt_dt_tm = cnvtdatetime(
         curdate,curtime),
        dc.updt_task = reqinfo->updt_task, dc.updt_applctx = reqinfo->updt_applctx
       WHERE (dc.catalog_cd=request->olist[o].catalog_cd)
        AND (dc.dup_check_seq=request->dlist[d].dup_check_level)
       WITH nocounter
      ;end update
     ELSE
      INSERT  FROM dup_checking dc
       SET dc.catalog_cd = request->olist[o].catalog_cd, dc.dup_check_seq = request->dlist[d].
        dup_check_level, dc.min_behind = request->dlist[d].look_behind_minutes,
        dc.min_behind_action_cd = request->dlist[d].look_behind_action_cd, dc.min_ahead = request->
        dlist[d].look_ahead_minutes, dc.min_ahead_action_cd = request->dlist[d].look_ahead_action_cd,
        dc.active_ind = 1, dc.updt_dt_tm = cnvtdatetime(curdate,curtime), dc.updt_id = reqinfo->
        updt_id,
        dc.updt_task = reqinfo->updt_task, dc.updt_cnt = 0, dc.updt_applctx = reqinfo->updt_applctx,
        dc.exact_hit_action_cd = request->dlist[d].exact_match_action_cd, dc
        .outpat_exact_hit_action_cd = ignore_cd, dc.outpat_flex_ind = 0,
        dc.outpat_min_ahead = 0, dc.outpat_min_ahead_action_cd = ignore_cd, dc.outpat_min_behind = 0,
        dc.outpat_min_behind_action_cd = ignore_cd
       WITH nocounter
      ;end insert
     ENDIF
     IF ((request->dlist[d].dup_check_level=1))
      SET level_1_updated = 1
     ELSEIF ((request->dlist[d].dup_check_level=2))
      SET level_2_updated = 1
     ELSEIF ((request->dlist[d].dup_check_level=3))
      SET level_3_updated = 1
     ENDIF
    ENDFOR
    IF (level_1_updated=0
     AND level_1_exists=1
     AND level_1_status=1)
     UPDATE  FROM dup_checking dc
      SET dc.active_ind = 0, dc.updt_cnt = (dc.updt_cnt+ 1), dc.updt_id = reqinfo->updt_id,
       dc.updt_dt_tm = cnvtdatetime(curdate,curtime), dc.updt_task = reqinfo->updt_task, dc
       .updt_applctx = reqinfo->updt_applctx
      WHERE (dc.catalog_cd=request->olist[o].catalog_cd)
       AND dc.dup_check_seq=1
      WITH nocounter
     ;end update
    ENDIF
    IF (level_2_updated=0
     AND level_2_exists=1
     AND level_2_status=1)
     UPDATE  FROM dup_checking dc
      SET dc.active_ind = 0, dc.updt_cnt = (dc.updt_cnt+ 1), dc.updt_id = reqinfo->updt_id,
       dc.updt_dt_tm = cnvtdatetime(curdate,curtime), dc.updt_task = reqinfo->updt_task, dc
       .updt_applctx = reqinfo->updt_applctx
      WHERE (dc.catalog_cd=request->olist[o].catalog_cd)
       AND dc.dup_check_seq=2
      WITH nocounter
     ;end update
    ENDIF
    IF (level_3_updated=0
     AND level_3_exists=1
     AND level_3_status=1)
     UPDATE  FROM dup_checking dc
      SET dc.active_ind = 0, dc.updt_cnt = (dc.updt_cnt+ 1), dc.updt_id = reqinfo->updt_id,
       dc.updt_dt_tm = cnvtdatetime(curdate,curtime), dc.updt_task = reqinfo->updt_task, dc
       .updt_applctx = reqinfo->updt_applctx
      WHERE (dc.catalog_cd=request->olist[o].catalog_cd)
       AND dc.dup_check_seq=3
      WITH nocounter
     ;end update
    ENDIF
    SET dup_check_exists = 0
    SELECT INTO "NL:"
     FROM dup_checking dc
     WHERE (dc.catalog_cd=request->olist[o].catalog_cd)
      AND dc.active_ind=1
     DETAIL
      dup_check_exists = 1
     WITH nocounter
    ;end select
    UPDATE  FROM order_catalog oc
     SET oc.dup_checking_ind = dup_check_exists, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_id = reqinfo
      ->updt_id,
      oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task = reqinfo->updt_task, oc
      .updt_applctx = reqinfo->updt_applctx
     WHERE (oc.catalog_cd=request->olist[o].catalog_cd)
     WITH nocounter
    ;end update
  ENDFOR
 ENDIF
 IF ((((request->clin_cat_ind=1)) OR ((request->sched_params_ind=1))) )
  FOR (o = 1 TO ocnt)
    IF ((request->clin_cat_ind=1)
     AND (request->sched_params_ind=1))
     UPDATE  FROM order_catalog oc
      SET oc.dcp_clin_cat_cd = request->clin_cat_cd, oc.schedule_ind = request->schedulable_ind, oc
       .updt_cnt = (oc.updt_cnt+ 1),
       oc.updt_id = reqinfo->updt_id, oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task =
       reqinfo->updt_task,
       oc.updt_applctx = reqinfo->updt_applctx
      WHERE (oc.catalog_cd=request->olist[o].catalog_cd)
      WITH nocounter
     ;end update
    ELSEIF ((request->clin_cat_ind=1)
     AND (request->sched_params_ind=0))
     UPDATE  FROM order_catalog oc
      SET oc.dcp_clin_cat_cd = request->clin_cat_cd, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_id =
       reqinfo->updt_id,
       oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task = reqinfo->updt_task, oc
       .updt_applctx = reqinfo->updt_applctx
      WHERE (oc.catalog_cd=request->olist[o].catalog_cd)
      WITH nocounter
     ;end update
    ELSEIF ((request->clin_cat_ind=0)
     AND (request->sched_params_ind=1))
     UPDATE  FROM order_catalog oc
      SET oc.schedule_ind = request->schedulable_ind, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_id =
       reqinfo->updt_id,
       oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task = reqinfo->updt_task, oc
       .updt_applctx = reqinfo->updt_applctx
      WHERE (oc.catalog_cd=request->olist[o].catalog_cd)
      WITH nocounter
     ;end update
    ENDIF
  ENDFOR
 ENDIF
 IF ((request->clin_cat_ind=1))
  FOR (o = 1 TO ocnt)
    UPDATE  FROM order_catalog_synonym ocs
     SET ocs.dcp_clin_cat_cd = request->clin_cat_cd, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_id =
      reqinfo->updt_id,
      ocs.updt_dt_tm = cnvtdatetime(curdate,curtime), ocs.updt_task = reqinfo->updt_task, ocs
      .updt_applctx = reqinfo->updt_applctx
     WHERE (ocs.catalog_cd=request->olist[o].catalog_cd)
     WITH nocounter
    ;end update
  ENDFOR
 ENDIF
 IF ((request->sched_params_ind=1))
  FOR (o = 1 TO ocnt)
   DELETE  FROM dcp_entity_reltn der
    WHERE (der.entity1_id=request->olist[o].catalog_cd)
     AND der.entity_reltn_mean="ORC/SCHENCTP"
    WITH nocounter
   ;end delete
   FOR (s = 1 TO scnt)
     SET ent_rel_id = 0.0
     SELECT INTO "nl:"
      z = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       ent_rel_id = cnvtreal(z)
      WITH format, nocounter
     ;end select
     INSERT  FROM dcp_entity_reltn der
      SET der.dcp_entity_reltn_id = ent_rel_id, der.entity_reltn_mean = "ORC/SCHENCTP", der
       .entity1_id = request->olist[o].catalog_cd,
       der.entity1_display = null, der.entity2_id = request->slist[s].pat_type_cd, der
       .entity2_display = null,
       der.rank_sequence = 0, der.active_ind = 1, der.begin_effective_dt_tm = cnvtdatetime(curdate,
        curtime3),
       der.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), der.updt_dt_tm =
       cnvtdatetime(curdate,curtime), der.updt_id = reqinfo->updt_id,
       der.updt_task = reqinfo->updt_task, der.updt_cnt = 0, der.updt_applctx = reqinfo->updt_applctx,
       der.entity1_name = "CODE_VALUE", der.entity2_name = "CODE_VALUE"
     ;end insert
   ENDFOR
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 CALL echorecord(reply)
END GO
