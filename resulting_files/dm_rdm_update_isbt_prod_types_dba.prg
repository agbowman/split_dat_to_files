CREATE PROGRAM dm_rdm_update_isbt_prod_types:dba
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
 SET readme_data->message = "Readme failed: starting script dm_rdm_update_isbt_prod_types..."
 FREE RECORD isbt
 FREE RECORD attr
 RECORD isbt(
   1 isbt_product_type_list[*]
     2 isbt_product_type_id = f8
 )
 RECORD attr(
   1 attr_info_list[*]
     2 attr_info_id = f8
 )
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE icnt = i4 WITH protect, noconstant(0)
 DECLARE acnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  bipt.bb_isbt_product_type_id
  FROM bb_isbt_product_type bipt,
   product_index pi
  PLAN (bipt
   WHERE bipt.active_ind=1)
   JOIN (pi
   WHERE pi.active_ind=0
    AND bipt.product_cd=pi.product_cd)
  ORDER BY bipt.bb_isbt_product_type_id
  HEAD REPORT
   icnt = 0
  HEAD bipt.bb_isbt_product_type_id
   icnt += 1
   IF (mod(icnt,10)=1)
    stat = alterlist(isbt->isbt_product_type_list,(icnt+ 9))
   ENDIF
   isbt->isbt_product_type_list[icnt].isbt_product_type_id = bipt.bb_isbt_product_type_id
  FOOT  bipt.bb_isbt_product_type_id
   null
  FOOT REPORT
   stat = alterlist(isbt->isbt_product_type_list,icnt)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to Select from bb_isbt_product_type",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  UPDATE  FROM (dummyt d1  WITH seq = value(size(isbt->isbt_product_type_list,5))),
    bb_isbt_product_type bipt
   SET bipt.active_ind = 0, bipt.active_status_cd = reqdata->inactive_status_cd, bipt
    .active_status_dt_tm = cnvtdatetime(sysdate),
    bipt.active_status_prsnl_id = reqinfo->updt_id, bipt.updt_cnt = (bipt.updt_cnt+ 1), bipt
    .updt_dt_tm = cnvtdatetime(sysdate),
    bipt.updt_id = reqinfo->updt_id, bipt.updt_task = reqinfo->updt_task, bipt.updt_applctx = reqinfo
    ->updt_applctx
   PLAN (d1)
    JOIN (bipt
    WHERE (bipt.bb_isbt_product_type_id=isbt->isbt_product_type_list[d1.seq].isbt_product_type_id))
  ;end update
  IF (error(errmsg,0) > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update bb_isbt_product_type :",errmsg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   bia.bb_isbt_add_info_id
   FROM (dummyt d1  WITH seq = value(size(isbt->isbt_product_type_list,5))),
    bb_isbt_add_info bia
   PLAN (d1)
    JOIN (bia
    WHERE (bia.bb_isbt_product_type_id=isbt->isbt_product_type_list[d1.seq].isbt_product_type_id)
     AND bia.active_ind=1)
   ORDER BY bia.bb_isbt_add_info_id
   HEAD REPORT
    acnt = 0
   HEAD bia.bb_isbt_add_info_id
    acnt += 1
    IF (mod(acnt,10)=1)
     stat = alterlist(attr->attr_info_list,(acnt+ 9))
    ENDIF
    attr->attr_info_list[acnt].attr_info_id = bia.bb_isbt_add_info_id
   FOOT  bia.bb_isbt_add_info_id
    null
   FOOT REPORT
    stat = alterlist(attr->attr_info_list,acnt)
   WITH nocounter
  ;end select
  IF (error(errmsg,0) > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to Select from bb_isbt_add_info: ",errmsg)
   GO TO exit_script
  ENDIF
  IF (curqual > 0)
   UPDATE  FROM (dummyt d1  WITH seq = value(size(attr->attr_info_list,5))),
     bb_isbt_add_info bia
    SET bia.active_ind = 0, bia.active_status_cd = reqdata->inactive_status_cd, bia
     .active_status_dt_tm = cnvtdatetime(sysdate),
     bia.active_status_prsnl_id = reqinfo->updt_id, bia.updt_cnt = (bia.updt_cnt+ 1), bia.updt_dt_tm
      = cnvtdatetime(sysdate),
     bia.updt_id = reqinfo->updt_id, bia.updt_task = reqinfo->updt_task, bia.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d1)
     JOIN (bia
     WHERE (bia.bb_isbt_add_info_id=attr->attr_info_list[d1.seq].attr_info_id))
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update bb_isbt_add_info:",errmsg)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 FREE RECORD isbt
 FREE RECORD attr
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
