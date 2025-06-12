CREATE PROGRAM dm_dm_one_code_set:dba
 RECORD reply(
   1 code_set = i4
   1 display = c40
   1 display_key = c40
   1 descr_null_ind = i2
   1 description = vc
   1 def_null_ind = i2
   1 definition = vc
   1 cache_ind = i2
   1 extension_ind = i2
   1 add_access_ind = i2
   1 chg_access_ind = i2
   1 del_access_ind = i2
   1 inq_access_ind = i2
   1 default_dup_rule_flag = i2
   1 display_dup_ind = i2
   1 display_key_dup_ind = i2
   1 cdf_meaning_dup_ind = i2
   1 active_ind_dup_ind = i2
   1 definition_dup_ind = i2
   1 alias_dup_ind = i2
   1 updt_cnt = i4
   1 delete_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET nulldef = 0
 SET nulldescr = 0
 FREE SET r1
 RECORD r1(
   1 rdate = dq8
 )
 SET r1->rdate = 0
 SELECT INTO "nl:"
  dac.schema_date
  FROM dm_adm_code_value_set dac
  WHERE (dac.code_set=request->code_set)
  DETAIL
   IF ((dac.schema_date > r1->rdate))
    r1->rdate = dac.schema_date
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_set, c.display, c.display_key,
  c.description, nulldescr = nullind(c.description), c.definition,
  nulldef = nullind(c.definition), c.cache_ind, c.extension_ind,
  c.add_access_ind, c.chg_access_ind, c.del_access_ind,
  c.inq_access_ind, c.def_dup_rule_flag, c.display_dup_ind,
  c.display_key_dup_ind, c.cdf_meaning_dup_ind, c.active_ind_dup_ind,
  c.alias_dup_ind, c.definition_dup_ind, c.updt_cnt,
  c.delete_ind
  FROM dm_adm_code_value_set c
  WHERE (c.code_set=request->code_set)
   AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
  DETAIL
   reply->code_set = c.code_set, reply->display = c.display, reply->display_key = c.display_key,
   reply->description = c.description, reply->descr_null_ind =
   IF (nulldescr=0) 0
   ELSE 1
   ENDIF
   , reply->definition = c.definition,
   reply->def_null_ind =
   IF (nulldef=0) 0
   ELSE 1
   ENDIF
   , reply->cache_ind = c.cache_ind, reply->extension_ind = c.extension_ind,
   reply->add_access_ind = c.add_access_ind, reply->chg_access_ind = c.chg_access_ind, reply->
   del_access_ind = c.del_access_ind,
   reply->inq_access_ind = c.inq_access_ind, reply->default_dup_rule_flag = c.def_dup_rule_flag,
   reply->display_dup_ind = c.display_dup_ind,
   reply->display_key_dup_ind = c.display_key_dup_ind, reply->cdf_meaning_dup_ind = c
   .cdf_meaning_dup_ind, reply->active_ind_dup_ind = c.active_ind_dup_ind,
   reply->alias_dup_ind = c.alias_dup_ind, reply->definition_dup_ind = c.definition_dup_ind, reply->
   updt_cnt = c.updt_cnt,
   reply->delete_ind = c.delete_ind
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
