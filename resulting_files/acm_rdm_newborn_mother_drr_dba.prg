CREATE PROGRAM acm_rdm_newborn_mother_drr:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = concat("FAILED STARTING README ",cnvtstring(readme_data->readme_id))
 DECLARE ms_errmsg = vc WITH protect, noconstant("")
 DECLARE leertotal = i4 WITH protect, noconstant(0)
 FREE RECORD t_newborn_mother_record
 RECORD t_newborn_mother_record(
   1 encntr_encntr_reltns[*]
     2 encntr_encntr_reltn_id = f8
     2 mother_encntr_id = f8
     2 child_encntr_id = f8
 )
 DECLARE dnewborncd = f8 WITH protect, noconstant(0.0)
 DECLARE dactivestatuscd = f8 WITH protect, noconstant(0.0)
 CALL echo("Processing... ACM_RDM_NEWBORN_MOTHER_DRR")
 CALL echo("")
 SET stat = alterlist(drr_validate_table->list,2)
 SET drr_validate_table->list[1].table_name = "ENCNTR_ENCNTR_RELT8882DRR"
 SET drr_validate_table->list[2].table_name = "ENCNTR_MOTHER_CHIL4265DRR"
 IF (drr_table_and_ccldef_exists(null) != 0
  AND drr_table_and_ccldef_exists(null) != 2)
  SET readme_data->status = "F"
  SET readme_data->message = drr_validate_table->msg_returned
  GO TO exit_program
 ELSEIF (drr_table_and_ccldef_exists(null)=0)
  SET readme_data->status = "S"
  SET readme_data->message = drr_validate_table->msg_returned
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="NEWBORN"
   AND cv.code_set=385571
   AND cv.active_ind=1
  DETAIL
   dnewborncd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error selecting the CDF_MEANING from CODE_VALUE table for CODE_SET 385571: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="ACTIVE"
   AND cv.code_set=48
   AND cv.active_ind=1
  DETAIL
   dactivestatuscd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error selecting the CDF_MEANING from CODE_VALUE table for CODE_SET 48: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_mother_chil4265drr emcr,
   encntr_encntr_relt8882drr eer
  WHERE emcr.mother_encntr_id=eer.related_encntr_id
   AND emcr.child_encntr_id=eer.encntr_id
   AND emcr.active_ind=1
   AND emcr.active_status_cd=dactivestatuscd
   AND emcr.encntr_mother_child_reltn_id > 0
   AND emcr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND emcr.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND eer.encntr_encntr_reltn_id > 0
   AND eer.encntr_reltn_type_cd=dnewborncd
  HEAD REPORT
   leertotal = 0
  HEAD eer.encntr_encntr_reltn_id
   leertotal += 1
   IF (mod(leertotal,100)=1)
    stat = alterlist(t_newborn_mother_record->encntr_encntr_reltns,(leertotal+ 99))
   ENDIF
   t_newborn_mother_record->encntr_encntr_reltns[leertotal].encntr_encntr_reltn_id = eer
   .encntr_encntr_reltn_id, t_newborn_mother_record->encntr_encntr_reltns[leertotal].mother_encntr_id
    = emcr.mother_encntr_id, t_newborn_mother_record->encntr_encntr_reltns[leertotal].child_encntr_id
    = emcr.child_encntr_id
  FOOT  eer.encntr_encntr_reltn_id
   null
  FOOT REPORT
   stat = alterlist(t_newborn_mother_record->encntr_encntr_reltns,leertotal)
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error occured when updating t_newborn_mother_record record.",
   ms_errmsg)
  GO TO exit_program
 ENDIF
 IF (leertotal > 0)
  UPDATE  FROM encntr_encntr_relt8882drr eer,
    (dummyt d1  WITH seq = value(leertotal))
   SET eer.encntr_id = t_newborn_mother_record->encntr_encntr_reltns[d1.seq].mother_encntr_id, eer
    .related_encntr_id = t_newborn_mother_record->encntr_encntr_reltns[d1.seq].child_encntr_id, eer
    .updt_dt_tm = cnvtdatetime(sysdate),
    eer.updt_cnt = (eer.updt_cnt+ 1), eer.updt_id = reqinfo->updt_id, eer.updt_task = reqinfo->
    updt_task,
    eer.updt_applctx = reqinfo->updt_applctx
   PLAN (d1)
    JOIN (eer
    WHERE (eer.encntr_encntr_reltn_id=t_newborn_mother_record->encntr_encntr_reltns[d1.seq].
    encntr_encntr_reltn_id))
   WITH nocounter
  ;end update
 ENDIF
 IF (error(ms_errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error occured when updating encntr_encntr_relt8882drr.",
   ms_errmsg)
  GO TO exit_program
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme completed successfully"
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 FREE RECORD t_newborn_mother_record
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
