CREATE PROGRAM bbt_add_pat_dispense:dba
 RECORD reply(
   1 productlist[*]
     2 product_id = f8
     2 product_event_id = f8
     2 assign_event_id = f8
     2 status_flag = c1
     2 updt_cnt = i4
     2 interface_status_flag = i2
     2 dispense_event_id = f8
   1 bb_comment_changed = c1
   1 pat_aborh_changed = c1
   1 trans_req_changed = c1
   1 antibodies_changed = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD outbound_products(
   1 product_cnt = i4
   1 message_name = vc
   1 products[*]
     2 product_id = f8
     2 device_id = f8
     2 person_id = f8
 )
 DECLARE nbr_to_add = i4 WITH noconstant(size(request->productlist,5))
 DECLARE code_cnt = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE count2 = i4 WITH noconstant(0)
 DECLARE count3 = i4 WITH noconstant(0)
 DECLARE cntr = i4 WITH noconstant(0)
 DECLARE reqs_cntr = i4 WITH noconstant(0)
 DECLARE cntrnbr_of_excepts = i4 WITH noconstant(0)
 DECLARE autodir_reqs_cntr = i4 WITH noconstant(0)
 DECLARE nbr_of_reqs = i4 WITH noconstant(0)
 DECLARE nbr_of_autodir_reqs = i4 WITH noconstant(0)
 DECLARE event_id = f8 WITH noconstant(0.0)
 DECLARE product_event_id = f8 WITH noconstant(0.0)
 DECLARE new_product_event_id = f8 WITH noconstant(0.0)
 DECLARE dispense_type_cd = f8 WITH noconstant(0.0)
 DECLARE transfer_type_cd = f8 WITH noconstant(0.0)
 DECLARE avail_type_cd = f8 WITH noconstant(0.0)
 DECLARE xm_type_cd = f8 WITH noconstant(0.0)
 DECLARE assign_type_cd = f8 WITH noconstant(0.0)
 DECLARE quarantine_type_cd = f8 WITH noconstant(0.0)
 DECLARE release_status = c1 WITH noconstant(fillstring(1," "))
 DECLARE assign_status = c1 WITH noconstant(fillstring(1," "))
 DECLARE exception_status = c1 WITH noconstant(fillstring(1," "))
 DECLARE unlock_status = c1 WITH noconstant(fillstring(1," "))
 DECLARE assign_event_id = f8 WITH noconstant(0.0)
 DECLARE dispense_event_id = f8 WITH noconstant(0.0)
 DECLARE related_event_id = f8 WITH noconstant(0.0)
 DECLARE bb_exception_id = f8 WITH noconstant(0.0)
 DECLARE inactive_avail = i2 WITH noconstant(0)
 DECLARE override_ind = i2 WITH noconstant(0)
 DECLARE nextrow = i4 WITH noconstant(1)
 DECLARE cur_qty = i4 WITH noconstant(0)
 DECLARE cur_ius = i4 WITH noconstant(0)
 DECLARE states_code_set = i4 WITH constant(1610)
 DECLARE cdf_meaning = c12 WITH noconstant(fillstring(12," "))
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE interface_status_flag = i2 WITH noconstant(0)
 DECLARE interfaced_device_ind = i2 WITH noconstant(0)
 DECLARE valid_aborh_ind = i2 WITH noconstant(0)
 DECLARE transfer_allocated_reason_cd = f8 WITH noconstant(0.0)
 DECLARE disp_prov_id = f8 WITH noconstant(0.0)
 DECLARE order_id = f8 WITH noconstant(0.0)
 DECLARE modifyassignqty_ind = i2 WITH noconstant(0)
 DECLARE dispense_device_id = f8 WITH noconstant(0.0)
 DECLARE insert_assignrelease_event(drelprod_id=f8,drelevent_id=f8,drelreason_cd=f8) = null
 DECLARE sendreservestockmessage(null) = null
 DECLARE settransferallocatedreasoncd(null) = null
 SET reply->status_data.status = "I"
 SET reply->bb_comment_changed = "F"
 SET reply->pat_aborh_changed = "F"
 SET reply->trans_req_changed = "F"
 SET reply->antibodies_changed = "F"
 IF ((request->unknown_patient_ind=0))
  RECORD trans_req_rec(
    1 reqs[*]
      2 requirement_cd = f8
  )
  RECORD antibody_rec(
    1 antibody[*]
      2 antibody_cd = f8
  )
  SET sub_bb_comment_changed_error = fillstring(255," ")
  SET sub_bb_comment_changed = fillstring(1," ")
  SET sub_bb_comment_changed = "F"
  SET sub_pat_aborh_changed_error = fillstring(255," ")
  SET sub_pat_aborh_changed = fillstring(1," ")
  SET sub_pat_aborh_changed = "F"
  SET sub_trans_req_changed_error = fillstring(255," ")
  SET sub_trans_req_changed = fillstring(1," ")
  SET sub_trans_req_changed = "F"
  SET sub_antibodies_changed_error = fillstring(255," ")
  SET sub_antibodies_changed = fillstring(1," ")
  SET sub_antibodies_changed = "F"
  SUBROUTINE check_patient_demographics(sub_dummy)
    SET serrormsg = fillstring(255," ")
    SET nerrorstatus = error(serrormsg,1)
    SET check_bb_comment_id = 0.0
    SET check_bb_comment_updt_cnt = 0
    SELECT INTO "nl:"
     b.*
     FROM blood_bank_comment b
     PLAN (b
      WHERE (b.person_id=request->person_id)
       AND b.active_ind=1)
     DETAIL
      check_bb_comment_id = b.bb_comment_id, check_bb_comment_updt_cnt = b.updt_cnt
     WITH nocounter, forupdate(b)
    ;end select
    SET nerrorstatus = error(serrormsg,0)
    IF (nerrorstatus=0)
     IF (curqual < 1)
      IF ((((check_bb_comment_id != request->bb_comment_id)) OR ((check_bb_comment_updt_cnt !=
      request->bb_comment_updt_cnt))) )
       SET sub_bb_comment_changed = "T"
      ENDIF
     ELSE
      IF ((((check_bb_comment_id != request->bb_comment_id)) OR ((check_bb_comment_updt_cnt !=
      request->bb_comment_updt_cnt))) )
       SET sub_bb_comment_changed = "T"
      ENDIF
     ENDIF
    ELSE
     SET sub_bb_comment_changed_error = serrormsg
     SET sub_bb_comment_changed = "E"
    ENDIF
    SET serrormsg = fillstring(255," ")
    SET nerrorstatus = error(serrormsg,1)
    SET check_abo_cd = 0.0
    SET check_rh_cd = 0.0
    SELECT INTO "nl:"
     p.*
     FROM person_aborh p
     PLAN (p
      WHERE (p.person_id=request->person_id)
       AND p.active_ind=1)
     DETAIL
      check_abo_cd = p.abo_cd, check_rh_cd = p.rh_cd
     WITH nocounter, forupdate(p)
    ;end select
    SET nerrorstatus = error(serrormsg,0)
    IF (nerrorstatus=0)
     IF (curqual < 1)
      IF ((((check_abo_cd != request->abo_cd)) OR ((check_rh_cd != request->rh_cd))) )
       SET sub_pat_aborh_changed = "T"
      ENDIF
     ELSE
      IF ((((check_abo_cd != request->abo_cd)) OR ((check_rh_cd != request->rh_cd))) )
       SET sub_pat_aborh_changed = "T"
      ENDIF
     ENDIF
    ELSE
     SET sub_pat_aborh_changed_error = serrormsg
     SET sub_pat_aborh_changed = "E"
    ENDIF
    SET serrormsg = fillstring(255," ")
    SET nerrorstatus = error(serrormsg,1)
    SET trans_cnt = 0
    SELECT INTO "nl:"
     p.*
     FROM person_trans_req p
     PLAN (p
      WHERE (p.person_id=request->person_id)
       AND p.active_ind=1)
     DETAIL
      trans_cnt += 1, stat = alterlist(trans_req_rec->reqs,trans_cnt), trans_req_rec->reqs[trans_cnt]
      .requirement_cd = p.requirement_cd
     WITH nocounter, forupdate(p)
    ;end select
    SET nerrorstatus = error(serrormsg,0)
    IF (nerrorstatus=0)
     SET trans_req_changed = "F"
     SET bfound = "F"
     SET trans_now_cnt = size(trans_req_rec->reqs,5)
     SET trans_before_cnt = size(request->transreqlist,5)
     IF (trans_now_cnt=0
      AND trans_before_cnt=0)
      SET trans_req_changed = "F"
     ELSE
      FOR (n = 1 TO trans_now_cnt)
        SET bfound = "F"
        FOR (b = 1 TO trans_before_cnt)
          IF ((trans_req_rec->reqs[n].requirement_cd=request->transreqlist[b].requirement_cd))
           SET bfound = "T"
           SET b = trans_before_cnt
          ENDIF
        ENDFOR
        IF (bfound="F")
         SET trans_req_changed = "T"
         SET n = trans_now_cnt
        ENDIF
      ENDFOR
     ENDIF
     IF (trans_req_changed="T")
      SET sub_trans_req_changed = "T"
     ENDIF
    ELSE
     SET sub_pat_aborh_changed_error = serrormsg
     SET sub_pat_aborh_changed = "E"
    ENDIF
    SET serrormsg = fillstring(255," ")
    SET nerrorstatus = error(serrormsg,1)
    SET anti_cnt = 0
    SELECT INTO "nl:"
     p.*
     FROM person_antibody p
     PLAN (p
      WHERE (p.person_id=request->person_id)
       AND p.active_ind=1)
     ORDER BY p.antibody_cd
     HEAD p.antibody_cd
      anti_cnt += 1, stat = alterlist(antibody_rec->antibody,anti_cnt), antibody_rec->antibody[
      anti_cnt].antibody_cd = p.antibody_cd
     WITH nocounter, forupdate(p)
    ;end select
    SET nerrorstatus = error(serrormsg,0)
    IF (nerrorstatus=0)
     SET antibody_changed = "F"
     SET bfound = "F"
     SET antibody_now_cnt = size(antibody_rec->antibody,5)
     SET antibody_before_cnt = size(request->antibodylist,5)
     IF (antibody_now_cnt=0
      AND antibody_before_cnt=0)
      SET antibody_changed = "F"
     ELSEIF (antibody_now_cnt != antibody_before_cnt)
      SET antibody_changed = "T"
     ELSE
      FOR (n = 1 TO antibody_now_cnt)
        SET bfound = "F"
        FOR (b = 1 TO antibody_before_cnt)
          IF ((antibody_rec->antibody[n].antibody_cd=request->antibodylist[b].antibody_cd))
           SET bfound = "T"
           SET b = antibody_before_cnt
          ENDIF
        ENDFOR
        IF (bfound="F")
         SET antibody_changed = "T"
         SET n = antibody_now_cnt
        ENDIF
      ENDFOR
     ENDIF
     IF (antibody_changed="T")
      SET sub_antibodies_changed = "T"
     ENDIF
    ELSE
     SET sub_pat_aborh_changed_error = serrormsg
     SET sub_pat_aborh_changed = "E"
    ENDIF
  END ;Subroutine
  CALL check_patient_demographics(0)
  IF (sub_bb_comment_changed="E")
   CALL update_status_data_err(sub_bb_comment_changed_error)
   SET reply->bb_comment_changed = "T"
   GO TO exit_program
  ENDIF
  IF (sub_pat_aborh_changed="E")
   CALL update_status_data_err(sub_pat_aborh_changed_error)
   SET reply->pat_aborh_changed = "T"
   GO TO exit_program
  ENDIF
  IF (sub_trans_req_changed="E")
   CALL update_status_data_err(sub_trans_req_changed_error)
   SET reply->trans_req_changed = "T"
   GO TO exit_program
  ENDIF
  IF (sub_antibodies_changed="E")
   CALL update_status_data_err(sub_antibodies_changed_error)
   SET reply->antibodies_changed = "T"
   GO TO exit_program
  ENDIF
  IF (sub_bb_comment_changed="T")
   SET reply->bb_comment_changed = "T"
   SET reply->status_data.status = "Z"
   GO TO exit_program
  ENDIF
  IF (sub_pat_aborh_changed="T")
   SET reply->pat_aborh_changed = "T"
   SET reply->status_data.status = "Z"
   GO TO exit_program
  ENDIF
  IF (sub_trans_req_changed="T")
   SET reply->trans_req_changed = "T"
   SET reply->status_data.status = "Z"
   GO TO exit_program
  ENDIF
  IF (sub_antibodies_changed="T")
   SET reply->antibodies_changed = "T"
   SET reply->status_data.status = "Z"
   GO TO exit_program
  ENDIF
 ENDIF
 SET code_cnt = 1
 SET cdf_meaning = "4"
 SET stat = uar_get_meaning_by_codeset(states_code_set,cdf_meaning,code_cnt,dispense_type_cd)
 IF (stat != 0)
  CALL update_status_data_err("Unable to obtain code value for dispensed, code set 1610.")
  GO TO exit_program
 ENDIF
 SET ev_dt_tm = cnvtdatetime(request->dispense_dt_tm)
 SET code_cnt = 1
 SET cdf_meaning = "12"
 SET stat = uar_get_meaning_by_codeset(states_code_set,cdf_meaning,code_cnt,avail_type_cd)
 IF (stat != 0)
  CALL update_status_data_err("Unable to obtain code value for available, code set 1610.")
  GO TO exit_program
 ENDIF
 SET code_cnt = 1
 SET cdf_meaning = "3"
 SET stat = uar_get_meaning_by_codeset(states_code_set,cdf_meaning,code_cnt,xm_type_cd)
 IF (stat != 0)
  CALL update_status_data_err("Unable to obtain code value for crossmatched, code set 1610.")
  GO TO exit_program
 ENDIF
 SET code_cnt = 1
 SET cdf_meaning = "1"
 SET stat = uar_get_meaning_by_codeset(states_code_set,cdf_meaning,code_cnt,assign_type_cd)
 IF (stat != 0)
  CALL update_status_data_err("Unable to obtain code value for assigned, code set 1610.")
  GO TO exit_program
 ENDIF
 SET code_cnt = 1
 SET cdf_meaning = "2"
 SET stat = uar_get_meaning_by_codeset(states_code_set,cdf_meaning,code_cnt,quarantine_type_cd)
 IF (stat != 0)
  CALL update_status_data_err("Unable to obtain code value for quarantined, code set 1610.")
  GO TO exit_program
 ENDIF
 SET code_cnt = 1
 SET cdf_meaning = "6"
 SET stat = uar_get_meaning_by_codeset(states_code_set,cdf_meaning,code_cnt,transfer_type_cd)
 IF (stat != 0)
  CALL update_status_data_err("Unable to obtain code value for transferred, code set 1610.")
  GO TO exit_program
 ENDIF
 CALL settransferallocatedreasoncd(null)
 IF ((request->device_id > 0))
  SET dispense_device_id = request->device_id
 ELSEIF ((request->dispense_cooler_id > 0))
  SET dispense_device_id = request->dispense_cooler_id
 ENDIF
 IF ((request->unknown_patient_ind=0))
  SET interfaced_device_ind = getinterfaceflag(dispense_device_id)
  IF ((request->abo_cd > 0)
   AND (request->rh_cd > 0))
   SET valid_aborh_ind = 1
  ENDIF
 ENDIF
#start_loop
 FOR (x = nextrow TO nbr_to_add)
   SET lock_status = "I"
   CALL lock_product(request->productlist[x].product_id)
   IF (lock_status="F")
    GO TO next_row
   ENDIF
   SET modifyassignqty_ind = 0
   IF ((request->productlist[x].order_id > 0))
    SET order_id = request->productlist[x].order_id
   ELSEIF ((request->order_id > 0))
    SET order_id = request->order_id
   ELSE
    SET order_id = 0.0
   ENDIF
   IF ((request->productlist[x].dispense_prov_id > 0))
    SET disp_prov_id = request->productlist[x].dispense_prov_id
   ELSEIF ((request->dispense_prov_id > 0))
    SET disp_prov_id = request->dispense_prov_id
   ELSE
    SET disp_prov_id = 0.0
   ENDIF
   IF ((request->quar_reason_cd > 0))
    CALL update_status_data_err(
     "The quarantine reason code value was greater than zero.  Please investigate.")
    GO TO next_row
   ENDIF
   SET assign_event_id = 0.0
   SET dispense_event_id = 0.0
   IF ((request->productlist[x].add_assign_ind=1))
    SET assign_status = "I"
    CALL add_assign(request->productlist[x].product_id,request->person_id,request->encntr_id,request
     ->dispense_reason_cd,disp_prov_id,
     request->productlist[x].dispense_qty,request->productlist[x].dispense_intl_units,reqinfo->
     updt_id,reqinfo->updt_task,reqinfo->updt_applctx,
     reqdata->active_status_cd,reqinfo->updt_id,ev_dt_tm)
    IF (assign_status != "S")
     CALL update_status_data_err("Unable to add assign.")
     GO TO next_row
    ENDIF
   ENDIF
   IF ((request->productlist[x].related_event_id=0))
    SET related_event_id = assign_event_id
   ELSE
    SET related_event_id = request->productlist[x].related_event_id
   ENDIF
   SET inactive_avail = 1
   SET dispense_event_id = 0.0
   IF ((request->productlist[x].dispense_qty > 0))
    SET release_status = "I"
    IF ((request->productlist[x].modassigneventid > 0))
     CALL modifyassignqty(request->productlist[x].product_id,request->productlist[x].modassigneventid,
      request->productlist[x].modassignupdtcnt,request->productlist[x].dispense_qty,request->
      productlist[x].dispense_intl_units)
    ELSE
     CALL updateavailableqty(request->productlist[x].product_id,request->productlist[x].der_updt_cnt,
      request->productlist[x].dispense_qty,request->productlist[x].dispense_intl_units)
    ENDIF
    IF (release_status != "S")
     CALL update_status_data_err("Unable to update quantity.")
     GO TO next_row
    ENDIF
   ENDIF
   IF (inactive_avail=1)
    SELECT INTO "nl:"
     p.seq
     FROM product_event p
     WHERE (p.product_id=request->productlist[x].product_id)
      AND p.event_type_cd=avail_type_cd
      AND p.active_ind=1
     WITH nocounter, forupdate(p)
    ;end select
    IF (curqual=0)
     CALL update_status_data_err("Unable to lock product_event table for updating.")
    ENDIF
    UPDATE  FROM product_event p
     SET p.active_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
      p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
      updt_applctx
     WHERE (p.product_id=request->productlist[x].product_id)
      AND p.event_type_cd=avail_type_cd
      AND p.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL update_status_data_err("Unable to inactivate the available product event.")
    ENDIF
   ENDIF
   SET y = 0
   FOR (y = 1 TO request->productlist[x].event_cnt)
     SET release_status = "I"
     IF ((request->productlist[x].eventlist[y].xm_ind=1))
      CALL releasecrossmatch(request->productlist[x].product_id,request->productlist[x].eventlist[y].
       event_id,request->productlist[x].eventlist[y].reason_cd,request->productlist[x].eventlist[y].
       updt_cnt,request->productlist[x].eventlist[y].pe_updt_cnt)
     ELSEIF ((request->productlist[x].eventlist[y].assign_ind=1))
      CALL releaseassign(request->productlist[x].product_id,request->productlist[x].eventlist[y].
       event_id,request->productlist[x].eventlist[y].reason_cd,request->productlist[x].eventlist[y].
       updt_cnt,request->productlist[x].eventlist[y].pe_updt_cnt,
       request->productlist[x].dispense_qty,request->productlist[x].dispense_intl_units)
     ELSEIF ((request->productlist[x].eventlist[y].inprog_ind=1))
      CALL releaseinprogress(request->productlist[x].product_id,request->productlist[x].eventlist[y].
       event_id,request->productlist[x].eventlist[y].reason_cd,request->productlist[x].eventlist[y].
       updt_cnt,request->productlist[x].eventlist[y].pe_updt_cnt)
     ELSE
      SET release_status = "F"
     ENDIF
     IF (release_status="F")
      CALL update_status_data_err("Unable to add a product event.")
      GO TO next_row
     ENDIF
   ENDFOR
   IF ((request->productlist[x].except_cnt > 0))
    SET override_ind = 1
   ELSE
    SET override_ind = 0
   ENDIF
   CALL add_product_event(request->productlist[x].product_id,request->person_id,request->encntr_id,
    order_id,0,
    dispense_type_cd,ev_dt_tm,reqinfo->updt_id,0,override_ind,
    0,related_event_id,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
    reqinfo->updt_id)
   IF (curqual=0)
    CALL update_status_data_err("Unable to add a dispense product event.")
    GO TO next_row
   ENDIF
   SET dispense_event_id = product_event_id
   INSERT  FROM patient_dispense d
    SET d.product_event_id = dispense_event_id, d.person_id = request->person_id, d.bb_id_nbr =
     request->bb_id_nbr,
     d.unknown_patient_ind = request->unknown_patient_ind, d.unknown_patient_text = request->
     unknown_patient_text, d.dispense_prov_id = disp_prov_id,
     d.dispense_reason_cd = request->dispense_reason_cd, d.dispense_to_locn_cd = request->
     dispense_to_locn_cd, d.dispense_vis_insp_cd = request->dispense_vis_insp_cd,
     d.dispense_cooler_id = request->dispense_cooler_id, d.dispense_cooler_text = request->
     dispense_cooler_text, d.dispense_courier_id = request->courier_id,
     d.dispense_courier_text = request->courier_text, d.device_id = request->device_id, d
     .tag_verify_flag = request->productlist[x].tag_verify_flag,
     d.dispense_status_flag = 1, d.product_id = request->productlist[x].product_id, d
     .dispense_from_locn_cd = request->productlist[x].dispense_from_locn_cd,
     d.orig_dispense_qty = request->productlist[x].dispense_qty, d.cur_dispense_qty = request->
     productlist[x].dispense_qty, d.cur_dispense_intl_units = request->productlist[x].
     dispense_intl_units,
     d.orig_dispense_intl_units = request->productlist[x].dispense_intl_units, d.updt_cnt = 0, d
     .updt_dt_tm = cnvtdatetime(sysdate),
     d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
     updt_applctx,
     d.active_ind = 1, d.active_status_cd = reqdata->active_status_cd, d.active_status_dt_tm =
     cnvtdatetime(sysdate),
     d.active_status_prsnl_id = reqinfo->updt_id, d.backdated_on_dt_tm =
     IF ((request->backdated_ind=1)) cnvtdatetime(sysdate)
     ELSE null
     ENDIF
    WITH counter
   ;end insert
   IF (curqual=0)
    CALL update_status_data_err("Unable to add patient dispense.")
    GO TO next_row
   ENDIF
   SET nbr_of_excepts = request->productlist[x].except_cnt
   SET cntr = 0
   FOR (cntr = 1 TO nbr_of_excepts)
     SET exception_status = "I"
     SET bb_exception_id = 0.0
     CALL add_bb_exception(0.0,0.0,0.0,cnvtdatetime(""),product_event_id,
      request->productlist[x].exceptlist[cntr].exception_type_mean,request->productlist[x].
      exceptlist[cntr].override_reason_cd,dispense_type_cd,request->productlist[x].exceptlist[cntr].
      result_id,0,
      request->productlist[x].exceptlist[cntr].from_abo_cd,request->productlist[x].exceptlist[cntr].
      from_rh_cd,request->productlist[x].exceptlist[cntr].to_abo_cd,request->productlist[x].
      exceptlist[cntr].to_rh_cd,0.0)
     IF (exception_status != "S")
      CALL update_status_data_err("Unable to add exception.")
      GO TO next_row
     ENDIF
     IF (trim(request->productlist[x].exceptlist[cntr].exception_type_mean)="TAGMISMATCH")
      CALL add_tag_mismatch_exception(request->productlist[x].exceptlist[cntr].tag_product_num,
       request->productlist[x].exceptlist[cntr].tag_div_chars,request->productlist[x].exceptlist[cntr
       ].tag_product_type_cd)
      IF (exception_status != "S")
       CALL update_status_data_err("Unable to add BB_TAG_VERIFY_EXCPN.")
       GO TO next_row
      ENDIF
     ENDIF
     IF (trim(request->productlist[x].exceptlist[cntr].exception_type_mean)="NOVLDPRODORD")
      CALL add_invd_prod_ord_exception(request->productlist[x].exceptlist[cntr].order_id)
      IF (exception_status != "S")
       CALL update_status_data_err("Unable to add bb_invd_prod_order_exception.")
       GO TO next_row
      ENDIF
     ENDIF
     SET reqs_cntr = 0
     SET nbr_of_reqs = request->productlist[x].exceptlist[cntr].req_cnt
     FOR (reqs_cntr = 1 TO nbr_of_reqs)
       SET exception_status = "I"
       CALL add_reqs_exception(request->productlist[x].exceptlist[cntr].reqslist[reqs_cntr].
        special_testing_cd,request->productlist[x].exceptlist[cntr].reqslist[reqs_cntr].
        requirement_cd)
       IF (exception_status != "S")
        CALL update_status_data_err("Unable to add bb_reqs_exception.")
        GO TO next_row
       ENDIF
     ENDFOR
     SET autodir_reqs_cntr = 0
     SET nbr_of_autodir_reqs = request->productlist[x].exceptlist[cntr].autodir_req_cnt
     FOR (autodir_reqs_cntr = 1 TO nbr_of_autodir_reqs)
       SET exception_status = "I"
       CALL add_autodir_reqs_exception(request->productlist[x].exceptlist[cntr].autodir_reqslist[
        autodir_reqs_cntr].product_id)
       IF (exception_status != "S")
        CALL update_status_data_err("Unable to add bb_autodir_exception.")
        GO TO next_row
       ENDIF
     ENDFOR
   ENDFOR
   SET interface_status_flag = 0
   IF (interfaced_device_ind > 0)
    IF (isderivative(request->productlist[x].product_id)=0)
     IF (valid_aborh_ind > 0)
      IF (size(getproducttypebarcode(request->productlist[x].product_id),1) > 0)
       SET interface_status_flag = 1
      ELSE
       SET interface_status_flag = - (2)
      ENDIF
     ELSE
      SET interface_status_flag = - (1)
     ENDIF
    ENDIF
   ENDIF
   IF (interface_status_flag=1)
    CALL add_product_to_outbound(request->productlist[x].product_id,request->person_id,
     dispense_device_id)
   ENDIF
   SET unlock_status = "I"
   CALL unlock_product(request->productlist[x].product_id,request->dispense_to_locn_cd,reqinfo->
    updt_id,reqinfo->updt_task,reqinfo->updt_applctx)
   IF (unlock_status="S")
    CALL update_status_data_success(request->productlist[x].product_id,product_event_id,
     assign_event_id,interface_status_flag,dispense_event_id)
   ELSE
    GO TO next_row
   ENDIF
 ENDFOR
 IF ((outbound_products->product_cnt > 0))
  CALL sendreservestockmessage(null)
 ENDIF
 GO TO exit_program
#next_row
 SET nextrow += 1
 GO TO start_loop
 SUBROUTINE (isderivative(dproductid=f8) =i2)
   DECLARE nisderivative = i2 WITH noconstant(0)
   SELECT
    d.product_id
    FROM derivative d
    WHERE d.product_id=dproductid
   ;end select
   IF (curqual > 0)
    SET nisderivative = 1
   ENDIF
   RETURN(nisderivative)
 END ;Subroutine
 SUBROUTINE (add_product_to_outbound(dproductid=f8,dpersonid=f8,ddeviceid=f8) =null)
   DECLARE pcnt = i4 WITH noconstant(0)
   DECLARE transfer_product_event_id = f8 WITH noconstant(0.0)
   CALL add_product_event(dproductid,null,null,null,0,
    transfer_type_cd,cnvtdatetime(sysdate),reqinfo->updt_id,0,0,
    0,0,0,reqdata->inactive_status_cd,cnvtdatetime(sysdate),
    reqinfo->updt_id)
   IF (curqual=0)
    CALL update_status_data_err("Unable to add a Transfer Event.")
   ENDIF
   SET transfer_product_event_id = product_event_id
   CALL add_device_transfer(transfer_product_event_id,dproductid,ddeviceid)
   IF (curqual=0)
    CALL update_status_data_err("Unable to add a Device Transfer Row.")
   ENDIF
   SET pcnt = (outbound_products->product_cnt+ 1)
   IF (pcnt > size(outbound_products->products,5))
    SET stat = alterlist(outbound_products->products,(pcnt+ 5))
   ENDIF
   SET outbound_products->product_cnt = pcnt
   SET outbound_products->products[pcnt].device_id = ddeviceid
   SET outbound_products->products[pcnt].product_id = dproductid
   SET outbound_products->products[pcnt].person_id = dpersonid
 END ;Subroutine
 SUBROUTINE sendreservestockmessage(null)
   SET outbound_products->message_name = "RS"
   SET stat = alterlist(outbound_products->products,outbound_products->product_cnt)
   CALL echorecord(outbound_products)
   EXECUTE bbt_send_products_outbound  WITH replace("REQUEST","OUTBOUND_PRODUCTS"), replace("REPLY",
    "RS_REPLY")
 END ;Subroutine
 SUBROUTINE settransferallocatedreasoncd(null)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=1617
     AND cv.cdf_meaning="TRNSFRALLO"
    ORDER BY cv.code_value
    DETAIL
     transfer_allocated_reason_cd = cv.code_value
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (add_device_transfer(deventid=f8,dproductid=f8,ddeviceid=f8) =null)
   INSERT  FROM bb_device_transfer bd
    SET bd.product_event_id = deventid, bd.product_id = dproductid, bd.from_device_id = 0,
     bd.to_device_id = ddeviceid, bd.reason_cd = transfer_allocated_reason_cd, bd.updt_cnt = 0,
     bd.updt_dt_tm = cnvtdatetime(sysdate), bd.updt_id = reqinfo->updt_id, bd.updt_task = reqinfo->
     updt_task,
     bd.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE (getinterfaceflag(ddeviceid=f8) =i2)
   DECLARE interface_flag = i2 WITH noconstant(0)
   SELECT
    bbid.interface_flag
    FROM bb_inv_device bbid
    WHERE bbid.bb_inv_device_id=ddeviceid
    DETAIL
     interface_flag = bbid.interface_flag
    WITH nocounter
   ;end select
   RETURN(interface_flag)
 END ;Subroutine
 SUBROUTINE (getproducttypebarcode(dproductid=f8) =vc)
   DECLARE barcode = vc WITH noconstant("")
   SELECT
    p.product_type_barcode
    FROM product p
    WHERE p.product_id=dproductid
    DETAIL
     barcode = p.product_type_barcode
    WITH nocounter
   ;end select
   RETURN(trim(barcode))
 END ;Subroutine
 SUBROUTINE (updateavailableqty(dupd_prod_id=f8,der_updt_cnt=i4,lqty=i4,lius=i4) =null)
   SET cur_qty = 0
   SET cur_ius = 0
   SELECT INTO "nl:"
    d.seq
    FROM derivative d
    PLAN (d
     WHERE d.product_id=dupd_prod_id
      AND d.updt_cnt=der_updt_cnt)
    DETAIL
     cur_qty = d.cur_avail_qty, cur_ius = d.cur_intl_units
    WITH nocounter, forupdate(d)
   ;end select
   IF (curqual=0)
    SET release_status = "F"
   ELSE
    SET cur_qty -= lqty
    IF (cur_qty > 0)
     SET inactive_avail = 0
    ENDIF
    IF (lius > cur_ius)
     SET cur_ius = 0
    ELSE
     SET cur_ius -= lius
    ENDIF
    UPDATE  FROM derivative d
     SET d.cur_avail_qty = cur_qty, d.cur_intl_units = cur_ius, d.updt_cnt = (d.updt_cnt+ 1),
      d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
      updt_task,
      d.updt_applctx = reqinfo->updt_applctx
     WHERE d.product_id=dupd_prod_id
      AND d.updt_cnt=der_updt_cnt
    ;end update
    IF (curqual=0)
     SET release_status = "F"
    ELSE
     SET release_status = "S"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (modifyassignqty(dchgprod_id=f8,dchgevent_id=f8,lchgupdt_cnt=i4,qty=i4,ius=i4) =null)
   DECLARE remove_assign = i2 WITH noconstant(0)
   SET inactive_avail = 0
   SET cur_qty = 0
   SET cur_ius = 0
   SELECT INTO "nl:"
    a.seq
    FROM assign a
    PLAN (a
     WHERE a.product_id=dchgprod_id
      AND a.product_event_id=dchgevent_id
      AND a.updt_cnt=lchgupdt_cnt)
    DETAIL
     cur_qty = a.cur_assign_qty, cur_ius = a.cur_assign_intl_units
    WITH nocounter, forupdate(a)
   ;end select
   IF (curqual=0)
    SET release_status = "F"
   ELSE
    SET cur_qty -= qty
    IF (cur_qty > 0)
     SET remove_assign = 0
    ELSE
     SET remove_assign = 1
    ENDIF
    IF (ius > cur_ius)
     SET cur_ius = 0
    ELSE
     SET cur_ius -= ius
    ENDIF
    SET modifyassignqty_ind = 1
    UPDATE  FROM assign a
     SET a.cur_assign_qty = cur_qty, a.cur_assign_intl_units = cur_ius, a.active_ind =
      IF (remove_assign=1) 0
      ENDIF
      ,
      a.updt_cnt = (a.updt_cnt+ 1), a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = reqinfo->
      updt_id,
      a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx
     WHERE a.product_id=dchgprod_id
      AND a.product_event_id=dchgevent_id
      AND a.updt_cnt=lchgupdt_cnt
    ;end update
    IF (curqual=0)
     SET release_status = "F"
    ELSE
     IF (remove_assign=1)
      SELECT INTO "nl:"
       pe.seq
       FROM product_event pe
       WHERE pe.product_id=dchgprod_id
        AND pe.product_event_id=dchgevent_id
       WITH nocounter, forupdate(pe)
      ;end select
      UPDATE  FROM product_event pe
       SET pe.active_ind = 0, pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate),
        pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
        updt_applctx
       WHERE pe.product_id=dchgprod_id
        AND pe.product_event_id=dchgevent_id
      ;end update
      IF (curqual=0)
       SET release_status = "F"
      ELSE
       SET release_status = "S"
      ENDIF
     ELSE
      SET release_status = "S"
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (releaseassign(drelprod_id=f8,drelevent_id=f8,drelreason_cd=f8,lrelupdt_cnt=i4,
  lrelpe_updt_cnt=i4,qty=i4,ius=i4) =null)
  IF (modifyassignqty_ind=0)
   SELECT INTO "nl:"
    pe.seq
    FROM product_event pe
    PLAN (pe
     WHERE pe.product_id=drelprod_id
      AND pe.product_event_id=drelevent_id
      AND pe.updt_cnt=lrelpe_updt_cnt)
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    SET release_status = "F"
    RETURN
   ENDIF
   SELECT INTO "nl:"
    a.seq
    FROM assign a
    PLAN (a
     WHERE a.product_id=drelprod_id
      AND a.product_event_id=drelevent_id
      AND a.updt_cnt=lrelupdt_cnt)
    WITH nocounter, forupdate(a)
   ;end select
   IF (curqual=0)
    SET release_status = "F"
   ELSE
    SET orig_event_type_cd = assign_type_cd
    CALL chg_product_event(0)
    IF (curqual=0)
     SET release_status = "F"
    ELSE
     UPDATE  FROM assign a
      SET a.active_ind = 0, a.updt_cnt = (a.updt_cnt+ 1), a.updt_dt_tm = cnvtdatetime(sysdate),
       a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
       updt_applctx,
       a.active_status_cd = reqdata->active_status_cd, a.active_status_dt_tm = cnvtdatetime(sysdate),
       a.active_status_prsnl_id = reqinfo->updt_id
      WHERE a.product_id=drelprod_id
       AND a.product_event_id=drelevent_id
       AND a.updt_cnt=lrelupdt_cnt
     ;end update
     IF (curqual=0)
      SET release_status = "F"
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  IF (release_status != "F")
   CALL insert_assignrelease_event(drelprod_id,drelevent_id,drelreason_cd,qty,ius)
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_assignrelease_event(drelprod_id,drelevent_id,drelreason_cd,drelqty,drelius)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   INSERT  FROM assign_release a
    SET a.assign_release_id = new_pathnet_seq, a.product_event_id = drelevent_id, a.product_id =
     drelprod_id,
     a.release_dt_tm = cnvtdatetime(sysdate), a.release_prsnl_id = reqinfo->updt_id, a
     .release_reason_cd = drelreason_cd,
     a.release_qty =
     IF (drelqty > 0) drelqty
     ENDIF
     , a.release_intl_units =
     IF (drelius > 0) drelius
     ENDIF
     , a.active_ind = 0,
     a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = reqinfo->updt_id,
     a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.active_status_cd =
     reqdata->active_status_cd,
     a.active_status_dt_tm = cnvtdatetime(sysdate), a.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET release_status = "F"
   ELSE
    SET release_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (releasecrossmatch(dproduct_id=f8,devent_id=f8,dreason_cd=f8,lupdt_cnt=i4,lpe_updt_cnt=i4
  ) =null)
   SELECT INTO "nl:"
    pe.product_id
    FROM product_event pe
    PLAN (pe
     WHERE pe.product_id=dproduct_id
      AND pe.product_event_id=devent_id
      AND pe.updt_cnt=lpe_updt_cnt)
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    SET release_status = "F"
    RETURN
   ENDIF
   SELECT INTO "nl:"
    xm.product_id, xm.product_event_id
    FROM crossmatch xm
    PLAN (xm
     WHERE xm.product_id=dproduct_id
      AND xm.product_event_id=devent_id
      AND xm.updt_cnt=lupdt_cnt)
    WITH nocounter, forupdate(xm)
   ;end select
   IF (curqual=0)
    SET release_status = "F"
   ELSE
    CALL chg_product_event(0)
    IF (curqual=0)
     SET release_status = "F"
    ELSE
     UPDATE  FROM crossmatch xm
      SET xm.release_dt_tm = cnvtdatetime(sysdate), xm.release_prsnl_id = reqinfo->updt_id, xm
       .release_reason_cd = dreason_cd,
       xm.updt_cnt = (xm.updt_cnt+ 1), xm.updt_dt_tm = cnvtdatetime(sysdate), xm.updt_id = reqinfo->
       updt_id,
       xm.updt_task = reqinfo->updt_task, xm.updt_applctx = reqinfo->updt_applctx, xm.active_ind = 0
      WHERE xm.product_id=dproduct_id
       AND xm.product_event_id=devent_id
       AND xm.updt_cnt=lupdt_cnt
     ;end update
     IF (curqual=0)
      SET release_status = "F"
     ELSE
      SET release_status = "S"
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (releaseinprogress(dproduct_id=f8,devent_id=f8,dreason_cd=f8,lupdt_cnt=i4,lpe_updt_cnt=i4
  ) =null)
  SELECT INTO "nl:"
   pe.product_id, pe.event_dt_tm, pe.event_type_cd
   FROM product_event pe
   PLAN (pe
    WHERE pe.product_id=dproduct_id
     AND pe.product_event_id=devent_id
     AND pe.updt_cnt=lpe_updt_cnt)
   WITH nocounter, forupdate(pe)
  ;end select
  IF (curqual=0)
   SET release_status = "F"
  ELSE
   CALL chg_product_event(0)
   IF (curqual=0)
    SET release_status = "F"
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (chg_product_event(dummyx=i2) =null)
   UPDATE  FROM product_event pe
    SET pe.active_ind = 0, pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(curdate,
      curtime),
     pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
     updt_applctx
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[x].eventlist[y].event_id)
      AND (pe.product_id=request->productlist[x].product_id)
      AND (pe.updt_cnt=request->productlist[x].eventlist[y].pe_updt_cnt))
    WITH counter
   ;end update
 END ;Subroutine
 SUBROUTINE (lock_product(sub_product_id=f8) =null)
  SELECT INTO "nl:"
   p.product_id
   FROM product p
   WHERE (p.product_id=request->productlist[x].product_id)
    AND (p.updt_cnt=request->productlist[x].updt_cnt)
    AND p.locked_ind=1
   WITH nocounter, forupdate(p)
  ;end select
  IF (curqual=0)
   CALL update_status_data_err("Unable to lock product row for updating.")
   SET lock_status = "F"
  ELSE
   SET lock_status = "T"
  ENDIF
 END ;Subroutine
 SUBROUTINE (unlock_product(sub_product_id=f8,dispense_to_locn_cd=f8,sub_updt_id=f8,sub_updt_task=i4,
  sub_updt_applctx=i4) =null)
   SELECT INTO "nl:"
    p.seq
    FROM product p
    WHERE p.product_id=sub_product_id
    WITH nocounter, forupdate(p)
   ;end select
   UPDATE  FROM product p
    SET p.locked_ind = 0, p.cur_inv_locn_cd = dispense_to_locn_cd, p.cur_dispense_device_id =
     dispense_device_id,
     p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = sub_updt_id,
     p.updt_task = sub_updt_task, p.updt_applctx = sub_updt_applctx
    WHERE p.product_id=sub_product_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL update_status_data_err("Unable to unlock the product row.")
    SET unlock_status = "F"
   ELSE
    SET unlock_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (update_status_data_err(messaged=vc) =null)
   SET count1 += 1
   SET count2 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET stat = alterlist(reply->productlist,(count2+ 1))
   SET reply->productlist[count2].product_id = request->productlist[x].product_id
   SET reply->productlist[count2].product_event_id = 0
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[count1].operationname = "change"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "PRODUCT"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = messaged
   SET reqinfo->commit_ind = 0
 END ;Subroutine
 SUBROUTINE (update_status_data_success(updt_product_id=f8,updt_product_event_id=f8,
  updt_assign_event_id=f8,interface_status_flag=i2,updt_dispense_event_id=f8) =null)
   SET count1 += 1
   SET count2 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET stat = alterlist(reply->productlist,(count2+ 1))
   SET reply->productlist[count2].product_id = updt_product_id
   SET reply->productlist[count2].product_event_id = updt_product_event_id
   SET reply->productlist[count2].assign_event_id = updt_assign_event_id
   SET reply->productlist[count2].interface_status_flag = interface_status_flag
   SET reply->productlist[count2].dispense_event_id = updt_dispense_event_id
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationname = "change"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "PRODUCT"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Successfully Updated"
   SET reqinfo->commit_ind = 1
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
      pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->
      updt_task,
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
      pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->
      updt_task,
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
 END ;Subroutine
 SUBROUTINE add_assign(sub_product_id,sub_person_id,encntr_id,sub_assign_reason_cd,sub_prov_id,
  qty_assigned,assign_intl_units,sub_updt_id,sub_updt_task,sub_updt_applctx,sub_active_status_cd,
  sub_active_status_prsnl_id,assign_dt_tm)
   SET assign_event_id = 0.0
   SET event_type_cd = 0.0
   CALL get_event_type("1")
   IF (event_type_cd=0)
    SET assign_status = "F"
   ELSE
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET product_event_id = 0.0
    SET sub_product_event_id = 0.0
    CALL add_product_event(sub_product_id,sub_person_id,encntr_id,0,0,
     event_type_cd,cnvtdatetime(assign_dt_tm),reqinfo->updt_id,0,0,
     0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
     reqinfo->updt_id)
    SET sub_product_event_id = product_event_id
    IF (curqual=0)
     SET assign_status = "F"
    ELSE
     INSERT  FROM assign a
      SET a.product_event_id = sub_product_event_id, a.product_id = sub_product_id, a.person_id =
       sub_person_id,
       a.assign_reason_cd = sub_assign_reason_cd, a.prov_id = sub_prov_id, a.orig_assign_qty =
       qty_assigned,
       a.cur_assign_qty = qty_assigned, a.cur_assign_intl_units = assign_intl_units, a
       .orig_assign_intl_units = assign_intl_units,
       a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = sub_updt_id,
       a.updt_task = sub_updt_task, a.updt_applctx = sub_updt_applctx, a.active_ind = 1,
       a.active_status_cd = sub_active_status_cd, a.active_status_dt_tm = cnvtdatetime(sysdate), a
       .active_status_prsnl_id = sub_active_status_prsnl_id
      WITH counter
     ;end insert
     IF (curqual=0)
      SET assign_status = "F"
     ELSE
      SET assign_event_id = sub_product_event_id
      SET assign_status = "S"
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_event_type(meaning)
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=1610
     AND cv.cdf_meaning=meaning
    DETAIL
     event_type_cd = cv.code_value
    WITH counter
   ;end select
 END ;Subroutine
 SUBROUTINE (add_bb_exception(sub_person_id=f8,sub_order_id=f8,sub_exception_prsnl_id=f8,
  exception_dt_tm=dq8,prod_event_id=f8,exception_type_mean=vc,sub_override_reason_cd=f8,
  sub_event_type_cd=f8,sub_result_id=f8,sub_perform_result_id=f8,sub_from_abo_cd=f8,sub_from_rh_cd=f8,
  sub_to_abo_cd=f8,sub_to_rh_cd=f8,sub_default_expiration_dt_tm=dq8) =null)
   SET exception_status = "I"
   SET sub_exception_type_cd = 0.0
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   DECLARE except_type_mean = c12
   SET except_type_mean = fillstring(12," ")
   SET except_type_mean = exception_type_mean
   SET stat = uar_get_meaning_by_codeset(14072,nullterm(except_type_mean),1,sub_exception_type_cd)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   SET sub_bb_exception_id = new_pathnet_seq
   INSERT  FROM bb_exception b
    SET b.exception_id = sub_bb_exception_id, b.product_event_id = prod_event_id, b.exception_type_cd
      = sub_exception_type_cd,
     b.event_type_cd = sub_event_type_cd, b.from_abo_cd = sub_from_abo_cd, b.from_rh_cd =
     sub_from_rh_cd,
     b.to_abo_cd = sub_to_abo_cd, b.to_rh_cd = sub_to_rh_cd, b.override_reason_cd =
     sub_override_reason_cd,
     b.result_id = sub_result_id, b.perform_result_id = sub_perform_result_id, b.updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
     updt_task,
     b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1, b.active_status_cd = reqdata->
     active_status_cd,
     b.active_status_dt_tm = cnvtdatetime(sysdate), b.active_status_prsnl_id = reqinfo->updt_id, b
     .donor_contact_id = 0.0,
     b.donor_contact_type_cd = 0.0, b.order_id = sub_order_id, b.exception_prsnl_id =
     sub_exception_prsnl_id,
     b.exception_dt_tm = cnvtdatetime(exception_dt_tm), b.person_id = sub_person_id, b
     .default_expire_dt_tm = cnvtdatetime(sub_default_expiration_dt_tm)
    WITH counter
   ;end insert
   SET bb_exception_id = sub_bb_exception_id
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_tag_mismatch_exception(tag_product_nbr=vc,tag_div_chars=vc,tag_product_type_cd=f8) =
  null)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   SET sub_bb_exception_id = bb_exception_id
   INSERT  FROM bb_tag_verify_excpn tv
    SET tv.bb_tag_verify_excpn_id = new_pathnet_seq, tv.exception_id = sub_bb_exception_id, tv
     .tag_product_sub_nbr_txt = tag_div_chars,
     tv.tag_product_nbr_txt = tag_product_nbr, tv.tag_product_type_cd = tag_product_type_cd, tv
     .updt_id = reqinfo->updt_id,
     tv.updt_task = reqinfo->updt_task, tv.updt_applctx = reqinfo->updt_applctx, tv.updt_cnt = 0
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_invd_prod_ord_exception(product_order_id=f8) =null)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   SET sub_bb_exception_id = bb_exception_id
   INSERT  FROM bb_invld_prod_ord_exceptn b
    SET b.bb_invld_prod_ord_exceptn_id = new_pathnet_seq, b.exception_id = sub_bb_exception_id, b
     .product_order_id = product_order_id,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE add_reqs_exception(sub_special_testing_cd,sub_requirement_cd)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   SET sub_bb_exception_id = bb_exception_id
   INSERT  FROM bb_reqs_exception b
    SET b.reqs_exception_id = new_pathnet_seq, b.exception_id = sub_bb_exception_id, b
     .special_testing_cd = sub_special_testing_cd,
     b.requirement_cd = sub_requirement_cd, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx,
     b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm =
     cnvtdatetime(sysdate),
     b.active_status_prsnl_id = reqinfo->updt_id
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE add_autodir_reqs_exception(sub_product_id)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   SET sub_bb_exception_id = bb_exception_id
   INSERT  FROM bb_autodir_exception b
    SET b.bb_autodir_exc_id = new_pathnet_seq, b.bb_exception_id = sub_bb_exception_id, b.product_id
      = sub_product_id,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1,
     b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm = cnvtdatetime(sysdate), b
     .active_status_prsnl_id = reqinfo->updt_id
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_bb_inactive_exception(sub_person_id=f8,sub_order_id=f8,sub_exception_prsnl_id=f8,
  exception_dt_tm=dq8,prod_event_id=f8,exception_type_mean=vc,sub_override_reason_cd=f8,
  sub_event_type_cd=f8,sub_result_id=f8,sub_perform_result_id=f8,sub_from_abo_cd=f8,sub_from_rh_cd=f8,
  sub_to_abo_cd=f8,sub_to_rh_cd=f8,sub_default_expiration_dt_tm=dq8) =null)
   SET exception_status = "I"
   DECLARE sub_exception_type_cd = f8 WITH protect, noconstant(0.0)
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   DECLARE except_type_mean = c12
   SET except_type_mean = fillstring(12," ")
   SET except_type_mean = exception_type_mean
   SET stat = uar_get_meaning_by_codeset(14072,nullterm(except_type_mean),1,sub_exception_type_cd)
   IF (sub_exception_type_cd=0.0)
    SET exception_status = "FU"
   ELSE
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET sub_bb_exception_id = new_pathnet_seq
    INSERT  FROM bb_exception b
     SET b.exception_id = sub_bb_exception_id, b.product_event_id = prod_event_id, b
      .exception_type_cd = sub_exception_type_cd,
      b.event_type_cd = sub_event_type_cd, b.from_abo_cd = sub_from_abo_cd, b.from_rh_cd =
      sub_from_rh_cd,
      b.to_abo_cd = sub_to_abo_cd, b.to_rh_cd = sub_to_rh_cd, b.override_reason_cd =
      sub_override_reason_cd,
      b.result_id = sub_result_id, b.perform_result_id = sub_perform_result_id, b.updt_cnt = 0,
      b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
      updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 0, b.active_status_cd = reqdata->
      inactive_status_cd,
      b.active_status_dt_tm = cnvtdatetime(sysdate), b.active_status_prsnl_id = reqinfo->updt_id, b
      .donor_contact_id = 0.0,
      b.donor_contact_type_cd = 0.0, b.order_id = sub_order_id, b.exception_prsnl_id =
      sub_exception_prsnl_id,
      b.exception_dt_tm = cnvtdatetime(exception_dt_tm), b.person_id = sub_person_id, b
      .default_expire_dt_tm = cnvtdatetime(sub_default_expiration_dt_tm)
     WITH counter
    ;end insert
    SET bb_exception_id = sub_bb_exception_id
    IF (curqual=0)
     SET exception_status = "F"
    ELSE
     SET exception_status = "S"
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE add_inactive_reqs_exception(sub_special_testing_cd,sub_requirement_cd) = null
 SUBROUTINE add_inactive_reqs_exception(sub_special_testing_cd,sub_requirement_cd)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   SET sub_bb_exception_id = bb_exception_id
   INSERT  FROM bb_reqs_exception b
    SET b.reqs_exception_id = new_pathnet_seq, b.exception_id = sub_bb_exception_id, b
     .special_testing_cd = sub_special_testing_cd,
     b.requirement_cd = sub_requirement_cd, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx,
     b.active_ind = 0, b.active_status_cd = reqdata->inactive_status_cd, b.active_status_dt_tm =
     cnvtdatetime(sysdate),
     b.active_status_prsnl_id = reqinfo->updt_id
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (activate_bb_exception(sub_exception_id=f8,updt_cnt=i4) =null)
   SET exception_status = "I"
   SELECT INTO "nl:"
    b.exception_id
    FROM bb_exception b
    WHERE b.exception_id=sub_exception_id
     AND b.active_ind=0
     AND b.updt_cnt=updt_cnt
    WITH nocounter, forupdate(b)
   ;end select
   IF (curqual=0)
    SET exception_status = "FL"
   ENDIF
   IF (curqual=1)
    UPDATE  FROM bb_exception b
     SET b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd, b.updt_cnt = (b.updt_cnt+
      1),
      b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
      updt_task,
      b.updt_applctx = reqinfo->updt_applctx
     WHERE b.exception_id=sub_exception_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET exception_status = "F"
    ELSE
     SET exception_status = "S"
    ENDIF
   ENDIF
 END ;Subroutine
#exit_program
 IF ((reply->status_data.status="S"))
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationname = "add"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "product_event & patient_dispense"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(request->person_id)
 ELSEIF ((reply->status_data.status="Z"))
  SET count3 += 1
  IF (count3 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count3+ 1))
  ENDIF
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[count1].operationname = "check"
  SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "PATIENT"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Patient Demographics changed"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
#exit_script
 CALL echo(reply->status_data.status)
 FOR (x = 1 TO count1)
   CALL echo("    ")
   CALL echo(reply->status_data.subeventstatus[x].operationname)
   CALL echo(reply->status_data.subeventstatus[x].operationstatus)
   CALL echo(reply->status_data.subeventstatus[x].targetobjectname)
   CALL echo(reply->status_data.subeventstatus[x].targetobjectvalue)
 ENDFOR
 FREE RECORD outbound_products
END GO
