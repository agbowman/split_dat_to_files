CREATE PROGRAM dm_ocd_create_defs:dba
 SET trace symbol mark
 DROP TABLE dm_alpha_features
 DROP DDLRECORD dm_alpha_features FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_alpha_features FROM DATABASE v500
 TABLE dm_alpha_features
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 description  = vc80 CCL(description)
  1 rev_number  = f8 CCL(rev_number)
  1 sponsor_client_id  = c10 CCL(sponsor_client_id)
  1 create_dt_tm  = di8 CCL(create_dt_tm)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_alpha_features
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_alpha_features_env
 DROP DDLRECORD dm_alpha_features_env FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_alpha_features_env FROM DATABASE v500
 TABLE dm_alpha_features_env
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 environment_id  = f8 CCL(environment_id)
  1 start_dt_tm  = di8 CCL(start_dt_tm)
  1 end_dt_tm  = di8 CCL(end_dt_tm)
  1 status  = vc100 CCL(status)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_alpha_features_env
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_min_tspace_size
 DROP DDLRECORD dm_min_tspace_size FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_min_tspace_size FROM DATABASE v500
 TABLE dm_min_tspace_size
  1 function_id  = f8 CCL(function_id)
  1 tablespace_name  = c30 CCL(tablespace_name)
  1 minimum_size  = f8 CCL(minimum_size)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_min_tspace_size
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_afd_code_set_extension
 DROP DDLRECORD dm_afd_code_set_extension FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_afd_code_set_extension FROM DATABASE v500
 TABLE dm_afd_code_set_extension
  1 code_set  = i4 CCL(code_set)
  1 field_name  = c32 CCL(field_name)
  1 field_seq  = i4 CCL(field_seq)
  1 field_type  = i4 CCL(field_type)
  1 field_len  = i4 CCL(field_len)
  1 field_prompt  = vc50 CCL(field_prompt)
  1 field_in_mask  = vc50 CCL(field_in_mask)
  1 field_out_mask  = vc50 CCL(field_out_mask)
  1 validation_condition  = vc100 CCL(validation_condition)
  1 validation_code_set  = i4 CCL(validation_code_set)
  1 action_field  = vc50 CCL(action_field)
  1 field_default  = vc50 CCL(field_default)
  1 field_help  = vc100 CCL(field_help)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_afd_code_set_extension
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_afd_code_value
 DROP DDLRECORD dm_afd_code_value FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_afd_code_value FROM DATABASE v500
 TABLE dm_afd_code_value
  1 code_value  = f8 CCL(code_value)
  1 code_set  = i4 CCL(code_set)
  1 cdf_meaning  = c12 CCL(cdf_meaning)
  1 display  = c40 CCL(display)
  1 display_key  = c40 CCL(display_key)
  1 description  = vc60 CCL(description)
  1 definition  = vc100 CCL(definition)
  1 collation_seq  = i4 CCL(collation_seq)
  1 active_type_cd  = f8 CCL(active_type_cd)
  1 active_ind  = i2 CCL(active_ind)
  1 active_dt_tm  = di8 CCL(active_dt_tm)
  1 inactive_dt_tm  = di8 CCL(inactive_dt_tm)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 begin_effective_dt_tm  = di8 CCL(begin_effective_dt_tm)
  1 end_effective_dt_tm  = di8 CCL(end_effective_dt_tm)
  1 data_status_cd  = f8 CCL(data_status_cd)
  1 data_status_dt_tm  = di8 CCL(data_status_dt_tm)
  1 data_status_prsnl_id  = f8 CCL(data_status_prsnl_id)
  1 active_status_prsnl_id  = f8 CCL(active_status_prsnl_id)
  1 cki  = vc255 CCL(cki)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_afd_code_value
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_afd_code_value_alias
 DROP DDLRECORD dm_afd_code_value_alias FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_afd_code_value_alias FROM DATABASE v500
 TABLE dm_afd_code_value_alias
  1 code_set  = i4 CCL(code_set)
  1 contributor_source_cd  = f8 CCL(contributor_source_cd)
  1 alias  = vc255 CCL(alias)
  1 code_value  = f8 CCL(code_value)
  1 primary_ind  = i2 CCL(primary_ind)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 alias_type_meaning  = c12 CCL(alias_type_meaning)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_afd_code_value_alias
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_afd_code_value_extension
 DROP DDLRECORD dm_afd_code_value_extension FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_afd_code_value_extension FROM DATABASE v500
 TABLE dm_afd_code_value_extension
  1 code_value  = f8 CCL(code_value)
  1 field_name  = c32 CCL(field_name)
  1 code_set  = i4 CCL(code_set)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 field_type  = i4 CCL(field_type)
  1 field_value  = vc100 CCL(field_value)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_afd_code_value_extension
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_afd_code_value_set
 DROP DDLRECORD dm_afd_code_value_set FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_afd_code_value_set FROM DATABASE v500
 TABLE dm_afd_code_value_set
  1 code_set  = i4 CCL(code_set)
  1 display  = c40 CCL(display)
  1 display_key  = c40 CCL(display_key)
  1 description  = vc60 CCL(description)
  1 definition  = vc500 CCL(definition)
  1 table_name  = c32 CCL(table_name)
  1 contributor  = c18 CCL(contributor)
  1 owner_module  = c12 CCL(owner_module)
  1 cache_ind  = i2 CCL(cache_ind)
  1 extension_ind  = i2 CCL(extension_ind)
  1 add_access_ind  = i2 CCL(add_access_ind)
  1 chg_access_ind  = i2 CCL(chg_access_ind)
  1 del_access_ind  = i2 CCL(del_access_ind)
  1 inq_access_ind  = i2 CCL(inq_access_ind)
  1 domain_qualifier_ind  = i2 CCL(domain_qualifier_ind)
  1 domain_code_set  = i4 CCL(domain_code_set)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_task  = i4 CCL(updt_task)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 code_set_hits  = i4 CCL(code_set_hits)
  1 code_values_cnt  = i4 CCL(code_values_cnt)
  1 def_dup_rule_flag  = i2 CCL(def_dup_rule_flag)
  1 cdf_meaning_dup_ind  = i2 CCL(cdf_meaning_dup_ind)
  1 display_key_dup_ind  = i2 CCL(display_key_dup_ind)
  1 active_ind_dup_ind  = i2 CCL(active_ind_dup_ind)
  1 display_dup_ind  = i2 CCL(display_dup_ind)
  1 alias_dup_ind  = i2 CCL(alias_dup_ind)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 feature_number  = i4 CCL(feature_number)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_afd_code_value_set
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_afd_columns
 DROP DDLRECORD dm_afd_columns FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_afd_columns FROM DATABASE v500
 TABLE dm_afd_columns
  1 table_name  = c30 CCL(table_name)
  1 column_name  = c30 CCL(column_name)
  1 column_seq  = i4 CCL(column_seq)
  1 data_type  = c9 CCL(data_type)
  1 data_length  = i4 CCL(data_length)
  1 data_precision  = i4 CCL(data_precision)
  1 data_scale  = i4 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 data_default  = vc255 CCL(data_default)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_afd_columns
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_afd_common_data_foundation
 DROP DDLRECORD dm_afd_common_data_foundation FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_afd_common_data_foundation FROM DATABASE v500
 TABLE dm_afd_common_data_foundation
  1 code_set  = i4 CCL(code_set)
  1 cdf_meaning  = c12 CCL(cdf_meaning)
  1 display  = c40 CCL(display)
  1 definition  = vc100 CCL(definition)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_afd_common_data_foundation
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_afd_constraints
 DROP DDLRECORD dm_afd_constraints FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_afd_constraints FROM DATABASE v500
 TABLE dm_afd_constraints
  1 table_name  = c30 CCL(table_name)
  1 constraint_name  = c30 CCL(constraint_name)
  1 constraint_type  = c1 CCL(constraint_type)
  1 parent_table_name  = c30 CCL(parent_table_name)
  1 status_ind  = i2 CCL(status_ind)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 parent_table_columns  = vc255 CCL(parent_table_columns)
  1 r_constraint_name  = c30 CCL(r_constraint_name)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_afd_constraints
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_afd_cons_columns
 DROP DDLRECORD dm_afd_cons_columns FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_afd_cons_columns FROM DATABASE v500
 TABLE dm_afd_cons_columns
  1 table_name  = c30 CCL(table_name)
  1 constraint_name  = c30 CCL(constraint_name)
  1 column_name  = c30 CCL(column_name)
  1 position  = i4 CCL(position)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_afd_cons_columns
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_afd_indexes
 DROP DDLRECORD dm_afd_indexes FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_afd_indexes FROM DATABASE v500
 TABLE dm_afd_indexes
  1 index_name  = c30 CCL(index_name)
  1 table_name  = c30 CCL(table_name)
  1 tablespace_name  = c30 CCL(tablespace_name)
  1 pct_increase  = i4 CCL(pct_increase)
  1 pct_free  = i4 CCL(pct_free)
  1 unique_ind  = i2 CCL(unique_ind)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_afd_indexes
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_afd_index_columns
 DROP DDLRECORD dm_afd_index_columns FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_afd_index_columns FROM DATABASE v500
 TABLE dm_afd_index_columns
  1 index_name  = c30 CCL(index_name)
  1 table_name  = c30 CCL(table_name)
  1 column_name  = c30 CCL(column_name)
  1 column_position  = i4 CCL(column_position)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_afd_index_columns
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_afd_tables
 DROP DDLRECORD dm_afd_tables FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_afd_tables FROM DATABASE v500
 TABLE dm_afd_tables
  1 table_name  = c30 CCL(table_name)
  1 tablespace_name  = c30 CCL(tablespace_name)
  1 pct_increase  = i4 CCL(pct_increase)
  1 pct_used  = i4 CCL(pct_used)
  1 pct_free  = i4 CCL(pct_free)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 feature_number  = i4 CCL(feature_number)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_afd_tables
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_ocd_application
 DROP DDLRECORD dm_ocd_application FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_ocd_application FROM DATABASE v500
 TABLE dm_ocd_application
  1 application_number  = i4 CCL(application_number)
  1 owner  = c20 CCL(owner)
  1 description  = vc200 CCL(description)
  1 active_dt_tm  = di8 CCL(active_dt_tm)
  1 active_ind  = i2 CCL(active_ind)
  1 last_localized_dt_tm  = di8 CCL(last_localized_dt_tm)
  1 text  = vc500 CCL(text)
  1 inactive_dt_tm  = di8 CCL(inactive_dt_tm)
  1 log_access_ind  = i2 CCL(log_access_ind)
  1 application_ini_ind  = i2 CCL(application_ini_ind)
  1 object_name  = vc60 CCL(object_name)
  1 direct_access_ind  = i2 CCL(direct_access_ind)
  1 log_level  = i4 CCL(log_level)
  1 request_log_level  = i4 CCL(request_log_level)
  1 min_version_required  = c40 CCL(min_version_required)
  1 disable_cache_ind  = i2 CCL(disable_cache_ind)
  1 module  = c40 CCL(module)
  1 feature_number  = i4 CCL(feature_number)
  1 deleted_ind  = i2 CCL(deleted_ind)
  1 schema_date  = di8 CCL(schema_date)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_ocd_application
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_ocd_app_task_r
 DROP DDLRECORD dm_ocd_app_task_r FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_ocd_app_task_r FROM DATABASE v500
 TABLE dm_ocd_app_task_r
  1 application_number  = i4 CCL(application_number)
  1 task_number  = i4 CCL(task_number)
  1 feature_number  = i4 CCL(feature_number)
  1 deleted_ind  = i2 CCL(deleted_ind)
  1 schema_date  = di8 CCL(schema_date)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_ocd_app_task_r
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_ocd_features
 DROP DDLRECORD dm_ocd_features FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_ocd_features FROM DATABASE v500
 TABLE dm_ocd_features
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 feature_number  = i4 CCL(feature_number)
  1 schema_ind  = i2 CCL(schema_ind)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_ocd_features
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_ocd_request
 DROP DDLRECORD dm_ocd_request FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_ocd_request FROM DATABASE v500
 TABLE dm_ocd_request
  1 request_number  = i4 CCL(request_number)
  1 description  = vc200 CCL(description)
  1 request_name  = c30 CCL(request_name)
  1 text  = vc500 CCL(text)
  1 active_ind  = i2 CCL(active_ind)
  1 active_dt_tm  = di8 CCL(active_dt_tm)
  1 inactive_dt_tm  = di8 CCL(inactive_dt_tm)
  1 prolog_script  = c30 CCL(prolog_script)
  1 epilog_script  = c30 CCL(epilog_script)
  1 write_to_que_ind  = i2 CCL(write_to_que_ind)
  1 requestclass  = i4 CCL(requestclass)
  1 cachetime  = i4 CCL(cachetime)
  1 feature_number  = i4 CCL(feature_number)
  1 deleted_ind  = i2 CCL(deleted_ind)
  1 schema_date  = di8 CCL(schema_date)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_ocd_request
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_ocd_task
 DROP DDLRECORD dm_ocd_task FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_ocd_task FROM DATABASE v500
 TABLE dm_ocd_task
  1 task_number  = i4 CCL(task_number)
  1 description  = vc200 CCL(description)
  1 active_dt_tm  = di8 CCL(active_dt_tm)
  1 inactive_dt_tm  = di8 CCL(inactive_dt_tm)
  1 active_ind  = i2 CCL(active_ind)
  1 text  = vc500 CCL(text)
  1 subordinate_task_ind  = i2 CCL(subordinate_task_ind)
  1 optional_required_flag  = i2 CCL(optional_required_flag)
  1 feature_number  = i4 CCL(feature_number)
  1 deleted_ind  = i2 CCL(deleted_ind)
  1 schema_date  = di8 CCL(schema_date)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_ocd_task
 SET trace = symbol
 SET trace symbol mark
 DROP TABLE dm_ocd_task_req_r
 DROP DDLRECORD dm_ocd_task_req_r FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm_ocd_task_req_r FROM DATABASE v500
 TABLE dm_ocd_task_req_r
  1 task_number  = i4 CCL(task_number)
  1 request_number  = i4 CCL(request_number)
  1 feature_number  = i4 CCL(feature_number)
  1 deleted_ind  = i2 CCL(deleted_ind)
  1 schema_date  = di8 CCL(schema_date)
  1 updt_dt_tm  = di8 CCL(updt_dt_tm)
  1 updt_id  = f8 CCL(updt_id)
  1 updt_task  = i4 CCL(updt_task)
  1 updt_cnt  = i4 CCL(updt_cnt)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 alpha_feature_nbr  = i4 CCL(alpha_feature_nbr)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm_ocd_task_req_r
 SET trace = symbol
 SET reply->status_data.status = "S"
END GO
