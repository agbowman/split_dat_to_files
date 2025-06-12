CREATE PROGRAM bed_get_pharm_check_used_ndc:dba
 FREE SET reply
 RECORD reply(
   1 mill[*]
     2 ndc = vc
     2 already_used_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET mcnt = 0
 SET mcnt = size(request->mill,5)
 SET stat = alterlist(reply->mill,mcnt)
 FOR (m = 1 TO mcnt)
   SET reply->mill[m].ndc = request->mill[m].ndc
 ENDFOR
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = mcnt),
   br_pharm_product_work b
  PLAN (d)
   JOIN (b
   WHERE b.match_ind=1
    AND (b.match_ndc=request->mill[d.seq].ndc)
    AND b.match_option IN (1, 4, 5))
  DETAIL
   reply->mill[d.seq].already_used_ind = 1
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
