CREATE PROGRAM dcp_get_missing_required_ind_r:dba
 SET query_missing_required_reply->status = "F"
 SET query_missing_required_reply->status_description =
 "Readme failed in starting the script dcp_get_missing_required_ind_r.prg"
 DECLARE request_count = i4 WITH protect, constant(size(query_missing_required_request->list,5))
 IF (request_count < 1)
  SET query_missing_required_reply->status = "Z"
  SET query_missing_required_reply->status_description = "No rows to be updated"
  GO TO exit_script
 ENDIF
 FREE RECORD data
 RECORD data(
   1 order_sentence_list[*]
     2 component_count = i4
     2 component_list[*]
       3 pathway_comp_id = f8
     2 order_sentence_id = f8
     2 oe_format_idx = i4
     2 action_type_idx = i4
     2 iv_set_idx = i4
     2 iv_component_idx = i4
     2 timed_priority_idx = i4
     2 missing_required_ind = i2
     2 iv_ind = i2
     2 diluent_ind = i2
     2 additive_ind = i2
     2 medication_ind = i2
     2 rx_ind = i2
     2 normalized_dose_unit_ind = i2
     2 has_strength_dose_ind = i2
     2 has_strength_dose_unit_ind = i2
     2 has_volume_dose_ind = i2
     2 has_volume_dose_unit_ind = i2
     2 has_freetext_rate_ind = i2
     2 has_infuse_over_ind = i2
     2 has_infuse_over_unit_ind = i2
     2 has_weight_ind = i2
     2 has_weight_unit_ind = i2
     2 has_rate_ind = i2
     2 has_rate_unit_ind = i2
     2 has_normalized_rate_ind = i2
     2 has_normalized_rate_unit_ind = i2
     2 has_freetext_dose_ind = i2
     2 has_timed_priority_ind = i2
     2 has_duration_ind = i2
     2 has_duration_unit_ind = i2
     2 has_sch_prn_ind = i2
     2 has_prn_reason_ind = i2
     2 has_prn_instructions_ind = i2
     2 accept_flag_prn_reason = i2
     2 accept_flag_prn_instructions = i2
     2 field_count = i4
     2 field_list[*]
       3 oe_field_id = f8
   1 oe_format_list[*]
     2 oe_format_id = f8
     2 action_type_list[*]
       3 action_type_cd = f8
       3 has_sch_prn_ind = i2
       3 has_prn_reason_ind = i2
       3 has_prn_instructions_ind = i2
       3 accept_flag_sch_prn = i2
       3 accept_flag_prn_reason = i2
       3 accept_flag_prn_instructions = i2
       3 required_field_count = i4
       3 required_field_list[*]
         4 oe_field_id = f8
         4 oe_field_meaning_id = f8
   1 timed_priority_list[*]
     2 oe_format_id = f8
     2 priority_count = i4
     2 priority_list[*]
       3 priority_cd = f8
   1 timed_collection_priority_list[*]
     2 collection_priority_cd = f8
     2 order_sentence_count = i4
     2 order_sentence_list[*]
       3 order_sentence_idx = i4
   1 iv_set_list[*]
     2 synonym_id = f8
     2 pathway_comp_id = f8
     2 diluent_idx = i4
     2 has_normalized_additive_ind = i2
     2 iv_component_count = i4
     2 iv_component_list[*]
       3 iv_comp_syn_id = f8
       3 order_sentence_idx = i4
   1 query_oe_format_list[*]
     2 oe_format_id = f8
     2 action_type_cd = f8
 )
 DECLARE i_stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE lfindindex = i4 WITH protect, noconstant(0)
 DECLARE bfoundfield = i2 WITH protect, noconstant(0)
 DECLARE catalog_type_cs = i4 WITH protect, constant(6000)
 DECLARE catalog_type_cd_pharmacy = f8 WITH protect, noconstant(0.00)
 DECLARE action_type_cs = i4 WITH protect, constant(6003)
 DECLARE action_type_cd_order = f8 WITH protect, noconstant(0.00)
 DECLARE action_type_cd_disorder = f8 WITH protect, noconstant(0.00)
 DECLARE comp_type_cs = i4 WITH protect, constant(16750)
 DECLARE comp_type_cd_order = f8 WITH protect, noconstant(0.00)
 DECLARE comp_type_cd_prescription = f8 WITH protect, noconstant(0.00)
 DECLARE oe_field_meaning_strengthdose = f8 WITH protect, constant(2056.00)
 DECLARE oe_field_meaning_strengthdoseunit = f8 WITH protect, constant(2057.00)
 DECLARE oe_field_meaning_volumedose = f8 WITH protect, constant(2058.00)
 DECLARE oe_field_meaning_volumedoseunit = f8 WITH protect, constant(2059.00)
 DECLARE oe_field_meaning_freetextrate = f8 WITH protect, constant(2104.00)
 DECLARE oe_field_meaning_infuseover = f8 WITH protect, constant(118.00)
 DECLARE oe_field_meaning_infuseoverunit = f8 WITH protect, constant(2064.00)
 DECLARE oe_field_meaning_rate = f8 WITH protect, constant(2043.00)
 DECLARE oe_field_meaning_rateunit = f8 WITH protect, constant(2044.00)
 DECLARE oe_field_meaning_normalizedrate = f8 WITH protect, constant(2393.00)
 DECLARE oe_field_meaning_normalizedrateunit = f8 WITH protect, constant(2394.00)
 DECLARE oe_field_meaning_freetxtdose = f8 WITH protect, constant(2063.00)
 DECLARE oe_field_meaning_priority = f8 WITH protect, constant(127.00)
 DECLARE oe_field_meaning_collpri = f8 WITH protect, constant(43.00)
 DECLARE oe_field_meaning_duration = f8 WITH protect, constant(2061.00)
 DECLARE oe_field_meaning_durationunit = f8 WITH protect, constant(2062.00)
 DECLARE oe_field_meaning_prninstructions = f8 WITH protect, constant(2101.00)
 DECLARE oe_field_meaning_prnreason = f8 WITH protect, constant(142.00)
 DECLARE oe_field_meaning_sch_prn = f8 WITH protect, constant(2037.00)
 DECLARE oe_field_meaning_sampleqty = f8 WITH protect, constant(2019.00)
 DECLARE oe_field_meaning_samplesgiven = f8 WITH protect, constant(2018.00)
 DECLARE oe_field_meaning_refillqty = f8 WITH protect, constant(2016.00)
 DECLARE oe_field_meaning_refillsremaining = f8 WITH protect, constant(1551.00)
 DECLARE oe_field_meaning_totalrefills = f8 WITH protect, constant(1558.00)
 DECLARE oe_field_meaning_additionalrefills = f8 WITH protect, constant(1557.00)
 DECLARE oe_field_meaning_nbrrefills = f8 WITH protect, constant(67.00)
 DECLARE oe_field_meaning_rxtransrefillqty = f8 WITH protect, constant(2273.00)
 DECLARE oe_field_meaning_rxtransrefillsremain = f8 WITH protect, constant(2274.00)
 DECLARE oe_field_meaning_rxtranstotalrefills = f8 WITH protect, constant(2272.00)
 DECLARE oe_field_meaning_other = f8 WITH protect, constant(9000.00)
 DECLARE oe_field_type_date = i2 WITH protect, constant(3)
 DECLARE oe_field_type_date_time = i2 WITH protect, constant(5)
 DECLARE accept_flag_empty = i2 WITH protect, constant(- (1))
 DECLARE accept_flag_required = i2 WITH protect, constant(0)
 DECLARE accept_flag_optional = i2 WITH protect, constant(1)
 DECLARE accept_flag_no_display = i2 WITH protect, constant(2)
 DECLARE accept_flag_display_only = i2 WITH protect, constant(3)
 DECLARE idurationacceptflag = i2 WITH protect, noconstant(0)
 DECLARE idurationunitacceptflag = i2 WITH protect, noconstant(0)
 DECLARE iprnindacceptflag = i2 WITH protect, noconstant(0)
 DECLARE iprnreasonacceptflag = i2 WITH protect, noconstant(0)
 DECLARE iprninstructionsacceptflag = i2 WITH protect, noconstant(0)
 DECLARE ihighestpriorityacceptflag = i2 WITH protect, noconstant(0)
 DECLARE boshasprnreason = i2 WITH protect, noconstant(0)
 DECLARE boshasprninstructions = i2 WITH protect, noconstant(0)
 DECLARE bprnindexistsonformat = i2 WITH protect, noconstant(0)
 DECLARE bprnreasonexistsonformat = i2 WITH protect, noconstant(0)
 DECLARE bprninstructionsexistsonformat = i2 WITH protect, noconstant(0)
 DECLARE bprnreasonneeded = i2 WITH protect, noconstant(0)
 DECLARE bprninstructionsneeded = i2 WITH protect, noconstant(0)
 DECLARE lreplycount = i4 WITH protect, noconstant(0)
 DECLARE lreplysize = i4 WITH protect, noconstant(0)
 DECLARE lreplybatchsize = i4 WITH protect, noconstant(10)
 DECLARE loeformatindex = i4 WITH protect, noconstant(0)
 DECLARE loeformatcount = i4 WITH protect, noconstant(0)
 DECLARE loeformatsize = i4 WITH protect, noconstant(0)
 DECLARE loeformatbatchsize = i4 WITH protect, noconstant(20)
 DECLARE lactiontypeindex = i4 WITH protect, noconstant(0)
 DECLARE lactiontypecount = i4 WITH protect, noconstant(0)
 DECLARE lactiontypesize = i4 WITH protect, noconstant(0)
 DECLARE lactiontypebatchsize = i4 WITH protect, noconstant(2)
 DECLARE loefieldcount = i4 WITH protect, noconstant(0)
 DECLARE loefieldsize = i4 WITH protect, noconstant(0)
 DECLARE loefieldbatchsize = i4 WITH protect, noconstant(10)
 DECLARE ltimedpriorityindex = i4 WITH protect, noconstant(0)
 DECLARE ltimedprioritycount = i4 WITH protect, noconstant(0)
 DECLARE ltimedprioritysize = i4 WITH protect, noconstant(0)
 DECLARE ltimedprioritybatchsize = i4 WITH protect, noconstant(20)
 DECLARE lpriorityindex = i4 WITH protect, noconstant(0)
 DECLARE lprioritycount = i4 WITH protect, noconstant(0)
 DECLARE lprioritysize = i4 WITH protect, noconstant(0)
 DECLARE lprioritybatchsize = i4 WITH protect, noconstant(20)
 DECLARE ltimedcollectionpriorityindex = i4 WITH protect, noconstant(0)
 DECLARE ltimedcollectionprioritycount = i4 WITH protect, noconstant(0)
 DECLARE ltimedcollectionprioritysize = i4 WITH protect, noconstant(0)
 DECLARE ltimedcollectionprioritybatchsize = i4 WITH protect, noconstant(20)
 DECLARE lqueryoeformatindex = i4 WITH protect, noconstant(0)
 DECLARE lqueryoeformatcount = i4 WITH protect, noconstant(0)
 DECLARE lqueryoeformatsize = i4 WITH protect, noconstant(0)
 DECLARE lqueryoeformatbatchsize = i4 WITH protect, noconstant(10)
 DECLARE lordersentenceindex = i4 WITH protect, noconstant(0)
 DECLARE lordersentencecount = i4 WITH protect, noconstant(0)
 DECLARE lordersentencesize = i4 WITH protect, noconstant(0)
 DECLARE lordersentencebatchsize = i4 WITH protect, noconstant(20)
 DECLARE lcomponentindex = i4 WITH protect, noconstant(0)
 DECLARE lcomponentcount = i4 WITH protect, noconstant(0)
 DECLARE lcomponentsize = i4 WITH protect, noconstant(0)
 DECLARE lcomponentbatchsize = i4 WITH protect, noconstant(5)
 DECLARE losfieldcount = i4 WITH protect, noconstant(0)
 DECLARE losfieldsize = i4 WITH protect, noconstant(0)
 DECLARE losfieldbatchsize = i4 WITH protect, noconstant(10)
 DECLARE livsetindex = i4 WITH protect, noconstant(0)
 DECLARE livsetcount = i4 WITH protect, noconstant(0)
 DECLARE livsetsize = i4 WITH protect, noconstant(0)
 DECLARE livsetbatchsize = i4 WITH protect, noconstant(20)
 DECLARE livcomponentindex = i4 WITH protect, noconstant(0)
 DECLARE livcomponentcount = i4 WITH protect, noconstant(0)
 DECLARE livcomponentsize = i4 WITH protect, noconstant(0)
 DECLARE livcomponentbatchsize = i4 WITH protect, noconstant(10)
 DECLARE lrequiredfieldindex = i4 WITH protect, noconstant(0)
 DECLARE lrequiredfieldcount = i4 WITH protect, noconstant(0)
 DECLARE lrequiredfieldsize = i4 WITH protect, noconstant(0)
 DECLARE lordersentencefieldindex = i4 WITH protect, noconstant(0)
 DECLARE lordersentencefieldcount = i4 WITH protect, noconstant(0)
 DECLARE lordersentencefieldsize = i4 WITH protect, noconstant(0)
 DECLARE bvalidcomponenttype = i2 WITH protect, noconstant(0)
 DECLARE biscomptypeprescription = i2 WITH protect, noconstant(0)
 DECLARE baddedivsetdata = i2 WITH protect, noconstant(0)
 DECLARE bhasvalueind = i2 WITH protect, noconstant(0)
 DECLARE bhastextind = i2 WITH protect, noconstant(0)
 DECLARE dcatalogtypecd = f8 WITH protect, noconstant(0.00)
 DECLARE divcomponentsynonymid = f8 WITH protect, noconstant(0.00)
 DECLARE drequiredoefieldid = f8 WITH protect, noconstant(0.00)
 DECLARE dordersentenceoefieldid = f8 WITH protect, noconstant(0.00)
 DECLARE drequiredoefieldmeaningid = f8 WITH protect, noconstant(0.00)
 DECLARE dsynonymid = f8 WITH protect, noconstant(0.00)
 DECLARE dcollectionprioritycd = f8 WITH protect, noconstant(0.00)
 DECLARE l_diluent_order_sentence_idx = i4 WITH protect, noconstant(0)
 DECLARE err_msg = vc
 DECLARE err_code = i4 WITH protect, noconstant(0)
 DECLARE hasdosefilledout(l_order_sentence_idx=i4) = i2
 DECLARE hasinfuseoverfilledout(l_diluent_order_sentence_idx=i4) = i2
 DECLARE hasratefilledout(l_diluent_order_sentence_idx=i4) = i2
 DECLARE getdiluentmissingrequiredind(l_order_sentence_idx=i4) = i2
 DECLARE getadditivemissingrequiredind(l_order_sentence_idx=i4) = i2
 DECLARE getmedicationmissingrequiredind(l_order_sentence_idx=i4) = i2
 DECLARE getdurationmissingrequiredind(l_order_sentence_idx=i4,loeformatindex=i4,lactiontypeindex=i4)
  = i2
 DECLARE getprnmissingrequiredind(l_order_sentence_idx=i4,loeformatindex=i4,lactiontypeindex=i4) = i2
 DECLARE getmissingrequiredfields(l_order_sentence_idx=i4) = i2
 DECLARE catcherrors(s_description=vc) = null
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=catalog_type_cs
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   catalog_type_cd_pharmacy = cv.code_value
  WITH nocounter
 ;end select
 IF (catalog_type_cd_pharmacy <= 0.0)
  SET query_missing_required_reply->status = "F"
  SET query_missing_required_reply->status_description = concat(
   "Readme failed as it could not find code value for code set ",build(catalog_type_cs))
  GO TO exit_script
 ENDIF
 CALL catcherrors("DCP_GET_MISSING_REQUIRED_IND_R 02 - Get code values")
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=action_type_cs
   AND cv.cdf_meaning IN ("ORDER", "DISORDER")
   AND cv.active_ind=1
  DETAIL
   CASE (cv.cdf_meaning)
    OF "ORDER":
     action_type_cd_order = cv.code_value
    OF "DISORDER":
     action_type_cd_disorder = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (((action_type_cd_order <= 0.0) OR (action_type_cd_disorder <= 0.0)) )
  SET query_missing_required_reply->status = "F"
  SET query_missing_required_reply->status_description = concat(
   "Readme failed as it could not find code value for code set ",build(action_type_cs))
  GO TO exit_script
 ENDIF
 CALL catcherrors("DCP_GET_MISSING_REQUIRED_IND_R 02 - Get code values")
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=comp_type_cs
   AND cv.cdf_meaning IN ("ORDER CREATE", "PRESCRIPTION")
   AND cv.active_ind=1
  DETAIL
   CASE (cv.cdf_meaning)
    OF "ORDER CREATE":
     comp_type_cd_order = cv.code_value
    OF "PRESCRIPTION":
     comp_type_cd_prescription = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (((comp_type_cd_order <= 0.0) OR (comp_type_cd_prescription <= 0.0)) )
  SET query_missing_required_reply->status = "F"
  SET query_missing_required_reply->status_description = concat(
   "Readme failed as it could not find code value for code set ",build(comp_type_cs))
  GO TO exit_script
 ENDIF
 CALL catcherrors("DCP_GET_MISSING_REQUIRED_IND_R 02 - Get code values")
 SELECT INTO "nl:"
  oefp.oe_format_id, pwc.comp_type_cd, pcor.order_sentence_id,
  pwc.pathway_comp_id, pwc.parent_entity_id
  FROM (dummyt d1  WITH seq = value(request_count)),
   pathway_comp pwc,
   pw_comp_os_reltn pcor,
   order_sentence os,
   order_entry_format_parent oefp
  PLAN (d1)
   JOIN (pwc
   WHERE (pwc.pathway_comp_id=query_missing_required_request->list[d1.seq].pathway_comp_id))
   JOIN (pcor
   WHERE pcor.pathway_comp_id=pwc.pathway_comp_id
    AND pcor.pathway_comp_id > 0.0
    AND pcor.order_sentence_id > 0.0)
   JOIN (os
   WHERE os.order_sentence_id=pcor.order_sentence_id
    AND os.oe_format_id > 0.0)
   JOIN (oefp
   WHERE oefp.oe_format_id=os.oe_format_id)
  ORDER BY oefp.oe_format_id, pwc.comp_type_cd, pcor.order_sentence_id,
   pwc.pathway_comp_id
  HEAD oefp.oe_format_id
   dcatalogtypecd = oefp.catalog_type_cd, lactiontypecount = 0, lactiontypesize = 0,
   loeformatcount = (loeformatcount+ 1)
   IF (loeformatsize < loeformatcount)
    loeformatsize = (loeformatsize+ loeformatbatchsize), i_stat = alterlist(data->oe_format_list,
     loeformatsize)
   ENDIF
   data->oe_format_list[loeformatcount].oe_format_id = oefp.oe_format_id, ltimedprioritycount = (
   ltimedprioritycount+ 1)
   IF (ltimedprioritysize < ltimedprioritycount)
    ltimedprioritysize = (ltimedprioritysize+ ltimedprioritybatchsize), i_stat = alterlist(data->
     timed_priority_list,ltimedprioritysize)
   ENDIF
   data->timed_priority_list[ltimedprioritycount].oe_format_id = oefp.oe_format_id
  HEAD pwc.comp_type_cd
   bvalidcomponenttype = 0, biscomptypeprescription = 0
   IF (pwc.comp_type_cd=comp_type_cd_prescription)
    bvalidcomponenttype = 1, biscomptypeprescription = 1
   ELSEIF (pwc.comp_type_cd=comp_type_cd_order)
    bvalidcomponenttype = 1
   ENDIF
   IF (bvalidcomponenttype=1)
    lactiontypecount = (lactiontypecount+ 1)
    IF (lactiontypesize < lactiontypecount)
     lactiontypesize = (lactiontypesize+ lactiontypebatchsize), i_stat = alterlist(data->
      oe_format_list[loeformatcount].action_type_list,lactiontypesize)
    ENDIF
    IF (biscomptypeprescription=1)
     data->oe_format_list[loeformatcount].action_type_list[lactiontypecount].action_type_cd =
     action_type_cd_disorder
    ELSE
     data->oe_format_list[loeformatcount].action_type_list[lactiontypecount].action_type_cd =
     action_type_cd_order
    ENDIF
    lqueryoeformatcount = (lqueryoeformatcount+ 1)
    IF (lqueryoeformatsize < lqueryoeformatcount)
     lqueryoeformatsize = (lqueryoeformatsize+ lqueryoeformatbatchsize), i_stat = alterlist(data->
      query_oe_format_list,lqueryoeformatsize)
    ENDIF
    data->query_oe_format_list[lqueryoeformatcount].oe_format_id = data->oe_format_list[
    loeformatcount].oe_format_id, data->query_oe_format_list[lqueryoeformatcount].action_type_cd =
    data->oe_format_list[loeformatcount].action_type_list[lactiontypecount].action_type_cd
   ENDIF
  HEAD pcor.order_sentence_id
   livsetindex = 0, livcomponentcount = 0, livcomponentsize = 0,
   lcomponentcount = 0, lcomponentsize = 0, lordersentencecount = (lordersentencecount+ 1)
   IF (lordersentencesize < lordersentencecount)
    lordersentencesize = (lordersentencesize+ lordersentencebatchsize), i_stat = alterlist(data->
     order_sentence_list,lordersentencesize)
   ENDIF
   data->order_sentence_list[lordersentencecount].order_sentence_id = pcor.order_sentence_id, data->
   order_sentence_list[lordersentencecount].oe_format_idx = loeformatcount, data->
   order_sentence_list[lordersentencecount].action_type_idx = lactiontypecount,
   data->order_sentence_list[lordersentencecount].normalized_dose_unit_ind = pcor
   .normalized_dose_unit_ind, data->order_sentence_list[lordersentencecount].timed_priority_idx =
   ltimedprioritycount, data->order_sentence_list[lordersentencecount].rx_ind =
   biscomptypeprescription
   IF (dcatalogtypecd=catalog_type_cd_pharmacy)
    data->order_sentence_list[lordersentencecount].medication_ind = 1
   ENDIF
   divcomponentsynonymid = pcor.iv_comp_syn_id
   IF (divcomponentsynonymid > 0.0)
    IF (livsetindex=0
     AND livsetcount > 0)
     lfindindex = 1, livsetindex = 0
     WHILE (livsetindex=0
      AND lfindindex <= livsetcount)
      IF ((data->iv_set_list[lfindindex].pathway_comp_id=pcor.pathway_comp_id))
       livsetindex = lfindindex
      ENDIF
      ,lfindindex = (lfindindex+ 1)
     ENDWHILE
    ENDIF
    IF (livsetindex=0)
     livsetcount = (livsetcount+ 1), livsetindex = livsetcount
     IF (livsetsize < livsetcount)
      livsetsize = (livsetsize+ livsetbatchsize), i_stat = alterlist(data->iv_set_list,livsetsize)
     ENDIF
     data->iv_set_list[livsetcount].pathway_comp_id = pcor.pathway_comp_id, data->iv_set_list[
     livsetcount].synonym_id = pwc.parent_entity_id
    ENDIF
    data->order_sentence_list[lordersentencecount].iv_ind = 1, data->order_sentence_list[
    lordersentencecount].iv_set_idx = livsetindex, livcomponentcount = data->iv_set_list[livsetindex]
    .iv_component_count,
    livcomponentcount = (livcomponentcount+ 1), data->iv_set_list[livsetindex].iv_component_count =
    livcomponentcount, i_stat = alterlist(data->iv_set_list[livsetindex].iv_component_list,
     livcomponentcount),
    data->iv_set_list[livsetindex].iv_component_list[livcomponentcount].order_sentence_idx =
    lordersentencecount, data->iv_set_list[livsetindex].iv_component_list[livcomponentcount].
    iv_comp_syn_id = divcomponentsynonymid, data->order_sentence_list[lordersentencecount].
    additive_ind = 1,
    data->order_sentence_list[lordersentencecount].iv_component_idx = livcomponentcount
   ENDIF
  HEAD pwc.pathway_comp_id
   lcomponentcount = (lcomponentcount+ 1)
   IF (lcomponentsize < lcomponentcount)
    lcomponentsize = (lcomponentsize+ lcomponentbatchsize), i_stat = alterlist(data->
     order_sentence_list[lordersentencecount].component_list,lcomponentsize)
   ENDIF
   data->order_sentence_list[lordersentencecount].component_list[lcomponentcount].pathway_comp_id =
   pwc.pathway_comp_id
  DETAIL
   dummy = 0
  FOOT  pcor.order_sentence_id
   IF (lcomponentcount > 0
    AND lordersentencecount > 0)
    data->order_sentence_list[lordersentencecount].component_count = lcomponentcount
    IF (lcomponentcount < lcomponentsize)
     i_stat = alterlist(data->order_sentence_list[lordersentencecount].component_list,lcomponentcount
      )
    ENDIF
   ENDIF
  FOOT  oefp.oe_format_id
   IF (loeformatcount > 0
    AND lactiontypecount > 0
    AND lactiontypecount < lactiontypesize)
    i_stat = alterlist(data->oe_format_list[loeformatcount].action_type_list,lactiontypecount)
   ENDIF
  FOOT REPORT
   IF (loeformatcount > 0
    AND loeformatcount < loeformatsize)
    i_stat = alterlist(data->oe_format_list,loeformatcount)
   ENDIF
   IF (ltimedprioritycount > 0
    AND ltimedprioritycount < ltimedprioritysize)
    i_stat = alterlist(data->timed_priority_list,ltimedprioritycount)
   ENDIF
   IF (lqueryoeformatcount > 0
    AND lqueryoeformatcount < lqueryoeformatsize)
    i_stat = alterlist(data->query_oe_format_list,lqueryoeformatcount)
   ENDIF
   IF (lordersentencecount > 0
    AND lordersentencecount < lordersentencesize)
    i_stat = alterlist(data->order_sentence_list,lordersentencecount)
   ENDIF
   IF (livsetcount > 0
    AND livsetcount < livsetsize)
    i_stat = alterlist(data->iv_set_list,livsetcount)
   ENDIF
  WITH nocounter
 ;end select
 CALL catcherrors("DCP_GET_MISSING_REQUIRED_IND_R 03 - Get component order sentence information")
 IF (((loeformatcount < 1) OR (((lqueryoeformatcount < 1) OR (lordersentencecount < 1)) )) )
  SET query_missing_required_reply->status = "Z"
  SET query_missing_required_reply->status_description = "No rows to be updated"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  oeff.oe_format_id, oeff.action_type_cd, oeff.oe_field_id
  FROM (dummyt d1  WITH seq = value(lqueryoeformatcount)),
   oe_format_fields oeff,
   order_entry_fields oef
  PLAN (d1)
   JOIN (oeff
   WHERE (oeff.oe_format_id=data->query_oe_format_list[d1.seq].oe_format_id)
    AND (oeff.action_type_cd=data->query_oe_format_list[d1.seq].action_type_cd))
   JOIN (oef
   WHERE oef.oe_field_id=oeff.oe_field_id
    AND  NOT (oef.field_type_flag IN (oe_field_type_date, oe_field_type_date_time)))
  ORDER BY oeff.oe_format_id, oeff.action_type_cd, oeff.oe_field_id
  HEAD oeff.oe_format_id
   lfindindex = 1, loeformatindex = 0, doeformatid = oeff.oe_format_id
   WHILE (loeformatindex=0
    AND lfindindex <= loeformatcount)
    IF ((data->oe_format_list[lfindindex].oe_format_id=doeformatid))
     loeformatindex = lfindindex
    ENDIF
    ,lfindindex = (lfindindex+ 1)
   ENDWHILE
  HEAD oeff.action_type_cd
   lactiontypeindex = 0, loefieldcount = 0, loefieldsize = 0
   IF (loeformatindex > 0)
    lactiontypecount = size(data->oe_format_list[loeformatindex].action_type_list,5)
    IF (lactiontypecount > 0)
     lfindindex = 1, lactiontypeindex = 0, dactiontypecd = oeff.action_type_cd
     WHILE (lactiontypeindex=0
      AND lfindindex <= lactiontypecount)
      IF ((data->oe_format_list[loeformatindex].action_type_list[lfindindex].action_type_cd=
      dactiontypecd))
       lactiontypeindex = lfindindex
      ENDIF
      ,lfindindex = (lfindindex+ 1)
     ENDWHILE
    ENDIF
   ENDIF
  DETAIL
   IF (lactiontypeindex > 0)
    iacceptflag = oeff.accept_flag, doefieldmeaningid = oef.oe_field_meaning_id
    IF (iacceptflag=0)
     loefieldcount = (loefieldcount+ 1)
     IF (loefieldsize < loefieldcount)
      loefieldsize = (loefieldsize+ loefieldbatchsize), i_stat = alterlist(data->oe_format_list[
       loeformatindex].action_type_list[lactiontypeindex].required_field_list,loefieldsize)
     ENDIF
     data->oe_format_list[loeformatindex].action_type_list[lactiontypeindex].required_field_list[
     loefieldcount].oe_field_id = oeff.oe_field_id, data->oe_format_list[loeformatindex].
     action_type_list[lactiontypeindex].required_field_list[loefieldcount].oe_field_meaning_id =
     doefieldmeaningid
    ENDIF
    IF (doefieldmeaningid=oe_field_meaning_prninstructions)
     data->oe_format_list[loeformatindex].action_type_list[lactiontypeindex].has_prn_instructions_ind
      = 1, data->oe_format_list[loeformatindex].action_type_list[lactiontypeindex].
     accept_flag_prn_instructions = iacceptflag
    ELSEIF (doefieldmeaningid=oe_field_meaning_prnreason)
     data->oe_format_list[loeformatindex].action_type_list[lactiontypeindex].has_prn_reason_ind = 1,
     data->oe_format_list[loeformatindex].action_type_list[lactiontypeindex].accept_flag_prn_reason
      = iacceptflag
    ELSEIF (doefieldmeaningid=oe_field_meaning_sch_prn)
     data->oe_format_list[loeformatindex].action_type_list[lactiontypeindex].has_sch_prn_ind = 1,
     data->oe_format_list[loeformatindex].action_type_list[lactiontypeindex].accept_flag_sch_prn =
     iacceptflag
    ENDIF
   ENDIF
  FOOT  oeff.action_type_cd
   IF (loefieldcount > 0)
    data->oe_format_list[loeformatindex].action_type_list[lactiontypeindex].required_field_count =
    loefieldcount
    IF (loefieldcount < loefieldsize)
     i_stat = alterlist(data->oe_format_list[loeformatindex].action_type_list[lactiontypeindex].
      required_field_list,loefieldcount)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL catcherrors("DCP_GET_MISSING_REQUIRED_IND_R 05 - Get order format fields")
 IF (ltimedprioritycount > 0)
  SELECT INTO "nl:"
   opf.oe_format_id, opf.priority_cd
   FROM (dummyt d1  WITH seq = value(ltimedprioritycount)),
    order_priority_flexing opf
   PLAN (d1)
    JOIN (opf
    WHERE opf.order_priority_flexing_id > 0.0
     AND (opf.oe_format_id=data->timed_priority_list[d1.seq].oe_format_id)
     AND opf.active_ind=1
     AND opf.default_start_dt_tm=";")
   ORDER BY opf.oe_format_id, opf.priority_cd
   HEAD opf.oe_format_id
    lprioritycount = 0, lprioritysize = 0, lfindindex = 1,
    ltimedpriorityindex = 0, doeformatid = opf.oe_format_id
    WHILE (ltimedpriorityindex=0
     AND lfindindex <= ltimedprioritycount)
     IF ((data->timed_priority_list[lfindindex].oe_format_id=doeformatid))
      ltimedpriorityindex = lfindindex
     ENDIF
     ,lfindindex = (lfindindex+ 1)
    ENDWHILE
   HEAD opf.priority_cd
    IF (ltimedpriorityindex > 0)
     lprioritycount = (lprioritycount+ 1)
     IF (lprioritysize < lprioritycount)
      lprioritysize = (lprioritysize+ lprioritybatchsize), i_stat = alterlist(data->
       timed_priority_list[ltimedpriorityindex].priority_list,lprioritysize)
     ENDIF
     data->timed_priority_list[ltimedpriorityindex].priority_list[lprioritycount].priority_cd = opf
     .priority_cd
    ENDIF
   DETAIL
    dummy = 0
   FOOT  opf.oe_format_id
    IF (lprioritycount > 0
     AND ltimedpriorityindex > 0)
     data->timed_priority_list[ltimedpriorityindex].priority_count = lprioritycount
     IF (lprioritycount < lprioritysize)
      i_stat = alterlist(data->timed_priority_list[ltimedpriorityindex].priority_list,lprioritycount)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  CALL catcherrors("DCP_GET_MISSING_REQUIRED_IND_R 06 - Get timed priority from format")
 ENDIF
 IF (livsetcount > 0)
  SELECT INTO "nl:"
   ocs.synonym_id, csc.catalog_cd, csc.comp_seq
   FROM (dummyt d1  WITH seq = value(livsetcount)),
    order_catalog_synonym ocs,
    cs_component csc
   PLAN (d1)
    JOIN (ocs
    WHERE (ocs.synonym_id=data->iv_set_list[d1.seq].synonym_id))
    JOIN (csc
    WHERE csc.catalog_cd=ocs.catalog_cd
     AND csc.comp_seq=1)
   ORDER BY ocs.synonym_id, csc.catalog_cd, csc.comp_seq
   HEAD ocs.synonym_id
    ddiluentsynonymid = 0.0
   HEAD csc.comp_seq
    IF (csc.comp_seq=1)
     ddiluentsynonymid = csc.comp_id
    ENDIF
   DETAIL
    dummy = 0
   FOOT  ocs.synonym_id
    lfindindex = 1, livsetindex = 0, dsynonymid = ocs.synonym_id
    WHILE (livsetindex=0
     AND lfindindex <= livsetcount)
     IF ((data->iv_set_list[lfindindex].synonym_id=dsynonymid))
      livsetindex = lfindindex
     ENDIF
     ,lfindindex = (lfindindex+ 1)
    ENDWHILE
    WHILE (livsetindex != 0)
      livcomponentcount = data->iv_set_list[livsetindex].iv_component_count, lfindindex = 1,
      livcomponentindex = 0
      WHILE (livcomponentindex=0
       AND lfindindex <= livcomponentcount)
       IF ((data->iv_set_list[livsetindex].iv_component_list[lfindindex].iv_comp_syn_id=
       ddiluentsynonymid))
        livcomponentindex = lfindindex
       ENDIF
       ,lfindindex = (lfindindex+ 1)
      ENDWHILE
      IF (livcomponentindex > 0)
       data->iv_set_list[livsetindex].diluent_idx = livcomponentindex, lordersentenceindex = data->
       iv_set_list[livsetindex].iv_component_list[livcomponentindex].order_sentence_idx
       IF (lordersentenceindex > 0)
        data->order_sentence_list[lordersentenceindex].diluent_ind = 1, data->order_sentence_list[
        lordersentenceindex].additive_ind = 0
       ENDIF
      ENDIF
      lfindindex = (livsetindex+ 1), livsetindex = 0
      WHILE (livsetindex=0
       AND lfindindex <= livsetcount)
       IF ((data->iv_set_list[lfindindex].synonym_id=dsynonymid))
        livsetindex = lfindindex
       ENDIF
       ,lfindindex = (lfindindex+ 1)
      ENDWHILE
    ENDWHILE
   WITH nocounter
  ;end select
  CALL catcherrors("DCP_GET_MISSING_REQUIRED_IND_R 07 - Get IV Sets")
 ENDIF
 SELECT INTO "nl:"
  osd.order_sentence_id, osd.oe_field_id
  FROM (dummyt d1  WITH seq = value(lordersentencecount)),
   order_sentence_detail osd
  PLAN (d1)
   JOIN (osd
   WHERE (osd.order_sentence_id=data->order_sentence_list[d1.seq].order_sentence_id)
    AND  NOT (osd.field_type_flag IN (oe_field_type_date, oe_field_type_date_time)))
  ORDER BY osd.order_sentence_id, osd.oe_field_id
  HEAD REPORT
   ltimedcollectionprioritycount = 0, ltimedcollectionprioritysize = 0,
   ltimedcollectionpriorityoscount = 0
  HEAD osd.order_sentence_id
   losfieldcount = 0, losfieldsize = 0, lfindindex = 1,
   lordersentenceindex = 0, dordersentenceid = osd.order_sentence_id
   WHILE (lordersentenceindex=0
    AND lfindindex <= lordersentencecount)
    IF ((data->order_sentence_list[lfindindex].order_sentence_id=dordersentenceid))
     lordersentenceindex = lfindindex
    ENDIF
    ,lfindindex = (lfindindex+ 1)
   ENDWHILE
  HEAD osd.oe_field_id
   IF (lordersentenceindex > 0)
    losfieldcount = (losfieldcount+ 1)
    IF (losfieldsize < losfieldcount)
     losfieldsize = (losfieldsize+ losfieldbatchsize), i_stat = alterlist(data->order_sentence_list[
      lordersentenceindex].field_list,losfieldsize)
    ENDIF
    data->order_sentence_list[lordersentenceindex].field_list[losfieldcount].oe_field_id = osd
    .oe_field_id, bhasvalueind = 0, bhastextind = 0,
    doefieldmeaningid = osd.oe_field_meaning_id
    IF (doefieldmeaningid IN (oe_field_meaning_sampleqty, oe_field_meaning_samplesgiven,
    oe_field_meaning_refillqty, oe_field_meaning_refillsremaining, oe_field_meaning_totalrefills,
    oe_field_meaning_additionalrefills, oe_field_meaning_nbrrefills,
    oe_field_meaning_rxtransrefillqty, oe_field_meaning_rxtransrefillsremain,
    oe_field_meaning_rxtranstotalrefills,
    oe_field_meaning_other))
     bhasvalueind = 1
    ELSEIF (osd.oe_field_value != 0.0)
     bhasvalueind = 1
    ELSEIF (osd.default_parent_entity_id != 0.0)
     bhasvalueind = 1
    ENDIF
    IF (size(trim(osd.oe_field_display_value),1) > 0)
     bhastextind = 1
    ENDIF
    IF (bhasvalueind=1)
     IF (doefieldmeaningid=oe_field_meaning_collpri
      AND osd.default_parent_entity_name="CODE_VALUE")
      dcollectionprioritycd = osd.default_parent_entity_id
      IF (dcollectionprioritycd > 0.0)
       lfindindex = 1, ltimedcollectionpriorityindex = 0
       WHILE (ltimedcollectionpriorityindex=0
        AND lfindindex <= ltimedcollectionprioritycount)
        IF ((data->timed_collection_priority_list[lfindindex].collection_priority_cd=
        dcollectionprioritycd))
         ltimedcollectionpriorityindex = lfindindex
        ENDIF
        ,lfindindex = (lfindindex+ 1)
       ENDWHILE
       IF (ltimedcollectionpriorityindex < 1)
        ltimedcollectionprioritycount = (ltimedcollectionprioritycount+ 1)
        IF (ltimedcollectionprioritysize < ltimedcollectionprioritycount)
         ltimedcollectionprioritysize = (ltimedcollectionprioritysize+
         ltimedcollectionprioritybatchsize), i_stat = alterlist(data->timed_collection_priority_list,
          ltimedcollectionprioritysize)
        ENDIF
        data->timed_collection_priority_list[ltimedcollectionprioritycount].collection_priority_cd =
        dcollectionprioritycd, ltimedcollectionpriorityindex = ltimedcollectionprioritycount, data->
        timed_collection_priority_list[ltimedcollectionpriorityindex].order_sentence_count = 0
       ENDIF
       IF (ltimedcollectionpriorityindex > 0)
        ltimedcollectionpriorityoscount = data->timed_collection_priority_list[
        ltimedcollectionpriorityindex].order_sentence_count, ltimedcollectionpriorityoscount = (
        ltimedcollectionpriorityoscount+ 1), i_stat = alterlist(data->timed_collection_priority_list[
         ltimedcollectionpriorityindex].order_sentence_list,ltimedcollectionpriorityoscount),
        data->timed_collection_priority_list[ltimedcollectionpriorityindex].order_sentence_list[
        ltimedcollectionpriorityoscount].order_sentence_idx = lordersentenceindex, data->
        timed_collection_priority_list[ltimedcollectionpriorityindex].order_sentence_count =
        ltimedcollectionpriorityoscount
       ENDIF
      ENDIF
     ELSEIF (doefieldmeaningid=oe_field_meaning_priority
      AND osd.default_parent_entity_name="CODE_VALUE")
      ltimedpriorityindex = data->order_sentence_list[lordersentenceindex].timed_priority_idx
      IF (ltimedpriorityindex > 0)
       lfindindex = 1, lpriorityindex = 0, lprioritycount = data->timed_priority_list[
       ltimedpriorityindex].priority_count,
       dprioritycd = osd.default_parent_entity_id
       WHILE (lpriorityindex=0
        AND lfindindex <= lprioritycount)
        IF ((data->timed_priority_list[ltimedpriorityindex].priority_list[lfindindex].priority_cd=
        dprioritycd))
         lpriorityindex = lfindindex
        ENDIF
        ,lfindindex = (lfindindex+ 1)
       ENDWHILE
       IF (lpriorityindex > 0)
        data->order_sentence_list[lordersentenceindex].has_timed_priority_ind = 1
       ENDIF
      ENDIF
     ELSEIF (doefieldmeaningid=oe_field_meaning_strengthdose)
      data->order_sentence_list[lordersentenceindex].has_strength_dose_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_strengthdoseunit)
      data->order_sentence_list[lordersentenceindex].has_strength_dose_unit_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_volumedose)
      data->order_sentence_list[lordersentenceindex].has_volume_dose_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_volumedoseunit)
      data->order_sentence_list[lordersentenceindex].has_volume_dose_unit_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_infuseover)
      data->order_sentence_list[lordersentenceindex].has_infuse_over_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_infuseoverunit)
      data->order_sentence_list[lordersentenceindex].has_infuse_over_unit_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_rate)
      data->order_sentence_list[lordersentenceindex].has_rate_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_rateunit)
      data->order_sentence_list[lordersentenceindex].has_rate_unit_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_normalizedrate)
      data->order_sentence_list[lordersentenceindex].has_normalized_rate_ind = 1
      IF ((data->order_sentence_list[lordersentenceindex].has_normalized_rate_unit_ind=1))
       livsetindex = data->order_sentence_list[lordersentenceindex].iv_set_idx
       IF (livsetindex > 0)
        data->iv_set_list[livsetindex].has_normalized_additive_ind = 1
       ENDIF
      ENDIF
     ELSEIF (doefieldmeaningid=oe_field_meaning_normalizedrateunit)
      data->order_sentence_list[lordersentenceindex].has_normalized_rate_unit_ind = 1
      IF ((data->order_sentence_list[lordersentenceindex].has_normalized_rate_ind=1))
       livsetindex = data->order_sentence_list[lordersentenceindex].iv_set_idx
       IF (livsetindex > 0)
        data->iv_set_list[livsetindex].has_normalized_additive_ind = 1
       ENDIF
      ENDIF
     ELSEIF (doefieldmeaningid=oe_field_meaning_duration)
      data->order_sentence_list[lordersentenceindex].has_duration_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_durationunit)
      data->order_sentence_list[lordersentenceindex].has_duration_unit_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_prninstructions)
      data->order_sentence_list[lordersentenceindex].has_prn_instructions_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_prnreason)
      data->order_sentence_list[lordersentenceindex].has_prn_reason_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_sch_prn)
      data->order_sentence_list[lordersentenceindex].has_sch_prn_ind = 1
     ENDIF
    ENDIF
    IF (bhastextind=1)
     IF (doefieldmeaningid=oe_field_meaning_freetextrate)
      data->order_sentence_list[lordersentenceindex].has_freetext_rate_ind = 1
     ELSEIF (doefieldmeaningid=oe_field_meaning_freetxtdose)
      data->order_sentence_list[lordersentenceindex].has_freetext_dose_ind = 1
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   dummy = 0
  FOOT  osd.order_sentence_id
   IF (lordersentenceindex > 0)
    IF (losfieldcount > 0
     AND losfieldcount < losfieldsize)
     i_stat = alterlist(data->order_sentence_list[lordersentenceindex].field_list,losfieldcount)
    ENDIF
   ENDIF
  FOOT REPORT
   IF (ltimedcollectionprioritycount > 0
    AND ltimedcollectionprioritycount < ltimedcollectionprioritysize)
    i_stat = alterlist(data->timed_collection_priority_list,ltimedcollectionprioritycount)
   ENDIF
  WITH nocounter
 ;end select
 CALL catcherrors("DCP_GET_MISSING_REQUIRED_IND_R 08 - Get order sentence fields")
 IF (lordersentencecount > 0
  AND lordersentencecount < lordersentencesize)
  SET i_stat = alterlist(data->order_sentence_list,lordersentencecount)
 ENDIF
 IF (ltimedcollectionprioritycount > 0)
  SELECT INTO "nl:"
   cp.collection_priority_cd
   FROM (dummyt d1  WITH seq = value(ltimedcollectionprioritycount)),
    collection_priority cp
   PLAN (d1)
    JOIN (cp
    WHERE (cp.collection_priority_cd=data->timed_collection_priority_list[d1.seq].
    collection_priority_cd)
     AND cp.time_study_ind=1)
   ORDER BY cp.collection_priority_cd
   HEAD cp.collection_priority_cd
    lfindindex = 1, ltimedcollectionpriorityindex = 0, dcollectionprioritycd = cp
    .collection_priority_cd
    WHILE (ltimedcollectionpriorityindex=0
     AND lfindindex <= ltimedcollectionprioritycount)
     IF ((data->timed_collection_priority_list[lfindindex].collection_priority_cd=
     dcollectionprioritycd))
      ltimedcollectionpriorityindex = lfindindex
     ENDIF
     ,lfindindex = (lfindindex+ 1)
    ENDWHILE
    IF (ltimedcollectionpriorityindex > 0)
     FOR (idx = 1 TO data->timed_collection_priority_list[ltimedcollectionpriorityindex].
     order_sentence_count)
      lordersentenceindex = data->timed_collection_priority_list[ltimedcollectionpriorityindex].
      order_sentence_list[idx].order_sentence_idx,
      IF (lordersentenceindex > 0)
       data->order_sentence_list[lordersentenceindex].has_timed_priority_ind = 1
      ENDIF
     ENDFOR
    ENDIF
   DETAIL
    dummy = 0
   WITH nocounter
  ;end select
  CALL catcherrors("DCP_GET_MISSING_REQUIRED_IND_R 09 - Get timed collection priority codes")
 ENDIF
 SET lreplycount = 0
 SET lreplysize = 0
 FOR (lordersentenceindex = 1 TO lordersentencecount)
   SET data->order_sentence_list[lordersentenceindex].missing_required_ind = getmissingrequiredfields
   (lordersentenceindex)
   SET lcomponentcount = data->order_sentence_list[lordersentenceindex].component_count
   FOR (idx = 1 TO lcomponentcount)
     SET lreplycount = (lreplycount+ 1)
     IF (lreplysize < lreplycount)
      SET lreplysize = (lreplysize+ lreplybatchsize)
      SET i_stat = alterlist(query_missing_required_reply->list,lreplysize)
     ENDIF
     SET query_missing_required_reply->list[lreplycount].pathway_comp_id = data->order_sentence_list[
     lordersentenceindex].component_list[idx].pathway_comp_id
     SET query_missing_required_reply->list[lreplycount].order_sentence_id = data->
     order_sentence_list[lordersentenceindex].order_sentence_id
     SET query_missing_required_reply->list[lreplycount].missing_required_ind = data->
     order_sentence_list[lordersentenceindex].missing_required_ind
   ENDFOR
 ENDFOR
 IF (lreplycount < 1)
  SET query_missing_required_reply->status = "Z"
  SET query_missing_required_reply->status_description = "No rows to be updated"
 ELSE
  SET query_missing_required_reply->batch_size = lreplybatchsize
  SET query_missing_required_reply->count = lreplycount
  SET query_missing_required_reply->loop_count = ceil((cnvtreal(lreplysize)/ cnvtreal(lreplybatchsize
    )))
  SET query_missing_required_reply->start = 1
  IF ((query_missing_required_request->resize_reply_ind=1))
   SET query_missing_required_reply->size = lreplycount
   IF (lreplycount < lreplysize)
    SET i_stat = alterlist(query_missing_required_reply->list,lreplycount)
   ENDIF
  ELSE
   SET query_missing_required_reply->size = lreplysize
   IF (lreplycount < lreplysize)
    FOR (idx = (lreplycount+ 1) TO lreplysize)
     SET query_missing_required_reply->list[idx].pathway_comp_id = query_missing_required_reply->
     list[lreplycount].pathway_comp_id
     SET query_missing_required_reply->list[idx].order_sentence_id = query_missing_required_reply->
     list[lreplycount].order_sentence_id
    ENDFOR
   ENDIF
  ENDIF
  SET query_missing_required_reply->status = "S"
  SET query_missing_required_reply->status_description = "Readme was successful"
 ENDIF
 CALL catcherrors("DCP_GET_MISSING_REQUIRED_IND_R 10 - Get missing required field indicators")
 SUBROUTINE catcherrors(s_description)
   SET err_msg = fillstring(132," ")
   SET err_code = error(err_msg,0)
   IF (err_code != 0)
    SET query_missing_required_reply->status = "F"
    SET query_missing_required_reply->status_description = concat(trim(s_description)," - ",trim(
      err_msg))
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE hasdosefilledout(l_order_sentence_idx)
   IF (l_order_sentence_idx < 1)
    RETURN(0)
   ENDIF
   IF ((((data->order_sentence_list[l_order_sentence_idx].has_strength_dose_ind=1)
    AND (data->order_sentence_list[l_order_sentence_idx].has_strength_dose_unit_ind=1)) OR ((((data->
   order_sentence_list[l_order_sentence_idx].has_volume_dose_ind=1)
    AND (data->order_sentence_list[l_order_sentence_idx].has_volume_dose_unit_ind=1)) OR ((data->
   order_sentence_list[l_order_sentence_idx].has_freetext_dose_ind=1))) )) )
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE hasinfuseoverfilledout(l_diluent_order_sentence_idx)
   IF (l_diluent_order_sentence_idx < 1)
    RETURN(0)
   ENDIF
   IF ((data->order_sentence_list[l_diluent_order_sentence_idx].has_infuse_over_ind=0))
    RETURN(0)
   ELSEIF ((data->order_sentence_list[l_diluent_order_sentence_idx].has_infuse_over_unit_ind=0))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE hasratefilledout(l_diluent_order_sentence_idx)
   IF (l_diluent_order_sentence_idx < 1)
    RETURN(0)
   ENDIF
   IF ((data->order_sentence_list[l_diluent_order_sentence_idx].has_rate_ind=0))
    RETURN(0)
   ELSEIF ((data->order_sentence_list[l_diluent_order_sentence_idx].has_rate_unit_ind=0))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getdiluentmissingrequiredind(l_order_sentence_idx)
   IF (l_order_sentence_idx < 1)
    RETURN(0)
   ENDIF
   IF ((data->order_sentence_list[l_order_sentence_idx].diluent_ind=0))
    RETURN(0)
   ENDIF
   SET livsetindex = data->order_sentence_list[l_order_sentence_idx].iv_set_idx
   IF (livsetindex < 1)
    RETURN(0)
   ENDIF
   IF ((data->iv_set_list[livsetindex].has_normalized_additive_ind=1))
    IF ((data->order_sentence_list[l_order_sentence_idx].has_volume_dose_ind=1)
     AND (data->order_sentence_list[l_order_sentence_idx].has_volume_dose_unit_ind=1))
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
   IF ((data->order_sentence_list[l_order_sentence_idx].has_freetext_rate_ind=1))
    IF ((data->order_sentence_list[l_order_sentence_idx].has_volume_dose_ind=1)
     AND (data->order_sentence_list[l_order_sentence_idx].has_volume_dose_unit_ind=1))
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
   IF ((data->order_sentence_list[l_order_sentence_idx].has_volume_dose_ind=1)
    AND (data->order_sentence_list[l_order_sentence_idx].has_volume_dose_unit_ind=1))
    IF (hasinfuseoverfilledout(l_order_sentence_idx)=1)
     RETURN(0)
    ELSEIF (hasratefilledout(l_order_sentence_idx)=1)
     RETURN(0)
    ENDIF
   ELSEIF (hasinfuseoverfilledout(l_order_sentence_idx)=1
    AND hasratefilledout(l_order_sentence_idx)=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getadditivemissingrequiredind(l_order_sentence_idx)
   IF (l_order_sentence_idx < 1)
    RETURN(0)
   ENDIF
   IF ((data->order_sentence_list[l_order_sentence_idx].additive_ind=0))
    RETURN(0)
   ENDIF
   IF (hasdosefilledout(l_order_sentence_idx)=0)
    RETURN(1)
   ENDIF
   IF ((((data->order_sentence_list[l_order_sentence_idx].has_normalized_rate_ind=1)
    AND (data->order_sentence_list[l_order_sentence_idx].has_normalized_rate_unit_ind=0)) OR ((data->
   order_sentence_list[l_order_sentence_idx].has_normalized_rate_ind=0)
    AND (data->order_sentence_list[l_order_sentence_idx].has_normalized_rate_unit_ind=1))) )
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getmedicationmissingrequiredind(l_order_sentence_idx)
   IF (l_order_sentence_idx < 1)
    RETURN(0)
   ENDIF
   IF ((data->order_sentence_list[l_order_sentence_idx].medication_ind=0))
    RETURN(0)
   ENDIF
   IF (hasdosefilledout(l_order_sentence_idx)=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getdurationmissingrequiredind(l_order_sentence_idx,loeformatindex,lactiontypeindex)
   IF (l_order_sentence_idx < 1)
    RETURN(0)
   ENDIF
   IF (loeformatindex < 1)
    RETURN(0)
   ENDIF
   IF (lactiontypeindex < 1)
    RETURN(0)
   ENDIF
   IF ((data->order_sentence_list[l_order_sentence_idx].has_duration_ind=1))
    IF ((data->order_sentence_list[l_order_sentence_idx].has_duration_unit_ind=0))
     RETURN(1)
    ENDIF
   ELSE
    IF ((data->order_sentence_list[l_order_sentence_idx].has_duration_unit_ind=1))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getprnmissingrequiredind(l_order_sentence_idx,loeformatindex,lactiontypeindex)
   IF (l_order_sentence_idx < 1)
    RETURN(0)
   ENDIF
   IF (loeformatindex < 1)
    RETURN(0)
   ENDIF
   IF (lactiontypeindex < 1)
    RETURN(0)
   ENDIF
   IF ((data->order_sentence_list[l_order_sentence_idx].has_sch_prn_ind=0))
    RETURN(0)
   ENDIF
   SET bprnreasonneeded = 0
   SET bprninstructionsneeded = 0
   SET bprnreasonexistsonformat = data->oe_format_list[loeformatindex].action_type_list[
   lactiontypeindex].has_prn_reason_ind
   SET bprninstructionsexistsonformat = data->oe_format_list[loeformatindex].action_type_list[
   lactiontypeindex].has_prn_instructions_ind
   SET iprnreasonacceptflag = data->oe_format_list[loeformatindex].action_type_list[lactiontypeindex]
   .accept_flag_prn_reason
   SET iprninstructionsacceptflag = data->oe_format_list[loeformatindex].action_type_list[
   lactiontypeindex].accept_flag_prn_instructions
   SET boshasprnreason = data->order_sentence_list[l_order_sentence_idx].has_prn_reason_ind
   SET boshasprninstructions = data->order_sentence_list[l_order_sentence_idx].
   has_prn_instructions_ind
   IF (bprnreasonexistsonformat=0)
    SET iprnreasonacceptflag = accept_flag_empty
   ENDIF
   IF (bprninstructionsexistsonformat=0)
    SET iprninstructionsacceptflag = accept_flag_empty
   ENDIF
   IF (bprnreasonexistsonformat=1)
    IF (boshasprnreason=1)
     SET iprnreasonacceptflag = accept_flag_required
     IF (bprninstructionsexistsonformat=1
      AND iprninstructionsacceptflag=accept_flag_required)
      SET iprninstructionsacceptflag = accept_flag_optional
     ENDIF
     SET data->order_sentence_list[l_order_sentence_idx].accept_flag_prn_reason =
     iprnreasonacceptflag
     SET data->order_sentence_list[l_order_sentence_idx].accept_flag_prn_instructions =
     iprninstructionsacceptflag
     RETURN(0)
    ELSE
     SET bprnreasonneeded = 1
    ENDIF
   ENDIF
   IF (bprninstructionsexistsonformat=1)
    IF (boshasprninstructions=1)
     SET iprninstructionsacceptflag = accept_flag_required
     IF (bprnreasonexistsonformat=1
      AND iprnreasonacceptflag=accept_flag_required)
      SET iprnreasonacceptflag = accept_flag_optional
     ENDIF
     SET data->order_sentence_list[l_order_sentence_idx].accept_flag_prn_reason =
     iprnreasonacceptflag
     SET data->order_sentence_list[l_order_sentence_idx].accept_flag_prn_instructions =
     iprninstructionsacceptflag
     RETURN(0)
    ELSE
     SET bprninstructionsneeded = 1
    ENDIF
   ENDIF
   SET data->order_sentence_list[l_order_sentence_idx].accept_flag_prn_reason = iprnreasonacceptflag
   SET data->order_sentence_list[l_order_sentence_idx].accept_flag_prn_instructions =
   iprninstructionsacceptflag
   IF (((bprnreasonneeded=1) OR (bprninstructionsneeded=1)) )
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getmissingrequiredfields(l_order_sentence_idx)
   IF (l_order_sentence_idx < 1)
    RETURN(0)
   ENDIF
   IF ((data->order_sentence_list[l_order_sentence_idx].has_timed_priority_ind=1))
    RETURN(1)
   ENDIF
   SET loeformatindex = data->order_sentence_list[l_order_sentence_idx].oe_format_idx
   IF (loeformatindex < 1)
    RETURN(0)
   ENDIF
   SET lactiontypeindex = data->order_sentence_list[l_order_sentence_idx].action_type_idx
   IF (lactiontypeindex < 1)
    RETURN(0)
   ENDIF
   IF ((data->order_sentence_list[l_order_sentence_idx].diluent_ind=1))
    IF (getdiluentmissingrequiredind(l_order_sentence_idx)=1)
     RETURN(1)
    ENDIF
   ELSEIF ((data->order_sentence_list[l_order_sentence_idx].additive_ind=1))
    IF (getadditivemissingrequiredind(l_order_sentence_idx)=1)
     RETURN(1)
    ENDIF
   ELSEIF ((data->order_sentence_list[l_order_sentence_idx].medication_ind=1))
    IF (getmedicationmissingrequiredind(l_order_sentence_idx)=1)
     RETURN(1)
    ENDIF
   ENDIF
   IF (getdurationmissingrequiredind(l_order_sentence_idx,loeformatindex,lactiontypeindex)=1)
    RETURN(1)
   ENDIF
   IF (getprnmissingrequiredind(l_order_sentence_idx,loeformatindex,lactiontypeindex)=1)
    RETURN(1)
   ENDIF
   SET lordersentencefieldcount = size(data->order_sentence_list[l_order_sentence_idx].field_list,5)
   SET lrequiredfieldcount = size(data->oe_format_list[loeformatindex].action_type_list[
    lactiontypeindex].required_field_list,5)
   IF (lrequiredfieldcount < 1)
    RETURN(0)
   ENDIF
   FOR (lrequiredfieldindex = 1 TO lrequiredfieldcount)
     SET drequiredoefieldid = data->oe_format_list[loeformatindex].action_type_list[lactiontypeindex]
     .required_field_list[lrequiredfieldindex].oe_field_id
     SET drequiredoefieldmeaningid = data->oe_format_list[loeformatindex].action_type_list[
     lactiontypeindex].required_field_list[lrequiredfieldindex].oe_field_meaning_id
     SET bfoundfield = 0
     SET lordersentencefieldindex = 1
     IF (drequiredoefieldmeaningid=oe_field_meaning_prnreason
      AND (data->order_sentence_list[l_order_sentence_idx].accept_flag_prn_reason !=
     accept_flag_required))
      SET bfoundfield = 1
     ELSEIF (drequiredoefieldmeaningid=oe_field_meaning_prninstructions
      AND (data->order_sentence_list[l_order_sentence_idx].accept_flag_prn_instructions !=
     accept_flag_required))
      SET bfoundfield = 1
     ENDIF
     WHILE (bfoundfield=0
      AND lordersentencefieldindex <= lordersentencefieldcount)
       SET dordersentenceoefieldid = data->order_sentence_list[l_order_sentence_idx].field_list[
       lordersentencefieldindex].oe_field_id
       IF (drequiredoefieldid=dordersentenceoefieldid)
        SET bfoundfield = 1
       ENDIF
       SET lordersentencefieldindex = (lordersentencefieldindex+ 1)
     ENDWHILE
     IF (bfoundfield=0)
      RETURN(1)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
#exit_script
 FREE RECORD data
 DECLARE dcp_get_missing_required_ind_r_last_mod = c3 WITH protect, constant("000")
END GO
