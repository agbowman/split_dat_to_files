CREATE PROGRAM dm_fix_fk_trck_itm_and_ord_rvw:dba
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
 FREE RECORD tables
 RECORD tables(
   1 list[16]
     2 table_name = vc
     2 exist = c1
     2 fk_name = c30
     2 fk_exists = i2
     2 dm_info_exists = c1
 )
 SET dm_three_cnt = 0
 SET d_str = fillstring(132," ")
 SET dm_failed_cons = fillstring(132," ")
 SET rdm_err_msg = fillstring(132," ")
 SET tables->list[1].exist = "N"
 SET tables->list[2].exist = "N"
 SET tables->list[3].exist = "N"
 SET tables->list[4].exist = "N"
 SET tables->list[5].exist = "N"
 SET tables->list[6].exist = "N"
 SET tables->list[7].exist = "N"
 SET tables->list[8].exist = "N"
 SET tables->list[9].exist = "N"
 SET tables->list[10].exist = "N"
 SET tables->list[11].exist = "N"
 SET tables->list[12].exist = "N"
 SET tables->list[13].exist = "N"
 SET tables->list[14].exist = "N"
 SET tables->list[15].exist = "N"
 SET tables->list[16].exist = "N"
 SET tables->list[1].dm_info_exists = "N"
 SET tables->list[2].dm_info_exists = "N"
 SET tables->list[3].dm_info_exists = "N"
 SET tables->list[4].dm_info_exists = "N"
 SET tables->list[5].dm_info_exists = "N"
 SET tables->list[6].dm_info_exists = "N"
 SET tables->list[7].dm_info_exists = "N"
 SET tables->list[8].dm_info_exists = "N"
 SET tables->list[9].dm_info_exists = "N"
 SET tables->list[10].dm_info_exists = "N"
 SET tables->list[11].dm_info_exists = "N"
 SET tables->list[12].dm_info_exists = "N"
 SET tables->list[13].dm_info_exists = "N"
 SET tables->list[14].dm_info_exists = "N"
 SET tables->list[15].dm_info_exists = "N"
 SET tables->list[16].dm_info_exists = "N"
 SELECT INTO "nl:"
  FROM dm_tables_doc dtd
  PLAN (dtd
   WHERE dtd.table_name IN ("ORDER_REVIEW", "TRACKING_ITEM", "CHARGE", "SN_CHARGE_DETAIL",
   "HIM_PV_PHYSICIAN",
   "CASE_ATTENDANCE"))
  DETAIL
   IF (dtd.table_name="ORDER_REVIEW")
    tables->list[1].exist = "Y", tables->list[2].exist = "Y"
    IF (currdb="ORACLE")
     tables->list[1].table_name = dtd.full_table_name, tables->list[1].fk_name = "XFK12ORDER_REVIEW",
     tables->list[2].table_name = dtd.full_table_name,
     tables->list[2].fk_name = "XFK12ORDER_REVIEW$C"
    ELSE
     tables->list[1].table_name = dtd.suffixed_table_name, tables->list[1].fk_name =
     "XFK12ORDER_R0156", tables->list[2].table_name = dtd.suffixed_table_name,
     tables->list[2].fk_name = "XFK12ORDER_R0156"
    ENDIF
   ENDIF
   IF (dtd.table_name="TRACKING_ITEM")
    tables->list[3].exist = "Y", tables->list[4].exist = "Y", tables->list[5].exist = "Y",
    tables->list[6].exist = "Y", tables->list[7].exist = "Y", tables->list[8].exist = "Y"
    IF (currdb="ORACLE")
     tables->list[3].table_name = dtd.full_table_name, tables->list[3].fk_name = "XFK5TRACKING_ITEM",
     tables->list[4].table_name = dtd.full_table_name,
     tables->list[4].fk_name = "XFK5TRACKING_ITEM$C", tables->list[5].table_name = dtd
     .full_table_name, tables->list[5].fk_name = "XFK6TRACKING_ITEM",
     tables->list[6].table_name = dtd.full_table_name, tables->list[6].fk_name =
     "XFK6TRACKING_ITEM$C", tables->list[7].table_name = dtd.full_table_name,
     tables->list[7].fk_name = "XFK7TRACKING_ITEM", tables->list[8].table_name = dtd.full_table_name,
     tables->list[8].fk_name = "XFK7TRACKING_ITEM$C"
    ELSE
     tables->list[3].table_name = dtd.suffixed_table_name, tables->list[3].fk_name =
     "XFK5TRACKING2976", tables->list[4].table_name = dtd.suffixed_table_name,
     tables->list[4].fk_name = "XFK5TRACKING2976", tables->list[5].table_name = dtd
     .suffixed_table_name, tables->list[5].fk_name = "XFK6TRACKING2976",
     tables->list[6].table_name = dtd.suffixed_table_name, tables->list[6].fk_name =
     "XFK6TRACKING2976", tables->list[7].table_name = dtd.suffixed_table_name,
     tables->list[7].fk_name = "XFK7TRACKING2976", tables->list[8].table_name = dtd
     .suffixed_table_name, tables->list[8].fk_name = "XFK7TRACKING2976"
    ENDIF
   ENDIF
   IF (dtd.table_name="CHARGE")
    tables->list[9].exist = "Y", tables->list[10].exist = "Y"
    IF (currdb="ORACLE")
     tables->list[9].table_name = dtd.full_table_name, tables->list[9].fk_name = "XFK4CHARGE", tables
     ->list[10].table_name = dtd.full_table_name,
     tables->list[10].fk_name = "XFK4CHARGE$C"
    ELSE
     tables->list[9].table_name = dtd.suffixed_table_name, tables->list[9].fk_name = "XFK4CHARGE1156",
     tables->list[10].table_name = dtd.suffixed_table_name,
     tables->list[10].fk_name = "XFK4CHARGE1156"
    ENDIF
   ENDIF
   IF (dtd.table_name="SN_CHARGE_DETAIL")
    tables->list[11].exist = "Y", tables->list[12].exist = "Y"
    IF (currdb="ORACLE")
     tables->list[11].table_name = dtd.full_table_name, tables->list[11].fk_name =
     "XFK2SN_CHARGE_DETAIL", tables->list[12].table_name = dtd.full_table_name,
     tables->list[12].fk_name = "XFK2SN4CHARGE_DETAIL$C"
    ELSE
     tables->list[11].table_name = dtd.suffixed_table_name, tables->list[11].fk_name =
     "XFK2SN_CHARG6806", tables->list[12].table_name = dtd.suffixed_table_name,
     tables->list[12].fk_name = "XFK2SN_CHARG6806"
    ENDIF
   ENDIF
   IF (dtd.table_name="HIM_PV_PHYSICIAN")
    tables->list[13].exist = "Y", tables->list[14].exist = "Y"
    IF (currdb="ORACLE")
     tables->list[13].table_name = dtd.full_table_name, tables->list[13].fk_name =
     "XFK1HIM_PV_PHYSICIAN", tables->list[14].table_name = dtd.full_table_name,
     tables->list[14].fk_name = "XFK1HIM_PV_PHYSICIAN$C"
    ELSE
     tables->list[13].table_name = dtd.suffixed_table_name, tables->list[13].fk_name =
     "XFK1HIM_PV_P5426", tables->list[14].table_name = dtd.suffixed_table_name,
     tables->list[14].fk_name = "XFK1HIM_PV_P5426"
    ENDIF
   ENDIF
   IF (dtd.table_name="CASE_ATTENDANCE")
    tables->list[15].exist = "Y", tables->list[16].exist = "Y"
    IF (currdb="ORACLE")
     tables->list[15].table_name = dtd.full_table_name, tables->list[15].fk_name =
     "XFK4CASE_ATTENDANCE", tables->list[16].table_name = dtd.full_table_name,
     tables->list[16].fk_name = "XFK4CASE_ATTENDANCE$C"
    ELSE
     tables->list[15].table_name = dtd.suffixed_table_name, tables->list[15].fk_name =
     "XFK4CASE_ATT1283", tables->list[16].table_name = dtd.suffixed_table_name,
     tables->list[16].fk_name = "XFK3CASE_ATT1283"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (error(rdm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = "ERROR: Select from dm_tables_doc failed"
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  GO TO dm_info_rows
 ENDIF
 SELECT INTO "nl:"
  FROM dm2_user_constraints uc,
   (dummyt d  WITH seq = 16)
  PLAN (d
   WHERE (tables->list[d.seq].exist="Y"))
   JOIN (uc
   WHERE (uc.table_name=tables->list[d.seq].table_name)
    AND (uc.constraint_name=tables->list[d.seq].fk_name))
  DETAIL
   tables->list[d.seq].fk_exists = 1
  WITH nocounter
 ;end select
 IF (error(rdm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("ERROR: could not retrieve data from dm2_user_constraints")
  CALL echorecord(readme_data)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  GO TO dm_info_rows
 ENDIF
 FOR (dm_three_cnt = 1 TO 16)
   IF ((tables->list[dm_three_cnt].fk_exists=1))
    IF (currdb="ORACLE")
     SET d_str = concat("rdb alter table ",tables->list[dm_three_cnt].table_name,
      " disable constraint ",tables->list[dm_three_cnt].fk_name," go")
    ELSEIF (currdb="DB2UDB")
     SET d_str = concat("rdb alter table ",tables->list[dm_three_cnt].table_name,
      " alter foreign key ",tables->list[dm_three_cnt].fk_name," not enforced go")
    ENDIF
    CALL echo(d_str)
    CALL parser(d_str)
    IF (error(rdm_err_msg,1) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("ERROR: Could not disable constraint ",tables->list[
      dm_three_cnt].fk_name)
    ELSE
     IF (currdb="ORACLE")
      SET d_str = concat("rdb alter TABLE ",tables->list[dm_three_cnt].table_name," drop CONSTRAINT ",
       tables->list[dm_three_cnt].fk_name," go")
     ELSEIF (currdb="DB2UDB")
      SET d_str = concat("rdb alter TABLE ",tables->list[dm_three_cnt].table_name," drop CONSTRAINT ",
       tables->list[dm_three_cnt].fk_name," go")
     ENDIF
     CALL echo(d_str)
     CALL parser(d_str)
     IF (error(rdm_err_msg,1) != 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("ERROR: Could not drop constraint ",tables->list[dm_three_cnt
       ].fk_name)
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM dm2_user_constraints uc,
   (dummyt d  WITH seq = 16)
  PLAN (d
   WHERE (tables->list[d.seq].exist="Y"))
   JOIN (uc
   WHERE (uc.table_name=tables->list[d.seq].table_name)
    AND (uc.constraint_name=tables->list[d.seq].fk_name))
  DETAIL
   dm_failed_cons = concat(dm_failed_cons," ",uc.constraint_name)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAILED: constraints ",dm_failed_cons," were not dropped.")
  GO TO exit_script
 ELSE
  COMMIT
  SET readme_data->message = "FK Constraints dropped"
 ENDIF
#dm_info_rows
 SELECT INTO "nl:"
  FROM dm_info di,
   (dummyt d  WITH seq = 16)
  PLAN (d)
   JOIN (di
   WHERE di.info_domain="OBSOLETE_CONSTRAINT"
    AND di.info_char="CONSTRAINT"
    AND (di.info_name=tables->list[d.seq].fk_name))
  DETAIL
   tables->list[d.seq].dm_info_exists = "Y"
  WITH nocounter
 ;end select
 FOR (dm_three_cnt = 1 TO 16)
   IF ((tables->list[dm_three_cnt].dm_info_exists="N"))
    INSERT  FROM dm_info di
     SET di.info_domain = "OBSOLETE_CONSTRAINT", di.info_char = "CONSTRAINT", di.info_name = tables->
      list[dm_three_cnt].fk_name
    ;end insert
   ENDIF
 ENDFOR
 IF (error(rdm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = "ERROR: could not retrieve data from dm_info on constraints"
  CALL echorecord(readme_data)
  GO TO exit_script
 ELSE
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = concat("FK Constraints dropped")
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 CALL echorecord(tables)
END GO
