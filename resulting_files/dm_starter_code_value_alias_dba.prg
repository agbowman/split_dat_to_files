CREATE PROGRAM dm_starter_code_value_alias:dba
 FREE RECORD dmreq
 RECORD dmreq(
   1 qual[*]
     2 alias = vc
     2 schema_date = dq8
     2 code_set = i4
     2 display = vc
     2 cdf_meaning = c12
     2 active_ind = i2
     2 cki = vc
     2 alias_type_meaning = vc
     2 contributor_source_disp = vc
     2 contributor_source_cd = i2
     2 primary_ind = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = i4
   1 cnt = i4
 )
 SET dmreq->cnt = 0
 SET stat = alterlist(dmreq->qual,10)
 SELECT INTO "nl:"
  dcv.code_set, dcv.schema_date, dcv.code_value,
  dcv.alias, dcv.contributor_source_cd, dcv.alias_type_meaning,
  dcv.primary_ind, dcv.updt_dt_tm, dcv.updt_id,
  dcv.updt_task, dcv.updt_cnt, dcv.updt_applctx,
  dc.cdf_meaning, dc.display, dc.active_ind,
  dc.cki, dca.display
  FROM dm_adm_code_value_alias dcv,
   dm_adm_code_value dc,
   dm_adm_code_value dca
  WHERE (dcv.code_set=list->qual[cnt].code_set)
   AND datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
   AND dcv.delete_ind=0
   AND dc.code_value=dcv.code_value
   AND dc.schema_date=dcv.schema_date
   AND dca.code_value=dcv.contributor_source_cd
   AND dca.schema_date IN (
  (SELECT
   max(d.schema_date)
   FROM dm_adm_code_value d
   WHERE d.code_set=73
    AND d.code_value=dca.code_value))
  DETAIL
   dmreq->cnt = (dmreq->cnt+ 1), stat = alterlist(dmreq->qual,(dmreq->cnt+ 1)), dmreq->qual[dmreq->
   cnt].code_set = dcv.code_set,
   dmreq->qual[dmreq->cnt].schema_date = cnvtdatetime(dcv.schema_date), dmreq->qual[dmreq->cnt].cki
    = dc.cki, dmreq->qual[dmreq->cnt].alias = dcv.alias,
   dmreq->qual[dmreq->cnt].alias_type_meaning = dcv.alias_type_meaning, dmreq->qual[dmreq->cnt].
   contributor_source_disp = dca.display, dmreq->qual[dmreq->cnt].display = dc.display,
   dmreq->qual[dmreq->cnt].cdf_meaning = dc.cdf_meaning, dmreq->qual[dmreq->cnt].active_ind = dc
   .active_ind, dmreq->qual[dmreq->cnt].primary_ind = dcv.primary_ind
  WITH nocounter
 ;end select
 SET knt = 0
 FOR (knt = 1 TO dmreq->cnt)
   FREE SET dmrequest
   RECORD dmrequest(
     1 alias = vc
     1 schema_date = dq8
     1 code_set = i4
     1 display = vc
     1 cdf_meaning = c12
     1 active_ind = i2
     1 cki = vc
     1 alias_type_meaning = vc
     1 contributor_source_disp = vc
     1 contributor_source_cd = i2
     1 primary_ind = i2
     1 updt_dt_tm = dq8
     1 updt_id = f8
     1 updt_task = i4
     1 updt_cnt = i4
     1 updt_applctx = i4
   )
   SET dmrequest->code_set = dmreq->qual[knt].code_set
   SET dmrequest->schema_date = dmreq->qual[knt].schema_date
   SET dmrequest->cki = dmreq->qual[knt].cki
   SET dmrequest->alias = dmreq->qual[knt].alias
   SET dmrequest->alias_type_meaning = dmreq->qual[knt].alias_type_meaning
   SET dmrequest->contributor_source_disp = dmreq->qual[knt].contributor_source_disp
   SET dmrequest->display = dmreq->qual[knt].display
   SET dmrequest->cdf_meaning = dmreq->qual[knt].cdf_meaning
   SET dmrequest->active_ind = dmreq->qual[knt].active_ind
   SET dmrequest->primary_ind = dmreq->qual[knt].primary_ind
   SET reqinfo->updt_id = 111
   SET reqinfo->updt_applctx = 111
   EXECUTE dm_code_value_alias
   EXECUTE dm_delete_cva
 ENDFOR
 COMMIT
END GO
