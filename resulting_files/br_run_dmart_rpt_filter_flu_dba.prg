CREATE PROGRAM br_run_dmart_rpt_filter_flu:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_run_dmart_rpt_filter_flu> script"
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
 IF (curqual > 0)
  DELETE  FROM br_datamart_report_filter_r br
   SET br.seq = 1
   WHERE br.br_datamart_filter_id=filter_id
    AND br.br_datamart_report_id IN (
   (SELECT
    b.br_datamart_report_id
    FROM br_datamart_report b
    WHERE b.br_datamart_category_id=cat_id))
   WITH nocounter
  ;end delete
 ENDIF
 EXECUTE dm_dbimport "cer_install:datamart_report_filter_flu.csv", "br_reg_rpt_filter_config", 5000
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
