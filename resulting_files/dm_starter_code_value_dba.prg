CREATE PROGRAM dm_starter_code_value:dba
 FREE RECORD dmreq
 RECORD dmreq(
   1 qual[*]
     2 dup_rule_flag = i2
     2 code_set = f8
     2 cki = vc
     2 code_value = f8
     2 schema_date = dq8
     2 cdf_meaning = c12
     2 display = c40
     2 display_key = c40
     2 description = c60
     2 definition = c100
     2 collation_seq = i2
     2 active_type_cd = f8
     2 active_ind = i2
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 active_status_prsnl_id = f8
     2 alias = vc
     2 contributor_source_display = vc
     2 contributor_source_cd = f8
   1 cnt = i4
 )
 SET dmreq->cnt = 0
 SET stat = alterlist(dmreq->qual,10)
 SELECT INTO "nl:"
  dcv.code_value, dcv.cki, dcv.schema_date,
  dcv.code_set, dcv.cdf_meaning, dcv.display,
  dcv.display_key, dcv.definition, dcv.collation_seq,
  dcv.active_type_cd, dcv.active_ind, dcv.data_status_cd,
  dcv.data_status_prsnl_id, dcv.end_effective_dt_tm, dcv.begin_effective_dt_tm,
  dcv.active_status_prsnl_id
  FROM dm_adm_code_value dcv,
   dm_adm_code_value_alias d,
   dm_adm_code_value v
  PLAN (dcv
   WHERE datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
    AND (dcv.code_set=list->qual[cnt].code_set)
    AND dcv.delete_ind=0)
   JOIN (d
   WHERE outerjoin(dcv.code_value)=d.code_value)
   JOIN (v
   WHERE outerjoin(d.contributor_source_cd)=v.code_value)
  DETAIL
   dmreq->cnt = (dmreq->cnt+ 1), stat = alterlist(dmreq->qual,(dmreq->cnt+ 1)), dmreq->qual[dmreq->
   cnt].dup_rule_flag = 0,
   dmreq->qual[dmreq->cnt].code_value = dcv.code_value, dmreq->qual[dmreq->cnt].code_set = dcv
   .code_set, dmreq->qual[dmreq->cnt].cki = dcv.cki,
   dmreq->qual[dmreq->cnt].schema_date = cnvtdatetime(dcv.schema_date), dmreq->qual[dmreq->cnt].
   cdf_meaning = dcv.cdf_meaning, dmreq->qual[dmreq->cnt].display = dcv.display,
   dmreq->qual[dmreq->cnt].display_key = dcv.display_key, dmreq->qual[dmreq->cnt].description = dcv
   .description, dmreq->qual[dmreq->cnt].definition = dcv.definition,
   dmreq->qual[dmreq->cnt].collation_seq = dcv.collation_seq, dmreq->qual[dmreq->cnt].active_ind =
   dcv.active_ind, dmreq->qual[dmreq->cnt].active_type_cd = dcv.active_type_cd,
   dmreq->qual[dmreq->cnt].data_status_cd = dcv.data_status_cd, dmreq->qual[dmreq->cnt].
   data_status_prsnl_id = dcv.data_status_prsnl_id, dmreq->qual[dmreq->cnt].active_status_prsnl_id =
   dcv.active_status_prsnl_id,
   dmreq->qual[dmreq->cnt].alias = d.alias, dmreq->qual[dmreq->cnt].contributor_source_display = v
   .display
  WITH nocounter
 ;end select
 SET knt = 0
 FOR (knt = 1 TO dmreq->cnt)
   FREE SET dmrequest
   RECORD dmrequest(
     1 dup_rule_flag = i2
     1 code_set = f8
     1 cki = vc
     1 code_value = f8
     1 schema_date = dq8
     1 cdf_meaning = c12
     1 display = c40
     1 display_key = c40
     1 description = c60
     1 definition = c100
     1 collation_seq = i2
     1 active_type_cd = f8
     1 active_ind = i2
     1 data_status_cd = f8
     1 data_status_dt_tm = dq8
     1 data_status_prsnl_id = f8
     1 active_status_prsnl_id = f8
     1 alias = vc
     1 contributor_source_display = vc
     1 contributor_source_cd = f8
   )
   SET dmrequest->dup_rule_flag = 0
   SET dmrequest->code_value = dmreq->qual[knt].code_value
   SET dmrequest->code_set = dmreq->qual[knt].code_set
   SET dmrequest->cki = dmreq->qual[knt].cki
   SET dmrequest->schema_date = dmreq->qual[knt].schema_date
   SET dmrequest->cdf_meaning = dmreq->qual[knt].cdf_meaning
   SET dmrequest->display = dmreq->qual[knt].display
   SET dmrequest->display_key = dmreq->qual[knt].display_key
   SET dmrequest->description = dmreq->qual[knt].description
   SET dmrequest->definition = dmreq->qual[knt].definition
   SET dmrequest->collation_seq = dmreq->qual[knt].collation_seq
   SET dmrequest->active_ind = dmreq->qual[knt].active_ind
   SET dmrequest->active_type_cd = dmreq->qual[knt].active_type_cd
   SET dmrequest->data_status_cd = dmreq->qual[knt].data_status_cd
   SET dmrequest->data_status_prsnl_id = dmreq->qual[knt].data_status_prsnl_id
   SET dmrequest->active_status_prsnl_id = dmreq->qual[knt].active_status_prsnl_id
   SET dmrequest->alias = dmreq->qual[knt].alias
   SET dmrequest->contributor_source_display = dmreq->qual[knt].contributor_source_display
   SET dmrequest->contributor_source_cd = 0
   SET reqinfo->updt_id = 111
   SET reqinfo->updt_applctx = 111
   EXECUTE dm_insert_code_value
 ENDFOR
 EXECUTE dm_delete_code_value
 COMMIT
END GO
