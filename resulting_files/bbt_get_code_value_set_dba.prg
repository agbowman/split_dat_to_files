CREATE PROGRAM bbt_get_code_value_set:dba
 RECORD reply(
   1 code_set = i4
   1 display = c40
   1 display_key = c40
   1 description = vc
   1 definition = vc
   1 table_name = c32
   1 contributor = c18
   1 owner_module = c12
   1 cache_ind = i2
   1 extension_ind = i2
   1 add_access_ind = i2
   1 chg_access_ind = i2
   1 del_access_ind = i2
   1 inq_access_ind = i2
   1 domain_qualifier_ind = i2
   1 domain_code_set = i4
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 updt_cnt = i4
   1 updt_task = i4
   1 updt_applctx = i4
   1 code_set_hits = i4
   1 code_values_cnt = i4
   1 def_dup_rule_flag = i2
   1 cdf_meaning_dup_ind = i2
   1 display_key_dup_ind = i2
   1 active_ind_dup_ind = i2
   1 display_dup_ind = i2
   1 alias_dup_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET failed = "T"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cvs.code_set, cvs.display, cvs.display_key,
  cvs.description, cvs.definition, cvs.table_name,
  cvs.contributor, cvs.owner_module, cvs.cache_ind,
  cvs.extension_ind, cvs.add_access_ind, cvs.chg_access_ind,
  cvs.del_access_ind, cvs.inq_access_ind, cvs.domain_qualifier_ind,
  cvs.domain_code_set, cvs.updt_dt_tm, cvs.updt_id,
  cvs.updt_cnt, cvs.updt_task, cvs.updt_applctx,
  cvs.code_set_hits, cvs.code_values_cnt, cvs.def_dup_rule_flag,
  cvs.cdf_meaning_dup_ind, cvs.display_key_dup_ind, cvs.active_ind_dup_ind,
  cvs.display_dup_ind, cvs.alias_dup_ind
  FROM code_value_set cvs
  WHERE (cvs.code_set=request->code_set)
  DETAIL
   reply->code_set = cvs.code_set, reply->display = cvs.display, reply->display_key = cvs.display_key,
   reply->description = cvs.description, reply->definition = cvs.definition, reply->table_name = cvs
   .table_name,
   reply->contributor = cvs.contributor, reply->owner_module = cvs.owner_module, reply->cache_ind =
   cvs.cache_ind,
   reply->extension_ind = cvs.extension_ind, reply->add_access_ind = cvs.add_access_ind, reply->
   chg_access_ind = cvs.chg_access_ind,
   reply->del_access_ind = cvs.del_access_ind, reply->inq_access_ind = cvs.inq_access_ind, reply->
   domain_qualifier_ind = cvs.domain_qualifier_ind,
   reply->domain_code_set = cvs.domain_code_set, reply->updt_dt_tm = cvs.updt_dt_tm, reply->updt_id
    = cvs.updt_id,
   reply->updt_cnt = cvs.updt_cnt, reply->updt_task = cvs.updt_task, reply->updt_applctx = cvs
   .updt_applctx,
   reply->code_set_hits = cvs.code_set_hits, reply->code_values_cnt = cvs.code_values_cnt, reply->
   def_dup_rule_flag = cvs.def_dup_rule_flag,
   reply->cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind, reply->display_key_dup_ind = cvs
   .display_key_dup_ind, reply->active_ind_dup_ind = cvs.active_ind_dup_ind,
   reply->display_dup_ind = cvs.display_dup_ind, reply->alias_dup_ind = cvs.alias_dup_ind
  FOOT REPORT
   failed = "F"
  WITH nocounter, nullreport
 ;end select
 SET reply->status_data.subeventstatus[count1].operationname = "Get code_value_set"
 SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_code_value_set"
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Select on code_value_set failed"
 ENDIF
END GO
