CREATE PROGRAM dm_ocd_create_admin_tables:dba
 SET param1 =  $1
 SET param2 =  $2
 SET param3 = request->output_dist
 SET dm_sys = fillstring(5," ")
 SELECT INTO "nl:"
  x = cursys
  FROM dual
  DETAIL
   dm_sys = trim(cnvtupper(x))
  WITH nocounter
 ;end select
 IF (dm_sys="AXP")
  SET fname = "dm_ocd_create_adm_tbls.com"
 ELSEIF (dm_sys="AIX")
  SET fname = "dm_ocd_create_adm_tbls.ksh"
 ENDIF
 SET dm_env_id = 0.0
 SELECT INTO "nl:"
  i.info_number
  FROM dm_info i
  WHERE i.info_domain="DATA MANAGEMENT"
   AND i.info_name="DM_ENV_ID"
  DETAIL
   dm_env_id = i.info_number
  WITH nocounter
 ;end select
 IF (dm_env_id=0.0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = "INVALID OR NONEXISTENT ENVIRONMENT_ID IN DM_INFO"
  GO TO end_program
 ENDIF
 IF (dm_sys="AIX")
  SELECT INTO value(fname)
   i.info_name
   FROM dm_info i,
    dm_environment e
   WHERE i.info_name="DM_ENV_ID"
    AND i.info_domain="DATA MANAGEMENT"
    AND i.info_number=e.environment_id
   DETAIL
    col 0, "#!/usr/bin/ksh", row + 1,
    col 0, ". $cer_mgr/.user_setup ", e.envset_string,
    row + 1, col 0, "ccl <<!",
    row + 1, col 0, "execute dm_ocd_create_adm_tbls_int '",
    param1, "','", param2,
    "','", param3, "' go"
   WITH nocounter, formfeed = none, maxrow = 1,
    maxcol = 512, format = variable
  ;end select
 ELSE
  SELECT INTO value(fname)
   d.seq
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    col 0, "$!", row + 1,
    col 0, "$set verify", row + 1,
    col 0, '$CCL :== "$CER_EXE:CCLORA.EXE"', row + 1,
    col 0, "$CCL", row + 1,
    col 0, "execute dm_ocd_create_adm_tbls_int '", param1,
    "','", param2, "','",
    param3, "' go"
   WITH nocounter, formfeed = none, format = variable,
    maxrow = 1, maxcol = 200
  ;end select
 ENDIF
 SET dclcom = fillstring(100," ")
 IF (dm_sys="AIX")
  SET dclcom = "chmod 755 $CCLUSERDIR/dm_ocd_create_adm_tbls.ksh"
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  IF (status=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Couldn't chmod dm_ocd_create_adm_tbls.ksh"
  ENDIF
  SET dclcom = "./dm_ocd_create_adm_tbls.ksh"
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
 ELSE
  SET dclcom = "@dm_ocd_create_adm_tbls.com"
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  IF (status=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Couldn't execute dm_ocd_create_adm_tbls.com"
  ENDIF
 ENDIF
 SET core_ind = 0
 SET schema_ind = 0
 SET cs_ind = 0
 SET atr_ind = 0
 SET tbl_cnt = 0
 SET parser_buffer[5] = fillstring(132," ")
 SET parser_buffer[1] = concat("select into 'nl:' u.* from user_tables@",param2," u")
 SET parser_buffer[2] = " where u.table_name in ('DM_ALPHA_*','DM_OCD_FEATURES')"
 SET parser_buffer[3] = " detail tbl_cnt = tbl_cnt + 1 with nocounter go"
 FOR (dm_cnt = 1 TO 3)
   CALL parser(parser_buffer[dm_cnt])
 ENDFOR
 IF (tbl_cnt=3)
  SET core_ind = 1
 ENDIF
 SET tbl_cnt = 0
 SET parser_buffer[5] = fillstring(132," ")
 SET parser_buffer[1] = concat("select into 'nl:' u.* from user_tables@",param2," u")
 SET parser_buffer[2] = " where u.table_name = 'DM_AFD_*'"
 SET parser_buffer[3] = "  and u.table_name not in ('DM_AFD_CODE*','DM_AFD_COMMON_DATA_FOUNDATION')"
 SET parser_buffer[4] = "detail tbl_cnt = tbl_cnt + 1 with nocounter go"
 FOR (dm_cnt = 1 TO 4)
   CALL parser(parser_buffer[dm_cnt])
 ENDFOR
 IF (tbl_cnt=6)
  SET schema_ind = 1
 ENDIF
 SET tbl_cnt = 0
 SET parser_buffer[5] = fillstring(132," ")
 SET parser_buffer[1] = concat("select into 'nl:' u.* from user_tables@",param2," u")
 SET parser_buffer[2] = "where u.table_name in ('DM_AFD_CODE*','DM_AFD_COMMON_DATA_FOUNDATION')"
 SET parser_buffer[3] = "detail tbl_cnt = tbl_cnt + 1 with nocounter go"
 FOR (dm_cnt = 1 TO 3)
   CALL parser(parser_buffer[dm_cnt])
 ENDFOR
 IF (tbl_cnt=6)
  SET cs_ind = 1
 ENDIF
 SET tbl_cnt = 0
 SET parser_buffer[5] = fillstring(132," ")
 SET parser_buffer[1] = concat("select into 'nl:' u.* from user_tables@",param2," u")
 SET parser_buffer[2] = "where u.table_name in ('DM_OCD_APP*', 'DM_OCD_TASK*', 'DM_OCD_REQUEST')"
 SET parser_buffer[3] = "detail tbl_cnt = tbl_cnt + 1 with nocounter go"
 FOR (dm_cnt = 1 TO 3)
   CALL parser(parser_buffer[dm_cnt])
 ENDFOR
 IF (tbl_cnt=5)
  SET atr_ind = 1
 ENDIF
 IF (core_ind=1
  AND schema_ind=1
  AND cs_ind=1
  AND atr_ind=1)
  SET reply->status_data.status = "S"
  SET reply->ops_event = " "
 ELSEIF (core_ind=0)
  SET reply->status_data.status = "Z"
  SET reply->ops_event = "Cannot find one of the Core OCD Admin tables"
 ELSEIF (schema_ind=0)
  SET reply->status_data.status = "Z"
  SET reply->ops_event = "Cannot find one of the Schema OCD Admin tables"
 ELSEIF (cs_ind=0)
  SET reply->status_data.status = "Z"
  SET reply->ops_event = "Cannot find one of the Codeset OCD Admin tables"
 ELSEIF (atr_ind=0)
  SET reply->status_data.status = "Z"
  SET reply->ops_event = "Cannot find one of the ATR OCD Admin tables"
 ENDIF
#end_program
END GO
