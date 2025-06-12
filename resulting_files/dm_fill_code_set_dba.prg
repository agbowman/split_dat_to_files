CREATE PROGRAM dm_fill_code_set:dba
 SET sch_date = cnvtdatetime( $1)
 CALL echo("Deleting Schema Date. ")
 DELETE  FROM dm_code_value_set a
  WHERE a.schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_common_data_foundation a
  WHERE a.schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_code_set_extension a
  WHERE a.schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_code_value a
  WHERE a.schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_code_value_alias a
  WHERE a.schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_code_value_extension a
  WHERE a.schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 FREE SET list
 RECORD list(
   1 qual[*]
     2 code_set = i4
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->qual,10)
 SELECT DISTINCT INTO "nl:"
  dm.code_set
  FROM dm_feature_code_sets_env dm
  WHERE dm.code_set > 0
  ORDER BY dm.code_set
  DETAIL
   list->count = (list->count+ 1)
   IF (mod(list->count,10)=1)
    stat = alterlist(list->qual,(list->count+ 9))
   ENDIF
   list->qual[list->count].code_set = dm.code_set
  WITH nocounter
 ;end select
 SET cnt = 0
 FOR (cnt = 1 TO list->count)
   FREE SET r1
   RECORD r1(
     1 rdate = dq8
   )
   SET r1->rdate = 0
   SELECT DISTINCT INTO "NL:"
    dcf.schema_dt_tm
    FROM dm_feature_code_sets_env dcf,
     dm_features d
    WHERE dcf.feature_number=d.feature_number
     AND (dcf.code_set=list->qual[cnt].code_set)
     AND (((d.feature_status= $2)) OR ((d.feature_status= $3)))
    DETAIL
     IF ((dcf.schema_dt_tm > r1->rdate))
      r1->rdate = dcf.schema_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual > 0)
    INSERT  FROM dm_code_value_set c
     (c.code_set, c.schema_date, c.display,
     c.display_key, c.description, c.definition,
     c.table_name, c.contributor, c.owner_module,
     c.cache_ind, c.extension_ind, c.add_access_ind,
     c.chg_access_ind, c.del_access_ind, c.inq_access_ind,
     c.domain_qualifier_ind, c.domain_code_set, c.updt_dt_tm,
     c.updt_id, c.updt_cnt, c.updt_task,
     c.updt_applctx, c.code_set_hits, c.code_values_cnt,
     c.def_dup_rule_flag, c.cdf_meaning_dup_ind, c.display_key_dup_ind,
     c.active_ind_dup_ind, c.display_dup_ind, c.alias_dup_ind)(SELECT
      a.code_set, cnvtdatetime(sch_date), a.display,
      a.display_key, a.description, a.definition,
      a.table_name, a.contributor, a.owner_module,
      a.cache_ind, a.extension_ind, a.add_access_ind,
      a.chg_access_ind, a.del_access_ind, a.inq_access_ind,
      a.domain_qualifier_ind, a.domain_code_set, a.updt_dt_tm,
      a.updt_id, a.updt_cnt, a.updt_task,
      a.updt_applctx, a.code_set_hits, a.code_values_cnt,
      a.def_dup_rule_flag, a.cdf_meaning_dup_ind, a.display_key_dup_ind,
      a.active_ind_dup_ind, a.display_dup_ind, a.alias_dup_ind
      FROM dm_adm_code_value_set a
      WHERE a.delete_ind != 1
       AND (a.code_set=list->qual[cnt].code_set)
       AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
    ;end insert
    INSERT  FROM dm_common_data_foundation c
     (c.code_set, c.schema_date, c.cdf_meaning,
     c.display, c.definition, c.updt_applctx,
     c.updt_dt_tm, c.updt_id, c.updt_cnt,
     c.updt_task)(SELECT
      a.code_set, cnvtdatetime(sch_date), a.cdf_meaning,
      a.display, a.definition, a.updt_applctx,
      a.updt_dt_tm, a.updt_id, a.updt_cnt,
      a.updt_task
      FROM dm_adm_common_data_foundation a
      WHERE a.delete_ind != 1
       AND (a.code_set=list->qual[cnt].code_set)
       AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
    ;end insert
    INSERT  FROM dm_code_set_extension c
     (c.code_set, c.schema_date, c.field_name,
     c.field_seq, c.field_type, c.field_len,
     c.field_prompt, c.field_in_mask, c.field_out_mask,
     c.validation_condition, c.validation_code_set, c.action_field,
     c.field_default, c.field_help, c.updt_task,
     c.updt_id, c.updt_cnt, c.updt_dt_tm,
     c.updt_applctx)(SELECT
      a.code_set, cnvtdatetime(sch_date), a.field_name,
      a.field_seq, a.field_type, a.field_len,
      a.field_prompt, a.field_in_mask, a.field_out_mask,
      a.validation_condition, a.validation_code_set, a.action_field,
      a.field_default, a.field_help, a.updt_task,
      a.updt_id, a.updt_cnt, a.updt_dt_tm,
      a.updt_applctx
      FROM dm_adm_code_set_extension a
      WHERE a.delete_ind != 1
       AND (a.code_set=list->qual[cnt].code_set)
       AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
    ;end insert
    INSERT  FROM dm_code_value c
     (c.code_value, c.schema_date, c.cki,
     c.code_set, c.cdf_meaning, c.display,
     c.display_key, c.description, c.definition,
     c.collation_seq, c.active_type_cd, c.active_ind,
     c.active_dt_tm, c.inactive_dt_tm, c.updt_dt_tm,
     c.updt_id, c.updt_cnt, c.updt_task,
     c.updt_applctx, c.begin_effective_dt_tm, c.end_effective_dt_tm,
     c.data_status_cd, c.data_status_dt_tm, c.data_status_prsnl_id,
     c.active_status_prsnl_id)(SELECT
      a.code_value, cnvtdatetime(sch_date), a.cki,
      a.code_set, a.cdf_meaning, a.display,
      a.display_key, a.description, a.definition,
      a.collation_seq, a.active_type_cd, a.active_ind,
      a.active_dt_tm, a.inactive_dt_tm, a.updt_dt_tm,
      a.updt_id, a.updt_cnt, a.updt_task,
      a.updt_applctx, a.begin_effective_dt_tm, a.end_effective_dt_tm,
      a.data_status_cd, a.data_status_dt_tm, a.data_status_prsnl_id,
      a.active_status_prsnl_id
      FROM dm_adm_code_value a
      WHERE a.delete_ind != 1
       AND (a.code_set=list->qual[cnt].code_set)
       AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
    ;end insert
    INSERT  FROM dm_code_value_alias c
     (c.code_set, c.schema_date, c.alias,
     c.contributor_source_cd, c.code_value, c.primary_ind,
     c.updt_dt_tm, c.updt_id, c.updt_task,
     c.updt_cnt, c.updt_applctx, c.alias_type_meaning)(SELECT
      a.code_set, cnvtdatetime(sch_date), a.alias,
      a.contributor_source_cd, a.code_value, a.primary_ind,
      a.updt_dt_tm, a.updt_id, a.updt_task,
      a.updt_cnt, a.updt_applctx, a.alias_type_meaning
      FROM dm_adm_code_value_alias a
      WHERE a.delete_ind != 1
       AND (a.code_set=list->qual[cnt].code_set)
       AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
    ;end insert
    INSERT  FROM dm_code_value_extension c
     (c.code_set, c.schema_date, c.field_name,
     c.code_value, c.updt_applctx, c.updt_dt_tm,
     c.updt_id, c.field_type, c.field_value,
     c.updt_cnt, c.updt_task)(SELECT
      a.code_set, cnvtdatetime(sch_date), a.field_name,
      a.code_value, a.updt_applctx, a.updt_dt_tm,
      a.updt_id, a.field_type, a.field_value,
      a.updt_cnt, a.updt_task
      FROM dm_adm_code_value_extension a
      WHERE a.delete_ind != 1
       AND (a.code_set=list->qual[cnt].code_set)
       AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
    ;end insert
   ENDIF
 ENDFOR
 COMMIT
END GO
