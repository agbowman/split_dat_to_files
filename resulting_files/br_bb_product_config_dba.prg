CREATE PROGRAM br_bb_product_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_bb_product_config.prg> script"
 FREE RECORD exists_rec
 RECORD exists_rec(
   1 list_0[*]
     2 exists_ind = i2
     2 numeric_min_bef_quar = i4
     2 numeric_max_exp_val = i4
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE numrows = i4
 SET numrows = size(requestin->list_0,5)
 SET stat = alterlist(exists_rec->list_0,numrows)
 SELECT INTO "nl:"
  FROM br_bb_product b,
   (dummyt d  WITH seq = value(numrows))
  PLAN (d)
   JOIN (b
   WHERE (b.display=requestin->list_0[d.seq].display))
  DETAIL
   exists_rec->list_0[d.seq].exists_ind = 1
  WITH nocounter
 ;end select
 FOR (i = 1 TO numrows)
   IF ((exists_rec->list_0[i].exists_ind=0))
    IF ((requestin->list_0[i].max_exp_val > " "))
     SET exists_rec->list_0[i].numeric_max_exp_val = cnvtint(requestin->list_0[i].max_exp_val)
    ENDIF
    IF ((requestin->list_0[i].min_bef_quar > " "))
     SET exists_rec->list_0[i].numeric_min_bef_quar = cnvtint(requestin->list_0[i].min_bef_quar)
    ENDIF
   ENDIF
 ENDFOR
 INSERT  FROM br_bb_product b,
   (dummyt d  WITH seq = value(numrows))
  SET b.product_id = seq(bedrock_seq,nextval), b.display = requestin->list_0[d.seq].display, b
   .description = requestin->list_0[d.seq].description,
   b.selected_ind = 0, b.product_cd = 0.0, b.prodcat_id =
   (SELECT
    bp.prodcat_id
    FROM br_bb_prodcat bp
    WHERE (bp.display=requestin->list_0[d.seq].prodcat_disp)
    WITH maxqual(bp,1)),
   b.bar_code_val = requestin->list_0[d.seq].bar_code_val, b.auto_ind = evaluate(requestin->list_0[d
    .seq].auto_ind,"Y",1,0), b.directed_ind = evaluate(requestin->list_0[d.seq].directed_ind,"Y",1,0),
   b.max_exp_unit = requestin->list_0[d.seq].max_exp_unit, b.max_exp_val = exists_rec->list_0[d.seq].
   numeric_max_exp_val, b.calc_exp_from_draw_ind = evaluate(requestin->list_0[d.seq].
    calc_exp_from_draw_ind,"Y",1,0),
   b.volume_def = evaluate(requestin->list_0[d.seq].volume_def,"Y",1,0), b.def_supplier = requestin->
   list_0[d.seq].def_supplier, b.aborh_conf_test_name = requestin->list_0[d.seq].aborh_conf_test_name,
   b.dispense_ind = evaluate(requestin->list_0[d.seq].dispense_ind,"Y",1,0), b.min_bef_quar =
   exists_rec->list_0[d.seq].numeric_min_bef_quar, b.validate_antibody_ind = evaluate(requestin->
    list_0[d.seq].validate_antibody_ind,"Y",1,0),
   b.validate_transf_req_ind = evaluate(requestin->list_0[d.seq].validate_transf_req_ind,"Y",1,0), b
   .int_units_ind = evaluate(requestin->list_0[d.seq].int_units_ind,"Y",1,0), b.aliquot_ind =
   evaluate(requestin->list_0[d.seq].aliquot_ind,"Y",1,0),
   b.active_ind = 0, b.autobuild_ind = evaluate(requestin->list_0[d.seq].autobuild_ind,"Y",1,0), b
   .def_storage_temp = requestin->list_0[d.seq].def_storage_temp,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
   ->updt_task,
   b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (exists_rec->list_0[d.seq].exists_ind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Inserting into br_bb_product: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_bb_product_config.prg> script"
#exit_script
 FREE RECORD exists_rec
END GO
