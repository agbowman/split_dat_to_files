CREATE PROGRAM bbt_chg_event_release:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 results[1]
     2 product_event_id = f8
     2 status = c1
     2 err_process = vc
     2 err_message = vc
 )
 DECLARE assign_release_id_val = f8 WITH protect, noconstant(0.0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE count2 = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE active_quar = c1 WITH protect, noconstant("F")
 DECLARE active_uncfrm = c1 WITH protect, noconstant("F")
 DECLARE active_avail = c1 WITH protect, noconstant("F")
 DECLARE multiple_xm = c1 WITH protect, noconstant("F")
 DECLARE active_auto = c1 WITH protect, noconstant("F")
 DECLARE active_dir = c1 WITH protect, noconstant("F")
 DECLARE active_assign = c1 WITH protect, noconstant(" ")
 DECLARE active_xm = c1 WITH protect, noconstant("F")
 DECLARE active_transfuse = c1 WITH protect, noconstant("F")
 DECLARE active_dispose = c1 WITH protect, noconstant("F")
 DECLARE active_destroy = c1 WITH protect, noconstant("F")
 DECLARE active_shipped = c1 WITH protect, noconstant("F")
 DECLARE active_intransit = c1 WITH protect, noconstant("F")
 DECLARE active_disp = c1 WITH protect, noconstant("F")
 DECLARE error_process = c38 WITH protect, noconstant(fillstring(38," "))
 DECLARE error_message = c38 WITH protect, noconstant(fillstring(38," "))
 DECLARE success_cnt = i4 WITH protect, noconstant(0)
 DECLARE failure_occured = c1 WITH protect, noconstant("F")
 DECLARE quantity_val = i4 WITH protect, noconstant(0)
 DECLARE quantity_iu = i4 WITH protect, noconstant(0)
 DECLARE product_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE gsub_product_event_status = c2 WITH protect, noconstant("  ")
 DECLARE this_prod_id = f8 WITH protect, noconstant(0.0)
 DECLARE other_events = c1 WITH protect, noconstant("F")
 DECLARE quar_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE assgn_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE xmtch_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE avail_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE uncfrm_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE inprog_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE auto_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dir_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE disp_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE trans_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dispose_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE destroy_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE shipped_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE intransit_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE nbr_to_update = i4 WITH protect, noconstant(cnvtint(size(request->productlist,5)))
 SET stat = alter(reply->results,nbr_to_update)
 SET stat = alter(reply->status_data.subeventstatus,nbr_to_update)
 DECLARE unlock_product(none=i2) = i2
 SET uar_failed = 0
 SET current_meaning = fillstring(12," ")
 SET code_set = 1610
 SET current_meaning = "1"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,assgn_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "2"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,quar_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "3"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,xmtch_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "12"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,avail_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "9"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,uncfrm_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "10"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,auto_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "11"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,dir_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "16"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,inprog_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "4"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,disp_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "7"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,trans_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "5"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,dispose_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "14"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,destroy_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "15"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,shipped_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
 SET current_meaning = "25"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(current_meaning),1,intransit_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_the_rest
 ENDIF
#skip_the_rest
 IF (uar_failed=1)
  SET reply->status_data.status = "F"
  SET error_process = "lock assign/product_event"
  SET error_message = "assign/product_event not locked"
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "release"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code value read failed"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "F"
 ENDIF
 FOR (prod = 1 TO nbr_to_update)
   SET failure_occured = "F"
   SET active_quar = "F"
   SET active_uncfrm = "F"
   SET this_prod_id = 0.0
   SET other_events = "F"
   SET active_avail = "F"
   SET multiple_xm = "F"
   SET active_auto = "F"
   SET active_dir = "F"
   SET active_assign = "F"
   SET active_disp = "F"
   SET active_xm = "F"
   SET active_transfuse = "F"
   SET active_dispose = "F"
   SET active_destroy = "F"
   SET active_shipped = "F"
   SET active_intransit = "F"
   SET this_prod_id = request->productlist[prod].product_id
   SET count2 = (prod+ 1)
   IF (prod < nbr_to_update)
    FOR (count1 = count2 TO nbr_to_update)
      IF ((this_prod_id=request->productlist[count1].product_id))
       SET other_events = "T"
      ENDIF
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    WHERE pe.active_ind=1
     AND (pe.product_id=request->productlist[prod].product_id)
    DETAIL
     IF (pe.event_type_cd=quar_event_type_cd)
      active_quar = "T"
     ELSEIF (pe.event_type_cd=uncfrm_event_type_cd)
      active_uncfrm = "T"
     ELSEIF (pe.event_type_cd=avail_event_type_cd)
      active_avail = "T"
     ELSEIF (pe.event_type_cd=quar_event_type_cd)
      active_quar = "T"
     ELSEIF (pe.event_type_cd=auto_event_type_cd)
      active_auto = "T"
     ELSEIF (pe.event_type_cd=dir_event_type_cd)
      active_dir = "T"
     ELSEIF (pe.event_type_cd=assgn_event_type_cd)
      active_assign = "T"
     ELSEIF (pe.event_type_cd=disp_event_type_cd)
      active_disp = "T"
     ELSEIF (pe.event_type_cd=trans_event_type_cd)
      active_transfuse = "T"
     ELSEIF (pe.event_type_cd=dispose_event_type_cd)
      active_dispose = "T"
     ELSEIF (pe.event_type_cd=destroy_event_type_cd)
      active_destroy = "T"
     ELSEIF (pe.event_type_cd=shipped_event_type_cd)
      active_shipped = "T"
     ELSEIF (pe.event_type_cd=intransit_event_type_cd)
      active_intransit = "T"
     ELSEIF (pe.event_type_cd=xmtch_event_type_cd)
      active_xm = "T"
      IF ((pe.product_event_id != request->productlist[prod].assgn_prod_event_id))
       multiple_xm = "T"
      ENDIF
     ELSEIF (pe.event_type_cd=inprog_event_type_cd
      AND (pe.product_event_id != request->productlist[prod].assgn_prod_event_id))
      multiple_xm = "T"
     ENDIF
    WITH counter
   ;end select
   IF ((request->productlist[prod].rel_assign_flag="T")
    AND failure_occured="F")
    SELECT INTO "nl:"
     a.product_id, a.product_event_id
     FROM assign a
     PLAN (a
      WHERE (a.product_event_id=request->productlist[prod].assgn_prod_event_id)
       AND (a.product_id=request->productlist[prod].product_id)
       AND (a.updt_cnt=request->productlist[prod].as_updt_cnt))
     DETAIL
      quantity_val = a.cur_assign_qty, quantity_iu = a.cur_assign_intl_units
     WITH nocounter, forupdate(a)
    ;end select
    IF (curqual != 0)
     SELECT INTO "nl:"
      pe.product_id, pe.product_event_id
      FROM product_event pe
      PLAN (pe
       WHERE (pe.product_event_id=request->productlist[prod].assgn_prod_event_id)
        AND (pe.product_id=request->productlist[prod].product_id)
        AND pe.event_type_cd=assgn_event_type_cd
        AND (pe.updt_cnt=request->productlist[prod].pe_as_updt_cnt))
      WITH nocounter, forupdate(pe)
     ;end select
    ENDIF
    IF (curqual=0)
     SET error_process = "lock assign/product_event"
     SET error_message = "assign/product_event not locked"
     SET failure_occured = "T"
    ELSE
     UPDATE  FROM assign a
      SET a.cur_assign_qty =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((quantity_val <= request->productlist[prod].release_qty)) 0
       ELSE (quantity_val - request->productlist[prod].release_qty)
       ENDIF
       , a.cur_assign_intl_units =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((quantity_iu <= request->productlist[prod].release_iu)) 0
       ELSE (quantity_iu - request->productlist[prod].release_iu)
       ENDIF
       , a.updt_cnt = (a.updt_cnt+ 1),
       a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_task = reqinfo->updt_task, a.updt_id =
       reqinfo->updt_id,
       a.updt_applctx = reqinfo->updt_applctx, a.active_ind =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((quantity_val=request->productlist[prod].release_qty)) 0
       ELSE 1
       ENDIF
       , a.active_status_cd =
       IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
       ELSEIF ((quantity_val=request->productlist[prod].release_qty)) reqdata->inactive_status_cd
       ELSE reqdata->active_status_cd
       ENDIF
       ,
       a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.active_status_prsnl_id = reqinfo->
       updt_id
      PLAN (a
       WHERE (a.product_event_id=request->productlist[prod].assgn_prod_event_id)
        AND (a.product_id=request->productlist[prod].product_id)
        AND (a.updt_cnt=request->productlist[prod].as_updt_cnt))
      WITH counter
     ;end update
     IF (curqual=0)
      SET error_process = "update assign"
      SET error_message = "assign row not updated"
      SET failure_occured = "T"
     ELSE
      SELECT INTO "nl:"
       seqn = seq(pathnet_seq,nextval)
       FROM dual
       DETAIL
        assign_release_id_val = seqn
       WITH format, nocounter
      ;end select
      IF (curqual=0)
       SET error_process = "insert assign_release_id"
       SET error_message = "assign_release_id not generated"
       SET failure_occured = "T"
      ELSE
       INSERT  FROM assign_release ar
        SET ar.assign_release_id = assign_release_id_val, ar.product_id = request->productlist[prod].
         product_id, ar.product_event_id = request->productlist[prod].assgn_prod_event_id,
         ar.release_reason_cd = request->productlist[prod].release_reason_cd, ar.release_dt_tm =
         cnvtdatetime(curdate,curtime3), ar.release_prsnl_id = reqinfo->updt_id,
         ar.release_qty =
         IF ((request->productlist[prod].product_type="B")) 0
         ELSE request->productlist[prod].release_qty
         ENDIF
         , ar.release_intl_units =
         IF ((request->productlist[prod].product_type="B")) 0
         ELSE request->productlist[prod].release_iu
         ENDIF
         , ar.updt_cnt = 0,
         ar.updt_dt_tm = cnvtdatetime(curdate,curtime3), ar.updt_task = reqinfo->updt_task, ar
         .updt_id = reqinfo->updt_id,
         ar.updt_applctx = reqinfo->updt_applctx, ar.active_ind = 1, ar.active_status_cd = reqdata->
         active_status_cd,
         ar.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ar.active_status_prsnl_id = reqinfo
         ->updt_id
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_process = "insert assign_release row"
        SET error_message = "assign_release row not updated"
        SET failure_occured = "T"
       ELSE
        UPDATE  FROM product_event pe
         SET pe.active_ind =
          IF ((request->productlist[prod].product_type="B")) 0
          ELSEIF ((quantity_val <= request->productlist[prod].release_qty)) 0
          ELSE 1
          ENDIF
          , pe.active_status_cd =
          IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
          ELSEIF ((quantity_val <= request->productlist[prod].release_qty)) reqdata->
           inactive_status_cd
          ELSE reqdata->active_status_cd
          ENDIF
          , pe.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
          pe.active_status_prsnl_id = reqinfo->updt_id, pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm
           = cnvtdatetime(curdate,curtime3),
          pe.updt_task = reqinfo->updt_task, pe.updt_id = reqinfo->updt_id, pe.updt_applctx = reqinfo
          ->updt_applctx
         PLAN (pe
          WHERE (pe.product_event_id=request->productlist[prod].assgn_prod_event_id)
           AND (pe.product_id=request->productlist[prod].product_id)
           AND pe.event_type_cd=assgn_event_type_cd
           AND (pe.updt_cnt=request->productlist[prod].pe_as_updt_cnt))
         WITH counter
        ;end update
        IF (curqual=0)
         SET error_process = "update event"
         SET error_message = "assign product_event event row not updated"
         SET failure_occured = "T"
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSEIF ((request->productlist[prod].rel_xmatch_flag="T")
    AND failure_occured="F")
    SELECT INTO "nl:"
     xm.product_id, xm.product_event_id
     FROM crossmatch xm
     PLAN (xm
      WHERE (xm.product_event_id=request->productlist[prod].assgn_prod_event_id)
       AND (xm.product_id=request->productlist[prod].product_id)
       AND (xm.updt_cnt=request->productlist[prod].as_updt_cnt))
     DETAIL
      quantity_val = xm.crossmatch_qty
     WITH nocounter, forupdate(xm)
    ;end select
    IF (curqual != 0)
     SELECT INTO "nl:"
      pe.product_id, pe.product_event_id
      FROM product_event pe
      PLAN (pe
       WHERE (pe.product_event_id=request->productlist[prod].assgn_prod_event_id)
        AND (pe.product_id=request->productlist[prod].product_id)
        AND pe.event_type_cd=xmtch_event_type_cd
        AND (pe.updt_cnt=request->productlist[prod].pe_as_updt_cnt))
      WITH nocounter, forupdate(pe)
     ;end select
    ENDIF
    IF (curqual=0)
     SET error_process = "lock crossmatch/product_event"
     SET error_message = "crossmatch/product_event not locked"
     SET failure_occured = "T"
    ELSE
     UPDATE  FROM crossmatch xm
      SET xm.release_reason_cd = request->productlist[prod].release_reason_cd, xm.release_dt_tm =
       cnvtdatetime(curdate,curtime3), xm.release_prsnl_id = reqinfo->updt_id,
       xm.release_qty =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((quantity_val <= request->productlist[prod].release_qty)) 0
       ELSE request->productlist[prod].release_qty
       ENDIF
       , xm.crossmatch_qty =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((quantity_val=request->productlist[prod].release_qty)) 0
       ELSE (quantity_val - request->productlist[prod].release_qty)
       ENDIF
       , xm.updt_cnt = (xm.updt_cnt+ 1),
       xm.updt_dt_tm = cnvtdatetime(curdate,curtime3), xm.updt_task = reqinfo->updt_task, xm.updt_id
        = reqinfo->updt_id,
       xm.updt_applctx = reqinfo->updt_applctx, xm.active_ind =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((quantity_val <= request->productlist[prod].release_qty)) 0
       ELSE 1
       ENDIF
       , xm.active_status_cd =
       IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
       ELSEIF ((quantity_val <= request->productlist[prod].release_qty)) reqdata->inactive_status_cd
       ELSE reqdata->active_status_cd
       ENDIF
       ,
       xm.active_status_dt_tm = cnvtdatetime(curdate,curtime3), xm.active_status_prsnl_id = reqinfo->
       updt_id
      PLAN (xm
       WHERE (xm.product_event_id=request->productlist[prod].assgn_prod_event_id)
        AND (xm.product_id=request->productlist[prod].product_id)
        AND (xm.updt_cnt=request->productlist[prod].as_updt_cnt))
      WITH counter
     ;end update
     IF (curqual=0)
      SET error_process = "update crossmatch"
      SET error_message = "crossmatch not updated"
      SET failure_occured = "T"
     ELSE
      UPDATE  FROM product_event pe
       SET pe.active_ind =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((quantity_val <= request->productlist[prod].release_qty)) 0
        ELSE 1
        ENDIF
        , pe.active_status_cd =
        IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
        ELSEIF ((quantity_val <= request->productlist[prod].release_qty)) reqdata->inactive_status_cd
        ELSE reqdata->active_status_cd
        ENDIF
        , pe.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        pe.active_status_prsnl_id = reqinfo->updt_id, pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm
         = cnvtdatetime(curdate,curtime3),
        pe.updt_task = reqinfo->updt_task, pe.updt_id = reqinfo->updt_id, pe.updt_applctx = reqinfo->
        updt_applctx
       PLAN (pe
        WHERE (pe.product_event_id=request->productlist[prod].assgn_prod_event_id)
         AND (pe.product_id=request->productlist[prod].product_id)
         AND pe.event_type_cd=xmtch_event_type_cd
         AND (pe.updt_cnt=request->productlist[prod].pe_as_updt_cnt))
       WITH counter
      ;end update
      IF (curqual=0)
       SET error_process = "update event"
       SET error_message = "crossmatch product_event not updated"
       SET failure_occured = "T"
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF ((request->productlist[prod].rel_in_progress_flag="T")
     AND failure_occured="F")
     CALL chg_product_event(request->productlist[prod].assgn_prod_event_id,cnvtdatetime(curdate,
       curtime3),reqinfo->updt_id,0,0,
      reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->
      productlist[prod].pe_as_updt_cnt,1,
      0)
     IF (gsub_product_event_status != "OK")
      SET error_process = "update event"
      SET error_message = "in progress product_event not updated"
      SET failure_occured = "T"
     ENDIF
    ENDIF
   ENDIF
   IF (failure_occured="F"
    AND ((active_quar="F"
    AND active_uncfrm="F"
    AND active_auto="F"
    AND active_dir="F"
    AND active_disp="F"
    AND active_transfuse="F"
    AND active_dispose="F"
    AND active_destroy="F"
    AND active_shipped="F"
    AND active_intransit="F"
    AND multiple_xm="F"
    AND ((active_assign="F") OR (active_assign="T"
    AND active_xm="F"))
    AND (request->productlist[prod].product_type="B")) OR ((request->productlist[prod].product_type=
   "D")))
    AND active_avail="F")
    CALL add_product_event(request->productlist[prod].product_id,0,0,0,0,
     avail_event_type_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
     0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id)
    IF (curqual=0)
     SET error_process = "add product_event"
     SET error_message = "available product_event row not added for assign"
     SET failure_occured = "T"
    ENDIF
   ENDIF
   IF (failure_occured="F"
    AND (request->productlist[prod].product_type="D"))
    UPDATE  FROM derivative der
     SET der.cur_avail_qty = (der.cur_avail_qty+ request->productlist[prod].release_qty), der
      .cur_intl_units = (der.cur_intl_units+ request->productlist[prod].release_iu), der.updt_cnt =
      IF (other_events="F") (der.updt_cnt+ 1)
      ELSE der.updt_cnt
      ENDIF
      ,
      der.updt_dt_tm = cnvtdatetime(curdate,curtime3), der.updt_task = reqinfo->updt_task, der
      .updt_id = reqinfo->updt_id,
      der.updt_applctx = reqinfo->updt_applctx
     PLAN (der
      WHERE (der.product_id=request->productlist[prod].product_id)
       AND (der.updt_cnt=request->productlist[prod].der_updt_cnt))
     WITH counter
    ;end update
    IF (curqual=0)
     SET error_process = "updt derivative"
     SET error_message = "available qty not updated on derivative"
     SET failure_occured = "T"
    ENDIF
   ENDIF
   IF ((request->productlist[prod].keep_lock_ind=0))
    CALL unlock_product(0)
   ENDIF
   IF (failure_occured="F")
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus[prod].operationname = "Complete"
    SET reply->status_data.subeventstatus[prod].operationstatus = "S"
    SET reply->status_data.subeventstatus[prod].targetobjectname = "Tables Updated"
    SET reply->status_data.subeventstatus[prod].targetobjectvalue = "S"
    SET reply->results[prod].product_event_id = request->productlist[prod].assgn_prod_event_id
    SET reply->results[prod].status = "S"
    SET reply->results[prod].err_process = "complete"
    SET reply->results[prod].err_message = "no errors"
    SET success_cnt = (success_cnt+ 1)
   ELSE
    SET reply->status_data.subeventstatus[prod].operationname = error_process
    SET reply->status_data.subeventstatus[prod].operationstatus = "F"
    SET reply->status_data.subeventstatus[prod].targetobjectname = error_message
    SET reply->status_data.subeventstatus[prod].targetobjectvalue = "F"
    SET reply->results[prod].product_event_id = request->productlist[prod].assgn_prod_event_id
    SET reply->results[prod].status = "F"
    SET reply->results[prod].err_process = error_process
    SET reply->results[prod].err_message = error_message
   ENDIF
 ENDFOR
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
 SUBROUTINE unlock_product(none)
   IF (failure_occured="F"
    AND other_events="F")
    SELECT INTO "nl:"
     p.product_id
     FROM product p
     PLAN (p
      WHERE (p.product_id=request->productlist[prod].product_id)
       AND (p.updt_cnt=request->productlist[prod].p_updt_cnt)
       AND p.locked_ind=1)
     WITH nocounter, forupdate(p)
    ;end select
    IF (curqual=0)
     SET error_process = "update product"
     SET error_message = "product not locked"
     SET failure_occured = "T"
    ELSE
     UPDATE  FROM product p
      SET p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
       updt_applctx
      PLAN (p
       WHERE (p.product_id=request->productlist[prod].product_id)
        AND (p.updt_cnt=request->productlist[prod].p_updt_cnt)
        AND p.locked_ind=1)
      WITH counter
     ;end update
     IF (curqual=0)
      SET error_process = "update product"
      SET error_message = "product not updated"
      SET failure_occured = "T"
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 IF (success_cnt < nbr_to_update)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#end_script
END GO
