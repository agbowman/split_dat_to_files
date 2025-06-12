CREATE PROGRAM br_run_dmart_filter_flu:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_run_dmart_filter_flu> script"
 FREE SET idstodelete
 RECORD idstodelete(
   1 deleted_items[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 DECLARE vparse = vc WITH protect
 DECLARE delete_hist_cnt = i4 WITH protect
 DECLARE cat_id = f8 WITH protect
 DECLARE filter_id = f8 WITH protect
 DECLARE prsnl_field_found = i4 WITH protect
 DECLARE br_datamart_value_field_found = i4 WITH protect
 DECLARE data_partition_ind = i4 WITH protect
 DECLARE errcode = i4 WITH protect
 DECLARE errmsg = vc WITH protect
 SET vparse = "bv.br_datamart_filter_id = filter_id"
 SET data_partition_ind = 0
 SET br_datamart_value_field_found = 0
 RANGE OF b IS br_datamart_value
 SET br_datamart_value_field_found = validate(b.logical_domain_id,0)
 FREE RANGE b
 SET prsnl_field_found = 0
 RANGE OF p IS prsnl
 SET prsnl_field_found = validate(p.logical_domain_id,0)
 FREE RANGE p
 IF (prsnl_field_found=1
  AND br_datamart_value_field_found=1)
  SET data_partition_ind = 1
 ENDIF
 IF (data_partition_ind=1)
  IF (validate(ld_concept_person)=0)
   DECLARE ld_concept_person = i2 WITH public, constant(1)
  ENDIF
  IF (validate(ld_concept_prsnl)=0)
   DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
  ENDIF
  IF (validate(ld_concept_organization)=0)
   DECLARE ld_concept_organization = i2 WITH public, constant(3)
  ENDIF
  IF (validate(ld_concept_healthplan)=0)
   DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
  ENDIF
  IF (validate(ld_concept_alias_pool)=0)
   DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
  ENDIF
  IF (validate(ld_concept_minvalue)=0)
   DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
  ENDIF
  IF (validate(ld_concept_maxvalue)=0)
   DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
  ENDIF
  RECORD acm_get_curr_logical_domain_req(
    1 concept = i4
  )
  RECORD acm_get_curr_logical_domain_rep(
    1 logical_domain_id = f8
    1 status_block
      2 status_ind = i2
      2 error_code = i4
  )
  SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
  EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
  replace("REPLY",acm_get_curr_logical_domain_rep)
  SET vparse = build(vparse," and bv.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
 ENDIF
 SET cat_id = 0.0
 SET filter_id = 0.0
 SELECT INTO "nl:"
  FROM br_datamart_category b,
   br_datamart_filter f
  PLAN (b
   WHERE b.category_mean="INFLUENZA")
   JOIN (f
   WHERE f.br_datamart_category_id=b.br_datamart_category_id
    AND f.filter_mean="FLU_VACC_STATUS")
  DETAIL
   cat_id = b.br_datamart_category_id, filter_id = f.br_datamart_filter_id
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Readme Failed: Selecting br_datamart_category and br_datamart_filter rows:",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  SET delete_hist_cnt = 0
  SELECT INTO "nl:"
   FROM br_datamart_value bv
   PLAN (bv
    WHERE bv.br_datamart_category_id=cat_id
     AND parser(vparse))
   HEAD REPORT
    delete_hist_cnt = 0, stat = alterlist(idstodelete->deleted_items,50)
   HEAD bv.br_datamart_value_id
    delete_hist_cnt = (delete_hist_cnt+ 1)
    IF (mod(delete_hist_cnt,50)=1)
     stat = alterlist(idstodelete->deleted_items,(delete_hist_cnt+ 49))
    ENDIF
    idstodelete->deleted_items[delete_hist_cnt].parent_entity_id = bv.br_datamart_value_id,
    idstodelete->deleted_items[delete_hist_cnt].parent_entity_name = "BR_DATAMART_VALUE"
   FOOT REPORT
    stat = alterlist(idstodelete->deleted_items,delete_hist_cnt)
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: Selecting br_datamart_value rows: ",errmsg)
   GO TO exit_script
  ENDIF
  DELETE  FROM br_datamart_value bv
   SET bv.seq = 1
   PLAN (bv
    WHERE bv.br_datamart_category_id=cat_id
     AND parser(vparse))
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: Deleting br_datamart_value rows: ",errmsg)
   GO TO exit_script
  ENDIF
  IF (delete_hist_cnt > 0)
   DELETE  FROM br_delete_hist b
    PLAN (b
     WHERE b.br_delete_hist_id != 0.0
      AND b.create_dt_tm < cnvtlookbehind("4, M"))
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Deleting br_delete_hist rows: ",errmsg)
    GO TO exit_script
   ENDIF
   INSERT  FROM br_delete_hist his,
     (dummyt d  WITH seq = value(delete_hist_cnt))
    SET his.br_delete_hist_id = seq(bedrock_seq,nextval), his.parent_entity_name = idstodelete->
     deleted_items[d.seq].parent_entity_name, his.parent_entity_id = idstodelete->deleted_items[d.seq
     ].parent_entity_id,
     his.updt_dt_tm = cnvtdatetime(curdate,curtime3), his.updt_id = reqinfo->updt_id, his.updt_task
      = reqinfo->updt_task,
     his.updt_cnt = 0, his.updt_applctx = reqinfo->updt_applctx, his.create_dt_tm = cnvtdatetime(
      curdate,curtime3)
    PLAN (d)
     JOIN (his
     WHERE  NOT ( EXISTS (
     (SELECT
      his.parent_entity_id
      FROM br_delete_hist h
      WHERE (h.parent_entity_id=idstodelete->deleted_items[d.seq].parent_entity_id)
       AND (h.parent_entity_name=idstodelete->deleted_items[d.seq].parent_entity_name)))))
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Inserting br_delete_hist rows: ",errmsg)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 EXECUTE dm_dbimport "cer_install:datamart_filter_flu.csv", "br_reg_filter_config", 5000
 IF (errcode=0)
  COMMIT
 ENDIF
#exit_script
 FREE SET idstodelete
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
