CREATE PROGRAM dm_ocd_output_file2:dba
 SET oname = build("ocd_schema_",cnvtstring(afd_nbr))
 SET fname = build("ccluserdir:ocd_schema_",cnvtstring(afd_nbr),".ccl")
 SET cnumber = cnvtstring(afd_nbr)
 SET tempstr = fillstring(255," ")
 SELECT INTO value(fname)
  FROM dual
  DETAIL
   tempstr = build("set ocd_number = ",cnumber," go"), tempstr, row + 2,
   "set env_name = fillstring(20,' ') go", row + 1, "select into 'nl:'",
   row + 1, " de.environment_name", row + 1,
   tempstr = build("from DM_INFO di",","," DM_ENVIRONMENT de "), tempstr, row + 1,
   "where di.info_name = 'DM_ENV_ID'", row + 1, " and di.info_domain = 'DATA MANAGEMENT'",
   row + 1, "  and de.environment_id = di.info_number", row + 1,
   "detail", row + 1, " env_name = de.environment_name",
   row + 1, "with nocounter go", row + 2,
   "execute dm_ocd_insert_env go", row + 1
  WITH nocounter, maxrow = 2, maxcol = 512,
   format = variable, formfeed = none
 ;end select
 SELECT INTO value(fname)
  *
  FROM dual
  DETAIL
   "set trace symbol mark go", row + 2, tempstr =
   "delete from dm_afd_code_value_set where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_code_value where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_code_value_alias where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_code_value_extension where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_code_set_extension where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_common_data_foundation where alpha_feature_nbr =",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, "commit  go",
   row + 2, tempstr = "delete from dm_afd_tables where alpha_feature_nbr = ", tempstr,
   row + 1, tempstr = build(cnumber," with nocounter go"), tempstr,
   row + 1, tempstr = "delete from dm_afd_columns where alpha_feature_nbr = ", tempstr,
   row + 1, tempstr = build(cnumber," with nocounter go"), tempstr,
   row + 1, tempstr = "delete from dm_afd_constraints where alpha_feature_nbr = ", tempstr,
   row + 1, tempstr = build(cnumber," with nocounter go"), tempstr,
   row + 1, tempstr = "delete from dm_afd_cons_columns where alpha_feature_nbr = ", tempstr,
   row + 1, tempstr = build(cnumber," with nocounter go"), tempstr,
   row + 1, tempstr = "delete from dm_afd_indexes where alpha_feature_nbr = ", tempstr,
   row + 1, tempstr = build(cnumber," with nocounter go"), tempstr,
   row + 1, tempstr = "delete from dm_afd_index_columns where alpha_feature_nbr =", tempstr,
   row + 1, tempstr = build(cnumber," with nocounter go"), tempstr,
   row + 1, "commit go ", row + 2,
   "delete from dm_ocd_features", row + 1, tempstr = build("where alpha_feature_nbr = ",afd_nbr),
   tempstr, row + 1, "with nocounter go",
   row + 1, "commit go", row + 2
  WITH nocounter, maxrow = 2, maxcol = 512,
   format = variable, formfeed = none, append
 ;end select
 SELECT INTO value(fname)
  FROM dm_ocd_features c
  WHERE c.alpha_feature_nbr=afd_nbr
  ORDER BY c.feature_number
  DETAIL
   "insert into dm_ocd_features", row + 1, tempstr = build("set alpha_feature_nbr = ",afd_nbr,","),
   tempstr, row + 1, tempstr = build("feature_number = ",c.feature_number),
   tempstr, row + 1, "with nocounter go",
   row + 1, "commit go", row + 2
  WITH nocounter, maxrow = 2, maxcol = 512,
   format = variable, formfeed = none, append
 ;end select
 SELECT INTO value(fname)
  FROM dm_ocd_features c
  WHERE c.alpha_feature_nbr=afd_nbr
   AND c.schema_ind=1
  ORDER BY c.feature_number
  DETAIL
   "update into dm_ocd_features a", row + 1, "set a.schema_ind = 1",
   row + 1, tempstr = build("where a.alpha_feature_nbr = ",afd_nbr), tempstr,
   row + 1, tempstr = build("and a.feature_number = ",c.feature_number), tempstr,
   row + 1, "with nocounter go", row + 1,
   "commit go", row + 2
  WITH nocounter, maxrow = 2, maxcol = 512,
   format = variable, formfeed = none, append
 ;end select
 SET cdate = cnvtdatetime(curdate,curtime3)
 SET cdate = cnvtdatetime(format(cdate,"dd-mmm-yyyy hh:mm:ss;;d"))
 SELECT INTO value(fname)
  a.*
  FROM dm_afd_code_value_set a
  WHERE a.alpha_feature_nbr=afd_nbr
  ORDER BY a.code_set
  HEAD a.code_set
   ldesc = 0
   IF (size(trim(a.definition)) > 110)
    ldesc = 1, 'set def1 = fillstring(100, " ") go', row + 1,
    'set def2 = fillstring(100, " ") go', row + 1, 'set def3 = fillstring(100, " ") go',
    row + 1, 'set def4 = fillstring(100, " ") go', row + 1,
    tempstr = build('set def1 = "',substring(1,100,replace(a.definition,'"',"'",0)),'" go'), tempstr,
    row + 1,
    tempstr = build('set def2 = "',substring(101,100,replace(a.definition,'"',"'",0)),'" go'),
    tempstr, row + 1,
    tempstr = build('set def3 = "',substring(201,100,replace(a.definition,'"',"'",0)),'" go'),
    tempstr, row + 1,
    tempstr = build('set def4 = "',substring(301,100,replace(a.definition,'"',"'",0)),'" go'),
    tempstr, row + 1
   ENDIF
  DETAIL
   tempstr = "insert into dm_afd_code_value_set c", tempstr, row + 1,
   tempstr = "(c.code_set, c.alpha_feature_nbr,c.feature_number,c.display,c.display_key,", tempstr,
   row + 1,
   tempstr = " c.description,c.definition, c.table_name,c.contributor,", tempstr, row + 1,
   tempstr = " c.owner_module,c.cache_ind,c.extension_ind,c.add_access_ind,", tempstr, row + 1,
   tempstr = " c.chg_access_ind,c.del_access_ind,c.inq_access_ind,", tempstr, row + 1,
   tempstr = " c.domain_qualifier_ind,c.domain_code_set,", tempstr, row + 1,
   tempstr = " c.updt_dt_tm,c.updt_id,c.updt_cnt,c.updt_task,c.updt_applctx,", tempstr, row + 1,
   tempstr = " c.code_set_hits,c.code_values_cnt,c.def_dup_rule_flag,", tempstr, row + 1,
   tempstr = " c.cdf_meaning_dup_ind,c.display_key_dup_ind,c.active_ind_dup_ind,", tempstr, row + 1,
   tempstr = " c.display_dup_ind, c.alias_dup_ind)", tempstr, row + 1,
   tempstr = build("values( ",a.code_set,",",a.alpha_feature_nbr,",",
    a.feature_number,","), tempstr, row + 1,
   tempstr = build('"',replace(a.display,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build('"',trim(a.display_key),'",'), tempstr, row + 1,
   tempstr = build('"',replace(a.description,'"',"'",0),'",'), tempstr, row + 1
   IF (ldesc=1)
    tempstr = "concat(trim(def1),trim(def2),trim(def3),trim(def4)),"
   ELSE
    tempstr = build('"',replace(a.definition,'"',"'",0),'",')
   ENDIF
   tempstr, row + 1, tempstr = build('"',trim(a.table_name),'","',trim(a.contributor),'",'),
   tempstr, row + 1, tempstr = build('"',trim(a.owner_module),'",',a.cache_ind,",",
    a.extension_ind,",",a.add_access_ind),
   tempstr, row + 1, tempstr = build(",",a.chg_access_ind,",",a.del_access_ind,",",
    a.inq_access_ind),
   tempstr, row + 1, tempstr = build(",",a.domain_qualifier_ind,",",a.domain_code_set,
    ',cnvtdatetime("',
    format(cdate,"dd-mmm-yyyy hh:mm:ss;;d"),'")'),
   tempstr, row + 1, tempstr = build(",",a.updt_id,",",a.updt_cnt,",",
    a.updt_task,",",a.updt_applctx),
   tempstr, row + 1, tempstr = build(",",a.code_set_hits,",",a.code_values_cnt,",",
    a.def_dup_rule_flag),
   tempstr, row + 1, tempstr = build(",",a.cdf_meaning_dup_ind,",",a.display_key_dup_ind,","),
   tempstr, row + 1, tempstr = build(a.active_ind_dup_ind,",",a.display_dup_ind,",",a.alias_dup_ind,
    ")"),
   tempstr, row + 1, tempstr = "with nocounter go",
   tempstr, row + 1, "commit go",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SELECT INTO value(fname)
  a.*
  FROM dm_afd_common_data_foundation a
  WHERE a.alpha_feature_nbr=afd_nbr
  ORDER BY a.code_set, a.cdf_meaning
  DETAIL
   tempstr = "insert into dm_afd_common_data_foundation c", tempstr, row + 1,
   tempstr = "(c.code_set, c.alpha_feature_nbr, c.cdf_meaning,", tempstr, row + 1,
   tempstr = " c.display, c.definition, c.updt_applctx, c.updt_dt_tm, ", tempstr, row + 1,
   tempstr = " c.updt_id, c.updt_cnt, c.updt_task)", tempstr, row + 1,
   tempstr = build("values (",a.code_set,",",cnumber,","), tempstr, row + 1,
   tempstr = build('"',replace(a.cdf_meaning,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = concat('"',replace(a.display,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build('"',replace(a.definition,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build(a.updt_applctx,","), tempstr, row + 1,
   tempstr = build('cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),',a.updt_id,",",
    a.updt_cnt,",",a.updt_task,") "), tempstr, row + 1,
   "with nocounter go", row + 1, "commit go",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 1
 ;end select
 SELECT INTO value(fname)
  a.*
  FROM dm_afd_code_set_extension a
  WHERE a.alpha_feature_nbr=afd_nbr
  ORDER BY a.code_set, a.field_name
  DETAIL
   tempstr = "insert into dm_afd_code_set_extension c", tempstr, row + 1,
   tempstr = "(c.code_set, c.alpha_feature_nbr, c.field_name, ", tempstr, row + 1,
   tempstr = " c.field_seq, c.field_type, c.field_len, c.field_prompt,", tempstr, row + 1,
   tempstr = " c.field_in_mask, c.field_out_mask, c.validation_condition,", tempstr, row + 1,
   tempstr = " c.validation_code_set, c.action_field, c.field_default,", tempstr, row + 1,
   tempstr = " c.field_help, c.updt_task, c.updt_id, c.updt_cnt,", tempstr, row + 1,
   tempstr = " c.updt_dt_tm, c.updt_applctx)", tempstr, row + 1,
   tempstr = build("values (",a.code_set,",",cnumber,","), tempstr, row + 1,
   tempstr = build('"',replace(a.field_name,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build(a.field_seq,",",a.field_type,",",a.field_len,
    ","), tempstr, row + 1,
   tempstr = build('"',replace(a.field_prompt,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build('"',replace(a.field_in_mask,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build('"',replace(a.field_out_mask,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build('"',replace(a.validation_condition,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build(a.validation_code_set,","), tempstr, row + 1,
   tempstr = build('"',replace(a.action_field,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build('"',replace(a.field_default,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build('"',replace(a.field_help,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build(a.updt_task,",",a.updt_id,",",a.updt_cnt,
    ","), tempstr, row + 1,
   tempstr = build('cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),',a.updt_applctx,") "
    ), tempstr, row + 1,
   "with nocounter go", row + 1, "commit go",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SET cv_count = 0
 SELECT INTO value(fname)
  a.*
  FROM dm_afd_code_value a
  WHERE a.alpha_feature_nbr=afd_nbr
  ORDER BY a.code_set
  HEAD a.code_set
   "set trace symbol go", row + 1
  DETAIL
   cv_count = (cv_count+ 1)
   IF (mod(cv_count,1000)=1
    AND cv_count != 1)
    "set trace symbol go", row + 1
   ENDIF
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
   tempstr = build('"',replace(a.cdf_meaning,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build('"',replace(a.display,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build('"',a.display_key,'",'), tempstr, row + 1,
   tempstr = build('"',replace(a.description,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build('"',replace(a.definition,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build(a.collation_seq,",",a.active_type_cd,",",a.active_ind,
    ","), tempstr, row + 1,
   tempstr = build('cnvtdatetime("',format(a.active_dt_tm,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'), tempstr,
   row + 1,
   tempstr = build('cnvtdatetime("',format(a.inactive_dt_tm,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'),
   tempstr, row + 1,
   tempstr = build('cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'), tempstr, row + 1,
   tempstr = build(a.updt_id,",",a.updt_cnt,","), tempstr, row + 1,
   tempstr = build(a.updt_task,",",a.updt_applctx,","), tempstr, row + 1,
   tempstr = build('cnvtdatetime("',format(a.begin_effective_dt_tm,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'),
   tempstr, row + 1,
   tempstr = build('cnvtdatetime("',format(a.end_effective_dt_tm,"dd-mmm-yyyy hh:mm:ss;;D"),'"),',a
    .data_status_cd,","), tempstr, row + 1,
   tempstr = build('cnvtdatetime("',format(a.data_status_dt_tm,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'),
   tempstr, row + 1,
   tempstr = build(a.data_status_prsnl_id,",",a.active_status_prsnl_id,","), tempstr, row + 1,
   tempstr = build('"',a.cki,'")'), tempstr, row + 1,
   "with nocounter go", row + 1, "commit go",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SELECT INTO value(fname)
  a.*
  FROM dm_afd_code_value_alias a
  WHERE a.alpha_feature_nbr=afd_nbr
  ORDER BY a.code_set, a.alias
  HEAD a.code_set
   lalias = 0
   IF (size(trim(a.alias)) > 110)
    lalias = 1, 'set al1 = fillstring(100, " ") go', row + 1,
    'set al2 = fillstring(100, " ") go', row + 1, 'set al3 = fillstring(55, " ") go',
    row + 1, tempstr = build('set al1 = "',substring(1,100,replace(a.alias,'"',"'",0)),'" go'),
    tempstr,
    row + 1, tempstr = build('set al2 = "',substring(101,100,replace(a.alias,'"',"'",0)),'" go'),
    tempstr,
    row + 1, tempstr = build('set al3 = "',substring(201,55,replace(a.alias,'"',"'",0)),'" go'),
    tempstr,
    row + 1
   ENDIF
  DETAIL
   tempstr = "insert into dm_afd_code_value_alias c ", tempstr, row + 1,
   tempstr = "(c.code_set,c.alpha_feature_nbr,c.alias,", tempstr, row + 1,
   tempstr = "c.contributor_source_cd,c.code_value,c.primary_ind,", tempstr, row + 1,
   tempstr = "c.updt_dt_tm,c.updt_id,c.updt_task,c.updt_cnt,", tempstr, row + 1,
   tempstr = "c.updt_applctx,c.alias_type_meaning )", tempstr, row + 1,
   tempstr = build("values(",a.code_set,",",cnumber,","), tempstr, row + 1
   IF (lalias=1)
    tempstr = "concat(trim(al1),trim(al2),trim(al3)),"
   ELSE
    tempstr = concat('"',trim(replace(trim(a.alias),'"',"'",0)),'",')
   ENDIF
   tempstr, row + 1, tempstr = build(a.contributor_source_cd,",",a.code_value,",",a.primary_ind,
    ","),
   tempstr, row + 1, tempstr = build('cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'),
   tempstr, row + 1, tempstr = build(a.updt_id,",",a.updt_task,",",a.updt_cnt,
    ","),
   tempstr, row + 1, tempstr = build(a.updt_applctx,","),
   tempstr, row + 1, tempstr = build('"',replace(a.alias_type_meaning,'"',"'",0),'" ) '),
   tempstr, row + 1, "with nocounter go",
   row + 1, "commit go", row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SELECT INTO value(fname)
  a.*
  FROM dm_afd_code_value_extension a
  WHERE a.alpha_feature_nbr=afd_nbr
  ORDER BY a.code_set, a.field_name
  DETAIL
   tempstr = "insert into dm_afd_code_value_extension c", tempstr, row + 1,
   tempstr = "(c.code_set,c.alpha_feature_nbr,c.field_name,", tempstr, row + 1,
   tempstr = "c.code_value,c.updt_applctx,c.updt_dt_tm,c.updt_id,", tempstr, row + 1,
   tempstr = "c.field_type,c.field_value,c.updt_cnt,c.updt_task )", tempstr, row + 1,
   tempstr = build("values (",a.code_set,",",cnumber,","), tempstr, row + 1,
   tempstr = build('"',replace(a.field_name,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build(a.code_value,",",a.updt_applctx,","), tempstr, row + 1,
   tempstr = build('cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),'), tempstr, row + 1,
   tempstr = build(a.updt_id,",",a.field_type,","), tempstr, row + 1,
   tempstr = build('"',replace(a.field_value,'"',"'",0),'",'), tempstr, row + 1,
   tempstr = build(a.updt_cnt,",",a.updt_task,") "), tempstr, row + 1,
   "with nocounter go", row + 1, "commit go",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SELECT INTO value(fname)
  at.*
  FROM dm_afd_tables at
  WHERE at.alpha_feature_nbr=afd_nbr
  ORDER BY at.table_name
  DETAIL
   tempstr = "insert into dm_afd_tables", tempstr, row + 1,
   tempstr =
   "(table_name, alpha_feature_nbr, feature_number,tablespace_name, pct_increase, pct_used,", tempstr,
   row + 1,
   tempstr = " pct_free, updt_applctx, updt_dt_tm, updt_cnt, updt_id, updt_task, schema_date )",
   tempstr, row + 1,
   tempstr = build('values("',at.table_name,'",',at.alpha_feature_nbr,",",
    at.feature_number,',"',at.tablespace_name,'",'), tempstr, row + 1,
   tempstr = build(at.pct_increase,",",at.pct_used,",",at.pct_free,
    ",",at.updt_applctx,","), tempstr, row + 1,
   tempstr = build('cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),',at.updt_cnt,",",
    at.updt_id,","), tempstr, row + 1,
   tempstr = build(at.updt_task,","), tempstr, row + 1,
   tempstr = build('cnvtdatetime("',format(at.schema_date,"dd-mmm-yyyy hh:mm:ss;;D"),'"))'), tempstr,
   row + 1,
   "with nocounter go", row + 1, "commit go ",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SELECT INTO value(fname)
  ac.*
  FROM dm_afd_columns ac
  WHERE ac.alpha_feature_nbr=afd_nbr
  ORDER BY ac.table_name, ac.column_name
  DETAIL
   tempstr = "insert into dm_afd_columns ", tempstr, row + 1,
   tempstr = "(table_name,alpha_feature_nbr,column_name,column_seq,", tempstr, row + 1,
   tempstr = " data_type,data_length,data_precision,data_scale,", tempstr, row + 1,
   tempstr = " nullable,data_default,updt_applctx,", tempstr, row + 1,
   tempstr = " updt_dt_tm,updt_cnt,updt_id,updt_task)", tempstr, row + 1,
   tempstr = build('values ("',ac.table_name,'",',cnumber,","), tempstr, row + 1,
   tempstr = build('"',ac.column_name,'",'), tempstr, row + 1,
   tempstr = build(ac.column_seq,',"',ac.data_type,'",',ac.data_length,
    ","), tempstr, row + 1,
   tempstr = build(ac.data_precision,",",ac.data_scale,',"',ac.nullable,
    '",'), tempstr, row + 1,
   tempstr = build('"',ac.data_default,'",'), tempstr, row + 1,
   tempstr = build('0,cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),0,0,0 )'), tempstr,
   row + 1,
   tempstr = "with nocounter  go", tempstr, row + 1,
   "commit go ", row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SELECT INTO value(fname)
  ac.*
  FROM dm_afd_constraints ac
  WHERE ac.alpha_feature_nbr=afd_nbr
  ORDER BY ac.table_name, ac.constraint_name
  DETAIL
   tempstr = "insert into dm_afd_constraints", tempstr, row + 1,
   tempstr = "(table_name,alpha_feature_nbr,constraint_name,", tempstr, row + 1,
   tempstr = " constraint_type,parent_table_name,status_ind,", tempstr, row + 1,
   tempstr = " parent_table_columns,r_constraint_name,updt_applctx,", tempstr, row + 1,
   tempstr = " updt_dt_tm,updt_cnt,updt_id,updt_task)", tempstr, row + 1,
   tempstr = build('values ("',ac.table_name,'",'), tempstr, row + 1,
   tempstr = build(cnumber,","), tempstr, row + 1,
   tempstr = build('"',ac.constraint_name,'",'), tempstr, row + 1,
   tempstr = build('"',ac.constraint_type,'",'), tempstr, row + 1,
   tempstr = build('"',ac.parent_table_name,'",'), tempstr, row + 1,
   tempstr = build(ac.status_ind,","), tempstr, row + 1,
   tempstr = build('"',ac.parent_table_columns,'",'), tempstr, row + 1,
   tempstr = build('"',ac.r_constraint_name,'",'), tempstr, row + 1,
   tempstr = build('0,cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),0,0,0 )'), tempstr,
   row + 1,
   "with nocounter go ", row + 1, "commit go ",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SELECT INTO value(fname)
  acc.*
  FROM dm_afd_cons_columns acc
  WHERE acc.alpha_feature_nbr=afd_nbr
  ORDER BY acc.table_name, acc.constraint_name
  DETAIL
   tempstr = "insert into dm_afd_cons_columns", tempstr, row + 1,
   tempstr = "(table_name,alpha_feature_nbr,constraint_name,", tempstr, row + 1,
   tempstr = " column_name,position,updt_applctx,", tempstr, row + 1,
   tempstr = " updt_dt_tm,updt_cnt,updt_id,updt_task)", tempstr, row + 1,
   tempstr = build('values ("',acc.table_name,'",'), tempstr, row + 1,
   tempstr = build(cnumber,","), tempstr, row + 1,
   tempstr = build('"',acc.constraint_name,'",'), tempstr, row + 1,
   tempstr = build('"',acc.column_name,'",'), tempstr, row + 1,
   tempstr = build(acc.position,","), tempstr, row + 1,
   tempstr = build('0,cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),0,0,0)'), tempstr,
   row + 1,
   "with nocounter go  ", row + 1, "commit go ",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SELECT INTO value(fname)
  ai.*
  FROM dm_afd_indexes ai
  WHERE ai.alpha_feature_nbr=afd_nbr
  ORDER BY ai.table_name, ai.index_name
  DETAIL
   tempstr = "insert into dm_afd_indexes", tempstr, row + 1,
   tempstr = "(index_name,alpha_feature_nbr,table_name,tablespace_name,", tempstr, row + 1,
   tempstr = " pct_increase,pct_free,unique_ind,updt_applctx, ", tempstr, row + 1,
   tempstr = " updt_dt_tm,updt_cnt,updt_id,updt_task)", tempstr, row + 1,
   tempstr = build('values ("',ai.index_name,'",'), tempstr, row + 1,
   tempstr = build(cnumber,","), tempstr, row + 1,
   tempstr = build('"',ai.table_name,'",'), tempstr, row + 1,
   tempstr = build('"',ai.tablespace_name,'",'), tempstr, row + 1,
   tempstr = build(ai.pct_increase,",",ai.pct_free,",",ai.unique_ind,
    ","), tempstr, row + 1,
   tempstr = build('0,cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),0,0,0 )'), tempstr,
   row + 1,
   "with nocounter go ", row + 1, "commit go ",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SELECT INTO value(fname)
  aic.*
  FROM dm_afd_index_columns aic
  WHERE aic.alpha_feature_nbr=afd_nbr
  ORDER BY aic.table_name, aic.index_name
  DETAIL
   tempstr = "insert into dm_afd_index_columns", tempstr, row + 1,
   tempstr = "(index_name,table_name,alpha_feature_nbr,column_name,", tempstr, row + 1,
   tempstr = " column_position,updt_applctx,", tempstr, row + 1,
   tempstr = " updt_dt_tm,updt_cnt,updt_id,updt_task)", tempstr, row + 1,
   tempstr = build('values ("',aic.index_name,'",'), tempstr, row + 1,
   tempstr = build('"',aic.table_name,'",'), tempstr, row + 1,
   tempstr = build(cnumber,","), tempstr, row + 1,
   tempstr = build('"',aic.column_name,'",'), tempstr, row + 1,
   tempstr = build(aic.column_position,","), tempstr, row + 1,
   tempstr = build('0,cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),0,0,0 ) '), tempstr,
   row + 1,
   "with nocounter go ", row + 1, "commit go ",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SELECT INTO value(fname)
  FROM dm_afd_tables a,
   dm_afd_tables b
  WHERE b.table_name=a.table_name
   AND a.alpha_feature_nbr != b.alpha_feature_nbr
   AND a.alpha_feature_nbr=afd_nbr
  ORDER BY b.table_name
  DETAIL
   "update into dm_afd_tables c", row + 1, tempstr = build("set c.schema_date = cnvtdatetime('",
    format(b.schema_date,"dd-mmm-yyyy hh:mm:ss;;D"),"')"),
   tempstr, row + 1, tempstr = build("where c.table_name = '",b.table_name,"' and"),
   tempstr, row + 1, tempstr = build("c.feature_number = ",b.feature_number," and "),
   tempstr, row + 1, tempstr = build("c.alpha_feature_nbr = ",b.alpha_feature_nbr),
   tempstr, row + 1, "with nocounter go",
   row + 1, "commit go", row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SET tempstr = fillstring(255," ")
 SELECT INTO value(fname)
  FROM dm_tables_doc t,
   dm_afd_tables a
  WHERE a.alpha_feature_nbr=afd_nbr
   AND t.table_name=a.table_name
  ORDER BY t.table_name
  HEAD REPORT
   "free record tbl_doc go", row + 2, "record tbl_doc (",
   row + 1, "1 qual[*]", row + 1,
   "2 table_name = vc", row + 1, "2 data_model_section = vc",
   row + 1, "2 description = vc", row + 1,
   "2 definition = vc", row + 1, "2 primary_update_script = vc",
   row + 1, "2 primary_insert_script = vc", row + 1,
   "2 primary_delete_script = vc", row + 1, "2 static_size_flg = i4",
   row + 1, "2 static_rows = i4", row + 1,
   "2 reads_flg = i4", row + 1, "2 update_flg = i4",
   row + 1, "2 insert_flg = i4", row + 1,
   "2 delete_flg = i4", row + 1, "2 core_ind = i2",
   row + 1, "2 updt_cnt = i4", row + 1,
   "2 bytes_per_row = i4", row + 1, "2 reference_ind = i2",
   row + 1, "2 pct_free  = i4", row + 1,
   "2 pct_used = i4", row + 1, "2 bpr_mean = f8",
   row + 1, "2 bpr_min = f8", row + 1,
   "2 bpr_max = f8", row + 1, "2 bpr_std_dev = f8",
   row + 1, "2 human_reqd_ind = i2", row + 1,
   "2 purge_except_ind = i2", row + 1, "2 freelist_cnt = i4  ) go",
   row + 2, "set trace symbol mark go", row + 2,
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), ldesc = 0
   IF (size(trim(t.definition)) > 80)
    ldesc = 1, 'set def1 = fillstring(100, " ") go', row + 1,
    'set def2 = fillstring(100, " ") go', row + 1, 'set def3 = fillstring(100, " ") go',
    row + 1, 'set def4 = fillstring(100, " ") go', row + 1,
    tempstr = build('set def1 = "',substring(1,100,replace(check(t.definition),'"',"'",0)),'" go'),
    tempstr, row + 1,
    tempstr = build('set def2 = "',substring(101,100,replace(check(t.definition),'"',"'",0)),'" go'),
    tempstr, row + 1,
    tempstr = build('set def3 = "',substring(201,100,replace(check(t.definition),'"',"'",0)),'" go'),
    tempstr, row + 1,
    tempstr = build('set def4 = "',substring(301,100,replace(check(t.definition),'"',"'",0)),'" go'),
    tempstr, row + 1
   ENDIF
   tempstr = build("set stat = alterlist(tbl_doc->qual,",cnt," ) go"), tempstr, row + 1,
   tempstr = build("set tbl_doc->qual[",cnt,"]->table_name = '",t.table_name,"' go"), tempstr, row +
   1,
   tempstr = build("set tbl_doc->qual[",cnt,"]->data_model_section = '",t.data_model_section,"' go"),
   tempstr, row + 1,
   tempstr = build("set tbl_doc->qual[",cnt,']->description ="',replace(check(t.description),'"',"'",
     0),'" go'), tempstr, row + 1
   IF (ldesc=1)
    tempstr = build("set tbl_doc->qual[",cnt,
     "]->definition = concat(trim(def1),trim(def2),trim(def3),trim(def4)) go")
   ELSE
    tempstr = build("set tbl_doc->qual[",cnt,']->definition = "',replace(check(t.definition),'"',"'",
      0),'" go')
   ENDIF
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->primary_update_script = '",trim(t
     .primary_update_script),"' go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->primary_insert_script = '",trim(t
     .primary_insert_script),"' go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->primary_delete_script = '",trim(t
     .primary_delete_script),"' go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->static_size_flg = ",t
    .static_size_flg," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->static_rows = ",t.static_rows," go"
    ),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->reads_flg = ",t.reads_flg," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->update_flg = ",t.update_flg," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->insert_flg = ",t.insert_flg," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->delete_flg = ",t.delete_flg," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->core_ind = ",t.core_ind," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->updt_cnt = ",t.updt_cnt," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->bytes_per_row = ",t.bytes_per_row,
    " go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->reference_ind = ",t.reference_ind,
    " go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->pct_free = ",t.pct_free," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->pct_used = ",t.pct_used," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->bpr_mean = ",t.bpr_mean," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->bpr_min = ",t.bpr_min," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->bpr_max = ",t.bpr_max," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->bpr_std_dev = ",t.bpr_std_dev," go"
    ),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->human_reqd_ind = ",t.human_reqd_ind,
    " go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->purge_except_ind = ",t
    .purge_except_ind," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->freelist_cnt= ",t.freelist_cnt,
    " go"),
   tempstr, row + 2, row + 1
  FOOT REPORT
   "execute dm_ins_upd_tbl_doc go", row + 1, "set trace symbol release go",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
 SELECT INTO value(fname)
  FROM dm_tables_doc t,
   dm_columns_doc d,
   dm_afd_columns c,
   dm_afd_tables a
  WHERE a.alpha_feature_nbr=afd_nbr
   AND c.alpha_feature_nbr=a.alpha_feature_nbr
   AND t.table_name=a.table_name
   AND c.table_name=t.table_name
   AND d.table_name=c.table_name
   AND d.column_name=c.column_name
  ORDER BY d.table_name, d.column_name
  HEAD d.table_name
   "free record col_doc go", row + 2, "record col_doc (",
   row + 1, "1 qual[*]", row + 1,
   "2 table_name = vc", row + 1, "2 column_name = vc",
   row + 1, "2 sequence_name = vc", row + 1,
   "2 code_set = i4", row + 1, "2 description = vc",
   row + 1, "2 definition = vc", row + 1,
   "2 flag_ind = i2", row + 1, "2 updt_cnt = i4",
   row + 1, "2 unique_ident_ind = i2", row + 1,
   "2 root_entity_name = vc", row + 1, "2 root_entity_attr = vc",
   row + 1, "2 constant_value = vc", row + 1,
   "2 parent_entity_col = vc", row + 1, "2 exception_flg = i4",
   row + 1, "2 defining_attribute_ind = i2", row + 1,
   "2 merge_updateable_ind = i2", row + 1, "2 nls_col_ind = i2 ) go",
   row + 2, "set trace symbol mark go", row + 2,
   cknt = 0
  DETAIL
   cknt = (cknt+ 1), tempstr = build("set stat = alterlist(col_doc->qual,",cknt," ) go"), tempstr,
   row + 1, tempstr = build("set col_doc->qual[",cknt,"]->table_name = '",t.table_name,"' go"),
   tempstr,
   row + 1, lcoldesc = 0
   IF (size(trim(d.definition)) > 80)
    lcoldesc = 1, row + 1, 'set cdef1 = fillstring(100, " ") go',
    row + 1, 'set cdef2 = fillstring(100, " ") go', row + 1,
    'set cdef3 = fillstring(100, " ") go', row + 1, 'set cdef4 = fillstring(100, " ") go',
    row + 1, tempstr = build('set cdef1 = "',substring(1,100,replace(check(d.definition),'"',"'",0)),
     '" go'), tempstr,
    row + 1, tempstr = build('set cdef2 = "',substring(101,100,replace(check(d.definition),'"',"'",0)
      ),'" go'), tempstr,
    row + 1, tempstr = build('set cdef3 = "',substring(201,100,replace(check(d.definition),'"',"'",0)
      ),'" go'), tempstr,
    row + 1, tempstr = build('set cdef4 = "',substring(301,100,replace(check(d.definition),'"',"'",0)
      ),'" go'), tempstr,
    row + 1
   ENDIF
   row + 1, tempstr = build("set col_doc->qual[",cknt,"]->column_name = '",d.column_name,"' go"),
   tempstr,
   row + 1, tempstr = build("set col_doc->qual[",cknt,"]->sequence_name = '",trim(d.sequence_name),
    "' go"), tempstr,
   row + 1, tempstr = build("set col_doc->qual[",cknt,"]->code_set = ",d.code_set," go"), tempstr,
   row + 1, tempstr = build("set col_doc->qual[",cknt,"]->description = '",replace(check(d
      .description),"'",'"',0),"' go"), tempstr,
   row + 1
   IF (lcoldesc=1)
    tempstr = build("set col_doc->qual[",cknt,
     "]->definition = concat(trim(cdef1),trim(cdef2),trim(cdef3),trim(cdef4)) go")
   ELSE
    tempstr = build("set col_doc->qual[",cknt,"]->definition = '",replace(check(d.definition),"'",'"',
      0),"' go")
   ENDIF
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->flag_ind = ",d.flag_ind," go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->updt_cnt = ",d.updt_cnt," go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->unique_ident_ind = ",d
    .unique_ident_ind," go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->root_entity_name = '",trim(d
     .root_entity_name),"' go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->root_entity_attr = '",trim(d
     .root_entity_attr),"' go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->constant_value ='",trim(d
     .constant_value),"' go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->parent_entity_col='",trim(d
     .parent_entity_col),"' go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->exception_flg = ",d.exception_flg,
    " go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->defining_attribute_ind = ",d
    .defining_attribute_ind," go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->merge_updateable_ind = ",d
    .merge_updateable_ind," go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->nls_col_ind = ",d.nls_col_ind,
    " go"),
   tempstr, row + 1
  FOOT  d.table_name
   "execute dm_ins_upd_col_doc go", row + 1, "set trace symbol release go",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
END GO
