CREATE PROGRAM bbt_get_disp_dest:dba
 RECORD reply(
   1 dispose_pe_updt_cnt = i4
   1 dispose_pe_active_ind = i2
   1 dispose_d_updt_cnt = i4
   1 dispose_d_active_ind = i2
   1 disp_orig_updt_cnt = i4
   1 disp_orig_updt_dt_tm = dq8
   1 disp_orig_updt_id = f8
   1 disp_orig_updt_task = i4
   1 disp_orig_updt_applctx = i4
   1 dispose_product_event_id = f8
   1 dispose_dt_tm = dq8
   1 disp_event_prsnl_id = f8
   1 reason_cd = f8
   1 reason_cd_disp = vc
   1 destruction_product_event_id = f8
   1 destruction_pe_updt_cnt = i4
   1 destruction_pe_active_ind = i2
   1 destruction_d_updt_cnt = i4
   1 destruction_d_active_ind = i2
   1 dest_orig_updt_cnt = i4
   1 dest_orig_updt_dt_tm = dq8
   1 dest_orig_updt_id = f8
   1 dest_orig_updt_task = i4
   1 dest_orig_updt_applctx = i4
   1 destruction_dt_tm = dq8
   1 dest_event_prsnl_id = f8
   1 method_cd = f8
   1 method_cd_disp = vc
   1 manifest_nbr = vc
   1 autoclave_ind = i2
   1 destruction_org_id = f8
   1 box_nbr = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->disp_dest_ind="DI"))
  SELECT INTO "nl:"
   d.*
   FROM disposition d,
    product_event p
   PLAN (d
    WHERE (d.product_event_id=request->product_event_id))
    JOIN (p
    WHERE p.product_event_id=d.product_event_id)
   HEAD REPORT
    count1 = 0
   DETAIL
    reply->dispose_pe_updt_cnt = p.updt_cnt, reply->dispose_pe_active_ind = p.active_ind, reply->
    dispose_d_updt_cnt = d.updt_cnt,
    reply->dispose_d_active_ind = d.active_ind, reply->disp_orig_updt_cnt = p.updt_cnt, reply->
    disp_orig_updt_dt_tm = p.updt_dt_tm,
    reply->disp_orig_updt_id = p.updt_id, reply->disp_orig_updt_task = p.updt_task, reply->
    disp_orig_updt_applctx = p.updt_applctx,
    reply->dispose_product_event_id = p.product_event_id, reply->reason_cd = d.reason_cd, reply->
    dispose_dt_tm = p.event_dt_tm,
    reply->disp_event_prsnl_id = p.event_prsnl_id, reply->destruction_product_event_id = 0, reply->
    destruction_pe_updt_cnt = 0,
    reply->destruction_pe_active_ind = 0, reply->destruction_d_updt_cnt = 0, reply->
    destruction_d_active_ind = 0,
    reply->dest_orig_updt_cnt = 0, reply->dest_orig_updt_dt_tm = null, reply->dest_orig_updt_id = 0,
    reply->dest_orig_updt_task = 0, reply->dest_orig_updt_applctx = 0, reply->destruction_dt_tm =
    null,
    reply->method_cd = 0, reply->manifest_nbr = "", reply->autoclave_ind = 0,
    reply->destruction_org_id = 0, reply->box_nbr = ""
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   d.*
   FROM destruction d,
    product_event p,
    code_value c
   PLAN (p
    WHERE (p.related_product_event_id=request->product_event_id))
    JOIN (d
    WHERE d.product_event_id=p.product_event_id)
    JOIN (c
    WHERE c.code_set=1610
     AND c.cdf_meaning="14"
     AND c.code_value=p.event_type_cd)
   HEAD REPORT
    count1 = 0
   DETAIL
    reply->dispose_pe_updt_cnt = 0, reply->dispose_pe_active_ind = 0, reply->dispose_d_updt_cnt = 0,
    reply->dispose_d_active_ind = 0, reply->disp_orig_updt_cnt = 0, reply->disp_orig_updt_dt_tm = 0,
    reply->disp_orig_updt_id = 0, reply->disp_orig_updt_task = 0, reply->disp_orig_updt_applctx = 0,
    reply->dispose_product_event_id = 0, reply->reason_cd = 0, reply->dispose_dt_tm = null,
    reply->destruction_product_event_id = p.product_event_id, reply->destruction_pe_updt_cnt = p
    .updt_cnt, reply->destruction_pe_active_ind = p.active_ind,
    reply->destruction_d_updt_cnt = d.updt_cnt, reply->destruction_d_active_ind = d.active_ind, reply
    ->dest_orig_updt_cnt = p.updt_cnt,
    reply->dest_orig_updt_dt_tm = p.updt_dt_tm, reply->dest_orig_updt_id = p.updt_id, reply->
    dest_orig_updt_task = p.updt_task,
    reply->dest_orig_updt_applctx = p.updt_applctx, reply->destruction_dt_tm = p.event_dt_tm, reply->
    dest_event_prsnl_id = p.event_prsnl_id,
    reply->method_cd = d.method_cd, reply->manifest_nbr = d.manifest_nbr, reply->autoclave_ind = d
    .autoclave_ind,
    reply->destruction_org_id = d.destruction_org_id, reply->box_nbr = ""
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
