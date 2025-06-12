CREATE PROGRAM aps_get_order_info:dba
 IF (curutc=1)
  SET orders->time_zone = curtimezoneapp
 ELSE
  SET orders->time_zone = 0
 ENDIF
 SET cnt = cnvtint(size(replyout->orderlist,5))
 SET reqinfo->commit_ind = 0
 CALL echo(build("orders->case_id = ",orders->case_id))
 CALL echo(build("orders->last_case_id = ",orders->last_case_id))
 IF ((orders->case_id != orders->last_case_id))
  CALL loadpathcaseinfo(0)
 ENDIF
 IF ((((orders->last_case_id != orders->case_id)) OR ((orders->case_id=0.0))) )
  GO TO exit_script
 ENDIF
 CALL echo(build("Preparing to build orders for accession: ",orders->accession_nbr))
 IF ((((orders->type_ind=ot->specimen_order)) OR ((orders->type_ind=ot->specimen_update))) )
  IF ((cd->specimen_type_cd=0.0))
   CALL loadspecimentypecd(0)
  ENDIF
  IF ((cd->specimen_type_cd=0.0))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((((orders->type_ind=ot->specimen_update)) OR ((((orders->type_ind=ot->report_update)) OR ((
 orders->type_ind=ot->task_update))) )) )
  IF ((cd->order_canceled_cd=0.0))
   CALL loadorderstatuscd(0)
  ENDIF
  IF ((cd->order_canceled_cd=0.0))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((((orders->type_ind=ot->specimen_order)) OR ((((orders->type_ind=ot->report_order)) OR ((orders
 ->type_ind=ot->task_order))) )) )
  IF ((order_encntr_info->encntr_id=0.0))
   CALL loadencounter(0)
  ENDIF
  IF ((order_encntr_info->encntr_id=0.0))
   GO TO exit_script
  ENDIF
  IF ((cd->dept_status_cd=0.0))
   CALL loaddeptstatuscd(0)
  ENDIF
  IF ((cd->dept_status_cd=0.0))
   GO TO exit_script
  ENDIF
  SET replyout->passingencntrinfoind = 1
  SET replyout->encntrfinancialid = order_encntr_info->encntr_financial_id
  SET replyout->locationcd = order_encntr_info->location_cd
  SET replyout->locfacilitycd = order_encntr_info->loc_facility_cd
  SET replyout->locnurseunitcd = order_encntr_info->loc_nurse_unit_cd
  SET replyout->locroomcd = order_encntr_info->loc_room_cd
  SET replyout->locbedcd = order_encntr_info->loc_bed_cd
  CALL echo(build("replyout->passingEncntrInfoInd = ",replyout->passingencntrinfoind))
  CALL echo(build("replyout->encntrFinancialId = ",replyout->encntrfinancialid))
  CALL echo(build("replyout->locationCd = ",replyout->locationcd))
  CALL echo(build("replyout->locFacilityCd = ",replyout->locfacilitycd))
  CALL echo(build("replyout->locNurseUnitCd = ",replyout->locnurseunitcd))
  CALL echo(build("replyout->locRoomCd = ",replyout->locroomcd))
  CALL echo(build("replyout->locBedCd = ",replyout->locbedcd))
 ENDIF
 IF ((orders->type_ind=ot->task_update))
  IF ((cd->dos_collection_cd=0.0))
   CALL loaddateofservicecds(0)
  ENDIF
 ENDIF
 SET order_idx = 0
 FOR (orders_idx = 1 TO orders->qual_cnt)
   IF ((orders->qual[orders_idx].type_ind=ot->specimen_order))
    SET orders->qual[orders_idx].catalog_cd = orders->specimen_catalog_cd
   ENDIF
 ENDFOR
 SET replyout->personid = orders->person_id
 SET replyout->encntrid = orders->encntr_id
 SET replyout->commitgroupind = 1
 IF ((orders->trigger_app > 0))
  SET replyout->trigger_app = orders->trigger_app
 ENDIF
 CALL echo(build("replyout->personId = ",replyout->personid))
 CALL echo(build("replyout->encntrId = ",replyout->encntrid))
 CALL echo(build("replyout->commitGroupInd = ",replyout->commitgroupind))
 CALL getorderentryformatfields(0)
 SET order_idx = 0
 FOR (orders_idx = 1 TO orders->qual_cnt)
   IF ((orders->qual[orders_idx].type_ind=orders->type_ind))
    SET oe_format_info->catalog_cd = orders->qual[orders_idx].catalog_cd
    IF ((((orders->type_ind=ot->specimen_update)) OR ((((orders->type_ind=ot->report_update)) OR ((
    orders->type_ind=ot->task_update))) )) )
     IF ((orders->qual[orders_idx].action_type_cd=cd->cancel_action_type_cd))
      SET oe_format_info->action_type_cd = cd->cancel_action_type_cd
     ELSE
      SET oe_format_info->action_type_cd = cd->order_action_type_cd
     ENDIF
    ELSE
     SET oe_format_info->action_type_cd = cd->order_action_type_cd
    ENDIF
    CALL getorderentryformatfieldsforcatalog(0)
    CALL echo(build("oe_format_info->qual_idx = ",oe_format_info->qual_idx))
    IF ((oe_format_info->qual_idx > 0))
     IF ((((orders->type_ind=ot->specimen_update)) OR ((((orders->type_ind=ot->report_update)) OR ((
     orders->type_ind=ot->task_update))) )) )
      IF ((orders->qual[orders_idx].action_type_cd=cd->modify_action_type_cd))
       CALL echo(build("Preparing to process modify order for id: ",orders->qual[orders_idx].id))
      ELSE
       IF ((orders->qual[orders_idx].order_status_cd=0.0))
        CALL getorderstatus(0)
       ENDIF
       IF ((orders->qual[orders_idx].order_status_cd != cd->order_canceled_cd)
        AND (orders->qual[orders_idx].order_status_cd != cd->order_completed_cd))
        IF ((orders->qual[orders_idx].case_id != 0.0))
         CALL echo(build("orders->qual[",orders_idx,"].case_id = ",orders->qual[orders_idx].case_id))
         CALL echo("replyout->commitGroupInd = 0")
         SET replyout->commitgroupind = 0
         SET orders->case_id = orders->qual[orders_idx].case_id
         IF ((orders->case_id != orders->last_case_id))
          CALL loadpathcaseinfo(0)
         ENDIF
        ENDIF
        IF ((orders->type_ind=ot->report_update))
         CALL updateorderprovider(0)
        ENDIF
        CALL startopsexception(0)
       ELSE
        SET orders->ops_parent_id = orders->qual[orders_idx].id
        CALL deleteopsexception(0)
       ENDIF
      ENDIF
     ELSE
      IF ((orders->qual[orders_idx].order_id=0.0))
       CALL startopsexception(0)
      ELSE
       SET orders->ops_parent_id = orders->qual[orders_idx].id
       CALL deleteopsexception(0)
      ENDIF
     ENDIF
     IF ((((orders->qual[orders_idx].in_process_ind=1)) OR ((orders->qual[orders_idx].action_type_cd=
     cd->modify_action_type_cd))) )
      SET qual_idx = oe_format_info->qual_idx
      SET cnt += 1
      SET stat = alterlist(replyout->orderlist,cnt)
      IF ((orders->time_zone != curtimezoneapp)
       AND (orders->time_zone != 0))
       SET replyout->orderlist[cnt].useroverridetz = orders->time_zone
      ENDIF
      CALL loadorderlevelinfo(0)
      CALL loadorderdetaillevelinfo(0)
      SET reqinfo->commit_ind = 1
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SUBROUTINE loadspecimentypecd(dummy1)
  CALL echo("Loading specimen type cd information.")
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=2052
    AND cv.cdf_meaning="AP"
    AND cv.active_ind=1
   HEAD REPORT
    cd->specimen_type_cd = 0.0, cd->specimen_type_disp = ""
   DETAIL
    cd->specimen_type_cd = cv.code_value, cd->specimen_type_disp = cv.display
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE updateorderprovider(dummy)
   DECLARE action_seq = i4 WITH noconstant(0)
   DECLARE nfound = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    oa.action_sequence
    FROM order_action oa
    WHERE (oa.order_id=orders->qual[orders_idx].order_id)
     AND oa.action_type_cd IN (cd->order_action_type_cd, cd->activate_action_type_cd, cd->
    modify_action_type_cd, cd->renew_action_type_cd, cd->resume_action_type_cd,
    cd->stud_act_action_type_cd)
    ORDER BY oa.action_sequence DESC
    HEAD REPORT
     IF ((oa.order_provider_id != orders->requesting_physician_id))
      action_seq = oa.action_sequence, nfound = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (nfound=1)
    SELECT INTO "nl:"
     oa.order_id
     FROM order_action oa
     WHERE (oa.order_id=orders->qual[orders_idx].order_id)
      AND oa.action_sequence=action_seq
     WITH nocounter, forupdate(oa)
    ;end select
    UPDATE  FROM order_action oa
     SET oa.order_provider_id = orders->requesting_physician_id
     WHERE (orders->qual[orders_idx].order_id=oa.order_id)
      AND action_seq=oa.action_sequence
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE loaddeptstatuscd(dummy2)
  CALL echo("Loading dept status cd information.")
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=14281
    AND cv.cdf_meaning="INPATHOLOGY"
    AND cv.active_ind=1
   HEAD REPORT
    cd->dept_status_cd = 0.0
   DETAIL
    cd->dept_status_cd = cv.code_value
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE loaddateofservicecds(dummy19)
  CALL echo("Loading date of service cd information.")
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=24989
   HEAD REPORT
    cd->dos_collection_cd = 0.0, cd->dos_received_cd = 0.0, cd->dos_taskorder_cd = 0.0,
    cd->dos_current_cd = 0.0
   DETAIL
    IF (cv.cdf_meaning="COLLECTION")
     cd->dos_collection_cd = cv.code_value
    ELSEIF (cv.cdf_meaning="RECEIVED")
     cd->dos_received_cd = cv.code_value
    ELSEIF (cv.cdf_meaning="TASKORDER")
     cd->dos_taskorder_cd = cv.code_value
    ELSEIF (cv.cdf_meaning="CURRENT")
     cd->dos_current_cd = cv.code_value
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE loadorderstatuscd(dummy18)
  CALL echo("Loading order status cd information.")
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=6004
    AND cv.cdf_meaning IN ("CANCELED", "COMPLETED")
    AND cv.active_ind=1
   HEAD REPORT
    cd->order_canceled_cd = 0.0, cd->order_completed_cd = 0.0
   DETAIL
    IF (cv.cdf_meaning="CANCELED")
     cd->order_canceled_cd = cv.code_value
    ELSEIF (cv.cdf_meaning="COMPLETED")
     cd->order_completed_cd = cv.code_value
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE loadpathcaseinfo(dummy4)
   CALL echo(build("Loading pathology case information for case_id:  ",orders->case_id))
   SELECT INTO "nl:"
    pc.person_id
    FROM pathology_case pc,
     ap_prefix ap
    PLAN (pc
     WHERE (orders->case_id=pc.case_id)
      AND pc.case_id != 0.0)
     JOIN (ap
     WHERE pc.prefix_id=ap.prefix_id)
    DETAIL
     orders->person_id = pc.person_id, orders->encntr_id = pc.encntr_id, orders->
     requesting_physician_id = pc.requesting_physician_id,
     orders->responsible_pathologist_id = pc.responsible_pathologist_id, orders->accession_nbr = pc
     .accession_nbr, orders->case_received_dt_tm = cnvtdatetime(pc.case_received_dt_tm),
     orders->case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm), orders->specimen_catalog_cd =
     ap.order_catalog_cd
    WITH nocounter
   ;end select
   IF (curqual != 0)
    SET orders->last_case_id = orders->case_id
    SET order_encntr_info->encntr_id = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE getorderstatus(dummy17)
   SET orders->qual[orders_idx].order_status_cd = 0.0
   SELECT INTO "nl:"
    o.catalog_cd
    FROM orders o
    PLAN (o
     WHERE (orders->qual[orders_idx].order_id=o.order_id))
    DETAIL
     orders->qual[orders_idx].order_status_cd = o.order_status_cd
    WITH nocounter
   ;end select
   CALL echo(build("Order has a status of: ",orders->qual[orders_idx].order_status_cd))
 END ;Subroutine
 SUBROUTINE loadencounter(dummy5)
   CALL echo(build("Loading encounter information for encntr_id:  ",orders->encntr_id))
   SET order_encntr_info->encntr_id = orders->encntr_id
   SELECT INTO "nl:"
    e.encntr_id
    FROM encounter e
    WHERE (order_encntr_info->encntr_id=e.encntr_id)
     AND e.encntr_id != 0.0
    HEAD REPORT
     order_encntr_info->encntr_financial_id = 0.0, order_encntr_info->location_cd = 0.0,
     order_encntr_info->loc_facility_cd = 0.0,
     order_encntr_info->loc_nurse_unit_cd = 0.0, order_encntr_info->loc_room_cd = 0.0,
     order_encntr_info->loc_bed_cd = 0.0
    DETAIL
     order_encntr_info->encntr_financial_id = e.encntr_financial_id, order_encntr_info->location_cd
      = e.location_cd, order_encntr_info->loc_facility_cd = e.loc_facility_cd,
     order_encntr_info->loc_nurse_unit_cd = e.loc_nurse_unit_cd, order_encntr_info->loc_room_cd = e
     .loc_room_cd, order_encntr_info->loc_bed_cd = e.loc_bed_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET order_encntr_info->encntr_id = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE getorderentryformatfieldsforcatalog(dummy6)
   SET nbr_of_items = cnvtint(size(oe_format_info->qual,5))
   SET oe_x = 0
   SET oe_format_info->qual_idx = 0
   SET oe_format_info->fldqual_idx = 0
   FOR (oe_x = 1 TO nbr_of_items)
     IF ((oe_format_info->qual[oe_x].catalog_cd=oe_format_info->catalog_cd)
      AND (oe_format_info->qual[oe_x].action_type_cd=oe_format_info->action_type_cd))
      SET oe_format_info->qual_idx = oe_x
      SET oe_x = nbr_of_items
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE getorderentryformatfieldsdetail(dummy7)
   SET oe_x = 0
   SET oe_format_info->fldqual_idx = 0
   IF ((oe_format_info->qual_idx > 0)
    AND (oe_format_info->qual_idx <= size(oe_format_info->qual,5)))
    FOR (oe_x = 1 TO oe_format_info->qual[oe_format_info->qual_idx].fldqual_cnt)
      IF ((oe_format_info->qual[oe_format_info->qual_idx].fldqual[oe_x].oe_field_meaning_id=
      oe_format_info->oe_field_meaning_id))
       SET oe_format_info->fldqual_idx = oe_x
       SET oe_x = oe_format_info->qual[oe_format_info->qual_idx].fldqual_cnt
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE getorderentryformatfields(dummy8)
   SET order_idx = 0
   SET load_oe_formats = 0
   FOR (orders_idx = 1 TO orders->qual_cnt)
     SET oe_format_info->catalog_cd = orders->qual[orders_idx].catalog_cd
     IF ((((orders->type_ind=ot->specimen_update)) OR ((((orders->type_ind=ot->report_update)) OR ((
     orders->type_ind=ot->task_update))) )) )
      IF ((orders->qual[orders_idx].action_type_cd=cd->cancel_action_type_cd))
       SET oe_format_info->action_type_cd = cd->cancel_action_type_cd
      ELSE
       SET oe_format_info->action_type_cd = cd->order_action_type_cd
      ENDIF
     ELSE
      SET oe_format_info->action_type_cd = cd->order_action_type_cd
     ENDIF
     CALL getorderentryformatfieldsforcatalog(0)
     IF ((oe_format_info->qual_idx=0))
      SET stat = alterlist(oe_format_info->qual,(size(oe_format_info->qual,5)+ 1))
      SET oe_format_info->qual[size(oe_format_info->qual,5)].catalog_cd = orders->qual[orders_idx].
      catalog_cd
      IF ((((orders->type_ind=ot->specimen_update)) OR ((((orders->type_ind=ot->report_update)) OR ((
      orders->type_ind=ot->task_update))) )) )
       IF ((orders->qual[orders_idx].action_type_cd=cd->cancel_action_type_cd))
        SET oe_format_info->qual[size(oe_format_info->qual,5)].action_type_cd = cd->
        cancel_action_type_cd
       ELSE
        SET oe_format_info->qual[size(oe_format_info->qual,5)].action_type_cd = cd->
        order_action_type_cd
       ENDIF
      ELSE
       SET oe_format_info->qual[size(oe_format_info->qual,5)].action_type_cd = cd->
       order_action_type_cd
      ENDIF
      SET load_oe_formats = 1
     ENDIF
   ENDFOR
   IF (load_oe_formats > 0)
    CALL loadorderentryformatfields(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadorderentryformatfields(dummy9)
   SET code_set = 0
   SET cdf_meaning = fillstring(12," ")
   SET code_value = 0.0
   SET code_set = 6006
   SET cdf_meaning = "WRITTEN"
   EXECUTE cpm_get_cd_for_cdf
   SET oe_format_info->communication_type_cd = code_value
   SET code_set = 6011
   SET cdf_meaning = "PRIMARY"
   EXECUTE cpm_get_cd_for_cdf
   SET mnemonic_type_cd = code_value
   SET nbr_to_get = cnvtint(size(oe_format_info->qual,5))
   CALL echo(build("Loading order entry format information for:  ",nbr_to_get," catalog cds."))
   SELECT INTO "nl:"
    dt.seq, oc.catalog_cd, ocs.catalog_cd,
    ocs.oe_format_id, fields_exist = decode(off.seq,"Y","N"), oef.oe_field_id,
    ofm.oe_field_meaning
    FROM (dummyt dt  WITH seq = value(nbr_to_get)),
     order_catalog oc,
     order_catalog_synonym ocs,
     (dummyt d1  WITH seq = 1),
     oe_format_fields off,
     order_entry_fields oef,
     oe_field_meaning ofm
    PLAN (dt)
     JOIN (oc
     WHERE (oe_format_info->qual[dt.seq].catalog_cd=oc.catalog_cd))
     JOIN (ocs
     WHERE oc.catalog_cd=ocs.catalog_cd
      AND mnemonic_type_cd=ocs.mnemonic_type_cd)
     JOIN (d1
     WHERE 1=d1.seq)
     JOIN (off
     WHERE ocs.oe_format_id=off.oe_format_id
      AND (oe_format_info->qual[dt.seq].action_type_cd=off.action_type_cd))
     JOIN (oef
     WHERE off.oe_field_id=oef.oe_field_id)
     JOIN (ofm
     WHERE oef.oe_field_meaning_id=ofm.oe_field_meaning_id)
    ORDER BY dt.seq
    HEAD REPORT
     count1 = 0
    HEAD dt.seq
     count2 = 0, count1 += 1, oe_format_info->qual[count1].primary_mnemonic = oc.primary_mnemonic,
     oe_format_info->qual[count1].dept_display_name = oc.dept_display_name, oe_format_info->qual[
     count1].activity_type_cd = oc.activity_type_cd, oe_format_info->qual[count1].activity_subtype_cd
      = oc.activity_subtype_cd,
     oe_format_info->qual[count1].cont_order_method_flag = oc.cont_order_method_flag, oe_format_info
     ->qual[count1].complete_upon_order_ind = oc.complete_upon_order_ind, oe_format_info->qual[count1
     ].order_review_ind = oc.order_review_ind,
     oe_format_info->qual[count1].print_req_ind = oc.print_req_ind, oe_format_info->qual[count1].
     requisition_format_cd = oc.requisition_format_cd, oe_format_info->qual[count1].
     requisition_routing_cd = oc.requisition_routing_cd,
     oe_format_info->qual[count1].resource_route_lvl = oc.resource_route_lvl, oe_format_info->qual[
     count1].consent_form_ind = oc.consent_form_ind, oe_format_info->qual[count1].
     consent_form_format_cd = oc.consent_form_format_cd,
     oe_format_info->qual[count1].consent_form_routing_cd = oc.consent_form_routing_cd,
     oe_format_info->qual[count1].dept_dup_check_ind = oc.dept_dup_check_ind, oe_format_info->qual[
     count1].abn_review_ind = oc.abn_review_ind,
     oe_format_info->qual[count1].review_hierarchy_id = oc.review_hierarchy_id, oe_format_info->qual[
     count1].ref_text_mask = oc.ref_text_mask, oe_format_info->qual[count1].dup_checking_ind = oc
     .dup_checking_ind,
     oe_format_info->qual[count1].orderable_type_flag = oc.orderable_type_flag, oe_format_info->qual[
     count1].catalog_type_cd = ocs.catalog_type_cd, oe_format_info->qual[count1].synonym_id = ocs
     .synonym_id,
     oe_format_info->qual[count1].mnemonic = ocs.mnemonic, oe_format_info->qual[count1].oe_format_id
      = ocs.oe_format_id
    DETAIL
     IF (fields_exist="Y")
      count2 += 1
      IF (count2 > size(oe_format_info->qual[count1].fldqual,5))
       stat = alterlist(oe_format_info->qual[count1].fldqual,(count2+ 10))
      ENDIF
      oe_format_info->qual[count1].fldqual[count2].oe_field_id = off.oe_field_id, oe_format_info->
      qual[count1].fldqual[count2].value_required_ind = off.value_required_ind, oe_format_info->qual[
      count1].fldqual[count2].group_seq = off.group_seq,
      oe_format_info->qual[count1].fldqual[count2].field_seq = off.field_seq, oe_format_info->qual[
      count1].fldqual[count2].default_value_id = cnvtreal(validate(off.default_parent_entity_id,off
        .default_value)), oe_format_info->qual[count1].fldqual[count2].default_value = off
      .default_value,
      oe_format_info->qual[count1].fldqual[count2].oe_field_meaning_id = oef.oe_field_meaning_id,
      oe_format_info->qual[count1].fldqual[count2].oe_field_meaning = ofm.oe_field_meaning
     ENDIF
    FOOT  dt.seq
     oe_format_info->qual[count1].fldqual_cnt = count2, stat = alterlist(oe_format_info->qual[count1]
      .fldqual,count2)
    WITH nocounter, outerjoin = d1, check
   ;end select
 END ;Subroutine
 SUBROUTINE loadorderlevelinfo(dummy10)
   SET replyout->orderlist[cnt].actiontypecd = orders->qual[orders_idx].action_type_cd
   SET replyout->orderlist[cnt].communicationtypecd = oe_format_info->communication_type_cd
   CALL echo(build("replyout->orderList[",cnt,"].actionTypeCd = ",replyout->orderlist[cnt].
     actiontypecd))
   CALL echo(build("replyout->orderList[",cnt,"].communicationTypeCd = ",replyout->orderlist[cnt].
     communicationtypecd))
   IF ((((orders->type_ind=ot->specimen_update)) OR ((((orders->type_ind=ot->report_update)) OR ((
   orders->type_ind=ot->task_update))) )) )
    CALL echo(build("Loading order information for order_id = ",orders->qual[orders_idx].order_id))
    SET replyout->orderlist[cnt].orderid = orders->qual[orders_idx].order_id
    SET replyout->orderlist[cnt].lastupdtcnt = orders->qual[orders_idx].updt_cnt
    IF ((orders->qual[orders_idx].action_type_cd != cd->complete_action_type_cd))
     SET replyout->orderlist[cnt].deptstatuscd = orders->qual[orders_idx].dept_status_cd
    ENDIF
    CALL echo(build("replyout->orderList[",cnt,"].orderId = ",replyout->orderlist[cnt].orderid))
    CALL echo(build("replyout->orderList[",cnt,"].lastUpdtCnt = ",replyout->orderlist[cnt].
      lastupdtcnt))
    CALL echo(build("replyout->orderList[",cnt,"].deptStatusCd = ",replyout->orderlist[cnt].
      deptstatuscd))
   ELSE
    CALL echo(build("Loading order information for id = ",orders->qual[orders_idx].id))
   ENDIF
   IF ((orders->qual[orders_idx].action_type_cd=cd->complete_action_type_cd))
    IF ((orders->type_ind=ot->task_update)
     AND (orders->qual[orders_idx].charge_verifying_id != 0.0))
     SET replyout->orderlist[cnt].orderproviderid = orders->qual[orders_idx].charge_verifying_id
    ELSE
     SET replyout->orderlist[cnt].orderproviderid = orders->responsible_pathologist_id
    ENDIF
   ELSEIF ((((orders->type_ind=ot->task_order)) OR ((orders->type_ind=ot->task_update))) )
    SET replyout->orderlist[cnt].orderproviderid = orders->requesting_prsnl_id
   ELSE
    SET replyout->orderlist[cnt].orderproviderid = orders->requesting_physician_id
   ENDIF
   CALL echo(build("replyout->orderList[",cnt,"].orderProviderId = ",replyout->orderlist[cnt].
     orderproviderid))
   IF ((((orders->type_ind=ot->specimen_order)) OR ((orders->type_ind=ot->specimen_update))) )
    SET replyout->orderlist[cnt].orderdttm = cnvtdatetime(orders->qual[orders_idx].received_dt_tm)
   ELSEIF ((((orders->type_ind=ot->task_order)) OR ((orders->type_ind=ot->task_update))) )
    SET replyout->orderlist[cnt].orderdttm = cnvtdatetime(orders->qual[orders_idx].request_dt_tm)
   ELSE
    SET replyout->orderlist[cnt].orderdttm = cnvtdatetime(orders->case_received_dt_tm)
   ENDIF
   CALL echo(build("replyout->orderList[",cnt,"].orderDtTm = ",replyout->orderlist[cnt].orderdttm))
   SET replyout->orderlist[cnt].oeformatid = oe_format_info->qual[qual_idx].oe_format_id
   SET replyout->orderlist[cnt].catalogtypecd = oe_format_info->qual[qual_idx].catalog_type_cd
   SET replyout->orderlist[cnt].accessionnbr = orders->accession_nbr
   SET replyout->orderlist[cnt].accessionid = orders->case_id
   SET replyout->orderlist[cnt].catalogcd = oe_format_info->qual[qual_idx].catalog_cd
   SET replyout->orderlist[cnt].synonymid = oe_format_info->qual[qual_idx].synonym_id
   SET replyout->orderlist[cnt].ordermnemonic = oe_format_info->qual[qual_idx].mnemonic
   CALL echo(build("replyout->orderList[",cnt,"].oeFormatId = ",replyout->orderlist[cnt].oeformatid))
   CALL echo(build("replyout->orderList[",cnt,"].catalogTypeCd = ",replyout->orderlist[cnt].
     catalogtypecd))
   CALL echo(build("replyout->orderList[",cnt,"].accessionNbr = ",replyout->orderlist[cnt].
     accessionnbr))
   CALL echo(build("replyout->orderList[",cnt,"].accessionId = ",replyout->orderlist[cnt].accessionid
     ))
   CALL echo(build("replyout->orderList[",cnt,"].catalogCd = ",replyout->orderlist[cnt].catalogcd))
   CALL echo(build("replyout->orderList[",cnt,"].synonymId = ",replyout->orderlist[cnt].synonymid))
   CALL echo(build("replyout->orderList[",cnt,"].orderMnemonic = ",replyout->orderlist[cnt].
     ordermnemonic))
   IF ((((orders->type_ind=ot->task_order)) OR ((orders->type_ind=ot->task_update))) )
    SET replyout->orderlist[cnt].nochargeind = orders->qual[orders_idx].no_charge_ind
    CALL echo(build("replyout->orderList[",cnt,"].noChargeInd = ",replyout->orderlist[cnt].
      nochargeind))
   ENDIF
   IF ((((orders->type_ind=ot->specimen_order)) OR ((((orders->type_ind=ot->report_order)) OR ((
   orders->type_ind=ot->task_order))) )) )
    SET replyout->orderlist[cnt].passingorcinfoind = 1
    SET replyout->orderlist[cnt].primarymnemonic = oe_format_info->qual[qual_idx].primary_mnemonic
    SET replyout->orderlist[cnt].deptdisplayname = oe_format_info->qual[qual_idx].dept_display_name
    SET replyout->orderlist[cnt].activitytypecd = oe_format_info->qual[qual_idx].activity_type_cd
    SET replyout->orderlist[cnt].activitysubtypecd = oe_format_info->qual[qual_idx].
    activity_subtype_cd
    SET replyout->orderlist[cnt].contordermethodflag = oe_format_info->qual[qual_idx].
    cont_order_method_flag
    SET replyout->orderlist[cnt].completeuponorderind = oe_format_info->qual[qual_idx].
    complete_upon_order_ind
    SET replyout->orderlist[cnt].orderreviewind = oe_format_info->qual[qual_idx].order_review_ind
    SET replyout->orderlist[cnt].printreqind = oe_format_info->qual[qual_idx].print_req_ind
    SET replyout->orderlist[cnt].requisitionformatcd = oe_format_info->qual[qual_idx].
    requisition_format_cd
    SET replyout->orderlist[cnt].requisitionroutingcd = oe_format_info->qual[qual_idx].
    requisition_routing_cd
    SET replyout->orderlist[cnt].resourceroutelevel = oe_format_info->qual[qual_idx].
    resource_route_lvl
    SET replyout->orderlist[cnt].consentformind = oe_format_info->qual[qual_idx].consent_form_ind
    SET replyout->orderlist[cnt].consentformformatcd = oe_format_info->qual[qual_idx].
    consent_form_format_cd
    SET replyout->orderlist[cnt].consentformroutingcd = oe_format_info->qual[qual_idx].
    consent_form_routing_cd
    SET replyout->orderlist[cnt].deptdupcheckind = oe_format_info->qual[qual_idx].dept_dup_check_ind
    SET replyout->orderlist[cnt].abnreviewind = oe_format_info->qual[qual_idx].abn_review_ind
    SET replyout->orderlist[cnt].reviewhierarchyid = oe_format_info->qual[qual_idx].
    review_hierarchy_id
    SET replyout->orderlist[cnt].deptstatuscd = cd->dept_status_cd
    SET replyout->orderlist[cnt].reftextmask = oe_format_info->qual[qual_idx].ref_text_mask
    SET replyout->orderlist[cnt].dupcheckingind = oe_format_info->qual[qual_idx].dup_checking_ind
    SET replyout->orderlist[cnt].orderabletypeflag = oe_format_info->qual[qual_idx].
    orderable_type_flag
    CALL echo(build("replyout->orderList[",cnt,"].passingOrcInfoInd = ",replyout->orderlist[cnt].
      passingorcinfoind))
    CALL echo(build("replyout->orderList[",cnt,"].primaryMnemonic = ",replyout->orderlist[cnt].
      primarymnemonic))
    CALL echo(build("replyout->orderList[",cnt,"].deptDisplayName = ",replyout->orderlist[cnt].
      deptdisplayname))
    CALL echo(build("replyout->orderList[",cnt,"].activityTypeCd = ",replyout->orderlist[cnt].
      activitytypecd))
    CALL echo(build("replyout->orderList[",cnt,"].activitySubtypeCd = ",replyout->orderlist[cnt].
      activitysubtypecd))
    CALL echo(build("replyout->orderList[",cnt,"].contOrderMethodFlag = ",replyout->orderlist[cnt].
      contordermethodflag))
    CALL echo(build("replyout->orderList[",cnt,"].completeUponOrderInd = ",replyout->orderlist[cnt].
      completeuponorderind))
    CALL echo(build("replyout->orderList[",cnt,"].orderReviewInd = ",replyout->orderlist[cnt].
      orderreviewind))
    CALL echo(build("replyout->orderList[",cnt,"].printReqInd = ",replyout->orderlist[cnt].
      printreqind))
    CALL echo(build("replyout->orderList[",cnt,"].requisitionFormatCd = ",replyout->orderlist[cnt].
      requisitionformatcd))
    CALL echo(build("replyout->orderList[",cnt,"].requisitionRoutingCd = ",replyout->orderlist[cnt].
      requisitionroutingcd))
    CALL echo(build("replyout->orderList[",cnt,"].deptDupCheckInd = ",replyout->orderlist[cnt].
      deptdupcheckind))
    CALL echo(build("replyout->orderList[",cnt,"].abnReviewInd = ",replyout->orderlist[cnt].
      abnreviewind))
    CALL echo(build("replyout->orderList[",cnt,"].reviewHierarchyId = ",replyout->orderlist[cnt].
      reviewhierarchyid))
    CALL echo(build("replyout->orderList[",cnt,"].deptStatusCd = ",replyout->orderlist[cnt].
      deptstatuscd))
    CALL echo(build("replyout->orderList[",cnt,"].refTextMask = ",replyout->orderlist[cnt].
      reftextmask))
    CALL echo(build("replyout->orderList[",cnt,"].dupCheckingInd = ",replyout->orderlist[cnt].
      dupcheckingind))
    CALL echo(build("replyout->orderList[",cnt,"].orderableTypeFlag = ",replyout->orderlist[cnt].
      orderabletypeflag))
   ENDIF
   IF ((orders->type_ind=ot->specimen_order))
    SET stat = alterlist(replyout->orderlist[cnt].misclist,1)
    SET replyout->orderlist[cnt].misclist[1].fieldmeaning = "specimenId"
    SET replyout->orderlist[cnt].misclist[1].fieldvalue = orders->qual[orders_idx].id
    CALL echo(build("replyout->orderList[",cnt,"].miscList[1].fieldMeaning = ",replyout->orderlist[
      cnt].misclist[1].fieldmeaning))
    CALL echo(build("replyout->orderList[",cnt,"].miscList[1].fieldValue = ",replyout->orderlist[cnt]
      .misclist[1].fieldvalue))
    SELECT INTO "NL:"
     FROM case_specimen cs,
      ap_tag ap,
      processing_task pt,
      ord_rqstn_ord_r oror
     PLAN (cs
      WHERE (cs.case_id=orders->case_id))
      JOIN (ap
      WHERE cs.specimen_tag_id=ap.tag_id
       AND ap.tag_sequence=1)
      JOIN (pt
      WHERE cs.case_specimen_id=pt.case_specimen_id
       AND pt.create_inventory_flag=4
       AND pt.order_id > 0)
      JOIN (oror
      WHERE oror.order_id=pt.order_id)
     DETAIL
      stat = alterlist(replyout->orderlist[cnt].misclist,2), replyout->orderlist[cnt].misclist[2].
      fieldmeaning = "REQIDID", replyout->orderlist[cnt].misclist[2].fieldmeaningid = 6011.00,
      replyout->orderlist[cnt].misclist[2].fieldvalue = oror.ord_rqstn_id, replyout->orderlist[cnt].
      misclist[2].modifiedind = 1
     WITH nocounter
    ;end select
   ELSEIF ((orders->type_ind=ot->report_order))
    SET stat = alterlist(replyout->orderlist[cnt].misclist,1)
    SET replyout->orderlist[cnt].misclist[1].fieldmeaning = "reportId"
    SET replyout->orderlist[cnt].misclist[1].fieldvalue = orders->qual[orders_idx].id
    CALL echo(build("replyout->orderList[",cnt,"].miscList[1].fieldMeaning = ",replyout->orderlist[
      cnt].misclist[1].fieldmeaning))
    CALL echo(build("replyout->orderList[",cnt,"].miscList[1].fieldValue = ",replyout->orderlist[cnt]
      .misclist[1].fieldvalue))
   ENDIF
   IF ((((orders->type_ind=ot->task_order)) OR ((orders->type_ind=ot->task_update))) )
    SET stat = alterlist(replyout->orderlist[cnt].misclist,1)
    SET replyout->orderlist[cnt].misclist[1].fieldmeaning = "processingId"
    SET replyout->orderlist[cnt].misclist[1].fieldvalue = orders->qual[orders_idx].id
    CALL echo(build("replyout->orderList[",cnt,"].miscList[1].fieldMeaning = ",replyout->orderlist[
      cnt].misclist[1].fieldmeaning))
    CALL echo(build("replyout->orderList[",cnt,"].miscList[1].fieldValue = ",replyout->orderlist[cnt]
      .misclist[1].fieldvalue))
   ENDIF
   IF ((orders->type_ind IN (ot->task_order, ot->report_order)))
    SET stat = alterlist(replyout->orderlist[cnt].misclist,2)
    SET replyout->orderlist[cnt].misclist[2].fieldmeaning = "REQIDID"
    SET replyout->orderlist[cnt].misclist[2].fieldmeaningid = 6011.00
    SET replyout->orderlist[cnt].misclist[2].fieldvalue = - (1.0)
    SET replyout->orderlist[cnt].misclist[2].modifiedind = 1
   ENDIF
   IF ((((orders->type_ind=ot->task_order)) OR ((orders->type_ind=ot->task_update))) )
    SELECT INTO "nl:"
     FROM processing_task pt,
      processing_task pt2,
      service_resource sr
     PLAN (pt
      WHERE (pt.processing_task_id=orders->qual[orders_idx].id))
      JOIN (pt2
      WHERE pt2.case_specimen_id=pt.case_specimen_id
       AND pt2.create_inventory_flag=4)
      JOIN (sr
      WHERE sr.service_resource_cd=pt2.service_resource_cd)
     DETAIL
      nidx = (size(replyout->orderlist[cnt].misclist,5)+ 1), stat = alterlist(replyout->orderlist[cnt
       ].misclist,nidx), replyout->orderlist[cnt].misclist[nidx].fieldmeaning = "specLogInLoc",
      replyout->orderlist[cnt].misclist[nidx].fieldvalue = sr.cs_login_loc_cd,
      CALL echo(build("replyout->orderList[",cnt,"].miscList[",nidx,"].fieldMeaning = ",
       replyout->orderlist[cnt].misclist[nidx].fieldmeaning)),
      CALL echo(build("replyout->orderList[",cnt,"].miscList[",nidx,"].fieldValue = ",
       replyout->orderlist[cnt].misclist[nidx].fieldvalue))
     WITH nocounter
    ;end select
   ELSEIF ((((orders->type_ind=ot->report_order)) OR ((orders->type_ind=ot->report_update))) )
    SELECT INTO "nl:"
     FROM case_report cr,
      case_specimen cs,
      ap_tag at,
      processing_task pt,
      service_resource sr
     PLAN (cr
      WHERE (cr.report_id=orders->qual[orders_idx].id))
      JOIN (cs
      WHERE cs.case_id=cr.case_id)
      JOIN (at
      WHERE at.tag_id=cs.specimen_tag_id)
      JOIN (pt
      WHERE pt.case_specimen_id=cs.case_specimen_id
       AND pt.create_inventory_flag=4)
      JOIN (sr
      WHERE sr.service_resource_cd=pt.service_resource_cd)
     ORDER BY at.tag_sequence
     HEAD cs.case_id
      IF (sr.service_resource_cd > 0.0)
       nidx = (size(replyout->orderlist[cnt].misclist,5)+ 1), stat = alterlist(replyout->orderlist[
        cnt].misclist,nidx), replyout->orderlist[cnt].misclist[nidx].fieldmeaning = "specLogInLoc",
       replyout->orderlist[cnt].misclist[nidx].fieldvalue = sr.cs_login_loc_cd,
       CALL echo(build("replyout->orderList[",cnt,"].miscList[",nidx,"].fieldMeaning = ",
        replyout->orderlist[cnt].misclist[nidx].fieldmeaning)),
       CALL echo(build("replyout->orderList[",cnt,"].miscList[",nidx,"].fieldValue = ",
        replyout->orderlist[cnt].misclist[nidx].fieldvalue))
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((orders->type_ind=ot->task_update)
    AND (orders->qual[orders_idx].action_type_cd=cd->complete_action_type_cd))
    SET stat = alterlist(replyout->orderlist[cnt].misclist,1)
    SET replyout->orderlist[cnt].misclist[1].fieldmeaning = "CHARGEDOS"
    SET replyout->orderlist[cnt].misclist[1].fieldmeaningid = 2
    IF ((orders->qual[orders_idx].charge_verifying_id != 0.0))
     IF ((orders->qual[orders_idx].charge_dos_cd=cd->dos_collection_cd))
      SET replyout->orderlist[cnt].misclist[1].fielddttmvalue = cnvtdatetime(orders->
       case_collect_dt_tm)
     ELSEIF ((orders->qual[orders_idx].charge_dos_cd=cd->dos_received_cd))
      SET replyout->orderlist[cnt].misclist[1].fielddttmvalue = cnvtdatetime(orders->
       case_received_dt_tm)
     ELSEIF ((orders->qual[orders_idx].charge_dos_cd=cd->dos_taskorder_cd))
      SET replyout->orderlist[cnt].misclist[1].fielddttmvalue = cnvtdatetime(orders->qual[orders_idx]
       .request_dt_tm)
     ELSEIF ((orders->qual[orders_idx].charge_dos_cd=cd->dos_current_cd))
      SET replyout->orderlist[cnt].misclist[1].fielddttmvalue = cnvtdatetime(sysdate)
     ELSE
      SET replyout->orderlist[cnt].misclist[1].fielddttmvalue = cnvtdatetime(orders->
       case_collect_dt_tm)
     ENDIF
    ELSE
     SET replyout->orderlist[cnt].misclist[1].fielddttmvalue = cnvtdatetime(orders->
      case_collect_dt_tm)
    ENDIF
    SET replyout->orderlist[cnt].misclist[1].modifiedind = 1
    CALL echo(build("replyout->orderList[",cnt,"].miscList[1].fieldMeaning = ",replyout->orderlist[
      cnt].misclist[1].fieldmeaning))
    CALL echo(build("replyout->orderList[",cnt,"].miscList[1].fieldMeaningId = ",replyout->orderlist[
      cnt].misclist[1].fieldmeaningid))
    CALL echo(build("replyout->orderList[",cnt,"].miscList[1].fieldDtTmValue = ",replyout->orderlist[
      cnt].misclist[1].fielddttmvalue))
    CALL echo(build("replyout->orderList[",cnt,"].miscList[1].modifiedInd = ",replyout->orderlist[cnt
      ].misclist[1].modifiedind))
   ENDIF
   IF ((orders->qual[orders_idx].service_resource_cd != 0.0))
    SET stat = alterlist(replyout->orderlist[cnt].resourcelist,1)
    SET replyout->orderlist[cnt].resourcelist[1].serviceresourcecd = orders->qual[orders_idx].
    service_resource_cd
    CALL echo(build("replyout->orderList[",cnt,"].resourceList[1].serviceResourceCd = ",replyout->
      orderlist[cnt].resourcelist[1].serviceresourcecd))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadorderdetaillevelinfo(dummy11)
   SET detailcnt = 0
   SET y = 1
   FOR (y = 1 TO oe_format_info->qual[qual_idx].fldqual_cnt)
     SET detailcnt += 1
     SET stat = alterlist(replyout->orderlist[cnt].detaillist,detailcnt)
     SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldid = oe_format_info->qual[qual_idx].
     fldqual[y].oe_field_id
     SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldmeaning = oe_format_info->qual[
     qual_idx].fldqual[y].oe_field_meaning
     SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldmeaningid = oe_format_info->qual[
     qual_idx].fldqual[y].oe_field_meaning_id
     SET replyout->orderlist[cnt].detaillist[detailcnt].valuerequiredind = oe_format_info->qual[
     qual_idx].fldqual[y].value_required_ind
     SET replyout->orderlist[cnt].detaillist[detailcnt].groupseq = oe_format_info->qual[qual_idx].
     fldqual[y].group_seq
     SET replyout->orderlist[cnt].detaillist[detailcnt].fieldseq = oe_format_info->qual[qual_idx].
     fldqual[y].field_seq
     CASE (oe_format_info->qual[qual_idx].fldqual[y].oe_field_meaning_id)
      OF 2:
       CALL prepareproviderdata(y)
      OF 3589:
       IF (validate(requestin->request.enable_cc_provider_pref_ind)=1)
        IF ((requestin->request.enable_cc_provider_pref_ind=1))
         CALL prepareproviderdata(y)
        ENDIF
       ENDIF
      OF 7:
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = orders->accession_nbr
       SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
       CALL echo("ACCESSION_NUMBER")
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
         replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
      OF 8:
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue = orders->qual[orders_idx].
       priority_cd
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = orders->qual[
       orders_idx].priority_disp
       SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
       CALL echo("REPORTING_PRIORITY")
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldValue = ",replyout
         ->orderlist[cnt].detaillist[detailcnt].oefieldvalue))
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
         replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
      OF 9:
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue = cd->specimen_type_cd
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = cd->
       specimen_type_disp
       SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
       CALL echo("SPECIMEN_TYPE")
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldValue = ",replyout
         ->orderlist[cnt].detaillist[detailcnt].oefieldvalue))
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
         replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
      OF 10:
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue = orders->case_id
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = cnvtstring(orders->
        case_id,32,6,r)
       SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
       CALL echo("ACCESSION_ID")
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
         replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
      OF 48:
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue = orders->qual[orders_idx].
       research_account_id
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = orders->qual[
       orders_idx].research_account_name
       SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
       CALL echo("RESEARCH ACCOUNT")
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldValue = ",replyout
         ->orderlist[cnt].detaillist[detailcnt].oefieldvalue))
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
         replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
      OF 51:
       IF ((orders->type_ind IN (ot->report_order, ot->task_order)))
        SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddttmvalue = cnvtdatetime(orders->
         case_collect_dt_tm)
       ELSE
        SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddttmvalue = cnvtdatetime(orders->
         qual[orders_idx].collect_dt_tm)
       ENDIF
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = format(cnvtdatetime(
         replyout->orderlist[cnt].detaillist[detailcnt].oefielddttmvalue),"DD-MMM-YYYY HH:MM;;D")
       SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
       CALL echo("COLLECTED_DATE_TIME")
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
         replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
      OF 1105:
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue = orders->qual[orders_idx].
       cancel_cd
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = orders->qual[
       orders_idx].cancel_disp
       SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
       CALL echo("CANCEL REASON")
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldValue = ",replyout
         ->orderlist[cnt].detaillist[detailcnt].oefieldvalue))
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
         replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
      OF 1124:
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = orders->qual[
       orders_idx].description
       SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
       CALL echo("SPECIMEN_DESCRIPTION")
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
         replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
      OF 6000:
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddttmvalue = cnvtdatetime(orders->
        qual[orders_idx].received_dt_tm)
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = format(cnvtdatetime(
         orders->qual[orders_idx].received_dt_tm),"DD-MMM-YYYY HH:MM;;D")
       SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
       CALL echo("SPECIMEN_RECEIVED_DATE_TIME")
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
         replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
      OF 6001:
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue = orders->qual[orders_idx].
       specimen_received_id
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = orders->qual[
       orders_idx].specimen_received_name
       SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
       CALL echo("SPECIMEN_RECEIVED_BY")
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldValue = ",replyout
         ->orderlist[cnt].detaillist[detailcnt].oefieldvalue))
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
         replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
      OF 6002:
       IF ((replyout->orderlist[cnt].orderid=0.0)
        AND (oe_format_info->qual[qual_idx].fldqual[y].default_value_id > 0.0))
        SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue = oe_format_info->qual[
        qual_idx].fldqual[y].default_value_id
        SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = uar_get_code_display
        (oe_format_info->qual[qual_idx].fldqual[y].default_value_id)
        SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
        CALL echo("SPECIMEN RECIEVED LOCATION")
        CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldValue = ",replyout
          ->orderlist[cnt].detaillist[detailcnt].oefieldvalue))
        CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
          replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
       ELSE
        SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 0
       ENDIF
      OF 6006:
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue = 1
       SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = "Collected"
       SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
       CALL echo("COLLECTED Y/N")
       CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
         replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
      OF 6012:
       IF (textlen(trim(oe_format_info->qual[qual_idx].fldqual[y].default_value)) > 0)
        SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue = 1
        SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue =
        "Print Request ID Labels"
        SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
        CALL echo("PRINT REQUEST ID LBL Y/N")
        CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
          replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
       ENDIF
      OF 6013:
       IF (textlen(trim(oe_format_info->qual[qual_idx].fldqual[y].default_value)) > 0)
        SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue = cnvtreal(oe_format_info->
         qual[qual_idx].fldqual[y].default_value)
        SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = build(
         "Number of Request ID Labels:",replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue)
        SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
        CALL echo("REQUEST ID NBR LBLS")
        CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
          replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue))
       ENDIF
      OF 6014:
       IF (textlen(trim(oe_format_info->qual[qual_idx].fldqual[y].default_value)) > 0)
        SET replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue = cnvtreal(oe_format_info->
         qual[qual_idx].fldqual[y].default_value)
        SET replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue = oe_format_info->
        qual[qual_idx].fldqual[y].default_value
        SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 1
        CALL echo("REQUEST ID LBL PRINTER")
        CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
          replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
       ENDIF
      ELSE
       SET replyout->orderlist[cnt].detaillist[detailcnt].modifiedind = 0
     ENDCASE
   ENDFOR
 END ;Subroutine
 SUBROUTINE prepareproviderdata(fldqual_cnt)
   SELECT INTO "nl:"
    c.case_id, p.person_id
    FROM case_provider c,
     prsnl p
    PLAN (c
     WHERE (orders->case_id=c.case_id))
     JOIN (p
     WHERE c.physician_id=p.person_id)
    HEAD REPORT
     consult_cnt = 0
    DETAIL
     consult_cnt += 1
     IF (consult_cnt > 1)
      detailcnt += 1, stat = alterlist(replyout->orderlist[cnt].detaillist,detailcnt), replyout->
      orderlist[cnt].detaillist[detailcnt].oefieldid = oe_format_info->qual[qual_idx].fldqual[
      fldqual_cnt].oe_field_id,
      replyout->orderlist[cnt].detaillist[detailcnt].oefieldmeaning = oe_format_info->qual[qual_idx].
      fldqual[fldqual_cnt].oe_field_meaning, replyout->orderlist[cnt].detaillist[detailcnt].
      oefieldmeaningid = oe_format_info->qual[qual_idx].fldqual[fldqual_cnt].oe_field_meaning_id,
      replyout->orderlist[cnt].detaillist[detailcnt].valuerequiredind = oe_format_info->qual[qual_idx
      ].fldqual[fldqual_cnt].value_required_ind,
      replyout->orderlist[cnt].detaillist[detailcnt].groupseq = oe_format_info->qual[qual_idx].
      fldqual[fldqual_cnt].group_seq, replyout->orderlist[cnt].detaillist[detailcnt].fieldseq =
      oe_format_info->qual[qual_idx].fldqual[fldqual_cnt].field_seq
     ENDIF
     replyout->orderlist[cnt].detaillist[detailcnt].oefieldvalue = p.person_id, replyout->orderlist[
     cnt].detaillist[detailcnt].oefielddisplayvalue = p.name_full_formatted, replyout->orderlist[cnt]
     .detaillist[detailcnt].modifiedind = 1,
     CALL echo(build("replyout->orderList[",cnt,"].detailList[detailcnt].oeFieldDisplayValue = ",
      replyout->orderlist[cnt].detaillist[detailcnt].oefielddisplayvalue))
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE startopsexception(dummy12)
   SET orders->ops_parent_id = orders->qual[orders_idx].id
   IF ((orders->ops_parent_id != 0.0))
    CALL checkopsexception(0)
   ENDIF
   IF ((orders->ops_parent_id != 0.0))
    CALL inactivateopsexception(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE checkopsexception(dummy13)
  SELECT INTO "nl:"
   a.parent_id, detail_exists = evaluate(nullind(aoed.parent_id),0,1,0)
   FROM ap_ops_exception a,
    ap_ops_exception_detail aoed
   PLAN (a
    WHERE (orders->ops_parent_id=a.parent_id)
     AND (a.action_flag=orders->type_ind)
     AND a.active_ind=1)
    JOIN (aoed
    WHERE (aoed.parent_id= Outerjoin(a.parent_id))
     AND (aoed.action_flag= Outerjoin(a.action_flag))
     AND (aoed.field_meaning= Outerjoin("TIME_ZONE")) )
   DETAIL
    IF (detail_exists)
     orders->time_zone = aoed.field_nbr
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   IF ((orders->type_ind=ot->specimen_order))
    CALL echo(build("ERROR:Unable to locate order for specimen_id = ",orders->ops_parent_id,
      " in ap_ops_exception. Skip processing ..."))
   ELSEIF ((orders->type_ind=ot->report_order))
    CALL echo(build("ERROR:Unable to locate order for report_id = ",orders->ops_parent_id,
      " in ap_ops_exception. Skip processing ..."))
   ELSEIF ((orders->type_ind=ot->task_order))
    CALL echo(build("ERROR:Unable to locate order for processing_task_id = ",orders->ops_parent_id,
      " in ap_ops_exception. Skip processing ..."))
   ELSEIF ((orders->type_ind=ot->specimen_update))
    CALL echo(build("ERROR:Unable to locate update for specimen_id = ",orders->ops_parent_id,
      " in ap_ops_exception. Skip processing ..."))
   ELSEIF ((orders->type_ind=ot->report_update))
    CALL echo(build("ERROR:Unable to locate update for report_id = ",orders->ops_parent_id,
      " in ap_ops_exception. Skip processing ..."))
   ELSEIF ((orders->type_ind=ot->task_update))
    CALL echo(build("ERROR:Unable to locate update for processing_task_id = ",orders->ops_parent_id,
      " in ap_ops_exception. Skip processing ..."))
   ELSE
    CALL echo(build("ERROR:Unable to locate an order type of ",orders->type_ind,
      " in ap_ops_exception. Skip processing ..."))
   ENDIF
   SET orders->ops_parent_id = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE inactivateopsexception(dummy14)
   UPDATE  FROM ap_ops_exception a
    SET a.active_ind = 0, a.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE (orders->ops_parent_id=a.parent_id)
     AND (a.action_flag=orders->type_ind)
     AND a.active_ind=1
    WITH nocounter
   ;end update
   IF (curqual != 0)
    SET orders->qual[orders_idx].in_process_ind = 1
    SET orders->qual[orders_idx].failed_ind = 1
    IF ( NOT (validate(xxdebug)))
     COMMIT
    ENDIF
   ENDIF
   IF ((orders->type_ind=ot->specimen_order))
    CALL echo(build("Processing ops exception of order for specimen_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->report_order))
    CALL echo(build("Processing ops exception of order for report_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->task_order))
    CALL echo(build("Processing ops exception of order for processing_task_id = ",orders->
      ops_parent_id))
   ELSEIF ((orders->type_ind=ot->specimen_update))
    CALL echo(build("Processing ops exception of update for specimen_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->report_update))
    CALL echo(build("Processing ops exception of update for report_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->task_update))
    CALL echo(build("Processing ops exception of update for processing_task_id = ",orders->
      ops_parent_id))
   ELSE
    CALL echo(build("Unable to locate an order type of ",orders->type_ind,
      " in ap_ops_exception. Can't inactivate..."))
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteopsexception(dummy19)
   IF ((orders->type_ind=ot->specimen_order))
    CALL echo(build("Processing ops exception complete for specimen_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->report_order))
    CALL echo(build("Processing ops exception complete for report_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->task_order))
    CALL echo(build("Processing ops exception complete for processing_task_id = ",orders->
      ops_parent_id))
   ELSEIF ((orders->type_ind=ot->specimen_update))
    CALL echo(build("Processing ops exception complete for specimen_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->report_update))
    CALL echo(build("Processing ops exception complete for report_id = ",orders->ops_parent_id))
   ELSEIF ((orders->type_ind=ot->task_update))
    CALL echo(build("Processing ops exception complete for processing_task_id = ",orders->
      ops_parent_id))
   ELSE
    CALL echo(build("Unable to locate an order type of ",orders->type_ind,
      " in ap_ops_exception. Can't delete..."))
   ENDIF
   DELETE  FROM ap_ops_exception ops
    WHERE (orders->ops_parent_id=ops.parent_id)
     AND (ops.action_flag=orders->type_ind)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    ROLLBACK
    CALL echo(build("Error deleting from ap_ops_exception for parent_id = ",orders->ops_parent_id))
   ELSE
    IF ( NOT (validate(xxdebug)))
     COMMIT
    ENDIF
   ENDIF
 END ;Subroutine
END GO
