CREATE PROGRAM bbt_add_assign:dba
 RECORD reply(
   1 productlist[1]
     2 product_id = f8
     2 assign_event_id = f8
     2 status_flag = c1
     2 updt_cnt = i4
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
 DECLARE nbr_to_add = i4 WITH noconstant(size(request->productlist,5))
 DECLARE code_cnt = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE count2 = i4 WITH noconstant(0)
 DECLARE count3 = i4 WITH noconstant(0)
 DECLARE product_event_id = f8 WITH noconstant(0.0)
 DECLARE avail_type_cd = f8 WITH noconstant(0.0)
 DECLARE assign_type_cd = f8 WITH noconstant(0.0)
 DECLARE release_status = c1 WITH noconstant(fillstring(1," "))
 DECLARE assign_status = c1 WITH noconstant(fillstring(1," "))
 DECLARE unlock_status = c1 WITH noconstant(fillstring(1," "))
 DECLARE assign_event_id = f8 WITH noconstant(0.0)
 DECLARE remove_avail_state = i2 WITH noconstant(0)
 DECLARE nextrow = i4 WITH noconstant(1)
 DECLARE states_code_set = i4 WITH constant(1610)
 DECLARE cdf_meaning = c12 WITH noconstant(fillstring(12," "))
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE modassignqty_ind = i4 WITH noconstant(0)
 DECLARE remove_assign_state = i2 WITH noconstant(0)
 SET reply->bb_comment_changed = "F"
 SET reply->pat_aborh_changed = "F"
 SET reply->trans_req_changed = "F"
 SET reply->antibodies_changed = "F"
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
     IF ((((check_bb_comment_id != request->bb_comment_id)) OR ((check_bb_comment_updt_cnt != request
     ->bb_comment_updt_cnt))) )
      SET sub_bb_comment_changed = "T"
     ENDIF
    ELSE
     IF ((((check_bb_comment_id != request->bb_comment_id)) OR ((check_bb_comment_updt_cnt != request
     ->bb_comment_updt_cnt))) )
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
     trans_cnt += 1, stat = alterlist(trans_req_rec->reqs,trans_cnt), trans_req_rec->reqs[trans_cnt].
     requirement_cd = p.requirement_cd
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
 SET code_cnt = 1
 SET cdf_meaning = "12"
 SET stat = uar_get_meaning_by_codeset(states_code_set,cdf_meaning,code_cnt,avail_type_cd)
 IF (stat != 0)
  CALL update_status_data_err("Unable to obtain code value for available, code set 1610.")
  GO TO exit_program
 ENDIF
 SET code_cnt = 1
 SET cdf_meaning = "1"
 SET stat = uar_get_meaning_by_codeset(states_code_set,cdf_meaning,code_cnt,assign_type_cd)
 IF (stat != 0)
  CALL update_status_data_err("Unable to obtain code value for assign, code set 1610.")
  GO TO exit_program
 ENDIF
#start_loop
 FOR (x = nextrow TO nbr_to_add)
   SET lock_status = "I"
   CALL lock_product(request->productlist[x].product_id)
   IF (lock_status="F")
    GO TO next_row
   ENDIF
   SET y = 0
   SET modassignqty_ind = 0
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
       request->productlist[x].assign_qty,request->productlist[x].assign_intl_units)
     ELSEIF ((request->productlist[x].eventlist[y].inprog_ind=1))
      CALL releaseinprogress(request->productlist[x].product_id,request->productlist[x].eventlist[y].
       event_id,request->productlist[x].eventlist[y].reason_cd,request->productlist[x].eventlist[y].
       updt_cnt,request->productlist[x].eventlist[y].pe_updt_cnt)
     ELSE
      SET release_status = "F"
     ENDIF
     IF (release_status="F")
      CALL update_status_data_err("Unable to release product.")
      GO TO next_row
     ENDIF
   ENDFOR
   SET assign_status = "I"
   SET assign_event_id = 0.0
   CALL assign_product(request->productlist[x].product_id,request->person_id,request->encntr_id,
    request->assign_reason_cd,request->assign_prov_id,
    request->productlist[x].assign_qty,request->productlist[x].assign_intl_units,reqinfo->updt_id,
    reqinfo->updt_task,reqinfo->updt_applctx,
    reqdata->active_status_cd,reqinfo->updt_id,request->assign_dt_tm,request->bb_id_nbr)
   IF (assign_status != "S")
    CALL update_status_data_err("Unable to add assign.")
    GO TO next_row
   ENDIF
   SET remove_avail_state = 1
   IF (modassignqty_ind=0)
    IF ((request->productlist[x].assign_qty > 0))
     SET release_status = "I"
     CALL updateavailableqty(request->productlist[x].product_id,request->productlist[x].assign_qty,
      request->productlist[x].assign_intl_units)
     IF (release_status="F")
      CALL update_status_data_err("Unable to update available quantity.")
      GO TO next_row
     ENDIF
    ENDIF
    IF (remove_avail_state=1)
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
       updt_applctx,
       p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm = cnvtdatetime(sysdate),
       p.active_status_prsnl_id = reqinfo->updt_id
      WHERE (p.product_id=request->productlist[x].product_id)
       AND p.event_type_cd=avail_type_cd
       AND p.active_ind=1
      WITH nocounter
     ;end update
     IF (curqual=0)
      CALL update_status_data_err("Unable to inactivate the available product event.")
     ENDIF
    ENDIF
   ENDIF
   SET unlock_status = "I"
   CALL unlock_product(request->productlist[x].product_id,reqinfo->updt_id,reqinfo->updt_task,reqinfo
    ->updt_applctx)
   IF (unlock_status="S")
    CALL update_status_data_success(request->productlist[x].product_id,assign_event_id)
   ELSE
    GO TO next_row
   ENDIF
 ENDFOR
 GO TO exit_program
#next_row
 SET nextrow += 1
 GO TO start_loop
 SUBROUTINE (updateavailableqty(dupd_prod_id=f8,lqty=i4,lius=i4) =null)
   DECLARE cur_qty = i4 WITH noconstant(0)
   DECLARE cur_ius = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    d.seq
    FROM derivative d
    WHERE d.product_id=dupd_prod_id
    DETAIL
     cur_qty = d.cur_avail_qty, cur_ius = d.cur_intl_units
    WITH nocounter, forupdate(d)
   ;end select
   IF (curqual=0)
    SET release_status = "F"
   ELSE
    SET cur_qty -= lqty
    IF (cur_qty > 0)
     SET remove_avail_state = 0
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
    ;end update
    IF (curqual=0)
     SET release_status = "F"
    ELSE
     SET release_status = "S"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (releaseassign(drelprod_id=f8,drelevent_id=f8,drelreason_cd=f8,lrelupdt_cnt=i4,
  lrelpe_updt_cnt=i4,lqty=i4,lius=i4) =null)
   DECLARE cur_qty = i4 WITH noconstant(0)
   DECLARE cur_ius = i4 WITH noconstant(0)
   SET modassignqty_ind = 1
   SET remove_assign_state = 1
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
   ELSE
    SELECT INTO "nl:"
     a.seq
     FROM assign a
     PLAN (a
      WHERE a.product_id=drelprod_id
       AND a.product_event_id=drelevent_id
       AND a.updt_cnt=lrelupdt_cnt)
     DETAIL
      cur_qty = a.cur_assign_qty, cur_ius = a.cur_assign_intl_units
     WITH nocounter, forupdate(a)
    ;end select
    IF (curqual=0)
     SET release_status = "F"
    ELSE
     SET cur_qty -= lqty
     IF (cur_qty > 0)
      SET remove_assign_state = 0
     ELSE
      SET remove_assign_state = 1
     ENDIF
     IF (lius > cur_ius)
      SET cur_ius = 0
     ELSE
      SET cur_ius -= lius
     ENDIF
     CALL chg_product_event(remove_assign_state)
     IF (curqual=0)
      SET release_status = "F"
     ELSE
      UPDATE  FROM assign a
       SET a.active_ind =
        IF (remove_assign_state=1) 0
        ENDIF
        , a.updt_cnt = (a.updt_cnt+ 1), a.updt_dt_tm = cnvtdatetime(sysdate),
        a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
        updt_applctx,
        a.active_status_cd = reqdata->active_status_cd, a.active_status_dt_tm = cnvtdatetime(sysdate),
        a.active_status_prsnl_id = reqinfo->updt_id,
        a.cur_assign_qty = cur_qty, a.cur_assign_intl_units = cur_ius
       WHERE a.product_id=drelprod_id
        AND a.product_event_id=drelevent_id
        AND a.updt_cnt=lrelupdt_cnt
      ;end update
      IF (curqual=0)
       SET release_status = "F"
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
       INSERT  FROM assign_release a
        SET a.assign_release_id = new_pathnet_seq, a.product_event_id = drelevent_id, a.product_id =
         drelprod_id,
         a.release_dt_tm = cnvtdatetime(sysdate), a.release_prsnl_id = reqinfo->updt_id, a
         .release_reason_cd = drelreason_cd,
         a.active_ind = 0, a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(sysdate),
         a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
         updt_applctx,
         a.active_status_cd = reqdata->active_status_cd, a.active_status_dt_tm = cnvtdatetime(sysdate
          ), a.active_status_prsnl_id = reqinfo->updt_id,
         a.release_qty = lqty, a.release_intl_units = lius
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET release_status = "F"
       ELSE
        SET release_status = "S"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (releasecrossmatch(dproduct_id=f8,devent_id=f8,dreason_cd=f8,lupdt_cnt=i4,lpe_updt_cnt=i4
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
    CALL chg_product_event(1)
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
   CALL chg_product_event(1)
   IF (curqual=0)
    SET release_status = "F"
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (chg_product_event(dummyx=i2) =null)
   IF (dummyx > 0)
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
   ENDIF
 END ;Subroutine
 SUBROUTINE (lock_product(product_id=f8) =null)
   DECLARE lock_status = c1 WITH noconstant(fillstring(1," "))
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
 SUBROUTINE (unlock_product(product_id=f8,updt_id=f8,updt_task=i4,updt_applctx=i4) =null)
  UPDATE  FROM product p
   SET p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
    p.updt_id = updt_id, p.updt_task = updt_task, p.updt_applctx = updt_applctx
   WHERE product_id=p.product_id
   WITH counter
  ;end update
  IF (curqual=0)
   CALL update_status_data_err("Unable to unlock the product row.")
   SET unlock_status = "F"
  ELSE
   SET unlock_status = "S"
  ENDIF
 END ;Subroutine
 SUBROUTINE (update_status_data_err(message=vc) =null)
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[count1].operationname = "change"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "PRODUCT"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = message
   SET reqinfo->commit_ind = 0
 END ;Subroutine
 SUBROUTINE (update_status_data_success(updt_product_id=f8,updt_assign_event_id=f8) =null)
   SET count1 += 1
   SET count2 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   IF (count2 > 1)
    SET stat = alter(reply->productlist,(count2+ 1))
   ENDIF
   SET reply->productlist[count2].product_id = updt_product_id
   SET reply->productlist[count2].assign_event_id = updt_assign_event_id
   SET reply->productlist[count2].status_flag = "S"
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationname = "change"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "PRODUCT"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Successfully Updated."
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
 SUBROUTINE assign_product(sub_product_id,sub_person_id,encntr_id,sub_assign_reason_cd,sub_prov_id,
  qty_assigned,assign_intl_units,sub_updt_id,sub_updt_task,sub_updt_applctx,sub_active_status_cd,
  sub_active_status_prsnl_id,assign_dt_tm,bb_id_nbr)
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
       .active_status_prsnl_id = sub_active_status_prsnl_id,
       a.bb_id_nbr =
       IF (trim(bb_id_nbr) > "") bb_id_nbr
       ELSE ""
       ENDIF
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
#exit_program
 IF ((reply->status_data.status="S"))
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationname = "add"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "product_event & patient_ASSIGN"
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
END GO
