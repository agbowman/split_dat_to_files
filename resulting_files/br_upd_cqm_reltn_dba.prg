CREATE PROGRAM br_upd_cqm_reltn:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_upd_cqm_reltn.prg> script"
 DECLARE errmsg = vc WITH protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE provider_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 FREE SET temp
 RECORD temp(
   1 providers[*]
     2 provider_id = f8
     2 br_eligible_provider_id = f8
     2 action_flag = i4
 )
 FREE SET delete_hist
 RECORD delete_hist(
   1 deleted_item[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 DECLARE delete_hist_cnt = i4 WITH noconstant(0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 SELECT INTO "nl:"
  FROM lh_cqm_meas_svc_entity_r cqm,
   br_eligible_provider bep
  PLAN (cqm
   WHERE cqm.parent_entity_name="BR_ELIGIBLE_PROVIDER")
   JOIN (bep
   WHERE cqm.parent_entity_id=outerjoin(bep.provider_id))
  HEAD REPORT
   stat = alterlist(temp->providers,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(temp->providers,(provider_cnt+ 10))
   ENDIF
   provider_cnt = (provider_cnt+ 1), temp->providers[provider_cnt].provider_id = cqm.parent_entity_id
   IF (bep.provider_id=0)
    temp->providers[provider_cnt].action_flag = 3
   ELSE
    temp->providers[provider_cnt].br_eligible_provider_id = bep.br_eligible_provider_id, temp->
    providers[provider_cnt].action_flag = 2
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->providers,provider_cnt)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: selecting br_eligible_provider row: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (provider_cnt > 0)
  UPDATE  FROM lh_cqm_meas_svc_entity_r cqm,
    (dummyt d  WITH seq = value(provider_cnt))
   SET cqm.parent_entity_id = temp->providers[d.seq].br_eligible_provider_id, cqm.updt_dt_tm =
    cnvtdatetime(curdate,curtime3), cqm.updt_id = reqinfo->updt_id,
    cqm.updt_task = reqinfo->updt_task, cqm.updt_applctx = reqinfo->updt_applctx, cqm.updt_cnt = 0
   PLAN (d
    WHERE (temp->providers[d.seq].action_flag=2))
    JOIN (cqm
    WHERE (cqm.parent_entity_id=temp->providers[d.seq].provider_id))
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: updating lh_cqm_meas_svc_entity_r row: ",errmsg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM lh_cqm_meas_svc_entity_r cqm,
    (dummyt d  WITH seq = value(provider_cnt))
   PLAN (d
    WHERE (temp->providers[d.seq].action_flag=3))
    JOIN (cqm
    WHERE (cqm.parent_entity_id=temp->providers[d.seq].provider_id))
   HEAD REPORT
    stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt > 10)
     cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
    ENDIF
    delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
    parent_entity_id = b.lh_cqm_meas_svc_entity_r_id, delete_hist->deleted_item[delete_hist_cnt].
    parent_entity_name = "LH_CQM_MEAS_SVC_ENTITY_R"
   FOOT REPORT
    stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
   WITH nocounter
  ;end select
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: selecting lh_cqm_meas_svc_entity_r row: ",errmsg
    )
   GO TO exit_script
  ENDIF
  DELETE  FROM lh_cqm_meas_svc_entity_r cqm,
    (dummyt d  WITH seq = value(provider_cnt))
   SET seq = 1
   PLAN (d
    WHERE (temp->providers[d.seq].action_flag=3))
    JOIN (cqm
    WHERE (cqm.parent_entity_id=temp->providers[d.seq].provider_id))
   WITH nocounter
  ;end delete
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: deleting lh_cqm_meas_svc_entity_r row: ",errmsg)
   GO TO exit_script
  ENDIF
  IF (delete_hist_cnt > 0)
   INSERT  FROM br_delete_hist his,
     (dummyt d  WITH seq = delete_hist_cnt)
    SET his.br_delete_hist_id = seq(bedrock_seq,nextval), his.parent_entity_name = delete_hist->
     deleted_item[d.seq].parent_entity_name, his.parent_entity_id = delete_hist->deleted_item[d.seq].
     parent_entity_id,
     his.updt_dt_tm = cnvtdatetime(curdate,curtime3), his.updt_id = reqinfo->updt_id, his.updt_task
      = reqinfo->updt_task,
     his.updt_cnt = 0, his.updt_applctx = reqinfo->updt_applctx, his.create_dt_tm = cnvtdatetime(
      curdate,curtime3)
    PLAN (d)
     JOIN (his)
    WITH nocounter
   ;end insert
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: inserting br_delete_hist row: ",errmsg)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_upd_cqm_reltn.prg> script"
#exit_script
 IF (errcode <= 0)
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE SET temp
 FREE SET delete_hist
END GO
