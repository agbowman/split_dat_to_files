CREATE PROGRAM afc_rdm_upt_bitem_ld_item_mstr:dba
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
 SET readme_data->message = "Readme Failed: Starting script afc_rdm_upt_bitem_ld_item_mstr.prg..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE c13016_itemspacemaster_cd = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="ITEM MASTER"
   AND cv.active_ind=1
  DETAIL
   c13016_itemspacemaster_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = build("Failed to get the code value for ITEM MASTER from Code Set 13016",
   errmsg)
  GO TO end_program
 ENDIF
 IF (c13016_itemspacemaster_cd <= 0.0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: Readme did not find the code value for ITEM MASTER from Code Set 13016"
  GO TO exit_script
 ENDIF
 UPDATE  FROM bill_item bi
  SET bi.logical_domain_id =
   (SELECT
    id.logical_domain_id
    FROM item_definition id
    WHERE id.item_id=bi.ext_parent_reference_id), bi.logical_domain_enabled_ind = 1, bi.updt_applctx
    = reqinfo->updt_applctx,
   bi.updt_cnt = (bi.updt_cnt+ 1), bi.updt_dt_tm = cnvtdatetime(curdate,curtime3), bi.updt_id =
   reqinfo->updt_id,
   bi.updt_task = reqinfo->updt_task
  WHERE bi.bill_item_id > 0.0
   AND  EXISTS (
  (SELECT
   id1.item_id
   FROM item_definition id1
   WHERE id1.item_id=bi.ext_parent_reference_id
    AND bi.ext_parent_contributor_cd=c13016_itemspacemaster_cd))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update BILL_ITEM: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
