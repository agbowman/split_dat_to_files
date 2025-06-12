CREATE PROGRAM dcp_rdm_plan_synonyms_fav:dba
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
 SET readme_data->message = "Readme failed: starting script dcp_rdm_plan_synonyms_fav..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE syncnt = i4 WITH protect, noconstant(0)
 DECLARE maxid = f8 WITH protect, noconstant(0.0)
 DECLARE minid = f8 WITH protect, noconstant(0.0)
 DECLARE curminid = f8 WITH protect, noconstant(0.0)
 DECLARE curmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE batchsize = i4 WITH protect, noconstant(250000)
 FREE RECORD plandata
 RECORD plandata(
   1 planlist[*]
     2 pathway_catalog_id = f8
     2 pw_cat_synonym_id = f8
 )
 SELECT INTO "nl:"
  minidval = min(asl.alt_sel_category_id)
  FROM alt_sel_list asl
  WHERE asl.alt_sel_category_id > 0
  DETAIL
   minid = maxval(minidval,1.0)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->status = concat("Failed to get minimum ID: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  maxidval = max(asl.alt_sel_category_id)
  FROM alt_sel_list asl
  DETAIL
   maxid = maxidval
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->status = concat("Failed to get maximum ID: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (minid > maxid)
  SET readme_data->status = "S"
  SET readme_data->message = "No work needs to be done; exiting"
  GO TO exit_script
 ENDIF
 SET curminid = minid
 SET curmaxid = ((curminid+ batchsize) - 1)
 WHILE (curminid <= maxid)
   IF (size(plandata->planlist,5) > 0)
    SET stat = alterlist(plandata->planlist,0)
    SET syncnt = 0
   ENDIF
   SELECT INTO "nl:"
    FROM alt_sel_list asl,
     pw_cat_synonym pcs
    PLAN (asl
     WHERE asl.list_type=6
      AND asl.pw_cat_synonym_id=0
      AND asl.alt_sel_category_id BETWEEN curminid AND curmaxid)
     JOIN (pcs
     WHERE pcs.pathway_catalog_id=asl.pathway_catalog_id
      AND pcs.primary_ind=1)
    DETAIL
     syncnt = (syncnt+ 1)
     IF (mod(syncnt,50)=1)
      stat = alterlist(plandata->planlist,(syncnt+ 49))
     ENDIF
     plandata->planlist[syncnt].pathway_catalog_id = pcs.pathway_catalog_id, plandata->planlist[
     syncnt].pw_cat_synonym_id = pcs.pw_cat_synonym_id
    FOOT REPORT
     stat = alterlist(plandata->planlist,syncnt)
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed in collection from ALT_SEL_LIST and PW_CAT_SYNONYM: ",
     errmsg)
    GO TO exit_script
   ELSEIF (syncnt > 0)
    UPDATE  FROM alt_sel_list asl,
      (dummyt d  WITH seq = value(syncnt))
     SET asl.pw_cat_synonym_id = plandata->planlist[d.seq].pw_cat_synonym_id, asl.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), asl.updt_applctx = reqinfo->updt_applctx,
      asl.updt_id = reqinfo->updt_id, asl.updt_task = reqinfo->updt_task, asl.updt_cnt = (asl
      .updt_cnt+ 1)
     PLAN (d)
      JOIN (asl
      WHERE (asl.pathway_catalog_id=plandata->planlist[d.seq].pathway_catalog_id))
     WITH nocounter
    ;end update
    IF (error(errmsg,0) != 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to update ALT_SEL_LIST: ",errmsg)
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET curminid = (curmaxid+ 1)
   SET curmaxid = ((curminid+ batchsize) - 1)
 ENDWHILE
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 FREE RECORD plandata
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
