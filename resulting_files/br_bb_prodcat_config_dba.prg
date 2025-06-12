CREATE PROGRAM br_bb_prodcat_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_bb_prodcat_config.prg> script"
 FREE RECORD exists_rec
 RECORD exists_rec(
   1 list_0[*]
     2 exist_ind = i2
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE numrows = i4
 SET numrows = size(requestin->list_0,5)
 SET stat = alterlist(exists_rec->list_0,numrows)
 SELECT INTO "nl:"
  FROM br_bb_prodcat b,
   (dummyt d  WITH seq = value(numrows))
  PLAN (d)
   JOIN (b
   WHERE (b.display=requestin->list_0[d.seq].display))
  DETAIL
   exists_rec->list_0[d.seq].exist_ind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_bb_prodcat b,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET b.prodcat_id = seq(bedrock_seq,nextval), b.display = requestin->list_0[d.seq].display, b
   .description = requestin->list_0[d.seq].description,
   b.selected_ind = 0, b.prodcat_cd = 0.0, b.product_class_mean = cnvtupper(requestin->list_0[d.seq].
    product_class_mean),
   b.red_cell_ind = evaluate(requestin->list_0[d.seq].red_cell_ind,"Y",1,0), b.rh_req_ind = evaluate(
    requestin->list_0[d.seq].rh_req_ind,"Y",1,0), b.aborh_conf_req_ind = evaluate(requestin->list_0[d
    .seq].aborh_conf_req_ind,"Y",1,0),
   b.val_compat_ind = evaluate(requestin->list_0[d.seq].val_compat_ind,"Y",1,0), b.xm_req_ind =
   evaluate(requestin->list_0[d.seq].xm_req_ind,"Y",1,0), b.uom_def = requestin->list_0[d.seq].
   uom_def,
   b.ship_cond_def = requestin->list_0[d.seq].ship_cond_def, b.prompt_for_vol_ind = evaluate(
    requestin->list_0[d.seq].prompt_for_vol_ind,"Y",1,0), b.seg_num_ind = evaluate(requestin->list_0[
    d.seq].seg_num_ind,"Y",1,0),
   b.alternate_id_ind = evaluate(requestin->list_0[d.seq].alternate_id_ind,"Y",1,0), b.xm_tag_req_ind
    = evaluate(requestin->list_0[d.seq].xm_tag_req_ind,"Y",1,0), b.comp_tag_req_ind = evaluate(
    requestin->list_0[d.seq].comp_tag_req_ind,"Y",1,0),
   b.pilot_label_req_ind = evaluate(requestin->list_0[d.seq].pilot_label_req_ind,"Y",1,0), b
   .active_ind = 0, b.autobuild_ind = evaluate(requestin->list_0[d.seq].autobuild_ind,"Y",1,0),
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
   ->updt_task,
   b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (exists_rec->list_0[d.seq].exist_ind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme failed: Inserting into br_bb_prodcat: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_bb_prodcat_config.prg> script"
#exit_script
 FREE RECORD exists_rec
END GO
