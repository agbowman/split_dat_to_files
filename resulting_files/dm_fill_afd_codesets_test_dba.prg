CREATE PROGRAM dm_fill_afd_codesets_test:dba
 SET tempstr = fillstring(255," ")
 SET cnumber = cnvtstring(afd_nbr)
 SET cdate = cnvtdatetime(curdate,curtime3)
 IF ((list->count > 0))
  SET cnt = 0
  FOR (cnt = 1 TO list->count)
    FREE SET r1
    RECORD r1(
      1 rdate = dq8
    )
    SET r1->rdate = 0
    SELECT INTO "nl:"
     dcf.schema_dt_tm
     FROM dm_feature_code_sets_env dcf
     WHERE (dcf.code_set=list->qual[cnt].code_set)
      AND dcf.feature_number=fnumber
     DETAIL
      IF ((dcf.schema_dt_tm > r1->rdate))
       r1->rdate = dcf.schema_dt_tm
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual > 0)
     INSERT  FROM dm_afd_code_value_set c
      (c.code_set, c.alpha_feature_nbr, c.feature_number,
      c.display, c.display_key, c.description,
      c.definition, c.table_name, c.contributor,
      c.owner_module, c.cache_ind, c.extension_ind,
      c.add_access_ind, c.chg_access_ind, c.del_access_ind,
      c.inq_access_ind, c.domain_qualifier_ind, c.domain_code_set,
      c.updt_dt_tm, c.updt_id, c.updt_cnt,
      c.updt_task, c.updt_applctx, c.code_set_hits,
      c.code_values_cnt, c.def_dup_rule_flag, c.cdf_meaning_dup_ind,
      c.display_key_dup_ind, c.active_ind_dup_ind, c.display_dup_ind,
      c.alias_dup_ind)(SELECT
       a.code_set, afd_nbr, fnumber,
       a.display, a.display_key, a.description,
       a.definition, a.table_name, a.contributor,
       a.owner_module, a.cache_ind, a.extension_ind,
       a.add_access_ind, a.chg_access_ind, a.del_access_ind,
       a.inq_access_ind, a.domain_qualifier_ind, a.domain_code_set,
       cnvtdatetime(cdate), a.updt_id, a.updt_cnt,
       a.updt_task, a.updt_applctx, a.code_set_hits,
       a.code_values_cnt, a.def_dup_rule_flag, a.cdf_meaning_dup_ind,
       a.display_key_dup_ind, a.active_ind_dup_ind, a.display_dup_ind,
       a.alias_dup_ind
       FROM dm_adm_code_value_set a
       WHERE a.delete_ind != 1
        AND (a.code_set=list->qual[cnt].code_set)
        AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
      WITH nocounter
     ;end insert
     SELECT INTO value(fname)
      a.*
      FROM dm_afd_code_value_set a
      WHERE a.alpha_feature_nbr=afd_nbr
       AND (a.code_set=list->qual[cnt].code_set)
      DETAIL
       def1 = fillstring(85," "), def2 = fillstring(85," "), def3 = fillstring(85," "),
       tempstr = "insert into dm_afd_code_value_set c", tempstr, row + 1,
       tempstr = "(c.code_set, c.alpha_feature_nbr,c.feature_number,c.display,c.display_key,",
       tempstr, row + 1,
       tempstr = " c.description,c.definition, c.table_name,c.contributor,", tempstr, row + 1,
       tempstr = " c.owner_module,c.cache_ind,c.extension_ind,c.add_access_ind,", tempstr, row + 1,
       tempstr = " c.chg_access_ind,c.del_access_ind,c.inq_access_ind,", tempstr, row + 1,
       tempstr = " c.domain_qualifier_ind,c.domain_code_set,", tempstr, row + 1,
       tempstr = " c.updt_dt_tm,c.updt_id,c.updt_cnt,c.updt_task,c.updt_applctx,", tempstr, row + 1,
       tempstr = " c.code_set_hits,c.code_values_cnt,c.def_dup_rule_flag,", tempstr, row + 1,
       tempstr = " c.cdf_meaning_dup_ind,c.display_key_dup_ind,c.active_ind_dup_ind,", tempstr, row
        + 1,
       tempstr = " c.display_dup_ind, c.alias_dup_ind)", tempstr, row + 1,
       tempstr = build("values( ",a.code_set,",",cnumber,",",
        fnumber,","), tempstr, row + 1,
       tempstr = build('"',trim(a.display),'",'), tempstr, row + 1,
       tempstr = build('"',trim(a.display_key),'",'), tempstr, row + 1,
       tempstr = build('"',trim(a.description),'",'), tempstr, row + 1,
       def1 = substring(1,85,a.definition), def2 = substring(86,85,a.definition), def3 = substring(
        171,85,a.definition),
       tempstr = build('"',trim(concat(def1,def2,def3)),'",'), tempstr, row + 1,
       tempstr = build('"',trim(a.table_name),'","',trim(a.contributor),'",'), tempstr, row + 1,
       tempstr = build('"',trim(a.owner_module),'",',a.cache_ind,",",
        a.extension_ind,",",a.add_access_ind), tempstr, row + 1,
       tempstr = build(",",a.chg_access_ind,",",a.del_access_ind,",",
        a.inq_access_ind), tempstr, row + 1,
       tempstr = build(",",a.domain_qualifier_ind,",",a.domain_code_set,',cnvtdatetime("',
        format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'")'), tempstr, row + 1,
       tempstr = build(",",a.updt_id,",",a.updt_cnt,",",
        a.updt_task,",",a.updt_applctx), tempstr, row + 1,
       tempstr = build(",",a.code_set_hits,",",a.code_values_cnt,",",
        a.def_dup_rule_flag), tempstr, row + 1,
       tempstr = build(",",a.cdf_meaning_dup_ind,",",a.display_key_dup_ind,","), tempstr, row + 1,
       tempstr = build(a.active_ind_dup_ind,",",a.display_dup_ind,",",a.alias_dup_ind,
        ")"), tempstr, row + 1,
       tempstr = "with nocounter go", tempstr, row + 1,
       "commit go", row + 2
      WITH nocounter, append, maxcol = 512,
       format = variable, formfeed = none, maxrow = 1
     ;end select
     INSERT  FROM dm_afd_common_data_foundation c
      (c.code_set, c.alpha_feature_nbr, c.cdf_meaning,
      c.display, c.definition, c.updt_applctx,
      c.updt_dt_tm, c.updt_id, c.updt_cnt,
      c.updt_task)(SELECT
       a.code_set, afd_nbr, a.cdf_meaning,
       a.display, a.definition, a.updt_applctx,
       cnvtdatetime(cdate), a.updt_id, a.updt_cnt,
       a.updt_task
       FROM dm_adm_common_data_foundation a
       WHERE a.delete_ind != 1
        AND (a.code_set=list->qual[cnt].code_set)
        AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
      WITH nocounter
     ;end insert
     SELECT INTO value(fname)
      a.*
      FROM dm_afd_common_data_foundation a
      WHERE a.alpha_feature_nbr=afd_nbr
       AND (a.code_set=list->qual[cnt].code_set)
      DETAIL
       tempstr = "insert into dm_afd_common_data_foundation c", tempstr, row + 1,
       tempstr = "(c.code_set, c.alpha_feature_nbr, c.cdf_meaning,", tempstr, row + 1,
       tempstr = " c.display, c.definition, c.updt_applctx, c.updt_dt_tm, ", tempstr, row + 1,
       tempstr = " c.updt_id, c.updt_cnt, c.updt_task)", tempstr, row + 1,
       tempstr = build("values (",a.code_set,",",cnumber,","), tempstr, row + 1,
       tempstr = build('"',a.cdf_meaning,'",'), tempstr, row + 1,
       tempstr = concat('"',a.display,'",'), tempstr, row + 1,
       tempstr = build('"',a.definition,'",'), tempstr, row + 1,
       tempstr = build(a.updt_applctx,","), tempstr, row + 1,
       tempstr = build('cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),',a.updt_id,",",
        a.updt_cnt,",",a.updt_task,") "), tempstr, row + 1,
       "with nocounter go", row + 1, "commit go",
       row + 2
      WITH nocounter, append, maxcol = 512,
       format = variable, formfeed = none, maxrow = 1
     ;end select
     INSERT  FROM dm_afd_code_set_extension c
      (c.code_set, c.alpha_feature_nbr, c.field_name,
      c.field_seq, c.field_type, c.field_len,
      c.field_prompt, c.field_in_mask, c.field_out_mask,
      c.validation_condition, c.validation_code_set, c.action_field,
      c.field_default, c.field_help, c.updt_task,
      c.updt_id, c.updt_cnt, c.updt_dt_tm,
      c.updt_applctx)(SELECT
       a.code_set, afd_nbr, a.field_name,
       a.field_seq, a.field_type, a.field_len,
       a.field_prompt, a.field_in_mask, a.field_out_mask,
       a.validation_condition, a.validation_code_set, a.action_field,
       a.field_default, a.field_help, a.updt_task,
       a.updt_id, a.updt_cnt, cnvtdatetime(cdate),
       a.updt_applctx
       FROM dm_adm_code_set_extension a
       WHERE a.delete_ind != 1
        AND (a.code_set=list->qual[cnt].code_set)
        AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
      WITH nocounter
     ;end insert
     SELECT INTO value(fname)
      a.*
      FROM dm_afd_code_set_extension a
      WHERE a.alpha_feature_nbr=afd_nbr
       AND (a.code_set=list->qual[cnt].code_set)
      DETAIL
       tempstr = "insert into dm_afd_code_set_extension c", tempstr, row + 1,
       tempstr = "(c.code_set, c.alpha_feature_nbr, c.field_name, ", tempstr, row + 1,
       tempstr = " c.field_seq, c.field_type, c.field_len, c.field_prompt,", tempstr, row + 1,
       tempstr = " c.field_in_mask, c.field_out_mask, c.validation_condition,", tempstr, row + 1,
       tempstr = " c.validation_code_set, c.action_field, c.field_default,", tempstr, row + 1,
       tempstr = " c.field_help, c.updt_task, c.updt_id, c.updt_cnt,", tempstr, row + 1,
       tempstr = " c.updt_dt_tm, c.updt_applctx)", tempstr, row + 1,
       tempstr = build("values (",a.code_set,",",cnumber,","), tempstr, row + 1,
       tempstr = build('"',a.field_name,'",'), tempstr, row + 1,
       tempstr = build(a.field_seq,",",a.field_type,",",a.field_len,
        ","), tempstr, row + 1,
       tempstr = build('"',a.field_prompt,'",'), tempstr, row + 1,
       tempstr = build('"',a.field_in_mask,'",'), tempstr, row + 1,
       tempstr = build('"',a.field_out_mask,'",'), tempstr, row + 1,
       tempstr = build('"',a.validation_condition,'",'), tempstr, row + 1,
       tempstr = build(a.validation_code_set,","), tempstr, row + 1,
       tempstr = build('"',a.action_field,'",'), tempstr, row + 1,
       tempstr = build('"',a.field_default,'",'), tempstr, row + 1,
       tempstr = build('"',a.field_help,'",'), tempstr, row + 1,
       tempstr = build(a.updt_task,",",a.updt_id,",",a.updt_cnt,
        ","), tempstr, row + 1,
       tempstr = build('cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),',a.updt_applctx,
        ") "), tempstr, row + 1,
       "with nocounter go", row + 1, "commit go",
       row + 2
      WITH nocounter, append, maxcol = 512,
       format = variable, formfeed = none, maxrow = 1
     ;end select
     INSERT  FROM dm_afd_code_value c
      (c.code_value, c.alpha_feature_nbr, c.code_set,
      c.cdf_meaning, c.display, c.display_key,
      c.description, c.definition, c.collation_seq,
      c.active_type_cd, c.active_ind, c.active_dt_tm,
      c.inactive_dt_tm, c.updt_dt_tm, c.updt_id,
      c.updt_cnt, c.updt_task, c.updt_applctx,
      c.begin_effective_dt_tm, c.end_effective_dt_tm, c.data_status_cd,
      c.data_status_dt_tm, c.data_status_prsnl_id, c.active_status_prsnl_id,
      c.cki)(SELECT
       a.code_value, afd_nbr, a.code_set,
       a.cdf_meaning, a.display, a.display_key,
       a.description, a.definition, a.collation_seq,
       a.active_type_cd, a.active_ind, a.active_dt_tm,
       a.inactive_dt_tm, cnvtdatetime(cdate), a.updt_id,
       a.updt_cnt, a.updt_task, a.updt_applctx,
       a.begin_effective_dt_tm, a.end_effective_dt_tm, a.data_status_cd,
       a.data_status_dt_tm, a.data_status_prsnl_id, a.active_status_prsnl_id,
       a.cki
       FROM dm_adm_code_value a
       WHERE a.delete_ind != 1
        AND (a.code_set=list->qual[cnt].code_set)
        AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0
        AND  NOT ( EXISTS (
       (SELECT
        "X"
        FROM dm_code_value c
        WHERE c.schema_date=cnvtdatetime(rev_date)
         AND a.code_set=c.code_set
         AND a.cki=c.cki
         AND a.cdf_meaning=c.cdf_meaning
         AND a.active_ind=c.active_ind))))
      WITH nocounter
     ;end insert
     SELECT INTO value(fname)
      a.*
      FROM dm_afd_code_value a
      WHERE a.alpha_feature_nbr=afd_nbr
       AND (a.code_set=list->qual[cnt].code_set)
      DETAIL
       tempstr = "insert into dm_afd_code_value c", tempstr, row + 1,
       tempstr = "(c.code_value, c.alpha_feature_nbr,c.code_set, c.cdf_meaning,", tempstr, row + 1,
       tempstr = "c.display, c.display_key, c.description,c.definition,", tempstr, row + 1,
       tempstr = "c.collation_seq,c.active_type_cd,c.active_ind,c.active_dt_tm,", tempstr, row + 1,
       tempstr = "c.inactive_dt_tm,c.updt_dt_tm,c.updt_id,", tempstr, row + 1,
       tempstr = "c.updt_cnt,c.updt_task,c.updt_applctx,c.begin_effective_dt_tm,", tempstr, row + 1,
       tempstr = "c.end_effective_dt_tm,c.data_status_cd,c.data_status_dt_tm,", tempstr, row + 1,
       tempstr = "c.data_status_prsnl_id,c.active_status_prsnl_id,c.cki)", tempstr, row + 1,
       tempstr = build("values (",a.code_value,",",cnumber,",",
        a.code_set,","), tempstr, row + 1,
       tempstr = build('"',a.cdf_meaning,'",'), tempstr, row + 1,
       tempstr = build('"',a.display,'",'), tempstr, row + 1,
       tempstr = build('"',a.display_key,'",'), tempstr, row + 1,
       tempstr = build('"',a.description,'",'), tempstr, row + 1,
       tempstr = build('"',a.definition,'",'), tempstr, row + 1,
       tempstr = build(a.collation_seq,",",a.active_type_cd,",",a.active_ind,
        ","), tempstr, row + 1,
       tempstr = build('cnvtdatetime("',format(a.active_dt_tm,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'),
       tempstr, row + 1,
       tempstr = build('cnvtdatetime("',format(a.inactive_dt_tm,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'),
       tempstr, row + 1,
       tempstr = build('cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'), tempstr, row
        + 1,
       tempstr = build(a.updt_id,",",a.updt_cnt,","), tempstr, row + 1,
       tempstr = build(a.updt_task,",",a.updt_applctx,","), tempstr, row + 1,
       tempstr = build('cnvtdatetime("',format(a.begin_effective_dt_tm,"dd-mmm-yyyy hh:mm:ss;;D"),
        '"),'), tempstr, row + 1,
       tempstr = build('cnvtdatetime("',format(a.end_effective_dt_tm,"dd-mmm-yyyy hh:mm:ss;;D"),'"),',
        a.data_status_cd,","), tempstr, row + 1,
       tempstr = build('cnvtdatetime("',format(a.data_status_dt_tm,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'),
       tempstr, row + 1,
       tempstr = build(a.data_status_prsnl_id,",",a.active_status_prsnl_id,","), tempstr, row + 1,
       tempstr = build('"',a.cki,'")'), tempstr, row + 1,
       "with nocounter go", row + 1, "commit go",
       row + 2
      WITH nocounter, append, maxcol = 512,
       format = variable, formfeed = none, maxrow = 1
     ;end select
     INSERT  FROM dm_afd_code_value_alias c
      (c.code_set, c.alpha_feature_nbr, c.alias,
      c.contributor_source_cd, c.code_value, c.primary_ind,
      c.updt_dt_tm, c.updt_id, c.updt_task,
      c.updt_cnt, c.updt_applctx, c.alias_type_meaning)(SELECT
       a.code_set, afd_nbr, a.alias,
       a.contributor_source_cd, a.code_value, a.primary_ind,
       cnvtdatetime(cdate), a.updt_id, a.updt_task,
       a.updt_cnt, a.updt_applctx, a.alias_type_meaning
       FROM dm_adm_code_value_alias a
       WHERE a.delete_ind != 1
        AND (a.code_set=list->qual[cnt].code_set)
        AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
      WITH nocounter
     ;end insert
     SELECT INTO value(fname)
      a.*
      FROM dm_afd_code_value_alias a
      WHERE a.alpha_feature_nbr=afd_nbr
       AND (a.code_set=list->qual[cnt].code_set)
      DETAIL
       tempstr = "insert into dm_afd_code_value_alias c ", tempstr, row + 1,
       tempstr = "(c.code_set,c.alpha_feature_nbr,c.alias,", tempstr, row + 1,
       tempstr = "c.contributor_source_cd,c.code_value,c.primary_ind,", tempstr, row + 1,
       tempstr = "c.updt_dt_tm,c.updt_id,c.updt_task,c.updt_cnt,", tempstr, row + 1,
       tempstr = "c.updt_applctx,c.alias_type_meaning )", tempstr, row + 1,
       tempstr = build("values(",a.code_set,",",cnumber,","), tempstr, row + 1,
       tempstr = build('"',a.alias,'",'), tempstr, row + 1,
       tempstr = build(a.contributor_source_cd,",",a.code_value,",",a.primary_ind,
        ","), tempstr, row + 1,
       tempstr = build('cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'), tempstr, row
        + 1,
       tempstr = build(a.updt_id,",",a.updt_task,",",a.updt_cnt,
        ","), tempstr, row + 1,
       tempstr = build(a.updt_applctx,","), tempstr, row + 1,
       tempstr = build('"',a.alias_type_meaning,'" ) '), tempstr, row + 1,
       "with nocounter go", row + 1, "commit go",
       row + 2
      WITH nocounter, append, maxcol = 512,
       format = variable, formfeed = none, maxrow = 1
     ;end select
     INSERT  FROM dm_afd_code_value_extension c
      (c.code_set, c.alpha_feature_nbr, c.field_name,
      c.code_value, c.updt_applctx, c.updt_dt_tm,
      c.updt_id, c.field_type, c.field_value,
      c.updt_cnt, c.updt_task)(SELECT
       a.code_set, afd_nbr, a.field_name,
       a.code_value, a.updt_applctx, cnvtdatetime(cdate),
       a.updt_id, a.field_type, a.field_value,
       a.updt_cnt, a.updt_task
       FROM dm_adm_code_value_extension a
       WHERE a.delete_ind != 1
        AND (a.code_set=list->qual[cnt].code_set)
        AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
      WITH nocounter
     ;end insert
     SELECT INTO value(fname)
      a.*
      FROM dm_afd_code_value_extension a
      WHERE a.alpha_feature_nbr=afd_nbr
       AND (a.code_set=list->qual[cnt].code_set)
      DETAIL
       tempstr = "insert into dm_afd_code_value_extension c", tempstr, row + 1,
       tempstr = "(c.code_set,c.alpha_feature_nbr,c.field_name,", tempstr, row + 1,
       tempstr = "c.code_value,c.updt_applctx,c.updt_dt_tm,c.updt_id,", tempstr, row + 1,
       tempstr = "c.field_type,c.field_value,c.updt_cnt,c.updt_task )", tempstr, row + 1,
       tempstr = build("values (",a.code_set,",",cnumber,","), tempstr, row + 1,
       tempstr = build('"',a.field_name,'",'), tempstr, row + 1,
       tempstr = build(a.code_value,",",a.updt_applctx,","), tempstr, row + 1,
       tempstr = build('cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'), tempstr, row
        + 1,
       tempstr = build(a.updt_id,",",a.field_type,","), tempstr, row + 1,
       tempstr = build('"',a.field_value,'",'), tempstr, row + 1,
       tempstr = build(a.updt_cnt,",",a.updt_task,") "), tempstr, row + 1,
       "with nocounter go", row + 1, "commit go",
       row + 2
      WITH nocounter, append, maxcol = 512,
       format = variable, formfeed = none, maxrow = 1
     ;end select
     COMMIT
     SELECT INTO "nl:"
      a.*
      FROM dm_ocd_features a
      WHERE a.alpha_feature_nbr=ocd_number
      WITH nocounter, forupdatewait(a)
     ;end select
    ENDIF
  ENDFOR
 ENDIF
END GO
