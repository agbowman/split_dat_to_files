CREATE PROGRAM dcp_rdm_plan_synonyms:dba
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
 SET readme_data->message = "Readme failed: starting script dcp_rdm_plan_synonyms..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE syncnt = i4 WITH protect, noconstant(0)
 DECLARE curdatetime = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 FREE RECORD plandata
 RECORD plandata(
   1 planlist[*]
     2 do_update_ind = i2
     2 do_insert_ind = i2
     2 pathway_catalog_id = f8
     2 pw_cat_synonym_id = f8
     2 display_description = vc
     2 display_description_key = vc
 )
 SELECT INTO "nl:"
  has_syn = negate(nullind(pcs.pathway_catalog_id))
  FROM pathway_catalog pc,
   pw_cat_synonym pcs
  PLAN (pc
   WHERE pc.type_mean IN ("CAREPLAN", "PATHWAY")
    AND ((pc.pathway_catalog_id+ 0) > 0)
    AND pc.beg_effective_dt_tm <= cnvtdatetime(curdatetime)
    AND pc.end_effective_dt_tm >= cnvtdatetime(curdatetime))
   JOIN (pcs
   WHERE pcs.pathway_catalog_id=outerjoin(pc.pathway_catalog_id)
    AND pcs.primary_ind=outerjoin(1))
  DETAIL
   syncnt = (syncnt+ 1)
   IF (mod(syncnt,50)=1)
    stat = alterlist(plandata->planlist,(syncnt+ 49))
   ENDIF
   plandata->planlist[syncnt].pathway_catalog_id = pc.pathway_catalog_id, plandata->planlist[syncnt].
   display_description = pc.display_description, plandata->planlist[syncnt].display_description_key
    = trim(cnvtupper(pc.display_description))
   IF (has_syn=1
    AND pcs.synonym_name != pc.display_description
    AND pcs.primary_ind=1)
    plandata->planlist[syncnt].do_update_ind = 1, plandata->planlist[syncnt].pw_cat_synonym_id = pcs
    .pw_cat_synonym_id
   ELSEIF (has_syn=0)
    plandata->planlist[syncnt].do_insert_ind = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(plandata->planlist,syncnt)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed in collection from PATHWAY_CATALOG: ",errmsg)
  GO TO exit_script
 ELSEIF (syncnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = "No PATHWAY_CATALOG entries found; auto-successing"
  GO TO exit_script
 ENDIF
 UPDATE  FROM pw_cat_synonym pcs,
   (dummyt d  WITH seq = value(syncnt))
  SET pcs.synonym_name = plandata->planlist[d.seq].display_description, pcs.synonym_name_key =
   plandata->planlist[d.seq].display_description_key, pcs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pcs.updt_applctx = reqinfo->updt_applctx, pcs.updt_id = reqinfo->updt_id, pcs.updt_task = reqinfo
   ->updt_task,
   pcs.updt_cnt = (pcs.updt_cnt+ 1)
  PLAN (d
   WHERE (plandata->planlist[d.seq].do_update_ind=1))
   JOIN (pcs
   WHERE (pcs.pw_cat_synonym_id=plandata->planlist[d.seq].pw_cat_synonym_id))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update PW_CAT_SYNONYM: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM pw_cat_synonym pcs,
   (dummyt d  WITH seq = value(syncnt))
  SET pcs.pw_cat_synonym_id = seq(reference_seq,nextval), pcs.pathway_catalog_id = plandata->
   planlist[d.seq].pathway_catalog_id, pcs.synonym_name = plandata->planlist[d.seq].
   display_description,
   pcs.synonym_name_key = plandata->planlist[d.seq].display_description_key, pcs.primary_ind = 1, pcs
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pcs.updt_cnt = 0, pcs.updt_id = reqinfo->updt_id, pcs.updt_task = reqinfo->updt_task,
   pcs.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (plandata->planlist[d.seq].do_insert_ind=1))
   JOIN (pcs)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert into PW_CAT_SYNONYM: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 FREE RECORD plandata
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
