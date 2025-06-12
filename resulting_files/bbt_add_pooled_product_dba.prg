CREATE PROGRAM bbt_add_pooled_product:dba
 IF ((request->called_from_script_ind=0))
  RECORD reply(
    1 product_id = f8
    1 product_event_id = f8
    1 event_type_cd = f8
    1 event_type_mean = c12
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET assigned_event_type_cd = 0.0
 SET crossmatched_event_type_cd = 0.0
 SET in_progress_event_type_cd = 0.0
 SET quarantined_event_type_cd = 0.0
 SET autologous_event_type_cd = 0.0
 SET directed_event_type_cd = 0.0
 SET available_event_type_cd = 0.0
 SET unconfirmed_event_type_cd = 0.0
 SET disposed_event_type_cd = 0.0
 SET destroyed_event_type_cd = 0.0
 SET pooled_event_type_cd = 0.0
 SET pooled_product_event_type_cd = 0.0
 SET method_cd_hd = 0.0
 SET method_cdf_meaning = "            "
 SET success_cnt = 0
 SET event_cnt = 0
 SET event = 0
 SET new_pathnet_seq = 0
 SET new_product_event_id = 0.0
 SET disposed_product_event_id = 0.0
 SET process_status_cnt = 0
 SET max_process_status_cnt = 0
 SET derivative_ind = " "
 SET cur_qty = 0
 SET new_cur_qty = 0
 SET new_active_status_cd = 0.0
 SET new_active_ind = 0
 SET new_drv_updt_cnt = 0
 SET pooled_destruction_method_cd = 0.0
 SET pooled_dispose_reason_cd = 0.0
 SET pooled_product_id = 0.0
 SET pool_event_cnt = 0
 SET cmpnt_cnt = 0
 SET cmpnt = 0
 SET cmpnt_event_cnt = 0
 SET event = 0
 SET event_cnt = 0
 SET product_cat_cd = 0.0
 SET product_class_cd = 0.0
 SET storage_temp_cd = 0.0
 SET new_blood_bank_seq = 0.0
 SET release_qty = 0
 SET release_prsnl_id = 0.0
 SET release_dt_tm = cnvtdatetime(curdate,curtime3)
 SET release_reason_cd = 0.0
 SET tag_product_event_id = 0.0
 SET tag_event_type_cd = 0.0
 SET product_state_code_set = 1610
 SET assigned_cdf_meaning = "1"
 SET crossmatched_cdf_meaning = "3"
 SET in_progress_cdf_meaning = "16"
 SET quarantined_cdf_meaning = "2"
 SET autologous_cdf_meaning = "10"
 SET directed_cdf_meaning = "11"
 SET available_cdf_meaning = "12"
 SET unconfirmed_cdf_meaning = "9"
 SET disposed_cdf_meaning = "5"
 SET destroyed_cdf_meaning = "14"
 SET pooled_cdf_meaning = "17"
 SET pooled_product_cdf_meaning = "18"
 SET pooled_destruction_cdf_meaning = "POOLED"
 SET destruction_method_code_set = 1609
 SET pooled_dispose_cdf_meaning = "POOLED"
 SET dispose_reason_code_set = 1608
 SET gsub_dummy = ""
 SET gsub_code_value = 0.0
 SET gsub_cdf_meaning = "            "
 SET gsub_product_event_status = "  "
 SET gsub_status = " "
 SET gsub_process = fillstring(200," ")
 SET gsub_message = fillstring(200," ")
 SET gsub_active_status_cd = 0.0
 SET gsub_active_ind = 0
 SET gsub_derivative_ind = " "
 SET gsub_person_id = 0.0
 SET gsub_encntr_id = 0.0
#begin_main
 SET reply->status_data.status = "I"
 CALL get_program_code_values(gsub_dummy)
 IF ((reply->status_data.status != "F"))
  SET request->event_prsnl_id = reqinfo->updt_id
  IF ((request->pooled_product_id=0))
   CALL add_pooled_product(gsub_dummy)
   IF ((reply->status_data.status != "F"))
    CALL add_pooled_product_product_event(gsub_dummy)
   ENDIF
  ELSE
   SET pooled_product_id = request->pooled_product_id
  ENDIF
  IF ((reply->status_data.status != "F"))
   CALL process_pooled_product_events(gsub_dummy)
  ENDIF
  IF ((reply->status_data.status != "F"))
   CALL pool_components(gsub_dummy)
   IF ((reply->status_data.status != "F"))
    CALL load_process_status("S","SUCCESS","Pooled product added.  All components pooled.")
    IF ((request->pooled_product_id=0))
     SET reply->product_id = pooled_product_id
     SET reply->product_event_id = tag_product_event_id
     SET reply->event_type_cd = tag_event_type_cd
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO exit_script
#end_main
 SUBROUTINE add_pooled_product(sub_dummy)
   SET product_cat_cd = 0.0
   SET product_class_cd = 0.0
   SET storage_temp_cd = 0.0
   SELECT INTO "nl:"
    pi.product_cat_cd, pi.product_class_cd, pc.storage_temp_cd
    FROM product_index pi,
     product_category pc
    PLAN (pi
     WHERE (pi.product_cd=request->product_cd)
      AND pi.active_ind=1)
     JOIN (pc
     WHERE pc.product_cat_cd=pi.product_cat_cd
      AND pc.active_ind=1)
    DETAIL
     product_cat_cd = pi.product_cat_cd, product_class_cd = pi.product_class_cd, storage_temp_cd = pc
     .storage_temp_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","get product_index, product_category",
     "product_cat_cd/product_class_cd/storage_temp_cd not found on product_index/product_category for pooled product product_cd"
     )
    RETURN
   ENDIF
   SET new_blood_bank_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(blood_bank_seq,nextval)"###########################;rp0"
    FROM dual
    DETAIL
     new_blood_bank_seq = cnvtreal(seqn)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","get new blood_bank_seq","could not get new blood_bank_seq")
    RETURN
   ENDIF
   SET pooled_product_id = new_blood_bank_seq
   INSERT  FROM product p
    SET p.product_id = pooled_product_id, p.product_nbr = request->product_nbr, p.flag_chars =
     request->flag_chars,
     p.locked_ind = 0, p.product_cd = request->product_cd, p.product_cat_cd = product_cat_cd,
     p.product_class_cd = product_class_cd, p.cur_inv_locn_cd = 0.0, p.orig_inv_locn_cd = 0.0,
     p.cur_supplier_id = request->supplier_id, p.orig_unit_meas_cd = request->unit_meas_cd, p
     .storage_temp_cd = storage_temp_cd,
     p.cur_unit_meas_cd = request->unit_meas_cd, p.cur_expire_dt_tm = cnvtdatetime(request->
      expire_dt_tm), p.pooled_product_ind = 1,
     p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     p.active_status_prsnl_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     p.updt_task = reqinfo->updt_task, p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->
     updt_applctx,
     p.cur_owner_area_cd = request->cur_owner_area_cd, p.cur_inv_area_cd = request->cur_inv_area_cd,
     p.pool_option_id = request->pool_option_id,
     p.create_dt_tm = cnvtdatetime(request->event_dt_tm)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL load_process_status("F","add product row","could not add product row for pooled product")
    RETURN
   ENDIF
   INSERT  FROM blood_product bp
    SET bp.product_id = pooled_product_id, bp.product_cd = request->product_cd, bp.cur_volume =
     request->volume,
     bp.orig_label_abo_cd = request->abo_cd, bp.orig_label_rh_cd = request->rh_cd, bp.cur_abo_cd =
     request->abo_cd,
     bp.cur_rh_cd = request->rh_cd, bp.orig_expire_dt_tm = cnvtdatetime(request->expire_dt_tm), bp
     .orig_volume = request->volume,
     bp.autologous_ind = request->autologous_ind, bp.directed_ind = request->directed_ind, bp
     .active_ind = 1,
     bp.active_status_cd = reqdata->active_status_cd, bp.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), bp.active_status_prsnl_id = reqinfo->updt_id,
     bp.updt_cnt = 0, bp.updt_dt_tm = cnvtdatetime(curdate,curtime3), bp.updt_task = reqinfo->
     updt_task,
     bp.updt_id = reqinfo->updt_id, bp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL load_process_status("F","add blood product row",
     "could not add blood product row for pooled product")
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE add_pooled_product_product_event(sub_dummy2)
  CALL add_product_event(pooled_product_id,request->person_id,request->encntr_id,0,0,
   pooled_product_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
   0,0,0,reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),
   reqinfo->updt_id)
  CALL process_product_event_status("add",gsub_product_event_status,"pooled_product")
 END ;Subroutine
 SUBROUTINE process_pooled_product_events(sub_dummy)
  SET pooled_event_cnt = cnvtint(size(request->pool_eventlist,5))
  FOR (event = 1 TO pooled_event_cnt)
    CALL get_event_detail(sub_dummy)
    IF ((request->pool_eventlist[event].event_type_cd=assigned_event_type_cd))
     IF ((request->pool_eventlist[event].inactivate_ind > 0))
      CALL release_inactivate_assign_pool(gsub_dummy)
     ELSE
      CALL assigned_pooled_product(gsub_dummy)
      IF ((reply->status_data.status != "F"))
       SET tag_product_event_id = new_product_event_id
       SET tag_event_type_cd = assigned_event_type_cd
      ENDIF
     ENDIF
    ELSEIF ((request->pool_eventlist[event].event_type_cd=crossmatched_event_type_cd))
     IF ((request->pool_eventlist[event].inactivate_ind > 0))
      CALL release_inactivate_crossmatch_pool(gsub_dummy)
     ELSE
      CALL crossmatched_pooled_product(gsub_dummy)
      IF ((reply->status_data.status != "F"))
       SET tag_product_event_id = new_product_event_id
       SET tag_event_type_cd = crossmatched_event_type_cd
      ENDIF
     ENDIF
    ELSEIF ((request->pool_eventlist[event].event_type_cd=quarantined_event_type_cd))
     CALL quarantined_pooled_product(gsub_dummy)
    ELSEIF ((request->pool_eventlist[event].event_type_cd=available_event_type_cd))
     IF ((request->pool_eventlist[event].inactivate_ind=1))
      CALL inactivate_available_pooled_product_event(request->pool_eventlist[event].product_event_id,
       request->pool_eventlist[event].updt_cnt)
     ELSE
      CALL available_pooled_product(gsub_dummy)
     ENDIF
    ELSEIF ((request->pool_eventlist[event].event_type_cd=unconfirmed_event_type_cd))
     IF ((request->pool_eventlist[event].inactivate_ind > 0))
      CALL inactivate_unconfirmed_pool(request->pool_eventlist[event].product_event_id,request->
       pool_eventlist[event].updt_cnt)
     ELSE
      CALL unconfirmed_pooled_product(gsub_dummy)
     ENDIF
    ELSEIF ((((request->pool_eventlist[event].event_type_cd=autologous_event_type_cd)) OR ((request->
    pool_eventlist[event].event_type_cd=directed_event_type_cd))) )
     IF ((request->pool_eventlist[event].inactivate_ind > 0))
      CALL inactivateautodirectedevent(request->pool_eventlist[event].product_event_id)
     ELSE
      CALL auto_directed_pooled_product(request->pool_eventlist[event].event_type_cd)
     ENDIF
    ELSE
     CALL load_process_status("F","add pooled product events",build(
       "invalid event_type_cd for pooled product--event_type_cd = ",request->pool_eventlist[event].
       event_type_cd))
    ENDIF
    IF ((reply->status_data.status="F"))
     RETURN
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE inactivate_available_pooled_product_event(sub2_product_event_id,sub2_updt_cnt)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE pe.product_event_id=sub2_product_event_id
      AND pe.updt_cnt=sub2_updt_cnt)
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock pooled product_event/available forupdate",
     "pooled available product_event row could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(sub2_product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,sub2_updt_cnt,0,
    0)
   CALL process_product_event_status("inactivate",gsub_product_event_status,"available")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE get_event_detail(sub_dummy)
   DECLARE req_person_id = f8 WITH noconstant(0)
   DECLARE req_encntr_id = f8 WITH noconstant(0)
   DECLARE evnt_person_id = f8 WITH noconstant(0)
   DECLARE evnt_encntr_id = f8 WITH noconstant(0)
   SET req_person_id = validate(request->person_id,req_person_id)
   SET req_encntr_id = validate(request->encntr_id,req_encntr_id)
   SET evnt_person_id = validate(request->pool_eventlist[event].person_id,evnt_person_id)
   SET evnt_encntr_id = validate(request->pool_eventlist[event].encntr_id,evnt_encntr_id)
   IF (evnt_person_id > 0
    AND evnt_encntr_id > 0)
    EXECUTE then
    SET gsub_person_id = evnt_person_id
    SET gsub_encntr_id = evnt_encntr_id
    RETURN
   ENDIF
   IF (req_person_id > 0
    AND req_encntr_id > 0)
    EXECUTE then
    SET gsub_person_id = req_person_id
    SET gsub_encntr_id = req_encntr_id
    RETURN
   ENDIF
   IF (evnt_person_id > 0)
    SET gsub_person_id = evnt_person_id
   ELSE
    SET gsub_person_id = req_person_id
   ENDIF
 END ;Subroutine
 SUBROUTINE assigned_pooled_product(sub_dummy2)
   CALL add_product_event(pooled_product_id,gsub_person_id,gsub_encntr_id,0,0,
    assigned_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
    0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
    reqinfo->updt_id)
   CALL process_product_event_status("add",gsub_product_event_status,"assigned")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   CALL add_assign(new_product_event_id,pooled_product_id,gsub_person_id,request->pool_eventlist[
    event].reason_cd,0,
    1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id)
   IF (curqual=0)
    CALL load_process_status("F","add assign row","could not add assign row for pooled product")
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE add_assign(sub_product_event_id,sub_product_id,sub_person_id,sub_assign_reason_cd,
  sub_prov_id,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
   INSERT  FROM assign a
    SET a.product_event_id = sub_product_event_id, a.product_id = sub_product_id, a.person_id =
     sub_person_id,
     a.assign_reason_cd = sub_assign_reason_cd, a.prov_id = sub_prov_id, a.updt_cnt = 0,
     a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_task =
     reqinfo->updt_task,
     a.updt_applctx = reqinfo->updt_applctx, a.active_ind = sub_active_ind, a.active_status_cd =
     sub_active_status_cd,
     a.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), a.active_status_prsnl_id =
     sub_active_status_prsnl_id
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE crossmatched_pooled_product(sub_dummy2)
   CALL add_product_event(pooled_product_id,gsub_person_id,gsub_encntr_id,0,0,
    crossmatched_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
    0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
    reqinfo->updt_id)
   CALL process_product_event_status("add",gsub_product_event_status,"crossmatched")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   CALL add_crossmatch(new_product_event_id,pooled_product_id,gsub_person_id,cnvtdatetime(request->
     pool_eventlist[event].expire_dt_tm),1,
    reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id)
   IF (curqual=0)
    CALL load_process_status("F","add crossmatch row",
     "could not add crossmatch row for pooled product")
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE add_crossmatch(sub_product_event_id,sub_product_id,sub_person_id,sub_crossmatch_exp_dt_tm,
  sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
   INSERT  FROM crossmatch xm
    SET xm.product_event_id = sub_product_event_id, xm.product_id = sub_product_id, xm.person_id =
     sub_person_id,
     xm.crossmatch_exp_dt_tm = cnvtdatetime(sub_crossmatch_exp_dt_tm), xm.updt_cnt = 0, xm.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     xm.updt_id = reqinfo->updt_id, xm.updt_task = reqinfo->updt_task, xm.updt_applctx = reqinfo->
     updt_applctx,
     xm.active_ind = sub_active_ind, xm.active_status_cd = sub_active_status_cd, xm
     .active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm),
     xm.active_status_prsnl_id = sub_active_status_prsnl_id
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE quarantined_pooled_product(sub_dummy2)
   CALL add_product_event(pooled_product_id,0,0,0,0,
    quarantined_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
    0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
    reqinfo->updt_id)
   CALL process_product_event_status("add",gsub_product_event_status,"quarantined")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   CALL add_quarantine(new_product_event_id,pooled_product_id,request->pool_eventlist[event].
    reason_cd,1,reqdata->active_status_cd,
    cnvtdatetime(curdate,curtime3),reqinfo->updt_id)
   IF (curqual=0)
    CALL load_process_status("F","add quarantine row",
     "could not add quarantine row for pooled product")
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE add_quarantine(sub_product_event_id,sub_product_id,sub_quar_reason_cd,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
   INSERT  FROM quarantine qu
    SET qu.product_event_id = sub_product_event_id, qu.product_id = sub_product_id, qu.quar_reason_cd
      = sub_quar_reason_cd,
     qu.updt_cnt = 0, qu.updt_dt_tm = cnvtdatetime(curdate,curtime3), qu.updt_id = reqinfo->updt_id,
     qu.updt_task = reqinfo->updt_task, qu.updt_applctx = reqinfo->updt_applctx, qu.active_ind =
     sub_active_ind,
     qu.active_status_cd = sub_active_status_cd, qu.active_status_dt_tm = cnvtdatetime(
      sub_active_status_dt_tm), qu.active_status_prsnl_id = sub_active_status_prsnl_id
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE available_pooled_product(sub_dummy2)
  CALL add_product_event(pooled_product_id,0,0,0,0,
   available_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
   0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
   reqinfo->updt_id)
  CALL process_product_event_status("add",gsub_product_event_status,"available")
 END ;Subroutine
 SUBROUTINE unconfirmed_pooled_product(sub_dummy2)
  CALL add_product_event(pooled_product_id,0,0,0,0,
   unconfirmed_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
   0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
   reqinfo->updt_id)
  CALL process_product_event_status("add",gsub_product_event_status,"unconfirmed")
 END ;Subroutine
 SUBROUTINE auto_directed_pooled_product(sub_ad_event_type_cd)
   CALL add_product_event(pooled_product_id,gsub_person_id,gsub_encntr_id,0,0,
    sub_ad_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
    0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
    reqinfo->updt_id)
   CALL process_product_event_status("add",gsub_product_event_status,"auto_directed")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   CALL add_auto_directed(new_product_event_id,pooled_product_id,gsub_person_id,gsub_encntr_id,
    cnvtdatetime(request->event_dt_tm),
    1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,validate(request->
     pool_eventlist[event].donated_by_relative_ind,0),
    validate(request->pool_eventlist[event].expected_usage_dt_tm,cnvtdatetime(curdate,curtime3)))
   SET request->pool_eventlist[event].product_event_id = new_product_event_id
   IF (curqual=0)
    CALL load_process_status("F","add autologous row",
     "could not add auto_directed row for pooled product")
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE add_auto_directed(sub_product_event_id,sub_product_id,sub_person_id,sub_encntr_id,
  sub_associated_dt_tm,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id,sub_donated_by_fam_ind,sub_expected_usage_dt_tm)
   INSERT  FROM auto_directed ad
    SET ad.product_event_id = sub_product_event_id, ad.product_id = sub_product_id, ad.person_id =
     sub_person_id,
     ad.encntr_id = sub_encntr_id, ad.associated_dt_tm = cnvtdatetime(sub_associated_dt_tm), ad
     .updt_cnt = 0,
     ad.updt_dt_tm = cnvtdatetime(curdate,curtime3), ad.updt_id = reqinfo->updt_id, ad.updt_task =
     reqinfo->updt_task,
     ad.updt_applctx = reqinfo->updt_applctx, ad.active_ind = sub_active_ind, ad.active_status_cd =
     sub_active_status_cd,
     ad.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), ad.active_status_prsnl_id =
     sub_active_status_prsnl_id, ad.donated_by_relative_ind = sub_donated_by_fam_ind,
     ad.expected_usage_dt_tm = cnvtdatetime(sub_expected_usage_dt_tm)
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE pool_components(sub_dummy)
  SET cmpnt_cnt = cnvtint(size(request->cmpntlist,5))
  IF (cmpnt_cnt > 0)
   FOR (cmpnt = 1 TO cmpnt_cnt)
    CALL lock_product_forupdate(request->cmpntlist[cmpnt].product_id,1,request->cmpntlist[cmpnt].
     p_updt_cnt)
    IF ((reply->status_data.status="F"))
     RETURN
    ELSE
     CALL add_pooled_product_event(gsub_dummy)
     IF ((reply->status_data.status="F"))
      RETURN
     ELSE
      CALL process_dispose_destroy(gsub_dummy)
      IF ((reply->status_data.status="F"))
       RETURN
      ENDIF
      SET cmpnt_event_cnt = cnvtint(size(request->cmpntlist[cmpnt].eventlist,5))
      FOR (event = 1 TO cmpnt_event_cnt)
       IF ((request->cmpntlist[cmpnt].eventlist[event].event_type_cd=assigned_event_type_cd))
        CALL release_inactivate_assign(gsub_dummy)
       ELSEIF ((request->cmpntlist[cmpnt].eventlist[event].event_type_cd=crossmatched_event_type_cd))
        CALL release_inactivate_crossmatch(gsub_dummy)
       ELSEIF ((request->cmpntlist[cmpnt].eventlist[event].event_type_cd=quarantined_event_type_cd))
        CALL inactivate_quarantine(gsub_dummy)
       ELSEIF ((request->cmpntlist[cmpnt].eventlist[event].event_type_cd=available_event_type_cd))
        CALL inactivate_available(gsub_dummy)
       ELSE
        IF ((request->cmpntlist[cmpnt].eventlist[event].event_type_cd != unconfirmed_event_type_cd)
         AND (request->cmpntlist[cmpnt].eventlist[event].event_type_cd != autologous_event_type_cd)
         AND (request->cmpntlist[cmpnt].eventlist[event].event_type_cd != directed_event_type_cd))
         CALL load_process_status("F","inactivate/release component product events",build(
           "invalid active product state for pool component--event_type_cd = ",request->cmpntlist[
           cmpnt].eventlist[event].event_type_cd))
        ENDIF
       ENDIF
       IF ((reply->status_data.status="F"))
        RETURN
       ENDIF
      ENDFOR
      IF ((reply->status_data.status != "F"))
       CALL update_component_product(request->cmpntlist[cmpnt].product_id,pooled_product_id,request->
        cmpntlist[cmpnt].p_updt_cnt)
       IF ((reply->status_data.status="F"))
        RETURN
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
  ELSE
   CALL load_process_status("F","pool components",
    "No components selected for pooling.  Pooled product not added.")
   RETURN
  ENDIF
 END ;Subroutine
 SUBROUTINE add_pooled_product_event(sub_dummy2)
  CALL add_product_event(request->cmpntlist[cmpnt].product_id,0,0,0,0,
   pooled_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
   0,0,0,reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),
   reqinfo->updt_id)
  CALL process_product_event_status("add",gsub_product_event_status,"pooled")
 END ;Subroutine
 SUBROUTINE process_dispose_destroy(sub_dummy2)
   SET disposed_product_event_id = 0.0
   CALL add_product_event(request->cmpntlist[cmpnt].product_id,0,0,0,0,
    disposed_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
    0,0,0,reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),
    reqinfo->updt_id)
   CALL process_product_event_status("add",gsub_product_event_status,"disposed")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   SET disposed_product_event_id = new_product_event_id
   CALL add_dispose(disposed_product_event_id,request->cmpntlist[cmpnt].product_id,
    pooled_dispose_reason_cd,null,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id)
   IF (curqual=0)
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ENDIF
   CALL add_product_event(request->cmpntlist[cmpnt].product_id,0,0,0,0,
    destroyed_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
    0,disposed_product_event_id,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
    reqinfo->updt_id)
   CALL process_product_event_status("add",gsub_product_event_status,"destroyed")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   CALL add_destruction(new_product_event_id,request->cmpntlist[cmpnt].product_id,
    pooled_destruction_method_cd,"",null,
    null,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
    reqinfo->updt_id)
   IF (curqual=0)
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE add_dispose(sub_product_event_id,sub_product_id,sub_reason_cd,sub_disposed_qty,
  sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
  INSERT  FROM disposition dsp
   SET dsp.product_event_id = sub_product_event_id, dsp.product_id = sub_product_id, dsp.reason_cd =
    sub_reason_cd,
    dsp.disposed_qty = sub_disposed_qty, dsp.active_ind = sub_active_ind, dsp.active_status_cd =
    sub_active_status_cd,
    dsp.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), dsp.active_status_prsnl_id =
    sub_active_status_prsnl_id, dsp.updt_cnt = 0,
    dsp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsp.updt_id = reqinfo->updt_id, dsp.updt_task =
    reqinfo->updt_task,
    dsp.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "create dispose row"
   SET gsub_message = "dispose row could not be created"
  ENDIF
 END ;Subroutine
 SUBROUTINE add_destruction(sub_product_event_id,sub_product_id,sub_method_cd,sub_box_nbr,
  sub_manifest_nbr,sub_destroyed_qty,sub_autoclave_ind,sub_active_ind,sub_active_status_cd,
  sub_active_status_dt_tm,sub_active_status_prsnl_id)
  INSERT  FROM destruction dst
   SET dst.product_event_id = sub_product_event_id, dst.product_id = sub_product_id, dst.method_cd =
    sub_method_cd,
    dst.box_nbr = trim(cnvtupper(sub_box_nbr)), dst.manifest_nbr = sub_manifest_nbr, dst
    .destroyed_qty = sub_destroyed_qty,
    dst.autoclave_ind = sub_autoclave_ind, dst.destruction_org_id = 0, dst.active_ind =
    sub_active_ind,
    dst.active_status_cd = sub_active_status_cd, dst.active_status_dt_tm = cnvtdatetime(
     sub_active_status_dt_tm), dst.active_status_prsnl_id = sub_active_status_prsnl_id,
    dst.updt_cnt = 0, dst.updt_dt_tm = cnvtdatetime(curdate,curtime3), dst.updt_id = reqinfo->updt_id,
    dst.updt_task = reqinfo->updt_task, dst.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "create destruction row"
   SET gsub_message = "destruction row could not be created"
  ENDIF
 END ;Subroutine
 SUBROUTINE release_inactivate_assign(sub_dummy2)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->cmpntlist[cmpnt].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->cmpntlist[cmpnt].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock product_event forupdate",
     "product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    a.product_event_id
    FROM assign a
    PLAN (a
     WHERE (a.product_event_id=request->cmpntlist[cmpnt].eventlist[event].product_event_id)
      AND (a.updt_cnt=request->cmpntlist[cmpnt].eventlist[event].pe_child_updt_cnt))
    WITH nocounter, forupdate(a)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock assign forupdate","assign rows could not be locked forupdate")
    RETURN
   ENDIF
   SET new_active_ind = 0
   SET new_active_status_cd = reqdata->inactive_status_cd
   CALL chg_product_event(request->cmpntlist[cmpnt].eventlist[event].product_event_id,0,0,0,
    new_active_ind,
    new_active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->cmpntlist[cmpnt].
    eventlist[event].pe_updt_cnt,0,
    0)
   CALL process_product_event_status("inactivate",gsub_product_event_status,"assigned")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   CALL chg_assign(request->cmpntlist[cmpnt].eventlist[event].product_event_id,null,request->
    cmpntlist[cmpnt].eventlist[event].pe_child_updt_cnt,new_active_ind,new_active_status_cd,
    cnvtdatetime(curdate,curtime3),reqinfo->updt_id," ")
   IF (curqual=0)
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ENDIF
   IF ((((request->cmpntlist[cmpnt].eventlist[event].person_id != request->person_id)) OR ((request->
   person_id <= 0))) )
    CALL add_assign_release(request->cmpntlist[cmpnt].eventlist[event].product_event_id,request->
     cmpntlist[cmpnt].product_id,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,request->
     cmpntlist[cmpnt].eventlist[event].release_reason_cd,
     null," ")
    IF (curqual=0)
     CALL load_process_status(gsub_status,gsub_process,gsub_message)
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_assign(sub_product_event_id,sub_new_cur_qty,sub_updt_cnt,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id,sub_derivative_ind)
  UPDATE  FROM assign a
   SET a.cur_assign_qty = sub_new_cur_qty, a.active_ind = sub_active_ind, a.active_status_cd =
    sub_active_status_cd,
    a.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), a.active_status_prsnl_id =
    sub_active_status_prsnl_id, a.updt_cnt = (a.updt_cnt+ 1),
    a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_task = reqinfo->updt_task, a.updt_id =
    reqinfo->updt_id,
    a.updt_applctx = reqinfo->updt_applctx
   WHERE a.product_event_id=sub_product_event_id
    AND a.updt_cnt=sub_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "release/inactivate assign row"
   SET gsub_message = "assign row could not be released/inactivated"
  ENDIF
 END ;Subroutine
 SUBROUTINE add_assign_release(sub_product_event_id,sub_product_id,sub_release_dt_tm,
  sub_release_prsnl_id,sub_release_reason_cd,sub_release_qty,sub_derivative_ind)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "add_assign_release"
    SET gsub_message = "get pathnet seq failed for assign_release_id"
   ELSE
    INSERT  FROM assign_release ar
     SET ar.assign_release_id = new_pathnet_seq, ar.product_event_id = sub_product_event_id, ar
      .product_id = sub_product_id,
      ar.release_dt_tm = cnvtdatetime(sub_release_dt_tm), ar.release_prsnl_id = sub_release_prsnl_id,
      ar.release_reason_cd = sub_release_reason_cd,
      ar.release_qty = sub_release_qty, ar.updt_cnt = 0, ar.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      ar.updt_task = reqinfo->updt_task, ar.updt_id = reqinfo->updt_id, ar.updt_applctx = reqinfo->
      updt_applctx,
      ar.active_ind = 1, ar.active_status_cd = reqdata->active_status_cd, ar.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      ar.active_status_prsnl_id = reqinfo->updt_id
    ;end insert
    IF (curqual=0)
     SET gsub_status = "F"
     SET gsub_process = "add_assign_release"
     SET gsub_message = "could not add assign_release row"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE release_inactivate_crossmatch(sub_dummy2)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->cmpntlist[cmpnt].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->cmpntlist[cmpnt].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock product_event forupdate",
     "product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    xm.product_event_id
    FROM crossmatch xm
    PLAN (xm
     WHERE (xm.product_event_id=request->cmpntlist[cmpnt].eventlist[event].product_event_id)
      AND (xm.updt_cnt=request->cmpntlist[cmpnt].eventlist[event].pe_child_updt_cnt))
    WITH nocounter, forupdate(xm)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock crossmatch forupdate",
     "crossmatch rows could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->cmpntlist[cmpnt].eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->cmpntlist[
    cmpnt].eventlist[event].pe_updt_cnt,0,
    0)
   CALL process_product_event_status("inactivate",gsub_product_event_status,"crossmatched")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   IF ((((request->cmpntlist[cmpnt].eventlist[event].person_id != request->person_id)) OR ((request->
   person_id <= 0))) )
    SET release_dt_tm = cnvtdatetime(request->event_dt_tm)
    SET release_prsnl_id = request->event_prsnl_id
    SET release_reason_cd = request->cmpntlist[cmpnt].eventlist[event].release_reason_cd
    SET release_qty = null
   ELSE
    SET release_dt_tm = null
    SET release_prsnl_id = 0.0
    SET release_reason_cd = 0.0
    SET release_qty = null
   ENDIF
   CALL chg_crossmatch(request->cmpntlist[cmpnt].eventlist[event].product_event_id,request->
    cmpntlist[cmpnt].eventlist[event].pe_child_updt_cnt,cnvtdatetime(release_dt_tm),release_prsnl_id,
    release_reason_cd,
    release_qty,0,reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id)
   IF (curqual=0)
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_crossmatch(sub_product_event_id,sub_updt_cnt,sub_release_dt_tm,sub_release_prsnl_id,
  sub_release_reason_cd,sub_release_qty,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id)
  UPDATE  FROM crossmatch xm
   SET xm.release_dt_tm = cnvtdatetime(sub_release_dt_tm), xm.release_prsnl_id = sub_release_prsnl_id,
    xm.release_reason_cd = sub_release_reason_cd,
    xm.release_qty = sub_release_qty, xm.active_ind = sub_active_ind, xm.active_status_cd =
    sub_active_status_cd,
    xm.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), xm.active_status_prsnl_id =
    sub_active_status_prsnl_id, xm.updt_cnt = (xm.updt_cnt+ 1),
    xm.updt_dt_tm = cnvtdatetime(curdate,curtime3), xm.updt_task = reqinfo->updt_task, xm.updt_id =
    reqinfo->updt_id,
    xm.updt_applctx = reqinfo->updt_applctx
   WHERE xm.product_event_id=sub_product_event_id
    AND xm.updt_cnt=sub_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "release/inactivate crossmatch row"
   SET gsub_message = "crossmatch row could not be released/inactivated"
  ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_quarantine(sub_dummy2)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->cmpntlist[cmpnt].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->cmpntlist[cmpnt].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock product_event forupdate",
     "product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    qu.product_event_id
    FROM quarantine qu
    PLAN (qu
     WHERE (qu.product_event_id=request->cmpntlist[cmpnt].eventlist[event].product_event_id)
      AND (qu.updt_cnt=request->cmpntlist[cmpnt].eventlist[event].pe_child_updt_cnt))
    WITH nocounter, forupdate(qu)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock quarantine forupdate",
     "quarantine rows could not be locked forupdate")
    RETURN
   ENDIF
   SET new_active_ind = 0
   SET new_active_status_cd = reqdata->inactive_status_cd
   CALL chg_product_event(request->cmpntlist[cmpnt].eventlist[event].product_event_id,0,0,0,
    new_active_ind,
    new_active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->cmpntlist[cmpnt].
    eventlist[event].pe_updt_cnt,0,
    0)
   CALL process_product_event_status("inactivate",gsub_product_event_status,"quarantined")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   CALL chg_quarantine(request->cmpntlist[cmpnt].eventlist[event].product_event_id,null,request->
    cmpntlist[cmpnt].eventlist[event].pe_child_updt_cnt,new_active_ind,new_active_status_cd,
    cnvtdatetime(curdate,curtime3),reqinfo->updt_id," ")
   IF (curqual=0)
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_quarantine(sub_product_event_id,sub_cur_quar_qty,sub_updt_cnt,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id,sub_derivative_ind)
  UPDATE  FROM quarantine qu
   SET qu.cur_quar_qty = sub_cur_quar_qty, qu.updt_cnt = (qu.updt_cnt+ 1), qu.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    qu.updt_task = reqinfo->updt_task, qu.updt_id = reqinfo->updt_id, qu.updt_applctx = reqinfo->
    updt_applctx,
    qu.active_ind = sub_active_ind, qu.active_status_cd = sub_active_status_cd, qu
    .active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm),
    qu.active_status_prsnl_id = sub_active_status_prsnl_id
   WHERE qu.product_event_id=sub_product_event_id
    AND qu.updt_cnt=sub_updt_cnt
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "inactivate quarantine row"
   SET gsub_message = "quarantine row could not be inactivated"
  ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_available(sub_dummy2)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->cmpntlist[cmpnt].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->cmpntlist[cmpnt].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock product_event forupdate",
     "product_event row could not be locked forupdate")
    RETURN
   ENDIF
   SET new_active_ind = 0
   SET new_active_status_cd = reqdata->inactive_status_cd
   CALL chg_product_event(request->cmpntlist[cmpnt].eventlist[event].product_event_id,0,0,0,
    new_active_ind,
    new_active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->cmpntlist[cmpnt].
    eventlist[event].pe_updt_cnt,0,
    0)
   CALL process_product_event_status("inactivate",gsub_product_event_status,"available")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_unconfirmed(sub_dummy2)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->cmpntlist[cmpnt].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->cmpntlist[cmpnt].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock unconfirmed product_event forupdate",
     "unconfirmed product_event row could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->cmpntlist[cmpnt].eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->cmpntlist[
    cmpnt].eventlist[event].pe_updt_cnt,0,
    0)
   CALL process_product_event_status("inactivate",gsub_product_event_status,"unconfirmed")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_auto_directed(sub_dummy2)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->cmpntlist[cmpnt].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->cmpntlist[cmpnt].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock product_event forupdate",
     "product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    ad.product_event_id
    FROM auto_directed ad
    PLAN (ad
     WHERE (ad.product_event_id=request->cmpntlist[cmpnt].eventlist[event].product_event_id)
      AND (ad.updt_cnt=request->cmpntlist[cmpnt].eventlist[event].pe_child_updt_cnt))
    WITH nocounter, forupdate(ad)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock auto_directed forupdate",
     "auto_directed rows could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->cmpntlist[cmpnt].eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->cmpntlist[
    cmpnt].eventlist[event].pe_updt_cnt,0,
    0)
   CALL process_product_event_status("inactivate",gsub_product_event_status,"auto_directed")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   CALL chg_auto_directed(request->cmpntlist[cmpnt].eventlist[event].product_event_id,request->
    cmpntlist[cmpnt].eventlist[event].pe_child_updt_cnt,0,reqdata->inactive_status_cd,cnvtdatetime(
     curdate,curtime3),
    reqinfo->updt_id)
   IF (curqual=0)
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_auto_directed(sub_product_event_id,sub_updt_cnt,sub_active_ind,sub_active_status_cd,
  sub_active_status_dt_tm,sub_active_status_prsnl_id)
  UPDATE  FROM auto_directed ad
   SET ad.active_ind = sub_active_ind, ad.active_status_cd = sub_active_status_cd, ad
    .active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm),
    ad.active_status_prsnl_id = sub_active_status_prsnl_id, ad.updt_cnt = (ad.updt_cnt+ 1), ad
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ad.updt_task = reqinfo->updt_task, ad.updt_id = reqinfo->updt_id, ad.updt_applctx = reqinfo->
    updt_applctx
   WHERE ad.product_event_id=sub_product_event_id
    AND ad.updt_cnt=sub_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "inactivate auto_directed row"
   SET gsub_message = "auto_directed row could not be inactivated"
  ENDIF
 END ;Subroutine
 SUBROUTINE process_product_event_status(sub_pe_type,sub_pe_status,sub_event_type_disp)
  SET sub_pe_process = concat(sub_pe_type," ",sub_event_type_disp," product_event")
  IF (sub_pe_status="FS")
   CALL load_process_status("F",sub_pe_process,"get new product_event_id failed (seq)")
  ELSEIF (sub_pe_status="FA")
   CALL load_process_status("F",sub_pe_process,concat("could not ",sub_pe_type," ",event_type_disp,
     " product_event row"))
  ELSEIF (gsub_product_event_status="FU")
   CALL load_process_status("F",concat(sub_pe_type," active ",sub_event_type_disp,
     " product_event row"),concat(sub_event_type_disp,
     " product_event row could not be released--product_event_id:  ",request->cmpntlist[cmpnt].
     eventlist[event].product_event_id))
  ELSEIF (sub_pe_status != "OK")
   CALL load_process_status("F",sub_pe_process,concat(
     "Script error!  Invalid product_event_status:  ",gsub_product_event_status))
  ENDIF
 END ;Subroutine
 SUBROUTINE update_component_product(sub_product_id,sub_pooled_product_id,sub_updt_cnt)
  UPDATE  FROM product p
   SET p.pooled_product_id = sub_pooled_product_id, p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1),
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
    reqinfo->updt_task,
    p.updt_applctx = reqinfo->updt_applctx
   WHERE p.product_id=sub_product_id
    AND p.updt_cnt=sub_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL load_process_status("F","update component product row",build(
     "could not update component product row.  product_id = ",sub_product_id))
  ENDIF
 END ;Subroutine
 SUBROUTINE lock_product_forupdate(sub_product_id,sub_locked_ind,sub_updt_cnt)
  SELECT INTO "nl:"
   p.product_id
   FROM product p
   PLAN (p
    WHERE p.product_id=sub_product_id
     AND p.updt_cnt=sub_updt_cnt)
   WITH nocounter, forupdate(p)
  ;end select
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "lock product row forupdate"
   SET gsub_message = build("product row could not be locked for update.  product_id = ",
    sub_product_id)
   CALL load_process_status(gsub_status,gsub_process,gsub_message)
  ENDIF
 END ;Subroutine
 SUBROUTINE unlock_product(sub_product_id,sub_updt_cnt)
  UPDATE  FROM product p
   SET p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
    updt_applctx
   WHERE p.product_id=sub_product_id
    AND p.updt_cnt=sub_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "unlock product row"
   SET gsub_message = "product row could not be unlocked"
  ENDIF
 END ;Subroutine
 SUBROUTINE get_program_code_values(sub_dummy)
   SET gsub_status = " "
   CALL get_code_value(destruction_method_code_set,pooled_destruction_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get pooled destruction method _cd"
    SET gsub_message =
    "could not retrieve pooled destruction method _cd--code_set = 1609, cdf_meaning = POOLED"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET pooled_destruction_method_cd = gsub_code_value
   ENDIF
   CALL get_code_value(dispose_reason_code_set,pooled_dispose_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get pooled dispose reason _cd"
    SET gsub_message =
    "could not retrieve pooled dispose reason _cd--code_set = 1608, cdf_meaning = POOLED"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET pooled_dispose_reason_cd = gsub_code_value
   ENDIF
   CALL get_code_value(product_state_code_set,disposed_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get disposed event_type_cd"
    SET gsub_message = "could not retrieve disosed event_type_cd--code_set = 1610, cdf_meaning = 5"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET disposed_event_type_cd = gsub_code_value
   ENDIF
   CALL get_code_value(product_state_code_set,destroyed_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get destroyed event_type_cd"
    SET gsub_message =
    "could not retrieve destroyed event_type_cd--code_set = 1610, cdf_meaning = 14"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET destroyed_event_type_cd = gsub_code_value
   ENDIF
   CALL get_code_value(product_state_code_set,assigned_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get assigned event_type_cd"
    SET gsub_message = "could not retrieve assigned event_type_cd--code_set = 1610, cdf_meaning = 1"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET assigned_event_type_cd = gsub_code_value
   ENDIF
   CALL get_code_value(product_state_code_set,crossmatched_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get crossmatched event_type_cd"
    SET gsub_message =
    "could not retrieve crossmatched event_type_cd--code_set = 1610, cdf_meaning = 3"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET crossmatched_event_type_cd = gsub_code_value
   ENDIF
   CALL get_code_value(product_state_code_set,in_progress_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get in_progress event_type_cd"
    SET gsub_message =
    "could not retrieve in_progress event_type_cd--code_set = 1610, cdf_meaning = 16"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET in_progress_event_type_cd = gsub_code_value
   ENDIF
   CALL get_code_value(product_state_code_set,quarantined_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get quarantine event_type_cd"
    SET gsub_message =
    "could not retrieve quarantined event_type_cd--code_set = 1610, cdf_meaning = 2"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET quarantined_event_type_cd = gsub_code_value
   ENDIF
   CALL get_code_value(product_state_code_set,directed_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get directed event_type_cd"
    SET gsub_message = "could not retrieve directed event_type_cd--code_set = 1610, cdf_meaning = 11"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET directed_event_type_cd = gsub_code_value
   ENDIF
   CALL get_code_value(product_state_code_set,autologous_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get autologous event_type_cd"
    SET gsub_message =
    "could not retrieve autologous event_type_cd--code_set = 1610, cdf_meaning = 10"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET autologous_event_type_cd = gsub_code_value
   ENDIF
   CALL get_code_value(product_state_code_set,unconfirmed_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get unconfirmed event_type_cd"
    SET gsub_message =
    "could not retrieve unconfirmed event_type_cd--code_set = 1610, cdf_meaning = 9"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET unconfirmed_event_type_cd = gsub_code_value
   ENDIF
   CALL get_code_value(product_state_code_set,available_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get available event_type_cd"
    SET gsub_message =
    "could not retrieve available event_type_cd--code_set = 1610, cdf_meaning = 12"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET available_event_type_cd = gsub_code_value
   ENDIF
   CALL get_code_value(product_state_code_set,pooled_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get pooled event_type_cd"
    SET gsub_message = "could not retrieve pooled event_type_cd--code_set = 1610, cdf_meaning = 17"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET pooled_event_type_cd = gsub_code_value
   ENDIF
   CALL get_code_value(product_state_code_set,pooled_product_cdf_meaning)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get pooled_product event_type_cd"
    SET gsub_message =
    "could not retrieve pooled_product event_type_cd--code_set = 1610, cdf_meaning = 18"
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET pooled_product_event_type_cd = gsub_code_value
   ENDIF
 END ;Subroutine
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=sub_code_set
     AND cv.cdf_meaning=sub_cdf_meaning
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     gsub_code_value = cv.code_value
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE inactivateautodirectedevent(inactivateeventid)
   IF (inactivateeventid > 0.0)
    SELECT INTO "nl:"
     pe.product_event_id
     FROM product_event pe
     PLAN (pe
      WHERE pe.product_event_id=inactivateeventid
       AND pe.active_ind=1)
     WITH nocounter, forupdate(pe)
    ;end select
    IF (curqual != 0)
     SELECT INTO "nl:"
      ad.product_event_id
      FROM auto_directed ad
      PLAN (ad
       WHERE ad.product_event_id=inactivateeventid
        AND ad.active_ind=1)
      WITH nocounter, forupdate(ad)
     ;end select
    ENDIF
    IF (curqual=0)
     SET failed = "T"
     SET count1 = (count1+ 1)
     SET stat = alter(reply->status_data.subeventstatus,count1)
     SET reply->status_data.subeventstatus[count1].operationname = "Lock"
     SET reply->status_data.subeventstatus[count1].operationstatus = "F"
     SET reply->status_data.subeventstatus[count1].targetobjectname = "Product_Event, Auto_Directed"
     SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(inactivateeventid)
     GO TO exit_script
    ENDIF
    UPDATE  FROM product_event p
     SET p.active_ind = 0, p.active_status_cd = reqdata->inactive_status_cd, p.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      p.active_status_prsnl_id = reqinfo->updt_id, p.updt_id = reqinfo->updt_id, p.updt_cnt = (p
      .updt_cnt+ 1),
      p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     WHERE p.product_event_id=inactivateeventid
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET count1 = (count1+ 1)
     SET stat = alter(reply->status_data.subeventstatus,count1)
     SET reply->status_data.subeventstatus[count1].operationname = "Update"
     SET reply->status_data.subeventstatus[count1].operationstatus = "F"
     SET reply->status_data.subeventstatus[count1].targetobjectname = "Product_Event"
     SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(inactivateeventid)
     GO TO exit_script
    ELSE
     UPDATE  FROM auto_directed ad
      SET ad.active_ind = 0, ad.active_status_cd = reqdata->inactive_status_cd, ad
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       ad.active_status_prsnl_id = reqinfo->updt_id, ad.updt_id = reqinfo->updt_id, ad.updt_cnt = (ad
       .updt_cnt+ 1),
       ad.updt_task = reqinfo->updt_task, ad.updt_applctx = reqinfo->updt_applctx, ad.updt_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WHERE ad.product_event_id=inactivateeventid
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET count1 = (count1+ 1)
      SET stat = alter(reply->status_data.subeventstatus,count1)
      SET reply->status_data.subeventstatus[count1].operationname = "Update"
      SET reply->status_data.subeventstatus[count1].operationstatus = "F"
      SET reply->status_data.subeventstatus[count1].targetobjectname = "auto_directed"
      SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(inactivateeventid)
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE release_inactivate_crossmatch_pool(sub_dummy)
   DECLARE child_updt_cnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->pool_eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->pool_eventlist[event].updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock product_event forupdate",
     "product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    xm.product_event_id
    FROM crossmatch xm
    PLAN (xm
     WHERE (xm.product_event_id=request->pool_eventlist[event].product_event_id))
    DETAIL
     child_updt_cnt = xm.updt_cnt
    WITH nocounter, forupdate(xm)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock crossmatch forupdate",
     "crossmatch rows could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->pool_eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->
    pool_eventlist[event].updt_cnt,0,
    0)
   CALL process_product_event_status("inactivate",gsub_product_event_status,"crossmatched")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   SET release_dt_tm = cnvtdatetime(request->event_dt_tm)
   SET release_prsnl_id = request->event_prsnl_id
   SET release_reason_cd = 0.0
   SET release_qty = null
   CALL chg_crossmatch(request->pool_eventlist[event].product_event_id,child_updt_cnt,cnvtdatetime(
     release_dt_tm),release_prsnl_id,release_reason_cd,
    release_qty,0,reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id)
   IF (curqual=0)
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE release_inactivate_assign_pool(sub_dummy)
   DECLARE child_updt_cnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->pool_eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->pool_eventlist[event].updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock product_event forupdate",
     "product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    a.product_event_id
    FROM assign a
    PLAN (a
     WHERE (a.product_event_id=request->pool_eventlist[event].product_event_id))
    DETAIL
     child_updt_cnt = a.updt_cnt
    WITH nocounter, forupdate(a)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock assign forupdate","assign rows could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->pool_eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->
    pool_eventlist[event].updt_cnt,0,
    0)
   CALL process_product_event_status("inactivate",gsub_product_event_status,"assigned")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   CALL chg_assign(request->pool_eventlist[event].product_event_id,null,child_updt_cnt,0,reqdata->
    inactive_status_cd,
    cnvtdatetime(curdate,curtime3),reqinfo->updt_id," ")
   IF (curqual=0)
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ENDIF
   CALL add_assign_release(request->pool_eventlist[event].product_event_id,pooled_product_id,
    cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,request->pool_eventlist[event].
    reason_cd,
    null," ")
   IF (curqual=0)
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_unconfirmed_pool(product_event_id,pe_updt_cnt)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE pe.product_event_id=product_event_id)
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock unconfirmed product_event forupdate",
     "unconfirmed product_event row could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,pe_updt_cnt,0,
    0)
   CALL process_product_event_status("inactivate",gsub_product_event_status,"unconfirmed")
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE get_cdf_meaning(sub_code_set,sub_code_value)
  SET gsub_cdf_meaning = "            "
  SELECT INTO "nl:"
   cv.cdf_meaning
   FROM code_value cv
   WHERE cv.code_set=sub_code_set
    AND cv.code_value=sub_code_value
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   DETAIL
    gsub_cdf_meaning = cv.cdf_meaning
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE add_product_event_with_inventory_area_cd(sub_product_id,sub_person_id,sub_encntr_id,
  sub_order_id,sub_bb_result_id,sub_event_type_cd,sub_event_dt_tm,sub_event_prsnl_id,
  sub_event_status_flag,sub_override_ind,sub_override_reason_cd,sub_related_product_event_id,
  sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id,sub_locn_cd)
   CALL echo(build(" PRODUCT_ID - ",sub_product_id," PERSON_ID - ",sub_person_id," ENCNTR_ID - ",
     sub_encntr_id," SUB_RODER_ID - ",sub_order_id," BB_RESULT_ID - ",sub_bb_result_id,
     " EVENT_TYPE_ID - ",sub_event_type_cd," EVENT_DT_TM_ID - ",sub_event_dt_tm," PRSNL_ID - ",
     sub_event_prsnl_id," EVENT_STATUS_FLAG - ",sub_event_status_flag," override_ind - ",
     sub_override_ind,
     " override_reason_cd - ",sub_override_reason_cd," related_pe_id - ",sub_related_product_event_id,
     " active_ind - ",
     sub_active_ind," active_status_cd - ",sub_active_status_cd," active_status_dt_tm - ",
     sub_active_status_dt_tm,
     " status_prsnl_id - ",sub_active_status_prsnl_id," inventoy_area_cd - ",sub_locn_cd))
   SET gsub_product_event_status = "  "
   SET product_event_id = 0.0
   SET sub_product_event_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_product_event_status = "FS"
   ELSE
    SET sub_product_event_id = new_pathnet_seq
    INSERT  FROM product_event pe
     SET pe.product_event_id = sub_product_event_id, pe.product_id = sub_product_id, pe.person_id =
      IF (sub_person_id=null) 0
      ELSE sub_person_id
      ENDIF
      ,
      pe.encntr_id =
      IF (sub_encntr_id=null) 0
      ELSE sub_encntr_id
      ENDIF
      , pe.order_id =
      IF (sub_order_id=null) 0
      ELSE sub_order_id
      ENDIF
      , pe.bb_result_id = sub_bb_result_id,
      pe.event_type_cd = sub_event_type_cd, pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe
      .event_prsnl_id = sub_event_prsnl_id,
      pe.event_status_flag = sub_event_status_flag, pe.override_ind = sub_override_ind, pe
      .override_reason_cd = sub_override_reason_cd,
      pe.related_product_event_id = sub_related_product_event_id, pe.active_ind = sub_active_ind, pe
      .active_status_cd = sub_active_status_cd,
      pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
      sub_active_status_prsnl_id, pe.updt_cnt = 0,
      pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
      reqinfo->updt_task,
      pe.updt_applctx = reqinfo->updt_applctx, pe.event_tz =
      IF (curutc=1) curtimezoneapp
      ELSE 0
      ENDIF
      , pe.inventory_area_cd = sub_locn_cd
     WITH nocounter
    ;end insert
    SET product_event_id = sub_product_event_id
    SET new_product_event_id = sub_product_event_id
    IF (curqual=0)
     SET gsub_product_event_status = "FA"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_product_event(sub_product_id,sub_person_id,sub_encntr_id,sub_order_id,
  sub_bb_result_id,sub_event_type_cd,sub_event_dt_tm,sub_event_prsnl_id,sub_event_status_flag,
  sub_override_ind,sub_override_reason_cd,sub_related_product_event_id,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
   SET gsub_product_event_status = "  "
   SET product_event_id = 0.0
   SET sub_product_event_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_product_event_status = "FS"
   ELSE
    SET sub_product_event_id = new_pathnet_seq
    INSERT  FROM product_event pe
     SET pe.product_event_id = sub_product_event_id, pe.product_id = sub_product_id, pe.person_id =
      IF (sub_person_id=null) 0
      ELSE sub_person_id
      ENDIF
      ,
      pe.encntr_id =
      IF (sub_encntr_id=null) 0
      ELSE sub_encntr_id
      ENDIF
      , pe.order_id =
      IF (sub_order_id=null) 0
      ELSE sub_order_id
      ENDIF
      , pe.bb_result_id = sub_bb_result_id,
      pe.event_type_cd = sub_event_type_cd, pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe
      .event_prsnl_id = sub_event_prsnl_id,
      pe.event_status_flag = sub_event_status_flag, pe.override_ind = sub_override_ind, pe
      .override_reason_cd = sub_override_reason_cd,
      pe.related_product_event_id = sub_related_product_event_id, pe.active_ind = sub_active_ind, pe
      .active_status_cd = sub_active_status_cd,
      pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
      sub_active_status_prsnl_id, pe.updt_cnt = 0,
      pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
      reqinfo->updt_task,
      pe.updt_applctx = reqinfo->updt_applctx, pe.event_tz =
      IF (curutc=1) curtimezoneapp
      ELSE 0
      ENDIF
     WITH nocounter
    ;end insert
    SET product_event_id = sub_product_event_id
    SET new_product_event_id = sub_product_event_id
    IF (curqual=0)
     SET gsub_product_event_status = "FA"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
   SET new_product_event_id = product_event_id
 END ;Subroutine
 SUBROUTINE chg_product_event(sub_product_event_id,sub_event_dt_tm,sub_event_prsnl_id,
  sub_event_status_flag,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id,sub_updt_cnt,sub_lock_forupdate_ind,sub_updt_dt_tm_prsnl_ind)
   SET gsub_product_event_status = "  "
   IF (sub_lock_forupdate_ind=1)
    SELECT INTO "nl:"
     pe.product_event_id
     FROM product_event pe
     WHERE pe.product_event_id=sub_product_event_id
      AND pe.updt_cnt=sub_updt_cnt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET gsub_product_event_status = "FL"
    ENDIF
   ENDIF
   IF (((sub_lock_forupdate_ind=0) OR (sub_lock_forupdate_ind=1
    AND curqual > 0)) )
    IF (sub_updt_dt_tm_prsnl_ind=1)
     UPDATE  FROM product_event pe
      SET pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe.event_prsnl_id = sub_event_prsnl_id, pe
       .event_status_flag = sub_event_status_flag,
       pe.active_ind = sub_active_ind, pe.active_status_cd = sub_active_status_cd, pe
       .active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm),
       pe.active_status_prsnl_id = sub_active_status_prsnl_id, pe.updt_cnt = (pe.updt_cnt+ 1), pe
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
       updt_applctx
      WHERE pe.product_event_id=sub_product_event_id
       AND pe.updt_cnt=sub_updt_cnt
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM product_event pe
      SET pe.event_status_flag = sub_event_status_flag, pe.active_ind = sub_active_ind, pe
       .active_status_cd = sub_active_status_cd,
       pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
       sub_active_status_prsnl_id, pe.updt_cnt = (pe.updt_cnt+ 1),
       pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
       reqinfo->updt_task,
       pe.updt_applctx = reqinfo->updt_applctx
      WHERE pe.product_event_id=sub_product_event_id
       AND pe.updt_cnt=sub_updt_cnt
      WITH nocounter
     ;end update
    ENDIF
    IF (curqual=0)
     SET gsub_product_event_status = "FU"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_pooled_product(sub_product_event_id,sub_product_id,sub_method_cd,
  sub_method_cdf_meaning,sub_box_nbr,sub_manifest_nbr,sub_destroyed_qty,sub_autoclave_ind,
  sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
  INSERT  FROM destruction dst
   SET dst.product_event_id = sub_product_event_id, dst.product_id = sub_product_id, dst.method_cd =
    sub_method_cd,
    dst.box_nbr = trim(cnvtupper(sub_box_nbr)), dst.manifest_nbr = sub_manifest_nbr, dst
    .destroyed_qty = sub_destroyed_qty,
    dst.autoclave_ind =
    IF (sub_method_cdf_meaning="DESTNOW") sub_autoclave_ind
    ELSE null
    ENDIF
    , dst.destruction_org_id = null, dst.active_ind = sub_active_ind,
    dst.active_status_cd = sub_active_status_cd, dst.active_status_dt_tm = cnvtdatetime(
     sub_active_status_dt_tm), dst.active_status_prsnl_id = sub_active_status_prsnl_id,
    dst.updt_cnt = 0, dst.updt_dt_tm = cnvtdatetime(curdate,curtime3), dst.updt_id = reqinfo->updt_id,
    dst.updt_task = reqinfo->updt_task, dst.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "create destruction row"
   SET gsub_message = "destruction row could not be created"
  ENDIF
 END ;Subroutine
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->status_data.status = sub_status
   SET count1 = (count1+ 1)
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,count1)
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = sub_process
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_status
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_add_pooled_product"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
 SUBROUTINE set_new_active_status(sub_derivative_ind,sub_cur_qty,sub_select_qty)
   SET gsub_status = "F"
   SET new_cur_qty = 0
   SET gsub_active_status_cd = reqdata->inactive_status_cd
   SET gsub_active_ind = 0
   IF (sub_derivative_ind="Y")
    IF (sub_select_qty > sub_cur_qty)
     SET gsub_status = "F"
    ELSE
     SET gsub_status = "S"
     SET new_cur_qty = (sub_cur_qty - sub_select_qty)
     IF (new_cur_qty > 0)
      SET gsub_active_status_cd = reqdata->active_status_cd
      SET gsub_active_ind = 1
     ENDIF
    ENDIF
   ELSE
    SET gsub_status = "S"
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
