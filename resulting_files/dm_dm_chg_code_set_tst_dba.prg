CREATE PROGRAM dm_dm_chg_code_set_tst:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET updt_cnt = 0
 INSERT  FROM dm_adm_code_value_set c
  SET c.code_set = request->code_set, c.schema_date = cnvtdatetime(request->schema_date), c.display
    = request->display,
   c.display_key = cnvtupper(cnvtalphanum(request->display)), c.description = request->description, c
   .definition = request->definition,
   c.cache_ind = request->cache_ind, c.extension_ind = request->extension_ind, c.add_access_ind =
   request->add_access_ind,
   c.chg_access_ind = request->chg_access_ind, c.del_access_ind = request->del_access_ind, c
   .inq_access_ind = request->inq_access_ind,
   c.def_dup_rule_flag = request->default_dup_rule_flag, c.display_dup_ind = request->display_dup_ind,
   c.display_key_dup_ind = request->display_key_dup_ind,
   c.cdf_meaning_dup_ind = request->cdf_meaning_dup_ind, c.active_ind_dup_ind = request->
   active_ind_dup_ind, c.definition_dup_ind = request->definition_dup_ind,
   c.alias_dup_ind = request->alias_dup_ind, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id
    = reqinfo->updt_id,
   c.updt_cnt = 0, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx,
   c.delete_ind = request->delete_ind
  WITH nocounter
 ;end insert
 IF (curqual=0)
  ROLLBACK
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
