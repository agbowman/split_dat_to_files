CREATE PROGRAM dts_rdm_cleanup_note_dt_tm:dba
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
 DECLARE signline_cv = f8 WITH protect, noconstant(0.0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme dts_rdm_cleanup_note_dt_tm failed."
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_value != 0.0
   AND c.code_set=14
   AND c.cdf_meaning="SIGN LINE"
   AND c.active_ind=1
  DETAIL
   signline_cv = c.code_value
  WITH nocounter
 ;end select
 SET err_code = error(error_msg,1)
 IF (err_code > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error - failed to get code value:",error_msg)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(drr_validate_table->list,1)
 SET drr_validate_table->list[1].table_name = "CE_EVENT_NOTE1334DRR"
 IF (drr_table_and_ccldef_exists(null) != 0
  AND drr_table_and_ccldef_exists(null) != 1)
  SET readme_data->status = "F"
  SET readme_data->message = drr_validate_table->msg_returned
  GO TO exit_script
 ELSEIF (drr_table_and_ccldef_exists(null)=0)
  SET readme_data->status = "S"
  SET readme_data->message = drr_validate_table->msg_returned
  GO TO exit_script
 ENDIF
 UPDATE  FROM ce_event_note1334drr c
  SET c.note_dt_tm = c.valid_from_dt_tm, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(
    sysdate),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
   updt_applctx
  WHERE c.note_dt_tm > cnvtdatetime("01-JAN-2101")
   AND c.note_type_cd=signline_cv
  WITH nocounter
 ;end update
 SET err_code = error(error_msg,1)
 IF (err_code > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error - failed to update the notes in ce_event_note1334drr:",
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
