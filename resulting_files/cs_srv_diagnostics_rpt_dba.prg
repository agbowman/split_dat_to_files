CREATE PROGRAM cs_srv_diagnostics_rpt:dba
 FREE SET diag
 RECORD diag(
   1 srv_diag = f8
   1 not_at_chrg_pnt = f8
   1 no_pnt_item = f8
   1 no_pnt_tier = f8
   1 not_at_chrg_lvl = f8
   1 no_chrg_ind = f8
   1 no_tier_for_org = f8
   1 no_phleb_chrg = f8
   1 workload_only = f8
   1 events[*]
     2 charge_event_id = f8
     2 master_event_id = f8
     2 master_ref_id = f8
     2 master_cont_cd = f8
     2 parent_ref_id = f8
     2 parent_cont_cd = f8
     2 item_ref_id = f8
     2 item_cont_cd = f8
     2 accession = c28
     2 order_id = f8
     2 person_id = f8
     2 person_name = c50
     2 encntr_id = f8
     2 bill_item = vc
     2 acts[*]
       3 charge_act_id = f8
       3 cea_type_cd = f8
       3 cea_type = vc
       3 charge_type_cd = f8
       3 cea_prsnl_id = f8
       3 cea_first_name = vc
       3 cea_last_name = vc
       3 updt_dt = c20
       3 diag[*]
         4 diag_cd = f8
         4 diag1_id = f8
         4 diag2_id = f8
         4 diag3_id = f8
         4 diag1 = vc
         4 diag2 = vc
         4 diag3 = vc
         4 diag_reason = c60
         4 diag_tier = f8
       3 charges[*]
         4 charge_item_id = f8
 )
 DECLARE event = i2
 DECLARE act = i2
 DECLARE mod = i2
 DECLARE eventcnt = i2
 DECLARE actcnt = i2
 DECLARE modcnt = i2
 SUBROUTINE initialize(a)
   DECLARE codeset = i4
   DECLARE meaning = c12
   DECLARE index = i4
   DECLARE codevalue = f8
   DECLARE iret = i4
   SET codeset = 13019
   SET meaning = "SRV DIAG"
   SET index = 1
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   IF (iret=0)
    SET diag->srv_diag = codevalue
   ENDIF
   SET codeset = 13028
   SET meaning = "WORKLOADONLY"
   SET index = 1
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   IF (iret=0)
    SET diag->workload_only = codevalue
   ENDIF
   SET codeset = 18269
   SET meaning = "NOTATCHRGPNT"
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET diag->not_at_chrg_pnt = - (1)
   IF (iret=0)
    SET diag->not_at_chrg_pnt = codevalue
   ENDIF
   SET meaning = "NOPNTONITEM"
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET diag->no_pnt_item = - (1)
   IF (iret=0)
    SET diag->no_pnt_item = codevalue
   ENDIF
   SET meaning = "NOPNTONTIER"
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET diag->no_pnt_tier = - (1)
   IF (iret=0)
    SET diag->no_pnt_tier = codevalue
   ENDIF
   SET meaning = "NOTATCHRGLVL"
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET diag->not_at_chrg_lvl = - (1)
   IF (iret=0)
    SET diag->not_at_chrg_lvl = codevalue
   ENDIF
   SET meaning = "NOCHARGEIND"
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET diag->no_chrg_ind = - (1)
   IF (iret=0)
    SET diag->no_chrg_ind = codevalue
   ENDIF
   SET meaning = "NOTIERFORORG"
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET diag->no_tier_for_org = - (1)
   IF (iret=0)
    SET diag->no_tier_for_org = codevalue
   ENDIF
   SET meaning = "NOPHLEBCHRG"
   SET codevalue = 0.0
   SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
   SET diag->no_phleb_chrg = - (1)
   IF (iret=0)
    SET diag->no_phleb_chrg = codevalue
   ENDIF
 END ;Subroutine
 SUBROUTINE readdiaginfo(b)
   SET event = 0
   SELECT
    IF ((diag_request->master_list[1].order_id > 0))
     PLAN (d)
      JOIN (c
      WHERE (c.ext_m_event_id=diag_request->master_list[d.seq].master_event_id)
       AND (c.order_id=diag_request->master_list[d.seq].order_id))
      JOIN (d1)
      JOIN (p
      WHERE p.person_id=c.person_id)
    ELSE
     PLAN (d)
      JOIN (c
      WHERE (c.ext_m_event_id=diag_request->master_list[d.seq].master_event_id))
      JOIN (d1)
      JOIN (p
      WHERE p.person_id=c.person_id)
    ENDIF
    INTO "nl:"
    c.charge_event_id, c.ext_m_event_id, c.order_id,
    c.accession, c.person_id, c.encntr_id,
    c.perf_loc_cd, p.name_full_formatted
    FROM charge_event c,
     person p,
     (dummyt d  WITH seq = value(diag_request->master_qual)),
     dummyt d1
    PLAN (d)
     JOIN (c
     WHERE (c.ext_m_event_id=diag_request->master_list[d.seq].master_event_id))
     JOIN (d1)
     JOIN (p
     WHERE p.person_id=c.person_id)
    ORDER BY c.ext_m_event_id, c.charge_event_id
    DETAIL
     eventcnt += 1, stat = alterlist(diag->events,eventcnt), diag->events[eventcnt].charge_event_id
      = c.charge_event_id,
     diag->events[eventcnt].master_event_id = c.ext_m_event_id, diag->events[eventcnt].master_ref_id
      = c.ext_m_reference_id, diag->events[eventcnt].master_cont_cd = c.ext_m_reference_cont_cd,
     diag->events[eventcnt].parent_ref_id = c.ext_p_reference_id, diag->events[eventcnt].
     parent_cont_cd = c.ext_p_reference_cont_cd, diag->events[eventcnt].item_ref_id = c
     .ext_i_reference_id,
     diag->events[eventcnt].item_cont_cd = c.ext_i_reference_cont_cd, diag->events[eventcnt].order_id
      = c.order_id, diag->events[eventcnt].accession = c.accession,
     diag->events[eventcnt].person_id = c.person_id, diag->events[eventcnt].encntr_id = c.encntr_id,
     diag->events[eventcnt].person_name = p.name_full_formatted
    WITH outerjoin = d1, nocounter
   ;end select
   SET act = 0
   SET mod = 0
   SELECT INTO "nl:"
    charge_event_id = diag->events[d.seq].charge_event_id, ca.charge_event_act_id, ca.cea_type_cd,
    ca.cea_prsnl_id, ca.updt_dt_tm, cm.field2_id,
    cm.field3_id, cm.field4_id, cm.field5_id
    FROM charge_event_act ca,
     (dummyt d  WITH seq = value(eventcnt)),
     dummyt d1,
     charge_event_mod cm
    PLAN (d)
     JOIN (ca
     WHERE (ca.charge_event_id=diag->events[d.seq].charge_event_id))
     JOIN (d1)
     JOIN (cm
     WHERE (cm.charge_event_id=diag->events[d.seq].charge_event_id)
      AND (cm.charge_event_mod_type_cd=diag->srv_diag)
      AND cm.field1_id=ca.charge_event_act_id)
    ORDER BY ca.charge_event_act_id, cm.field1_id, cm.charge_event_mod_id
    HEAD charge_event_id
     act = 0
    HEAD ca.charge_event_act_id
     mod = 0, act += 1, stat = alterlist(diag->events[d.seq].acts,act),
     diag->events[d.seq].acts[act].charge_act_id = ca.charge_event_act_id, diag->events[d.seq].acts[
     act].cea_type_cd = ca.cea_type_cd, diag->events[d.seq].acts[act].cea_type = uar_get_code_display
     (ca.cea_type_cd),
     diag->events[d.seq].acts[act].charge_type_cd = ca.charge_type_cd, diag->events[d.seq].acts[act].
     cea_prsnl_id = ca.cea_prsnl_id, diag->events[d.seq].acts[act].updt_dt = format(ca.updt_dt_tm,
      "mm/dd/yyyy hh:mm;;d")
    DETAIL
     mod += 1, stat = alterlist(diag->events[d.seq].acts[act].diag,mod), diag->events[d.seq].acts[act
     ].diag[mod].diag_cd = cm.field2_id,
     diag->events[d.seq].acts[act].diag[mod].diag1_id = cm.field3_id, diag->events[d.seq].acts[act].
     diag[mod].diag2_id = cm.field4_id, diag->events[d.seq].acts[act].diag[mod].diag3_id = cm
     .field5_id,
     diag->events[d.seq].acts[act].diag[mod].diag1 = uar_get_code_display(cm.field3_id), diag->
     events[d.seq].acts[act].diag[mod].diag2 = uar_get_code_display(cm.field4_id), diag->events[d.seq
     ].acts[act].diag[mod].diag3 = uar_get_code_display(cm.field5_id),
     diag->events[d.seq].acts[act].diag[mod].diag_reason = cm.field6, diag->events[d.seq].acts[act].
     diag[mod].diag_tier = cnvtreal(cm.field7)
    WITH outerjoin = d1, nocounter
   ;end select
   FOR (event = 1 TO eventcnt)
     SET pid = 0.0
     SET pcd = 0.0
     SET cid = 0.0
     SET ccd = 0.0
     SET bill_id = 0.0
     IF ((diag->events[event].parent_ref_id > 0)
      AND (diag->events[event].parent_cont_cd > 0))
      SET pid = diag->events[event].parent_ref_id
      SET pcd = diag->events[event].parent_cont_cd
      SET cid = diag->events[event].item_ref_id
      SET ccd = diag->events[event].item_cont_cd
     ELSE
      SET pid = diag->events[event].item_ref_id
      SET pcd = diag->events[event].item_cont_cd
     ENDIF
     SELECT INTO "nl:"
      bi.ext_description, bi.bill_item_id
      FROM bill_item bi
      WHERE bi.ext_parent_reference_id=pid
       AND bi.ext_parent_contributor_cd=pcd
       AND bi.ext_child_reference_id=cid
       AND bi.ext_child_contributor_cd=ccd
      DETAIL
       bill_id = bi.bill_item_id, diag->events[event].bill_item = bi.ext_description
      WITH nocounter
     ;end select
     IF (bill_id=0
      AND cid > 0
      AND ccd > 0)
      SELECT INTO "nl:"
       bi.ext_description, bi.bill_item_id
       FROM bill_item bi
       WHERE bi.ext_parent_reference_id=cid
        AND bi.ext_parent_contributor_cd=ccd
        AND bi.ext_child_reference_id=0
        AND bi.ext_child_contributor_cd=0
       DETAIL
        bill_id = bi.bill_item_id, diag->events[event].bill_item = bi.ext_description
       WITH nocounter
      ;end select
     ENDIF
     IF (bill_id=0
      AND cid > 0
      AND ccd > 0)
      SELECT INTO "nl:"
       bi.ext_description, bi.bill_item_id
       FROM bill_item bi
       WHERE bi.ext_parent_reference_id=0
        AND bi.ext_parent_contributor_cd=0
        AND bi.ext_child_reference_id=cid
        AND bi.ext_child_contributor_cd=ccd
       DETAIL
        bill_id = bi.bill_item_id, diag->events[event].bill_item = bi.ext_description
       WITH nocounter
      ;end select
     ENDIF
     SET charge = 0
     SET actcnt = size(diag->events[event].acts,5)
     SELECT INTO "nl:"
      c.charge_item_id
      FROM charge c,
       (dummyt d  WITH seq = value(actcnt))
      PLAN (d)
       JOIN (c
       WHERE (c.charge_event_id=diag->events[event].charge_event_id)
        AND (c.charge_event_act_id=diag->events[event].acts[d.seq].charge_act_id))
      DETAIL
       charge += 1, stat = alterlist(diag->events[event].acts[d.seq].charges,charge), diag->events[
       event].acts[d.seq].charges[charge].charge_item_id = c.charge_item_id
      WITH nocounter
     ;end select
     FOR (act = 1 TO actcnt)
       SET modcnt = size(diag->events[event].acts[act].diag,5)
       SELECT INTO "nl:"
        o.org_name
        FROM organization o,
         (dummyt d  WITH seq = value(modcnt))
        PLAN (d
         WHERE (diag->events[event].acts[act].diag[d.seq].diag_cd IN (diag->no_tier_for_org, diag->
         no_pnt_tier)))
         JOIN (o
         WHERE (o.organization_id=diag->events[event].acts[act].diag[d.seq].diag1_id))
        DETAIL
         diag->events[event].acts[act].diag[d.seq].diag1 = o.org_name
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        p.price_sched_desc
        FROM price_sched p,
         (dummyt d  WITH seq = value(modcnt))
        PLAN (d
         WHERE (diag->events[event].acts[act].diag[d.seq].diag_cd=diag->no_chrg_ind))
         JOIN (p
         WHERE (p.price_sched_id=diag->events[event].acts[act].diag[d.seq].diag1_id))
        DETAIL
         diag->events[event].acts[act].diag[d.seq].diag1 = p.price_sched_desc
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        p.name_last, p.name_first
        FROM person p,
         (dummyt d  WITH seq = value(modcnt))
        PLAN (d
         WHERE (diag->events[event].acts[act].diag[d.seq].diag_cd=diag->no_phleb_chrg))
         JOIN (p
         WHERE (p.person_id=diag->events[event].acts[act].cea_prsnl_id))
        DETAIL
         diag->events[event].acts[act].cea_first_name = p.name_first, diag->events[event].acts[act].
         cea_last_name = p.name_last
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        b.ext_description
        FROM bill_item b,
         (dummyt d  WITH seq = value(modcnt))
        PLAN (d
         WHERE (diag->events[event].acts[act].diag[d.seq].diag_cd=diag->not_at_chrg_lvl))
         JOIN (b
         WHERE (b.bill_item_id=diag->events[event].acts[act].diag[d.seq].diag3_id))
        DETAIL
         diag->events[event].acts[act].diag[d.seq].diag3 = b.ext_description
        WITH nocounter
       ;end select
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE createreport(c)
   DECLARE cea_type = vc
   SET act = 0
   SET mod = 0
   SET chg = 0
   SET dashed_line = fillstring(130,"-")
   SELECT
    FROM (dummyt d  WITH seq = value(eventcnt))
    HEAD REPORT
     col 48, "Charging Server Diagnostics Report", row + 1,
     col 48, "----------------------------------", row + 2,
     col 01, "MEvent Id", col 13,
     "Order Id", col 25, "CEvent Id",
     col 37, "Accession", col 65,
     "Bill Item", col 105, "Patient",
     row + 1, col 06, "CEventAct Id",
     col 20, "Event", col 34,
     "Update Date", col 56, "Tier",
     col 67, "Reason", row + 1
    DETAIL
     col 00, dashed_line, row + 1,
     col 01, diag->events[d.seq].master_event_id"##########;L", col 13,
     diag->events[d.seq].order_id"##########;L", col 25, diag->events[d.seq].charge_event_id
     "##########;L",
     col 37, diag->events[d.seq].accession"############################;L", col 65,
     diag->events[d.seq].bill_item"#############################;L", col 105, diag->events[d.seq].
     person_name"####################;L",
     row + 1
     FOR (act = 1 TO size(diag->events[d.seq].acts,5))
      cea_type = trim(diag->events[d.seq].acts[act].cea_type),
      IF (substring((size(cea_type,1) - 2),3,cea_type) != "ING")
       col 06, diag->events[d.seq].acts[act].charge_act_id"##########;L", col 20,
       diag->events[d.seq].acts[act].cea_type, col 34, diag->events[d.seq].acts[act].updt_dt
       FOR (mod = 1 TO size(diag->events[d.seq].acts[act].diag,5))
         IF ((diag->events[d.seq].acts[act].diag[mod].diag_cd > 0))
          col 56, diag->events[d.seq].acts[act].diag[mod].diag_tier"##########;L", col 68,
          diag->events[d.seq].acts[act].diag[mod].diag_reason, row + 1
          CASE (diag->events[d.seq].acts[act].diag[mod].diag_cd)
           OF diag->not_at_chrg_pnt:
            col 68,"Charge Sched:",col 83,
            diag->events[d.seq].acts[act].diag[mod].diag1_id"##########;L",col 92," -",
            diag->events[d.seq].acts[act].diag[mod].diag1"###################################",row +
            1,col 68,
            "Point on item:",col 83,diag->events[d.seq].acts[act].diag[mod].diag2_id"##########;L",
            col 92," -",diag->events[d.seq].acts[act].diag[mod].diag2
            "###################################",
            row + 1
           OF diag->no_pnt_item:
            col 68,"Charge Sched:",col 83,
            diag->events[d.seq].acts[act].diag[mod].diag1_id"##########;L",col 92," -",
            diag->events[d.seq].acts[act].diag[mod].diag1"###################################",row +
            1
           OF diag->no_pnt_tier:
            col 68,"Organization:",col 83,
            diag->events[d.seq].acts[act].diag[mod].diag1_id"##########;L",col 92," -",
            diag->events[d.seq].acts[act].diag[mod].diag1"###################################",row +
            1,col 68,
            "Tier group:",col 83,diag->events[d.seq].acts[act].diag[mod].diag2_id"##########;L",
            col 92," -",diag->events[d.seq].acts[act].diag[mod].diag2
            "###################################",
            row + 1
           OF diag->not_at_chrg_lvl:
            col 68,"Charge Sched:",col 83,
            diag->events[d.seq].acts[act].diag[mod].diag1_id"##########;L",col 92," -",
            diag->events[d.seq].acts[act].diag[mod].diag1"###################################",row +
            1,col 68,
            "Charge Level:",col 83,diag->events[d.seq].acts[act].diag[mod].diag2_id"##########;L",
            col 92," -",diag->events[d.seq].acts[act].diag[mod].diag2
            "###################################",
            row + 1,col 68,"Bill Item Id:",
            col 83,diag->events[d.seq].acts[act].diag[mod].diag3_id"##########;L",col 92,
            " -",diag->events[d.seq].acts[act].diag[mod].diag3"###################################",
            row + 1
           OF diag->no_chrg_ind:
            col 68,"Price Sched:",col 83,
            diag->events[d.seq].acts[act].diag[mod].diag1_id"##########;L",col 92," -",
            diag->events[d.seq].acts[act].diag[mod].diag1"###################################",row +
            1
           OF diag->no_tier_for_org:
            col 68,"Organization:",col 83,
            diag->events[d.seq].acts[act].diag[mod].diag1_id"##########;L",col 92," -",
            diag->events[d.seq].acts[act].diag[mod].diag1"###################################",row +
            1
           OF diag->no_phleb_chrg:
            col 68,"Person:",col 83,
            diag->events[d.seq].acts[act].cea_last_name,", ",diag->events[d.seq].acts[act].
            cea_first_name,
            row + 1,col 68,"PhlebCharging:",
            IF ((diag->events[d.seq].acts[act].diag[mod].diag1_id=1))
             col 83, "ON"
            ELSE
             col 83, "OFF"
            ENDIF
            ,row + 1
          ENDCASE
          row + 1
         ELSEIF ((diag->events[d.seq].acts[act].charge_type_cd=diag->workload_only))
          col 68, "Charge type is WORKOADONLY", row + 2
         ELSEIF (size(diag->events[d.seq].acts[act].charges,5) > 0)
          col 68, "There was a charge created", row + 1,
          col 68, "ChargeItemId:"
          FOR (chg = 1 TO size(diag->events[d.seq].acts[act].charges,5))
            col 83, diag->events[d.seq].acts[act].charges[chg].charge_item_id"##########;L", row + 1
          ENDFOR
          row + 1
         ELSE
          col 68, "No Reason Found", row + 2
         ENDIF
       ENDFOR
      ENDIF
     ENDFOR
    WITH nocounter
   ;end select
 END ;Subroutine
 CALL initialize("NULL")
 CALL readdiaginfo("NULL")
 CALL createreport("NULL")
 FREE SET diag
END GO
