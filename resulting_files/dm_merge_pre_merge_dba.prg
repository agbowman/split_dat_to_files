CREATE PROGRAM dm_merge_pre_merge:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  FREE SET reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD code_value(
   1 list[100]
     2 type = c3
     2 id = f8
     2 code_value = f8
     2 code_set = i4
     2 cdf_meaning = c12
     2 display = c40
     2 display_key = c40
     2 description = c60
     2 definition = c100
     2 primary_ind = i2
     2 collation_seq = i4
     2 active_type_disp = c40
     2 active_ind = i2
     2 active_dt_tm = dq8
     2 inactive_dt_tm = dq8
     2 data_status_disp = c40
     2 data_status_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_cnt = i4
     2 updt_task = i4
     2 updt_applctx = i4
     2 new_code_value = f8
 )
 RECORD active_type_cd(
   1 list[100]
     2 cdf_meaning = c12
     2 code_value = f8
 )
 RECORD data_status_cd(
   1 list[100]
     2 cdf_meaning = c12
     2 code_value = f8
 )
 SET v_source_id = request->env_source_id
 SET v_target_id = request->env_target_id
 SET database_link = request->db_link
 SET log_cnt = 0
 SET error_message1 = fillstring(80," ")
 SET error_message2 = fillstring(80," ")
 SET error_message3 = fillstring(80," ")
 SET parser_buffer[100] = fillstring(132," ")
 SET parser_number = 0
 SET nbr_code_values = 0
 SET nbr_active_type_cd = 0
 SET nbr_data_status_cd = 0
 SET nbr_env_src = 0
 SET new_code_value = 0
 SET code_values_yn = "Y"
 SET code_value_ret = 0
 SET display_key_ret = fillstring(40," ")
 SET active_typ_cd = 0
 SET data_stat_cd = 0
 SET updt_id = 1594
 SET updt_task = 1594
 SET updt_applctx = 1594
 SELECT INTO "nl:"
  c.display_key, c.code_value
  FROM code_value c
  WHERE c.code_set=48
  DETAIL
   nbr_active_type_cd = (nbr_active_type_cd+ 1), active_type_cd->list[nbr_active_type_cd].cdf_meaning
    = c.cdf_meaning, active_type_cd->list[nbr_active_type_cd].code_value = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.display_key, c.code_value
  FROM code_value c
  WHERE c.code_set=8
  DETAIL
   nbr_data_status_cd = (nbr_data_status_cd+ 1), data_status_cd->list[nbr_data_status_cd].cdf_meaning
    = c.cdf_meaning, data_status_cd->list[nbr_data_status_cd].code_value = c.code_value
  WITH nocounter
 ;end select
 DELETE  FROM dm_env_mrg_rows
  WHERE 1=1
 ;end delete
 COMMIT
 SELECT INTO "nl:"
  a.*
  FROM all_sequences a
  WHERE a.sequence_name="DM_ENV_MRG_ROWS_SEQ"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET parser_buffer[1] = "rdb drop sequence dm_env_mrg_rows_seq go"
  CALL parser(parser_buffer[1],1)
 ENDIF
 SET parser_buffer[1] = "rdb create sequence dm_env_mrg_rows_seq start with 1 increment by 1 go"
 CALL parser(parser_buffer[1],1)
 SET parser_buffer[1] = "insert into dm_env_mrg_rows dm"
 SET parser_buffer[2] = "  (dm.id,"
 SET parser_buffer[3] = "   dm.type,"
 SET parser_buffer[4] = "   dm.code_set,"
 SET parser_buffer[5] = "   dm.code_value,"
 SET parser_buffer[6] = "   dm.cdf_meaning,"
 SET parser_buffer[7] = "   dm.display,"
 SET parser_buffer[8] = "   dm.display_key,"
 SET parser_buffer[9] = "   dm.description,"
 SET parser_buffer[10] = "   dm.definition,"
 SET parser_buffer[11] = "   dm.collation_seq,"
 SET parser_buffer[12] = "   dm.active_type_disp,"
 SET parser_buffer[13] = "   dm.active_ind,"
 SET parser_buffer[14] = "   dm.active_dt_tm,"
 SET parser_buffer[15] = "   dm.inactive_dt_tm,"
 SET parser_buffer[16] = "   dm.begin_eff_dt_tm,"
 SET parser_buffer[17] = "   dm.end_eff_dt_tm,"
 SET parser_buffer[18] = "   dm.data_status_disp,"
 SET parser_buffer[19] = "   dm.data_status_dt_tm,"
 SET parser_buffer[20] = "   dm.updt_dt_tm)"
 SET parser_buffer[21] = "   (select"
 SET parser_buffer[22] = "      id = seq(dm_env_mrg_rows_seq,nextval),"
 SET parser_buffer[23] = '      type = "CV-",'
 SET parser_buffer[24] = "      c.code_set,"
 SET parser_buffer[25] = "      c.code_value,"
 SET parser_buffer[26] = "      c.cdf_meaning,"
 SET parser_buffer[27] = "      c.display,"
 SET parser_buffer[28] = "      c.display_key,"
 SET parser_buffer[29] = "      c.description,"
 SET parser_buffer[30] = "      c.definition,"
 SET parser_buffer[31] = "      c.collation_seq,"
 SET parser_buffer[32] = "      cx.cdf_meaning,"
 SET parser_buffer[33] = "      c.active_ind,"
 SET parser_buffer[34] = "      c.active_dt_tm,"
 SET parser_buffer[35] = "      c.inactive_dt_tm,"
 SET parser_buffer[36] = "      c.begin_effective_dt_tm,"
 SET parser_buffer[37] = "      c.end_effective_dt_tm,"
 SET parser_buffer[38] = "      cy.cdf_meaning,"
 SET parser_buffer[39] = "      c.data_status_dt_tm,"
 SET parser_buffer[40] = "      c.updt_dt_tm "
 SET parser_buffer[41] = concat("from code_value@",trim(database_link)," c,")
 SET parser_buffer[42] = concat(" code_value@",trim(database_link)," cx,")
 SET parser_buffer[43] = concat(" code_value@",trim(database_link)," cy")
 SET parser_buffer[44] = "     where c.code_set in (8,48)"
 SET parser_buffer[45] = "      and cx.code_value = c.active_type_cd"
 SET parser_buffer[46] = "      and cy.code_value = c.data_status_cd"
 SET parser_buffer[47] = "    with nocounter, outerjoin=c) go"
 FOR (cnt = 1 TO 47)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET error_message1 = concat(" 4000 load : ",cnvtstring(curqual))
 SET error_message2 = " "
 SET error_message3 = " "
 CALL 9000_log(1)
 SELECT INTO "nl:"
  FROM dm_env_mrg_rows dm
  WHERE dm.type="CV-"
  DETAIL
   nbr_code_values = (nbr_code_values+ 1)
   IF (mod(nbr_code_values,100)=1
    AND nbr_code_values != 1)
    stat = alter(code_value->list,(nbr_code_values+ 100))
   ENDIF
   code_value->list[nbr_code_values].type = dm.type, code_value->list[nbr_code_values].id = dm.id,
   code_value->list[nbr_code_values].code_value = dm.code_value,
   code_value->list[nbr_code_values].code_set = dm.code_set, code_value->list[nbr_code_values].
   cdf_meaning = dm.cdf_meaning, code_value->list[nbr_code_values].display = dm.display,
   code_value->list[nbr_code_values].display_key = dm.display_key, code_value->list[nbr_code_values].
   description = dm.description, code_value->list[nbr_code_values].definition = dm.definition,
   code_value->list[nbr_code_values].collation_seq = dm.collation_seq, code_value->list[
   nbr_code_values].active_type_disp = dm.active_type_disp, code_value->list[nbr_code_values].
   active_ind = dm.active_ind,
   code_value->list[nbr_code_values].active_dt_tm = dm.active_dt_tm, code_value->list[nbr_code_values
   ].inactive_dt_tm = dm.inactive_dt_tm, code_value->list[nbr_code_values].data_status_disp = dm
   .data_status_disp,
   code_value->list[nbr_code_values].data_status_dt_tm = dm.data_status_dt_tm, code_value->list[
   nbr_code_values].updt_dt_tm = dm.updt_dt_tm, code_value->list[nbr_code_values].updt_id = 0,
   code_value->list[nbr_code_values].updt_cnt = 0, code_value->list[nbr_code_values].updt_task = 0,
   code_value->list[nbr_code_values].updt_applctx = 0
  WITH check, nocounter
 ;end select
 SET counter = 0
 FOR (x = 1 TO nbr_code_values)
   CALL find_active_type_cd(code_value->list[x].active_type_disp)
   SET active_typ_cd = code_value_ret
   CALL find_data_status_cd(code_value->list[x].data_status_disp)
   SET data_stat_cd = code_value_ret
   SELECT INTO "nl:"
    FROM dm_merge_translate d
    WHERE d.env_source_id=v_source_id
     AND d.env_target_id=v_target_id
     AND d.table_name="CODE_VALUE"
     AND (d.from_value=code_value->list[x].code_value)
    DETAIL
     new_code_value = d.to_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     c.*
     FROM code_value c
     WHERE (c.code_set=code_value->list[x].code_set)
      AND (c.cdf_meaning=code_value->list[x].cdf_meaning)
     DETAIL
      new_code_value = c.code_value
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET code_value->list[x].new_code_value = new_code_value
     INSERT  FROM dm_merge_translate d
      SET d.env_source_id = v_source_id, d.env_target_id = v_target_id, d.table_name = "CODE_VALUE",
       d.from_value = code_value->list[x].code_value, d.to_value = new_code_value
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      SET error_message1 = "TRANSLATE NOT FOUND AND DUPLICATE CODE_VALUE EXISTS, TRANSLATE BUILT"
      SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
       cnvtstring(code_value->list[x].code_value),"New CV: ",
       cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].display_key
       )
      SET error_message3 = " "
      CALL 9000_log(1)
     ELSE
      SET error_message1 =
      " - %Error - Translate not found, duplicate code_value exists, translate build failed, RULE = 2"
      SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
       cnvtstring(code_value->list[x].code_value),"New CV: ",
       cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].display_key
       )
      SET error_message3 = " "
      CALL 9000_log(1)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      xyz = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_code_value = cnvtreal(xyz)
      WITH format, nocounter
     ;end select
     INSERT  FROM code_value c
      SET c.code_value = new_code_value, c.code_set = code_value->list[x].code_set, c.cdf_meaning =
       IF ((code_value->list[x].cdf_meaning > " ")) code_value->list[x].cdf_meaning
       ELSE null
       ENDIF
       ,
       c.display = code_value->list[x].display, c.display_key = code_value->list[x].display_key, c
       .description = code_value->list[x].description,
       c.definition = code_value->list[x].definition, c.collation_seq = code_value->list[x].
       collation_seq, c.active_type_cd = active_typ_cd,
       c.active_ind = code_value->list[x].active_ind, c.active_dt_tm = cnvtdatetime(code_value->list[
        x].active_dt_tm), c.inactive_dt_tm = cnvtdatetime(code_value->list[x].inactive_dt_tm),
       c.active_status_prsnl_id = 0, c.data_status_cd = data_stat_cd, c.data_status_dt_tm =
       cnvtdatetime(code_value->list[x].data_status_dt_tm),
       c.data_status_prsnl_id = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = updt_id,
       c.updt_cnt = 0, c.updt_task = updt_task, c.updt_applctx = updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      SET counter = (counter+ 1)
      SET code_value->list[x].new_code_value = new_code_value
      SET error_message1 = " ADDED CODE_VALUE, RULE = 2"
      SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
       cnvtstring(code_value->list[x].code_value),"New CV: ",
       cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].display_key
       )
      SET error_message3 = " "
      CALL 9000_log(1)
     ELSE
      SET error_message1 = " - %Error - INSERT OF CODE_VALUE FAILED, RULE = 2"
      SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
       cnvtstring(code_value->list[x].code_value),"New CV: ",
       cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].display_key
       )
      SET error_message3 = " "
      CALL 9000_log(1)
     ENDIF
     INSERT  FROM dm_merge_translate d
      SET d.env_source_id = v_source_id, d.env_target_id = v_target_id, d.table_name = "CODE_VALUE",
       d.from_value = code_value->list[x].code_value, d.to_value = new_code_value
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_message1 =
      " - %Error - Translate not found, no duplicate code_value exists, translate build failed RULE = 2"
      SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
       cnvtstring(code_value->list[x].code_value),"New CV: ",
       cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].display_key
       )
      SET error_message3 = " "
      CALL 9000_log(1)
     ENDIF
    ENDIF
   ELSE
    SET code_value->list[x].new_code_value = new_code_value
    SET error_message1 = " - %Warning - CODE VALUE ALREADY MERGED, RULE = 2"
    SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
     cnvtstring(code_value->list[x].code_value),"New CV: ",
     cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].display_key)
    SET error_message3 = " "
    CALL 9000_log(1)
   ENDIF
 ENDFOR
 COMMIT
 SELECT INTO "nl:"
  d.*
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="PRE_MERGE"
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM dm_info d
   SET d.info_domain = "DATA MANAGEMENT", d.info_name = "PRE_MERGE", d.info_number = v_source_id,
    d.info_date = cnvtdatetime(curdate,curtime3), d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d
    .updt_id = 0,
    d.updt_cnt = 0, d.updt_task = 0, d.updt_applctx = 0
   WITH nocounter
  ;end insert
 ELSE
  UPDATE  FROM dm_info d
   SET d.info_date = cnvtdatetime(curdate,curtime3), d.info_number = v_source_id, d.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    d.updt_id = 0, d.updt_cnt = 0, d.updt_task = 0,
    d.updt_applctx = 0
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="PRE_MERGE"
   WITH nocounter
  ;end update
 ENDIF
 COMMIT
 EXECUTE dm_ref_cons_cols
 EXECUTE dm_temp_constraints
 COMMIT
 SET reply->status_data.status = "S"
 SUBROUTINE 9000_log(xx)
   SET log_cnt = (log_cnt+ 1)
   IF (log_cnt=1)
    INSERT  FROM dm_merge_audit
     SET merge_dt_tm = cnvtdatetime(curdate,curtime3), sequence = log_cnt, action = "PROCESS",
      err_num = null, err_mess = null, text = "Code_Set 8, 48 Pre-Merge"
     WITH nocounter
    ;end insert
    COMMIT
    SET log_cnt = (log_cnt+ 1)
   ENDIF
   INSERT  FROM dm_merge_audit
    SET merge_dt_tm = cnvtdatetime(curdate,curtime3), sequence = log_cnt, action = "LOG",
     err_num = null, err_mess = null, text = error_message1
    WITH nocounter
   ;end insert
   SET log_cnt = (log_cnt+ 1)
   INSERT  FROM dm_merge_audit
    SET merge_dt_tm = cnvtdatetime(curdate,curtime3), sequence = log_cnt, action = "LOG",
     err_num = null, err_mess = null, text = error_message2
    WITH nocounter
   ;end insert
   SET log_cnt = (log_cnt+ 1)
   INSERT  FROM dm_merge_audit
    SET merge_dt_tm = cnvtdatetime(curdate,curtime3), sequence = log_cnt, action = "LOG",
     err_num = null, err_mess = null, text = error_message3
    WITH nocounter
   ;end insert
   COMMIT
 END ;Subroutine
 SUBROUTINE find_active_type_cd(active_type_disp_sub)
   SET code_value_ret = 0
   SET display_key_ret = fillstring(40," ")
   FOR (z = 1 TO nbr_active_type_cd)
     IF ((active_type_disp_sub=active_type_cd->list[z].cdf_meaning))
      SET code_value_ret = active_type_cd->list[z].code_value
      SET display_key_ret = active_type_cd->list[z].cdf_meaning
      SET z = nbr_active_type_cd
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE find_data_status_cd(data_status_disp_sub)
   SET code_value_ret = 0
   SET display_key_ret = fillstring(40," ")
   FOR (z = 1 TO nbr_data_status_cd)
     IF ((data_status_disp_sub=data_status_cd->list[z].cdf_meaning))
      SET code_value_ret = data_status_cd->list[z].code_value
      SET display_key_ret = data_status_cd->list[z].cdf_meaning
      SET z = nbr_data_status_cd
     ENDIF
   ENDFOR
 END ;Subroutine
END GO
