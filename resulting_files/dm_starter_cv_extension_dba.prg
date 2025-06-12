CREATE PROGRAM dm_starter_cv_extension:dba
 FREE RECORD dmreq
 RECORD dmreq(
   1 qual[*]
     2 field_name = c32
     2 code_set = i4
     2 schema_date = dq8
     2 code_value = f8
     2 display = vc
     2 cdf_meaning = c12
     2 active_ind = i2
     2 field_type = i4
     2 field_value = c100
     2 cki = vc
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_cnt = i4
     2 updt_applctx = i4
     2 updt_task = f8
   1 cnt = i4
 )
 SET dmreq->cnt = 0
 SET stat = alterlist(dmreq->qual,10)
 SELECT INTO "nl:"
  dcv.code_set, dcv.schema_date, dcv.code_value,
  dcv.field_name, dcv.field_type, dcv.field_value,
  dcv.updt_id, dcv.updt_cnt, dcv.updt_task,
  dcv.updt_dt_tm, dcv.updt_applctx, dc.display,
  dc.cdf_meaning, dc.cki, dc.active_ind
  FROM dm_adm_code_value_extension dcv,
   dm_adm_code_value dc
  WHERE datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
   AND (dcv.code_set=list->qual[cnt].code_set)
   AND dcv.delete_ind=0
   AND dc.code_value=dcv.code_value
   AND dcv.schema_date=dc.schema_date
  DETAIL
   dmreq->cnt = (dmreq->cnt+ 1), stat = alterlist(dmreq->qual,(dmreq->cnt+ 1)), dmreq->qual[dmreq->
   cnt].code_set = dcv.code_set,
   dmreq->qual[dmreq->cnt].schema_date = cnvtdatetime(dcv.schema_date), dmreq->qual[dmreq->cnt].cki
    = dc.cki, dmreq->qual[dmreq->cnt].field_name = dcv.field_name,
   dmreq->qual[dmreq->cnt].field_value = dcv.field_value, dmreq->qual[dmreq->cnt].field_type = dcv
   .field_type, dmreq->qual[dmreq->cnt].display = dc.display,
   dmreq->qual[dmreq->cnt].cdf_meaning = dc.cdf_meaning, dmreq->qual[dmreq->cnt].active_ind = dc
   .active_ind
  WITH nocounter
 ;end select
 SET knt = 0
 FOR (knt = 1 TO dmreq->cnt)
   FREE SET dmrequest
   RECORD dmrequest(
     1 field_name = c32
     1 code_set = i4
     1 schema_date = dq8
     1 code_value = f8
     1 display = vc
     1 cdf_meaning = c12
     1 active_ind = i2
     1 field_type = i4
     1 field_value = c100
     1 cki = vc
     1 updt_dt_tm = dq8
     1 updt_id = f8
     1 updt_cnt = i4
     1 updt_applctx = i4
     1 updt_task = f8
   )
   SET dmrequest->code_set = dmreq->qual[knt].code_set
   SET dmrequest->schema_date = dmreq->qual[knt].schema_date
   SET dmrequest->cki = dmreq->qual[knt].cki
   SET dmrequest->field_name = dmreq->qual[knt].field_name
   SET dmrequest->field_value = dmreq->qual[knt].field_value
   SET dmrequest->field_type = dmreq->qual[knt].field_type
   SET dmrequest->display = dmreq->qual[knt].display
   SET dmrequest->cdf_meaning = dmreq->qual[knt].cdf_meaning
   SET dmrequest->active_ind = dmreq->qual[knt].active_ind
   SET reqinfo->updt_id = 111
   SET reqinfo->updt_applctx = 111
   EXECUTE dm_code_value_extension
   EXECUTE dm_delete_cve
 ENDFOR
 COMMIT
END GO
