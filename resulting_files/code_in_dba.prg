CREATE PROGRAM code_in:dba
 PAINT
 SET modify = system
 SET width = 132
#1000_start
 EXECUTE FROM 2000_display_window TO 2099_display_window_exit
 EXECUTE FROM 3000_initialize TO 3099_initialize_exit
 EXECUTE FROM 3000_contrib_source TO 3099_contrib_source_exit
 EXECUTE FROM 4000_load_coded_values TO 4099_load_coded_values_exit
 EXECUTE FROM 5000_insert_coded_values TO 5099_insert_coded_values_exit
 EXECUTE FROM 4000_load_code_set TO 4099_load_code_set_exit
 EXECUTE FROM 4000_load_code TO 4099_load_code_exit
 EXECUTE FROM 4000_load_code_alias TO 4099_load_code_alias_exit
 EXECUTE FROM 5000_insert_code_value_set TO 5099_insert_code_value_set_exit
 EXECUTE FROM 9000_commit TO 9099_commit_exit
 EXECUTE FROM 5000_insert_code_value TO 5099_insert_code_value_exit
 EXECUTE FROM 9000_commit TO 9099_commit_exit
 EXECUTE FROM 5000_insert_code_value_alias TO 5099_insert_code_value_alias_exit
 EXECUTE FROM 9000_commit TO 9099_commit_exit
 EXECUTE FROM 6000_upt_coded_values TO 6099_upt_coded_values_exit
 EXECUTE FROM 9000_commit TO 9099_commit_exit
 GO TO 9999_end
#2000_display_window
 CALL box(7,35,15,85)
 CALL video(r)
 CALL text(8,36,"            ***  Code Conversion  ***            ")
 CALL video(n)
 CALL text(11,49,"Starting...")
 CALL text(23,1," ")
 CALL video(r)
 CALL text(14,36,"            ***  Code Conversion  ***            ")
 CALL video(n)
 EXECUTE FROM 9000_start_log TO 9099_start_log_exit
#2099_display_window_exit
#3000_initialize
 CALL clear(11,49,33)
 CALL text(11,49,"Initializing...")
 CALL text(23,1," ")
 SET nbr_code_sets = 0
 SET nbr_codes = 0
 SET nbr_code_alias = 0
 SET nbr_coded_values = 0
 SET code_value = 0
 SET code_set_in = 0
 SET code_value_in = fillstring(3," ")
 SET code_value_ret = 0
 SET conversion_contrib = 0
 SET active_type_cd = 0
 SET contributor_source_cd = 0
 SET status_cd = 0
 SET cache_ind = 0
 SET extension_ind = 0
 SET add_access_ind = 0
 SET chg_access_ind = 0
 SET del_access_ind = 0
 SET inq_access_ind = 0
 SET error_message = fillstring(100," ")
 SET cerner_user = 1406
 RECORD code_set(
   1 list[1000]
     2 code_set = i4
     2 code_set_disp = c12
     2 code_set_descr = c20
     2 code_set_table_name = c40
     2 code_set_cache_flag = c3
     2 code_max_size = i4
     2 code_source = c40
     2 code_display_format = c24
     2 code_set_extent_flag = c3
     2 code_set_high_value = c3
     2 code_set_status_cd = c3
     2 code_user_define_flag = c3
     2 code_set_definition = c40
     2 updt_dt_tm = dq8
     2 updt_centi = c2
     2 code_set_add_access_cd = c3
     2 code_set_chg_access_cd = c3
     2 code_set_del_access_cd = c3
     2 code_set_inq_access_cd = c3
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_id = f8
     2 updt_task = i4
 )
 RECORD code(
   1 list[1000]
     2 code_set = i4
     2 code_value = c3
     2 code_disp = c12
     2 code_disp_key = c12
     2 code_descr = c20
     2 code_definition = c40
     2 collating_seq = i4
     2 code_status_cd = c3
     2 updt_dt_tm = dq8
     2 updt_centi = c2
 )
 RECORD code_alias(
   1 list[1000]
     2 code_alias_type_cd = c3
     2 code_alias = c48
     2 code_set = i4
     2 code_value = c3
     2 code_status_cd = c3
     2 updt_dt_tm = dq8
     2 updt_centi = c2
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_id = f8
     2 updt_task = i4
 )
 RECORD coded_values(
   1 list[1000]
     2 code_set = i4
     2 code_alias = c48
     2 code_value = f8
 )
 EXECUTE FROM 9000_initialize_log TO 9099_initialize_log_exit
#3099_initialize_exit
#3000_contrib_source
 CALL clear(11,49,33)
 CALL text(11,49,"Load/Insert Contrib Source...")
 CALL text(23,1," ")
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=73
   AND cv.cdf_meaning="OCFCONV"
  DETAIL
   conversion_contrib = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_message = "OCFCONV Meaning and Code Value not found"
  EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
  INSERT  FROM common_data_foundation cdf
   SET cdf.code_set = 73, cdf.cdf_meaning = "OCFCONV", cdf.display = "OCF Conversion",
    cdf.definition = "Used by CODE_CONV to determine contributor_source_cd", cdf.updt_dt_tm =
    cnvtdatetime(curdate,curtime), cdf.updt_id = cerner_user,
    cdf.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_message = "%FATAL ERROR - Unable to add OCFCONV cdf_meaning"
   EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
   GO TO 9999_end
  ENDIF
  SELECT INTO "nl:"
   y = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    conversion_contrib = cnvtreal(y)
   WITH format, nocounter
  ;end select
  INSERT  FROM code_value cv
   SET cv.code_value = conversion_contrib, cv.code_set = 73, cv.cdf_meaning = "OCFCONV",
    cv.primary_ind = 0, cv.display = "OCF Conversion", cv.display_key = "OCF CONVERSION",
    cv.description = "Contributor_source_cd for OCF Conversion", cv.definition =
    "Contributor_source_cd for v400 to v500 Conversion", cv.collation_seq = 0,
    cv.active_type_cd = 0, cv.active_ind = 1, cv.active_dt_tm = cnvtdatetime(curdate,curtime),
    cv.inactive_dt_tm = null, cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_id = cerner_user,
    cv.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_message = "%FATAL ERROR - Unable to add OCFCONV code_value"
   EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
   GO TO 9999_end
  ELSE
   SET error_message = "OCFCONV Meaning and Code Value inserted"
   EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
  ENDIF
 ELSE
  SET error_message = "OCFCONV Meaning and Code Value loaded"
  EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
 ENDIF
#3099_contrib_source_exit
#4000_load_coded_values
 CALL clear(11,49,33)
 CALL text(11,49,"Load coded values...")
 CALL text(23,1," ")
 SELECT INTO "nl:"
  cv.*
  FROM cv_load cv
  WHERE ((cv.code_set=48) OR (cv.code_set=73))
  DETAIL
   nbr_coded_values = (nbr_coded_values+ 1)
   IF (mod(nbr_coded_values,1000)=1
    AND nbr_coded_values != 1)
    stat = alter(code->list,(nbr_coded_values+ 1000))
   ENDIF
   code->list[nbr_coded_values].code_set = cv.code_set, code->list[nbr_coded_values].code_value = cv
   .code_value, code->list[nbr_coded_values].code_disp = cv.code_disp,
   code->list[nbr_coded_values].code_disp_key = cv.code_disp_key, code->list[nbr_coded_values].
   code_descr = cv.code_descr, code->list[nbr_coded_values].code_definition = cv.code_definition,
   code->list[nbr_coded_values].collating_seq = cv.collating_seq, code->list[nbr_coded_values].
   code_status_cd = cv.code_status_cd, code->list[nbr_coded_values].updt_dt_tm = cnvtdatetime(curdate,
    curtime),
   code->list[nbr_coded_values].updt_centi = cv.updt_centi
  WITH nocounter
 ;end select
 EXECUTE FROM 9000_load_coded_values_log TO 9099_load_coded_values_log_exit
#4099_load_coded_values_exit
#4000_load_code_set
 CALL clear(11,49,33)
 CALL text(11,49,"Loading CODE_SET table...")
 CALL text(23,1," ")
 SELECT INTO "nl:"
  cvs.*
  FROM cvs_load cvs
  WHERE cvs.code_set >= 0
  DETAIL
   nbr_code_sets = (nbr_code_sets+ 1)
   IF (mod(nbr_code_sets,1000)=1
    AND nbr_code_sets != 1)
    stat = alter(code_set->list,(nbr_code_sets+ 1000))
   ENDIF
   code_set->list[nbr_code_sets].code_set = cvs.code_set, code_set->list[nbr_code_sets].code_set_disp
    = cvs.code_set_disp, code_set->list[nbr_code_sets].code_set_descr = cvs.code_set_descr,
   code_set->list[nbr_code_sets].code_set_table_name = cvs.code_set_table_name, code_set->list[
   nbr_code_sets].code_set_cache_flag = cvs.code_set_cache_flag, code_set->list[nbr_code_sets].
   code_max_size = cvs.code_max_size,
   code_set->list[nbr_code_sets].code_source = cvs.code_source, code_set->list[nbr_code_sets].
   code_display_format = cvs.code_display_format, code_set->list[nbr_code_sets].code_set_extent_flag
    = cvs.code_set_extent_flag,
   code_set->list[nbr_code_sets].code_set_high_value = cvs.code_set_high_value, code_set->list[
   nbr_code_sets].code_set_status_cd = cvs.code_set_status_cd, code_set->list[nbr_code_sets].
   code_user_define_flag = cvs.code_user_define_flag,
   code_set->list[nbr_code_sets].code_set_definition = cvs.code_set_definition, code_set->list[
   nbr_code_sets].updt_dt_tm = cnvtdatetime(curdate,curtime), code_set->list[nbr_code_sets].
   updt_centi = cvs.updt_centi,
   code_set->list[nbr_code_sets].code_set_add_access_cd = cvs.code_set_add_access_cd, code_set->list[
   nbr_code_sets].code_set_chg_access_cd = cvs.code_set_chg_access_cd, code_set->list[nbr_code_sets].
   code_set_del_access_cd = cvs.code_set_del_access_cd,
   code_set->list[nbr_code_sets].code_set_inq_access_cd = cvs.code_set_inq_access_cd, code_set->list[
   nbr_code_sets].updt_applctx = cvs.updt_applctx, code_set->list[nbr_code_sets].updt_cnt = cvs
   .updt_cnt,
   code_set->list[nbr_code_sets].updt_id = cvs.updt_id, code_set->list[nbr_code_sets].updt_task = cvs
   .updt_task
  WITH nocounter
 ;end select
 EXECUTE FROM 9000_load_code_set_log TO 9099_load_code_set_log_exit
#4099_load_code_set_exit
#4000_load_code
 CALL clear(11,49,33)
 CALL text(11,49,"Loading CODE table...")
 CALL text(23,1," ")
 SELECT INTO "nl:"
  cv.*
  FROM cv_load cv
  WHERE cv.code_set >= 0
   AND cv.code_set != 48
   AND cv.code_set != 73
  DETAIL
   nbr_codes = (nbr_codes+ 1)
   IF (mod(nbr_codes,1000)=1
    AND nbr_codes != 1)
    stat = alter(code->list,(nbr_codes+ 1000))
   ENDIF
   code->list[nbr_codes].code_set = cv.code_set, code->list[nbr_codes].code_value = cv.code_value,
   code->list[nbr_codes].code_disp = cv.code_disp,
   code->list[nbr_codes].code_disp_key = cv.code_disp_key, code->list[nbr_codes].code_descr = cv
   .code_descr, code->list[nbr_codes].code_definition = cv.code_definition,
   code->list[nbr_codes].collating_seq = cv.collating_seq, code->list[nbr_codes].code_status_cd = cv
   .code_status_cd, code->list[nbr_codes].updt_dt_tm = cnvtdatetime(curdate,curtime),
   code->list[nbr_codes].updt_centi = cv.updt_centi
  WITH nocounter
 ;end select
 EXECUTE FROM 9000_load_code_log TO 9099_load_code_log_exit
#4099_load_code_exit
#4000_load_code_alias
 CALL clear(11,49,33)
 CALL text(11,49,"Loading CODE_ALIAS table...")
 CALL text(23,1," ")
 SELECT INTO "nl:"
  cva.*
  FROM cva_load cva
  WHERE cva.code_set >= 0
   AND cva.code_set != 33
   AND cva.code_set != 55
   AND cva.code_set != 88
   AND cva.code_set != 101
   AND cva.code_set != 63
  DETAIL
   nbr_code_alias = (nbr_code_alias+ 1)
   IF (mod(nbr_code_alias,1000)=1
    AND nbr_code_alias != 1)
    stat = alter(code_alias->list,(nbr_code_alias+ 1000))
   ENDIF
   code_alias->list[nbr_code_alias].code_alias_type_cd = cva.code_alias_type_cd, code_alias->list[
   nbr_code_alias].code_alias = cva.code_alias, code_alias->list[nbr_code_alias].code_set = cva
   .code_set,
   code_alias->list[nbr_code_alias].code_value = cva.code_value, code_alias->list[nbr_code_alias].
   code_status_cd = cva.code_status_cd, code_alias->list[nbr_code_alias].updt_dt_tm = cnvtdatetime(
    curdate,curtime),
   code_alias->list[nbr_code_alias].updt_centi = cva.updt_centi, code_alias->list[nbr_code_alias].
   updt_applctx = cva.updt_applctx, code_alias->list[nbr_code_alias].updt_cnt = cva.updt_cnt,
   code_alias->list[nbr_code_alias].updt_id = cva.updt_id, code_alias->list[nbr_code_alias].updt_task
    = cva.updt_task
  WITH nocounter
 ;end select
 EXECUTE FROM 9000_load_code_alias_log TO 9099_load_code_alias_log_exit
#4099_load_code_alias_exit
#5000_insert_coded_values
 CALL clear(11,49,33)
 CALL text(11,49,"Inserting coded values...")
 CALL text(23,1," ")
 FOR (x = 1 TO nbr_coded_values)
   SET code_value = 0
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     code_value = cnvtreal(y)
    WITH format, nocounter
   ;end select
   INSERT  FROM code_value cv
    SET cv.code_value = code_value, cv.code_set = code->list[x].code_set, cv.display = code->list[x].
     code_disp,
     cv.display_key = code->list[x].code_disp_key, cv.description = code->list[x].code_descr, cv
     .definition = code->list[x].code_definition,
     cv.collation_seq = code->list[x].collating_seq, cv.updt_dt_tm = cnvtdatetime(curdate,curtime),
     cv.updt_id = cerner_user,
     cv.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_message = concat("%ERROR inserting CODE_VALUE CS = ",cnvtstring(code_set->list[x].
      code_set)," CV = ",code_set->list[x].code_value," Cd = ",
     code_set->list[x].code_disp)
    EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
   ELSE
    SET coded_values->list[x].code_set = code->list[x].code_set
    SET coded_values->list[x].code_alias = code->list[x].code_value
    SET coded_values->list[x].code_value = code_value
    INSERT  FROM code_value_alias cva
     SET cva.code_set = code->list[x].code_set, cva.contributor_source_cd = conversion_contrib, cva
      .alias = code->list[x].code_value,
      cva.code_value = code_value, cva.status_cd = 0, cva.primary_ind = 0,
      cva.updt_dt_tm = cnvtdatetime(curdate,curtime), cva.updt_id = cerner_user, cva.updt_cnt = 0,
      cva.updt_applctx = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_message = concat("%ERROR inserting CODE_VALUE_ALIAS  CS = ",cnvtstring(code_set->
       list[x].code_set)," CSC = ",cnvtstring(conversion_contrib)," CVA = ",
      code->list[x].code_value," CV = ",cnvtstring(code_value))
     EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
    ENDIF
   ENDIF
 ENDFOR
 EXECUTE FROM 9000_insert_coded_values_log TO 9099_insert_coded_values_log_exit
#5099_insert_coded_values_exit
#5000_insert_code_value_set
 CALL clear(11,49,33)
 CALL text(11,49,"Inserting CODE_VALUE_SET table...")
 CALL text(23,1," ")
 FOR (x = 1 TO nbr_code_sets)
  SELECT INTO "nl:"
   cvs.*
   FROM code_value_set cvs
   WHERE (code_set->list[x].code_set=cvs.code_set)
   WITH nocounter
  ;end select
  IF (curqual=0)
   EXECUTE FROM 7000_load_indicators TO 7099_load_indicators_exit
   INSERT  FROM code_value_set cvs
    SET cvs.code_set = code_set->list[x].code_set, cvs.display = code_set->list[x].code_set_disp, cvs
     .display_key = cnvtupper(code_set->list[x].code_set_disp),
     cvs.description = code_set->list[x].code_set_descr, cvs.definition = code_set->list[x].
     code_set_definition, cvs.table_name = code_set->list[x].code_set_table_name,
     cvs.contributor = substring(1,18,code_set->list[x].code_source), cvs.cache_ind = cache_ind, cvs
     .extension_ind = extension_ind,
     cvs.add_access_ind = add_access_ind, cvs.chg_access_ind = chg_access_ind, cvs.del_access_ind =
     del_access_ind,
     cvs.inq_access_ind = inq_access_ind, cvs.updt_dt_tm = cnvtdatetime(curdate,curtime), cvs.updt_id
      = cerner_user,
     cvs.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_message = concat("%ERROR inserting CODE_VALUE_SET  CVS = ",cnvtstring(code_set->list[x
      ].code_set))
    EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
   ENDIF
  ENDIF
 ENDFOR
 EXECUTE FROM 9000_insert_code_value_set_log TO 9099_insert_code_value_set_log_exit
#5099_insert_code_value_set_exit
#5000_insert_code_value
 CALL clear(11,49,33)
 CALL text(11,49,"Inserting CODE_VALUE table...")
 CALL text(23,1," ")
 FOR (x = 1 TO nbr_codes)
   SET code_value = 0
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     code_value = cnvtreal(y)
    WITH format, nocounter
   ;end select
   CALL find_code_value(48,code->list[x].code_status_cd)
   SET active_type_cd = code_value_ret
   INSERT  FROM code_value cv
    SET cv.code_value = code_value, cv.code_set = code->list[x].code_set, cv.display = code->list[x].
     code_disp,
     cv.display_key = code->list[x].code_disp_key, cv.description = code->list[x].code_descr, cv
     .definition = code->list[x].code_definition,
     cv.collation_seq = code->list[x].collating_seq, cv.active_type_cd = active_type_cd, cv
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     cv.updt_id = cerner_user, cv.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_message = concat("%ERROR inserting CODE_VALUE  CS = ",cnvtstring(code_set->list[x].
      code_set)," CD = ",code->list[x].code_disp)
    EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
   ELSE
    INSERT  FROM code_value_alias cva
     SET cva.code_set = code->list[x].code_set, cva.contributor_source_cd = conversion_contrib, cva
      .alias = code->list[x].code_value,
      cva.code_value = code_value, cva.status_cd = active_type_cd, cva.updt_id = cerner_user,
      cva.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_message = concat("%ERROR inserting CODE_VALUE_ALIAS  CS = ",cnvtstring(code_set->
       list[x].code_set)," CSC = ",cnvtstring(conversion_contrib)," CVA = ",
      code->list[x].code_value," CV = ",cnvtstring(code_value))
     EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
    ENDIF
   ENDIF
 ENDFOR
 EXECUTE FROM 9000_insert_code_value_log TO 9099_insert_code_value_log_exit
#5099_insert_code_value_exit
#5000_insert_code_value_alias
 CALL clear(11,49,33)
 CALL text(11,49,"Inserting CODE_VALUE_ALIAS...")
 CALL text(23,1," ")
 FOR (x = 1 TO nbr_code_alias)
   SET code_value = 0
   SELECT INTO "nl:"
    cva.code_value
    FROM code_value_alias cva
    WHERE (cva.code_set=code_alias->list[x].code_set)
     AND (cva.alias=code_alias->list[x].code_value)
     AND cva.contributor_source_cd=conversion_contrib
    DETAIL
     code_value = cva.code_value
    WITH nocounter
   ;end select
   IF (code_value=0)
    SET error_message = concat("%ERROR inserting CODE_VALUE_ALIAS  CS = ",cnvtstring(code_alias->
      list[x].code_set)," CV = ",cnvtstring(code_value)," CVA = ",
     code_alias->list[x].code_alias)
    EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
   ELSE
    CALL find_code_value(73,code_alias->list[x].code_alias_type_cd)
    SET contributor_source_cd = code_value_ret
    CALL find_code_value(48,code_alias->list[x].code_status_cd)
    SET status_cd = code_value_ret
    INSERT  FROM code_value_alias cva
     SET cva.code_set = code_alias->list[x].code_set, cva.contributor_source_cd =
      contributor_source_cd, cva.alias = code_alias->list[x].code_alias,
      cva.code_value = code_value, cva.status_cd = status_cd, cva.primary_ind = 0,
      cva.updt_dt_tm = cnvtdatetime(curdate,curtime), cva.updt_id = 0, cva.updt_task = 0,
      cva.updt_cnt = 0, cva.updt_applctx = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_message = concat("%ERROR inserting CODE_VALUE_ALIAS  CS = ",cnvtstring(code_alias->
       list[x].code_set)," CV =  ",cnvtstring(code_value)," CVA =  ",
      code_alias->list[x].code_alias)
     EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
    ENDIF
   ENDIF
 ENDFOR
 EXECUTE FROM 9000_insert_code_value_alias_log TO 9099_insert_code_value_alias_log_exit
#5099_insert_code_value_alias_exit
#6000_upt_coded_values
 CALL clear(11,49,33)
 CALL text(11,49,"Updating coded values...")
 CALL text(23,1," ")
 FOR (x = 1 TO nbr_coded_values)
   SET active_type_cd = 0
   SELECT INTO "nl:"
    cv.*
    FROM cv_load cv
    WHERE (cv.code_set=coded_values->list[x].code_set)
     AND (cv.code_value=coded_values->list[x].code_alias)
    DETAIL
     code->list[x].code_set = cv.code_set, code->list[x].code_value = cv.code_value, code->list[x].
     code_disp = cv.code_disp,
     code->list[x].code_disp_key = cv.code_disp_key, code->list[x].code_descr = cv.code_descr, code->
     list[x].code_definition = cv.code_definition,
     code->list[x].collating_seq = cv.collating_seq, code->list[x].code_status_cd = cv.code_status_cd,
     code->list[x].updt_dt_tm = cnvtdatetime(curdate,curtime),
     code->list[x].updt_centi = cv.updt_centi
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_message = concat("%ERROR updating CODE_VALUE  CS = ",cnvtstring(code->list[x].code_set
      )," CD = ",code->list[x].code_disp)
    EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
   ELSE
    CALL find_code_value(48,code->list[x].code_status_cd)
    SET active_type_cd = code_value_ret
    UPDATE  FROM code_value cv
     SET cv.active_type_cd = active_type_cd
     WHERE (cv.code_value=coded_values->list[x].code_value)
     WITH nocounter
    ;end update
    UPDATE  FROM code_value_alias cva
     SET cva.status_cd = active_type_cd
     WHERE (cva.code_set=code->list[x].code_set)
      AND cva.contributor_source_cd=0
      AND (cva.alias=code->list[x].code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_message = concat("%ERROR updating CODE_VALUE  CS = ",cnvtstring(code->list[x].
       code_set))
     EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
    ENDIF
   ENDIF
 ENDFOR
 EXECUTE FROM 9000_upt_coded_values_log TO 9099_upt_coded_values_log_exit
#6099_upt_coded_values_exit
#7000_load_indicators
 SET cache_ind = 0
 SET extension_ind = 0
 SET add_access_ind = 0
 SET chg_access_ind = 0
 SET del_access_ind = 0
 SET inq_access_ind = 0
 CASE (code_set->list[x].code_set_cache_flag)
  OF "AAA":
   SET cache_ind = 1
  ELSE
   SET cache_ind = 0
 ENDCASE
 CASE (code_set->list[x].code_set_extent_flag)
  OF "AAA":
   SET extension_ind = 1
  ELSE
   SET extension_ind = 0
 ENDCASE
 CASE (code_set->list[x].code_set_add_access_cd)
  OF "AAA":
   SET add_access_ind = 1
  ELSE
   SET add_access_ind = 0
 ENDCASE
 CASE (code_set->list[x].code_set_chg_access_cd)
  OF "AAA":
   SET chg_access_ind = 1
  ELSE
   SET chg_access_ind = 0
 ENDCASE
 CASE (code_set->list[x].code_set_del_access_cd)
  OF "AAA":
   SET del_access_ind = 1
  ELSE
   SET del_access_ind = 0
 ENDCASE
 CASE (code_set->list[x].code_set_inq_access_cd)
  OF "AAA":
   SET inq_access_ind = 1
  ELSE
   SET inq_access_ind = 0
 ENDCASE
#7099_load_indicators_exit
#7000_commit_yn
 CALL text(24,02,"COMMIT   (Y/N)")
 CALL accept(24,17,"A;CU"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
#7099_commit_yn_exit
#9000_start_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, "/******************** Code Conversion Log File ********************\", row + 1,
   " ", row + 1, col 01,
   "Date - ", curdate, row + 1,
   col 01, "User - ", curuser,
   row + 1, col 01, "Program - CODE_CONV (IMPORT)",
   row + 1, " ", row + 1,
   col 01, curtime3, " - Started"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading
 ;end select
#9099_start_log_exit
#9000_initialize_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime3, " - Variables Initialized"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_initialize_log_exit
#9000_load_coded_values_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime3, " - Coded Values loaded for codeset 48 and 73"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_load_coded_values_log_exit
#9000_insert_coded_values_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime3, " - Coded Values inserted for codeset 48 and 73"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_insert_coded_values_log_exit
#9000_load_code_set_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime3, " - Number of rows loaded from CVS_LOAD table is ",
   nbr_code_sets"#####"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_load_code_set_log_exit
#9000_load_code_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime3, " - Number of rows loaded from CV_LOAD table is ",
   nbr_codes"#####"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_load_code_log_exit
#9000_load_code_alias_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime3, " - Number of rows loaded from CVA_LOAD table is ",
   nbr_code_alias"#####"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_load_code_alias_log_exit
#9000_insert_code_value_set_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime3, " - Insert into CODE_VALUE_SET table completed"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_insert_code_value_set_log_exit
#9000_insert_code_value_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime3, " - Insert into CODE_VALUE table completed"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_insert_code_value_log_exit
#9000_insert_code_value_alias_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime3, " - Insert into CODE_VALUE_ALIAS table completed"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_insert_code_value_alias_log_exit
#9000_upt_coded_values_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime3, " - Coded values updated for 48 and 73",
   row + 1, col 01, curtime3,
   " - Conversion Completed", row + 1, " ",
   row + 1, col 01, "/******************** Code Conversion Log File ********************\"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_upt_coded_values_log_exit
#9000_log_insert_error
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime3, " - ",
   error_message
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_log_insert_error_exit
#9000_commit
 COMMIT
#9099_commit_exit
 SUBROUTINE find_code_value(code_set_sub,code_value_sub)
  SET code_value_ret = 0
  FOR (z = 1 TO nbr_coded_values)
    IF ((code_set_sub=coded_values->list[z].code_set)
     AND (code_value_sub=coded_values->list[z].code_alias))
     SET code_value_ret = coded_values->list[z].code_value
     SET z = nbr_coded_values
    ENDIF
  ENDFOR
 END ;Subroutine
#9999_end
 CALL clear(11,49,33)
 CALL text(11,49,"Code Conversion Completed")
 CALL text(23,1," ")
END GO
