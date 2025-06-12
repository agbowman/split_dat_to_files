CREATE PROGRAM cmn_rdm_stw_updt_rpt_dt_opt:dba
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
 DECLARE createqualifyingdttmsetting(null) = null WITH protect
 DECLARE createdisplaydttmsetting(null) = null WITH protect
 SUBROUTINE createqualifyingdttmsetting(null)
   DECLARE errmsg = vc WITH protect, noconstant("")
   INSERT  FROM br_datamart_value bdv
    (bdv.br_datamart_value_id, bdv.br_datamart_filter_id, bdv.br_datamart_category_id,
    bdv.freetext_desc, bdv.updt_dt_tm, bdv.updt_id,
    bdv.updt_task, bdv.updt_applctx, bdv.mpage_param_mean,
    bdv.beg_effective_dt_tm, bdv.end_effective_dt_tm)(SELECT
     seq(bedrock_seq,nextval), bdf.br_datamart_filter_id, bdc.br_datamart_category_id,
     "1.00", cnvtdatetime(curdate,curtime3), reqinfo->updt_id,
     reqinfo->updt_task, reqinfo->updt_applctx, "",
     cnvtdatetime(curdate,curtime3), cnvtdatetime("31-DEC-2100")
     FROM br_datamart_category bdc,
      br_datamart_filter bdf
     WHERE bdc.layout_flag=2
      AND bdf.br_datamart_category_id=bdc.br_datamart_category_id
      AND bdf.filter_mean="SMART_RPT_DT_QUAL_OPT"
      AND  NOT ( EXISTS (
     (SELECT
      v.br_datamart_value_id
      FROM br_datamart_value v
      WHERE v.br_datamart_category_id=bdc.br_datamart_category_id
       AND v.br_datamart_filter_id=bdf.br_datamart_filter_id))))
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Error inserting SMART_RPT_DT_QUAL_OPT rows into br_datamart_value: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE createdisplaydttmsetting(null)
   DECLARE errmsg = vc WITH protect, noconstant("")
   INSERT  FROM br_datamart_value bdv
    (bdv.br_datamart_value_id, bdv.br_datamart_filter_id, bdv.br_datamart_category_id,
    bdv.freetext_desc, bdv.updt_dt_tm, bdv.updt_id,
    bdv.updt_task, bdv.updt_applctx, bdv.mpage_param_mean,
    bdv.beg_effective_dt_tm, bdv.end_effective_dt_tm)(SELECT
     seq(bedrock_seq,nextval), bdf.br_datamart_filter_id, bdc.br_datamart_category_id,
     "1.00", cnvtdatetime(curdate,curtime3), reqinfo->updt_id,
     reqinfo->updt_task, reqinfo->updt_applctx, "",
     cnvtdatetime(curdate,curtime3), cnvtdatetime("31-DEC-2100")
     FROM br_datamart_category bdc,
      br_datamart_filter bdf
     WHERE bdc.layout_flag=2
      AND bdf.br_datamart_category_id=bdc.br_datamart_category_id
      AND bdf.filter_mean="SMART_RPT_DT_DISPLAY_OPT"
      AND  NOT ( EXISTS (
     (SELECT
      v.br_datamart_value_id
      FROM br_datamart_value v
      WHERE v.br_datamart_category_id=bdc.br_datamart_category_id
       AND v.br_datamart_filter_id=bdf.br_datamart_filter_id))))
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Error inserting SMART_RPT_DT_DISPLAY_OPT rows into br_datamart_value: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure: Starting Script cmn_rdm_stw_updt_rpt_dt_opt."
 CALL createqualifyingdttmsetting(null)
 CALL createdisplaydttmsetting(null)
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required updates"
 COMMIT
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
