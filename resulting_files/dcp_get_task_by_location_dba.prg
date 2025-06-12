CREATE PROGRAM dcp_get_task_by_location:dba
 RECORD reply(
   1 location_list[*]
     2 workload_units = f8
     2 loc_unit_cd = f8
     2 task_list[*]
       3 task_id = f8
       3 reference_task_id = f8
       3 catalog_cd = f8
       3 allpositionchart_ind = i2
       3 task_status_cd = f8
       3 task_class_cd = f8
       3 workload_units = f8
       3 multiplier = i4
       3 position_list[*]
         4 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE tsk_inprocess = f8 WITH constant(uar_get_code_by("MEANING",79,"INPROCESS"))
 DECLARE tsk_overdue = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE tsk_pending = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE prn_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"PRN"))
 DECLARE cont_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"CONT"))
 DECLARE workload_cd = f8 WITH constant(uar_get_code_by("MEANING",13019,"WORKLOAD"))
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE task_cnt = i4 WITH noconstant(0)
 DECLARE position_cnt = i4 WITH noconstant(0)
 DECLARE workload = i4 WITH noconstant(0)
 DECLARE loc_cnt = i4 WITH noconstant(size(request->location_list,5))
 SET stat = alterlist(reply->location_list,loc_cnt)
 SET reply->status_data.status = "F"
 IF ((request->prn_cont_workload_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loc_cnt)),
    task_activity ta,
    order_task ot,
    bill_item bi,
    bill_item_modifier bim,
    workload_code wl,
    order_task_position_xref otpx
   PLAN (d)
    JOIN (ta
    WHERE (ta.location_cd=request->location_list[d.seq].loc_unit_cd)
     AND ((ta.task_status_cd IN (tsk_inprocess, tsk_overdue, tsk_pending)
     AND ta.task_dt_tm >= cnvtdatetime(request->beg_effective_dt_tm)
     AND ta.task_dt_tm < cnvtdatetime(request->end_effective_dt_tm)) OR (ta.task_class_cd IN (cont_cd,
    prn_cd)
     AND ta.task_status_cd IN (tsk_inprocess, tsk_pending)
     AND ta.task_dt_tm < cnvtdatetime(request->end_effective_dt_tm))) )
    JOIN (ot
    WHERE ot.reference_task_id=ta.reference_task_id)
    JOIN (bi
    WHERE bi.ext_parent_reference_id=ta.catalog_cd
     AND bi.ext_child_reference_id=ot.reference_task_id
     AND bi.active_ind=1)
    JOIN (bim
    WHERE bim.bill_item_id=bi.bill_item_id
     AND bim.active_ind=1
     AND bim.bill_item_type_cd=workload_cd)
    JOIN (wl
    WHERE outerjoin(bim.key3_id)=wl.workload_code_id
     AND outerjoin(1)=wl.active_ind)
    JOIN (otpx
    WHERE outerjoin(ta.reference_task_id)=otpx.reference_task_id)
   ORDER BY d.seq, ta.task_id
   HEAD d.seq
    task_cnt = 0, workload = 0, reply->location_list[d.seq].loc_unit_cd = request->location_list[d
    .seq].loc_unit_cd
   HEAD ta.task_id
    position_cnt = 0, task_cnt = (task_cnt+ 1)
    IF (mod(task_cnt,10)=1)
     stat = alterlist(reply->location_list[d.seq].task_list,(task_cnt+ 9))
    ENDIF
    reply->location_list[d.seq].task_list[task_cnt].task_id = ta.task_id, reply->location_list[d.seq]
    .task_list[task_cnt].reference_task_id = ta.reference_task_id, reply->location_list[d.seq].
    task_list[task_cnt].catalog_cd = ta.catalog_cd,
    reply->location_list[d.seq].task_list[task_cnt].allpositionchart_ind = ot.allpositionchart_ind,
    reply->location_list[d.seq].task_list[task_cnt].task_status_cd = ta.task_status_cd, reply->
    location_list[d.seq].task_list[task_cnt].task_class_cd = ta.task_class_cd
    IF ((bim.bim1_int=- (1)))
     reply->location_list[d.seq].task_list[task_cnt].multiplier = 1
    ENDIF
    IF (bim.key3_id=0)
     reply->location_list[d.seq].task_list[task_cnt].workload_units = bim.bim1_nbr
    ELSE
     reply->location_list[d.seq].task_list[task_cnt].workload_units = wl.units
    ENDIF
    IF ((bim.bim2_int=- (1)))
     reply->location_list[d.seq].task_list[task_cnt].multiplier = wl.multiplier
    ENDIF
    workload = (workload+ reply->location_list[d.seq].task_list[task_cnt].workload_units)
   DETAIL
    position_cnt = (position_cnt+ 1)
    IF (mod(position_cnt,10)=1)
     stat = alterlist(reply->location_list[d.seq].task_list[task_cnt].position_list,(position_cnt+ 9)
      )
    ENDIF
    reply->location_list[d.seq].task_list[task_cnt].position_list[position_cnt].position_cd = otpx
    .position_cd
   FOOT  ta.task_id
    IF (task_cnt > 0)
     stat = alterlist(reply->location_list[d.seq].task_list[task_cnt].position_list,position_cnt)
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->location_list[d.seq].task_list,task_cnt), reply->location_list[d.seq].
    workload_units = workload
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loc_cnt)),
    task_activity ta,
    order_task ot,
    bill_item bi,
    bill_item_modifier bim,
    workload_code wl,
    order_task_position_xref otpx
   PLAN (d)
    JOIN (ta
    WHERE (ta.location_cd=request->location_list[d.seq].loc_unit_cd)
     AND ta.task_status_cd IN (tsk_inprocess, tsk_overdue, tsk_pending)
     AND  NOT (ta.task_class_cd IN (cont_cd, prn_cd))
     AND ta.task_dt_tm >= cnvtdatetime(request->beg_effective_dt_tm)
     AND ta.task_dt_tm < cnvtdatetime(request->end_effective_dt_tm))
    JOIN (ot
    WHERE ot.reference_task_id=ta.reference_task_id)
    JOIN (bi
    WHERE bi.ext_parent_reference_id=ta.catalog_cd
     AND bi.ext_child_reference_id=ot.reference_task_id
     AND bi.active_ind=1)
    JOIN (bim
    WHERE bim.bill_item_id=bi.bill_item_id
     AND bim.active_ind=1
     AND bim.bill_item_type_cd=workload_cd)
    JOIN (wl
    WHERE outerjoin(bim.key3_id)=wl.workload_code_id
     AND outerjoin(1)=wl.active_ind)
    JOIN (otpx
    WHERE outerjoin(ta.reference_task_id)=otpx.reference_task_id)
   ORDER BY d.seq, ta.task_id
   HEAD d.seq
    task_cnt = 0, workload = 0, reply->location_list[d.seq].loc_unit_cd = request->location_list[d
    .seq].loc_unit_cd
   HEAD ta.task_id
    position_cnt = 0, task_cnt = (task_cnt+ 1)
    IF (mod(task_cnt,10)=1)
     stat = alterlist(reply->location_list[d.seq].task_list,(task_cnt+ 9))
    ENDIF
    reply->location_list[d.seq].task_list[task_cnt].task_id = ta.task_id, reply->location_list[d.seq]
    .task_list[task_cnt].reference_task_id = ta.reference_task_id, reply->location_list[d.seq].
    task_list[task_cnt].catalog_cd = ta.catalog_cd,
    reply->location_list[d.seq].task_list[task_cnt].allpositionchart_ind = ot.allpositionchart_ind,
    reply->location_list[d.seq].task_list[task_cnt].task_status_cd = ta.task_status_cd, reply->
    location_list[d.seq].task_list[task_cnt].task_class_cd = ta.task_class_cd
    IF ((bim.bim1_int=- (1)))
     reply->location_list[d.seq].task_list[task_cnt].multiplier = 1
    ENDIF
    IF (bim.key3_id=0)
     reply->location_list[d.seq].task_list[task_cnt].workload_units = bim.bim1_nbr
    ELSE
     reply->location_list[d.seq].task_list[task_cnt].workload_units = wl.units
    ENDIF
    IF ((bim.bim2_int=- (1)))
     reply->location_list[d.seq].task_list[task_cnt].multiplier = wl.multiplier
    ENDIF
    workload = (workload+ reply->location_list[d.seq].task_list[task_cnt].workload_units)
   DETAIL
    position_cnt = (position_cnt+ 1)
    IF (mod(position_cnt,10)=1)
     stat = alterlist(reply->location_list[d.seq].task_list[task_cnt].position_list,(position_cnt+ 9)
      )
    ENDIF
    reply->location_list[d.seq].task_list[task_cnt].position_list[position_cnt].position_cd = otpx
    .position_cd
   FOOT  ta.task_id
    IF (task_cnt > 0)
     stat = alterlist(reply->location_list[d.seq].task_list[task_cnt].position_list,position_cnt)
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->location_list[d.seq].task_list,task_cnt), reply->location_list[d.seq].
    workload_units = workload
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
