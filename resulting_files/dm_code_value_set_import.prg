CREATE PROGRAM dm_code_value_set_import
 RECORD dmrequest(
   1 code_set = i4
   1 display = c40
   1 description = c60
   1 definition = c500
   1 table_name = c32
   1 cache_ind = i2
   1 add_access_ind = i2
   1 chg_access_ind = i2
   1 del_access_ind = i2
   1 inq_access_ind = i2
   1 domain_qualifier_ind = i2
   1 domain_code_set = i4
   1 add_code_value_ind = i2
   1 add_code_value_default = i4
   1 def_dup_rule_flag = i2
   1 cdf_meaning_dup_ind = i2
   1 display_key_dup_ind = i2
   1 active_ind_dup_ind = i2
   1 display_dup_ind = i2
   1 alias_dup_ind = i2
 )
 SET dmrequest->code_set = cnvtint(requestin->list_0[1].code_set)
 SET dmrequest->display = requestin->list_0[1].display
 SET dmrequest->description = requestin->list_0[1].description
 SET dmrequest->definition = requestin->list_0[1].definition
 SET dmrequest->cache_ind = cnvtint(requestin->list_0[1].cache_ind)
 SET dmrequest->add_access_ind = cnvtint(requestin->list_0[1].add_access_ind)
 SET dmrequest->chg_access_ind = cnvtint(requestin->list_0[1].chg_access_ind)
 SET dmrequest->del_access_ind = cnvtint(requestin->list_0[1].del_access_ind)
 SET dmrequest->inq_access_ind = cnvtint(requestin->list_0[1].inq_access_ind)
 SET dmrequest->def_dup_rule_flag = cnvtint(requestin->list_0[1].def_dup_rule_flag)
 SET dmrequest->cdf_meaning_dup_ind = cnvtint(requestin->list_0[1].cdf_meaning_dup_ind)
 SET dmrequest->display_key_dup_ind = cnvtint(requestin->list_0[1].display_key_dup_ind)
 SET dmrequest->active_ind_dup_ind = cnvtint(requestin->list_0[1].active_ind_dup_ind)
 SET dmrequest->display_dup_ind = cnvtint(requestin->list_0[1].display_dup_ind)
 SET dmrequest->alias_dup_ind = cnvtint(requestin->list_0[1].alias_dup_ind)
 EXECUTE dm_code_value_set
END GO
