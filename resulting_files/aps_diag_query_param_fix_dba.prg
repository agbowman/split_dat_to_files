CREATE PROGRAM aps_diag_query_param_fix:dba
 RECORD temp(
   1 qual[*]
     2 query_param_id = f8
     2 sequence = i4
 )
 SET qcnt = 0
 SELECT INTO "nl:"
  adqp.query_param_id, adqp.query_cd
  FROM ap_diag_query_param adqp
  PLAN (adqp)
  ORDER BY adqp.query_cd
  HEAD REPORT
   qcnt = 0
  HEAD adqp.query_cd
   seq_cnt = 0
  DETAIL
   seq_cnt = (seq_cnt+ 1), qcnt = (qcnt+ 1)
   IF (mod(qcnt,5)=1)
    stat = alterlist(temp->qual,(qcnt+ 4))
   ENDIF
   temp->qual[qcnt].query_param_id = adqp.query_param_id, temp->qual[qcnt].sequence = seq_cnt
  FOOT REPORT
   stat = alterlist(temp->qual,qcnt)
  WITH nocounter
 ;end select
 IF (qcnt != 0)
  UPDATE  FROM ap_diag_query_param adqp,
    (dummyt d1  WITH seq = value(qcnt))
   SET adqp.sequence = temp->qual[d1.seq].sequence
   PLAN (d1)
    JOIN (adqp
    WHERE (temp->qual[d1.seq].query_param_id=adqp.query_param_id))
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
END GO
