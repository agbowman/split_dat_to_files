CREATE PROGRAM cs_chg_code_set:dba
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
 SELECT INTO "nl:"
  c.*
  FROM code_value_set c
  WHERE (c.code_set=request->code_set)
  HEAD REPORT
   updt_cnt = c.updt_cnt
  WITH nocounter, forupdate(c)
 ;end select
 IF (curqual=0)
  ROLLBACK
  GO TO script_error
 ENDIF
 IF ((updt_cnt != request->updt_cnt))
  ROLLBACK
  GO TO script_error
 ENDIF
 UPDATE  FROM code_value_set c
  SET c.display = request->display, c.display_key = cnvtupper(cnvtalphanum(request->display_key)), c
   .description = request->description,
   c.definition = request->definition, c.table_name = request->table_name, c.contributor = request->
   contributor,
   c.owner_module = request->owner_module, c.cache_ind = request->cache_ind, c.extension_ind =
   request->extension_ind,
   c.add_access_ind = request->add_access_ind, c.chg_access_ind = request->chg_access_ind, c
   .del_access_ind = request->del_access_ind,
   c.inq_access_ind = request->inq_access_ind, c.domain_qualifier_ind = request->domain_qualifier_ind,
   c.domain_code_set = request->domain_code_set,
   c.display_dup_ind = request->display_dup_ind, c.display_key_dup_ind = request->display_key_dup_ind,
   c.cdf_meaning_dup_ind = request->cdf_meaning_dup_ind,
   c.active_ind_dup_ind = request->active_ind_dup_ind, c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   c.updt_id = reqinfo->updt_id,
   c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
   updt_applctx
  WHERE (c.code_set=request->code_set)
 ;end update
 IF (curqual=0)
  ROLLBACK
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
#script_error
END GO
