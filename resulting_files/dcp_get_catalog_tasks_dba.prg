CREATE PROGRAM dcp_get_catalog_tasks:dba
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE count2 = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH noconstant(50)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE num1 = i4 WITH noconstant(0)
 SET ntotal2 = size(request->catalog_list,5)
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(request->catalog_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->catalog_list[idx].catalog_cd = request->catalog_list[ntotal2].catalog_cd
 ENDFOR
 SELECT INTO "nl:"
  otx.catalog_cd, otx.reference_task_id
  FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   order_task_xref otx,
   order_task ot
  PLAN (d
   WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
   JOIN (otx
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),otx.catalog_cd,request->catalog_list[idx].catalog_cd
    ))
   JOIN (ot
   WHERE ot.reference_task_id=otx.reference_task_id
    AND ot.active_ind=1)
  ORDER BY otx.catalog_cd, otx.reference_task_id
  HEAD REPORT
   count1 = 0
  HEAD otx.catalog_cd
   count2 = 0, count1 += 1
   IF (count1 > size(reply->get_list,5))
    stat = alterlist(reply->get_list,(count1+ 10))
   ENDIF
   reply->get_list[count1].catalog_cd = otx.catalog_cd
  HEAD otx.reference_task_id
   count2 += 1
   IF (count2 > size(reply->get_list[count1].ref_list,5))
    stat = alterlist(reply->get_list[count1].ref_list,(count2+ 10))
   ENDIF
   reply->get_list[count1].ref_list[count2].reference_task_id = otx.reference_task_id
  FOOT  otx.reference_task_id
   col + 0
  FOOT  otx.catalog_cd
   stat = alterlist(reply->get_list[count1].ref_list,count2)
  FOOT REPORT
   stat = alterlist(reply->get_list,count1)
  WITH check
 ;end select
 SET stat = alterlist(request->catalog_list,ntotal2)
 SET reply->status_data.status = "S"
END GO
