CREATE PROGRAM aps_get_task_instr_protocols
 DECLARE current_dt_tm_hold = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE dordercd = f8 WITH protect, noconstant(0.0)
 DECLARE lindex = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, constant(1)
 DECLARE lordercnt = i4 WITH protect, noconstant(0)
 DECLARE lreplycnt = i4 WITH protect, noconstant(0)
 DECLARE lqual2cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET dordercd = uar_get_code_by("MEANING",1305,"ORDERED")
 SET lordercnt = size(request->qual,5)
 IF (lordercnt > 0)
  SELECT
   IF ((request->sending_instr_ind=1))
    PLAN (pt
     WHERE expand(lindex,lstart,lordercnt,pt.order_id,request->qual[lindex].order_id)
      AND pt.slide_id > 0.0
      AND pt.status_cd=dordercd)
     JOIN (tipr
     WHERE tipr.processing_task_id=pt.processing_task_id)
   ELSE
    PLAN (pt
     WHERE expand(lindex,lstart,lordercnt,pt.order_id,request->qual[lindex].order_id)
      AND pt.slide_id > 0.0
      AND pt.status_cd=dordercd)
     JOIN (tipr
     WHERE tipr.processing_task_id=outerjoin(pt.processing_task_id))
   ENDIF
   INTO "nl:"
   FROM processing_task pt,
    task_instrmt_protcl_r tipr
   DETAIL
    lreplycnt = (lreplycnt+ 1)
    IF (lreplycnt > size(reply->qual,5))
     stat = alterlist(reply->qual,(lreplycnt+ 9))
    ENDIF
    reply->qual[lreplycnt].task_instrmt_protocol_r_id = tipr.task_instrmt_protcl_r_id, reply->qual[
    lreplycnt].processing_task_id = pt.processing_task_id, reply->qual[lreplycnt].
    instrument_protocol_id = tipr.instrument_protocol_id,
    reply->qual[lreplycnt].status_flag = tipr.status_flag, reply->qual[lreplycnt].order_id = pt
    .order_id
   FOOT REPORT
    stat = alterlist(reply->qual,lreplycnt)
   WITH nocounter
  ;end select
  IF ((request->sending_instr_ind=0))
   SELECT DISTINCT INTO "nl:"
    pt.processing_task_id
    FROM processing_task pt,
     code_value_group cvg,
     instrument_protocol ip,
     proc_instrmt_protcl_r pipr,
     profile_task_r ptr,
     code_value cv
    PLAN (pt
     WHERE expand(lindex,lstart,lreplycnt,pt.processing_task_id,reply->qual[lindex].
      processing_task_id))
     JOIN (ptr
     WHERE ptr.task_assay_cd=pt.task_assay_cd
      AND cnvtdatetime(current_dt_tm_hold) BETWEEN ptr.beg_effective_dt_tm AND ptr
     .end_effective_dt_tm
      AND ptr.active_ind=1)
     JOIN (pipr
     WHERE pipr.catalog_cd=ptr.catalog_cd)
     JOIN (ip
     WHERE ip.instrument_protocol_id=pipr.instrument_protocol_id
      AND ip.active_ind=1)
     JOIN (cvg
     WHERE cvg.parent_code_value=ip.instrument_type_cd
      AND cvg.child_code_value=pt.service_resource_cd)
     JOIN (cv
     WHERE cv.code_value=cvg.parent_code_value
      AND cv.active_ind=1)
    DETAIL
     lindex = locateval(lindex,lstart,lreplycnt,pt.processing_task_id,reply->qual[lindex].
      processing_task_id), reply->qual[lindex].new_instrument_protocol_id = ip.instrument_protocol_id,
     reply->qual[lreplycnt].universal_service_ident = ip.universal_service_ident,
     reply->qual[lreplycnt].placer_field_1 = ip.placer_field_1, reply->qual[lreplycnt].
     suplmtl_serv_info_txt = ip.suplmtl_serv_info_txt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET lqual2cnt = size(request->qual2,5)
 IF (lqual2cnt > 0)
  SELECT INTO "nl"
   FROM (dummyt d  WITH seq = value(lqual2cnt)),
    processing_task pt,
    profile_task_r ptr,
    proc_instrmt_protcl_r pipr,
    instrument_protocol ip,
    code_value_group cvg,
    code_value cv
   PLAN (d)
    JOIN (pt
    WHERE (pt.processing_task_id=request->qual2[d.seq].processing_task_id))
    JOIN (ptr
    WHERE ptr.task_assay_cd=pt.task_assay_cd
     AND cnvtdatetime(current_dt_tm_hold) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm
     AND ptr.active_ind=1)
    JOIN (pipr
    WHERE pipr.catalog_cd=ptr.catalog_cd)
    JOIN (ip
    WHERE ip.instrument_protocol_id=pipr.instrument_protocol_id
     AND ip.active_ind=1)
    JOIN (cvg
    WHERE cvg.parent_code_value=ip.instrument_type_cd
     AND (cvg.child_code_value=request->qual2[d.seq].service_resource_cd))
    JOIN (cv
    WHERE cv.code_value=cvg.parent_code_value
     AND cv.active_ind=1)
   DETAIL
    lreplycnt = (lreplycnt+ 1)
    IF (lreplycnt > size(reply->qual,5))
     stat = alterlist(reply->qual,(lreplycnt+ 9))
    ENDIF
    reply->qual[lreplycnt].processing_task_id = pt.processing_task_id, reply->qual[lreplycnt].
    order_id = pt.order_id, reply->qual[lreplycnt].new_instrument_protocol_id = ip
    .instrument_protocol_id,
    reply->qual[lreplycnt].universal_service_ident = ip.universal_service_ident, reply->qual[
    lreplycnt].placer_field_1 = ip.placer_field_1, reply->qual[lreplycnt].suplmtl_serv_info_txt = ip
    .suplmtl_serv_info_txt,
    reply->qual[lreplycnt].service_resource_cd = request->qual2[d.seq].service_resource_cd
   FOOT REPORT
    stat = alterlist(reply->qual,lreplycnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (lreplycnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
