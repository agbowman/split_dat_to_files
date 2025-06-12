CREATE PROGRAM bed_get_pharm_items:dba
 FREE SET reply
 RECORD reply(
   1 items[*]
     2 item_id = f8
     2 description = vc
     2 all_facility_ind = i2
     2 mult_domain_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_items
 RECORD temp_items(
   1 items[*]
     2 item_id = f8
     2 qual_num = i4
     2 all_fac_ind = i2
     2 mult_domain_ind = i2
     2 logical_domain_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE search_string = vc
 DECLARE med_dispense_parse = vc
 DECLARE med_oe_defaults_parse = vc
 DECLARE order_cat_parse = vc
 DECLARE dose_search_string = vc
 IF ((request->strength_s_ind=1))
  SET med_dispense_parse = concat("mdisp.strength = ",trim(build(request->strength))," and ")
 ENDIF
 IF ((request->strength_unit_s_ind=1))
  SET med_dispense_parse = build(med_dispense_parse," mdisp.strength_unit_cd = ",request->
   strength_unit_code_value," and ")
 ENDIF
 IF ((request->volume_s_ind=1))
  SET med_dispense_parse = concat(med_dispense_parse," mdisp.volume = ",trim(build(request->volume)),
   " and ")
 ENDIF
 IF ((request->volume_unit_s_ind=1))
  SET med_dispense_parse = build(med_dispense_parse," mdisp.volume_unit_cd = ",request->
   volume_unit_code_value," and ")
 ENDIF
 IF ((request->medication_s_ind=1))
  SET med_dispense_parse = concat(med_dispense_parse," mdisp.med_filter_ind = ",trim(cnvtstring(
     request->medication_ind))," and ")
 ENDIF
 IF ((request->continuous_s_ind=1))
  SET med_dispense_parse = concat(med_dispense_parse," mdisp.continuous_filter_ind = ",trim(
    cnvtstring(request->continuous_ind))," and ")
 ENDIF
 IF ((request->tpn_ind_s_ind=1))
  SET med_dispense_parse = concat(med_dispense_parse," mdisp.tpn_filter_ind = ",trim(cnvtstring(
     request->tpn_ind))," and ")
 ENDIF
 IF ((request->intermittent_ind_s_ind=1))
  SET med_dispense_parse = concat(med_dispense_parse," mdisp.intermittent_filter_ind = ",trim(
    cnvtstring(request->intermittent_ind))," and ")
 ENDIF
 IF ((request->legal_status_s_ind=1))
  SET med_dispense_parse = build(med_dispense_parse," mdisp.legal_status_cd = ",request->
   legal_status_code_value," and ")
 ENDIF
 IF ((request->formulary_status_s_ind=1))
  SET med_dispense_parse = build(med_dispense_parse," mdisp.formulary_status_cd = ",request->
   formulary_status_code_value," and ")
 ENDIF
 IF ((request->divisibility_ind_s_ind=1))
  SET med_dispense_parse = concat(med_dispense_parse," mdisp.divisible_ind = ",trim(cnvtstring(
     request->divisibility_ind))," and ")
 ENDIF
 IF ((request->infinitely_divisible_ind_s_ind=1))
  SET med_dispense_parse = concat(med_dispense_parse," mdisp.infinite_div_ind = ",trim(cnvtstring(
     request->infinitely_divisible_ind))," and ")
 ENDIF
 IF ((request->divisible_factor_s_ind=1))
  SET med_dispense_parse = concat(med_dispense_parse," mdisp.base_issue_factor = ",trim(build(request
     ->divisible_factor))," and ")
 ENDIF
 IF ((request->total_volume_flag_s_ind=1))
  SET med_dispense_parse = concat(med_dispense_parse," mdisp.used_as_base_ind = ",trim(cnvtstring(
     request->total_volume_flag))," and ")
 ENDIF
 IF ((request->freetext_dose_s_ind=1))
  SET med_oe_defaults_parse = concat(med_oe_defaults_parse," oe.freetext_dose = '",trim(cnvtupper(
     cnvtalphanum(request->freetext_dose))),"'"," and ")
 ENDIF
 IF ((request->dose_unit_s_ind=1)
  AND (request->dose_s_ind=1))
  SET med_oe_defaults_parse = build(med_oe_defaults_parse," (((oe.strength_unit_cd = ",request->
   dose_unit_code_value," and oe.strength = ",request->dose,
   " ) or ( oe.volume_unit_cd = ",request->dose_unit_code_value," and oe.volume = ",request->dose,
   " )) ")
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.code_value=request->dose_unit_code_value)
   DETAIL
    dose_search_string = concat(trim(build(request->dose))," ",cv.display)
   WITH nocounter
  ;end select
  SET med_oe_defaults_parse = concat(med_oe_defaults_parse," or ( oe.freetext_dose = '",
   dose_search_string,"'))"," and ")
 ELSEIF ((request->dose_unit_s_ind=1)
  AND (request->dose_s_ind=0))
  SET med_oe_defaults_parse = build(med_oe_defaults_parse," ((oe.strength_unit_cd = ",request->
   dose_unit_code_value," or oe.volume_unit_cd = ",request->dose_unit_code_value,
   " ) ")
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.code_value=request->dose_unit_code_value)
   DETAIL
    dose_search_string = cv.display
   WITH nocounter
  ;end select
  SET med_oe_defaults_parse = concat(med_oe_defaults_parse," or ( oe.freetext_dose = '",
   dose_search_string,"'))"," and ")
 ELSEIF ((request->dose_unit_s_ind=0)
  AND (request->dose_s_ind=1))
  SET med_oe_defaults_parse = concat(med_oe_defaults_parse," ((oe.strength = ",trim(build(request->
     dose))," or oe.volume = ",trim(build(request->dose)),
   " ) ")
  SET dose_search_string = trim(cnvtstring(request->dose))
  SET med_oe_defaults_parse = concat(med_oe_defaults_parse," or ( oe.freetext_dose = '",
   dose_search_string,"'))"," and ")
 ENDIF
 IF ((request->duration_s_ind=1))
  SET med_oe_defaults_parse = concat(med_oe_defaults_parse," oe.duration = ",trim(build(request->
     duration))," and ")
 ENDIF
 IF ((request->duration_unit_s_ind=1))
  SET med_oe_defaults_parse = build(med_oe_defaults_parse," oe.duration_unit_cd = ",request->
   duration_unit_code_value," and ")
 ENDIF
 IF ((request->stop_type_s_ind=1))
  SET med_oe_defaults_parse = build(med_oe_defaults_parse," oe.stop_type_cd = ",request->
   stop_type_code_value," and ")
 ENDIF
 IF ((request->route_s_ind=1))
  SET med_oe_defaults_parse = build(med_oe_defaults_parse," oe.route_cd = ",request->route_code_value,
   " and ")
 ENDIF
 IF ((request->frequency_s_ind=1))
  SET med_oe_defaults_parse = build(med_oe_defaults_parse," oe.frequency_cd = ",request->
   frequency_code_value," and ")
 ENDIF
 IF ((request->infuse_over_s_ind=1))
  SET med_oe_defaults_parse = concat(med_oe_defaults_parse," oe.infuse_over = ",trim(build(request->
     infuse_over))," and ")
 ENDIF
 IF ((request->infuse_over_unit_s_ind=1))
  SET med_oe_defaults_parse = build(med_oe_defaults_parse," oe.infuse_over_cd = ",request->
   infuse_over_unit_code_value," and ")
 ENDIF
 IF ((request->prn_ind_s_ind=1))
  SET med_oe_defaults_parse = concat(med_oe_defaults_parse," oe.prn_ind = ",trim(cnvtstring(request->
     prn_ind))," and ")
 ENDIF
 IF ((request->prn_reason_s_ind=1))
  SET med_oe_defaults_parse = build(med_oe_defaults_parse," oe.prn_reason_cd = ",request->
   prn_reason_code_value," and ")
 ENDIF
 IF ((request->dispense_cat_s_ind=1))
  SET med_oe_defaults_parse = build(med_oe_defaults_parse," oe.dispense_category_cd = ",request->
   dispense_cat_code_value," and ")
 ENDIF
 IF ((request->price_sched_id_s_ind=1))
  SET med_oe_defaults_parse = build(med_oe_defaults_parse," oe.price_sched_id = ",request->
   price_sched_id," and ")
 ENDIF
 IF ((request->order_type_s_ind=1))
  DECLARE ord_type_meaning = vc
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.code_value=request->order_type_code_value)
   DETAIL
    ord_type_meaning = cv.cdf_meaning
   WITH nocounter
  ;end select
  SET med_dispense_parse = concat(med_dispense_parse," mdisp.oe_format_flag = ",ord_type_meaning,
   " and ")
 ENDIF
 IF ((request->dc_interaction_s_ind=1))
  SET order_cat_parse = concat(order_cat_parse,"oc.dc_interaction_days = ",trim(build(request->
     dc_interaction))," and ")
 ENDIF
 IF ((request->dc_display_s_ind=1))
  SET order_cat_parse = concat(order_cat_parse," oc.dc_display_days = ",trim(build(request->
     dc_display))," and ")
 ENDIF
 SET sys_pkg_code_value = 0.0
 SET system_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4062
   AND cv.cdf_meaning IN ("SYSPKGTYP", "SYSTEM")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="SYSPKGTYP")
    sys_pkg_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="SYSTEM")
    system_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET inpatient_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4500
   AND cv.cdf_meaning="INPATIENT"
   AND cv.active_ind=1
  DETAIL
   inpatient_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET desc_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=11000
   AND cv.cdf_meaning="DESC"
   AND cv.active_ind=1
  DETAIL
   desc_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET tot_qual_num = 0
 IF ((request->item_description_s_ind=1))
  DECLARE item_description_parse = vc
  IF (cnvtupper(request->item_desc_search_type_flag)="S")
   SET search_string = concat('"',trim(cnvtupper(cnvtalphanum(request->item_description))),'*"')
  ELSEIF (cnvtupper(request->item_desc_search_type_flag)="C")
   SET search_string = concat('"*',trim(cnvtupper(cnvtalphanum(request->item_description))),'*"')
  ENDIF
  SET item_description_parse = concat("mi.value_key = ",search_string)
  SET tot_qual_num = (tot_qual_num+ 1)
  SELECT INTO "nl:"
   FROM medication_definition md,
    med_identifier mi
   PLAN (md
    WHERE md.med_type_flag=0
     AND md.item_id > 0)
    JOIN (mi
    WHERE mi.item_id=md.item_id
     AND mi.pharmacy_type_cd=inpatient_code_value
     AND parser(item_description_parse)
     AND mi.med_identifier_type_cd=desc_code_value
     AND ((mi.flex_type_cd+ 0)=system_code_value)
     AND mi.primary_ind=1
     AND ((mi.med_product_id+ 0)=0)
     AND ((mi.active_ind+ 0)=1))
   ORDER BY md.item_id
   HEAD REPORT
    cnt = 0, lcnt = 0, stat = alterlist(temp_items->items,100)
   HEAD md.item_id
    cnt = (cnt+ 1), lcnt = (lcnt+ 1)
    IF (lcnt > 100)
     stat = alterlist(temp_items->items,(cnt+ 100)), lcnt = 1
    ENDIF
    temp_items->items[cnt].item_id = md.item_id, temp_items->items[cnt].qual_num = tot_qual_num
   FOOT REPORT
    stat = alterlist(temp_items->items,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->dosage_form_s_ind=1))
  IF (tot_qual_num > 0)
   IF (size(temp_items->items,5) <= 0)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM medication_definition md,
     (dummyt d  WITH seq = size(temp_items->items,5))
    PLAN (d
     WHERE (temp_items->items[d.seq].qual_num=tot_qual_num))
     JOIN (md
     WHERE (md.item_id=temp_items->items[d.seq].item_id)
      AND (md.form_cd=request->dosage_form_code_value))
    ORDER BY d.seq
    DETAIL
     temp_items->items[d.seq].qual_num = (tot_qual_num+ 1)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ELSE
   SELECT INTO "nl:"
    FROM medication_definition md
    PLAN (md
     WHERE md.med_type_flag=0
      AND (md.form_cd=request->dosage_form_code_value)
      AND md.item_id > 0)
    ORDER BY md.item_id
    HEAD REPORT
     cnt = 0, lcnt = 0, stat = alterlist(temp_items->items,100)
    HEAD md.item_id
     cnt = (cnt+ 1), lcnt = (lcnt+ 1)
     IF (lcnt > 100)
      stat = alterlist(temp_items->items,(cnt+ 100)), lcnt = 1
     ENDIF
     temp_items->items[cnt].item_id = md.item_id, temp_items->items[cnt].qual_num = (tot_qual_num+ 1)
    FOOT REPORT
     stat = alterlist(temp_items->items,cnt)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ENDIF
 ENDIF
 SET brand_code_value = 0.0
 SET ndc_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=11000
   AND cv.cdf_meaning IN ("BRAND_NAME", "NDC")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="BRAND_NAME")
    brand_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="NDC")
    ndc_code_value
   ENDIF
  WITH nocounter
 ;end select
 SET len = size(request->identifiers,5)
 FOR (z = 1 TO len)
   DECLARE item_ident_parse = vc
   IF (cnvtupper(request->identifiers_search_type_flag)="S")
    SET search_string = concat('"',trim(cnvtupper(cnvtalphanum(request->identifiers[z].value))),'*"')
   ELSEIF (cnvtupper(request->identifiers_search_type_flag)="C")
    SET search_string = concat('"*',trim(cnvtupper(cnvtalphanum(request->identifiers[z].value))),'*"'
     )
   ENDIF
   SET item_ident_parse = concat("mi.value_key =  ",search_string)
   IF (tot_qual_num > 0)
    IF (size(temp_items->items,5) <= 0)
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     FROM med_identifier mi,
      (dummyt d  WITH seq = size(temp_items->items,5))
     PLAN (d
      WHERE (temp_items->items[d.seq].qual_num=tot_qual_num))
      JOIN (mi
      WHERE (mi.item_id=temp_items->items[d.seq].item_id)
       AND mi.pharmacy_type_cd=inpatient_code_value
       AND parser(item_ident_parse)
       AND (mi.med_identifier_type_cd=request->identifiers[z].identifier_type_code_value)
       AND ((mi.flex_type_cd+ 0) IN (system_code_value, sys_pkg_code_value))
       AND ((mi.med_product_id > 0
       AND mi.med_identifier_type_cd IN (ndc_code_value, brand_code_value)) OR (mi.med_product_id=0
      ))
       AND ((mi.active_ind+ 0)=1))
     ORDER BY d.seq
     DETAIL
      temp_items->items[d.seq].qual_num = (tot_qual_num+ 1)
     WITH nocounter
    ;end select
    SET tot_qual_num = (tot_qual_num+ 1)
   ELSE
    SELECT INTO "nl:"
     FROM medication_definition md,
      med_identifier mi
     PLAN (md
      WHERE md.med_type_flag=0
       AND md.item_id > 0)
      JOIN (mi
      WHERE mi.item_id=md.item_id
       AND mi.pharmacy_type_cd=inpatient_code_value
       AND parser(item_ident_parse)
       AND (mi.med_identifier_type_cd=request->identifiers[z].identifier_type_code_value)
       AND ((mi.flex_type_cd+ 0) IN (system_code_value, sys_pkg_code_value))
       AND ((mi.med_product_id > 0
       AND mi.med_identifier_type_cd IN (ndc_code_value, brand_code_value)) OR (mi.med_product_id=0
      ))
       AND ((mi.active_ind+ 0)=1))
     ORDER BY md.item_id
     HEAD REPORT
      cnt = 0, lcnt = 0, stat = alterlist(temp_items->items,100)
     HEAD md.item_id
      cnt = (cnt+ 1), lcnt = (lcnt+ 1)
      IF (lcnt > 100)
       stat = alterlist(temp_items->items,(cnt+ 100)), lcnt = 1
      ENDIF
      temp_items->items[cnt].item_id = md.item_id, temp_items->items[cnt].qual_num = (tot_qual_num+ 1
      )
     FOOT REPORT
      stat = alterlist(temp_items->items,cnt)
     WITH nocounter
    ;end select
    SET tot_qual_num = (tot_qual_num+ 1)
   ENDIF
 ENDFOR
 IF ((request->location_s_ind=1))
  SET orderable_code_value = 0.0
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=4063
    AND cv.cdf_meaning="ORDERABLE"
    AND cv.active_ind=1
   DETAIL
    orderable_code_value = cv.code_value
   WITH nocounter
  ;end select
  IF (tot_qual_num > 0)
   IF (size(temp_items->items,5) <= 0)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi,
     (dummyt d  WITH seq = size(temp_items->items,5))
    PLAN (d
     WHERE (temp_items->items[d.seq].qual_num=tot_qual_num))
     JOIN (mdf
     WHERE (mdf.item_id=temp_items->items[d.seq].item_id)
      AND mdf.flex_type_cd=sys_pkg_code_value
      AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
      AND ((mdf.sequence+ 0)=0)
      AND ((mdf.med_def_flex_id+ 0) != 0)
      AND ((mdf.active_ind+ 0)=1))
     JOIN (mfoi
     WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
      AND mfoi.flex_object_type_cd=orderable_code_value
      AND ((mfoi.sequence+ 0)=0)
      AND ((mfoi.active_ind+ 0)=1)
      AND ((mfoi.parent_entity_id+ 0)=request->location_code_value))
    ORDER BY d.seq
    DETAIL
     temp_items->items[d.seq].qual_num = (tot_qual_num+ 1)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ELSE
   SELECT INTO "nl:"
    FROM medication_definition md,
     med_def_flex mdf,
     med_flex_object_idx mfoi
    PLAN (md
     WHERE md.med_type_flag=0
      AND md.item_id > 0)
     JOIN (mdf
     WHERE (mdf.item_id=(md.item_id+ 0))
      AND mdf.flex_type_cd=sys_pkg_code_value
      AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
      AND ((mdf.sequence+ 0)=0)
      AND ((mdf.med_def_flex_id+ 0) != 0)
      AND ((mdf.active_ind+ 0)=1))
     JOIN (mfoi
     WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
      AND mfoi.flex_object_type_cd=orderable_code_value
      AND ((mfoi.sequence+ 0)=0)
      AND ((mfoi.active_ind+ 0)=1)
      AND ((mfoi.parent_entity_id+ 0)=request->location_code_value))
    ORDER BY md.item_id
    HEAD REPORT
     cnt = 0, lcnt = 0, stat = alterlist(temp_items->items,100)
    HEAD md.item_id
     cnt = (cnt+ 1), lcnt = (lcnt+ 1)
     IF (lcnt > 100)
      stat = alterlist(temp_items->items,(cnt+ 100)), lcnt = 1
     ENDIF
     temp_items->items[cnt].item_id = md.item_id, temp_items->items[cnt].qual_num = (tot_qual_num+ 1)
    FOOT REPORT
     stat = alterlist(temp_items->items,cnt)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ENDIF
 ENDIF
 IF ((request->order_alert_id_s_ind=1))
  SET ord_alert_code_value = 0.0
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=4063
    AND cv.cdf_meaning="ORDERALERT"
    AND cv.active_ind=1
   DETAIL
    ord_alert_code_value = cv.code_value
   WITH nocounter
  ;end select
  IF (tot_qual_num > 0)
   IF (size(temp_items->items,5) <= 0)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi,
     (dummyt d  WITH seq = size(temp_items->items,5))
    PLAN (d
     WHERE (temp_items->items[d.seq].qual_num=tot_qual_num))
     JOIN (mdf
     WHERE (mdf.item_id=temp_items->items[d.seq].item_id)
      AND mdf.flex_type_cd=system_code_value
      AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
      AND ((mdf.sequence+ 0)=0)
      AND ((mdf.med_def_flex_id+ 0) != 0)
      AND ((mdf.active_ind+ 0)=1))
     JOIN (mfoi
     WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
      AND mfoi.flex_object_type_cd=ord_alert_code_value
      AND ((mfoi.sequence+ 0)=0)
      AND ((mfoi.active_ind+ 0)=1)
      AND ((mfoi.parent_entity_id+ 0)=request->order_alert_id))
    ORDER BY d.seq
    DETAIL
     temp_items->items[d.seq].qual_num = (tot_qual_num+ 1)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ELSE
   SELECT INTO "nl:"
    FROM medication_definition md,
     med_def_flex mdf,
     med_flex_object_idx mfoi
    PLAN (md
     WHERE md.med_type_flag=0
      AND md.item_id > 0)
     JOIN (mdf
     WHERE (mdf.item_id=(md.item_id+ 0))
      AND mdf.flex_type_cd=system_code_value
      AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
      AND ((mdf.sequence+ 0)=0)
      AND ((mdf.med_def_flex_id+ 0) != 0)
      AND ((mdf.active_ind+ 0)=1))
     JOIN (mfoi
     WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
      AND mfoi.flex_object_type_cd=ord_alert_code_value
      AND ((mfoi.sequence+ 0)=0)
      AND ((mfoi.active_ind+ 0)=1)
      AND ((mfoi.parent_entity_id+ 0)=request->order_alert_id))
    ORDER BY md.item_id
    HEAD REPORT
     cnt = 0, lcnt = 0, stat = alterlist(temp_items->items,100)
    HEAD md.item_id
     cnt = (cnt+ 1), lcnt = (lcnt+ 1)
     IF (lcnt > 100)
      stat = alterlist(temp_items->items,(cnt+ 100)), lcnt = 1
     ENDIF
     temp_items->items[cnt].item_id = md.item_id, temp_items->items[cnt].qual_num = (tot_qual_num+ 1)
    FOOT REPORT
     stat = alterlist(temp_items->items,cnt)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ENDIF
 ENDIF
 IF (order_cat_parse > " ")
  SET order_cat_parse = concat(order_cat_parse," oc.active_ind = 1 ")
  IF (tot_qual_num > 0)
   IF (size(temp_items->items,5) <= 0)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM order_catalog oc,
     order_catalog_item_r oci,
     order_catalog_synonym ocs,
     (dummyt d  WITH seq = size(temp_items->items,5))
    PLAN (d
     WHERE (temp_items->items[d.seq].qual_num=tot_qual_num))
     JOIN (oci
     WHERE (oci.item_id=temp_items->items[d.seq].item_id))
     JOIN (ocs
     WHERE ocs.synonym_id=oci.synonym_id
      AND ocs.active_ind=1)
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd
      AND parser(order_cat_parse))
    ORDER BY d.seq
    DETAIL
     temp_items->items[d.seq].qual_num = (tot_qual_num+ 1)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ELSE
   SELECT INTO "nl:"
    FROM medication_definition md,
     med_def_flex mdef,
     order_catalog oc,
     order_catalog_item_r oci,
     order_catalog_synonym ocs
    PLAN (md
     WHERE md.med_type_flag=0
      AND md.item_id > 0)
     JOIN (mdef
     WHERE mdef.item_id=md.item_id
      AND mdef.pharmacy_type_cd=inpatient_code_value
      AND mdef.active_ind=1)
     JOIN (oci
     WHERE oci.item_id=md.item_id)
     JOIN (ocs
     WHERE ocs.synonym_id=oci.synonym_id
      AND ocs.active_ind=1)
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd
      AND parser(order_cat_parse))
    ORDER BY md.item_id
    HEAD REPORT
     cnt = 0, lcnt = 0, stat = alterlist(temp_items->items,100)
    HEAD md.item_id
     cnt = (cnt+ 1), lcnt = (lcnt+ 1)
     IF (lcnt > 100)
      stat = alterlist(temp_items->items,(cnt+ 100)), lcnt = 1
     ENDIF
     temp_items->items[cnt].item_id = md.item_id, temp_items->items[cnt].qual_num = (tot_qual_num+ 1)
    FOOT REPORT
     stat = alterlist(temp_items->items,cnt)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ENDIF
 ENDIF
 IF ((request->therapeutic_s_ind=1))
  IF (tot_qual_num > 0)
   IF (size(temp_items->items,5) <= 0)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM order_catalog_item_r oci,
     alt_sel_list asl,
     alt_sel_cat asa,
     (dummyt d  WITH seq = size(temp_items->items,5))
    PLAN (d
     WHERE (temp_items->items[d.seq].qual_num=tot_qual_num))
     JOIN (oci
     WHERE (oci.item_id=temp_items->items[d.seq].item_id))
     JOIN (asl
     WHERE asl.synonym_id=oci.synonym_id)
     JOIN (asa
     WHERE asa.alt_sel_category_id=asl.alt_sel_category_id
      AND (asa.alt_sel_category_id=request->therapeutic_code_value)
      AND asa.ahfs_ind=1)
    ORDER BY d.seq
    DETAIL
     temp_items->items[d.seq].qual_num = (tot_qual_num+ 1)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ELSE
   SELECT INTO "nl:"
    FROM medication_definition md,
     med_def_flex mdef,
     order_catalog_item_r oci,
     alt_sel_list asl,
     alt_sel_cat asa
    PLAN (md
     WHERE md.med_type_flag=0
      AND md.item_id > 0)
     JOIN (mdef
     WHERE mdef.item_id=md.item_id
      AND mdef.pharmacy_type_cd=inpatient_code_value
      AND mdef.active_ind=1)
     JOIN (oci
     WHERE oci.item_id=md.item_id)
     JOIN (asl
     WHERE asl.synonym_id=oci.synonym_id)
     JOIN (asa
     WHERE asa.alt_sel_category_id=asl.alt_sel_category_id
      AND (asa.alt_sel_category_id=request->therapeutic_code_value)
      AND asa.ahfs_ind=1)
    ORDER BY md.item_id
    HEAD REPORT
     cnt = 0, lcnt = 0, stat = alterlist(temp_items->items,100)
    HEAD md.item_id
     cnt = (cnt+ 1), lcnt = (lcnt+ 1)
     IF (lcnt > 100)
      stat = alterlist(temp_items->items,(cnt+ 100)), lcnt = 1
     ENDIF
     temp_items->items[cnt].item_id = md.item_id, temp_items->items[cnt].qual_num = (tot_qual_num+ 1)
    FOOT REPORT
     stat = alterlist(temp_items->items,cnt)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ENDIF
 ENDIF
 IF (med_dispense_parse > " ")
  SET med_dispense_parse = concat(med_dispense_parse,
   " mdisp.pharmacy_type_cd+0 = inpatient_code_value ")
  SET dispense_code_value = 0.0
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=4063
    AND cv.cdf_meaning="DISPENSE"
    AND cv.active_ind=1
   DETAIL
    dispense_code_value = cv.code_value
   WITH nocounter
  ;end select
  IF (tot_qual_num > 0)
   IF (size(temp_items->items,5) <= 0)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_dispense mdisp,
     (dummyt d  WITH seq = size(temp_items->items,5))
    PLAN (d
     WHERE (temp_items->items[d.seq].qual_num=tot_qual_num))
     JOIN (mdf
     WHERE (mdf.item_id=temp_items->items[d.seq].item_id)
      AND mdf.flex_type_cd=sys_pkg_code_value
      AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
      AND ((mdf.sequence+ 0)=0)
      AND ((mdf.med_def_flex_id+ 0) != 0)
      AND ((mdf.active_ind+ 0)=1))
     JOIN (mfoi
     WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
      AND mfoi.flex_object_type_cd=dispense_code_value
      AND ((mfoi.parent_entity_id+ 0) != 0)
      AND ((mfoi.sequence+ 0)=1)
      AND ((mfoi.active_ind+ 0)=1))
     JOIN (mdisp
     WHERE (mdisp.med_dispense_id=(mfoi.parent_entity_id+ 0))
      AND parser(med_dispense_parse))
    ORDER BY d.seq
    DETAIL
     temp_items->items[d.seq].qual_num = (tot_qual_num+ 1)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ELSE
   SELECT INTO "nl:"
    FROM medication_definition md,
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_dispense mdisp
    PLAN (md
     WHERE md.med_type_flag=0
      AND md.item_id > 0)
     JOIN (mdf
     WHERE (mdf.item_id=(md.item_id+ 0))
      AND mdf.flex_type_cd=sys_pkg_code_value
      AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
      AND ((mdf.sequence+ 0)=0)
      AND ((mdf.med_def_flex_id+ 0) != 0)
      AND ((mdf.active_ind+ 0)=1))
     JOIN (mfoi
     WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
      AND mfoi.flex_object_type_cd=dispense_code_value
      AND ((mfoi.parent_entity_id+ 0) != 0)
      AND ((mfoi.sequence+ 0)=1)
      AND ((mfoi.active_ind+ 0)=1))
     JOIN (mdisp
     WHERE (mdisp.med_dispense_id=(mfoi.parent_entity_id+ 0))
      AND parser(med_dispense_parse)
      AND ((mdisp.pharmacy_type_cd+ 0)=inpatient_code_value))
    ORDER BY md.item_id
    HEAD REPORT
     cnt = 0, lcnt = 0, stat = alterlist(temp_items->items,100)
    HEAD md.item_id
     cnt = (cnt+ 1), lcnt = (lcnt+ 1)
     IF (lcnt > 100)
      stat = alterlist(temp_items->items,(cnt+ 100)), lcnt = 1
     ENDIF
     temp_items->items[cnt].item_id = md.item_id, temp_items->items[cnt].qual_num = (tot_qual_num+ 1)
    FOOT REPORT
     stat = alterlist(temp_items->items,cnt)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ENDIF
 ENDIF
 IF (med_oe_defaults_parse > " ")
  SET med_oe_defaults_parse = concat(med_oe_defaults_parse," oe.active_ind = 1 ")
  SET oe_code_value = 0.0
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=4063
    AND cv.cdf_meaning="OEDEF"
    AND cv.active_ind=1
   DETAIL
    oe_code_value = cv.code_value
   WITH nocounter
  ;end select
  IF (tot_qual_num > 0)
   IF (size(temp_items->items,5) <= 0)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_oe_defaults oe,
     (dummyt d  WITH seq = size(temp_items->items,5))
    PLAN (d
     WHERE (temp_items->items[d.seq].qual_num=tot_qual_num))
     JOIN (mdf
     WHERE (mdf.item_id=temp_items->items[d.seq].item_id)
      AND mdf.flex_type_cd=system_code_value
      AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
      AND ((mdf.sequence+ 0)=0)
      AND ((mdf.med_def_flex_id+ 0) != 0)
      AND ((mdf.active_ind+ 0)=1))
     JOIN (mfoi
     WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
      AND mfoi.flex_object_type_cd=oe_code_value
      AND ((mfoi.parent_entity_id+ 0) != 0)
      AND ((mfoi.sequence+ 0)=1)
      AND ((mfoi.active_ind+ 0)=1))
     JOIN (oe
     WHERE (oe.med_oe_defaults_id=(mfoi.parent_entity_id+ 0))
      AND parser(med_oe_defaults_parse))
    ORDER BY d.seq
    DETAIL
     temp_items->items[d.seq].qual_num = (tot_qual_num+ 1)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ELSE
   SELECT INTO "nl:"
    FROM medication_definition md,
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_oe_defaults oe
    PLAN (md
     WHERE md.med_type_flag=0
      AND md.item_id > 0)
     JOIN (mdf
     WHERE (mdf.item_id=(md.item_id+ 0))
      AND mdf.flex_type_cd=system_code_value
      AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
      AND ((mdf.sequence+ 0)=0)
      AND ((mdf.med_def_flex_id+ 0) != 0)
      AND ((mdf.active_ind+ 0)=1))
     JOIN (mfoi
     WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
      AND mfoi.flex_object_type_cd=oe_code_value
      AND ((mfoi.parent_entity_id+ 0) != 0)
      AND ((mfoi.sequence+ 0)=1)
      AND ((mfoi.active_ind+ 0)=1))
     JOIN (oe
     WHERE (oe.med_oe_defaults_id=(mfoi.parent_entity_id+ 0))
      AND parser(med_oe_defaults_parse))
    ORDER BY md.item_id
    HEAD REPORT
     cnt = 0, lcnt = 0, stat = alterlist(temp_items->items,100)
    HEAD md.item_id
     cnt = (cnt+ 1), lcnt = (lcnt+ 1)
     IF (lcnt > 100)
      stat = alterlist(temp_items->items,(cnt+ 100)), lcnt = 1
     ENDIF
     temp_items->items[cnt].item_id = md.item_id, temp_items->items[cnt].qual_num = (tot_qual_num+ 1)
    FOOT REPORT
     stat = alterlist(temp_items->items,cnt)
    WITH nocounter
   ;end select
   SET tot_qual_num = (tot_qual_num+ 1)
  ENDIF
 ENDIF
 FREE SET acm_get_acc_logical_domains_req
 RECORD acm_get_acc_logical_domains_req(
   1 write_mode_ind = i2
   1 concept = i4
 )
 FREE SET acm_get_acc_logical_domains_rep
 RECORD acm_get_acc_logical_domains_rep(
   1 logical_domain_grp_id = f8
   1 logical_domains_cnt = i4
   1 logical_domains[*]
     2 logical_domain_id = f8
   1 status_block
     2 status_ind = i2
     2 error_code = i4
 )
 SET data_partition_ind = 0
 SET prg_exists_ind = 0
 SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
 IF (prg_exists_ind > 0)
  SET field_found = 0
  RANGE OF o IS organization
  SET field_found = validate(o.logical_domain_id)
  FREE RANGE o
  IF (field_found=1)
   SET data_partition_ind = 1
   SET acm_get_acc_logical_domains_req->write_mode_ind = 0
   SET acm_get_acc_logical_domains_req->concept = 3
   EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
   replace("REPLY",acm_get_acc_logical_domains_rep)
  ENDIF
 ENDIF
 DECLARE org_parse = vc
 SET org_parse = "o.organization_id = outerjoin(l.organization_id)"
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET org_parse = concat(org_parse," and o.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 CALL echorecord(acm_get_acc_logical_domains_rep)
 IF (size(temp_items->items,5) > 0)
  SET orderable_code_value = 0.0
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=4063
    AND cv.cdf_meaning="ORDERABLE"
    AND cv.active_ind=1
   DETAIL
    orderable_code_value = cv.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM med_def_flex mdf,
    med_flex_object_idx mfoi,
    location l,
    organization o,
    (dummyt d  WITH seq = size(temp_items->items,5))
   PLAN (d
    WHERE (temp_items->items[d.seq].qual_num=tot_qual_num))
    JOIN (mdf
    WHERE (mdf.item_id=temp_items->items[d.seq].item_id)
     AND mdf.flex_type_cd=sys_pkg_code_value
     AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
     AND ((mdf.sequence+ 0)=0)
     AND ((mdf.med_def_flex_id+ 0) != 0)
     AND ((mdf.active_ind+ 0)=1))
    JOIN (mfoi
    WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
     AND mfoi.flex_object_type_cd=orderable_code_value
     AND ((mfoi.sequence+ 0)=0)
     AND ((mfoi.active_ind+ 0)=1))
    JOIN (l
    WHERE l.location_cd=outerjoin(mfoi.parent_entity_id)
     AND l.active_ind=outerjoin(1))
    JOIN (o
    WHERE o.organization_id=outerjoin(l.organization_id))
   ORDER BY d.seq, o.logical_domain_id, mfoi.parent_entity_id
   HEAD d.seq
    m_domin_ind = 0, temp_domain_cnt = 0
   HEAD o.logical_domain_id
    IF (o.organization_id > 0)
     temp_domain_cnt = (temp_domain_cnt+ 1)
    ENDIF
   HEAD mfoi.parent_entity_id
    IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0)
     AND mfoi.parent_entity_id > 0)
     FOR (ld_cnt = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
       IF ((acm_get_acc_logical_domains_rep->logical_domains[ld_cnt].logical_domain_id=o
       .logical_domain_id)
        AND o.organization_id > 0)
        temp_items->items[d.seq].logical_domain_ind = 1, ld_cnt = acm_get_acc_logical_domains_rep->
        logical_domains_cnt
       ENDIF
     ENDFOR
    ENDIF
    IF (mfoi.parent_entity_id IN (0, null))
     temp_items->items[d.seq].all_fac_ind = 1
    ENDIF
   FOOT  d.seq
    IF (temp_domain_cnt > 1)
     temp_items->items[d.seq].mult_domain_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM med_identifier mi,
    (dummyt d  WITH seq = size(temp_items->items,5)),
    medication_definition md,
    med_def_flex mdf
   PLAN (d
    WHERE (temp_items->items[d.seq].qual_num=tot_qual_num)
     AND (((temp_items->items[d.seq].logical_domain_ind=1)) OR ((((temp_items->items[d.seq].
    all_fac_ind=1)) OR ((((request->location_s_ind=1)) OR ((acm_get_acc_logical_domains_rep->
    logical_domains_cnt=0))) )) )) )
    JOIN (md
    WHERE (md.item_id=temp_items->items[d.seq].item_id))
    JOIN (mdf
    WHERE mdf.item_id=md.item_id
     AND mdf.active_ind=1)
    JOIN (mi
    WHERE mi.item_id=mdf.item_id
     AND mi.pharmacy_type_cd=inpatient_code_value
     AND mi.med_identifier_type_cd=desc_code_value
     AND ((mi.flex_type_cd+ 0) IN (system_code_value))
     AND mi.primary_ind=1
     AND ((mi.med_product_id+ 0)=0)
     AND ((mi.active_ind+ 0)=1))
   ORDER BY md.item_id
   HEAD REPORT
    cnt = 0, lcnt = 0, stat = alterlist(reply->items,100)
   HEAD mi.item_id
    cnt = (cnt+ 1), lcnt = (lcnt+ 1)
    IF (lcnt > 100)
     stat = alterlist(reply->items,(cnt+ 100)), lcnt = 1
    ENDIF
    reply->items[cnt].item_id = mi.item_id, reply->items[cnt].description = mi.value, reply->items[
    cnt].all_facility_ind = temp_items->items[d.seq].all_fac_ind,
    reply->items[cnt].mult_domain_ind = temp_items->items[d.seq].mult_domain_ind
   FOOT REPORT
    stat = alterlist(reply->items,cnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (size(reply->items,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
