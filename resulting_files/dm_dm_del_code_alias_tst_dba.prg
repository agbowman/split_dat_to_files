CREATE PROGRAM dm_dm_del_code_alias_tst:dba
 RECORD reply(
   1 qual[*]
     2 code_set = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET qual_size = size(request->qual,5)
 FREE SET list_cv
 RECORD list_cv(
   1 qual[*]
     2 code_value = f8
   1 cnt = i4
 )
 SET list_cv->cnt = 0
 SET stat = alterlist(list_cv->qual,10)
 SELECT DISTINCT INTO "nl:"
  c.code_value
  FROM dm_adm_code_value c,
   (dummyt d  WITH seq = value(qual_size))
  PLAN (d)
   JOIN (c
   WHERE (c.display=request->qual[d.seq].display)
    AND c.code_set=73)
  DETAIL
   list_cv->cnt = (list_cv->cnt+ 1), stat = alterlist(list_cv->qual,list_cv->cnt), list_cv->qual[
   list_cv->cnt].code_value = c.code_value
  WITH nocounter, maxqual(c,1)
 ;end select
 FREE SET list
 RECORD list(
   1 var[*]
     2 code_set = i4
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->var,10)
 SELECT DISTINCT INTO "nl:"
  dm.code_set
  FROM dm_adm_code_value_alias dm,
   (dummyt d2  WITH seq = value(list_cv->cnt))
  PLAN (d2)
   JOIN (dm
   WHERE (dm.contributor_source_cd=list_cv->qual[d2.seq].code_value)
    AND dm.delete_ind=0)
  DETAIL
   list->count = (list->count+ 1), stat = alterlist(list->var,list->count), stat2 = alterlist(reply->
    qual,list->count),
   list->var[list->count].code_set = dm.code_set, reply->qual[list->count].code_set = list->var[list
   ->count].code_set
  WITH nocounter, maxqual(dm,1)
 ;end select
 SET z = 0
 FOR (z = 1 TO list->count)
   FREE SET r1
   RECORD r1(
     1 rdate = dq8
   )
   SET r1->rdate = 0
   SELECT INTO "NL:"
    dcf.schema_date
    FROM dm_adm_code_value_set dcf
    WHERE (dcf.code_set=list->var[z].code_set)
    DETAIL
     IF ((dcf.schema_date > r1->rdate))
      r1->rdate = dcf.schema_date
     ENDIF
    WITH nocounter
   ;end select
   INSERT  FROM dm_adm_code_value_set c
    (c.code_set, c.schema_date, c.display,
    c.display_key, c.description, c.definition,
    c.table_name, c.contributor, c.owner_module,
    c.cache_ind, c.extension_ind, c.add_access_ind,
    c.chg_access_ind, c.del_access_ind, c.inq_access_ind,
    c.domain_qualifier_ind, c.domain_code_set, c.updt_dt_tm,
    c.updt_id, c.updt_cnt, c.updt_task,
    c.updt_applctx, c.code_set_hits, c.code_values_cnt,
    c.def_dup_rule_flag, c.cdf_meaning_dup_ind, c.display_key_dup_ind,
    c.active_ind_dup_ind, c.display_dup_ind, c.alias_dup_ind,
    c.definition_dup_ind, c.delete_ind)(SELECT
     a.code_set, cnvtdatetime(request->schema_date), a.display,
     a.display_key, a.description, a.definition,
     a.table_name, a.contributor, a.owner_module,
     a.cache_ind, a.extension_ind, a.add_access_ind,
     a.chg_access_ind, a.del_access_ind, a.inq_access_ind,
     a.domain_qualifier_ind, a.domain_code_set, a.updt_dt_tm,
     a.updt_id, a.updt_cnt, a.updt_task,
     a.updt_applctx, a.code_set_hits, a.code_values_cnt,
     a.def_dup_rule_flag, a.cdf_meaning_dup_ind, a.display_key_dup_ind,
     a.active_ind_dup_ind, a.display_dup_ind, a.alias_dup_ind,
     a.definition_dup_ind, a.delete_ind
     FROM dm_adm_code_value_set a
     WHERE (a.code_set=list->var[z].code_set)
      AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
   ;end insert
   INSERT  FROM dm_adm_common_data_foundation c
    (c.code_set, c.schema_date, c.cdf_meaning,
    c.display, c.definition, c.updt_applctx,
    c.updt_dt_tm, c.updt_id, c.updt_cnt,
    c.updt_task, c.delete_ind)(SELECT
     a.code_set, cnvtdatetime(request->schema_date), a.cdf_meaning,
     a.display, a.definition, a.updt_applctx,
     a.updt_dt_tm, a.updt_id, a.updt_cnt,
     a.updt_task, a.delete_ind
     FROM dm_adm_common_data_foundation a
     WHERE (a.code_set=list->var[z].code_set)
      AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
   ;end insert
   INSERT  FROM dm_adm_code_set_extension c
    (c.code_set, c.schema_date, c.field_name,
    c.field_seq, c.field_type, c.field_len,
    c.field_prompt, c.field_in_mask, c.field_out_mask,
    c.validation_condition, c.validation_code_set, c.action_field,
    c.field_default, c.field_help, c.updt_task,
    c.updt_id, c.updt_cnt, c.updt_dt_tm,
    c.updt_applctx, c.delete_ind)(SELECT
     a.code_set, cnvtdatetime(request->schema_date), a.field_name,
     a.field_seq, a.field_type, a.field_len,
     a.field_prompt, a.field_in_mask, a.field_out_mask,
     a.validation_condition, a.validation_code_set, a.action_field,
     a.field_default, a.field_help, a.updt_task,
     a.updt_id, a.updt_cnt, a.updt_dt_tm,
     a.updt_applctx, a.delete_ind
     FROM dm_adm_code_set_extension a
     WHERE (a.code_set=list->var[z].code_set)
      AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
   ;end insert
   INSERT  FROM dm_adm_code_value c
    (c.code_value, c.schema_date, c.code_set,
    c.cdf_meaning, c.display, c.display_key,
    c.description, c.definition, c.collation_seq,
    c.active_type_cd, c.active_ind, c.active_dt_tm,
    c.inactive_dt_tm, c.updt_dt_tm, c.updt_id,
    c.updt_cnt, c.updt_task, c.updt_applctx,
    c.begin_effective_dt_tm, c.end_effective_dt_tm, c.data_status_cd,
    c.data_status_dt_tm, c.data_status_prsnl_id, c.active_status_prsnl_id,
    c.delete_ind)(SELECT
     a.code_value, cnvtdatetime(request->schema_date), a.code_set,
     a.cdf_meaning, a.display, a.display_key,
     a.description, a.definition, a.collation_seq,
     a.active_type_cd, a.active_ind, a.active_dt_tm,
     a.inactive_dt_tm, a.updt_dt_tm, a.updt_id,
     a.updt_cnt, a.updt_task, a.updt_applctx,
     a.begin_effective_dt_tm, a.end_effective_dt_tm, a.data_status_cd,
     a.data_status_dt_tm, a.data_status_prsnl_id, a.active_status_prsnl_id,
     a.delete_ind
     FROM dm_adm_code_value a
     WHERE (a.code_set=list->var[z].code_set)
      AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
   ;end insert
   INSERT  FROM dm_adm_code_value_alias c
    (c.code_set, c.schema_date, c.alias,
    c.contributor_source_cd, c.code_value, c.primary_ind,
    c.updt_dt_tm, c.updt_id, c.updt_task,
    c.updt_cnt, c.updt_applctx, c.alias_type_meaning,
    c.delete_ind)(SELECT
     a.code_set, cnvtdatetime(request->schema_date), a.alias,
     a.contributor_source_cd, a.code_value, a.primary_ind,
     a.updt_dt_tm, a.updt_id, a.updt_task,
     a.updt_cnt, a.updt_applctx, a.alias_type_meaning,
     a.delete_ind
     FROM dm_adm_code_value_alias a
     WHERE (a.code_set=list->var[z].code_set)
      AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
   ;end insert
   INSERT  FROM dm_adm_code_value_extension c
    (c.code_set, c.schema_date, c.field_name,
    c.code_value, c.updt_applctx, c.updt_dt_tm,
    c.updt_id, c.field_type, c.field_value,
    c.updt_cnt, c.updt_task, c.delete_ind)(SELECT
     a.code_set, cnvtdatetime(request->schema_date), a.field_name,
     a.code_value, a.updt_applctx, a.updt_dt_tm,
     a.updt_id, a.field_type, a.field_value,
     a.updt_cnt, a.updt_task, a.delete_ind
     FROM dm_adm_code_value_extension a
     WHERE (a.code_set=list->var[z].code_set)
      AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0)
   ;end insert
 ENDFOR
 FOR (y = 1 TO qual_size)
   UPDATE  FROM dm_adm_code_value_alias d
    SET d.delete_ind = 1
    WHERE (d.contributor_source_cd=list_cv->qual[y].code_value)
     AND datetimediff(d.schema_date,cnvtdatetime(request->schema_date))=0
   ;end update
 ENDFOR
 COMMIT
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
