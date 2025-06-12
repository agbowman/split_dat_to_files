CREATE PROGRAM dm2_nbr_to_float_backfill:dba
 SET dnt_err_code = 0
 SET dnt_err_ind = 0
 SET dnt_err_msg = fillstring(132," ")
 SET dnt_dm2_err_ind = 0
 IF ((validate(dm_err->err_ind,- (99)) != - (99)))
  SET dnt_dm2_err_ind = 1
 ENDIF
 SUBROUTINE dnt_insert_column(dic_table_name,dic_column_name)
   SELECT INTO "nl:"
    FROM dm_info
    WHERE info_domain="DM2_NBR_TO_FLOAT"
     AND info_name=concat(cnvtupper(dic_table_name),"-",cnvtupper(dic_column_name))
    WITH nocounter
   ;end select
   IF (dnt_check_error(null)=1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info
     SET info_domain = "DM2_NBR_TO_FLOAT", info_name = concat(cnvtupper(dic_table_name),"-",cnvtupper
       (dic_column_name)), updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (dnt_check_error(null)=1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dnt_check_error(null)
   SET dnt_err_code = error(dnt_err_msg,1)
   IF (dnt_err_code > 0)
    SET dnt_err_ind = 1
   ENDIF
   IF (dnt_err_ind=1)
    IF (dnt_dm2_err_ind=1)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = dnt_err_msg
    ENDIF
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dnt_chk_ccl_def(dcc_table_name,dcc_column_name)
   DECLARE dcc_type = vc WITH protect, noconstant("")
   DECLARE dcc_len = i4 WITH protect, noconstant(0)
   IF (checkdic(cnvtupper(concat(dcc_table_name,".",dcc_column_name)),"A",0)=2)
    IF (((currev=8
     AND ((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 81401)) OR (currev > 8
     AND ((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 90201))) )
     CALL parser(concat(" set dcc_type = reflect(",dcc_table_name,".",dcc_column_name,",1) go "),1)
     CALL parser(concat(" free range ",dcc_table_name," go "),1)
     SET dcc_len = cnvtint(cnvtalphanum(dcc_type,1))
     SET dcc_type = trim(cnvtalphanum(dcc_type,2))
     IF (textlen(dcc_type)=2)
      SET dcc_type = substring(2,2,dcc_type)
     ENDIF
     SET dcc_type = build(dcc_type,dcc_len)
    ELSE
     SELECT INTO "nl:"
      FROM dtable t,
       dtableattr ta,
       dtableattrl tl
      PLAN (t
       WHERE t.table_name=cnvtupper(dcc_table_name))
       JOIN (ta
       WHERE t.table_name=ta.table_name)
       JOIN (tl
       WHERE tl.structtype != "K"
        AND btest(tl.stat,11)=0
        AND btest(tl.stat,9)=0
        AND btest(tl.stat,10)=0
        AND tl.attr_name=cnvtupper(dcc_column_name))
      DETAIL
       dcc_type = concat(tl.type,trim(cnvtstring(tl.len)))
      WITH nocounter
     ;end select
     IF (dnt_check_error(null)=1)
      RETURN(0)
     ENDIF
     IF (dnt_dm2_err_ind=1)
      IF ((dm_err->debug_flag > 1))
       CALL echo(build("dcc_type = ",dcc_type))
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (dcc_type != "F8")
    IF ((dm_err->debug_flag > 1))
     CALL echo(build("dcc_type = ",dcc_type))
    ENDIF
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
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
 SET readme_data->message = "Readme Failed: Starting dm2_nbr_to_float_backfill script"
 FREE RECORD dnb_f8_cols
 RECORD dnb_f8_cols(
   1 cnt = i4
   1 qual[*]
     2 table_name = vc
     2 column_name = vc
 )
 SET dnb_f8_cols->cnt = 4
 SET stat = alterlist(dnb_f8_cols->qual,dnb_f8_cols->cnt)
 SET dnb_f8_cols->qual[1].table_name = "PFT_RULE_GROUP"
 SET dnb_f8_cols->qual[1].column_name = "PARENT_GROUP_NBR"
 SET dnb_f8_cols->qual[2].table_name = "ENTITY_DETAIL"
 SET dnb_f8_cols->qual[2].column_name = "DATA_NUMBER"
 SET dnb_f8_cols->qual[3].table_name = "DM2_DDL_OPS_LOG"
 SET dnb_f8_cols->qual[3].column_name = "ROW_CNT"
 SET dnb_f8_cols->qual[4].table_name = "DM2_DDL_OPS_LOG1"
 SET dnb_f8_cols->qual[4].column_name = "ROW_CNT"
 FOR (dcc_i = 1 TO dnb_f8_cols->cnt)
   SELECT INTO "nl:"
    FROM user_tab_columns u
    WHERE (u.table_name=dnb_f8_cols->qual[dcc_i].table_name)
     AND (u.column_name=dnb_f8_cols->qual[dcc_i].column_name)
    WITH nocounter
   ;end select
   IF (dnt_check_error(null)=1)
    GO TO exit_script
   ENDIF
   IF (curqual > 0)
    IF (dnt_insert_column(dnb_f8_cols->qual[dcc_i].table_name,dnb_f8_cols->qual[dcc_i].column_name)=0
    )
     GO TO exit_script
    ENDIF
    EXECUTE oragen3 dnb_f8_cols->qual[dcc_i].table_name
    IF (dnt_dm2_err_ind=1)
     IF ((dm_err->err_ind=1))
      SET readme_data->status = "F"
      SET readme_data->message = dm_err->emsg
      GO TO exit_script
     ENDIF
    ENDIF
    IF (dnt_chk_ccl_def(dnb_f8_cols->qual[dcc_i].table_name,dnb_f8_cols->qual[dcc_i].column_name)=0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("CCL definition for column ",dnb_f8_cols->qual[dcc_i].
      column_name," on table ",dnb_f8_cols->qual[dcc_i].table_name," is not F8.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "DM2_NBR_TO_FLOAT_BACKFILL executed successfully."
#exit_script
 IF (dnt_err_ind != 0)
  SET readme_data->status = "F"
  SET readme_data->message = dnt_err_msg
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
