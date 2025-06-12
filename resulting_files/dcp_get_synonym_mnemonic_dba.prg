CREATE PROGRAM dcp_get_synonym_mnemonic:dba
 RECORD reply(
   1 qual[*]
     2 synonym_id = f8
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE qual_cnt = i4 WITH constant(cnvtint(size(request->qual,5)))
 DECLARE counter = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4
 DECLARE num = i4 WITH noconstant(0)
 SET ntotal2 = size(request->qual,5)
 SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
 SET stat = alterlist(request->qual,ntotal)
 SET nstart = 1
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->qual[idx].synonym_id = request->qual[ntotal2].synonym_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   order_catalog_synonym ocs
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
   JOIN (ocs
   WHERE expand(num,nstart,(nstart+ (nsize - 1)),ocs.synonym_id,request->qual[num].synonym_id))
  HEAD REPORT
   counter = 0
  DETAIL
   counter = (counter+ 1)
   IF (mod(counter,10)=1)
    stat = alterlist(reply->qual,(counter+ 9))
   ENDIF
   reply->qual[counter].synonym_id = ocs.synonym_id, reply->qual[counter].mnemonic = ocs.mnemonic
  FOOT REPORT
   stat = alterlist(reply->qual,counter)
  WITH nocounter
 ;end select
 IF (counter=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
