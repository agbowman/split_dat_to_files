CREATE PROGRAM dm_env_mrg_code_values
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
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
     2 alias = c255
     2 alias_type_meaning = c12
     2 primary_ind = i2
     2 contrib_src_disp = c40
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
     2 display_key = c40
     2 code_value = f8
 )
 RECORD data_status_cd(
   1 list[100]
     2 display_key = c40
     2 code_value = f8
 )
 RECORD contrib_src_cd(
   1 list[500]
     2 display = c40
     2 code_value = f8
 )
 RECORD hold(
   1 code_set[1000] = f8
 )
 SET reply->status_data.status = "F"
 EXECUTE FROM merge_code_values TO merge_code_values_exit
 SET reply->status_data.status = "S"
 GO TO end_program
#merge_code_values
 SET log_file = fillstring(30," ")
 SET log_cnt = 0
 SET error_message1 = fillstring(80," ")
 SET error_message2 = fillstring(80," ")
 SET error_message3 = fillstring(80," ")
 SET parser_buffer[100] = fillstring(132," ")
 SET parser_number = 0
 SET nbr_code_values = 0
 SET nbr_active_type_cd = 0
 SET nbr_data_status_cd = 0
 SET nbr_contrib_src_cd = 0
 SET nbr_env_src = 0
 SET new_code_value = 0
 SET code_values_yn = "Y"
 SET found_code_value = "N"
 SET code_value_ret = 0
 SET display_key_ret = fillstring(40," ")
 SET prev_code_set = 0
 SET active_typ_cd = 0
 SET data_stat_cd = 0
 SET contrb_src_cd = 0
 SET target_code_set_exists = "N"
 SET current_code_set_rule = 0
 SET current_display_key_dup_ind = 0
 SET current_cdf_meaning_dup_ind = 0
 SET current_active_ind_dup_ind = 0
 SET current_display_dup_ind = 0
 SET current_alias_dup_ind = 0
 SET total_cs_nbr = 0
 SET rule_found = "N"
 SET duplicate_cd = 0
 SET updt_id = 1594
 SET updt_task = 1594
 SET updt_applctx = 1594
 SET cv_dt_tm_cnt = 0
 SET extid_alias_type_cd = 0
 SET error_message1 = " Starting CV Merge "
 SET error_message2 = " "
 SET error_message3 = " "
 EXECUTE FROM 9000_log TO 9099_log_exit
 SELECT INTO "nl:"
  c.display_key, c.code_value
  FROM code_value c
  WHERE c.code_set=48
  DETAIL
   nbr_active_type_cd = (nbr_active_type_cd+ 1), active_type_cd->list[nbr_active_type_cd].display_key
    = c.display_key, active_type_cd->list[nbr_active_type_cd].code_value = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.display_key, c.code_value
  FROM code_value c
  WHERE c.code_set=8
  DETAIL
   nbr_data_status_cd = (nbr_data_status_cd+ 1), data_status_cd->list[nbr_data_status_cd].display_key
    = c.display_key, data_status_cd->list[nbr_data_status_cd].code_value = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.display, c.code_value
  FROM code_value c
  WHERE c.code_set=73
  DETAIL
   nbr_contrib_src_cd = (nbr_contrib_src_cd+ 1), contrib_src_cd->list[nbr_contrib_src_cd].display = c
   .display, contrib_src_cd->list[nbr_contrib_src_cd].code_value = c.code_value
  WITH nocounter
 ;end select
 SET found_code_value = "Y"
 EXECUTE FROM 6000_init_mrg_rows TO 6099_init_mrg_rows_exit
 EXECUTE FROM 4000_load_rules TO 4099_load_rules_exit
 EXECUTE FROM 4000_write_code_values TO 4099_write_code_values_exit
 SET nbr_code_values = 0
 SET error_message1 = concat(" Code_Value_Set : ",cnvtstring(request->beginning_code_set))
 SET error_message2 = " "
 SET error_message3 = " "
 EXECUTE FROM 9000_log TO 9099_log_exit
 IF (target_code_set_exists="Y")
  EXECUTE FROM 5000_load_code_values TO 5099_load_code_values_exit
  EXECUTE FROM 5000_insert_code_values TO 5099_insert_code_values_exit
  COMMIT
 ELSE
  SET error_message1 = concat(" CVS: ",cnvtstring(request->beginning_code_set))
  IF (target_code_set_exists != "Y")
   SET error_message2 = " CODE SET DOES NOT EXIST ON TARGET OR INVALID DUP INDICATORS - NOT MERGED"
  ELSE
   SET error_message2 = " INVALID CODE SET RULE - SKIPPED, NOT MERGED"
  ENDIF
  SET error_message3 = " "
  EXECUTE FROM 9000_log TO 9099_log_exit
 ENDIF
#merge_code_values_exit
#4000_load_rules
 SELECT INTO "nl:"
  c.*
  FROM code_value_set c
  WHERE (c.code_set=request->beginning_code_set)
   AND ((c.display_key_dup_ind=1) OR (((c.display_dup_ind=1) OR (((c.alias_dup_ind=1) OR (c
  .cdf_meaning_dup_ind=1)) )) ))
  DETAIL
   current_display_key_dup_ind = c.display_key_dup_ind, current_cdf_meaning_dup_ind = c
   .cdf_meaning_dup_ind, current_active_ind_dup_ind = c.active_ind_dup_ind,
   current_display_dup_ind = c.display_dup_ind, current_alias_dup_ind = c.alias_dup_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET target_code_set_exists = "N"
 ELSE
  SET target_code_set_exists = "Y"
 ENDIF
 SET current_code_set_rule = request->merge_mode_ind
#4099_load_rules_exit
#4000_write_code_values
 SET parser_buffer[1] = "insert into dm_env_mrg_rows dm"
 SET parser_buffer[2] = "  (dm.id,"
 SET parser_buffer[3] = "   dm.type,"
 SET parser_buffer[4] = "   dm.code_set,"
 SET parser_buffer[5] = "   dm.code_value,"
 SET parser_buffer[6] = "   dm.cdf_meaning,"
 SET parser_buffer[7] = "   dm.display,"
 SET parser_buffer[8] = "   dm.display_key,"
 IF (current_alias_dup_ind=1)
  SET parser_buffer[9] = "   dm.alias,"
  SET parser_buffer[10] = "   dm.alias_type_meaning,"
  SET parser_buffer[11] = "   dm.contrib_source_disp,"
  SET parser_buffer[12] = "   dm.primary_ind,"
 ENDIF
 SET parser_buffer[13] = "   dm.description,"
 SET parser_buffer[14] = "   dm.definition,"
 SET parser_buffer[15] = "   dm.collation_seq,"
 SET parser_buffer[16] = "   dm.active_type_disp,"
 SET parser_buffer[17] = "   dm.active_ind,"
 SET parser_buffer[18] = "   dm.active_dt_tm,"
 SET parser_buffer[19] = "   dm.inactive_dt_tm,"
 SET parser_buffer[20] = "   dm.begin_eff_dt_tm,"
 SET parser_buffer[21] = "   dm.end_eff_dt_tm,"
 SET parser_buffer[22] = "   dm.data_status_disp,"
 SET parser_buffer[23] = "   dm.data_status_dt_tm,"
 SET parser_buffer[24] = "   dm.updt_dt_tm)"
 SET parser_buffer[25] = "   (select"
 SET parser_buffer[26] = "      id = seq(dm_env_mrg_rows_seq,nextval),"
 SET parser_buffer[27] = '      type = "CV-",'
 SET parser_buffer[28] = "      c.code_set,"
 SET parser_buffer[29] = "      c.code_value,"
 SET parser_buffer[30] = "      c.cdf_meaning,"
 SET parser_buffer[31] = "      c.display,"
 SET parser_buffer[32] = "      c.display_key,"
 IF (current_alias_dup_ind=1)
  SET parser_buffer[33] = "      cva.alias,"
  SET parser_buffer[34] = "      cva.alias_type_meaning,"
  SET parser_buffer[35] = "      cz.display,"
  SET parser_buffer[36] = "      cva.primary_ind,"
 ENDIF
 SET parser_buffer[37] = "      c.description,"
 SET parser_buffer[38] = "      c.definition,"
 SET parser_buffer[39] = "      c.collation_seq,"
 SET parser_buffer[40] = "      cx.display_key,"
 SET parser_buffer[41] = "      c.active_ind,"
 SET parser_buffer[42] = "      c.active_dt_tm,"
 SET parser_buffer[43] = "      c.inactive_dt_tm,"
 SET parser_buffer[44] = "      c.begin_effective_dt_tm,"
 SET parser_buffer[45] = "      c.end_effective_dt_tm,"
 SET parser_buffer[46] = "      cy.display_key,"
 SET parser_buffer[47] = "      c.data_status_dt_tm,"
 SET parser_buffer[48] = "      c.updt_dt_tm "
 SET parser_buffer[49] = concat("from code_value@",trim(request->database_link)," c,")
 IF (current_alias_dup_ind=1)
  SET parser_buffer[50] = concat(" code_value_alias@",trim(request->database_link)," cva,")
 ENDIF
 SET parser_buffer[51] = concat(" code_value@",trim(request->database_link)," cx,")
 IF (current_alias_dup_ind=1)
  SET parser_buffer[52] = concat(" code_value@",trim(request->database_link)," cz,")
 ENDIF
 SET parser_buffer[53] = concat(" code_value@",trim(request->database_link)," cy")
 SET parser_buffer[54] = concat("where c.code_set = ",trim(cnvtstring(request->beginning_code_set,8))
  )
 SET parser_buffer[55] = "      and cx.code_value = c.active_type_cd"
 SET parser_buffer[56] = "      and cy.code_value = c.data_status_cd"
 IF (current_alias_dup_ind=1)
  SET parser_buffer[57] = "      and cva.code_value = c.code_value"
  SET parser_buffer[58] = "      and cz.code_value = cva.contributor_source_cd"
 ENDIF
 SET parser_buffer[59] = "    with nocounter, outerjoin=c) go"
 FOR (cnt = 1 TO 59)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET error_message1 = concat(" 4000 load : ",cnvtstring(curqual))
 SET error_message2 = " "
 SET error_message3 = " "
 EXECUTE FROM 9000_log TO 9099_log_exit
#4099_write_code_values_exit
#5000_load_code_values
 SELECT INTO "nl:"
  FROM dm_env_mrg_rows dm
  WHERE dm.type="CV-"
   AND (dm.code_set=request->beginning_code_set)
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
   code_value->list[nbr_code_values].alias = dm.alias, code_value->list[nbr_code_values].
   alias_type_meaning = dm.alias_type_meaning, code_value->list[nbr_code_values].contrib_src_disp =
   dm.contrib_source_disp,
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
#5099_load_code_values_exit
#5000_insert_code_values
 SET counter = 0
 FOR (x = 1 TO nbr_code_values)
   CALL find_active_type_cd(code_value->list[x].active_type_disp)
   SET active_typ_cd = code_value_ret
   CALL find_data_status_cd(code_value->list[x].data_status_disp)
   SET data_stat_cd = code_value_ret
   CASE (current_code_set_rule)
    OF 0:
     SELECT INTO "nl:"
      FROM dm_env_mrg_trnslt d
      WHERE (d.enviro_source=request->environment_source)
       AND d.entity_name="CODE_VALUE"
       AND d.entity_attribute="CODE_VALUE"
       AND (d.from_value=code_value->list[x].code_value)
      DETAIL
       new_code_value = d.to_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      SELECT INTO "nl:"
       xyz = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_code_value = cnvtreal(xyz)
       WITH format, nocounter
      ;end select
      INSERT  FROM dm_env_mrg_trnslt d
       SET d.enviro_source = request->environment_source, d.entity_name = "CODE_VALUE", d
        .entity_attribute = "CODE_VALUE",
        d.from_value = code_value->list[x].code_value, d.to_value = new_code_value, d.updt_dt_tm =
        cnvtdatetime(curdate,curtime3)
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_message1 = " - %Error - Translate build failed, RULE = 0"
       SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
        cnvtstring(code_value->list[x].code_value),"New CV: ",
        cnvtstring(new_code_value),"Display Key: ",code_value->list[x].display_key)
       SET error_message3 = " "
       EXECUTE FROM 9000_log TO 9099_log_exit
      ENDIF
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
        c.active_ind = code_value->list[x].active_ind, c.active_dt_tm = cnvtdatetime(code_value->
         list[x].active_dt_tm), c.inactive_dt_tm = cnvtdatetime(code_value->list[x].inactive_dt_tm),
        c.active_status_prsnl_id = 0, c.data_status_cd = data_stat_cd, c.data_status_dt_tm =
        cnvtdatetime(code_value->list[x].data_status_dt_tm),
        c.data_status_prsnl_id = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id =
        updt_id,
        c.updt_cnt = 0, c.updt_task = updt_task, c.updt_applctx = updt_applctx
       WITH nocounter
      ;end insert
      SET code_value->list[x].new_code_value = new_code_value
      SET counter = (counter+ 1)
      IF (curqual > 0)
       SET error_message1 = " ADDED CODE_VALUE, RULE = 0"
       SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
        cnvtstring(code_value->list[x].code_value),"New CV: ",
        cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
        display_key)
       SET error_message3 = " "
       EXECUTE FROM 9000_log TO 9099_log_exit
      ELSE
       SET error_message1 = " - %Error - INSERTING CODE_VALUE "
       SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
        cnvtstring(code_value->list[x].code_value),"New CV: ",
        cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
        display_key)
       SET error_message3 = " "
       EXECUTE FROM 9000_log TO 9099_log_exit
      ENDIF
      SELECT INTO "nl:"
       c.*
       FROM code_value c
       WHERE (c.code_set=code_value->list[x].code_set)
        AND (c.display_key=code_value->list[x].display_key)
       WITH nocounter
      ;end select
      IF (curqual > 1)
       SET error_message1 = " - %Warning - ADDED CODE_VALUE WITH DUPLICATE DISPLAY_KEY"
       SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
        cnvtstring(code_value->list[x].code_value),"New CV: ",
        cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
        display_key)
       SET error_message3 = " "
       EXECUTE FROM 9000_log TO 9099_log_exit
      ENDIF
     ELSE
      SET code_value->list[x].new_code_value = new_code_value
      SET error_message1 = " CODE VALUE ALREADY MERGED"
      SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
       cnvtstring(code_value->list[x].code_value),"New CV: ",
       cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].display_key
       )
      SET error_message3 = " "
      EXECUTE FROM 9000_log TO 9099_log_exit
     ENDIF
    OF 1:
     SELECT INTO "nl:"
      FROM dm_env_mrg_trnslt d
      WHERE (d.enviro_source=request->environment_source)
       AND d.entity_name="CODE_VALUE"
       AND d.entity_attribute="CODE_VALUE"
       AND (d.from_value=code_value->list[x].code_value)
      DETAIL
       new_code_value = d.to_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      IF (current_alias_dup_ind=1)
       CALL find_contrib_src_cd(code_value->list[x].contrib_src_disp)
       SET contrb_src_cd = code_value_ret
       SET parser_buffer[1] = 'select into "nl:" cva.*'
       SET parser_buffer[2] = "from code_value_alias cva"
       SET parser_buffer[3] = "where cva.code_set = code_value->list[x]->code_set"
       SET parser_buffer[4] = "  and cva.alias = code_value->list[x]->alias"
       SET parser_buffer[5] =
       "  and cva.alias_type_meaning = code_value->list[x]->alias_type_meaning"
       SET parser_buffer[6] = "  and cva.contributor_source_cd = contrb_src_cd"
       SET parser_buffer[7] = "detail"
       SET parser_buffer[8] = "  new_code_value = cva.code_value"
       SET parser_buffer[9] = "with nocounter go"
       FOR (z = 1 TO 9)
         CALL parser(parser_buffer[z],1)
       ENDFOR
      ELSE
       SET parser_buffer[1] = 'select into "nl:" c.*'
       SET parser_buffer[2] = "from code_value c"
       SET parser_buffer[3] = "where c.code_set = code_value->list[x]->code_set"
       SET parser_number = 3
       IF (current_display_key_dup_ind=1)
        SET parser_number = (parser_number+ 1)
        SET parser_buffer[parser_number] = "  and c.display_key = code_value->list[x]->display_key"
       ENDIF
       IF (current_cdf_meaning_dup_ind=1)
        IF ((code_value->list[x].cdf_meaning > " "))
         SET parser_number = (parser_number+ 1)
         SET parser_buffer[parser_number] = "  and c.cdf_meaning = code_value->list[x]->cdf_meaning"
        ELSE
         SET parser_number = (parser_number+ 1)
         SET parser_buffer[parser_number] = "  and c.cdf_meaning = NULL"
        ENDIF
       ENDIF
       IF (current_active_ind_dup_ind=1)
        SET parser_number = (parser_number+ 1)
        SET parser_buffer[parser_number] = "  and c.active_ind = code_value->list[x]->active_ind"
       ENDIF
       IF (current_display_dup_ind=1)
        SET parser_number = (parser_number+ 1)
        SET parser_buffer[parser_number] = "  and c.display = code_value->list[x]->display"
       ENDIF
       SET parser_number = (parser_number+ 1)
       SET parser_buffer[parser_number] = "detail"
       SET parser_number = (parser_number+ 1)
       SET parser_buffer[parser_number] = "  new_code_value = c.code_value"
       SET parser_number = (parser_number+ 1)
       SET parser_buffer[parser_number] = "with nocounter go"
       FOR (z = 1 TO parser_number)
         CALL parser(parser_buffer[z],1)
       ENDFOR
      ENDIF
      IF (curqual=0)
       SELECT INTO "nl:"
        xyz = seq(reference_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_code_value = cnvtreal(xyz)
        WITH format, nocounter
       ;end select
       INSERT  FROM dm_env_mrg_trnslt d
        SET d.enviro_source = request->environment_source, d.entity_name = "CODE_VALUE", d
         .entity_attribute = "CODE_VALUE",
         d.from_value = code_value->list[x].code_value, d.to_value = new_code_value, d.updt_dt_tm =
         cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_message1 = " - %Error - Translate build failed, RULE = 1"
        SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
         cnvtstring(code_value->list[x].code_value),"New CV: ",
         cnvtstring(new_code_value),"Display Key: ",code_value->list[x].display_key)
        SET error_message3 = " "
        EXECUTE FROM 9000_log TO 9099_log_exit
       ENDIF
       INSERT  FROM code_value c
        SET c.code_value = new_code_value, c.code_set = code_value->list[x].code_set, c.cdf_meaning
          =
         IF ((code_value->list[x].cdf_meaning > " ")) code_value->list[x].cdf_meaning
         ELSE null
         ENDIF
         ,
         c.display = code_value->list[x].display, c.display_key = code_value->list[x].display_key, c
         .description = code_value->list[x].description,
         c.definition = code_value->list[x].definition, c.collation_seq = code_value->list[x].
         collation_seq, c.active_type_cd = active_typ_cd,
         c.active_ind = code_value->list[x].active_ind, c.active_dt_tm = cnvtdatetime(code_value->
          list[x].active_dt_tm), c.inactive_dt_tm = cnvtdatetime(code_value->list[x].inactive_dt_tm),
         c.active_status_prsnl_id = 0, c.data_status_cd = data_stat_cd, c.data_status_dt_tm =
         cnvtdatetime(code_value->list[x].data_status_dt_tm),
         c.data_status_prsnl_id = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id =
         updt_id,
         c.updt_cnt = 0, c.updt_task = updt_task, c.updt_applctx = updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual > 0)
        SET code_value->list[x].new_code_value = new_code_value
        SET counter = (counter+ 1)
        SET error_message1 = " ADDED CODE_VALUE, RULE = 1"
        SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
         cnvtstring(code_value->list[x].code_value),"New CV: ",
         cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
         display_key)
        SET error_message3 = " "
        EXECUTE FROM 9000_log TO 9099_log_exit
        IF (current_alias_dup_ind=1)
         INSERT  FROM code_value_alias cva
          SET cva.code_value = new_code_value, cva.code_set = code_value->list[x].code_set, cva.alias
            = code_value->list[x].alias,
           cva.alias_type_meaning = code_value->list[x].alias_type_meaning, cva.primary_ind =
           code_value->list[x].primary_ind, cva.contributor_source_cd = contrb_src_cd,
           cva.updt_dt_tm = cnvtdatetime(curdate,curtime3), cva.updt_id = updt_id, cva.updt_cnt = 0,
           cva.updt_task = updt_task, cva.updt_applctx = updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual > 0)
          SET counter = (counter+ 1)
          SET code_value->list[x].new_code_value = new_code_value
          SET error_message1 = " ADDED CODE_VALUE_ALIAS, RULE = 1"
          SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set)," Old CV: ",
           cnvtstring(code_value->list[x].code_value)," New CV: ",
           cnvtstring(code_value->list[x].new_code_value)," ALIAS: ",code_value->list[x].alias)
          SET error_message3 = " "
          EXECUTE FROM 9000_log TO 9099_log_exit
         ENDIF
        ENDIF
       ELSE
        SET error_message1 = " - %Error - ADDING CODE_VALUE, RULE = 1"
        SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
         cnvtstring(code_value->list[x].code_value),"New CV: ",
         cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
         display_key)
        SET error_message3 = " "
        EXECUTE FROM 9000_log TO 9099_log_exit
       ENDIF
       SELECT INTO "nl:"
        c.*
        FROM code_value c
        WHERE (c.code_set=code_value->list[x].code_set)
         AND (c.display_key=code_value->list[x].display_key)
        WITH nocounter
       ;end select
       IF (curqual > 1)
        SET error_message1 =
        " - %Warning - PREVIOUS CODE_VALUE ADDED CREATED A DUPLICATE DISPLAY_KEY"
        SET error_message2 = " "
        SET error_message3 = " "
        EXECUTE FROM 9000_log TO 9099_log_exit
       ENDIF
      ELSE
       UPDATE  FROM code_value c
        SET c.code_set = code_value->list[x].code_set, c.cdf_meaning =
         IF ((code_value->list[x].cdf_meaning > " ")) code_value->list[x].cdf_meaning
         ELSE null
         ENDIF
         , c.display = code_value->list[x].display,
         c.display_key = code_value->list[x].display_key, c.description = code_value->list[x].
         description, c.definition = code_value->list[x].definition,
         c.collation_seq = code_value->list[x].collation_seq, c.active_type_cd = active_typ_cd, c
         .active_ind = code_value->list[x].active_ind,
         c.active_dt_tm = cnvtdatetime(code_value->list[x].active_dt_tm), c.inactive_dt_tm =
         cnvtdatetime(code_value->list[x].inactive_dt_tm), c.active_status_prsnl_id = 0,
         c.data_status_cd = data_stat_cd, c.data_status_dt_tm = cnvtdatetime(code_value->list[x].
          data_status_dt_tm), c.data_status_prsnl_id = 0,
         c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = updt_id, c.updt_cnt = 0,
         c.updt_task = updt_task, c.updt_applctx = updt_applctx
        WHERE c.code_value=new_code_value
        WITH nocounter
       ;end update
       IF (curqual > 0)
        SET counter = (counter+ 1)
        SET code_value->list[x].new_code_value = new_code_value
        SET error_message1 = " UPDATED CODE_VALUE, RULE = 1"
        SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
         cnvtstring(code_value->list[x].code_value),"New CV: ",
         cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
         display_key)
        SET error_message3 = " "
        EXECUTE FROM 9000_log TO 9099_log_exit
       ELSE
        SET error_message1 = " - %Error - UPDATING CODE_VALUE, RULE = 1"
        SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
         cnvtstring(code_value->list[x].code_value),"New CV: ",
         cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
         display_key)
        SET error_message3 = " "
        EXECUTE FROM 9000_log TO 9099_log_exit
       ENDIF
       INSERT  FROM dm_env_mrg_trnslt d
        SET d.enviro_source = request->environment_source, d.entity_name = "CODE_VALUE", d
         .entity_attribute = "CODE_VALUE",
         d.from_value = code_value->list[x].code_value, d.to_value = new_code_value, d.updt_dt_tm =
         cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_message1 = " - %Error - Translate build failed on update of code value, RULE = 1"
        SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
         cnvtstring(code_value->list[x].code_value),"New CV: ",
         cnvtstring(new_code_value),"Display Key: ",code_value->list[x].display_key)
        SET error_message3 = " "
        EXECUTE FROM 9000_log TO 9099_log_exit
       ENDIF
      ENDIF
     ELSE
      UPDATE  FROM code_value c
       SET c.code_set = code_value->list[x].code_set, c.cdf_meaning =
        IF ((code_value->list[x].cdf_meaning > " ")) code_value->list[x].cdf_meaning
        ELSE null
        ENDIF
        , c.display = code_value->list[x].display,
        c.display_key = code_value->list[x].display_key, c.description = code_value->list[x].
        description, c.definition = code_value->list[x].definition,
        c.collation_seq = code_value->list[x].collation_seq, c.active_type_cd = active_typ_cd, c
        .active_ind = code_value->list[x].active_ind,
        c.active_dt_tm = cnvtdatetime(code_value->list[x].active_dt_tm), c.inactive_dt_tm =
        cnvtdatetime(code_value->list[x].inactive_dt_tm), c.active_status_prsnl_id = 0,
        c.data_status_cd = data_stat_cd, c.data_status_dt_tm = cnvtdatetime(code_value->list[x].
         data_status_dt_tm), c.data_status_prsnl_id = 0,
        c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = updt_id, c.updt_cnt = 0,
        c.updt_task = updt_task, c.updt_applctx = updt_applctx
       WHERE c.code_value=new_code_value
       WITH nocounter
      ;end update
      IF (curqual > 0)
       SET counter = (counter+ 1)
       SET code_value->list[x].new_code_value = new_code_value
       SET error_message1 = " UPDATED CODE_VALUE, RULE = 1, TRANSLATE ALREADY EXISTS"
       SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
        cnvtstring(code_value->list[x].code_value),"New CV: ",
        cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
        display_key)
       SET error_message3 = " "
       EXECUTE FROM 9000_log TO 9099_log_exit
      ELSE
       SET error_message1 = " - %Error - UPDATING CODE_VALUE, RULE = 1, TRANSLATE ALREADY EXISTS"
       SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
        cnvtstring(code_value->list[x].code_value),"New CV: ",
        cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
        display_key)
       SET error_message3 = " "
       EXECUTE FROM 9000_log TO 9099_log_exit
      ENDIF
     ENDIF
    OF 2:
     SELECT INTO "nl:"
      FROM dm_env_mrg_trnslt d
      WHERE (d.enviro_source=request->environment_source)
       AND d.entity_name="CODE_VALUE"
       AND d.entity_attribute="CODE_VALUE"
       AND (d.from_value=code_value->list[x].code_value)
      DETAIL
       new_code_value = d.to_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      IF (current_alias_dup_ind=1)
       CALL find_contrib_src_cd(code_value->list[x].contrib_src_disp)
       SET contrb_src_cd = code_value_ret
       SET parser_buffer[1] = 'select into "nl:" cva.*'
       SET parser_buffer[2] = "from code_value_alias cva"
       SET parser_buffer[3] = "where cva.code_set = code_value->list[x]->code_set"
       SET parser_buffer[4] = "  and cva.alias = code_value->list[x]->alias"
       SET parser_buffer[5] =
       "  and cva.alias_type_meaning = code_value->list[x]->alias_type_meaning"
       SET parser_buffer[6] = "  and cva.contributor_source_cd = contrb_src_cd"
       SET parser_buffer[7] = "detail"
       SET parser_buffer[8] = "  new_code_value = cva.code_value"
       SET parser_buffer[9] = "with nocounter go"
       FOR (z = 1 TO 9)
         CALL parser(parser_buffer[z],1)
       ENDFOR
      ELSE
       SET parser_buffer[1] = 'select into "nl:" c.*'
       SET parser_buffer[2] = "from code_value c"
       SET parser_buffer[3] = "where c.code_set = code_value->list[x]->code_set"
       SET parser_number = 3
       IF (current_display_key_dup_ind=1)
        SET parser_number = (parser_number+ 1)
        SET parser_buffer[parser_number] = "  and c.display_key = code_value->list[x]->display_key"
       ENDIF
       IF (current_cdf_meaning_dup_ind=1)
        IF ((code_value->list[x].cdf_meaning > " "))
         SET parser_number = (parser_number+ 1)
         SET parser_buffer[parser_number] = "  and c.cdf_meaning = code_value->list[x]->cdf_meaning"
        ELSE
         SET parser_number = (parser_number+ 1)
         SET parser_buffer[parser_number] = "  and c.cdf_meaning = NULL"
        ENDIF
       ENDIF
       IF (current_active_ind_dup_ind=1)
        SET parser_number = (parser_number+ 1)
        SET parser_buffer[parser_number] = "  and c.active_ind = code_value->list[x]->active_ind"
       ENDIF
       IF (current_display_dup_ind=1)
        SET parser_number = (parser_number+ 1)
        SET parser_buffer[parser_number] = "  and c.display = code_value->list[x]->display"
       ENDIF
       SET parser_number = (parser_number+ 1)
       SET parser_buffer[parser_number] = "detail"
       SET parser_number = (parser_number+ 1)
       SET parser_buffer[parser_number] = "  new_code_value = c.code_value"
       SET parser_number = (parser_number+ 1)
       SET parser_buffer[parser_number] = "with nocounter go"
       FOR (z = 1 TO parser_number)
         CALL parser(parser_buffer[z],1)
       ENDFOR
      ENDIF
      IF (curqual > 0)
       SET code_value->list[x].new_code_value = new_code_value
       INSERT  FROM dm_env_mrg_trnslt d
        SET d.enviro_source = request->environment_source, d.entity_name = "CODE_VALUE", d
         .entity_attribute = "CODE_VALUE",
         d.from_value = code_value->list[x].code_value, d.to_value = new_code_value, d.updt_dt_tm =
         cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end insert
       IF (curqual > 0)
        SET error_message1 = "TRANSLATE NOT FOUND AND DUPLICATE CODE_VALUE EXISTS, TRANSLATE BUILT"
        SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
         cnvtstring(code_value->list[x].code_value),"New CV: ",
         cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
         display_key)
        SET error_message3 = " "
        EXECUTE FROM 9000_log TO 9099_log_exit
       ELSE
        SET error_message1 =
        " - %Error - Translate not found, duplicate code_value exists, translate build failed, RULE = 2"
        SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
         cnvtstring(code_value->list[x].code_value),"New CV: ",
         cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
         display_key)
        SET error_message3 = " "
        EXECUTE FROM 9000_log TO 9099_log_exit
       ENDIF
      ELSE
       SELECT INTO "nl:"
        xyz = seq(reference_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_code_value = cnvtreal(xyz)
        WITH format, nocounter
       ;end select
       INSERT  FROM dm_env_mrg_trnslt d
        SET d.enviro_source = request->environment_source, d.entity_name = "CODE_VALUE", d
         .entity_attribute = "CODE_VALUE",
         d.from_value = code_value->list[x].code_value, d.to_value = new_code_value, d.updt_dt_tm =
         cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_message1 =
        " - %Error - Translate not found, no duplicate code_value exists, translate build failed RULE = 2"
        SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
         cnvtstring(code_value->list[x].code_value),"New CV: ",
         cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
         display_key)
        SET error_message3 = " "
        EXECUTE FROM 9000_log TO 9099_log_exit
       ENDIF
       INSERT  FROM code_value c
        SET c.code_value = new_code_value, c.code_set = code_value->list[x].code_set, c.cdf_meaning
          =
         IF ((code_value->list[x].cdf_meaning > " ")) code_value->list[x].cdf_meaning
         ELSE null
         ENDIF
         ,
         c.display = code_value->list[x].display, c.display_key = code_value->list[x].display_key, c
         .description = code_value->list[x].description,
         c.definition = code_value->list[x].definition, c.collation_seq = code_value->list[x].
         collation_seq, c.active_type_cd = active_typ_cd,
         c.active_ind = code_value->list[x].active_ind, c.active_dt_tm = cnvtdatetime(code_value->
          list[x].active_dt_tm), c.inactive_dt_tm = cnvtdatetime(code_value->list[x].inactive_dt_tm),
         c.active_status_prsnl_id = 0, c.data_status_cd = data_stat_cd, c.data_status_dt_tm =
         cnvtdatetime(code_value->list[x].data_status_dt_tm),
         c.data_status_prsnl_id = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id =
         updt_id,
         c.updt_cnt = 0, c.updt_task = updt_task, c.updt_applctx = updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual > 0)
        SET counter = (counter+ 1)
        SET code_value->list[x].new_code_value = new_code_value
        SET error_message1 = " ADDED CODE_VALUE, RULE = 2"
        SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
         cnvtstring(code_value->list[x].code_value),"New CV: ",
         cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
         display_key)
        SET error_message3 = " "
        EXECUTE FROM 9000_log TO 9099_log_exit
        IF (current_alias_dup_ind=1)
         INSERT  FROM code_value_alias cva
          SET cva.code_value = new_code_value, cva.code_set = code_value->list[x].code_set, cva.alias
            = code_value->list[x].alias,
           cva.alias_type_meaning = code_value->list[x].alias_type_meaning, cva.primary_ind =
           code_value->list[x].primary_ind, cva.contributor_source_cd = contrb_src_cd,
           cva.updt_dt_tm = cnvtdatetime(curdate,curtime3), cva.updt_id = updt_id, cva.updt_cnt = 0,
           cva.updt_task = updt_task, cva.updt_applctx = updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual > 0)
          SET counter = (counter+ 1)
          SET code_value->list[x].new_code_value = new_code_value
          SET error_message1 = " ADDED CODE_VALUE_ALIAS, RULE = 2"
          SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set)," Old CV: ",
           cnvtstring(code_value->list[x].code_value)," New CV: ",
           cnvtstring(code_value->list[x].new_code_value)," ALIAS: ",code_value->list[x].alias)
          SET error_message3 = " "
          EXECUTE FROM 9000_log TO 9099_log_exit
         ENDIF
        ENDIF
       ELSE
        SET error_message1 = " - %Error - INSERT OF CODE_VALUE FAILED, RULE = 2"
        SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
         cnvtstring(code_value->list[x].code_value),"New CV: ",
         cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
         display_key)
        SET error_message3 = " "
        EXECUTE FROM 9000_log TO 9099_log_exit
       ENDIF
      ENDIF
     ELSE
      IF (current_alias_dup_ind=1)
       CALL find_contrib_src_cd(code_value->list[x].contrib_src_disp)
       SET contrb_src_cd = code_value_ret
       SET parser_buffer[1] = 'select into "nl:" cva.*'
       SET parser_buffer[2] = "from code_value_alias cva"
       SET parser_buffer[3] = "where cva.code_set = code_value->list[x]->code_set"
       SET parser_buffer[4] = "  and cva.alias = code_value->list[x]->alias"
       SET parser_buffer[5] =
       "  and cva.alias_type_meaning = code_value->list[x]->alias_type_meaning"
       SET parser_buffer[6] = "  and cva.contributor_source_cd = contrb_src_cd"
       SET parser_buffer[7] = "detail"
       SET parser_buffer[8] = "  new_code_value = cva.code_value"
       SET parser_buffer[9] = "with nocounter go"
       FOR (z = 1 TO 9)
         CALL parser(parser_buffer[z],1)
       ENDFOR
       IF (curqual=0)
        INSERT  FROM code_value_alias cva
         SET cva.code_value = new_code_value, cva.code_set = code_value->list[x].code_set, cva.alias
           = code_value->list[x].alias,
          cva.alias_type_meaning = code_value->list[x].alias_type_meaning, cva.primary_ind =
          code_value->list[x].primary_ind, cva.contributor_source_cd = contrb_src_cd,
          cva.updt_dt_tm = cnvtdatetime(curdate,curtime3), cva.updt_id = updt_id, cva.updt_cnt = 0,
          cva.updt_task = updt_task, cva.updt_applctx = updt_applctx
         WITH nocounter
        ;end insert
        IF (curqual > 0)
         SET counter = (counter+ 1)
         SET code_value->list[x].new_code_value = new_code_value
         SET error_message1 = " ADDED CODE_VALUE_ALIAS, RULE = 2"
         SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set)," Old CV: ",
          cnvtstring(code_value->list[x].code_value)," New CV: ",
          cnvtstring(code_value->list[x].new_code_value)," ALIAS: ",code_value->list[x].alias)
         SET error_message3 = " "
         EXECUTE FROM 9000_log TO 9099_log_exit
        ELSE
         SET error_message1 = " %Error - ADDING CODE_VALUE_ALIAS, RULE = 2"
         SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set)," Old CV: ",
          cnvtstring(code_value->list[x].code_value)," New CV: ",
          cnvtstring(code_value->list[x].new_code_value)," ALIAS: ",code_value->list[x].alias)
         SET error_message3 = " "
         EXECUTE FROM 9000_log TO 9099_log_exit
        ENDIF
       ENDIF
      ELSE
       SET code_value->list[x].new_code_value = new_code_value
       SET error_message1 = " - %Warning - CODE VALUE ALREADY MERGED, RULE = 2"
       SET error_message2 = concat("CVS: ",cnvtstring(code_value->list[x].code_set),"Old CV: ",
        cnvtstring(code_value->list[x].code_value),"New CV: ",
        cnvtstring(code_value->list[x].new_code_value),"Display Key: ",code_value->list[x].
        display_key)
       SET error_message3 = " "
       EXECUTE FROM 9000_log TO 9099_log_exit
      ENDIF
     ENDIF
    ELSE
     SET error_message1 = " - %Error - invalid code set rule"
     SET error_message2 = concat("CVS: ",cnvtstring(code_set_extension->list[x].code_set))
     SET error_message3 = " "
     EXECUTE FROM 9000_log TO 9099_log_exit
   ENDCASE
 ENDFOR
#5099_insert_code_values_exit
#6000_init_mrg_rows
 DELETE  FROM dm_env_mrg_rows
  WHERE 1=1
 ;end delete
 SELECT INTO "nl:"
  a.*
  FROM all_sequences a
  WHERE a.sequence_name="DM_ENV_MRG_ROWS_SEQ"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  EXECUTE FROM 6000_drop_sequence TO 6099_drop_sequence_exit
 ENDIF
 SET parser_buffer[1] = "rdb create sequence dm_env_mrg_rows_seq start with 1 increment by 1 go"
 CALL parser(parser_buffer[1],1)
#6099_init_mrg_rows_exit
#6000_drop_sequence
 SET parser_buffer[1] = "rdb drop sequence dm_env_mrg_rows_seq go"
 CALL parser(parser_buffer[1],1)
#6099_drop_sequence_exit
#9000_delete_dm_env_mrg_rows
 DELETE  FROM dm_env_mrg_rows dm
  WHERE 1=1
  WITH nocounter
 ;end delete
 COMMIT
#9099_delete_dm_env_mrg_rows_exit
#9000_log
 SET log_cnt = (log_cnt+ 1)
 IF (log_cnt=1)
  SET log_dt_tm = cnvtdatetime(curdate,curtime3)
  EXECUTE FROM 9000_start_log TO 9099_start_log_exit
  SET log_cnt = (log_cnt+ 1)
 ENDIF
 INSERT  FROM dm_env_mrg_audit
  SET mrg_dt_tm = cnvtdatetime(log_dt_tm), sequence = log_cnt, action = "LOG",
   table_name = "CODE_VALUE", err_num = null, err_mess = null,
   translate_errs = null, statement = concat(error_message1,error_message2,error_message3)
  WITH nocounter
 ;end insert
 COMMIT
#9099_log_exit
#9000_start_log
 INSERT  FROM dm_env_mrg_audit
  SET mrg_dt_tm = cnvtdatetime(log_dt_tm), sequence = log_cnt, action = "PROCESS",
   table_name = "CODE_VALUE", err_num = null, err_mess = null,
   translate_errs = null, statement = concat("Database Link: ",request->database_link,
    "  Enviro Source: ",request->environment_source,"  Beginning Code Set: ",
    cnvtstring(request->beginning_code_set),"  Ending Code Set: ",cnvtstring(request->ending_code_set
     ))
  WITH nocounter
 ;end insert
 COMMIT
#9099_start_log_exit
 SUBROUTINE find_active_type_cd(active_type_disp_sub)
   SET code_value_ret = 0
   SET display_key_ret = fillstring(40," ")
   FOR (z = 1 TO nbr_active_type_cd)
     IF ((active_type_disp_sub=active_type_cd->list[z].display_key))
      SET code_value_ret = active_type_cd->list[z].code_value
      SET display_key_ret = active_type_cd->list[z].display_key
      SET z = nbr_active_type_cd
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE find_data_status_cd(data_status_disp_sub)
   SET code_value_ret = 0
   SET display_key_ret = fillstring(40," ")
   FOR (z = 1 TO nbr_data_status_cd)
     IF ((data_status_disp_sub=data_status_cd->list[z].display_key))
      SET code_value_ret = data_status_cd->list[z].code_value
      SET display_key_ret = data_status_cd->list[z].display_key
      SET z = nbr_data_status_cd
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE find_contrib_src_cd(contrib_src_disp_sub)
   SET code_value_ret = 0
   SET display_key_ret = fillstring(40," ")
   FOR (z = 1 TO nbr_contrib_src_cd)
     IF ((contrib_src_disp_sub=contrib_src_cd->list[z].display))
      SET code_value_ret = contrib_src_cd->list[z].code_value
      SET display_key_ret = contrib_src_cd->list[z].display
      SET z = nbr_contrib_src_cd
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
