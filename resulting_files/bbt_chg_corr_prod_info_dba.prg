CREATE PROGRAM bbt_chg_corr_prod_info:dba
 RECORD reply(
   1 qual[*]
     2 product_id = f8
     2 product_nbr = c20
     2 product_sub_nbr = c5
   1 newautodirevents[*]
     2 product_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE insertbasecorrectedproductrow(null) = null
 SET count1 = 0
 SET count2 = 0
 SET y = 0
 SET next_code = 0.0
 DECLARE corr_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET failed = "F"
 DECLARE new_event_type_cd = f8 WITH protected, noconstant(0.0)
 DECLARE ce_supplier_prefix = c5 WITH protected, noconstant("")
 DECLARE ce_product_nbr = c20 WITH protected, noconstant("")
 DECLARE ce_product_sub_nbr = c5 WITH protected, noconstant("")
 DECLARE ce_new_product_nbr = vc WITH protected, noconstant("")
 DECLARE ce_old_supplier_prefix = c5 WITH protected, noconstant("")
 DECLARE ce_old_product_nbr = c20 WITH protected, noconstant("")
 DECLARE ce_old_product_sub_nbr = c5 WITH protected, noconstant("")
 DECLARE pi_product_cd = f8 WITH protected, noconstant(0.0)
 DECLARE bp_auto_ind = i2 WITH protected, noconstant(0)
 DECLARE bp_dir_ind = i2 WITH protected, noconstant(0)
 DECLARE new_product_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE autodirpersonlistcnt = i4 WITH protect, noconstant(0)
 DECLARE idxautodirperson = i4 WITH protect, noconstant(0)
 DECLARE event_cnt = i4 WITH noconstant(0)
 SET chg_demogr_cd = 0.0
 SET emerg_dispense_cd = 0.0
 SET chg_state_cd = 0.0
 SET unlock_prod_cd = 0.0
 SET spec_test_cd = 0.0
 SET chg_pool_cd = 0.0
 SET chg_reconrbc_cd = 0.0
 SET chg_disp_prod_order_cd = 0.0
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=14115
   AND c.active_ind=1
  DETAIL
   IF (c.cdf_meaning="DEMOG")
    chg_demogr_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="ERDIS")
    emerg_dispense_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="STATE")
    chg_state_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="UNLOCK")
    unlock_prod_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="SPECTEST")
    spec_test_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="POOL")
    chg_pool_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="RECONRBC")
    chg_reconrbc_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="DISPPRODORD")
    chg_disp_prod_order_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE next_pathnet_seq(pathnet_seq_dummy) = f8
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SUBROUTINE next_pathnet_seq(pathnet_seq_dummy)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   RETURN(new_pathnet_seq)
 END ;Subroutine
 FOR (count1 = 1 TO request->product_count)
   SELECT INTO "nl:"
    p.*
    FROM product p
    WHERE (p.product_id=request->qual[count1].product_id)
     AND (p.updt_cnt=request->qual[count1].updt_cnt)
     AND p.active_ind=1
    WITH counter, forupdate(p)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET count2 += 1
    SET stat = alterlist(reply->qual,count2)
    SET reply->qual[count2].product_id = request->qual[count1].product_id
    SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
    SET reply->status_data.subeventstatus[count2].operationname = "Lock"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "Product"
    SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[count1].
     product_id)
    GO TO exit_script
   ELSE
    UPDATE  FROM product p
     SET p.product_nbr =
      IF ((request->qual[count1].new_product_nbr="-1")) p.product_nbr
      ELSE request->qual[count1].new_product_nbr
      ENDIF
      , p.barcode_nbr =
      IF ((request->qual[count1].new_barcode_nbr="-1")) p.barcode_nbr
      ELSE request->qual[count1].new_barcode_nbr
      ENDIF
      , p.product_sub_nbr =
      IF ((request->qual[count1].new_product_sub_nbr="-1")) p.product_sub_nbr
      ELSE request->qual[count1].new_product_sub_nbr
      ENDIF
      ,
      p.flag_chars =
      IF ((request->qual[count1].new_flag_chars="-1")) p.flag_chars
      ELSE request->qual[count1].new_flag_chars
      ENDIF
      , p.alternate_nbr =
      IF ((request->qual[count1].new_alt_nbr="-1")) p.alternate_nbr
      ELSE cnvtupper(request->qual[count1].new_alt_nbr)
      ENDIF
      , p.product_cd =
      IF ((request->qual[count1].new_product_cd=- (1))) p.product_cd
      ELSE request->qual[count1].new_product_cd
      ENDIF
      ,
      p.product_class_cd =
      IF ((request->qual[count1].new_product_class_cd=- (1))) p.product_class_cd
      ELSE request->qual[count1].new_product_class_cd
      ENDIF
      , p.product_cat_cd =
      IF ((request->qual[count1].new_product_cat_cd=- (1))) p.product_cat_cd
      ELSE request->qual[count1].new_product_cat_cd
      ENDIF
      , p.cur_supplier_id =
      IF ((request->qual[count1].new_supplier_id=- (1))) p.cur_supplier_id
      ELSE request->qual[count1].new_supplier_id
      ENDIF
      ,
      p.recv_dt_tm =
      IF ((request->qual[count1].new_recv_dt_tm=- (1))) p.recv_dt_tm
      ELSE cnvtdatetime(request->qual[count1].new_recv_dt_tm)
      ENDIF
      , p.cur_unit_meas_cd =
      IF ((request->qual[count1].new_unit_of_meas_cd=- (1))) p.cur_unit_meas_cd
      ELSE request->qual[count1].new_unit_of_meas_cd
      ENDIF
      , p.cur_expire_dt_tm =
      IF ((request->qual[count1].new_exp_dt_tm=- (1))) p.cur_expire_dt_tm
      ELSE cnvtdatetime(request->qual[count1].new_exp_dt_tm)
      ENDIF
      ,
      p.locked_ind = 0, p.cur_owner_area_cd =
      IF ((request->qual[count1].new_owner_area_cd=- (1))) p.cur_owner_area_cd
      ELSE request->qual[count1].new_owner_area_cd
      ENDIF
      , p.cur_inv_area_cd =
      IF ((request->qual[count1].new_inv_area_cd=- (1))) p.cur_inv_area_cd
      ELSE request->qual[count1].new_inv_area_cd
      ENDIF
      ,
      p.storage_temp_cd =
      IF ((request->qual[count1].new_storage_temp_cd=- (1))) p.storage_temp_cd
      ELSE request->qual[count1].new_storage_temp_cd
      ENDIF
      , p.electronic_entry_flag =
      IF ((request->qual[count1].new_electronic_entry_flag=- (1))) p.electronic_entry_flag
      ELSE request->qual[count1].new_electronic_entry_flag
      ENDIF
      , p.donation_type_cd =
      IF ((request->qual[count1].new_donation_type_cd=- (1))) p.donation_type_cd
      ELSE request->qual[count1].new_donation_type_cd
      ENDIF
      ,
      p.disease_cd =
      IF ((request->qual[count1].new_disease_cd=- (1))) p.disease_cd
      ELSE request->qual[count1].new_disease_cd
      ENDIF
      , p.serial_number_txt =
      IF ((request->qual[count1].new_serial_nbr="-1")) p.serial_number_txt
      ELSE request->qual[count1].new_serial_nbr
      ENDIF
      , p.updt_cnt = (request->qual[count1].updt_cnt+ 1),
      p.corrected_ind = 1, p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id,
      p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p
      .intended_use_print_parm_txt =
      IF ((request->qual[count1].new_intended_use="-")) p.intended_use_print_parm_txt
      ELSE request->qual[count1].new_intended_use
      ENDIF
      ,
      p.product_type_barcode =
      IF ((request->qual[count1].new_product_type_barcode="-1")) p.product_type_barcode
      ELSE request->qual[count1].new_product_type_barcode
      ENDIF
     WHERE (p.product_id=request->qual[count1].product_id)
      AND (p.updt_cnt=request->qual[count1].updt_cnt)
      AND p.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET count2 += 1
     SET stat = alterlist(reply->qual,count2)
     SET reply->qual[count2].product_id = request->qual[count1].product_id
     SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
     SET reply->status_data.subeventstatus[count2].operationname = "update"
     SET reply->status_data.subeventstatus[count2].operationstatus = "F"
     SET reply->status_data.subeventstatus[count2].targetobjectname = "product"
     SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[count1].
      product_id)
     GO TO exit_script
    ELSE
     IF ((request->qual[1].update_child="T"))
      IF ((request->derivative_ind="T"))
       SELECT INTO "nl:"
        d.*
        FROM derivative d
        WHERE (d.product_id=request->qual[count1].product_id)
         AND (d.updt_cnt=request->qual[count1].child_updt_cnt)
         AND d.active_ind=1
        WITH counter, forupdate(d)
       ;end select
       IF (curqual=0)
        SET failed = "T"
        SET count2 += 1
        SET stat = alterlist(reply->qual,count2)
        SET reply->qual[count2].product_id = request->qual[count1].product_id
        SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
        SET reply->status_data.subeventstatus[count2].operationname = "Lock"
        SET reply->status_data.subeventstatus[count2].operationstatus = "F"
        SET reply->status_data.subeventstatus[count2].targetobjectname = "Derivative"
        SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[count1]
         .product_id)
        GO TO exit_script
       ELSE
        UPDATE  FROM derivative d
         SET d.item_volume =
          IF ((request->qual[count1].new_volume=- (1))) d.item_volume
          ELSE request->qual[count1].new_volume
          ENDIF
          , d.item_unit_meas_cd =
          IF ((request->qual[count1].new_unit_of_meas_cd=- (1))) d.item_unit_meas_cd
          ELSE request->qual[count1].new_unit_of_meas_cd
          ENDIF
          , d.product_cd =
          IF ((request->qual[count1].new_product_cd=- (1))) d.product_cd
          ELSE request->qual[count1].new_product_cd
          ENDIF
          ,
          d.manufacturer_id =
          IF ((request->qual[count1].new_manu_id=- (1))) d.manufacturer_id
          ELSE request->qual[count1].new_manu_id
          ENDIF
          , d.cur_intl_units =
          IF ((request->qual[count1].new_ius=- (1))) d.cur_intl_units
          ELSE request->qual[count1].new_ius
          ENDIF
          , d.cur_avail_qty =
          IF ((request->qual[count1].new_qty=- (1))) d.cur_avail_qty
          ELSE request->qual[count1].new_qty
          ENDIF
          ,
          d.units_per_vial =
          IF ((request->qual[count1].new_units_per_vial=- (1))) d.units_per_vial
          ELSE request->qual[count1].new_units_per_vial
          ENDIF
          , d.updt_cnt = (request->qual[count1].child_updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(
           sysdate),
          d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
          updt_applctx
         WHERE (d.product_id=request->qual[count1].product_id)
          AND (d.updt_cnt=request->qual[count1].child_updt_cnt)
          AND d.active_ind=1
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET failed = "T"
         SET count2 += 1
         SET stat = alterlist(reply->qual,count2)
         SET reply->qual[count2].product_id = request->qual[count1].product_id
         SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
         SET reply->status_data.subeventstatus[count2].operationname = "update"
         SET reply->status_data.subeventstatus[count2].operationstatus = "F"
         SET reply->status_data.subeventstatus[count2].targetobjectname = "derivative"
         SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[count1
          ].product_id)
         GO TO exit_script
        ENDIF
       ENDIF
      ELSE
       IF ((request->qual[count1].new_product_cd=- (1)))
        SELECT INTO "nl:"
         p.product_cd
         FROM product p
         PLAN (p
          WHERE (p.product_id=request->qual[count1].product_id))
         DETAIL
          pi_product_cd = p.product_cd
         WITH nocounter
        ;end select
       ELSE
        SET pi_product_cd = request->qual[count1].new_product_cd
       ENDIF
       SELECT INTO "nl:"
        pi.*
        FROM product_index pi
        PLAN (pi
         WHERE pi.product_cd=pi_product_cd)
        DETAIL
         bp_auto_ind = pi.autologous_ind, bp_dir_ind = pi.directed_ind
       ;end select
       SELECT INTO "nl:"
        bp.*
        FROM blood_product bp
        WHERE (bp.product_id=request->qual[count1].product_id)
         AND (bp.updt_cnt=request->qual[count1].child_updt_cnt)
         AND bp.active_ind=1
        WITH counter, forupdate(bp)
       ;end select
       IF (curqual=0)
        SET failed = "T"
        SET count2 += 1
        SET stat = alterlist(reply->qual,count2)
        SET reply->qual[count2].product_id = request->qual[count1].product_id
        SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
        SET reply->status_data.subeventstatus[count2].operationname = "Lock"
        SET reply->status_data.subeventstatus[count2].operationstatus = "F"
        SET reply->status_data.subeventstatus[count2].targetobjectname = "Blood Product"
        SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[count1]
         .product_id)
        GO TO exit_script
       ELSE
        UPDATE  FROM blood_product bp
         SET bp.supplier_prefix =
          IF ((request->qual[count1].new_supplier_prefix="-1")) bp.supplier_prefix
          ELSE request->qual[count1].new_supplier_prefix
          ENDIF
          , bp.cur_volume =
          IF ((request->qual[count1].new_volume=- (1))) bp.cur_volume
          ELSE request->qual[count1].new_volume
          ENDIF
          , bp.cur_abo_cd =
          IF ((request->qual[count1].new_abo_cd=- (1))) bp.cur_abo_cd
          ELSE request->qual[count1].new_abo_cd
          ENDIF
          ,
          bp.cur_rh_cd =
          IF ((request->qual[count1].new_rh_cd=- (1))) bp.cur_rh_cd
          ELSE request->qual[count1].new_rh_cd
          ENDIF
          , bp.segment_nbr =
          IF ((request->qual[count1].new_segment_nbr="-1")) bp.segment_nbr
          ELSE request->qual[count1].new_segment_nbr
          ENDIF
          , bp.product_cd =
          IF ((request->qual[count1].new_product_cd=- (1))) bp.product_cd
          ELSE request->qual[count1].new_product_cd
          ENDIF
          ,
          bp.drawn_dt_tm =
          IF ((request->qual[count1].new_drawn_dt_tm=- (1))) bp.drawn_dt_tm
          ELSE cnvtdatetime(request->qual[count1].new_drawn_dt_tm)
          ENDIF
          , bp.autologous_ind = bp_auto_ind, bp.directed_ind = bp_dir_ind,
          bp.updt_cnt = (request->qual[count1].child_updt_cnt+ 1), bp.updt_dt_tm = cnvtdatetime(
           sysdate), bp.updt_id = reqinfo->updt_id,
          bp.updt_task = reqinfo->updt_task, bp.updt_applctx = reqinfo->updt_applctx
         WHERE (bp.product_id=request->qual[count1].product_id)
          AND (bp.updt_cnt=request->qual[count1].child_updt_cnt)
          AND bp.active_ind=1
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET failed = "T"
         SET count2 += 1
         SET stat = alterlist(reply->qual,count2)
         SET reply->qual[count2].product_id = request->qual[count1].product_id
         SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
         SET reply->status_data.subeventstatus[count2].operationname = "update"
         SET reply->status_data.subeventstatus[count2].operationstatus = "F"
         SET reply->status_data.subeventstatus[count2].targetobjectname = "Blood Product"
         SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[count1
          ].product_id)
         GO TO exit_script
        ELSE
         IF ((request->qual[count1].receipt_product_event_id > 0)
          AND (request->qual[count1].receipt_product_event_id != null))
          SELECT INTO "nl:"
           r.*
           FROM receipt r
           WHERE (r.product_event_id=request->qual[count1].receipt_product_event_id)
            AND (r.updt_cnt=request->qual[count1].receipt_updt_cnt)
           WITH counter, forupdate(r)
          ;end select
          IF (curqual=0)
           SET failed = "T"
           SET count2 += 1
           SET stat = alterlist(reply->qual,count2)
           SET reply->qual[count2].product_id = request->qual[count1].product_id
           SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
           SET reply->status_data.subeventstatus[count2].operationname = "Lock"
           SET reply->status_data.subeventstatus[count2].operationstatus = "F"
           SET reply->status_data.subeventstatus[count2].targetobjectname = "Receipt"
           SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[
            count1].product_id)
           GO TO exit_script
          ELSE
           UPDATE  FROM receipt r
            SET r.bb_supplier_id =
             IF ((request->qual[count1].new_orig_supplier_id=- (1))) r.bb_supplier_id
             ELSE request->qual[count1].new_orig_supplier_id
             ENDIF
             , r.alpha_translation_id =
             IF ((request->qual[count1].alpha_translation_id=- (1))) r.alpha_translation_id
             ELSE request->qual[count1].alpha_translation_id
             ENDIF
             , r.vis_insp_cd =
             IF ((request->qual[count1].new_orig_vis_insp_cd=- (1))) r.vis_insp_cd
             ELSE request->qual[count1].new_orig_vis_insp_cd
             ENDIF
             ,
             r.ship_cond_cd =
             IF ((request->qual[count1].new_orig_ship_cond_cd=- (1))) r.ship_cond_cd
             ELSE request->qual[count1].new_orig_ship_cond_cd
             ENDIF
             , r.updt_cnt = (request->qual[count1].receipt_updt_cnt+ 1), r.updt_dt_tm = cnvtdatetime(
              sysdate),
             r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo
             ->updt_applctx
            WHERE (r.product_id=request->qual[count1].product_id)
             AND (r.updt_cnt=request->qual[count1].receipt_updt_cnt)
            WITH nocounter
           ;end update
           IF (curqual=0)
            SET failed = "T"
            SET count2 += 1
            SET stat = alterlist(reply->qual,count2)
            SET reply->qual[count2].product_id = request->qual[count1].product_id
            SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
            SET reply->status_data.subeventstatus[count2].operationname = "update"
            SET reply->status_data.subeventstatus[count2].operationstatus = "F"
            SET reply->status_data.subeventstatus[count2].targetobjectname = "Receipt"
            SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[
             count1].product_id)
            GO TO exit_script
           ENDIF
           IF ((request->qual[count1].new_recv_dt_tm != - (1)))
            SELECT INTO "nl:"
             FROM product_event pv
             WHERE (pv.product_event_id=request->qual[count1].receipt_product_event_id)
              AND pv.active_ind=0
             WITH nocounter, forupdate(pv)
            ;end select
            IF (curqual != 0)
             UPDATE  FROM product_event pe
              SET pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id
                = reqinfo->updt_id,
               pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe
               .event_dt_tm = cnvtdatetime(request->qual[count1].new_recv_dt_tm)
              WHERE (pe.product_event_id=request->qual[count1].receipt_product_event_id)
             ;end update
             IF (curqual=0)
              SET count2 += 1
              SET stat = alterlist(reply->status_data.subeventstatus,count2)
              SET reply->status_data.subeventstatus[count2].operationname =
              "Error updating the received event."
              SET reply->status_data.subeventstatus[count2].operationstatus = "F"
              SET reply->status_data.subeventstatus[count2].targetobjectname = "product_event"
              SET reply->status_data.subeventstatus[count2].targetobjectvalue = new_product_event_id
              SET failed = "T"
              GO TO exit_script
             ENDIF
            ELSE
             SET count2 += 1
             SET stat = alterlist(reply->status_data.subeventstatus,count2)
             SET reply->status_data.subeventstatus[count2].operationname =
             "Lock table for updating received event."
             SET reply->status_data.subeventstatus[count2].operationstatus = "F"
             SET reply->status_data.subeventstatus[count2].targetobjectname = "product_event"
             SET reply->status_data.subeventstatus[count2].targetobjectvalue = request->qual[count1].
             product_id
             SET failed = "T"
             GO TO exit_script
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     SET autodirpersonlistcnt = size(request->qual[count1].autodirpersonlist,5)
     IF (autodirpersonlistcnt=0)
      IF ((((request->qual[count1].inactivate_event_id > 0.0)) OR ((((request->qual[count1].
      add_state_mean="10")) OR ((((request->qual[count1].add_state_mean="11")) OR ((request->qual[
      count1].product_event_id > 0.0))) )) )) )
       IF ((request->qual[count1].inactivate_event_id > 0.0)
        AND (((request->qual[count1].add_state_mean="10")) OR ((request->qual[count1].add_state_mean=
       "11"))) )
        SET autodirpersonlistcnt = 2
       ELSE
        SET autodirpersonlistcnt = 1
       ENDIF
       SET stat = alterlist(request->qual[count1].autodirpersonlist,autodirpersonlistcnt)
       IF (autodirpersonlistcnt=1)
        IF ((((request->qual[count1].add_state_mean="10")) OR ((request->qual[count1].add_state_mean=
        "11"))) )
         SET request->qual[count1].autodirpersonlist[1].add_change_ind = 1
         SET request->qual[count1].autodirpersonlist[1].old_person_id = - (1.0)
         SET request->qual[count1].autodirpersonlist[1].old_encntr_id = - (1.0)
         SET request->qual[count1].autodirpersonlist[1].old_usage_dt_tm = 0
        ELSE
         SET request->qual[count1].autodirpersonlist[1].add_change_ind = 2
         IF ((((request->qual[count1].old_person_id=request->qual[count1].new_person_id)) OR ((
         request->qual[count1].new_person_id=0.0))) )
          SET request->qual[count1].autodirpersonlist[1].old_person_id = - (1.0)
         ELSE
          SET request->qual[count1].autodirpersonlist[1].old_person_id = request->qual[count1].
          old_person_id
         ENDIF
         IF ((((request->qual[count1].old_encntr_id=request->qual[count1].new_encntr_id)) OR ((
         request->qual[count1].new_encntr_id=0.0))) )
          SET request->qual[count1].autodirpersonlist[1].old_encntr_id = - (1.0)
         ELSE
          SET request->qual[count1].autodirpersonlist[1].old_encntr_id = request->qual[count1].
          old_encntr_id
         ENDIF
         IF ((((request->qual[count1].old_usage_dt_tm=request->qual[count1].new_usage_dt_tm)) OR ((
         request->qual[count1].new_usage_dt_tm=0))) )
          SET request->qual[count1].autodirpersonlist[1].old_usage_dt_tm = 0
         ELSE
          SET request->qual[count1].autodirpersonlist[1].old_usage_dt_tm = request->qual[count1].
          old_usage_dt_tm
         ENDIF
        ENDIF
        IF ((request->qual[count1].inactivate_event_id > 0.0))
         SET request->qual[count1].autodirpersonlist[1].active_ind = 0
         SET request->qual[count1].autodirpersonlist[1].product_event_id = request->qual[count1].
         inactivate_event_id
        ELSE
         SET request->qual[count1].autodirpersonlist[1].active_ind = 1
         SET request->qual[count1].autodirpersonlist[1].product_event_id = request->qual[count1].
         product_event_id
        ENDIF
        SET request->qual[count1].autodirpersonlist[1].add_state_mean = request->qual[count1].
        add_state_mean
        SET request->qual[count1].autodirpersonlist[1].ad_updt_cnt = request->qual[count1].
        ad_updt_cnt
        SET request->qual[count1].autodirpersonlist[1].pe_updt_cnt = request->qual[count1].
        pe_updt_cnt
        SET request->qual[count1].autodirpersonlist[1].new_person_id = request->qual[count1].
        new_person_id
        SET request->qual[count1].autodirpersonlist[1].new_encntr_id = request->qual[count1].
        new_encntr_id
        SET request->qual[count1].autodirpersonlist[1].new_usage_dt_tm = request->qual[count1].
        new_usage_dt_tm
        SET request->qual[count1].autodirpersonlist[1].new_relative_ind = request->qual[count1].
        new_relative_ind
        SET request->qual[count1].autodirpersonlist[1].old_relative_ind = - (1)
       ELSE
        SET request->qual[count1].autodirpersonlist[1].add_change_ind = 1
        SET request->qual[count1].autodirpersonlist[1].active_ind = 1
        SET request->qual[count1].autodirpersonlist[1].add_state_mean = request->qual[count1].
        add_state_mean
        SET request->qual[count1].autodirpersonlist[1].product_event_id = - (1.0)
        SET request->qual[count1].autodirpersonlist[1].ad_updt_cnt = - (1.0)
        SET request->qual[count1].autodirpersonlist[1].pe_updt_cnt = - (1.0)
        SET request->qual[count1].autodirpersonlist[1].new_person_id = request->qual[count1].
        new_person_id
        SET request->qual[count1].autodirpersonlist[1].new_encntr_id = request->qual[count1].
        new_encntr_id
        SET request->qual[count1].autodirpersonlist[1].new_usage_dt_tm = request->qual[count1].
        new_usage_dt_tm
        SET request->qual[count1].autodirpersonlist[1].new_relative_ind = request->qual[count1].
        new_relative_ind
        SET request->qual[count1].autodirpersonlist[1].old_person_id = - (1.0)
        SET request->qual[count1].autodirpersonlist[1].old_encntr_id = - (1.0)
        SET request->qual[count1].autodirpersonlist[1].old_usage_dt_tm = 0
        SET request->qual[count1].autodirpersonlist[1].old_relative_ind = - (1)
        SET request->qual[count1].autodirpersonlist[2].add_change_ind = 2
        SET request->qual[count1].autodirpersonlist[2].active_ind = 0
        SET request->qual[count1].autodirpersonlist[2].add_state_mean = ""
        SET request->qual[count1].autodirpersonlist[2].product_event_id = request->qual[count1].
        inactivate_event_id
        SET request->qual[count1].autodirpersonlist[2].ad_updt_cnt = request->qual[count1].
        ad_updt_cnt
        SET request->qual[count1].autodirpersonlist[2].pe_updt_cnt = request->qual[count1].
        pe_updt_cnt
        SET request->qual[count1].autodirpersonlist[2].new_person_id = - (1.0)
        SET request->qual[count1].autodirpersonlist[2].new_encntr_id = - (1.0)
        SET request->qual[count1].autodirpersonlist[2].new_usage_dt_tm = 0
        SET request->qual[count1].autodirpersonlist[2].new_relative_ind = - (1.0)
        SET request->qual[count1].autodirpersonlist[2].old_person_id = - (1.0)
        SET request->qual[count1].autodirpersonlist[2].old_encntr_id = - (1.0)
        SET request->qual[count1].autodirpersonlist[2].old_usage_dt_tm = 0
        SET request->qual[count1].autodirpersonlist[2].old_relative_ind = - (1)
       ENDIF
      ENDIF
     ENDIF
     CALL insertbasecorrectedproductrow(null)
     FOR (idxautodirperson = 1 TO autodirpersonlistcnt)
       CALL insertautodircorrectedproductrow(request->qual[count1].autodirpersonlist[idxautodirperson
        ].active_ind,request->qual[count1].autodirpersonlist[idxautodirperson].product_event_id,
        request->qual[count1].autodirpersonlist[idxautodirperson].old_person_id,request->qual[count1]
        .autodirpersonlist[idxautodirperson].old_encntr_id,request->qual[count1].autodirpersonlist[
        idxautodirperson].old_usage_dt_tm,
        request->qual[count1].autodirpersonlist[idxautodirperson].old_relative_ind)
     ENDFOR
    ENDIF
   ENDIF
   SET quar_event_cd = 0.0
   SET avail_event_cd = 0.0
   SET auto_event_cd = 0.0
   SET dir_event_cd = 0.0
   SET dispose_reason_cd = 0.0
   SET destroy_method_cd = 0.0
   SET unconf_event_cd = 0.0
   DECLARE assigned_event_cd = f8 WITH protected, noconstant(0.0)
   DECLARE destroyed_event_cd = f8 WITH protected, noconstant(0.0)
   DECLARE inprogress_event_cd = f8 WITH protected, noconstant(0.0)
   DECLARE crossmatched_event_cd = f8 WITH protected, noconstant(0.0)
   DECLARE dispensed_event_cd = f8 WITH protected, noconstant(0.0)
   DECLARE disposed_event_cd = f8 WITH protected, noconstant(0.0)
   DECLARE transfused_event_cd = f8 WITH protected, noconstant(0.0)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"2",cv_cnt,quar_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"9",cv_cnt,unconf_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"10",cv_cnt,auto_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"11",cv_cnt,dir_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"12",cv_cnt,avail_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1608,"CORRECTED",cv_cnt,dispose_reason_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1609,"CORRECTED",cv_cnt,destroy_method_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"1",cv_cnt,assigned_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"14",cv_cnt,destroyed_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"16",cv_cnt,inprogress_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"3",cv_cnt,crossmatched_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"4",cv_cnt,dispensed_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"5",cv_cnt,disposed_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"7",cv_cnt,transfused_event_cd)
   IF (((auto_event_cd=0.0) OR (((dir_event_cd=0.0) OR (((avail_event_cd=0.0) OR (((unconf_event_cd=
   0.0) OR (((quar_event_cd=0.0) OR (((dispose_reason_cd=0.0) OR (((destroy_method_cd=0.0) OR (((
   assigned_event_cd=0.0) OR (((destroyed_event_cd=0.0) OR (((inprogress_event_cd=0.0) OR (((
   crossmatched_event_cd=0.0) OR (((dispensed_event_cd=0.0) OR (((disposed_event_cd=0.0) OR (
   transfused_event_cd=0.0)) )) )) )) )) )) )) )) )) )) )) )) )) )
    SET failed = "T"
    SET reply->status_data.status = "F"
    SET count2 += 1
    IF (count2 > 1)
     SET stat = alter(reply->status_data.subeventstatus,(count2+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "code_value"
    IF (quar_event_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get quarantined event code value"
    ELSEIF (unconf_event_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get unconfirmed event code value"
    ELSEIF (auto_event_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get autologous event code value"
    ELSEIF (dir_event_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get directed event code value"
    ELSEIF (avail_event_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get available event code value"
    ELSEIF (dispose_reason_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get dispose reason code value"
    ELSEIF (destroy_method_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname =
     "get destruction method code value"
    ELSEIF (assigned_event_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get assigned event code value"
    ELSEIF (destroyed_event_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get destroyed event code value"
    ELSEIF (inprogress_event_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get in progress event code value"
    ELSEIF (crossmatched_event_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get crossmatch event code value"
    ELSEIF (dispensed_event_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get dispensed event code value"
    ELSEIF (disposed_event_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get disposed event code value"
    ELSEIF (transfused_event_cd=0.0)
     SET reply->status_data.subeventstatus[count2].operationname = "get transfused event code value"
    ENDIF
    GO TO exit_script
   ENDIF
   IF ((request->qual[count1].quarantine_ind=1))
    IF ((request->qual[count1].orig_prod_avail_id > 0))
     SELECT INTO "nl:"
      FROM product_event pv
      WHERE (pv.product_event_id=request->qual[count1].orig_prod_avail_id)
       AND (pv.updt_cnt=request->qual[count1].avail_event_updt_cnt)
       AND pv.active_ind=1
      WITH nocounter, forupdate(pv)
     ;end select
     IF (curqual != 0)
      UPDATE  FROM product_event pe
       SET pe.active_ind = 0, pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate),
        pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
        updt_applctx
       WHERE (pe.product_event_id=request->qual[count1].orig_prod_avail_id)
      ;end update
      IF (curqual=0)
       SET count2 += 1
       SET stat = alterlist(reply->status_data.subeventstatus,count2)
       SET reply->status_data.subeventstatus[count2].operationname = "update state to inactive"
       SET reply->status_data.subeventstatus[count2].operationstatus = "F"
       SET reply->status_data.subeventstatus[count2].targetobjectname = "available product_event"
       SET reply->status_data.subeventstatus[count2].targetobjectvalue = new_product_event_id
       SET failed = "T"
       GO TO exit_script
      ENDIF
     ELSE
      SET count2 += 1
      SET stat = alterlist(reply->status_data.subeventstatus,count2)
      SET reply->status_data.subeventstatus[count2].operationname = "select event for update"
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "available product_event"
      SET reply->status_data.subeventstatus[count2].targetobjectvalue = request->qual[count1].
      product_id
      SET failed = "T"
      GO TO exit_script
     ENDIF
    ENDIF
    SET new_product_event_id = 0.0
    SET gsub_product_event_status = "  "
    CALL add_product_event(request->qual[count1].product_id,0,0,0,0.0,
     quar_event_cd,cnvtdatetime(sysdate),reqinfo->updt_id,0,0,
     0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
     reqinfo->updt_id)
    IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
     SET count2 += 1
     IF (count2 > 1)
      SET stat = alter(reply->status_data.subeventstatus,(count2+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[count2].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[count2].sourceobjectvalue = "bbt_add_blood_product"
     SET reply->status_data.subeventstatus[count2].operationname = "add product event"
     SET reply->status_data.subeventstatus[count2].operationstatus = "F"
     SET reply->status_data.subeventstatus[count2].targetobjectname = "product_event"
     SET reply->status_data.subeventstatus[count2].targetobjectvalue = "add product event"
     SET reply->status_data.subeventstatus[count2].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[count2].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     SET failed = "T"
    ELSE
     SET gsub_quar_status = "  "
     CALL add_quarantine(request->qual[count1].product_id,new_product_event_id,request->qual[count1].
      quar_reason_cd,request->qual[count1].quar_qty)
     IF (gsub_quar_status != "OK")
      SET failed = "T"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF ((request->qual[count1].destroy_product=1))
    SET event_states_added = "I"
    CALL bbt_add_destroyed_event(request->qual[count1].product_id,cnvtdatetime(sysdate),
     dispose_reason_cd,0,0,
     destroy_method_cd,0," "," ",0)
    IF (event_states_added="F")
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   FOR (idxautodirperson = 1 TO autodirpersonlistcnt)
     IF ((request->qual[count1].autodirpersonlist[idxautodirperson].active_ind=0)
      AND (request->qual[count1].autodirpersonlist[idxautodirperson].add_change_ind=2))
      CALL inactivateevent(request->qual[count1].autodirpersonlist[idxautodirperson].product_event_id,
       request->qual[count1].autodirpersonlist[idxautodirperson].pe_updt_cnt,request->qual[count1].
       autodirpersonlist[idxautodirperson].ad_updt_cnt)
     ENDIF
   ENDFOR
   FOR (idxautodirperson = 1 TO autodirpersonlistcnt)
     IF ((request->qual[count1].autodirpersonlist[idxautodirperson].active_ind=1)
      AND (request->qual[count1].autodirpersonlist[idxautodirperson].add_change_ind=1))
      CALL addstate(request->qual[count1].autodirpersonlist[idxautodirperson].add_state_mean,request
       ->qual[count1].autodirpersonlist[idxautodirperson].new_person_id,request->qual[count1].
       autodirpersonlist[idxautodirperson].new_encntr_id,request->qual[count1].autodirpersonlist[
       idxautodirperson].new_usage_dt_tm,request->qual[count1].autodirpersonlist[idxautodirperson].
       new_relative_ind)
      SET event_cnt += 1
      SET stat = alterlist(reply->newautodirevents,event_cnt)
      SET reply->newautodirevents[event_cnt].product_event_id = new_product_event_id
     ENDIF
   ENDFOR
   IF ((request->qual[count1].conf_req_ind=1))
    IF ((request->qual[count1].orig_prod_avail_id > 0.0))
     SELECT INTO "nl:"
      pe.*
      FROM product_event pe
      WHERE (pe.product_event_id=request->qual[count1].orig_prod_avail_id)
       AND (pe.updt_cnt=request->qual[count1].avail_event_updt_cnt)
      WITH nocounter, forupdate(pe)
     ;end select
     IF (curqual != 0)
      UPDATE  FROM product_event p
       SET p.active_ind = 0, p.active_status_cd = reqdata->inactive_status_cd, p.active_status_dt_tm
         = cnvtdatetime(sysdate),
        p.active_status_prsnl_id = reqinfo->updt_id, p.updt_id = reqinfo->updt_id, p.updt_cnt = (p
        .updt_cnt+ 1),
        p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
        cnvtdatetime(sysdate)
       WHERE (p.product_event_id=request->qual[count1].orig_prod_avail_id)
       WITH nocounter
      ;end update
     ELSE
      SET failed = "T"
      SET count2 += 1
      SET stat = alterlist(reply->qual,count2)
      SET reply->qual[count2].product_id = request->qual[count1].product_id
      SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
      SET reply->status_data.subeventstatus[count2].operationname = "Lock"
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "Product_Event"
      SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[count1].
       orig_prod_avail_id)
      GO TO exit_script
     ENDIF
    ENDIF
    IF ((request->qual[count1].orig_prod_conf_id=0.0))
     SET new_product_event_id = 0.0
     SET gsub_product_event_status = "  "
     CALL add_product_event(request->qual[count1].product_id,0,0,0,0.0,
      unconf_event_cd,cnvtdatetime(sysdate),reqinfo->updt_id,0,0,
      0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
      reqinfo->updt_id)
     IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
      SET count2 += 1
      IF (count2 > 1)
       SET stat = alter(reply->status_data.subeventstatus,(count2+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[count2].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[count2].sourceobjectvalue = "bbt_add_blood_product"
      SET reply->status_data.subeventstatus[count2].operationname = "add product event"
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "product_event"
      SET reply->status_data.subeventstatus[count2].targetobjectvalue = "add product event"
      SET reply->status_data.subeventstatus[count2].sourceobjectqual = 1
      SET reply->status_data.subeventstatus[count2].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      SET failed = "T"
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((request->qual[count1].conf_req_ind=- (1)))
    IF ((request->qual[count1].orig_prod_conf_id > 0.0))
     SELECT INTO "nl:"
      pe.*
      FROM product_event pe
      WHERE (pe.product_event_id=request->qual[count1].orig_prod_conf_id)
       AND (pe.updt_cnt=request->qual[count1].unconf_event_updt_cnt)
      WITH nocounter, forupdate(pe)
     ;end select
     IF (curqual != 0)
      UPDATE  FROM product_event p
       SET p.active_ind = 0, p.active_status_cd = reqdata->inactive_status_cd, p.active_status_dt_tm
         = cnvtdatetime(sysdate),
        p.active_status_prsnl_id = reqinfo->updt_id, p.updt_id = reqinfo->updt_id, p.updt_cnt = (p
        .updt_cnt+ 1),
        p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
        cnvtdatetime(sysdate)
       WHERE (p.product_event_id=request->qual[count1].orig_prod_conf_id)
       WITH nocounter
      ;end update
     ELSE
      SET failed = "T"
      SET count2 += 1
      SET stat = alterlist(reply->qual,count2)
      SET stat = alterlist(reply->status_data.subeventstatus,count2)
      SET reply->qual[count2].product_id = request->qual[count1].product_id
      SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
      SET reply->status_data.subeventstatus[count2].operationname = "Lock"
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "Product_Event"
      SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[count1].
       orig_prod_unconf_id)
      GO TO exit_script
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     pe.product_id
     FROM product_event pe
     WHERE (pe.product_id=request->qual[count1].product_id)
      AND pe.active_ind=1
      AND pe.event_type_cd IN (assigned_event_cd, destroyed_event_cd, inprogress_event_cd,
     quar_event_cd, crossmatched_event_cd,
     dispensed_event_cd, disposed_event_cd, transfused_event_cd)
     DETAIL
      new_event_type_cd = pe.event_type_cd
     WITH nocounter
    ;end select
    IF ((request->qual[count1].orig_prod_avail_id=0.0)
     AND (request->qual[count1].auto_dir_ind != 1)
     AND (request->qual[count1].new_autodir_ind != 1)
     AND new_event_type_cd=0)
     SET new_product_event_id = 0.0
     SET gsub_product_event_status = "  "
     CALL add_product_event(request->qual[count1].product_id,0,0,0,0.0,
      avail_event_cd,cnvtdatetime(sysdate),reqinfo->updt_id,0,0,
      0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
      reqinfo->updt_id)
     IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
      SET count2 += 1
      IF (count2 > 1)
       SET stat = alter(reply->status_data.subeventstatus,(count2+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[count2].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[count2].sourceobjectvalue = "bbt_add_blood_product"
      SET reply->status_data.subeventstatus[count2].operationname = "add product event"
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "product_event"
      SET reply->status_data.subeventstatus[count2].targetobjectvalue = "add product event"
      SET reply->status_data.subeventstatus[count2].sourceobjectqual = 1
      SET reply->status_data.subeventstatus[count2].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      SET failed = "T"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF ((request->qual[count1].auto_dir_ind=1))
    FOR (idxautodirperson = 1 TO autodirpersonlistcnt)
      IF ((request->qual[count1].autodirpersonlist[idxautodirperson].active_ind=1)
       AND (request->qual[count1].autodirpersonlist[idxautodirperson].add_change_ind=2))
       CALL updateautodirevent(request->qual[count1].autodirpersonlist[idxautodirperson].
        product_event_id,request->qual[count1].autodirpersonlist[idxautodirperson].pe_updt_cnt,
        request->qual[count1].autodirpersonlist[idxautodirperson].ad_updt_cnt,request->qual[count1].
        autodirpersonlist[idxautodirperson].new_person_id,request->qual[count1].autodirpersonlist[
        idxautodirperson].new_encntr_id,
        request->qual[count1].autodirpersonlist[idxautodirperson].new_usage_dt_tm,request->qual[
        count1].autodirpersonlist[idxautodirperson].new_relative_ind)
      ENDIF
    ENDFOR
   ENDIF
   IF ((((request->qual[count1].new_supplier_prefix != "-1")) OR ((((request->qual[count1].
   new_product_nbr != "-1")) OR ((request->qual[count1].new_product_sub_nbr != "-1"))) )) )
    SELECT INTO "nl:"
     ce.*
     FROM ce_product ce
     WHERE (ce.product_id=request->qual[count1].product_id)
      AND ce.valid_from_dt_tm <= cnvtdatetime(sysdate)
      AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
     WITH nocounter, forupdate(ce)
    ;end select
    IF (curqual != 0)
     SELECT INTO "nl:"
      pr.product_nbr, pr.product_sub_nbr, bp.supplier_prefix
      FROM product pr,
       blood_product bp
      PLAN (pr
       WHERE (pr.product_id=request->qual[count1].product_id))
       JOIN (bp
       WHERE (bp.product_id= Outerjoin(pr.product_id)) )
      DETAIL
       ce_old_product_nbr = pr.product_nbr, ce_old_product_sub_nbr = pr.product_sub_nbr,
       ce_old_supplier_prefix = bp.supplier_prefix
      WITH nocounter
     ;end select
     IF ((request->qual[count1].new_supplier_prefix="-1"))
      SET ce_supplier_prefix = trim(ce_old_supplier_prefix)
     ELSE
      SET ce_supplier_prefix = trim(request->qual[count1].new_supplier_prefix)
     ENDIF
     IF ((request->qual[count1].new_product_nbr="-1"))
      SET ce_product_nbr = trim(ce_old_product_nbr)
     ELSE
      SET ce_product_nbr = trim(request->qual[count1].new_product_nbr)
     ENDIF
     IF ((request->qual[count1].new_product_sub_nbr="-1"))
      IF (size(ce_old_product_sub_nbr,1) > 0)
       SET ce_product_sub_nbr = trim(ce_old_product_sub_nbr)
      ENDIF
     ELSE
      IF (size(request->qual[count1].new_product_sub_nbr,1) > 0)
       SET ce_product_sub_nbr = trim(request->qual[count1].new_product_sub_nbr)
      ENDIF
     ENDIF
     SET ce_new_product_nbr = concat(trim(ce_supplier_prefix),trim(ce_product_nbr)," ",trim(
       ce_product_sub_nbr))
     UPDATE  FROM ce_product ce
      SET ce.product_nbr = trim(ce_new_product_nbr,3), ce.updt_applctx = reqinfo->updt_applctx, ce
       .updt_cnt = (ce.updt_cnt+ 1),
       ce.updt_dt_tm = cnvtdatetime(sysdate), ce.updt_id = reqinfo->updt_id, ce.updt_task = reqinfo->
       updt_task
      WHERE (ce.product_id=request->qual[count1].product_id)
       AND ce.valid_from_dt_tm <= cnvtdatetime(sysdate)
       AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET count2 += 1
      SET stat = alterlist(reply->qual,count2)
      SET reply->qual[count2].product_id = request->qual[count1].product_id
      SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
      SET reply->status_data.subeventstatus[count2].operationname = "update"
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "ce_product"
      SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[count1].
       product_id)
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF ((request->qual[count1].new_product_cd > 0.0)
    AND ((bp_auto_ind=1) OR (bp_dir_ind=1)) )
    SELECT INTO "nl:"
     pe.product_event_id
     FROM product_event pe
     PLAN (pe
      WHERE (pe.product_id=request->qual[count1].product_id)
       AND ((pe.event_type_cd+ 0)=avail_event_cd)
       AND pe.active_ind=1)
     DETAIL
      row + 1
     WITH nocounter, forupdate(pe)
    ;end select
    IF (curqual > 0)
     UPDATE  FROM product_event pe
      SET pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id = reqinfo
       ->updt_id,
       pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.event_dt_tm =
       cnvtdatetime(request->qual[count1].new_recv_dt_tm),
       pe.active_status_cd = reqdata->inactive_status_cd, pe.active_ind = 0
      WHERE (pe.product_id=request->qual[count1].product_id)
       AND ((pe.event_type_cd+ 0)=avail_event_cd)
       AND pe.active_ind=1
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET count2 += 1
      SET stat = alter(reply->status_data.subeventstatus,count2)
      SET reply->status_data.subeventstatus[count2].operationname =
      "Error inactivating the assigned event."
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "product_event"
      SET reply->status_data.subeventstatus[count2].targetobjectvalue = request->qual[count1].
      product_id
      SET failed = "T"
      GO TO exit_script
     ENDIF
    ENDIF
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
 SUBROUTINE bbt_add_destroyed_event(sub_product_id,sub_event_dt_tm,sub_dispose_reason_code,
  sub_disposed_qty,sub_disposed_intl_units,sub_method_cd,sub_autoclave_ind,sub_box_nbr,
  sub_manifest_nbr,sub_destruction_org_id)
   SET event_states_added = "I"
   SET disposed_event_cd = 0.0
   SET destroyed_event_cd = 0.0
   SET auto_event_cd = 0.0
   SET dir_event_cd = 0.0
   SET unconfirmed_event_cd = 0.0
   SET nidx = 0
   SET struct_count = 0
   RECORD event_list(
     1 qual[*]
       2 product_event_id = f8
   )
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"14",cv_cnt,destroyed_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"10",cv_cnt,auto_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"11",cv_cnt,dir_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"9",cv_cnt,unconfirmed_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"5",cv_cnt,disposed_event_cd)
   IF (((destroyed_event_cd=0) OR (((auto_event_cd=0) OR (((dir_event_cd=0) OR (((
   unconfirmed_event_cd=0) OR (disposed_event_cd=0)) )) )) )) )
    SET event_states_added = "F"
   ENDIF
   IF (event_states_added="I")
    SET disposed_event_id = 0.0
    SET new_pathnet_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)"#####################;rp0"
     FROM dual
     DETAIL
      new_pathnet_seq = cnvtreal(seqn)
     WITH format, nocounter
    ;end select
    INSERT  FROM product_event p
     SET p.product_event_id = new_pathnet_seq, p.product_id = sub_product_id, p.event_type_cd =
      disposed_event_cd,
      p.event_dt_tm = cnvtdatetime(sub_event_dt_tm), p.event_prsnl_id = reqinfo->updt_id, p
      .event_status_flag = 0,
      p.order_id = 0, p.event_prsnl_id = reqinfo->updt_id, p.active_ind = 0,
      p.active_status_dt_tm = cnvtdatetime(sysdate), p.active_status_cd = reqdata->inactive_status_cd,
      p.active_status_prsnl_id = reqinfo->updt_id,
      p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_task = reqinfo->updt_task,
      p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(sysdate)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET event_states_added = "F"
    ENDIF
    IF (event_states_added != "F")
     INSERT  FROM disposition d
      SET d.product_event_id = new_pathnet_seq, d.product_id = sub_product_id, d.reason_cd =
       sub_dispose_reason_code,
       d.disposed_qty = sub_disposed_qty, d.disposed_intl_units = 0, d.active_ind = 0,
       d.active_status_cd = reqdata->active_status_cd, d.active_status_dt_tm = cnvtdatetime(sysdate),
       d.active_status_prsnl_id = reqinfo->updt_id,
       d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id,
       d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task
      WITH counter
     ;end insert
     IF (curqual=0)
      SET event_states_added = "F"
     ELSE
      SET disposed_event_id = new_pathnet_seq
     ENDIF
     IF (event_states_added != "F")
      SELECT INTO "nl:"
       p.product_event_id, p.event_type_cd
       FROM product_event p
       WHERE p.product_id=sub_product_id
        AND p.active_ind=1
       DETAIL
        IF (p.event_type_cd != auto_event_cd
         AND p.event_type_cd != dir_event_cd
         AND p.event_type_cd != unconfirmed_event_cd)
         struct_count += 1, stat = alterlist(event_list->qual,struct_count), event_list->qual[
         struct_count].product_event_id = p.product_event_id
        ENDIF
       WITH counter
      ;end select
      FOR (nidx = 1 TO struct_count)
        SELECT INTO "nl:"
         p.*
         FROM product_event p
         WHERE (p.product_event_id=event_list->qual[nidx].product_event_id)
         WITH counter, forupdate(p)
        ;end select
        IF (curqual=0)
         SET event_states_added = "F"
        ENDIF
        IF (event_states_added != "F")
         UPDATE  FROM product_event p
          SET p.active_ind = 0, p.active_status_cd = reqdata->inactive_status_cd, p
           .active_status_dt_tm = cnvtdatetime(sysdate),
           p.active_status_prsnl_id = reqinfo->updt_id, p.updt_id = reqinfo->updt_id, p.updt_cnt = (p
           .updt_cnt+ 1),
           p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
           cnvtdatetime(sysdate)
          WHERE (p.product_event_id=event_list->qual[nidx].product_event_id)
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET event_states_added = "F"
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     IF (event_states_added != "F")
      SET new_pathnet_seq = 0.0
      SELECT INTO "nl:"
       seqn = seq(pathnet_seq,nextval)"#####################;rp0"
       FROM dual
       DETAIL
        new_pathnet_seq = cnvtreal(seqn)
       WITH format, nocounter
      ;end select
      INSERT  FROM product_event p
       SET p.product_event_id = new_pathnet_seq, p.product_id = sub_product_id, p.event_type_cd =
        destroyed_event_cd,
        p.event_dt_tm = cnvtdatetime(sub_event_dt_tm), p.related_product_event_id = disposed_event_id,
        p.event_prsnl_id = reqinfo->updt_id,
        p.event_status_flag = 0, p.order_id = 0, p.active_ind = 1,
        p.active_status_dt_tm = cnvtdatetime(sysdate), p.active_status_cd = reqdata->active_status_cd,
        p.active_status_prsnl_id = reqinfo->updt_id,
        p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_task = reqinfo->updt_task,
        p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(sysdate)
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET event_states_added = "F"
      ENDIF
      IF (event_states_added != "F")
       INSERT  FROM destruction d
        SET d.product_id = sub_product_id, d.product_event_id = new_pathnet_seq, d.autoclave_ind =
         sub_autoclave_ind,
         d.method_cd = sub_method_cd, d.box_nbr = sub_box_nbr, d.manifest_nbr = sub_manifest_nbr,
         d.destroyed_qty = sub_disposed_qty, d.destruction_org_id = sub_destruction_org_id, d
         .active_ind = 1,
         d.active_status_cd = reqdata->active_status_cd, d.active_status_dt_tm = cnvtdatetime(sysdate
          ), d.active_status_prsnl_id = reqinfo->updt_id,
         d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id,
         d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task
        WITH counter
       ;end insert
       IF (curqual=0)
        SET event_states_added = "F"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (event_states_added="I")
     SET event_states_added = "S"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_quarantine(sub_product_id,quar_event_id,reason_cd,sub_orig_quar_qty)
   SET gsub_quar_status = "OK"
   INSERT  FROM quarantine q
    SET q.product_event_id = quar_event_id, q.product_id = sub_product_id, q.quar_reason_cd =
     reason_cd,
     q.orig_quar_qty = sub_orig_quar_qty, q.cur_quar_qty = sub_orig_quar_qty, q.active_ind = 1,
     q.active_status_cd = reqdata->active_status_cd, q.active_status_dt_tm = cnvtdatetime(sysdate), q
     .active_status_prsnl_id = reqinfo->updt_id,
     q.updt_cnt = 0, q.updt_dt_tm = cnvtdatetime(sysdate), q.updt_id = reqinfo->updt_id,
     q.updt_task = reqinfo->updt_task, q.updt_applctx = reqinfo->updt_applctx
    WITH counter
   ;end insert
   IF (curqual=0)
    SET y += 1
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_chg_corr_prod_info"
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "quarantine"
    SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    SET gsub_quar_status = "FI"
   ENDIF
   IF ((request->derivative_ind="T"))
    SELECT INTO "nl:"
     d.*
     FROM derivative d
     WHERE (d.product_id=request->qual[count1].product_id)
      AND (d.updt_cnt=(request->qual[count1].child_updt_cnt+ 1))
      AND d.active_ind=1
     WITH counter, forupdate(d)
    ;end select
    IF (curqual=0)
     SET y += 1
     IF (y > 1)
      SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_chg_corr_prod_info"
     SET reply->status_data.subeventstatus[y].operationname = "select"
     SET reply->status_data.subeventstatus[y].operationstatus = "F"
     SET reply->status_data.subeventstatus[y].targetobjectname = "for update DERIVATIVE"
     SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[count1].product_id
     SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     SET gsub_quar_status = "FI"
    ELSE
     UPDATE  FROM derivative d
      SET d.cur_avail_qty = 0, d.updt_cnt = (d.updt_cnt+ 1)
      WHERE (d.product_id=request->qual[count1].product_id)
       AND d.active_ind=1
     ;end update
     IF (curqual=0)
      SET y += 1
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_chg_corr_prod_info"
      SET reply->status_data.subeventstatus[y].operationname = "UPDATE"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "TABLE"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = "DERIVATIVE"
      SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
      SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      SET gsub_quar_status = "FI"
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE (addstate(addstatemean=vc,newpersonid=f8,newencntrid=f8,newusagedttm=dq8,newrelativeind=
  i2) =null)
   IF (addstatemean="10")
    SET new_product_event_id = 0.0
    SET gsub_product_event_status = "  "
    CALL add_product_event(request->qual[count1].product_id,newpersonid,newencntrid,0,0.0,
     auto_event_cd,cnvtdatetime(sysdate),reqinfo->updt_id,0,0,
     0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
     reqinfo->updt_id)
    IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
     SET count2 += 1
     IF (count2 > 1)
      SET stat = alter(reply->status_data.subeventstatus,(count2+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[count2].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[count2].sourceobjectvalue = "bbt_add_blood_product"
     SET reply->status_data.subeventstatus[count2].operationname = "add product event"
     SET reply->status_data.subeventstatus[count2].operationstatus = "F"
     SET reply->status_data.subeventstatus[count2].targetobjectname = "product_event"
     SET reply->status_data.subeventstatus[count2].targetobjectvalue = "add product event"
     SET reply->status_data.subeventstatus[count2].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[count2].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     SET failed = "T"
     GO TO exit_script
    ELSE
     INSERT  FROM auto_directed ad
      SET ad.product_event_id = new_product_event_id, ad.product_id = request->qual[count1].
       product_id, ad.person_id = newpersonid,
       ad.encntr_id = newencntrid, ad.expected_usage_dt_tm = cnvtdatetime(newusagedttm), ad
       .associated_dt_tm = cnvtdatetime(sysdate),
       ad.active_ind = 1, ad.active_status_cd = reqdata->active_status_cd, ad.active_status_dt_tm =
       cnvtdatetime(sysdate),
       ad.active_status_prsnl_id = reqinfo->updt_id, ad.donated_by_relative_ind = 0, ad.updt_dt_tm =
       cnvtdatetime(sysdate),
       ad.updt_id = reqinfo->updt_id
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET count2 += 1
      SET stat = alterlist(reply->qual,count2)
      SET stat = alterlist(reply->status_data.subeventstatus,count2)
      SET reply->qual[count2].product_id = request->qual[count1].product_id
      SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
      SET reply->status_data.subeventstatus[count2].operationname = "insert"
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "auto_directed table"
      SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(new_product_event_id)
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF (addstatemean="11")
    SET new_product_event_id = 0.0
    SET gsub_product_event_status = "  "
    CALL add_product_event(request->qual[count1].product_id,newpersonid,newencntrid,0,0.0,
     dir_event_cd,cnvtdatetime(sysdate),reqinfo->updt_id,0,0,
     0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
     reqinfo->updt_id)
    IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
     SET count2 += 1
     IF (count2 > 1)
      SET stat = alter(reply->status_data.subeventstatus,(count2+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[count2].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[count2].sourceobjectvalue = "bbt_add_blood_product"
     SET reply->status_data.subeventstatus[count2].operationname = "add product event"
     SET reply->status_data.subeventstatus[count2].operationstatus = "F"
     SET reply->status_data.subeventstatus[count2].targetobjectname = "product_event"
     SET reply->status_data.subeventstatus[count2].targetobjectvalue = "add product event"
     SET reply->status_data.subeventstatus[count2].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[count2].sub_event_dt_tm = cnvtdatetime(sysdate)
     SET failed = "T"
     GO TO exit_script
    ELSE
     INSERT  FROM auto_directed ad
      SET ad.product_event_id = new_product_event_id, ad.product_id = request->qual[count1].
       product_id, ad.person_id = newpersonid,
       ad.encntr_id = newencntrid, ad.expected_usage_dt_tm = cnvtdatetime(newusagedttm), ad
       .associated_dt_tm = cnvtdatetime(sysdate),
       ad.active_ind = 1, ad.active_status_cd = reqdata->active_status_cd, ad.active_status_dt_tm =
       cnvtdatetime(sysdate),
       ad.active_status_prsnl_id = reqinfo->updt_id, ad.donated_by_relative_ind = newrelativeind, ad
       .updt_dt_tm = cnvtdatetime(sysdate),
       ad.updt_id = reqinfo->updt_id
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET count2 += 1
      SET stat = alterlist(reply->qual,count2)
      SET stat = alterlist(reply->status_data.subeventstatus,count2)
      SET reply->qual[count2].product_id = request->qual[count1].product_id
      SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
      SET reply->status_data.subeventstatus[count2].operationname = "insert"
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "auto_directed table"
      SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[count1].
       product_event_id)
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (inactivateevent(inactivateeventid=f8,producteventupdtcnt=i4,adeventupdtcnt=i4) =null)
   IF (inactivateeventid > 0.0)
    SELECT INTO "nl:"
     pe.product_event_id
     FROM product_event pe
     PLAN (pe
      WHERE pe.product_event_id=inactivateeventid
       AND pe.updt_cnt=producteventupdtcnt)
     WITH nocounter, forupdate(pe)
    ;end select
    IF (curqual != 0)
     SELECT INTO "nl:"
      ad.product_event_id
      FROM auto_directed ad
      PLAN (ad
       WHERE ad.product_event_id=inactivateeventid
        AND ad.updt_cnt=adeventupdtcnt)
      WITH nocounter, forupdate(ad)
     ;end select
    ENDIF
    IF (curqual=0)
     SET failed = "T"
     SET count2 += 1
     SET stat = alterlist(reply->qual,count2)
     SET stat = alterlist(reply->status_data.subeventstatus,count2)
     SET reply->qual[count2].product_id = request->qual[count1].product_id
     SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
     SET reply->status_data.subeventstatus[count2].operationname = "Lock"
     SET reply->status_data.subeventstatus[count2].operationstatus = "F"
     SET reply->status_data.subeventstatus[count2].targetobjectname = "Product_Event, Auto_Directed"
     SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(inactivateeventid)
     GO TO exit_script
    ENDIF
    UPDATE  FROM product_event p
     SET p.active_ind = 0, p.active_status_cd = reqdata->inactive_status_cd, p.active_status_dt_tm =
      cnvtdatetime(sysdate),
      p.active_status_prsnl_id = reqinfo->updt_id, p.updt_id = reqinfo->updt_id, p.updt_cnt = (p
      .updt_cnt+ 1),
      p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
      cnvtdatetime(sysdate)
     WHERE p.product_event_id=inactivateeventid
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET count2 += 1
     SET stat = alterlist(reply->qual,count2)
     SET stat = alterlist(reply->status_data.subeventstatus,count2)
     SET reply->qual[count2].product_id = request->qual[count1].product_id
     SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
     SET reply->status_data.subeventstatus[count2].operationname = "Update"
     SET reply->status_data.subeventstatus[count2].operationstatus = "F"
     SET reply->status_data.subeventstatus[count2].targetobjectname = "Product_Event"
     SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(inactivateeventid)
     GO TO exit_script
    ELSE
     UPDATE  FROM auto_directed ad
      SET ad.active_ind = 0, ad.active_status_cd = reqdata->inactive_status_cd, ad
       .active_status_dt_tm = cnvtdatetime(sysdate),
       ad.active_status_prsnl_id = reqinfo->updt_id, ad.updt_id = reqinfo->updt_id, ad.updt_cnt = (ad
       .updt_cnt+ 1),
       ad.updt_task = reqinfo->updt_task, ad.updt_applctx = reqinfo->updt_applctx, ad.updt_dt_tm =
       cnvtdatetime(sysdate)
      WHERE ad.product_event_id=inactivateeventid
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET count2 += 1
      SET stat = alterlist(reply->qual,count2)
      SET stat = alterlist(reply->status_data.subeventstatus,count2)
      SET reply->qual[count2].product_id = request->qual[count1].product_id
      SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
      SET reply->status_data.subeventstatus[count2].operationname = "Update"
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "auto_directed"
      SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(inactivateeventid)
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (insertautodircorrectedproductrow(activeind=i2,producteventid=f8,oldpersonid=f8,
  oldencntrid=f8,oldusagedttm=dq8,oldrelativeind=i2) =null)
   SET corr_id = next_pathnet_seq(0)
   INSERT  FROM corrected_product cp
    SET cp.correction_id = corr_id, cp.product_id = request->qual[count1].product_id, cp
     .correction_type_cd =
     IF ((request->qual[count1].correction_mode="DEMOG")) chg_demogr_cd
     ELSEIF ((request->qual[count1].correction_mode="ERDIS")) emerg_dispense_cd
     ELSEIF ((request->qual[count1].correction_mode="STATE")) chg_state_cd
     ELSE unlock_prod_cd
     ENDIF
     ,
     cp.correction_reason_cd = request->qual[count1].corr_reason_cd, cp.product_nbr = null, cp
     .barcode_nbr = null,
     cp.product_sub_nbr = null, cp.flag_chars = null, cp.alternate_nbr = null,
     cp.product_cd = - (1), cp.product_class_cd = - (1), cp.product_cat_cd = - (1),
     cp.supplier_id = 0, cp.supplier_prefix = null, cp.recv_dt_tm = null,
     cp.volume = null, cp.unit_meas_cd = - (1), cp.expire_dt_tm = null,
     cp.abo_cd = - (1), cp.rh_cd = - (1), cp.segment_nbr = null,
     cp.manufacturer_id = 0, cp.vis_insp_cd = - (1), cp.ship_cond_cd = - (1),
     cp.cur_intl_units = - (1), cp.cur_avail_qty = - (1), cp.orig_updt_cnt = null,
     cp.orig_updt_dt_tm = null, cp.orig_updt_id = 0, cp.orig_updt_task = null,
     cp.orig_updt_applctx = null, cp.correction_note = null, cp.product_event_id =
     IF ((producteventid=- (1))) 0
     ELSE producteventid
     ENDIF
     ,
     cp.drawn_dt_tm = null, cp.event_dt_tm = cnvtdatetime(""), cp.reason_cd = - (1),
     cp.autoclave_ind = null, cp.destruction_method_cd = - (1), cp.destruction_org_id = 0,
     cp.manifest_nbr = null, cp.updt_cnt = 0, cp.updt_dt_tm = cnvtdatetime(sysdate),
     cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->updt_task, cp.updt_applctx = reqinfo->
     updt_applctx,
     cp.person_id =
     IF ((((oldpersonid=- (1))) OR (activeind=0)) ) 0
     ELSE oldpersonid
     ENDIF
     , cp.encntr_id =
     IF ((((oldencntrid=- (1))) OR (activeind=0)) ) 0
     ELSE oldencntrid
     ENDIF
     , cp.expected_usage_dt_tm =
     IF ((((oldusagedttm=- (1))) OR (activeind=0)) ) null
     ELSE cnvtdatetime(oldusagedttm)
     ENDIF
     ,
     cp.donated_by_relative_ind =
     IF ((((oldrelativeind=- (1))) OR (activeind=0)) ) - (1)
     ELSE oldrelativeind
     ENDIF
     , cp.cur_owner_area_cd = - (1), cp.cur_inv_area_cd = - (1),
     cp.donation_type_cd = - (1), cp.disease_cd = - (1)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET count2 += 1
    SET stat = alterlist(reply->qual,count2)
    SET reply->qual[count2].product_id = request->qual[count1].product_id
    SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
    SET reply->status_data.subeventstatus[count2].operationname = "insert"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "corrected product"
    SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[count1].
     product_id)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insertbasecorrectedproductrow(null)
   SET corr_id = next_pathnet_seq(0)
   INSERT  FROM corrected_product cp
    SET cp.correction_id = corr_id, cp.product_id = request->qual[count1].product_id, cp
     .correction_type_cd =
     IF ((request->qual[count1].correction_mode="DEMOG")) chg_demogr_cd
     ELSEIF ((request->qual[count1].correction_mode="ERDIS")) emerg_dispense_cd
     ELSEIF ((request->qual[count1].correction_mode="STATE")) chg_state_cd
     ELSE unlock_prod_cd
     ENDIF
     ,
     cp.correction_reason_cd = request->qual[count1].corr_reason_cd, cp.product_nbr =
     IF ((request->qual[count1].old_product_nbr="-1")) null
     ELSE request->qual[count1].old_product_nbr
     ENDIF
     , cp.barcode_nbr =
     IF ((request->qual[count1].old_barcode_nbr="-1")) null
     ELSE request->qual[count1].old_barcode_nbr
     ENDIF
     ,
     cp.product_sub_nbr =
     IF ((request->qual[count1].old_product_sub_nbr="-1")) null
     ELSE request->qual[count1].old_product_sub_nbr
     ENDIF
     , cp.flag_chars =
     IF ((request->qual[count1].old_flag_chars="-1")) null
     ELSE request->qual[count1].old_flag_chars
     ENDIF
     , cp.alternate_nbr =
     IF ((request->qual[count1].old_alt_nbr="-1")) null
     ELSE request->qual[count1].old_alt_nbr
     ENDIF
     ,
     cp.product_cd =
     IF ((request->qual[count1].old_product_cd=- (1))) - (1)
     ELSE request->qual[count1].old_product_cd
     ENDIF
     , cp.product_class_cd =
     IF ((request->qual[count1].old_product_class_cd=- (1))) - (1)
     ELSE request->qual[count1].old_product_class_cd
     ENDIF
     , cp.product_cat_cd =
     IF ((request->qual[count1].old_product_cat_cd=- (1))) - (1)
     ELSE request->qual[count1].old_product_cat_cd
     ENDIF
     ,
     cp.supplier_id =
     IF ((request->qual[count1].old_supplier_id=- (1))) 0
     ELSE request->qual[count1].old_supplier_id
     ENDIF
     , cp.supplier_prefix =
     IF ((request->qual[count1].old_supplier_prefix="-1")) null
     ELSE request->qual[count1].old_supplier_prefix
     ENDIF
     , cp.recv_dt_tm =
     IF ((request->qual[count1].old_recv_dt_tm=- (1))) null
     ELSE cnvtdatetime(request->qual[count1].old_recv_dt_tm)
     ENDIF
     ,
     cp.volume =
     IF ((request->qual[count1].old_volume=- (1))) null
     ELSE request->qual[count1].old_volume
     ENDIF
     , cp.unit_meas_cd =
     IF ((request->qual[count1].old_unit_of_meas_cd=- (1))) - (1)
     ELSE request->qual[count1].old_unit_of_meas_cd
     ENDIF
     , cp.expire_dt_tm =
     IF ((request->qual[count1].old_exp_dt_tm=- (1))) null
     ELSE cnvtdatetime(request->qual[count1].old_exp_dt_tm)
     ENDIF
     ,
     cp.abo_cd =
     IF ((request->qual[count1].old_abo_cd=- (1))) - (1)
     ELSE request->qual[count1].old_abo_cd
     ENDIF
     , cp.rh_cd =
     IF ((request->qual[count1].old_rh_cd=- (1))) - (1)
     ELSE request->qual[count1].old_rh_cd
     ENDIF
     , cp.segment_nbr =
     IF ((request->qual[count1].old_segment_nbr="-1")) null
     ELSE request->qual[count1].old_segment_nbr
     ENDIF
     ,
     cp.manufacturer_id =
     IF ((request->qual[count1].old_manu_id > - (1))) request->qual[count1].old_manu_id
     ELSE 0
     ENDIF
     , cp.vis_insp_cd =
     IF ((request->qual[count1].old_orig_vis_insp_cd=- (1))) - (1)
     ELSE request->qual[count1].old_orig_vis_insp_cd
     ENDIF
     , cp.ship_cond_cd =
     IF ((request->qual[count1].old_orig_ship_cond_cd=- (1))) - (1)
     ELSE request->qual[count1].old_orig_ship_cond_cd
     ENDIF
     ,
     cp.cur_intl_units =
     IF ((request->qual[count1].old_ius=- (1))) - (1)
     ELSE request->qual[count1].old_ius
     ENDIF
     , cp.cur_avail_qty =
     IF ((request->qual[count1].old_qty=- (1))) - (1)
     ELSE request->qual[count1].old_qty
     ENDIF
     , cp.units_per_vial_cnt =
     IF ((request->qual[count1].old_units_per_vial=- (1))) - (1)
     ELSE request->qual[count1].old_units_per_vial
     ENDIF
     ,
     cp.orig_updt_cnt =
     IF ((request->qual[count1].orig_updt_cnt=- (1))) null
     ELSE request->qual[count1].orig_updt_cnt
     ENDIF
     , cp.orig_updt_dt_tm =
     IF ((request->qual[count1].orig_updt_dt_tm=- (1))) null
     ELSE cnvtdatetime(request->qual[count1].orig_updt_dt_tm)
     ENDIF
     , cp.orig_updt_id =
     IF ((request->qual[count1].orig_updt_id > - (1))) request->qual[count1].orig_updt_id
     ELSE 0
     ENDIF
     ,
     cp.orig_updt_task =
     IF ((request->qual[count1].orig_updt_task=- (1))) null
     ELSE request->qual[count1].orig_updt_task
     ENDIF
     , cp.orig_updt_applctx =
     IF ((request->qual[count1].orig_updt_applctx=- (1))) null
     ELSE request->qual[count1].orig_updt_applctx
     ENDIF
     , cp.correction_note =
     IF ((request->qual[count1].corr_note="-1")) null
     ELSE request->qual[count1].corr_note
     ENDIF
     ,
     cp.product_event_id = 0, cp.drawn_dt_tm =
     IF ((request->qual[count1].old_drawn_dt_tm=- (1))) null
     ELSE cnvtdatetime(request->qual[count1].old_drawn_dt_tm)
     ENDIF
     , cp.event_dt_tm = cnvtdatetime(""),
     cp.reason_cd = - (1), cp.autoclave_ind = null, cp.destruction_method_cd = - (1),
     cp.destruction_org_id = 0, cp.manifest_nbr = null, cp.updt_cnt = 0,
     cp.updt_dt_tm = cnvtdatetime(sysdate), cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->
     updt_task,
     cp.updt_applctx = reqinfo->updt_applctx, cp.person_id = 0, cp.encntr_id = 0,
     cp.expected_usage_dt_tm = null, cp.donated_by_relative_ind = - (1), cp.cur_owner_area_cd =
     IF ((request->qual[count1].old_owner_area_cd=- (1))) - (1)
     ELSE request->qual[count1].old_owner_area_cd
     ENDIF
     ,
     cp.cur_inv_area_cd =
     IF ((request->qual[count1].old_inv_area_cd=- (1))) - (1)
     ELSE request->qual[count1].old_inv_area_cd
     ENDIF
     , cp.donation_type_cd =
     IF ((request->qual[count1].old_donation_type_cd=- (1))) - (1)
     ELSE request->qual[count1].old_donation_type_cd
     ENDIF
     , cp.disease_cd =
     IF ((request->qual[count1].old_disease_cd=- (1))) - (1)
     ELSE request->qual[count1].old_disease_cd
     ENDIF
     ,
     cp.intended_use_print_parm_txt =
     IF ((request->qual[count1].old_intended_use="-")) null
     ELSE request->qual[count1].old_intended_use
     ENDIF
     , cp.product_type_barcode =
     IF ((request->qual[count1].old_product_type_barcode="-1")) null
     ELSE request->qual[count1].old_product_type_barcode
     ENDIF
     , cp.serial_number_txt =
     IF ((request->qual[count1].old_serial_nbr="-1")) null
     ELSE request->qual[count1].old_serial_nbr
     ENDIF
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET count2 += 1
    SET stat = alterlist(reply->qual,count2)
    SET reply->qual[count2].product_id = request->qual[count1].product_id
    SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
    SET reply->status_data.subeventstatus[count2].operationname = "insert"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "corrected product"
    SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->qual[count1].
     product_id)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (updateautodirevent(producteventid=f8,producteventupdtcnt=i4,adeventupdtcnt=i4,
  newpersonid=f8,newencntrid=f8,newusagedttm=dq8,newrelativeind=i2) =null)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE pe.product_event_id=producteventid
      AND pe.updt_cnt=producteventupdtcnt)
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual != 0)
    SELECT INTO "nl:"
     ad.product_event_id
     FROM auto_directed ad
     PLAN (ad
      WHERE ad.product_event_id=producteventid
       AND ad.updt_cnt=adeventupdtcnt)
     WITH nocounter, forupdate(ad)
    ;end select
   ENDIF
   IF (curqual=0)
    SET failed = "T"
    SET count2 += 1
    SET stat = alterlist(reply->qual,count2)
    SET reply->qual[count2].product_id = request->qual[count1].product_id
    SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
    SET reply->status_data.subeventstatus[count2].operationname = "Lock"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "Product_Event, Auto_Directed"
    SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(producteventid)
    GO TO exit_script
   ELSE
    UPDATE  FROM product_event pe
     SET pe.person_id = newpersonid, pe.encntr_id = newencntrid, pe.updt_cnt = (pe.updt_cnt+ 1)
     WHERE pe.product_event_id=producteventid
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET count2 += 1
     SET stat = alterlist(reply->qual,count2)
     SET reply->qual[count2].product_id = request->qual[count1].product_id
     SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
     SET reply->status_data.subeventstatus[count2].operationname = "Update"
     SET reply->status_data.subeventstatus[count2].operationstatus = "F"
     SET reply->status_data.subeventstatus[count2].targetobjectname = "Product_Event"
     SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(producteventid)
     GO TO exit_script
    ENDIF
    UPDATE  FROM auto_directed ad
     SET ad.person_id = newpersonid, ad.encntr_id = newencntrid, ad.expected_usage_dt_tm =
      cnvtdatetime(newusagedttm),
      ad.donated_by_relative_ind = newrelativeind, ad.updt_cnt = (ad.updt_cnt+ 1)
     WHERE ad.product_event_id=producteventid
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET count2 += 1
     SET stat = alterlist(reply->qual,count2)
     SET reply->qual[count2].product_id = request->qual[count1].product_id
     SET reply->qual[count2].product_nbr = request->qual[count1].old_product_nbr
     SET reply->status_data.subeventstatus[count2].operationname = "Update"
     SET reply->status_data.subeventstatus[count2].operationstatus = "F"
     SET reply->status_data.subeventstatus[count2].targetobjectname = "Auto_Directed"
     SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(producteventid)
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
END GO
