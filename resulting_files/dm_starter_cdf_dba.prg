CREATE PROGRAM dm_starter_cdf:dba
 FREE SET dmreq
 RECORD dmreq(
   1 qual[*]
     2 code_set = i4
     2 cdf_meaning = c12
     2 display = c40
     2 definition = vc
     2 updt_applctx = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_cnt = i4
     2 updt_task = i4
   1 cnt = i4
 )
 SET dmreq->cnt = 0
 SET stat = alterlist(dmreq->qual,10)
 SELECT INTO "nl:"
  dcv.code_set, dcv.cdf_meaning, dcv.display,
  dcv.definition, dcv.updt_applctx, dcv.updt_dt_tm,
  dcv.updt_id, dcv.updt_cnt, dcv.updt_task
  FROM dm_adm_common_data_foundation dcv
  WHERE datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
   AND (dcv.code_set=list->qual[cnt].code_set)
   AND dcv.delete_ind=0
  DETAIL
   dmreq->cnt = (dmreq->cnt+ 1), stat = alterlist(dmreq->qual,(dmreq->cnt+ 1)), dmreq->qual[dmreq->
   cnt].code_set = dcv.code_set,
   dmreq->qual[dmreq->cnt].display = dcv.display, dmreq->qual[dmreq->cnt].cdf_meaning = dcv
   .cdf_meaning, dmreq->qual[dmreq->cnt].definition = dcv.definition,
   dmreq->qual[dmreq->cnt].updt_applctx = dcv.updt_applctx, dmreq->qual[dmreq->cnt].updt_dt_tm = dcv
   .updt_dt_tm, dmreq->qual[dmreq->cnt].updt_id = dcv.updt_id,
   dmreq->qual[dmreq->cnt].updt_cnt = dcv.updt_cnt, dmreq->qual[dmreq->cnt].updt_task = dcv.updt_task
  WITH nocounter
 ;end select
 SET knt = 0
 FOR (knt = 1 TO dmreq->cnt)
   FREE SET dmrequest
   RECORD dmrequest(
     1 code_set = i4
     1 cdf_meaning = c12
     1 display = c40
     1 definition = vc
     1 updt_applctx = i4
     1 updt_dt_tm = dq8
     1 updt_id = f8
     1 updt_cnt = i4
     1 updt_task = i4
   )
   SET dmrequest->code_set = dmreq->qual[knt].code_set
   SET dmrequest->display = dmreq->qual[knt].display
   SET dmrequest->cdf_meaning = dmreq->qual[knt].cdf_meaning
   SET dmrequest->definition = dmreq->qual[knt].definition
   SET dmrequest->updt_applctx = dmreq->qual[knt].updt_applctx
   SET dmrequest->updt_dt_tm = dmreq->qual[knt].updt_dt_tm
   SET dmrequest->updt_id = dmreq->qual[knt].updt_id
   SET dmrequest->updt_cnt = dmreq->qual[knt].updt_cnt
   SET dmrequest->updt_task = dmreq->qual[knt].updt_task
   SET reqinfo->updt_id = 111
   SET reqinfo->updt_applctx = 111
   EXECUTE dm_common_data_foundation
 ENDFOR
 DELETE  FROM common_data_foundation cdf
  WHERE (cdf.code_set=list->qual[cnt].code_set)
   AND (cdf.cdf_meaning=
  (SELECT
   c.cdf_meaning
   FROM dm_adm_common_data_foundation c
   WHERE (c.code_set=list->qual[cnt].code_set)
    AND c.schema_date=cnvtdatetime(r1->rdate)
    AND c.delete_ind=1))
  WITH nocounter
 ;end delete
 COMMIT
END GO
