CREATE PROGRAM bed_ens_rx_cont_iv_set:dba
 FREE SET reply
 RECORD reply(
   1 catalog_code_value = f8
   1 duplicate_iv_set_ind = i2
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET fcnt = 0
 SET syn_cnt = 0
 DECLARE syn_description = vc
 DECLARE inact_description = vc
 DECLARE long_txt = vc
 DECLARE catalog_type_cd = f8
 DECLARE activity_type_cd = f8
 DECLARE clin_cat_cd = f8
 DECLARE active_cd = f8
 DECLARE ord_cd = f8
 DECLARE cs_ord_cd = f8
 DECLARE primary_cd = f8
 DECLARE ord_action_cd = f8
 DECLARE ordsent_cd = f8
 DECLARE long_desc = vc
 DECLARE modifiable_flag_value = i2
 DECLARE orderable_type_flag_value = i2
 SET catalog_type_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET activity_type_cd = uar_get_code_by("MEANING",106,"PHARMACY")
 SET clin_cat_cd = uar_get_code_by("MEANING",16389,"IVSOLUTIONS")
 SET active_cd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET ord_cd = uar_get_code_by("MEANING",13016,"ORD CAT")
 SET cs_ord_cd = uar_get_code_by("MEANING",6030,"ORDERABLE")
 SET primary_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET ord_action_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET ordsent_cd = uar_get_code_by("MEANING",30620,"ORDERSENT")
 SET long_desc = request->description
 SET syn_cnt = size(request->synonyms,5)
 SET modifiable_flag_value = 1
 SET orderable_type_flag_value = 8
 IF (validate(request->modifiable_flag))
  SET modifiable_flag_value = request->modifiable_flag
 ENDIF
 IF (validate(request->orderable_type_flag))
  SET orderable_type_flag_value = request->orderable_type_flag
 ENDIF
 SET intermittent_ind_value = 0
 IF (validate(request->intermittent_ind))
  SET intermittent_ind_value = request->intermittent_ind
 ENDIF
 IF (intermittent_ind_value=1)
  SET int_cnt = size(request->patient_care_synonyms,5)
  FOR (i = 2 TO int_cnt)
    SET request->patient_care_synonyms[i].sentence.comment = ""
  ENDFOR
 ENDIF
 FOR (y = 1 TO syn_cnt)
   IF ((request->synonyms[y].type_code_value=primary_cd))
    SET request->description = request->synonyms[y].name
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM order_catalog o
  PLAN (o
   WHERE cnvtupper(o.primary_mnemonic)=cnvtupper(request->description))
  DETAIL
   reply->duplicate_iv_set_ind = 1, reply->catalog_code_value = o.catalog_cd
  WITH nocounter
 ;end select
 IF ((reply->duplicate_iv_set_ind=1))
  GO TO exit_script
 ENDIF
 SET new_cv = 0.0
 SELECT INTO "NL:"
  j = seq(reference_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_cv = cnvtreal(j)
  WITH format, counter
 ;end select
 SET reply->catalog_code_value = new_cv
 INSERT  FROM code_value cv
  SET cv.code_value = new_cv, cv.code_set = 200, cv.active_ind = 1,
   cv.cki = null, cv.concept_cki = " ", cv.display_key_nls = null,
   cv.display = trim(substring(1,40,request->description)), cv.display_key = trim(cnvtupper(
     cnvtalphanum(substring(1,40,request->description)))), cv.description = trim(substring(1,60,
     long_desc)),
   cv.definition = null, cv.data_status_cd = 0, cv.data_status_prsnl_id = 0,
   cv.active_type_cd = active_cd, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv
   .begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), cv.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), cv.updt_id = reqinfo->updt_id,
   cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to insert ",trim(request->description)," into codeset 200.")
  GO TO exit_script
 ENDIF
 INSERT  FROM order_catalog oc
  SET oc.catalog_cd = new_cv, oc.abn_review_ind = null, oc.activity_type_cd = activity_type_cd,
   oc.activity_subtype_cd = 0, oc.resource_route_lvl = null, oc.active_ind = 1,
   oc.prompt_ind = null, oc.catalog_type_cd = catalog_type_cd, oc.requisition_format_cd = 0,
   oc.requisition_routing_cd = 0, oc.description = trim(substring(1,60,long_desc)), oc.print_req_ind
    = 0,
   oc.orderable_type_flag = orderable_type_flag_value, oc.oe_format_id = 0, oc.prep_info_flag = 0,
   oc.cont_order_method_flag = 0, oc.primary_mnemonic = trim(substring(1,100,request->description)),
   oc.dept_display_name = trim(substring(1,60,request->description)),
   oc.ref_text_mask = null, oc.source_vocab_ident = null, oc.source_vocab_mean = null,
   oc.dcp_clin_cat_cd = clin_cat_cd, oc.cki = null, oc.concept_cki = null,
   oc.consent_form_ind = 0, oc.inst_restriction_ind = 0, oc.schedule_ind = 0,
   oc.quick_chart_ind = 0, oc.complete_upon_order_ind = 0, oc.comment_template_flag = 0,
   oc.dup_checking_ind = null, oc.bill_only_ind = 0, oc.form_level = null,
   oc.modifiable_flag = modifiable_flag_value, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc
   .updt_id = reqinfo->updt_id,
   oc.updt_task = reqinfo->updt_task, oc.updt_cnt = 0, oc.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to insert ",trim(request->description),
   " into the order catalog table.")
  GO TO exit_script
 ENDIF
 SET new_bill_id = 0.0
 SELECT INTO "NL:"
  j = seq(bill_item_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_bill_id = cnvtreal(j)
  WITH format, counter
 ;end select
 INSERT  FROM bill_item b
  SET b.bill_item_id = new_bill_id, b.ext_parent_reference_id = new_cv, b.ext_parent_contributor_cd
    = ord_cd,
   b.ext_child_reference_id = 0, b.ext_child_contributor_cd = 0, b.ext_description = trim(request->
    description),
   b.ext_owner_cd = activity_type_cd, b.parent_qual_cd = 1, b.charge_point_cd = 0,
   b.physician_qual_cd = 0, b.calc_type_cd = 0, b.active_ind = 1,
   b.ext_short_desc = trim(substring(1,50,request->description)), b.ext_parent_entity_name =
   "CODE_VALUE", b.ext_child_entity_name = null,
   b.careset_ind = 0, b.workload_only_ind = 0, b.parent_qual_ind = 0,
   b.misc_ind = 0, b.stats_only_ind = 0, b.child_seq = 0,
   b.num_hits = 0, b.late_chrg_excl_ind = 0, b.cost_basis_amt = 0,
   b.tax_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->
   updt_applctx,
   b.updt_cnt = 0, b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id,
   b.active_status_cd = active_cd, b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b
   .active_status_prsnl_id = reqinfo->updt_id,
   b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100")
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to insert ",trim(request->description),
   " into the bill_item table.")
  GO TO exit_script
 ENDIF
 FOR (y = 1 TO syn_cnt)
   SET new_order_synonym_id = 0.0
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_order_synonym_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM order_catalog_synonym ocs
    SET ocs.synonym_id = new_order_synonym_id, ocs.catalog_cd = new_cv, ocs.catalog_type_cd =
     catalog_type_cd,
     ocs.mnemonic = request->synonyms[y].name, ocs.mnemonic_key_cap = cnvtupper(request->synonyms[y].
      name), ocs.mnemonic_type_cd = request->synonyms[y].type_code_value,
     ocs.oe_format_id = 0, ocs.active_ind = request->synonyms[y].active_ind, ocs.activity_type_cd =
     activity_type_cd,
     ocs.activity_subtype_cd = 0, ocs.orderable_type_flag = orderable_type_flag_value, ocs
     .concentration_strength = null,
     ocs.concentration_volume = null, ocs.active_status_cd = active_cd, ocs.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     ocs.active_status_prsnl_id = reqinfo->updt_id, ocs.ref_text_mask = null, ocs
     .multiple_ord_sent_ind = null,
     ocs.hide_flag = 0, ocs.rx_mask = 3, ocs.dcp_clin_cat_cd = clin_cat_cd,
     ocs.filtered_od_ind = null, ocs.cki = null, ocs.mnemonic_key_cap_nls = null,
     ocs.virtual_view = " ", ocs.health_plan_view = null, ocs.concept_cki = null,
     ocs.intermittent_ind = intermittent_ind_value, ocs.updt_applctx = reqinfo->updt_applctx, ocs
     .updt_cnt = 0,
     ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs.updt_task
      = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to insert order set synonym: ",trim(request->synonyms[y].
      name)," on the order_catalog_synonym table")
    GO TO exit_script
   ENDIF
   SET fcnt = size(request->facilities,5)
   IF (((fcnt=0) OR ((request->facilities[1].code_value=0))) )
    INSERT  FROM ocs_facility_r ofr
     SET ofr.synonym_id = new_order_synonym_id, ofr.facility_cd = 0.0, ofr.updt_applctx = reqinfo->
      updt_applctx,
      ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ofr.updt_id = reqinfo->
      updt_id,
      ofr.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ELSE
    FOR (x = 1 TO fcnt)
      INSERT  FROM ocs_facility_r ofr
       SET ofr.synonym_id = new_order_synonym_id, ofr.facility_cd = request->facilities[x].code_value,
        ofr.updt_applctx = reqinfo->updt_applctx,
        ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ofr.updt_id = reqinfo->
        updt_id,
        ofr.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
    ENDFOR
   ENDIF
 ENDFOR
 SET comp_cnt = size(request->patient_care_synonyms,5)
 SET cc_seq = 0
 FOR (y = 1 TO comp_cnt)
   SET format_id = 0.0
   SET af_id = 0.0
   SET inact_bill_id = 0.0
   SET inact_description = " "
   SET inact_act_type = 0.0
   SELECT INTO "nl:"
    FROM order_entry_format o
    PLAN (o
     WHERE o.oe_format_name="IV Ingredient")
    DETAIL
     af_id = o.oe_format_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs,
     bill_item b
    PLAN (ocs
     WHERE (ocs.synonym_id=request->patient_care_synonyms[y].id))
     JOIN (b
     WHERE b.ext_child_reference_id=ocs.catalog_cd
      AND b.ext_parent_reference_id=new_cv
      AND b.active_ind=0)
    ORDER BY b.child_seq
    DETAIL
     inact_bill_id = b.bill_item_id, inact_description = ocs.mnemonic, inact_act_type = ocs
     .activity_type_cd
     IF (((intermittent_ind_value=0
      AND band(ocs.rx_mask,1)=1) OR (intermittent_ind_value=1
      AND y=1)) )
      format_id = ocs.oe_format_id
     ELSE
      format_id = af_id
      IF (intermittent_ind_value=0)
       request->patient_care_synonyms[y].sentence.comment = ""
      ENDIF
     ENDIF
    WITH nocounter, maxrec = 1
   ;end select
   IF (inact_bill_id > 0)
    UPDATE  FROM bill_item b
     SET b.active_ind = 1, b.ext_description = trim(inact_description), b.ext_owner_cd =
      inact_act_type,
      b.ext_short_desc = trim(substring(1,50,inact_description)), b.active_status_cd = active_cd, b
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      b.active_status_prsnl_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
      .updt_applctx = reqinfo->updt_applctx,
      b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id
     PLAN (b
      WHERE b.bill_item_id=inact_bill_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to update synonym_id:",trim(cnvtstring(request->
        patient_care_synonyms[y].id))," on the bill_item table.")
     GO TO exit_script
    ENDIF
   ELSE
    SET sequence = 0
    SELECT INTO "nl:"
     temp_seq = max(b.child_seq)
     FROM bill_item b,
      order_catalog_synonym o
     PLAN (o
      WHERE (o.synonym_id=request->patient_care_synonyms[y].id))
      JOIN (b
      WHERE b.ext_child_reference_id=o.catalog_cd
       AND b.ext_parent_reference_id=new_cv)
     DETAIL
      sequence = temp_seq
     WITH nocounter
    ;end select
    SET catalog_code_value = 0.0
    SET syn_description = " "
    SET syn_act_type = 0.0
    SELECT INTO "nl:"
     FROM order_catalog_synonym ocs
     PLAN (ocs
      WHERE (ocs.synonym_id=request->patient_care_synonyms[y].id))
     DETAIL
      catalog_code_value = ocs.catalog_cd, syn_description = ocs.mnemonic, syn_act_type = ocs
      .activity_type_cd
      IF (((intermittent_ind_value=0
       AND band(ocs.rx_mask,1)=1) OR (intermittent_ind_value=1
       AND y=1)) )
       format_id = ocs.oe_format_id
      ELSE
       format_id = af_id
       IF (intermittent_ind_value=0)
        request->patient_care_synonyms[y].sentence.comment = ""
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SET new_bill_id = 0.0
    SELECT INTO "NL:"
     j = seq(bill_item_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_bill_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM bill_item b
     SET b.bill_item_id = new_bill_id, b.ext_parent_reference_id = new_cv, b
      .ext_parent_contributor_cd = ord_cd,
      b.ext_child_reference_id = catalog_code_value, b.ext_child_contributor_cd = ord_cd, b
      .ext_description = trim(syn_description),
      b.ext_owner_cd = syn_act_type, b.parent_qual_cd = 1, b.charge_point_cd = 0,
      b.physician_qual_cd = 0, b.calc_type_cd = 0, b.active_ind = 1,
      b.ext_short_desc = trim(substring(1,50,syn_description)), b.ext_parent_entity_name =
      "CODE_VALUE", b.ext_child_entity_name = "CODE_VALUE",
      b.careset_ind = 0, b.workload_only_ind = 0, b.parent_qual_ind = 0,
      b.misc_ind = 0, b.stats_only_ind = 0, b.child_seq = (sequence+ 1),
      b.num_hits = 0, b.late_chrg_excl_ind = 0, b.cost_basis_amt = 0,
      b.tax_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->
      updt_applctx,
      b.updt_cnt = 0, b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id,
      b.active_status_cd = active_cd, b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b
      .active_status_prsnl_id = reqinfo->updt_id,
      b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100")
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to insert order set component:",trim(cnvtstring(request->
        patient_care_synonyms[y].id))," into the bill_item table.")
     GO TO exit_script
    ENDIF
   ENDIF
   FREE SET fld
   RECORD fld(
     1 fields[*]
       2 oe_field_id = f8
       2 value = vc
       2 code_value = f8
       2 group_seq = i4
       2 field_seq = i4
       2 field_type_flag = i2
   )
   SET route_cd = 0.0
   IF ((request->patient_care_synonyms[y].sentence.route > " "))
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=4001
       AND (c.display=request->patient_care_synonyms[y].sentence.route))
     DETAIL
      route_cd = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   DECLARE dose_disp = vc
   IF ((request->patient_care_synonyms[y].sentence.dose_unit_code_value > 0))
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE (c.code_value=request->patient_care_synonyms[y].sentence.dose_unit_code_value))
     DETAIL
      dose_disp = c.display
     WITH nocounter
    ;end select
   ENDIF
   DECLARE rate_disp = vc
   IF ((request->patient_care_synonyms[y].sentence.rate_unit_code_value > 0))
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE (c.code_value=request->patient_care_synonyms[y].sentence.rate_unit_code_value))
     DETAIL
      rate_disp = c.display
     WITH nocounter
    ;end select
   ENDIF
   DECLARE n_rate_disp = vc
   IF ((request->patient_care_synonyms[y].sentence.normalized_rate_unit_code_value > 0))
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE (c.code_value=request->patient_care_synonyms[y].sentence.normalized_rate_unit_code_value)
      )
     DETAIL
      n_rate_disp = c.display
     WITH nocounter
    ;end select
   ENDIF
   DECLARE frequency_disp = vc
   IF ((request->patient_care_synonyms[y].sentence.frequency_code_value > 0))
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE (c.code_value=request->patient_care_synonyms[y].sentence.frequency_code_value))
     DETAIL
      frequency_disp = c.display
     WITH nocounter
    ;end select
   ENDIF
   SET aa = 0
   SET cnt = 0
   SELECT INTO "nl:"
    FROM oe_format_fields off,
     order_entry_fields oef,
     oe_field_meaning oe
    PLAN (off
     WHERE off.oe_format_id=format_id
      AND off.action_type_cd=ord_action_cd)
     JOIN (oef
     WHERE oef.oe_field_id=off.oe_field_id)
     JOIN (oe
     WHERE oe.oe_field_meaning_id=oef.oe_field_meaning_id
      AND oe.oe_field_meaning IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT", "STRENGTHDOSE", "STRENGTHDOSEUNIT",
     "RXROUTE",
     "RATE", "RATEUNIT", "NORMALIZEDRATE", "NORMALIZEDRATEUNIT", "FREETEXTRATE",
     "FREQ"))
    ORDER BY off.group_seq, off.field_seq
    DETAIL
     IF ((request->patient_care_synonyms[y].sentence.route > " ")
      AND oe.oe_field_meaning="RXROUTE")
      cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
      .oe_field_id,
      fld->fields[cnt].value = request->patient_care_synonyms[y].sentence.route, fld->fields[cnt].
      code_value = route_cd, fld->fields[cnt].group_seq = off.group_seq,
      fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
      .field_type_flag
     ENDIF
     IF ((request->patient_care_synonyms[y].sentence.strength_ind=1))
      IF ((request->patient_care_synonyms[y].sentence.dose > 0)
       AND oe.oe_field_meaning="STRENGTHDOSE")
       cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
       .oe_field_id,
       fld->fields[cnt].value = build(request->patient_care_synonyms[y].sentence.dose), aa =
       findstring(".",fld->fields[cnt].value), fld->fields[cnt].value = substring(1,(aa+ 3),fld->
        fields[cnt].value)
       IF (substring((aa+ 1),3,fld->fields[cnt].value)="000")
        fld->fields[cnt].value = substring(1,(aa - 1),fld->fields[cnt].value)
       ELSEIF (substring((aa+ 2),2,fld->fields[cnt].value)="00")
        fld->fields[cnt].value = substring(1,(aa+ 1),fld->fields[cnt].value)
       ELSEIF (substring((aa+ 3),1,fld->fields[cnt].value)="0")
        fld->fields[cnt].value = substring(1,(aa+ 2),fld->fields[cnt].value)
       ENDIF
       fld->fields[cnt].code_value = 0, fld->fields[cnt].group_seq = off.group_seq, fld->fields[cnt].
       field_seq = off.field_seq,
       fld->fields[cnt].field_type_flag = oef.field_type_flag
      ENDIF
      IF ((request->patient_care_synonyms[y].sentence.dose_unit_code_value > 0)
       AND oe.oe_field_meaning="STRENGTHDOSEUNIT")
       cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
       .oe_field_id,
       fld->fields[cnt].value = dose_disp, fld->fields[cnt].code_value = request->
       patient_care_synonyms[y].sentence.dose_unit_code_value, fld->fields[cnt].group_seq = off
       .group_seq,
       fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
       .field_type_flag
      ENDIF
     ENDIF
     IF ((request->patient_care_synonyms[y].sentence.volume_ind=1))
      IF ((request->patient_care_synonyms[y].sentence.dose > 0)
       AND oe.oe_field_meaning="VOLUMEDOSE")
       cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
       .oe_field_id,
       fld->fields[cnt].value = build(request->patient_care_synonyms[y].sentence.dose), aa =
       findstring(".",fld->fields[cnt].value), fld->fields[cnt].value = substring(1,(aa+ 3),fld->
        fields[cnt].value)
       IF (substring((aa+ 1),3,fld->fields[cnt].value)="000")
        fld->fields[cnt].value = substring(1,(aa - 1),fld->fields[cnt].value)
       ELSEIF (substring((aa+ 2),2,fld->fields[cnt].value)="00")
        fld->fields[cnt].value = substring(1,(aa+ 1),fld->fields[cnt].value)
       ELSEIF (substring((aa+ 3),1,fld->fields[cnt].value)="0")
        fld->fields[cnt].value = substring(1,(aa+ 2),fld->fields[cnt].value)
       ENDIF
       fld->fields[cnt].code_value = 0, fld->fields[cnt].group_seq = off.group_seq, fld->fields[cnt].
       field_seq = off.field_seq,
       fld->fields[cnt].field_type_flag = oef.field_type_flag
      ENDIF
      IF ((request->patient_care_synonyms[y].sentence.dose_unit_code_value > 0)
       AND oe.oe_field_meaning="VOLUMEDOSEUNIT")
       cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
       .oe_field_id,
       fld->fields[cnt].value = dose_disp, fld->fields[cnt].code_value = request->
       patient_care_synonyms[y].sentence.dose_unit_code_value, fld->fields[cnt].group_seq = off
       .group_seq,
       fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
       .field_type_flag
      ENDIF
     ENDIF
     IF ((request->patient_care_synonyms[y].sentence.rate > 0)
      AND oe.oe_field_meaning="RATE")
      cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
      .oe_field_id,
      fld->fields[cnt].value = build(request->patient_care_synonyms[y].sentence.rate), aa =
      findstring(".",fld->fields[cnt].value), fld->fields[cnt].value = substring(1,(aa+ 3),fld->
       fields[cnt].value)
      IF (substring((aa+ 1),3,fld->fields[cnt].value)="000")
       fld->fields[cnt].value = substring(1,(aa - 1),fld->fields[cnt].value)
      ELSEIF (substring((aa+ 2),2,fld->fields[cnt].value)="00")
       fld->fields[cnt].value = substring(1,(aa+ 1),fld->fields[cnt].value)
      ELSEIF (substring((aa+ 3),1,fld->fields[cnt].value)="0")
       fld->fields[cnt].value = substring(1,(aa+ 2),fld->fields[cnt].value)
      ENDIF
      fld->fields[cnt].code_value = 0, fld->fields[cnt].group_seq = off.group_seq, fld->fields[cnt].
      field_seq = off.field_seq,
      fld->fields[cnt].field_type_flag = oef.field_type_flag
     ENDIF
     IF ((request->patient_care_synonyms[y].sentence.rate_unit_code_value > 0)
      AND oe.oe_field_meaning="RATEUNIT")
      cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
      .oe_field_id,
      fld->fields[cnt].value = rate_disp, fld->fields[cnt].code_value = request->
      patient_care_synonyms[y].sentence.rate_unit_code_value, fld->fields[cnt].group_seq = off
      .group_seq,
      fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
      .field_type_flag
     ENDIF
     IF ((request->patient_care_synonyms[y].sentence.normalized_rate > 0)
      AND oe.oe_field_meaning="NORMALIZEDRATE")
      cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
      .oe_field_id,
      fld->fields[cnt].value = build(request->patient_care_synonyms[y].sentence.normalized_rate), aa
       = findstring(".",fld->fields[cnt].value), fld->fields[cnt].value = substring(1,(aa+ 3),fld->
       fields[cnt].value)
      IF (substring((aa+ 1),3,fld->fields[cnt].value)="000")
       fld->fields[cnt].value = substring(1,(aa - 1),fld->fields[cnt].value)
      ELSEIF (substring((aa+ 2),2,fld->fields[cnt].value)="00")
       fld->fields[cnt].value = substring(1,(aa+ 1),fld->fields[cnt].value)
      ELSEIF (substring((aa+ 3),1,fld->fields[cnt].value)="0")
       fld->fields[cnt].value = substring(1,(aa+ 2),fld->fields[cnt].value)
      ENDIF
      fld->fields[cnt].code_value = 0, fld->fields[cnt].group_seq = off.group_seq, fld->fields[cnt].
      field_seq = off.field_seq,
      fld->fields[cnt].field_type_flag = oef.field_type_flag
     ENDIF
     IF ((request->patient_care_synonyms[y].sentence.normalized_rate_unit_code_value > 0)
      AND oe.oe_field_meaning="NORMALIZEDRATEUNIT")
      cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
      .oe_field_id,
      fld->fields[cnt].value = n_rate_disp, fld->fields[cnt].code_value = request->
      patient_care_synonyms[y].sentence.normalized_rate_unit_code_value, fld->fields[cnt].group_seq
       = off.group_seq,
      fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
      .field_type_flag
     ENDIF
     IF ((request->patient_care_synonyms[y].sentence.freetext_rate > " ")
      AND oe.oe_field_meaning="FREETEXTRATE")
      cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
      .oe_field_id,
      fld->fields[cnt].value = cnvtstring(request->patient_care_synonyms[y].sentence.freetext_rate),
      fld->fields[cnt].code_value = 0, fld->fields[cnt].group_seq = off.group_seq,
      fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
      .field_type_flag
     ENDIF
     IF ((request->patient_care_synonyms[y].sentence.frequency_code_value > 0)
      AND oe.oe_field_meaning="FREQ")
      cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
      .oe_field_id,
      fld->fields[cnt].value = frequency_disp, fld->fields[cnt].code_value = request->
      patient_care_synonyms[y].sentence.frequency_code_value, fld->fields[cnt].group_seq = off
      .group_seq,
      fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
      .field_type_flag
     ENDIF
    WITH nocounter
   ;end select
   SET os_id = 0.0
   SELECT INTO "nl:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     os_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET lt_id = 0.0
   IF ((request->patient_care_synonyms[y].sentence.comment > " "))
    SELECT INTO "nl:"
     j = seq(long_data_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      lt_id = cnvtreal(j)
     WITH format, counter
    ;end select
   ENDIF
   DECLARE order_sentence = vc
   DECLARE os_value = vc
   FOR (x = 1 TO size(fld->fields,5))
     IF ((fld->fields[x].field_type_flag=7))
      IF ((fld->fields[x].value IN ("YES", "1")))
       SET fld->fields[x].value = "Yes"
      ENDIF
      IF ((fld->fields[x].value IN ("NO", "0")))
       SET fld->fields[x].value = "No"
      ENDIF
     ENDIF
     SET os_value = fld->fields[x].value
     SELECT INTO "nl:"
      FROM oe_format_fields o
      PLAN (o
       WHERE o.oe_format_id=format_id
        AND (o.oe_field_id=fld->fields[x].oe_field_id)
        AND o.action_type_cd=ord_action_cd)
      DETAIL
       IF ((fld->fields[x].field_type_flag=7))
        IF ((fld->fields[x].value="Yes"))
         os_value = o.label_text
        ELSEIF ((fld->fields[x].value="No"))
         os_value = o.clin_line_label
        ENDIF
       ELSE
        IF (o.clin_line_label > " ")
         IF (o.clin_suffix_ind=1)
          os_value = concat(trim(fld->fields[x].value)," ",trim(o.clin_line_label))
         ELSE
          os_value = concat(trim(o.clin_line_label)," ",trim(fld->fields[x].value))
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (x=1)
      SET order_sentence = trim(os_value)
      SET gseq = fld->fields[x].group_seq
     ELSE
      IF (os_value > " ")
       IF ((gseq=fld->fields[x].group_seq))
        SET order_sentence = concat(trim(order_sentence)," ",trim(os_value))
       ELSE
        SET order_sentence = concat(trim(order_sentence),", ",trim(os_value))
        SET gseq = fld->fields[x].group_seq
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   DECLARE lock_details_flag_value = i2
   SET lock_details_flag_value = 0
   IF (validate(request->patient_care_synonyms[y].lock_details_flag))
    SET lock_details_flag_value = request->patient_care_synonyms[y].lock_details_flag
   ENDIF
   DECLARE auto_ver_opt_ind_value = i2
   SET auto_ver_opt_ind_value = 0
   IF (validate(request->patient_care_synonyms[y].auto_verification_optional_ind))
    SET auto_ver_opt_ind_value = request->patient_care_synonyms[y].auto_verification_optional_ind
   ENDIF
   SET cc_seq = (cc_seq+ 1)
   INSERT  FROM cs_component cc
    SET cc.catalog_cd = new_cv, cc.comp_seq = cc_seq, cc.comp_type_cd = cs_ord_cd,
     cc.comp_id = request->patient_care_synonyms[y].id, cc.long_text_id = 0, cc.required_ind = 0,
     cc.include_exclude_ind = 1, cc.comp_label = " ", cc.order_sentence_id = os_id,
     cc.linked_date_comp_seq = 0, cc.variance_format_id = 0, cc.parent_comp_seq = null,
     cc.cp_row_cat_cd = 0, cc.cp_col_cat_cd = 0, cc.outcome_par_comp_seq = null,
     cc.comp_type_mean = null, cc.index_type_cd = 0, cc.ord_com_template_long_text_id = 0,
     cc.comp_mask = null, cc.comp_reference = null, cc.lockdown_details_flag =
     lock_details_flag_value,
     cc.av_optional_ingredient_ind = auto_ver_opt_ind_value, cc.updt_applctx = reqinfo->updt_applctx,
     cc.updt_cnt = 0,
     cc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_id = reqinfo->updt_id, cc.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to insert order set orderable: ",trim(cnvtstring(request->
       patient_care_synonyms[y].id))," into the cs_component table")
    GO TO exit_script
   ENDIF
   INSERT  FROM order_sentence o
    SET o.order_sentence_id = os_id, o.order_sentence_display_line = order_sentence, o.oe_format_id
      = format_id,
     o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
     reqinfo->updt_task,
     o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.usage_flag = 1,
     o.order_encntr_group_cd = 0, o.ord_comment_long_text_id = lt_id, o.parent_entity_name =
     "ORDER_CATALOG_SYNONYM",
     o.parent_entity_id = request->patient_care_synonyms[y].id, o.parent_entity2_name =
     "ORDER_CATALOG", o.parent_entity2_id = new_cv,
     o.ic_auto_verify_flag = 0, o.discern_auto_verify_flag = 0, o.external_identifier = null
    PLAN (o)
    WITH nocounter
   ;end insert
   IF ((request->patient_care_synonyms[y].sentence.comment > " "))
    INSERT  FROM long_text l
     SET l.long_text_id = lt_id, l.updt_id = reqinfo->updt_id, l.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0,
      l.active_ind = 1, l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
       curtime),
      l.active_status_prsnl_id = reqinfo->updt_id, l.parent_entity_name = "ORDER_SENTENCE", l
      .parent_entity_id = os_id,
      l.long_text = request->patient_care_synonyms[y].sentence.comment
     PLAN (l)
     WITH nocounter
    ;end insert
   ENDIF
   SET fcnt = size(request->facilities,5)
   IF (((fcnt=0) OR ((request->facilities[1].code_value=0))) )
    INSERT  FROM filter_entity_reltn f
     SET f.filter_entity_reltn_id = seq(reference_seq,nextval), f.parent_entity_name =
      "ORDER_SENTENCE", f.parent_entity_id = os_id,
      f.filter_entity1_name = "LOCATION", f.filter_entity1_id = 0, f.filter_entity2_name = null,
      f.filter_entity2_id = 0, f.filter_entity3_name = null, f.filter_entity3_id = 0,
      f.filter_entity4_name = null, f.filter_entity4_id = 0, f.filter_entity5_name = null,
      f.filter_entity5_id = 0, f.filter_type_cd = ordsent_cd, f.exclusion_filter_ind = null,
      f.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), f.end_effective_dt_tm = cnvtdatetime(
       "31-dec-2100 00:00:00.00"), f.updt_id = reqinfo->updt_id,
      f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f.updt_applctx
       = reqinfo->updt_applctx,
      f.updt_cnt = 0
     PLAN (f)
     WITH nocounter
    ;end insert
   ELSE
    FOR (x = 1 TO size(request->facilities,5))
      INSERT  FROM filter_entity_reltn f
       SET f.filter_entity_reltn_id = seq(reference_seq,nextval), f.parent_entity_name =
        "ORDER_SENTENCE", f.parent_entity_id = os_id,
        f.filter_entity1_name = "LOCATION", f.filter_entity1_id = request->facilities[x].code_value,
        f.filter_entity2_name = null,
        f.filter_entity2_id = 0, f.filter_entity3_name = null, f.filter_entity3_id = 0,
        f.filter_entity4_name = null, f.filter_entity4_id = 0, f.filter_entity5_name = null,
        f.filter_entity5_id = 0, f.filter_type_cd = ordsent_cd, f.exclusion_filter_ind = null,
        f.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), f.end_effective_dt_tm = cnvtdatetime(
         "31-dec-2100 00:00:00.00"), f.updt_id = reqinfo->updt_id,
        f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f
        .updt_applctx = reqinfo->updt_applctx,
        f.updt_cnt = 0
       PLAN (f)
       WITH nocounter
      ;end insert
    ENDFOR
   ENDIF
   FOR (x = 1 TO size(fld->fields,5))
     SET oe_field_value = 0.0
     SET oe_field_meaning_id = 0.0
     DECLARE default_name = vc
     SET default_id = 0.0
     SELECT INTO "nl:"
      FROM order_entry_fields o
      PLAN (o
       WHERE (o.oe_field_id=fld->fields[x].oe_field_id))
      DETAIL
       oe_field_meaning_id = o.oe_field_meaning_id
      WITH nocounter
     ;end select
     IF ((fld->fields[x].field_type_flag IN (0, 1, 2, 3, 5,
     7, 11, 14, 15)))
      SET default_name = " "
      SET default_id = 0
      IF ((fld->fields[x].field_type_flag=5))
       SET oe_field_value = - (99999)
      ELSEIF ((fld->fields[x].field_type_flag=7)
       AND (fld->fields[x].value="Yes"))
       SET oe_field_value = 1
      ELSE
       SET oe_field_value = cnvtreal(fld->fields[x].value)
      ENDIF
     ELSEIF ((fld->fields[x].field_type_flag IN (6, 9)))
      SET oe_field_value = 0.0
      SET default_name = "CODE_VALUE"
      SET default_id = fld->fields[x].code_value
     ELSEIF ((fld->fields[x].field_type_flag=12))
      SET oe_field_value = 0.0
      IF (oe_field_meaning_id=48)
       SET default__name = "RESEARCH_ACCOUNT"
      ELSEIF (oe_field_meaning_id=123)
       SET default_name = "SCH_BOOK_INSTR"
      ELSE
       SET default_name = "CODE_VALUE"
      ENDIF
      SET default_id = fld->fields[x].code_value
     ELSEIF ((fld->fields[x].field_type_flag IN (8, 13)))
      SET oe_field_value = 0.0
      SET default_name = "PERSON"
      SET default_id = fld->fields[x].code_value
     ELSEIF ((fld->fields[x].field_type_flag=10))
      SET oe_field_value = 0.0
      SET default_name = "NOMENCLATURE"
      SET default_id = fld->fields[x].code_value
     ENDIF
     INSERT  FROM order_sentence_detail o
      SET o.order_sentence_id = os_id, o.sequence = x, o.oe_field_value = oe_field_value,
       o.oe_field_id = fld->fields[x].oe_field_id, o.oe_field_display_value = fld->fields[x].value, o
       .oe_field_meaning_id = oe_field_meaning_id,
       o.field_type_flag = fld->fields[x].field_type_flag, o.updt_id = reqinfo->updt_id, o.updt_dt_tm
        = cnvtdatetime(curdate,curtime),
       o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0,
       o.default_parent_entity_name = default_name, o.default_parent_entity_id = default_id
      PLAN (o)
      WITH nocounter
     ;end insert
   ENDFOR
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
