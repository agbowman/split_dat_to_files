CREATE PROGRAM ap_rqp_cleanup:dba
 RECORD ap_rqp(
   1 qual[*]
     2 request_number = i4
     2 sequence = i4
 )
 SELECT INTO "nl:"
  rp.format_script
  FROM request_processing rp
  WHERE rp.request_number IN (200005, 200006, 200390)
   AND rp.format_script="PFMT_APS_PATHOLOGY_ORDER"
   AND ((rp.service != "ORM.OrderWriteSynch") OR (rp.service=null))
   AND rp.active_ind=1
  ORDER BY rp.request_number, rp.sequence
  HEAD REPORT
   qual_cnt = 0, match_cnt = 0, first_sequence = 0
  HEAD rp.request_number
   match_cnt = 0, first_sequence = rp.sequence
  DETAIL
   match_cnt = (match_cnt+ 1)
  FOOT  rp.request_number
   IF (match_cnt > 1)
    qual_cnt = (qual_cnt+ 1), stat = alterlist(ap_rqp->qual,qual_cnt), ap_rqp->qual[qual_cnt].
    request_number = rp.request_number,
    ap_rqp->qual[qual_cnt].sequence = first_sequence
   ENDIF
  WITH nocounter
 ;end select
 IF (size(ap_rqp->qual,5) > 0)
  UPDATE  FROM request_processing rp,
    (dummyt d  WITH seq = value(size(ap_rqp->qual,5)))
   SET rp.service = "ORM.OrderWriteSynch", rp.updt_cnt = (rp.updt_cnt+ 1), rp.updt_dt_tm = sysdate
   PLAN (d)
    JOIN (rp
    WHERE (ap_rqp->qual[d.seq].request_number=rp.request_number)
     AND (ap_rqp->qual[d.seq].sequence=rp.sequence))
   WITH nocounter
  ;end update
  IF (curqual > 0)
   COMMIT
  ENDIF
 ENDIF
 FREE RECORD ap_rqp
END GO
