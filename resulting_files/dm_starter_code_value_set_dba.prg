CREATE PROGRAM dm_starter_code_value_set:dba
 FREE SET dmreq
 RECORD dmreq(
   1 qual[*]
     2 code_set = i4
     2 display = c40
     2 description = vc
     2 definition = vc
     2 table_name = c32
     2 contributor = c18
     2 cache_ind = i2
     2 extension_ind = i2
     2 add_access_ind = i2
     2 chg_access_ind = i2
     2 del_access_ind = i2
     2 inq_access_ind = i2
     2 domain_qualifier_ind = i2
     2 domain_code_set = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_cnt = i4
     2 updt_task = i4
     2 updt_applctx = i4
     2 add_code_value_ind = i2
     2 add_code_value_default = i4
     2 def_dup_rule_flag = i2
     2 cdf_meaning_dup_ind = i2
     2 display_key_dup_ind = i2
     2 active_ind_dup_ind = i2
     2 display_dup_ind = i2
     2 alias_dup_ind = i2
     2 definition_dup_ind = i2
   1 cnt = i4
 )
 SET dmreq->cnt = 0
 SET stat = alterlist(dmreq->qual,10)
 SELECT INTO "nl:"
  dcv.code_set, dcv.display, dcv.description,
  dcv.definition, dcv.table_name, dcv.contributor,
  dcv.cache_ind, dcv.extension_ind, dcv.add_access_ind,
  dcv.chg_access_ind, dcv.del_access_ind, dcv.inq_access_ind,
  dcv.domain_qualifier_ind, dcv.domain_code_set, dcv.updt_dt_tm,
  dcv.updt_id, dcv.updt_cnt, dcv.updt_task,
  dcv.updt_applctx, dcv.code_set_hits, dcv.code_values_cnt,
  dcv.def_dup_rule_flag, dcv.cdf_meaning_dup_ind, dcv.display_key_dup_ind,
  dcv.active_ind_dup_ind, dcv.display_dup_ind, dcv.alias_dup_ind,
  dcv.definition_dup_ind
  FROM dm_adm_code_value_set dcv
  WHERE datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
   AND (dcv.code_set=list->qual[cnt].code_set)
   AND dcv.delete_ind=0
  DETAIL
   dmreq->cnt = (dmreq->cnt+ 1), stat = alterlist(dmreq->qual,(dmreq->cnt+ 1)), dmreq->qual[dmreq->
   cnt].code_set = dcv.code_set,
   dmreq->qual[dmreq->cnt].display = dcv.display, dmreq->qual[dmreq->cnt].description = dcv
   .description, dmreq->qual[dmreq->cnt].definition = dcv.definition,
   dmreq->qual[dmreq->cnt].table_name = dcv.table_name, dmreq->qual[dmreq->cnt].cache_ind = dcv
   .cache_ind, dmreq->qual[dmreq->cnt].extension_ind = dcv.extension_ind,
   dmreq->qual[dmreq->cnt].add_access_ind = dcv.add_access_ind, dmreq->qual[dmreq->cnt].
   chg_access_ind = dcv.chg_access_ind, dmreq->qual[dmreq->cnt].del_access_ind = dcv.del_access_ind,
   dmreq->qual[dmreq->cnt].inq_access_ind = dcv.inq_access_ind, dmreq->qual[dmreq->cnt].
   domain_qualifier_ind = dcv.domain_qualifier_ind, dmreq->qual[dmreq->cnt].domain_code_set = dcv
   .domain_code_set,
   dmreq->qual[dmreq->cnt].def_dup_rule_flag = dcv.def_dup_rule_flag, dmreq->qual[dmreq->cnt].
   cdf_meaning_dup_ind = dcv.cdf_meaning_dup_ind, dmreq->qual[dmreq->cnt].display_key_dup_ind = dcv
   .display_key_dup_ind,
   dmreq->qual[dmreq->cnt].active_ind_dup_ind = dcv.active_ind_dup_ind, dmreq->qual[dmreq->cnt].
   display_dup_ind = dcv.display_dup_ind, dmreq->qual[dmreq->cnt].alias_dup_ind = dcv.alias_dup_ind,
   dmreq->qual[dmreq->cnt].definition_dup_ind = dcv.definition_dup_ind
  WITH nocounter
 ;end select
 SET knt = 0
 FOR (knt = 1 TO dmreq->cnt)
   FREE SET dmrequest
   RECORD dmrequest(
     1 code_set = i4
     1 display = c40
     1 description = vc
     1 definition = vc
     1 table_name = c32
     1 contributor = c18
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
     1 add_code_value_ind = i2
     1 add_code_value_default = i4
     1 def_dup_rule_flag = i2
     1 cdf_meaning_dup_ind = i2
     1 display_key_dup_ind = i2
     1 active_ind_dup_ind = i2
     1 display_dup_ind = i2
     1 alias_dup_ind = i2
     1 definition_dup_ind = i2
   )
   SET dmrequest->code_set = dmreq->qual[knt].code_set
   SET dmrequest->display = dmreq->qual[knt].display
   SET dmrequest->description = dmreq->qual[knt].description
   SET dmrequest->definition = dmreq->qual[knt].definition
   SET dmrequest->table_name = dmreq->qual[knt].table_name
   SET dmrequest->cache_ind = dmreq->qual[knt].cache_ind
   SET dmrequest->extension_ind = dmreq->qual[knt].extension_ind
   SET dmrequest->add_access_ind = dmreq->qual[knt].add_access_ind
   SET dmrequest->chg_access_ind = dmreq->qual[knt].chg_access_ind
   SET dmrequest->del_access_ind = dmreq->qual[knt].del_access_ind
   SET dmrequest->inq_access_ind = dmreq->qual[knt].inq_access_ind
   SET dmrequest->domain_qualifier_ind = dmreq->qual[knt].domain_qualifier_ind
   SET dmrequest->domain_code_set = dmreq->qual[knt].domain_code_set
   SET dmrequest->def_dup_rule_flag = dmreq->qual[knt].def_dup_rule_flag
   SET dmrequest->cdf_meaning_dup_ind = dmreq->qual[knt].cdf_meaning_dup_ind
   SET dmrequest->display_key_dup_ind = dmreq->qual[knt].display_key_dup_ind
   SET dmrequest->active_ind_dup_ind = dmreq->qual[knt].active_ind_dup_ind
   SET dmrequest->display_dup_ind = dmreq->qual[knt].display_dup_ind
   SET dmrequest->alias_dup_ind = dmreq->qual[knt].alias_dup_ind
   SET dmrequest->definition_dup_ind = dmreq->qual[knt].definition_dup_ind
   SET reqinfo->updt_id = 111
   SET reqinfo->updt_applctx = 111
   EXECUTE dm_code_value_set
 ENDFOR
 DELETE  FROM code_value_set cvs
  WHERE (cvs.code_set=
  (SELECT
   d.code_set
   FROM dm_adm_code_value_set d
   WHERE (d.code_set=list->qual[cnt].code_set)
    AND d.schema_date=cnvtdatetime(r1->rdate)
    AND d.delete_ind=1))
  WITH nocounter
 ;end delete
 COMMIT
END GO
