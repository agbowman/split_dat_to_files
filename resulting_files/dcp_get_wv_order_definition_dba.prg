CREATE PROGRAM dcp_get_wv_order_definition:dba
 RECORD reply(
   1 reference_list[*]
     2 catalog_cd = f8
     2 reference_task_id = f8
     2 event_code_list[*]
       3 event_cd = f8
       3 task_assay_cd = f8
       3 required_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_b(
   1 qual[*]
     2 reference_id = f8
     2 catalog_code = f8
     2 catalog_type = f8
 )
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4
 SET reply->status_data.status = "F"
 DECLARE count1 = i2 WITH noconstant(0)
 DECLARE count2 = i2 WITH noconstant(0)
 DECLARE num = i2 WITH noconstant(0)
 DECLARE list_size = i2 WITH constant(cnvtint(size(request->qual,5)))
 DECLARE pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE lab_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
 DECLARE rad_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"RADIOLOGY"))
 SET count = 0
 SET stat = alterlist(temp_b->qual,list_size)
 FOR (idx = 1 TO value(size(request->qual,5)))
   IF ((request->qual[idx].reference_task_id > 0))
    SET count = (count+ 1)
    SET temp_b->qual[count].reference_id = request->qual[idx].reference_task_id
    SET temp_b->qual[count].catalog_code = request->qual[idx].catalog_cd
    SET temp_b->qual[count].catalog_type = request->qual[idx].catalog_type_cd
   ENDIF
 ENDFOR
 SET stat = alterlist(temp_b->qual,count)
 IF (value(size(temp_b->qual,5)) > 0)
  SET ntotal2 = size(temp_b->qual,5)
  SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
  SET stat = alterlist(temp_b->qual,ntotal)
  SET nstart = 1
  FOR (idx = (ntotal2+ 1) TO ntotal)
    SET temp_b->qual[idx].reference_id = temp_b->qual[ntotal2].reference_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    task_discrete_r tdr,
    discrete_task_assay dta,
    order_task_xref otx
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
    JOIN (tdr
    WHERE expand(num,nstart,(nstart+ (nsize - 1)),tdr.reference_task_id,temp_b->qual[num].
     reference_id))
    JOIN (dta
    WHERE tdr.task_assay_cd=dta.task_assay_cd)
    JOIN (otx
    WHERE otx.reference_task_id=tdr.reference_task_id)
   ORDER BY otx.catalog_cd, dta.event_cd
   HEAD REPORT
    count1 = 0
   HEAD otx.catalog_cd
    count2 = 0, count1 = (count1+ 1)
    IF (mod(count1,10)=1)
     stat = alterlist(reply->reference_list,(count1+ 9))
    ENDIF
    reply->reference_list[count1].catalog_cd = otx.catalog_cd, reply->reference_list[count1].
    reference_task_id = otx.reference_task_id
   HEAD dta.event_cd
    count2 = (count2+ 1)
    IF (mod(count2,10)=1)
     stat = alterlist(reply->reference_list[count1].event_code_list,(count2+ 9))
    ENDIF
    reply->reference_list[count1].event_code_list[count2].event_cd = dta.event_cd, reply->
    reference_list[count1].event_code_list[count2].task_assay_cd = dta.task_assay_cd, reply->
    reference_list[count1].event_code_list[count2].required_ind = tdr.required_ind
   FOOT  otx.catalog_cd
    stat = alterlist(reply->reference_list[count1].event_code_list,count2)
   FOOT REPORT
    stat = alterlist(reply->reference_list,count1)
   WITH nocounter
  ;end select
 ENDIF
 IF (initrec(temp_b) != 1)
  CALL echo("Could not clear record structure!")
  RETURN
 ENDIF
 SET count = 0
 SET stat = alterlist(temp_b->qual,list_size)
 FOR (idx = 1 TO value(size(request->qual,5)))
   IF ((request->qual[idx].reference_task_id=0)
    AND (request->qual[idx].catalog_cd > 0)
    AND (request->qual[idx].catalog_type_cd=pharmacy_cd))
    SET count = (count+ 1)
    SET temp_b->qual[count].reference_id = request->qual[idx].reference_task_id
    SET temp_b->qual[count].catalog_code = request->qual[idx].catalog_cd
    SET temp_b->qual[count].catalog_type = request->qual[idx].catalog_type_cd
   ENDIF
 ENDFOR
 SET stat = alterlist(temp_b->qual,count)
 IF (value(size(temp_b->qual,5)) > 0)
  SET ntotal2 = size(temp_b->qual,5)
  SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
  SET stat = alterlist(temp_b->qual,ntotal)
  SET nstart = 1
  FOR (idx = (ntotal2+ 1) TO ntotal)
    SET temp_b->qual[idx].catalog_code = temp_b->qual[ntotal2].catalog_code
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    code_value_event_r cver
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
    JOIN (cver
    WHERE expand(num,nstart,(nstart+ (nsize - 1)),cver.parent_cd,temp_b->qual[num].catalog_code))
   ORDER BY cver.parent_cd
   HEAD REPORT
    count2 = 0
   HEAD cver.parent_cd
    count2 = 0, count1 = (count1+ 1)
    IF (mod(count1,10)=1)
     stat = alterlist(reply->reference_list,(count1+ 9))
    ENDIF
    reply->reference_list[count1].catalog_cd = cver.parent_cd
   DETAIL
    count2 = (count2+ 1)
    IF (mod(count2,10)=1)
     stat = alterlist(reply->reference_list[count1].event_code_list,(count2+ 9))
    ENDIF
    reply->reference_list[count1].event_code_list[count2].event_cd = cver.event_cd
   FOOT  cver.parent_cd
    IF (count2 > 0)
     stat = alterlist(reply->reference_list[count1].event_code_list,count2)
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->reference_list,count1)
   WITH nocounter
  ;end select
 ENDIF
 IF (initrec(temp_b) != 1)
  CALL echo("Could not clear record structure!")
  RETURN
 ENDIF
 SET count = 0
 SET stat = alterlist(temp_b->qual,list_size)
 FOR (idx = 1 TO value(size(request->qual,5)))
   IF ((request->qual[idx].reference_task_id=0)
    AND (request->qual[idx].catalog_cd > 0)
    AND (request->qual[idx].catalog_type_cd IN (lab_cd, rad_cd)))
    SET count = (count+ 1)
    SET temp_b->qual[count].reference_id = request->qual[idx].reference_task_id
    SET temp_b->qual[count].catalog_code = request->qual[idx].catalog_cd
    SET temp_b->qual[count].catalog_type = request->qual[idx].catalog_type_cd
   ENDIF
 ENDFOR
 SET stat = alterlist(temp_b->qual,count)
 IF (value(size(temp_b->qual,5)) > 0)
  SET ntotal2 = size(temp_b->qual,5)
  SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
  SET stat = alterlist(temp_b->qual,ntotal)
  SET nstart = 1
  FOR (idx = (ntotal2+ 1) TO ntotal)
    SET temp_b->qual[idx].catalog_code = temp_b->qual[ntotal2].catalog_code
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    profile_task_r ptr,
    code_value_event_r cver
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
    JOIN (ptr
    WHERE expand(num,nstart,(nstart+ (nsize - 1)),ptr.catalog_cd,temp_b->qual[num].catalog_code))
    JOIN (cver
    WHERE ptr.task_assay_cd=cver.parent_cd)
   ORDER BY ptr.reference_task_id, cver.parent_cd
   HEAD REPORT
    count2 = 0
   HEAD ptr.reference_task_id
    count2 = 0, count1 = (count1+ 1)
    IF (mod(count1,10)=1)
     stat = alterlist(reply->reference_list,(count1+ 9))
    ENDIF
    reply->reference_list[count1].catalog_cd = ptr.catalog_cd, reply->reference_list[count1].
    reference_task_id = ptr.reference_task_id
   HEAD cver.parent_cd
    count2 = (count2+ 1)
    IF (mod(count2,10)=1)
     stat = alterlist(reply->reference_list[count1].event_code_list,(count2+ 9))
    ENDIF
    reply->reference_list[count1].event_code_list[count2].event_cd = cver.event_cd, reply->
    reference_list[count1].event_code_list[count2].task_assay_cd = cver.parent_cd
   FOOT  ptr.reference_task_id
    IF (count2 > 0)
     stat = alterlist(reply->reference_list[count1].event_code_list,count2)
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->reference_list,count1)
   WITH nocounter
  ;end select
 ENDIF
 IF (initrec(temp_b) != 1)
  CALL echo("Could not clear record structure!")
  RETURN
 ENDIF
 SET count = 0
 SET stat = alterlist(temp_b->qual,list_size)
 FOR (idx = 1 TO value(size(request->qual,5)))
   IF ((request->qual[idx].reference_task_id=0)
    AND (request->qual[idx].catalog_cd > 0)
    AND  NOT ((request->qual[idx].catalog_type_cd IN (pharmacy_cd, lab_cd, rad_cd))))
    SET count = (count+ 1)
    SET temp_b->qual[count].reference_id = request->qual[idx].reference_task_id
    SET temp_b->qual[count].catalog_code = request->qual[idx].catalog_cd
    SET temp_b->qual[count].catalog_type = request->qual[idx].catalog_type_cd
   ENDIF
 ENDFOR
 SET stat = alterlist(temp_b->qual,count)
 CALL echorecord(temp_b)
 IF (value(size(temp_b->qual,5)) > 0)
  SET ntotal2 = size(temp_b->qual,5)
  SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
  SET stat = alterlist(temp_b->qual,ntotal)
  SET nstart = 1
  FOR (idx = (ntotal2+ 1) TO ntotal)
    SET temp_b->qual[idx].catalog_code = temp_b->qual[ntotal2].catalog_code
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    order_task_xref otx,
    task_discrete_r tdr,
    discrete_task_assay dta
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
    JOIN (otx
    WHERE expand(num,nstart,(nstart+ (nsize - 1)),otx.catalog_cd,temp_b->qual[num].catalog_code))
    JOIN (tdr
    WHERE otx.reference_task_id=tdr.reference_task_id)
    JOIN (dta
    WHERE tdr.task_assay_cd=dta.task_assay_cd)
   ORDER BY otx.reference_task_id, dta.event_cd
   HEAD REPORT
    count2 = 0
   HEAD otx.reference_task_id
    count2 = 0, count1 = (count1+ 1)
    IF (mod(count1,10)=1)
     stat = alterlist(reply->reference_list,(count1+ 9))
    ENDIF
    reply->reference_list[count1].catalog_cd = otx.catalog_cd, reply->reference_list[count1].
    reference_task_id = otx.reference_task_id
   HEAD dta.event_cd
    count2 = (count2+ 1)
    IF (mod(count2,10)=1)
     stat = alterlist(reply->reference_list[count1].event_code_list,(count2+ 9))
    ENDIF
    reply->reference_list[count1].event_code_list[count2].event_cd = dta.event_cd, reply->
    reference_list[count1].event_code_list[count2].task_assay_cd = dta.task_assay_cd, reply->
    reference_list[count1].event_code_list[count2].required_ind = tdr.required_ind
   FOOT  otx.reference_task_id
    IF (count2 > 0)
     stat = alterlist(reply->reference_list[count1].event_code_list,count2)
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->reference_list,count1)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
