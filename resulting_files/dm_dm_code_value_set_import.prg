CREATE PROGRAM dm_dm_code_value_set_import
 RECORD request(
   1 code_set = i4
   1 display = c40
   1 description = c60
   1 definition = c500
   1 table_name = c32
   1 cache_ind = i2
   1 add_access_ind = i2
   1 extension_ind = i2
   1 chg_access_ind = i2
   1 del_access_ind = i2
   1 inq_access_ind = i2
   1 domain_qualifier_ind = i2
   1 domain_code_set = i4
   1 add_code_value_ind = i2
   1 add_code_value_default = i4
   1 default_dup_rule_flag = i2
   1 cdf_meaning_dup_ind = i2
   1 display_key_dup_ind = i2
   1 active_ind_dup_ind = i2
   1 display_dup_ind = i2
   1 alias_dup_ind = i2
 )
 SET request->code_set = cnvtint(requestin->list_0[1].code_set)
 SET request->display = requestin->list_0[1].display
 SET request->description = requestin->list_0[1].description
 SET request->definition = requestin->list_0[1].definition
 SET request->cache_ind = cnvtint(requestin->list_0[1].cache_ind)
 SET request->add_access_ind = cnvtint(requestin->list_0[1].add_access_ind)
 SET request->extension_ind = 0
 SET request->chg_access_ind = cnvtint(requestin->list_0[1].chg_access_ind)
 SET request->del_access_ind = cnvtint(requestin->list_0[1].del_access_ind)
 SET request->inq_access_ind = cnvtint(requestin->list_0[1].inq_access_ind)
 SET request->default_dup_rule_flag = cnvtint(requestin->list_0[1].def_dup_rule_flag)
 SET request->cdf_meaning_dup_ind = cnvtint(requestin->list_0[1].cdf_meaning_dup_ind)
 SET request->display_key_dup_ind = cnvtint(requestin->list_0[1].display_key_dup_ind)
 SET request->active_ind_dup_ind = cnvtint(requestin->list_0[1].active_ind_dup_ind)
 SET request->display_dup_ind = cnvtint(requestin->list_0[1].display_dup_ind)
 SET request->alias_dup_ind = cnvtint(requestin->list_0[1].alias_dup_ind)
 EXECUTE dm_dm_chg_code_set
END GO
