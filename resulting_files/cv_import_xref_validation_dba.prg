CREATE PROGRAM cv_import_xref_validation:dba
 FREE RECORD requestcv
 RECORD requestcv(
   1 xv_rec[*]
     2 xref_validation_id = f8
     2 xref_id = f8
     2 response_id = f8
     2 child_xref_id = f8
     2 child_response_id = f8
     2 rltnship_flag = i2
     2 reqd_flag = i2
     2 transaction = i2
     2 offset_nbr = f8
 )
 IF (validate(cv_trns_del)=0)
  DECLARE cv_trns_add = i2 WITH protect, constant(1)
  DECLARE cv_trns_chg = i2 WITH protect, constant(2)
  DECLARE cv_trns_del = i2 WITH protect, constant(3)
 ENDIF
 DECLARE cur_list_size = i4 WITH protect
 DECLARE loop_cnt = i4 WITH protect
 DECLARE new_list_size = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE nstart = i4 WITH protect
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE xref_valid_cnt = i4 WITH protect
 SET stat = alterlist(requestcv->xv_rec,size(requestin->list_0,5))
 SET cur_list_size = size(requestin->list_0,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(requestin->list_0,new_list_size)
 SET nstart = 1
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET requestin->list_0[idx].xref_internal_name = requestin->list_0[cur_list_size].
   xref_internal_name
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   cv_xref cx
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cx
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cx.xref_internal_name,requestin->list_0[idx].
    xref_internal_name))
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cx.xref_internal_name,requestin->list_0[num1].
    xref_internal_name)
   WHILE (index != 0)
     requestcv->xv_rec[index].xref_id = cx.xref_id, requestcv->xv_rec[index].rltnship_flag = cnvtint(
      requestin->list_0[index].rltnship_flag), requestcv->xv_rec[index].reqd_flag = cnvtint(requestin
      ->list_0[index].reqd_flag),
     requestcv->xv_rec[index].offset_nbr = cnvtreal(requestin->list_0[index].offset_nbr), requestcv->
     xv_rec[index].transaction = cv_trns_add, index = locateval(num1,(index+ 1),cur_list_size,cx
      .xref_internal_name,requestin->list_0[num1].xref_internal_name)
   ENDWHILE
  WITH nocounter
 ;end select
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   cv_xref cx
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cx
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cx.xref_internal_name,requestin->list_0[idx].
    child_xref_internal_name))
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cx.xref_internal_name,requestin->list_0[num1].
    child_xref_internal_name)
   WHILE (index != 0)
    requestcv->xv_rec[index].child_xref_id = cx.xref_id,index = locateval(num1,(index+ 1),
     cur_list_size,cx.xref_internal_name,requestin->list_0[num1].child_xref_internal_name)
   ENDWHILE
  WITH nocounter
 ;end select
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   cv_response cr
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cr
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cr.response_internal_name,requestin->list_0[idx
    ].response_internal_name))
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cr.response_internal_name,requestin->list_0[num1].
    response_internal_name)
   WHILE (index != 0)
    requestcv->xv_rec[index].response_id = cr.response_id,index = locateval(num1,(index+ 1),
     cur_list_size,cr.response_internal_name,requestin->list_0[num1].response_internal_name)
   ENDWHILE
  WITH nocounter
 ;end select
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   cv_response cr
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cr
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cr.response_internal_name,requestin->list_0[idx
    ].child_response_internal_name))
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cr.response_internal_name,requestin->list_0[num1].
    child_response_internal_name)
   WHILE (index != 0)
    requestcv->xv_rec[index].child_response_id = cr.response_id,index = locateval(num1,(index+ 1),
     cur_list_size,cr.response_internal_name,requestin->list_0[num1].child_response_internal_name)
   ENDWHILE
  WITH nocounter
 ;end select
 SET stat = alterlist(requestin->list_0,cur_list_size)
 SELECT INTO "nl:"
  FROM cv_xref_validation t,
   (dummyt d1  WITH seq = value(size(requestcv->xv_rec,5)))
  PLAN (d1)
   JOIN (t
   WHERE (t.xref_id=requestcv->xv_rec[d1.seq].xref_id)
    AND (t.response_id=requestcv->xv_rec[d1.seq].response_id)
    AND (t.child_response_id=requestcv->xv_rec[d1.seq].child_response_id)
    AND (t.child_xref_id=requestcv->xv_rec[d1.seq].child_xref_id))
  HEAD REPORT
   xref_valid_cnt = 0
  DETAIL
   xref_valid_cnt = (xref_valid_cnt+ 1), requestcv->xv_rec[d1.seq].xref_validation_id = t
   .xref_validation_id, requestcv->xv_rec[d1.seq].transaction = cv_trns_chg
  WITH nocounter
 ;end select
 EXECUTE cv_add_fld_xref_validation  WITH replace(request,requestcv)
 EXECUTE cv_chg_fld_xref_validation  WITH replace(request,requestcv)
 DECLARE cv_import_xref_validate_vrsn = vc WITH private, constant("MOD 003 BM9013 07/19/2006")
END GO
