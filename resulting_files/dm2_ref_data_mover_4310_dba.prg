CREATE PROGRAM dm2_ref_data_mover_4310:dba
 SET cust_tab_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
 SET cust_root_name = get_value(cust_tab_name,"ROOT_NAME","FROM")
 SET cust_lt_id = get_value(cust_tab_name,"LONG_TEXT_ID","FROM")
 SET cust_lb_id = get_value(cust_tab_name,"LONG_BLOB_ID","FROM")
 SET cust_lb_col_pos = get_col_pos(cust_tab_name,"LONG_TEXT_ID")
 SET cust_lt_col_pos = get_col_pos(cust_tab_name,"LONG_BLOB_ID")
 IF ( NOT (cust_root_name IN ("PREFERENCE_CARD", "PRSNL", "SEGMENT_REFERENCE")))
  SET dm2_ref_data_reply->error_ind = 1
  SET dm2_ref_data_reply->error_msg = "NOMV11"
  GO TO exit_4310
 ENDIF
 IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_lt_col_pos].translated=1)
  AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_lb_col_pos].translated=1))
  IF (cust_lb_id=cust_lt_id)
   SET cust_lt_t_id = get_value(cust_tab_name,"LONG_TEXT_ID","TO")
   SET cust_lb_t_id = get_value(cust_tab_name,"LONG_BLOB_ID","TO")
   IF (cust_lb_t_id != cust_lt_t_id)
    CALL put_value(cust_tab_name,"LONG_BLOB_ID",cust_lt_t_id)
    UPDATE  FROM dm_merge_translate
     SET to_value = cnvtreal(cust_lt_t_id)
     WHERE from_value=cnvtreal(cust_lb_id)
      AND table_name="LONG_BLOB_REFERENCE"
      AND (env_source_id=dm2_ref_data_doc->env_source_id)
      AND (env_target_id=dm2_ref_data_doc->env_target_id)
     WITH nocounter
    ;end update
    SELECT INTO "NL:"
     FROM long_blob_reference
     WHERE long_blob_id=cnvtreal(cust_lt_t_id)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     DELETE  FROM long_blob_reference
      WHERE long_blob_id=cnvtreal(cust_lb_t_id)
     ;end delete
    ELSE
     UPDATE  FROM long_blob_reference
      SET long_blob_id = cnvtreal(cust_lt_t_id)
      WHERE long_blob_id=cnvtreal(cust_lb_t_id)
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET temp_col_cnt = get_col_pos(cust_tab_name,"SN_COMMENT_ID")
 IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[temp_col_cnt].translated=0))
  SET cust_no_query = is_translated(cust_tab_name,"UNIQUE")
  IF (cust_no_query=1)
   SET cust_val = query_target(temp_tbl_cnt,perm_col_cnt)
   IF (cust_val < 0)
    IF ((cust_val=- (3)))
     SET cust_val = get_seq(cust_tab_name,"SN_COMMENT_ID")
     IF (cust_val > 0)
      CALL put_value(cust_tab_name,"SN_COMMENT_ID",cnvtstring(cust_val))
      SET current_merges = (current_merges+ 1)
      SET child_merge_audit->num[current_merges].action = "NEWSEQ"
      SET child_merge_audit->num[current_merges].text = concat(cust_tab_name,"  SN_COMMENT_ID")
     ELSE
      GO TO exit_4310
     ENDIF
    ELSE
     GO TO exit_4310
    ENDIF
   ELSE
    CALL put_value(cust_tab_name,"SN_COMMENT_ID",cnvtstring(cust_val))
   ENDIF
   SET stat = alterlist(dm2_ref_data_reply->qual,1)
   SET dm2_ref_data_reply->qual[1].table_name = cust_tab_name
   SET cust_from_cd = get_value(cust_tab_name,"SN_COMMENT_ID","FROM")
   IF ((dm2_ref_data_reply->error_ind=1))
    GO TO exit_4310
   ELSE
    SET dm2_ref_data_reply->qual[1].from_value = cnvtreal(cust_from_cd)
   ENDIF
   SET cust_new_cd = get_value(cust_tab_name,"SN_COMMENT_ID","TO")
   IF ((dm2_ref_data_reply->error_ind=1))
    GO TO exit_4310
   ELSE
    SET dm2_ref_data_reply->qual[1].to_value = cnvtreal(cust_new_cd)
   ENDIF
   CALL echo(build("P COLUMN = ",curmem))
  ELSE
   SET cust_idcd_check = is_translated(cust_tab_name,"ALL")
   GO TO exit_4310
  ENDIF
 ENDIF
 SET cust_idcd_check = 0
 CALL echo("")
 CALL echo("")
 CALL echo("***************CHECKING ID AND CD COLUMNS******************")
 CALL echo("")
 CALL echo("")
 SET dm_err->eproc = "Checking ID and CD columns"
 SET cust_idcd_check = is_translated(cust_tab_name,"ALL")
 IF (drdm_error_out_ind=1)
  GO TO exit_4310
 ENDIF
 IF (cust_idcd_check=1)
  SET ins_upd = insert_update_row(temp_tbl_cnt,perm_col_cnt)
 ENDIF
#exit_4310
END GO
