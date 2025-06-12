CREATE PROGRAM acm_rdm_inact_dup_mrn_rcnr_drr:dba
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
 DECLARE drr_table_and_ccldef_exists(null) = i2
 IF (validate(drr_validate_table->table_name,"X")="X"
  AND validate(drr_validate_table->table_name,"Z")="Z")
  FREE RECORD drr_validate_table
  RECORD drr_validate_table(
    1 msg_returned = vc
    1 list[*]
      2 table_name = vc
      2 status = i2
  )
 ENDIF
 SUBROUTINE drr_table_and_ccldef_exists(null)
   DECLARE dtc_table_num = i4 WITH protect, noconstant(0)
   DECLARE dtc_table_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_ccldef_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_no_ccldef = vc WITH protect, noconstant("")
   DECLARE dtc_no_table = vc WITH protect, noconstant("")
   DECLARE dtc_errmsg = vc WITH protect, noconstant("")
   SET dtc_table_num = size(drr_validate_table->list,5)
   IF (dtc_table_num=0)
    SET drr_validate_table->msg_returned = concat(
     "No table specified in DRR_VALIDATE_TABLE record structure.")
    RETURN(- (1))
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables ut,
     (dummyt d  WITH seq = value(dtc_table_num))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (ut
     WHERE ut.table_name=trim(cnvtupper(drr_validate_table->list[d.seq].table_name)))
    DETAIL
     dtc_table_cnt += 1, drr_validate_table->list[d.seq].status = 1
    WITH nocounter
   ;end select
   IF (error(dtc_errmsg,0) != 0)
    SET drr_validate_table->msg_returned = concat("Select for table existence failed: ",dtc_errmsg)
    RETURN(- (1))
   ELSEIF (dtc_table_cnt=0)
    SET drr_validate_table->msg_returned = concat("No DRR tables found")
    RETURN(0)
   ENDIF
   IF (dtc_table_cnt < dtc_table_num)
    FOR (i = 1 TO dtc_table_num)
      IF ((drr_validate_table->list[i].status=0))
       SET dtc_no_table = concat(dtc_no_table," ",drr_validate_table->list[i].table_name)
      ENDIF
    ENDFOR
    SET drr_validate_table->msg_returned = concat("Missing table",dtc_no_table)
    RETURN(dtc_table_cnt)
   ENDIF
   FOR (i = 1 TO dtc_table_num)
     IF (checkdic(cnvtupper(drr_validate_table->list[i].table_name),"T",0) != 2)
      SET dtc_no_ccldef = concat(dtc_no_ccldef," ",drr_validate_table->list[i].table_name)
      SET drr_validate_table->list[i].status = 0
     ELSE
      SET dtc_ccldef_cnt += 1
     ENDIF
   ENDFOR
   IF (dtc_ccldef_cnt < dtc_table_num)
    SET drr_validate_table->msg_returned = concat("CCL definition missing for ",dtc_no_ccldef)
    RETURN(dtc_ccldef_cnt)
   ENDIF
   RETURN(dtc_table_cnt)
 END ;Subroutine
 DECLARE err_code = f8 WITH protect, noconstant(0.0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE dinactivecd = f8 WITH protect, noconstant(0.0)
 DECLARE dmrncd = f8 WITH protect, noconstant(0.0)
 DECLARE drr_table_cnt = i4 WITH protect, noconstant(1)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme acm_rdm_inact_dup_mrn_rcnr_drr failed."
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="INACTIVE"
   AND cv.code_set=48
   AND cv.active_ind=1
  DETAIL
   dinactivecd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error selecting the CDF_MEANING from CODE_VALUE table for CODE_SET 48: ",error_msg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="MRN"
   AND cv.code_set=319
   AND cv.active_ind=1
  DETAIL
   dmrncd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error selecting the CDF_MEANING from CODE_VALUE table for CODE_SET 319: ",error_msg)
  GO TO exit_program
 ENDIF
 SET stat = alterlist(drr_validate_table->list,2)
 SET drr_validate_table->list[1].table_name = "ENCNTR_ALIAS0071DRR"
 SET drr_validate_table->list[2].table_name = "PM_HIST_TRACKING7623DRR"
 SET drr_table_cnt = drr_table_and_ccldef_exists(null)
 IF (drr_table_cnt != 0
  AND drr_table_cnt != 2)
  SET readme_data->status = "F"
  SET readme_data->message = drr_validate_table->msg_returned
  GO TO exit_script
 ELSEIF (drr_table_cnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = drr_validate_table->msg_returned
  GO TO exit_script
 ENDIF
 UPDATE  FROM encntr_alias0071drr ea1
  SET ea1.active_ind = 0, ea1.active_status_cd = dinactivecd, ea1.updt_applctx = reqinfo->
   updt_applctx,
   ea1.updt_dt_tm = cnvtdatetime(sysdate), ea1.updt_cnt = (ea1.updt_cnt+ 1), ea1.updt_id = reqinfo->
   updt_id,
   ea1.updt_task = reqinfo->updt_task
  WHERE ea1.encntr_alias_id IN (
  (SELECT
   ea2.encntr_alias_id
   FROM encntr_alias0071drr ea2
   WHERE ea2.encntr_alias_type_cd=dmrncd
    AND ea2.active_ind=1
    AND ea2.encntr_id IN (
   (SELECT
    ea3.encntr_id
    FROM encntr_alias0071drr ea3
    WHERE ea3.encntr_alias_type_cd=dmrncd
     AND ea3.active_ind=1
     AND ea3.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ea3.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND ea3.encntr_id IN (
    (SELECT
     encntr_id
     FROM pm_hist_tracking7623drr
     WHERE transaction_type_txt="RCNR"))
    GROUP BY ea3.encntr_id, ea3.alias, ea3.alias_pool_cd
    HAVING count(encntr_id) > 1))))
   AND  NOT (ea1.encntr_alias_id IN (
  (SELECT
   max(ea4.encntr_alias_id)
   FROM encntr_alias0071drr ea4
   WHERE ea4.encntr_alias_type_cd=dmrncd
    AND ea4.active_ind=1
    AND ea4.encntr_id IN (
   (SELECT
    ea5.encntr_id
    FROM encntr_alias0071drr ea5
    WHERE ea5.encntr_alias_type_cd=dmrncd
     AND ea5.active_ind=1
     AND ea5.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ea5.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND ea5.encntr_id IN (
    (SELECT
     encntr_id
     FROM pm_hist_tracking7623drr
     WHERE transaction_type_txt="RCNR"))
    GROUP BY ea5.encntr_id, ea5.alias, ea5.alias_pool_cd
    HAVING count(encntr_id) > 1)))))
  WITH nocounter
 ;end update
 SET err_code = error(error_msg,1)
 IF (err_code > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error - failed to update the aliases in encntr_alias0071drr:",
   error_msg)
  ROLLBACK
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
