CREATE PROGRAM dcp_get_wv_order_info:dba
 RECORD reply(
   1 qual[*]
     2 synonym_id = f8
     2 event_cd = f8
     2 ingredient_rate_conversion_ind = i2
     2 witness_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE counter = i4 WITH noconstant(0)
 DECLARE nbr_to_get = i4 WITH constant(cnvtint(size(request->synonym_id_list,5)))
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4
 DECLARE num = i4 WITH noconstant(0)
 SET ntotal2 = size(request->synonym_id_list,5)
 SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
 SET stat = alterlist(request->synonym_id_list,ntotal)
 SET nstart = 1
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->synonym_id_list[idx].synonym_id = request->synonym_id_list[ntotal2].synonym_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   order_catalog_synonym ocs,
   code_value_event_r cvr
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
   JOIN (ocs
   WHERE expand(num,nstart,(nstart+ (nsize - 1)),ocs.synonym_id,request->synonym_id_list[num].
    synonym_id))
   JOIN (cvr
   WHERE cvr.parent_cd=ocs.catalog_cd)
  HEAD REPORT
   counter = 0
  DETAIL
   counter = (counter+ 1)
   IF (mod(counter,10)=1)
    stat = alterlist(reply->qual,(counter+ 9))
   ENDIF
   reply->qual[counter].synonym_id = ocs.synonym_id, reply->qual[counter].event_cd = cvr.event_cd,
   reply->qual[counter].ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind,
   reply->qual[counter].witness_flag = ocs.witness_flag
  FOOT REPORT
   stat = alterlist(reply->qual,counter)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
