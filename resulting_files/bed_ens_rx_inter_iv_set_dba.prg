CREATE PROGRAM bed_ens_rx_inter_iv_set:dba
 FREE SET reply
 RECORD reply(
   1 synonyms[*]
     2 id = f8
     2 duplicate_sentence_ind = i2
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
 SET syn_cnt = 0
 DECLARE syn_description = vc
 DECLARE inact_description = vc
 DECLARE catalog_type_cd = f8
 DECLARE activity_type_cd = f8
 DECLARE clin_cat_cd = f8
 DECLARE active_cd = f8
 DECLARE ord_cd = f8
 DECLARE primary_cd = f8
 DECLARE ord_action_cd = f8
 DECLARE ordsent_cd = f8
 DECLARE synonym_id = f8
 SET catalog_type_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET activity_type_cd = uar_get_code_by("MEANING",106,"PHARMACY")
 SET clin_cat_cd = uar_get_code_by("MEANING",16389,"IVSOLUTIONS")
 SET active_cd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET ord_cd = uar_get_code_by("MEANING",13016,"ORD CAT")
 SET primary_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET ord_action_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET ordsent_cd = uar_get_code_by("MEANING",30620,"ORDERSENT")
 SET syn_cnt = size(request->synonyms,5)
 SET stat = alterlist(reply->synonyms,syn_cnt)
 FOR (y = 1 TO syn_cnt)
   SET synonym_id = request->synonyms[y].id
   IF ((request->synonyms[y].action_flag=1))
    SET synonym_id = 0.0
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      synonym_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM order_catalog_synonym ocs
     SET ocs.synonym_id = synonym_id, ocs.catalog_cd = request->catalog_code_value, ocs
      .catalog_type_cd = catalog_type_cd,
      ocs.mnemonic = request->synonyms[y].name, ocs.mnemonic_key_cap = cnvtupper(request->synonyms[y]
       .name), ocs.mnemonic_type_cd = request->synonyms[y].type_code_value,
      ocs.oe_format_id = request->synonyms[y].format_id, ocs.active_ind = 1, ocs.activity_type_cd =
      activity_type_cd,
      ocs.activity_subtype_cd = 0, ocs.orderable_type_flag = 0, ocs.concentration_strength = null,
      ocs.concentration_volume = null, ocs.active_status_cd = active_cd, ocs.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      ocs.active_status_prsnl_id = reqinfo->updt_id, ocs.ref_text_mask = null, ocs
      .multiple_ord_sent_ind = null,
      ocs.hide_flag = 0, ocs.rx_mask = 4, ocs.dcp_clin_cat_cd = clin_cat_cd,
      ocs.filtered_od_ind = null, ocs.cki = null, ocs.mnemonic_key_cap_nls = null,
      ocs.virtual_view = " ", ocs.health_plan_view = null, ocs.concept_cki = null,
      ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = 0, ocs.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task
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
      SET ofr.synonym_id = synonym_id, ofr.facility_cd = 0.0, ofr.updt_applctx = reqinfo->
       updt_applctx,
       ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ofr.updt_id = reqinfo->
       updt_id,
       ofr.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
    ELSE
     FOR (x = 1 TO fcnt)
       INSERT  FROM ocs_facility_r ofr
        SET ofr.synonym_id = synonym_id, ofr.facility_cd = request->facilities[x].code_value, ofr
         .updt_applctx = reqinfo->updt_applctx,
         ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ofr.updt_id = reqinfo->
         updt_id,
         ofr.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
     ENDFOR
    ENDIF
    SET sequence = 0
    SELECT INTO "nl:"
     temp_seq = max(b.child_seq)
     FROM bill_item b,
      order_catalog_synonym o
     PLAN (o
      WHERE o.synonym_id=synonym_id)
      JOIN (b
      WHERE b.ext_child_reference_id=o.catalog_cd
       AND (b.ext_parent_reference_id=request->catalog_code_value))
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
      WHERE ocs.synonym_id=synonym_id)
     DETAIL
      catalog_code_value = ocs.catalog_cd, syn_description = ocs.mnemonic, syn_act_type = ocs
      .activity_type_cd
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
     SET b.bill_item_id = new_bill_id, b.ext_parent_reference_id = request->catalog_code_value, b
      .ext_parent_contributor_cd = ord_cd,
      b.ext_child_reference_id = request->catalog_code_value, b.ext_child_contributor_cd = ord_cd, b
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
        synonyms[y].id))," into the bill_item table.")
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
   IF ((request->synonyms[y].sentence.route > " "))
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=4001
       AND (c.display=request->synonyms[y].sentence.route))
     DETAIL
      route_cd = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   SET freq_cd = 0.0
   IF ((request->synonyms[y].sentence.frequency > " "))
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=4003
       AND (c.display=request->synonyms[y].sentence.frequency))
     DETAIL
      freq_cd = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   SET pr_cd = 0.0
   IF ((request->synonyms[y].sentence.prn_reason > " "))
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=4005
       AND (c.display=request->synonyms[y].sentence.prn_reason))
     DETAIL
      pr_cd = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   DECLARE dose_disp = vc
   IF ((request->synonyms[y].sentence.dose_unit_code_value > 0))
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=54
       AND (c.code_value=request->synonyms[y].sentence.dose_unit_code_value))
     DETAIL
      dose_disp = c.display
     WITH nocounter
    ;end select
   ENDIF
   SET format_id = 0.0
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs
    PLAN (ocs
     WHERE ocs.synonym_id=synonym_id)
    DETAIL
     format_id = ocs.oe_format_id
    WITH nocounter
   ;end select
   SET aa = 0
   SET cnt = 0
   SELECT INTO "nl:"
    FROM oe_format_fields off,
     order_entry_fields oef,
     oe_field_meaning oe
    PLAN (off
     WHERE off.oe_format_id=format_id
      AND off.action_type_cd=ord_action_cd
      AND off.accept_flag IN (0, 1))
     JOIN (oef
     WHERE oef.oe_field_id=off.oe_field_id)
     JOIN (oe
     WHERE oe.oe_field_meaning_id=oef.oe_field_meaning_id
      AND oe.oe_field_meaning IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT", "STRENGTHDOSE", "STRENGTHDOSEUNIT",
     "RXROUTE",
     "FREQ", "PRNREASON", "SCH/PRN"))
    ORDER BY off.group_seq, off.field_seq
    DETAIL
     IF ((request->synonyms[y].sentence.route > " ")
      AND oe.oe_field_meaning="RXROUTE")
      cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
      .oe_field_id,
      fld->fields[cnt].value = request->synonyms[y].sentence.route, fld->fields[cnt].code_value =
      route_cd, fld->fields[cnt].group_seq = off.group_seq,
      fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
      .field_type_flag
     ENDIF
     IF ((request->synonyms[y].sentence.frequency > " ")
      AND oe.oe_field_meaning="FREQ")
      cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
      .oe_field_id,
      fld->fields[cnt].value = request->synonyms[y].sentence.frequency, fld->fields[cnt].code_value
       = freq_cd, fld->fields[cnt].group_seq = off.group_seq,
      fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
      .field_type_flag
     ENDIF
     IF ((request->synonyms[y].sentence.prn > " ")
      AND oe.oe_field_meaning="SCH/PRN")
      cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
      .oe_field_id,
      fld->fields[cnt].value = request->synonyms[y].sentence.prn, fld->fields[cnt].code_value = 0,
      fld->fields[cnt].group_seq = off.group_seq,
      fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
      .field_type_flag
     ENDIF
     IF ((request->synonyms[y].sentence.prn_reason > " ")
      AND oe.oe_field_meaning="PRNREASON")
      cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
      .oe_field_id,
      fld->fields[cnt].value = request->synonyms[y].sentence.prn_reason, fld->fields[cnt].code_value
       = pr_cd, fld->fields[cnt].group_seq = off.group_seq,
      fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
      .field_type_flag
     ENDIF
     IF ((request->synonyms[y].sentence.strength_ind=1))
      IF ((request->synonyms[y].sentence.dose > 0)
       AND oe.oe_field_meaning="STRENGTHDOSE")
       cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
       .oe_field_id,
       fld->fields[cnt].value = build(request->synonyms[y].sentence.dose), aa = findstring(".",fld->
        fields[cnt].value), fld->fields[cnt].value = substring(1,(aa+ 3),fld->fields[cnt].value)
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
      IF ((request->synonyms[y].sentence.dose_unit_code_value > 0)
       AND oe.oe_field_meaning="STRENGTHDOSEUNIT")
       cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
       .oe_field_id,
       fld->fields[cnt].value = dose_disp, fld->fields[cnt].code_value = request->synonyms[y].
       sentence.dose_unit_code_value, fld->fields[cnt].group_seq = off.group_seq,
       fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
       .field_type_flag
      ENDIF
     ENDIF
     IF ((request->synonyms[y].sentence.volume_ind=1))
      IF ((request->synonyms[y].sentence.dose > 0)
       AND oe.oe_field_meaning="VOLUMEDOSE")
       cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
       .oe_field_id,
       fld->fields[cnt].value = build(request->synonyms[y].sentence.dose), aa = findstring(".",fld->
        fields[cnt].value), fld->fields[cnt].value = substring(1,(aa+ 3),fld->fields[cnt].value)
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
      IF ((request->synonyms[y].sentence.dose_unit_code_value > 0)
       AND oe.oe_field_meaning="VOLUMEDOSEUNIT")
       cnt = (cnt+ 1), stat = alterlist(fld->fields,cnt), fld->fields[cnt].oe_field_id = off
       .oe_field_id,
       fld->fields[cnt].value = dose_disp, fld->fields[cnt].code_value = request->synonyms[y].
       sentence.dose_unit_code_value, fld->fields[cnt].group_seq = off.group_seq,
       fld->fields[cnt].field_seq = off.field_seq, fld->fields[cnt].field_type_flag = oef
       .field_type_flag
      ENDIF
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
   IF ((request->synonyms[y].sentence.comment > " "))
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
   SELECT INTO "nl:"
    FROM ord_cat_sent_r o,
     filter_entity_reltn f
    PLAN (o
     WHERE o.synonym_id=synonym_id
      AND o.order_sentence_disp_line=order_sentence
      AND o.active_ind=1)
     JOIN (f
     WHERE f.parent_entity_name="ORDER_SENTENCE"
      AND f.parent_entity_id=o.order_sentence_id
      AND f.filter_entity1_name="LOCATION")
    DETAIL
     IF (size(request->facilities,5)=0)
      IF (f.filter_entity1_id=0)
       reply->synonyms[y].duplicate_sentence_ind = 1
      ENDIF
     ENDIF
     FOR (z = 1 TO size(request->facilities,5))
       IF ((((f.filter_entity1_id=request->facilities[z].code_value)) OR (f.filter_entity1_id=0)) )
        reply->synonyms[y].duplicate_sentence_ind = 1
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF ((reply->synonyms[y].duplicate_sentence_ind=0))
    INSERT  FROM ord_cat_sent_r o
     SET o.order_cat_sent_r_id = seq(reference_seq,nextval), o.order_sentence_id = os_id, o
      .order_sentence_disp_line = order_sentence,
      o.catalog_cd = request->catalog_code_value, o.synonym_id = synonym_id, o.active_ind = 1,
      o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
      reqinfo->updt_task,
      o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.display_seq = null
     PLAN (o)
     WITH nocounter
    ;end insert
    INSERT  FROM order_sentence o
     SET o.order_sentence_id = os_id, o.order_sentence_display_line = order_sentence, o.oe_format_id
       = format_id,
      o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
      reqinfo->updt_task,
      o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.usage_flag = 1,
      o.order_encntr_group_cd = 0, o.ord_comment_long_text_id = lt_id, o.parent_entity_name =
      "ORDER_CATALOG_SYNONYM",
      o.parent_entity_id = synonym_id, o.parent_entity2_name = "ORDER_CATALOG", o.parent_entity2_id
       = request->catalog_code_value,
      o.ic_auto_verify_flag = 0, o.discern_auto_verify_flag = 0, o.external_identifier = null
     PLAN (o)
     WITH nocounter
    ;end insert
    IF ((request->synonyms[y].sentence.comment > " "))
     INSERT  FROM long_text l
      SET l.long_text_id = lt_id, l.updt_id = reqinfo->updt_id, l.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0,
       l.active_ind = 1, l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
        curtime),
       l.active_status_prsnl_id = reqinfo->updt_id, l.parent_entity_name = "ORDER_SENTENCE", l
       .parent_entity_id = os_id,
       l.long_text = request->synonyms[y].sentence.comment
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
        o.oe_field_id = fld->fields[x].oe_field_id, o.oe_field_display_value = fld->fields[x].value,
        o.oe_field_meaning_id = oe_field_meaning_id,
        o.field_type_flag = fld->fields[x].field_type_flag, o.updt_id = reqinfo->updt_id, o
        .updt_dt_tm = cnvtdatetime(curdate,curtime),
        o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0,
        o.default_parent_entity_name = default_name, o.default_parent_entity_id = default_id
       PLAN (o)
       WITH nocounter
      ;end insert
    ENDFOR
    SET sent_id = 0.0
    SET mcnt = 0
    SELECT INTO "nl:"
     FROM ord_cat_sent_r o
     PLAN (o
      WHERE o.synonym_id=synonym_id)
     DETAIL
      mcnt = (mcnt+ 1), sent_id = o.order_sentence_id
     WITH nocounter
    ;end select
    IF (mcnt=1)
     UPDATE  FROM order_catalog_synonym o
      SET o.multiple_ord_sent_ind = 0, o.order_sentence_id = sent_id, o.updt_id = reqinfo->updt_id,
       o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx
        = reqinfo->updt_applctx,
       o.updt_cnt = (o.updt_cnt+ 1)
      PLAN (o
       WHERE o.synonym_id=synonym_id)
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM order_catalog_synonym o
      SET o.multiple_ord_sent_ind = 1, o.order_sentence_id = 0, o.updt_id = reqinfo->updt_id,
       o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx
        = reqinfo->updt_applctx,
       o.updt_cnt = (o.updt_cnt+ 1)
      PLAN (o
       WHERE o.synonym_id=synonym_id)
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
   SET reply->synonyms[y].id = synonym_id
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
