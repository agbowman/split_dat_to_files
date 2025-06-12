CREATE PROGRAM dcp_get_cat_ref_tasks:dba
 RECORD reply(
   1 reference_task_list[*]
     2 reference_task_id = f8
     2 task_activity_cd = f8
     2 task_type_cd = f8
     2 task_description = vc
     2 response_task_list[*]
       3 response_reference_task_id = f8
       3 response_minutes = i4
       3 response_route_cd = f8
       3 qualification_flag = i2
     2 catalog_list[*]
       3 catalog_cd = f8
     2 cernertask_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE catalog_count = i4 WITH noconstant(0)
 DECLARE reference_task_count = i4 WITH noconstant(0)
 DECLARE response_task_count = i4 WITH noconstant(0)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 SELECT INTO "nl:"
  FROM order_task ot,
   order_task_xref otx
  PLAN (ot
   WHERE ot.active_ind=1)
   JOIN (otx
   WHERE otx.reference_task_id=outerjoin(ot.reference_task_id))
  ORDER BY ot.reference_task_id
  HEAD REPORT
   catalog_count = 0, reference_task_count = 0
  HEAD ot.reference_task_id
   reference_task_count = (reference_task_count+ 1)
   IF (reference_task_count > size(reply->reference_task_list,5))
    stat = alterlist(reply->reference_task_list,(reference_task_count+ 10))
   ENDIF
   reply->reference_task_list[reference_task_count].reference_task_id = ot.reference_task_id, reply->
   reference_task_list[reference_task_count].task_activity_cd = ot.task_activity_cd, reply->
   reference_task_list[reference_task_count].task_type_cd = ot.task_type_cd,
   reply->reference_task_list[reference_task_count].task_description = ot.task_description, reply->
   reference_task_list[reference_task_count].cernertask_flag = ot.cernertask_flag, catalog_count = 0
  DETAIL
   IF (otx.catalog_cd > 0)
    catalog_count = (catalog_count+ 1)
    IF (catalog_count > size(reply->reference_task_list[reference_task_count].catalog_list,5))
     stat = alterlist(reply->reference_task_list[reference_task_count].catalog_list,(catalog_count+
      10))
    ENDIF
    reply->reference_task_list[reference_task_count].catalog_list[catalog_count].catalog_cd = otx
    .catalog_cd
   ENDIF
  FOOT  ot.reference_task_id
   stat = alterlist(reply->reference_task_list[reference_task_count].catalog_list,catalog_count)
  FOOT REPORT
   stat = alterlist(reply->reference_task_list,reference_task_count)
  WITH check
 ;end select
 IF (reference_task_count > 0)
  DECLARE idx = i4
  DECLARE ntotal = i4
  DECLARE ntotal2 = i4
  DECLARE nsize = i4 WITH constant(50)
  DECLARE nstart = i4 WITH noconstant(1)
  DECLARE num1 = i4 WITH noconstant(1)
  DECLARE index = i4 WITH noconstant(0)
  SET ntotal2 = size(reply->reference_task_list,5)
  SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
  SET stat = alterlist(reply->reference_task_list,ntotal)
  FOR (idx = (ntotal2+ 1) TO ntotal)
    SET reply->reference_task_list[idx].reference_task_id = reply->reference_task_list[ntotal2].
    reference_task_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    order_task_response otr
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
    JOIN (otr
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),otr.reference_task_id,reply->reference_task_list[
     idx].reference_task_id))
   ORDER BY otr.reference_task_id
   HEAD otr.reference_task_id
    response_task_count = 0
   DETAIL
    index = locateval(num1,1,ntotal2,otr.reference_task_id,reply->reference_task_list[num1].
     reference_task_id), response_task_count = (response_task_count+ 1)
    IF (response_task_count > size(reply->reference_task_list[index].response_task_list,5))
     stat = alterlist(reply->reference_task_list[index].response_task_list,(response_task_count+ 10))
    ENDIF
    reply->reference_task_list[index].response_task_list[response_task_count].
    response_reference_task_id = otr.response_task_id, reply->reference_task_list[index].
    response_task_list[response_task_count].response_route_cd = otr.route_cd, reply->
    reference_task_list[index].response_task_list[response_task_count].response_minutes = otr
    .response_minutes,
    reply->reference_task_list[index].response_task_list[response_task_count].qualification_flag =
    otr.qualification_flag
   FOOT  otr.reference_task_id
    stat = alterlist(reply->reference_task_list[index].response_task_list,response_task_count)
   WITH check
  ;end select
  SET stat = alterlist(reply->reference_task_list,ntotal2)
 ENDIF
 IF (error(errmsg,0))
  SET reply->status_data[1].subeventstatus.operationname = "SELECT"
  SET reply->status_data[1].subeventstatus.operationstatus = "F"
  SET reply->status_data[1].subeventstatus.targetobjectname = "ORDER_TASK"
  SET reply->status_data[1].subeventstatus.targetobjectvalue = errmsg
 ELSEIF (reference_task_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
