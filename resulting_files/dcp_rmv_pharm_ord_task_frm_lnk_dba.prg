CREATE PROGRAM dcp_rmv_pharm_ord_task_frm_lnk:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_basic_template.prg..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE pharm_type_cd = f8
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="PHARMACY"
   AND cv.code_set=6000
  DETAIL
   pharm_type_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL echo(build("pharm_type_cd = ",pharm_type_cd))
 SELECT INTO "CCLUSERDIR:DCP_REMOVED_FORM_TASK_LINKS_REPORT.TXT"
  FROM order_task ot,
   order_task_xref otx,
   order_catalog oc
  PLAN (ot
   WHERE ot.dcp_forms_ref_id > 0)
   JOIN (otx
   WHERE otx.reference_task_id=ot.reference_task_id)
   JOIN (oc
   WHERE oc.catalog_cd=otx.catalog_cd
    AND oc.catalog_type_cd=pharm_type_cd)
  HEAD REPORT
   row + 1, col 10, "Changed Tasks",
   row + 1, counter = 0, row + 1,
   col 0, "Reference_Task_ID", col 20,
   "DCP_Forms_Ref_ID", row + 2
  DETAIL
   counter = 1, col 0, ot.reference_task_id,
   col 20, ot.dcp_forms_ref_id, row + 1
  FOOT REPORT
   row + 1
   IF (counter=0)
    row + 1, col 10, "No Records",
    row + 2
   ENDIF
   col 10, "End of Report", row + 1
  WITH nocounter, nullreport, formfeed = none
 ;end select
 UPDATE  FROM order_task ot
  SET ot.dcp_forms_ref_id = 0.0, ot.updt_cnt = (ot.updt_cnt+ 1), ot.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   ot.updt_id = reqinfo->updt_id, ot.updt_applctx = reqinfo->updt_applctx, ot.updt_task = reqinfo->
   updt_task
  WHERE ot.reference_task_id IN (
  (SELECT
   ot2.reference_task_id
   FROM order_task ot2,
    order_task_xref otx2,
    order_catalog oc2
   WHERE ot2.dcp_forms_ref_id > 0
    AND otx2.reference_task_id=ot2.reference_task_id
    AND oc2.catalog_cd=otx2.catalog_cd
    AND oc2.catalog_type_cd=pharm_type_cd))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_stat->message = concat("<Brief Failure Summary>:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Success:Required tasks performed -Report:DCP_REMOVED_FORM_TASK_LINKS_REPORT.TXT"
#exit_script
 CALL echorecord(readme_data)
END GO
