CREATE PROGRAM dm_add_code_set:dba
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
 INSERT  FROM code_value_set c
  SET c.code_set = request->code_set, c.display = request->display, c.display_key = cnvtupper(
    cnvtalphanum(request->display_key)),
   c.description = request->description, c.definition = request->definition, c.cache_ind = request->
   cache_ind,
   c.extension_ind = request->extension_ind, c.add_access_ind = request->add_access_ind, c
   .chg_access_ind = request->chg_access_ind,
   c.del_access_ind = request->del_access_ind, c.inq_access_ind = request->inq_access_ind, c
   .display_dup_ind = request->display_dup_ind,
   c.display_key_dup_ind = request->display_key_dup_ind, c.cdf_meaning_dup_ind = request->
   cdf_meaning_dup_ind, c.active_ind_dup_ind = request->active_ind_dup_ind,
   c.alias_dup_ind = request->alias_dup_ind, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id
    = reqinfo->updt_id,
   c.updt_cnt = 0, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  ROLLBACK
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
