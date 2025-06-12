CREATE PROGRAM bed_get_power_plan_orders:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 order_catalogs[*]
      2 id = f8
      2 description = vc
      2 active_ind = i2
      2 synonyms[*]
        3 id = f8
        3 mnemonic = vc
        3 mnemonic_type_display = vc
        3 active_ind = i2
        3 order_type_flag = i4
        3 clinical_cat_cd = f8
        3 clinical_cat_display = vc
        3 clinical_cat_meaning = vc
        3 clinical_cat_seq = i4
        3 oe_format_id = f8
        3 vv_all_facilities_ind = i2
        3 vv_facility[*]
          4 id = f8
          4 display = vc
        3 intermittent_ind = i2
        3 rx_mask = i4
        3 hide_flag = i2
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(temp_orders,0)))
  RECORD temp_orders(
    1 order_catalogs[*]
      2 id = f8
      2 description = vc
      2 active_ind = i2
      2 synonyms[*]
        3 id = f8
        3 mnemonic = vc
        3 mnemonic_type_display = vc
        3 active_ind = i2
        3 order_type_flag = i4
        3 vv_facility[*]
          4 id = f8
          4 display = vc
        3 clinical_cat_cd = f8
        3 clinical_cat_display = vc
        3 clinical_cat_meaning = vc
        3 clinical_cat_seq = i4
        3 oe_format_id = f8
        3 intermittent_ind = i2
        3 rx_mask = i4
        3 hide_flag = i2
  )
 ENDIF
 IF ( NOT (validate(power_plan_facility,0)))
  RECORD power_plan_facility(
    1 power_plan_facility[*]
      2 id = f8
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET max_cnt = 0
 SET max_cnt = request->max_reply
 DECLARE search_string = vc
 SET search_string = "*"
 IF ((request->search_type_flag="S"))
  SET search_string = concat('"',trim(request->search_string),'*"')
 ELSE
  SET search_string = concat('"*',trim(request->search_string),'*"')
 ENDIF
 SET search_string = cnvtupper(search_string)
 DECLARE oc_parse = vc
 SET oc_parse = "oc.catalog_cd > 0"
 DECLARE ocs_parse = vc
 SET ocs_parse = "ocs.catalog_cd = oc.catalog_cd"
 IF ((request->show_inactive_ind=0))
  SET oc_parse = concat(oc_parse," and oc.active_ind = 1")
  SET ocs_parse = concat(ocs_parse," and ocs.active_ind = 1")
 ENDIF
 IF ((request->show_hidden_ind=0))
  SET ocs_parse = concat(ocs_parse," and ocs.hide_flag = 0")
 ENDIF
 IF ((request->search_string > " "))
  SET ocs_parse = concat(ocs_parse," and (cnvtupper(ocs.mnemonic) = ",search_string,")")
 ENDIF
 SET mnemonic_type_size = size(request->mnemonic_types,5)
 IF (mnemonic_type_size > 0)
  SET ocs_parse = concat(ocs_parse," and ocs.mnemonic_type_cd in (")
  FOR (x = 1 TO mnemonic_type_size)
    IF (x=1)
     SET ocs_parse = build(ocs_parse,request->mnemonic_types[x].mnemonic_type_code_value)
    ELSE
     SET ocs_parse = build(ocs_parse,", ",request->mnemonic_types[x].mnemonic_type_code_value)
    ENDIF
  ENDFOR
  SET ocs_parse = concat(ocs_parse,")")
 ENDIF
 IF ((request->oe_format_id > 0))
  SET ocs_parse = build(ocs_parse," and ocs.oe_format_id = ",request->oe_format_id)
 ENDIF
 IF ((request->search_type_ind=0))
  IF ((request->medication_type_ind=0))
   SET oc_parse = build(oc_parse," and oc.orderable_type_flag not in (2,6)")
   IF ((request->catalog_type_code_value > 0))
    SET oc_parse = build(oc_parse," and oc.catalog_type_cd = ",request->catalog_type_code_value)
   ENDIF
   IF ((request->activity_type_code_value > 0))
    SET oc_parse = build(oc_parse," and oc.activity_type_cd = ",request->activity_type_code_value)
   ENDIF
   IF ((request->subactivity_type_code_value > 0))
    SET oc_parse = build(oc_parse," and oc.activity_subtype_cd = ",request->
     subactivity_type_code_value)
   ENDIF
  ELSE
   SET catalog_type_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
   SET activity_type_cd = uar_get_code_by("MEANING",106,"PHARMACY")
   SET oc_parse = build(oc_parse," and oc.catalog_type_cd in (",catalog_type_cd,")")
   SET oc_parse = build(oc_parse," and oc.activity_type_cd in (",activity_type_cd,")")
   IF ((request->medication_type_ind=1))
    SET oc_parse = build(oc_parse," and oc.orderable_type_flag not in (2,3,6,8,9,11,14)")
   ELSEIF ((request->medication_type_ind=2))
    SET oc_parse = build(oc_parse," and oc.orderable_type_flag in (8,11)")
   ENDIF
  ENDIF
 ELSEIF ((request->search_type_ind=1))
  IF ((request->catalog_type_code_value > 0))
   SET oc_parse = build(oc_parse," and oc.catalog_type_cd = ",request->catalog_type_code_value)
  ENDIF
  IF ((request->activity_type_code_value > 0))
   SET oc_parse = build(oc_parse," and oc.activity_type_cd = ",request->activity_type_code_value)
  ENDIF
  IF ((request->subactivity_type_code_value > 0))
   SET oc_parse = build(oc_parse," and oc.activity_subtype_cd = ",request->
    subactivity_type_code_value)
  ENDIF
  SET catalog_type_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
  SET activity_type_cd = uar_get_code_by("MEANING",106,"PHARMACY")
  SET oc_parse = build(oc_parse," and oc.catalog_type_cd not in (",catalog_type_cd,")")
  SET oc_parse = build(oc_parse," and oc.activity_type_cd not in (",activity_type_cd,")")
 ENDIF
 SET order_count = 0
 SET alter_order_count = 0
 SET synonym_count = 0
 SET alter_synonym_count = 0
 SET facility_count = 0
 SET alter_facility_count = 0
 SELECT INTO "NL:"
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ocs_facility_r ocsf,
   code_value cv1,
   code_value cv2,
   code_value cv3
  PLAN (oc
   WHERE parser(oc_parse))
   JOIN (ocs
   WHERE parser(ocs_parse))
   JOIN (cv1
   WHERE cv1.code_value=ocs.mnemonic_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=ocs.dcp_clin_cat_cd
    AND cv2.active_ind=1)
   JOIN (ocsf
   WHERE ocsf.synonym_id=outerjoin(ocs.synonym_id))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(ocsf.facility_cd))
  ORDER BY oc.catalog_cd, ocs.synonym_id
  HEAD REPORT
   stat = alterlist(temp_orders->order_catalogs,50), order_count = 0, alter_order_count = 0
  HEAD oc.catalog_cd
   order_count = (order_count+ 1), alter_order_count = (alter_order_count+ 1)
   IF (alter_order_count > 50)
    stat = alterlist(temp_orders->order_catalogs,(order_count+ 50)), alter_order_count = 1
   ENDIF
   temp_orders->order_catalogs[order_count].id = oc.catalog_cd, temp_orders->order_catalogs[
   order_count].description = oc.description, temp_orders->order_catalogs[order_count].active_ind =
   oc.active_ind,
   stat = alterlist(temp_orders->order_catalogs[order_count].synonyms,10), synonym_count = 0,
   alter_synonym_count = 0
  HEAD ocs.synonym_id
   synonym_count = (synonym_count+ 1), alter_synonym_count = (alter_synonym_count+ 1)
   IF (alter_synonym_count > 10)
    stat = alterlist(temp_orders->order_catalogs[order_count].synonyms,(synonym_count+ 10)),
    alter_synonym_count = 1
   ENDIF
   temp_orders->order_catalogs[order_count].synonyms[synonym_count].id = ocs.synonym_id, temp_orders
   ->order_catalogs[order_count].synonyms[synonym_count].mnemonic = ocs.mnemonic, temp_orders->
   order_catalogs[order_count].synonyms[synonym_count].active_ind = ocs.active_ind,
   temp_orders->order_catalogs[order_count].synonyms[synonym_count].mnemonic_type_display = cv1
   .display, temp_orders->order_catalogs[order_count].synonyms[synonym_count].order_type_flag = ocs
   .orderable_type_flag, temp_orders->order_catalogs[order_count].synonyms[synonym_count].
   oe_format_id = ocs.oe_format_id,
   temp_orders->order_catalogs[order_count].synonyms[synonym_count].intermittent_ind = ocs
   .intermittent_ind, temp_orders->order_catalogs[order_count].synonyms[synonym_count].rx_mask = ocs
   .rx_mask, temp_orders->order_catalogs[order_count].synonyms[synonym_count].hide_flag = ocs
   .hide_flag
   IF (cv2.code_value > 0)
    temp_orders->order_catalogs[order_count].synonyms[synonym_count].clinical_cat_cd = cv2.code_value,
    temp_orders->order_catalogs[order_count].synonyms[synonym_count].clinical_cat_display = cv2
    .display, temp_orders->order_catalogs[order_count].synonyms[synonym_count].clinical_cat_meaning
     = cv2.cdf_meaning,
    temp_orders->order_catalogs[order_count].synonyms[synonym_count].clinical_cat_seq = cv2
    .collation_seq
   ENDIF
   stat = alterlist(temp_orders->order_catalogs[order_count].synonyms[synonym_count].vv_facility,5),
   facility_count = 0, alter_facility_count = 0
  DETAIL
   IF (ocsf.synonym_id > 0
    AND ((ocsf.facility_cd=0) OR (cv3.active_ind=1)) )
    facility_count = (facility_count+ 1), alter_facility_count = (alter_facility_count+ 1)
    IF (alter_facility_count > 5)
     stat = alterlist(temp_orders->order_catalogs[order_count].synonyms[synonym_count].vv_facility,(
      facility_count+ 5)), alter_facility_count = 1
    ENDIF
    temp_orders->order_catalogs[order_count].synonyms[synonym_count].vv_facility[facility_count].id
     = ocsf.facility_cd, temp_orders->order_catalogs[order_count].synonyms[synonym_count].
    vv_facility[facility_count].display = cv3.display
   ENDIF
  FOOT  ocs.synonym_id
   stat = alterlist(temp_orders->order_catalogs[order_count].synonyms[synonym_count].vv_facility,
    facility_count)
  FOOT  oc.catalog_cd
   stat = alterlist(temp_orders->order_catalogs[order_count].synonyms,synonym_count)
  FOOT REPORT
   stat = alterlist(temp_orders->order_catalogs,order_count)
  WITH nocounter
 ;end select
 IF ((request->virtual_view_ind=0))
  CALL handlenovirtualview(1)
 ELSE
  SET facility_count = 0
  SET alter_facility_count = 0
  IF (validate(request->power_plans))
   SET pp_size = size(request->power_plans,5)
   IF (pp_size=0)
    CALL handlenovirtualview(1)
    GO TO exit_script
   ENDIF
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(pp_size)),
     pw_cat_flex p
    PLAN (d)
     JOIN (p
     WHERE (p.pathway_catalog_id=request->power_plans[d.seq].pp_id)
      AND p.parent_entity_name="CODE_VALUE")
    ORDER BY p.parent_entity_id
    HEAD REPORT
     stat = alterlist(power_plan_facility->power_plan_facility,10), facility_count = 0,
     alter_facility_count = 0
    HEAD p.parent_entity_id
     facility_count = (facility_count+ 1), alter_facility_count = (alter_facility_count+ 1)
     IF (alter_facility_count > 10)
      stat = alterlist(power_plan_facility->power_plan_facility,(facility_count+ 10)),
      alter_facility_count = 1
     ENDIF
     power_plan_facility->power_plan_facility[facility_count].id = p.parent_entity_id
    FOOT REPORT
     stat = alterlist(power_plan_facility->power_plan_facility,facility_count)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM pw_cat_flex p
    WHERE (p.pathway_catalog_id=request->power_plan_id)
     AND p.parent_entity_name="CODE_VALUE"
    HEAD REPORT
     stat = alterlist(power_plan_facility->power_plan_facility,10), facility_count = 0,
     alter_facility_count = 0
    DETAIL
     facility_count = (facility_count+ 1), alter_facility_count = (alter_facility_count+ 1)
     IF (alter_facility_count > 10)
      stat = alterlist(power_plan_facility->power_plan_facility,(facility_count+ 10)),
      alter_facility_count = 1
     ENDIF
     power_plan_facility->power_plan_facility[facility_count].id = p.parent_entity_id
    FOOT REPORT
     stat = alterlist(power_plan_facility->power_plan_facility,facility_count)
    WITH nocounter
   ;end select
  ENDIF
  IF (facility_count=0)
   CALL handlenovirtualview(1)
   GO TO exit_script
  ENDIF
  SET synonyms_added = 0
  IF ((request->virtual_view_ind=1))
   IF (size(power_plan_facility->power_plan_facility,5)=1)
    IF ((power_plan_facility->power_plan_facility[1].id=0))
     SET order_count = size(temp_orders->order_catalogs,5)
     FOR (x = 1 TO order_count)
      SET synonym_count = size(temp_orders->order_catalogs[x].synonyms,5)
      FOR (y = 1 TO synonym_count)
        SET vv_facility_count = size(temp_orders->order_catalogs[x].synonyms[y].vv_facility,5)
        SET fac_num = 0
        SET fac_start = 0
        SET fac_found = 0
        SET fac_found = locateval(fac_num,fac_start,vv_facility_count,0.0,temp_orders->
         order_catalogs[x].synonyms[y].vv_facility[fac_num].id)
        IF (fac_found > 0)
         CALL addsynonymtoreply(x,y)
         SET synonyms_added = (synonyms_added+ 1)
        ENDIF
      ENDFOR
     ENDFOR
     GO TO exit_script
    ENDIF
   ENDIF
   SET order_count = size(temp_orders->order_catalogs,5)
   FOR (x = 1 TO order_count)
    SET synonym_count = size(temp_orders->order_catalogs[x].synonyms,5)
    FOR (y = 1 TO synonym_count)
      SET vv_facility_count = size(temp_orders->order_catalogs[x].synonyms[y].vv_facility,5)
      SET fac_num = 0
      SET fac_start = 0
      SET fac_found = 0
      SET vv_plan_count = size(power_plan_facility->power_plan_facility,5)
      SET found = locateval(fac_num,fac_start,vv_facility_count,0.0,temp_orders->order_catalogs[x].
       synonyms[y].vv_facility[fac_num].id)
      IF (found > 0)
       SET fac_found = 0
       SET vv_plan_count = 0
      ENDIF
      FOR (z = 1 TO vv_plan_count)
       SET found = locateval(fac_num,fac_start,vv_facility_count,power_plan_facility->
        power_plan_facility[z].id,temp_orders->order_catalogs[x].synonyms[y].vv_facility[fac_num].id)
       IF (found=0)
        SET z = vv_plan_count
       ELSE
        SET fac_found = (fac_found+ 1)
       ENDIF
      ENDFOR
      IF (fac_found=vv_plan_count)
       CALL addsynonymtoreply(x,y)
       SET synonyms_added = (synonyms_added+ 1)
      ENDIF
    ENDFOR
   ENDFOR
  ELSEIF ((request->virtual_view_ind=2))
   IF (size(power_plan_facility->power_plan_facility,5)=1)
    IF ((power_plan_facility->power_plan_facility[1].id=0))
     SET order_count = size(temp_orders->order_catalogs,5)
     FOR (x = 1 TO order_count)
      SET synonym_count = size(temp_orders->order_catalogs[x].synonyms,5)
      FOR (y = 1 TO synonym_count)
       SET vv_facility_count = size(temp_orders->order_catalogs[x].synonyms[y].vv_facility,5)
       IF (vv_facility_count > 0)
        CALL addsynonymtoreply(x,y)
        SET synonyms_added = (synonyms_added+ 1)
       ENDIF
      ENDFOR
     ENDFOR
     GO TO exit_script
    ENDIF
   ENDIF
   SET order_count = size(temp_orders->order_catalogs,5)
   FOR (x = 1 TO order_count)
    SET synonym_count = size(temp_orders->order_catalogs[x].synonyms,5)
    FOR (y = 1 TO synonym_count)
      SET vv_facility_count = size(temp_orders->order_catalogs[x].synonyms[y].vv_facility,5)
      SET fac_num = 0
      SET fac_start = 0
      SET fac_found = 0
      SET found = locateval(fac_num,fac_start,vv_facility_count,0.0,temp_orders->order_catalogs[x].
       synonyms[y].vv_facility[fac_num].id)
      IF (found > 0)
       SET fac_found = (fac_found+ 1)
      ELSE
       SET vv_plan_count = size(power_plan_facility->power_plan_facility,5)
       FOR (z = 1 TO vv_plan_count)
         SET found = 0
         SET found = locateval(fac_num,fac_start,vv_facility_count,power_plan_facility->
          power_plan_facility[z].id,temp_orders->order_catalogs[x].synonyms[y].vv_facility[fac_num].
          id)
         IF (found > 0)
          SET fac_found = (fac_found+ 1)
          SET z = vv_plan_count
         ENDIF
       ENDFOR
      ENDIF
      IF (fac_found > 0)
       CALL addsynonymtoreply(x,y)
       SET synonyms_added = (synonyms_added+ 1)
      ENDIF
    ENDFOR
   ENDFOR
  ENDIF
  IF ((synonyms_added > request->max_reply))
   SET stat = alterlist(reply->order_catalogs,0)
   SET reply->too_many_results_ind = 1
   GO TO exit_script
  ELSE
   SET reply->too_many_results_ind = 0
  ENDIF
 ENDIF
 SUBROUTINE handlenovirtualview(dummyv)
   SET total_count = 0
   SET order_count = size(temp_orders->order_catalogs,5)
   SET stat = alterlist(reply->order_catalogs,order_count)
   FOR (x = 1 TO order_count)
     SET reply->order_catalogs[x].id = temp_orders->order_catalogs[x].id
     SET reply->order_catalogs[x].description = temp_orders->order_catalogs[x].description
     SET reply->order_catalogs[x].active_ind = temp_orders->order_catalogs[x].active_ind
     SET synonym_count = size(temp_orders->order_catalogs[x].synonyms,5)
     SET total_count = (total_count+ synonym_count)
     SET stat = alterlist(reply->order_catalogs[x].synonyms,synonym_count)
     FOR (y = 1 TO synonym_count)
       SET reply->order_catalogs[x].synonyms[y].id = temp_orders->order_catalogs[x].synonyms[y].id
       SET reply->order_catalogs[x].synonyms[y].mnemonic = temp_orders->order_catalogs[x].synonyms[y]
       .mnemonic
       SET reply->order_catalogs[x].synonyms[y].mnemonic_type_display = temp_orders->order_catalogs[x
       ].synonyms[y].mnemonic_type_display
       SET reply->order_catalogs[x].synonyms[y].active_ind = temp_orders->order_catalogs[x].synonyms[
       y].active_ind
       SET reply->order_catalogs[x].synonyms[y].order_type_flag = temp_orders->order_catalogs[x].
       synonyms[y].order_type_flag
       SET reply->order_catalogs[x].synonyms[y].clinical_cat_cd = temp_orders->order_catalogs[x].
       synonyms[y].clinical_cat_cd
       SET reply->order_catalogs[x].synonyms[y].clinical_cat_display = temp_orders->order_catalogs[x]
       .synonyms[y].clinical_cat_display
       SET reply->order_catalogs[x].synonyms[y].clinical_cat_meaning = temp_orders->order_catalogs[x]
       .synonyms[y].clinical_cat_meaning
       SET reply->order_catalogs[x].synonyms[y].clinical_cat_seq = temp_orders->order_catalogs[x].
       synonyms[y].clinical_cat_seq
       SET reply->order_catalogs[x].synonyms[y].oe_format_id = temp_orders->order_catalogs[x].
       synonyms[y].oe_format_id
       SET reply->order_catalogs[x].synonyms[y].rx_mask = temp_orders->order_catalogs[x].synonyms[y].
       rx_mask
       SET reply->order_catalogs[x].synonyms[y].intermittent_ind = temp_orders->order_catalogs[x].
       synonyms[y].intermittent_ind
       SET reply->order_catalogs[x].synonyms[y].hide_flag = temp_orders->order_catalogs[x].synonyms[y
       ].hide_flag
       SET vv_count = size(temp_orders->order_catalogs[x].synonyms[y].vv_facility,5)
       SET stat = alterlist(reply->order_catalogs[x].synonyms[y].vv_facility,vv_count)
       FOR (z = 1 TO vv_count)
         SET reply->order_catalogs[x].synonyms[y].vv_facility[z].id = temp_orders->order_catalogs[x].
         synonyms[y].vv_facility[z].id
         SET reply->order_catalogs[x].synonyms[y].vv_facility[z].display = temp_orders->
         order_catalogs[x].synonyms[y].vv_facility[z].display
         IF ((reply->order_catalogs[x].synonyms[y].vv_facility[z].id=0.0))
          SET reply->order_catalogs[x].synonyms[y].vv_all_facilities_ind = 1
         ENDIF
       ENDFOR
     ENDFOR
     IF ((total_count > request->max_reply))
      SET stat = alterlist(reply->order_catalogs,0)
      SET reply->too_many_results_ind = 1
      GO TO exit_script
     ELSE
      SET reply->too_many_results_ind = 0
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE addsynonymtoreply(oc_index,syn_index)
   SET o_count = size(reply->order_catalogs,5)
   SET o_num = 0
   SET o_start = 0
   SET o_found = locateval(o_num,o_start,o_count,temp_orders->order_catalogs[oc_index].id,reply->
    order_catalogs[o_num].id)
   IF (o_found=0)
    SET o_count = (o_count+ 1)
    SET stat = alterlist(reply->order_catalogs,o_count)
    SET reply->order_catalogs[o_count].id = temp_orders->order_catalogs[oc_index].id
    SET reply->order_catalogs[o_count].description = temp_orders->order_catalogs[oc_index].
    description
    SET reply->order_catalogs[o_count].active_ind = temp_orders->order_catalogs[oc_index].active_ind
    SET o_found = o_count
   ENDIF
   SET s_count = size(reply->order_catalogs[o_found].synonyms,5)
   SET s_index = (s_count+ 1)
   SET stat = alterlist(reply->order_catalogs[o_found].synonyms,s_index)
   SET reply->order_catalogs[o_found].synonyms[s_index].id = temp_orders->order_catalogs[oc_index].
   synonyms[syn_index].id
   SET reply->order_catalogs[o_found].synonyms[s_index].mnemonic = temp_orders->order_catalogs[
   oc_index].synonyms[syn_index].mnemonic
   SET reply->order_catalogs[o_found].synonyms[s_index].active_ind = temp_orders->order_catalogs[
   oc_index].synonyms[syn_index].active_ind
   SET reply->order_catalogs[o_found].synonyms[s_index].mnemonic_type_display = temp_orders->
   order_catalogs[oc_index].synonyms[syn_index].mnemonic_type_display
   SET reply->order_catalogs[o_found].synonyms[s_index].order_type_flag = temp_orders->
   order_catalogs[oc_index].synonyms[syn_index].order_type_flag
   SET reply->order_catalogs[o_found].synonyms[s_index].clinical_cat_cd = temp_orders->
   order_catalogs[oc_index].synonyms[syn_index].clinical_cat_cd
   SET reply->order_catalogs[o_found].synonyms[s_index].clinical_cat_display = temp_orders->
   order_catalogs[oc_index].synonyms[syn_index].clinical_cat_display
   SET reply->order_catalogs[o_found].synonyms[s_index].clinical_cat_meaning = temp_orders->
   order_catalogs[oc_index].synonyms[syn_index].clinical_cat_meaning
   SET reply->order_catalogs[o_found].synonyms[s_index].clinical_cat_seq = temp_orders->
   order_catalogs[oc_index].synonyms[syn_index].clinical_cat_seq
   SET reply->order_catalogs[o_found].synonyms[s_index].oe_format_id = temp_orders->order_catalogs[
   oc_index].synonyms[syn_index].oe_format_id
   SET reply->order_catalogs[o_found].synonyms[s_index].intermittent_ind = temp_orders->
   order_catalogs[oc_index].synonyms[syn_index].intermittent_ind
   SET reply->order_catalogs[o_found].synonyms[s_index].rx_mask = temp_orders->order_catalogs[
   oc_index].synonyms[syn_index].rx_mask
   SET reply->order_catalogs[o_found].synonyms[s_index].hide_flag = temp_orders->order_catalogs[
   oc_index].synonyms[syn_index].hide_flag
   SET vv_count = size(temp_orders->order_catalogs[oc_index].synonyms[syn_index].vv_facility,5)
   SET stat = alterlist(reply->order_catalogs[o_found].synonyms[s_index].vv_facility,vv_count)
   FOR (vv_counter = 1 TO vv_count)
     SET reply->order_catalogs[o_found].synonyms[s_index].vv_facility[vv_counter].id = temp_orders->
     order_catalogs[oc_index].synonyms[syn_index].vv_facility[vv_counter].id
     SET reply->order_catalogs[o_found].synonyms[s_index].vv_facility[vv_counter].display =
     temp_orders->order_catalogs[oc_index].synonyms[syn_index].vv_facility[vv_counter].display
     IF ((reply->order_catalogs[o_found].synonyms[s_index].vv_facility[vv_counter].id=0.0))
      SET reply->order_catalogs[o_found].synonyms[s_index].vv_all_facilities_ind = 1
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
