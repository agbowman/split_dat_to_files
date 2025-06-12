CREATE PROGRAM dm_fix_xie99orders:dba
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
 IF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto Success on DB2 sites"
  GO TO exit_script
 ENDIF
 FREE RECORD indx
 RECORD indx(
   1 exec_run = i2
   1 cname = vc
   1 iname = vc
   1 cnt = i4
   1 qual[*]
     2 cname = vc
     2 tname = vc
     2 colname = vc
     2 disable_str = vc
     2 drop_str = vc
     2 create_str = vc
   1 status_ind = i2
   1 insert_cnt = i4
   1 disp_str = vc
   1 load_cnt = i4
   1 load[*]
     2 exec_str = vc
   1 dm_errcode = i2
   1 dm_errmsg = c132
 )
 SET indx->insert_cnt = 0
 SET indx->cname = "EMPTY"
 SET indx->iname = "EMPTY"
 SUBROUTINE add_dm_info_row(ti_ddl_string)
   SET indx->insert_cnt = (indx->insert_cnt+ 1)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM.XPKORDERS", di.info_name = ti_ddl_string, di.info_long_id = indx->
     insert_cnt,
     di.info_number = 0
    WITH nocounter
   ;end insert
   COMMIT
 END ;Subroutine
 SUBROUTINE get_dm_info_rec(dummy)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM.XPKORDERS"
     AND di.info_number=0
    ORDER BY di.info_long_id
    HEAD REPORT
     indx->load_cnt = 0, stat = alterlist(indx->load,indx->load_cnt)
    DETAIL
     indx->load_cnt = (indx->load_cnt+ 1), stat = alterlist(indx->load,indx->load_cnt), indx->load[
     indx->load_cnt].exec_str = trim(di.info_name)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE ti_parse_ddl(ti_exec_str)
   SET indx->dm_errcode = 0
   SET stat = error(indx->dm_errmsg,1)
   CALL parser(ti_exec_str,1)
   SET indx->dm_errcode = error(indx->dm_errmsg,0)
   IF (indx->dm_errcode
    AND  NOT (((findstring("ORA-02275",indx->dm_errmsg)) OR (((findstring("ORA-02443",indx->dm_errmsg
    )) OR (findstring("ORA-01418",indx->dm_errmsg))) )) ))
    SET indx->disp_str = concat("DDL Operation Failed: ",char(13),char(10),"'",ti_exec_str,
     "'",char(13),char(10),"---> Readme Failed.")
    CALL echo("******")
    CALL echo(indx->disp_str)
    CALL echo(build("ERROR:",indx->dm_errmsg))
    CALL echo("******")
    SET readme_data->status = "F"
    SET readme_data->message = indx->disp_str
    RETURN(0)
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_number = 1
     WHERE di.info_domain="DM.XPKORDERS"
      AND di.info_name=ti_exec_str
     WITH nocounter
    ;end update
    COMMIT
    RETURN(1)
   ENDIF
 END ;Subroutine
 SELECT INTO "nl:"
  FROM user_constraints uc
  WHERE uc.constraint_type="P"
   AND uc.table_name="ORDERS"
  DETAIL
   indx->cname = trim(uc.constraint_name)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM user_indexes ui
  WHERE ui.table_name="ORDERS"
   AND ui.index_name="XIE99*"
  DETAIL
   IF (((ui.index_name="XIE99ORDERS") OR (ui.index_name="XIE99ORDERS$C")) )
    indx->iname = trim(ui.index_name)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM.XPKORDERS"
   AND di.info_number=0
  WITH nocounter
 ;end select
 IF (curqual)
  CALL echo("******")
  CALL echo("Readme has failed before! Executing remaining rows from DM_INFO table ... ")
  CALL get_dm_info_rec(1)
  FOR (ijx = 1 TO value(indx->load_cnt))
   SET indx->status_ind = ti_parse_ddl(indx->load[ijx].exec_str)
   IF ( NOT (indx->status_ind))
    GO TO end_program
   ENDIF
  ENDFOR
  SET indx->disp_str = concat("Successfully dropped ",indx->iname," index.  Readme Successful.")
  CALL echo("******")
  CALL echo(indx->disp_str)
  CALL echo("******")
  SET readme_data->status = "S"
  SET readme_data->message = indx->disp_str
  GO TO end_program
 ENDIF
 SET indx->exec_run = 0
 SELECT INTO "nl:"
  FROM user_ind_columns uic
  WHERE uic.table_name="ORDERS"
   AND (uic.index_name=indx->iname)
   AND uic.column_name="ORDER_ID"
   AND uic.column_position=1
  WITH nocounter
 ;end select
 IF (curqual)
  SET indx->dm_errcode = 0
  SET stat = error(indx->dm_errmsg,1)
  CALL parser(concat("rdb drop index ",indx->iname," go"),1)
  SET indx->dm_errcode = error(indx->dm_errmsg,0)
  IF (indx->dm_errcode
   AND findstring("ORA-02429",indx->dm_errmsg))
   SET indx->exec_run = 1
  ENDIF
 ENDIF
 IF (indx->exec_run)
  SET indx->disp_str = concat(
   "Dropping index 'XIE99ORDERS'.  You can ignore the error message, ORA-2429, if displayed.")
  SET indx->disp_str = concat("Incorrect Referencing Exists.  Deteremine Foreign Key constraints on ",
   indx->cname," constraint...")
  CALL echo("******")
  CALL echo(indx->disp_str)
  SELECT INTO "nl:"
   uc.constraint_name, ucc.constraint_name, ucc.table_name,
   ucc.column_name
   FROM user_cons_columns ucc,
    user_constraints uc
   WHERE uc.constraint_type="R"
    AND (uc.r_constraint_name=indx->cname)
    AND uc.constraint_name=ucc.constraint_name
   ORDER BY uc.constraint_name
   HEAD REPORT
    indx->cnt = 0, stat = alterlist(indx->qual,indx->cnt)
   DETAIL
    indx->cnt = (indx->cnt+ 1), stat = alterlist(indx->qual,indx->cnt), indx->qual[indx->cnt].tname
     = trim(uc.table_name),
    indx->qual[indx->cnt].cname = trim(uc.constraint_name), indx->qual[indx->cnt].disable_str =
    concat("rdb alter table ",indx->qual[indx->cnt].tname," disable constraint ",indx->qual[indx->cnt
     ].cname," go")
   WITH nocounter
  ;end select
  CALL echo("******")
  CALL echo("Loading DDL rows into DM_INFO table...")
  IF (value(indx->cnt))
   FOR (ijx = 1 TO value(indx->cnt))
     CALL add_dm_info_row(indx->qual[ijx].disable_str)
   ENDFOR
  ENDIF
  CALL add_dm_info_row(concat("rdb alter table ORDERS disable constraint ",indx->cname," go"))
  CALL add_dm_info_row(concat("rdb drop index ",indx->iname," go"))
  CALL add_dm_info_row(concat("rdb alter table ORDERS enable constraint ",indx->cname," go"))
  CALL get_dm_info_rec(1)
  CALL echo("******")
  CALL echo("Executing rows from DM_INFO table...")
  FOR (ijx = 1 TO value(indx->load_cnt))
   SET indx->status_ind = ti_parse_ddl(indx->load[ijx].exec_str)
   IF ( NOT (indx->status_ind))
    GO TO end_program
   ENDIF
  ENDFOR
 ENDIF
 IF ((indx->iname="EMPTY"))
  SET indx->disp_str =
  "XIE99ORDERS does not exist on ORDERS table.  No action required.  Readme Successful."
 ELSE
  SET indx->disp_str = concat("Successfully dropped ",indx->iname," index.  Readme Successful.")
 ENDIF
 CALL echo("******")
 CALL echo(indx->disp_str)
 CALL echo("******")
 SET readme_data->status = "S"
 SET readme_data->message = indx->disp_str
#end_program
 DELETE  FROM dm_info di
  WHERE di.info_domain="DM.XPKORDERS"
   AND di.info_number=1
  WITH nocounter
 ;end delete
 COMMIT
#exit_script
 EXECUTE dm_readme_status
END GO
