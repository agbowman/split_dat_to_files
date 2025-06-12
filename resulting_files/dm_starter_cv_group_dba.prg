CREATE PROGRAM dm_starter_cv_group:dba
 CALL echo("start dm_starter_cv_group")
 FREE RECORD dmreq
 RECORD dmreq(
   1 cnt = i4
   1 qual[*]
     2 code_set = f8
     2 schema_date = dq8
     2 parent_code_value = f8
     2 child_code_value = f8
     2 collation_seq = i4
     2 child_code_set = f8
     2 p_cki = vc
     2 c_cki = vc
     2 delete_ind = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_cnt = i4
     2 updt_applctx = i4
     2 updt_task = f8
 )
 SET dmreq->cnt = 0
 SET stat = alterlist(dmreq->qual,10)
 SELECT INTO "nl:"
  dcg.code_set, dcg.schema_date, dcg.parent_code_value,
  dcg.child_code_value, dcg.collation_seq, dcg.child_code_set,
  dcg.updt_id, dcg.updt_cnt, dcg.updt_task,
  dcg.updt_dt_tm, dcg.updt_applctx, dc.cki
  FROM dm_adm_code_value_group dcg,
   dm_adm_code_value dc
  WHERE datetimediff(dcg.schema_date,cnvtdatetime(r1->rdate))=0
   AND (dcg.code_set=list->qual[cnt].code_set)
   AND dc.code_value=dcg.parent_code_value
   AND dcg.schema_date=dc.schema_date
  DETAIL
   dmreq->cnt = (dmreq->cnt+ 1), stat = alterlist(dmreq->qual,(dmreq->cnt+ 1)), dmreq->qual[dmreq->
   cnt].code_set = dcg.code_set,
   dmreq->qual[dmreq->cnt].schema_date = cnvtdatetime(dcg.schema_date), dmreq->qual[dmreq->cnt].
   parent_code_value = dcg.parent_code_value, dmreq->qual[dmreq->cnt].child_code_value = dcg
   .child_code_value,
   dmreq->qual[dmreq->cnt].collation_seq = dcg.collation_seq, dmreq->qual[dmreq->cnt].child_code_set
    = dcg.child_code_set, dmreq->qual[dmreq->cnt].delete_ind = dcg.delete_ind,
   dmreq->qual[dmreq->cnt].p_cki = dc.cki
  WITH nocounter
 ;end select
 IF ((dmreq->cnt > 0))
  SELECT INTO "nl:"
   dc.cki
   FROM dm_adm_code_value dc,
    (dummyt d  WITH seq = value(dmreq->cnt))
   PLAN (d)
    JOIN (dc
    WHERE (dc.code_set=dmreq->qual[d.seq].child_code_set)
     AND (dc.code_value=dmreq->qual[d.seq].child_code_value))
   ORDER BY dc.schema_date
   DETAIL
    dmreq->qual[d.seq].c_cki = dc.cki
   WITH nocounter
  ;end select
 ENDIF
 SET knt = 0
 FOR (knt = 1 TO dmreq->cnt)
   FREE SET dmrequest
   RECORD dmrequest(
     1 code_set = f8
     1 schema_date = dq8
     1 parent_code_value = f8
     1 child_code_value = f8
     1 collation_seq = i4
     1 child_code_set = f8
     1 p_cki = vc
     1 c_cki = vc
     1 delete_ind = i2
     1 updt_dt_tm = dq8
     1 updt_id = f8
     1 updt_cnt = i4
     1 updt_applctx = i4
     1 updt_task = f8
   )
   SET dmrequest->code_set = dmreq->qual[knt].code_set
   SET dmrequest->schema_date = dmreq->qual[knt].schema_date
   SET dmrequest->parent_code_value = dmreq->qual[knt].parent_code_value
   SET dmrequest->child_code_value = dmreq->qual[knt].child_code_value
   SET dmrequest->collation_seq = dmreq->qual[knt].collation_seq
   SET dmrequest->child_code_set = dmreq->qual[knt].child_code_set
   SET dmrequest->delete_ind = dmreq->qual[knt].delete_ind
   SET dmrequest->p_cki = dmreq->qual[knt].p_cki
   SET dmrequest->c_cki = dmreq->qual[knt].c_cki
   SET reqinfo->updt_id = 111
   SET reqinfo->updt_applctx = 111
   EXECUTE dm_code_value_group
   EXECUTE dm_delete_cvg
   CALL echo(build("reply =",cs_reply->cs_fail))
   IF ((cs_reply->cs_fail=1))
    SET knt = (dmreq->cnt+ 1)
    CALL echo("*********************************************")
    CALL echo(cs_reply->cs_fail_msg)
    CALL echo("*********************************************")
    ROLLBACK
    GO TO exit_program
   ENDIF
   COMMIT
 ENDFOR
#exit_program
END GO
