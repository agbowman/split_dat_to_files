CREATE PROGRAM dm_rdm_rem_worklist_order_r:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_rem_worklist_order_r..."
 CALL echo("Checking for TRG_*_ZDEL Triggers...")
 DECLARE trg_cnt = i4
 FREE RECORD trg_names
 RECORD trg_names(
   1 list[*]
     2 trg_name = vc
     2 parse_str = vc
 )
 SELECT INTO "nl:"
  FROM dm2_user_triggers dut
  WHERE dut.table_name="WORKLIST_ORDER_R"
   AND dut.trigger_name="TRG_*_ZDEL"
  HEAD REPORT
   trg_cnt = 0
  DETAIL
   trg_cnt = (trg_cnt+ 1), stat = alterlist(trg_names->list,trg_cnt), trg_names->list[trg_cnt].
   trg_name = trim(dut.trigger_name,3),
   trg_names->list[trg_cnt].parse_str = concat("rdb drop trigger ",trim(dut.trigger_name,3)," go")
  WITH nocounter
 ;end select
 IF (trg_cnt > 0)
  CALL echo("Deleting Remaining *_ZDEL Triggers...")
  SET err_msg = fillstring(132," ")
  SET err_code = 0
  FOR (i = 1 TO trg_cnt)
    CALL parser(trg_names->list[i].parse_str)
    SET err_code = error(err_msg,0)
    IF (err_code != 0)
     SET readme_data->message = concat("Readme Failed: Could not drop *_ZDEL Trigger: ",trg_names->
      list[i].trg_name)
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 CALL echo("Checking for TRG_*DR_UPDT_DEL* Triggers...")
 DECLARE trgr_cnt = i4
 FREE RECORD trgr_names
 RECORD trgr_names(
   1 list[*]
     2 trgr_name = vc
     2 trgr_parse_str = vc
 )
 SELECT
  IF (currdb="ORACLE")
   FROM dm2_user_triggers ut,
    dm_tables_doc dtd
   WHERE dtd.table_name="WORKLIST_ORDER_R"
    AND ut.table_name=dtd.table_name
    AND ut.trigger_name="TRG*_DR_UPDT_DEL*"
  ELSE
   FROM dm2_user_triggers ut,
    dm_tables_doc dtd
   WHERE dtd.table_name="WORKLIST_ORDER_R"
    AND ut.table_name=dtd.table_name
    AND ((ut.trigger_name="TRG*_DRDEL*") OR (ut.trigger_name="TRG*_DRUPD*"))
  ENDIF
  INTO "nl:"
  HEAD REPORT
   trgr_cnt = 0
  DETAIL
   trgr_cnt = (trgr_cnt+ 1), stat = alterlist(trgr_names->list,trgr_cnt), trgr_names->list[trgr_cnt].
   trgr_name = ut.trigger_name
   CASE (currdb)
    OF "ORACLE":
     IF (substring((textlen(trim(ut.trigger_name)) - 1),2,ut.trigger_name)="$C")
      IF (substring((textlen(trim(ut.trigger_name)) - 12),11,ut.trigger_name)="DR_UPDT_DEL")
       trgr_names->list[trgr_cnt].trgr_parse_str = concat("RDB ASIS(^ DROP TRIGGER ",trim(ut
         .trigger_name)," ^) GO")
      ENDIF
     ELSE
      IF (substring((textlen(trim(ut.trigger_name)) - 10),11,ut.trigger_name)="DR_UPDT_DEL")
       trgr_names->list[trgr_cnt].trgr_parse_str = concat("RDB DROP TRIGGER ",ut.trigger_name," GO")
      ENDIF
     ENDIF
    OF "DB2UDB":
     trgr_names->list[trgr_cnt].trgr_parse_str = concat("RDB ASIS(^ DROP TRIGGER ",trim(ut
       .trigger_name)," ^) GO")
   ENDCASE
  WITH nocounter
 ;end select
 IF (trgr_cnt > 0)
  CALL echo("Deleting Triggers...")
  SET err_msg = fillstring(132," ")
  SET err_code = 0
  FOR (i = 1 TO trgr_cnt)
    CALL parser(trgr_names->list[i].trgr_parse_str)
    SET err_code = error(err_msg,0)
    IF (err_code != 0)
     SET readme_data->message = concat("Readme Failed: Could not drop Trigger: ",trgr_names->list[i].
      trgr_name)
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 DECLARE rows_found = i4
 SET rows_found = 0
 SELECT INTO "nl:"
  FROM worklist_order_r wor
  WHERE wor.worklist_id=0.0
   AND wor.order_id=0.0
  HEAD REPORT
   rows_found = 0
  DETAIL
   rows_found = (rows_found+ 1)
  WITH nocounter
 ;end select
 IF (rows_found=1)
  DELETE  FROM worklist_order_r wor
   WHERE wor.worklist_id=0.0
    AND wor.order_id=0.0
   WITH nocounter
  ;end delete
  SET err_code = error(err_msg,0)
  IF (err_code != 0)
   ROLLBACK
   SET readme_data->message = "Readme Failed: Deleting default row"
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 DECLARE trg_remaining = i4
 SET trg_remaining = 0
 IF (currdb="ORACLE")
  CALL echo("Checking for Trigger Removal in Oracle DB...")
  SELECT INTO "nl:"
   FROM dm2_user_triggers ut,
    dm_tables_doc dtd
   PLAN (dtd
    WHERE dtd.table_name="WORKLIST_ORDER_R")
    JOIN (ut
    WHERE ut.table_name=dtd.table_name
     AND ut.trigger_name="TRG*_DR_UPDT_DEL*")
   HEAD REPORT
    trg_remaining = 0
   DETAIL
    trg_remaining = (trg_remaining+ 1)
   WITH nocounter
  ;end select
 ELSE
  CALL echo("Checking for Trigger Removal in non-Oracle DB...")
  SELECT INTO "nl:"
   FROM dm2_user_triggers ut,
    dm_tables_doc dtd
   PLAN (dtd
    WHERE dtd.table_name="WORKLIST_ORDER_R")
    JOIN (ut
    WHERE ut.table_name=dtd.table_name
     AND ((ut.trigger_name="TRG*_DRDEL*") OR (ut.trigger_name="TRG*_DRUPD*")) )
   HEAD REPORT
    trg_remaining = 0
   DETAIL
    trg_remaining = (trg_remaining+ 1)
   WITH nocounter
  ;end select
 ENDIF
 DECLARE rows_remaining = i4
 SET rows_remaining = 0
 CALL echo("Checking for Default Row Removal...")
 SELECT INTO "nl:"
  FROM worklist_order_r wor
  WHERE wor.worklist_id=0.0
   AND wor.order_id=0.0
  HEAD REPORT
   rows_remaining = 0
  DETAIL
   rows_remaining = (rows_remaining+ 1)
  WITH nocounter
 ;end select
 IF (trg_remaining > 0)
  SET readme_data->message = "Readme Failed: Not all Triggers were dropped."
 ELSEIF (rows_remaining > 0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Readme Success: All Default Row Triggers Dropped but unable to identify a single Default Row for Deletion"
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message =
  "Readme Success: Default Row Removed and All Associated Triggers Dropped"
 ENDIF
#exit_script
 FREE RECORD trg_names
 FREE RECORD trgr_names
 FREE RECORD tbl_names
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
