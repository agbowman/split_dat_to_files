CREATE PROGRAM dcp_p_get_task_attribs:dba
 DECLARE program_version = vc WITH private, constant("018")
 SET curnamespace = "BitField"
 DECLARE min_index = i4 WITH protect, constant(1)
 DECLARE max_index = i4 WITH protect, constant(31)
 DECLARE out_of_bounds_error = i4 WITH protect, constant(1)
 DECLARE validateindex(bitindex=i4) = null
 SUBROUTINE validateindex(bitindex)
   IF ((((bitindex < BITFIELD::min_index)) OR ((bitindex > BITFIELD::max_index))) )
    CALL cclexception(BITFIELD::out_of_bounds_error,"E",build("The given bitIndex (",bitindex,
      ") is not within the range 1 < bitIndex < 31"))
   ENDIF
 END ;Subroutine
 DECLARE calculatemask(bitindex=i4) = i4
 SUBROUTINE calculatemask(bitindex)
  CALL BITFIELD::validateindex(bitindex)
  RETURN((2** (bitindex - 1)))
 END ;Subroutine
 DECLARE isbitset(bitfield=i4(ref),bitindex=i4) = i2
 SUBROUTINE isbitset(bitfield,bitindex)
  CALL BITFIELD::validateindex(bitindex)
  RETURN(btest(bitfield,(bitindex - 1)))
 END ;Subroutine
 DECLARE setbit(bitfield=i4(ref),bitindex=i4) = null
 SUBROUTINE setbit(bitfield,bitindex)
  CALL BITFIELD::validateindex(bitindex)
  SET bitfield = bor(bitfield,BITFIELD::calculatemask(bitindex))
 END ;Subroutine
 DECLARE unsetbit(bitfield=i4(ref),bitindex=i4) = null
 SUBROUTINE unsetbit(bitfield,bitindex)
   CALL BITFIELD::validateindex(bitindex)
   DECLARE mask = i4 WITH private, constant(bnot(BITFIELD::calculatemask(bitindex)))
   SET bitfield = band(bitfield,mask)
 END ;Subroutine
 SET curnamespace = off
 DECLARE admin_completed_bit = i4 WITH protect, constant(4)
 DECLARE admin_requires_validation_bit = i4 WITH protect, constant(5)
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->task_list,5))
 DECLARE detailordfrequency = i4 WITH protect, constant(2011)
 DECLARE detailadhocfreqinstance = i4 WITH protect, constant(2071)
 DECLARE detailnursecollect = i4 WITH protect, constant(1108)
 DECLARE cpendingvalidation = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"VALIDATION"))
 DECLARE ctaskcomplete = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE cordercomplete = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE expandindex = i4 WITH protect, noconstant(0)
 DECLARE selectindex = i4 WITH protect, noconstant(0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   ta.task_id, p.person_id
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    task_activity ta,
    prsnl p
   PLAN (d)
    JOIN (ta
    WHERE (ta.task_id=request->task_list[d.seq].task_id)
     AND ta.active_ind=1)
    JOIN (p
    WHERE p.person_id=ta.updt_id)
   ORDER BY ta.task_id
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].task_id = ta.task_id, reply->get_list[count1].reference_task_id = ta
    .reference_task_id, reply->get_list[count1].order_id = ta.order_id,
    reply->get_list[count1].catalog_cd = ta.catalog_cd, reply->get_list[count1].catalog_type_cd = ta
    .catalog_type_cd, reply->get_list[count1].task_activity_cd = ta.task_activity_cd,
    reply->get_list[count1].person_id = ta.person_id, reply->get_list[count1].encntr_id = ta
    .encntr_id, reply->get_list[count1].location_cd = ta.location_cd,
    reply->get_list[count1].updt_dt_tm = ta.updt_dt_tm, reply->get_list[count1].updt_id = ta.updt_id,
    reply->get_list[count1].task_status_cd = ta.task_status_cd,
    reply->get_list[count1].task_status_reason_cd = ta.task_status_reason_cd, reply->get_list[count1]
    .iv_ind = ta.iv_ind, reply->get_list[count1].med_order_type_cd = ta.med_order_type_cd,
    reply->get_list[count1].task_class_cd = ta.task_class_cd, reply->get_list[count1].task_dt_tm = ta
    .task_dt_tm, reply->get_list[count1].name_full_formatted = p.name_full_formatted,
    reply->get_list[count1].activity_type_cd = 0, reply->get_list[count1].action_sequence = 0, reply
    ->get_list[count1].freq_cd = 0,
    reply->get_list[count1].adhoc_inst = - (1), reply->get_list[count1].order_provider_id = 0, reply
    ->get_list[count1].task_priority_cd = ta.task_priority_cd,
    reply->get_list[count1].task_type_cd = ta.task_type_cd, reply->get_list[count1].
    performed_prsnl_id = ta.performed_prsnl_id, reply->get_list[count1].container_id = ta
    .container_id
   FOOT REPORT
    stat = alterlist(reply->get_list,count1)
   WITH check
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 DECLARE orderstatusreasonbit = i4 WITH protect, noconstant(0)
 DECLARE setreply_ordersinfo(null) = null WITH protect
 IF (count1 > 0)
  SELECT INTO "nl:"
   o.order_id, oa.order_id
   FROM (dummyt d  WITH seq = value(count1)),
    orders o,
    order_action oa,
    order_detail od
   PLAN (d)
    JOIN (o
    WHERE (reply->get_list[d.seq].order_id > 0)
     AND (o.order_id=reply->get_list[d.seq].order_id)
     AND o.active_ind=1)
    JOIN (oa
    WHERE o.order_id=oa.order_id)
    JOIN (od
    WHERE od.order_id=oa.order_id
     AND od.action_sequence=oa.action_sequence)
   ORDER BY d.seq, o.order_id, oa.action_sequence
   DETAIL
    reply->get_list[d.seq].action_sequence = oa.action_sequence, reply->get_list[d.seq].
    order_provider_id = oa.order_provider_id, reply->get_list[d.seq].activity_type_cd = o
    .activity_type_cd,
    reply->get_list[d.seq].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->get_list[d.seq].
    frequency_id = o.frequency_id, reply->get_list[d.seq].freq_type_flag = o.freq_type_flag,
    reply->get_list[d.seq].remaining_dose_cnt = o.remaining_dose_cnt, reply->get_list[d.seq].
    order_status_cd = o.order_status_cd, reply->get_list[d.seq].current_start_dt_tm = o
    .current_start_dt_tm,
    reply->get_list[d.seq].dept_status_cd = o.dept_status_cd, reply->get_list[d.seq].
    ad_hoc_order_flag = o.ad_hoc_order_flag, reply->get_list[d.seq].order_prn_ind = o.prn_ind,
    reply->get_list[d.seq].order_stop_type_cd = o.stop_type_cd,
    CALL setreply_ordersinfo(null)
    IF (od.oe_field_meaning_id=detailordfrequency)
     reply->get_list[d.seq].freq_cd = od.oe_field_value
    ENDIF
    IF (od.oe_field_meaning_id=detailadhocfreqinstance)
     reply->get_list[d.seq].adhoc_inst = od.oe_field_value
    ENDIF
    IF (od.oe_field_meaning_id=detailnursecollect)
     reply->get_list[d.seq].nurse_collect_order_ind = od.oe_field_value
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE setreply_ordersinfo(null)
   IF (validate(reply->get_list.template_order_id)=1)
    SET reply->get_list[d.seq].template_order_id = o.template_order_id
   ENDIF
   IF (validate(reply->get_list.template_order_flag)=1)
    SET reply->get_list[d.seq].template_order_flag = o.template_order_flag
   ENDIF
   IF (validate(reply->get_list.charted_as_done_ind)=1)
    IF (o.order_status_reason_bit != null)
     SET orderstatusreasonbit = o.order_status_reason_bit
     IF (((BITFIELD::isbitset(orderstatusreasonbit,admin_completed_bit)) OR (BITFIELD::isbitset(
      orderstatusreasonbit,admin_requires_validation_bit))) )
      SET reply->get_list[d.seq].charted_as_done_ind = 1
     ELSE
      SET reply->get_list[d.seq].charted_as_done_ind = 0
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SELECT INTO "nl:"
  FROM task_activity ta,
   order_container_r ocr
  PLAN (ocr
   WHERE expand(expandindex,1,size(reply->get_list,5),ocr.order_id,reply->get_list[expandindex].
    order_id)
    AND ocr.order_id > 0.0)
   JOIN (ta
   WHERE ta.container_id=ocr.container_id
    AND ((ta.order_id+ 0.0)=0.0)
    AND ta.container_id > 0.0)
  ORDER BY ocr.order_id, ta.container_id
  DETAIL
   selectindex = locateval(expandindex,1,size(reply->get_list,5),ocr.order_id,reply->get_list[
    expandindex].order_id)
   IF (selectindex > 0
    AND ta.task_status_cd IN (ctaskcomplete, cpendingvalidation))
    reply->get_list[selectindex].specimen_collect_charted_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("count=  ",count1))
 FOR (x = 1 TO count1)
   CALL echo(build("x = ",x," o_id =",reply->get_list[x].order_id," t_id =",
     reply->get_list[x].task_id))
   CALL echo(build("act_seq =",reply->get_list[x].action_sequence," ord_prov_id =",reply->get_list[x]
     .order_provider_id))
   CALL echo(build("freq_cd =",reply->get_list[x].freq_cd," adhoc_inst =",reply->get_list[x].
     adhoc_inst))
   CALL echo(build("cat_cd =",reply->get_list[x].catalog_cd,"activity_type_cd =",reply->get_list[x].
     activity_type_cd))
 ENDFOR
 DECLARE iv_med_order_type_code = f8 WITH constant(uar_get_code_by("MEANING",18309,"IV"))
 SELECT INTO "nl:"
  FROM order_iv_info oii
  PLAN (oii
   WHERE expand(expandindex,1,size(reply->get_list,5),oii.order_id,reply->get_list[expandindex].
    order_id)
    AND (reply->get_list[expandindex].med_order_type_cd=iv_med_order_type_code)
    AND oii.order_id > 0)
  DETAIL
   selectindex = locateval(expandindex,1,size(reply->get_list,5),oii.order_id,reply->get_list[
    expandindex].order_id)
   IF (selectindex > 0)
    stat = alterlist(reply->get_list[selectindex].iv_info_list,1), reply->get_list[selectindex].
    iv_info_list.applicable_fields_bit = oii.applicable_fields_bit
   ENDIF
  WITH nocounter
 ;end select
END GO
