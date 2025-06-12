CREATE PROGRAM bed_get_oc_match_fac:dba
 FREE SET reply
 RECORD reply(
   1 matches[*]
     2 oc_id = f8
     2 facility = vc
     2 short_desc = vc
     2 long_desc = vc
     2 possible_match[*]
       3 primary_name = vc
       3 description = vc
       3 catalog_code_value = f8
       3 match_type = i2
       3 match_value = vc
       3 already_matched_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_reply
 RECORD temp_reply(
   1 matches[*]
     2 oc_id = f8
     2 facility = vc
     2 short_desc = vc
     2 long_desc = vc
     2 possible_match[*]
       3 primary_name = vc
       3 description = vc
       3 catalog_code_value = f8
       3 match_type = i2
       3 match_value = vc
       3 already_matched_ind = i2
       3 concept_cki = vc
 )
 FREE SET fac_list
 RECORD fac_list(
   1 fac[*]
     2 name = vc
 )
 FREE SET client_orderable_list
 RECORD client_orderable_list(
   1 orderable[*]
     2 oc_id = f8
     2 facility = vc
     2 short_desc = c100
     2 long_desc = c100
     2 cpt4_code = vc
     2 loinc_code = c10
     2 match_ind = i2
     2 clist[*]
       3 concept_cki = vc
     2 llist[*]
       3 concept_cki = vc
 )
 FREE SET one_to_one_match
 RECORD one_to_one_match(
   1 olist[*]
     2 catalog_cd = f8
     2 facility = vc
     2 concept_cki = vc
 )
 SET found_cerner_orderable = 0
 SET tot_nbr_client_orderables = 0
 SET tot_nbr_one_matches = 0
 SET match_count = 0
 SET one_match_count = 0
 SET poss_match_count = 0
 SET tot_match = 0
 SET tot_poss_match = 0
 SET tot_count = 0
 SET i = 0
 SET z = 0
 SET already_matched = 0
 SET match_cnt = 0
 SET dsize = 0
 SET reply_count = 0
 SET fac_count = 0
 SET fac_listcount = 0
 SET another_fac = 0
 SET reply->status_data.status = "F"
 SET stat = alterlist(client_orderable_list->orderable,100)
 DECLARE br_parse = vc
 SET cpt4_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.cki="CKI.CODEVALUE!3600"
  DETAIL
   cpt4_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET dcp_code_value = 0.0
 SET ancillary_code_value = 0.0
 SET primary_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("DCP", "ANCILLARY", "PRIMARY")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "DCP":
     dcp_code_value = cv.code_value
    OF "ANCILLARY":
     ancillary_code_value = cv.code_value
    OF "PRIMARY":
     primary_code_value = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET cat_surgery_ind = 0
 SET catalog_display = fillstring(42," ")
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.active_ind=1
   AND (cv.code_value=request->filters.catalog_type_code_value)
  DETAIL
   catalog_display = concat("'",trim(cnvtupper(cv.display)),"'")
   IF (cv.cdf_meaning="SURGERY")
    cat_surgery_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET activity_display = fillstring(42," ")
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.active_ind=1
   AND (cv.code_value=request->filters.activity_type_code_value)
  DETAIL
   activity_display = concat("'",trim(cnvtupper(cv.display)),"'")
  WITH nocounter
 ;end select
 SET br_parse = concat(br_parse,"b.status_ind = 0 and b.skip_match_ind != 1 ")
 IF (catalog_display > "   *")
  SET br_parse = concat(br_parse," and cnvtupper(b.catalog_type) =",catalog_display)
 ENDIF
 IF (activity_display > "   *")
  SET br_parse = concat(br_parse," and cnvtupper(b.activity_type) =",activity_display)
 ENDIF
 CALL echo(build("parser = ",br_parse))
 SET fac_count = size(request->filters.fac_list,5)
 IF (fac_count=0)
  SELECT DISTINCT INTO "NL:"
   b.facility
   FROM br_oc_work b
   PLAN (b
    WHERE parser(br_parse))
   ORDER BY b.facility
   HEAD REPORT
    stat = alterlist(fac_list->fac,10)
   DETAIL
    fac_count = (fac_count+ 1), fac_listcount = (fac_listcount+ 1)
    IF (fac_listcount > 10)
     stat = alterlist(fac_list->fac,(fac_count+ 10)), fac_listcount = 1
    ENDIF
    fac_list->fac[fac_count].name = b.facility
    IF (fac_count=1)
     br_parse = concat(br_parse," and (b.facility = '",trim(request->filters.fac_list[i].name),"'")
    ELSE
     br_parse = concat(br_parse," or b.facility = '",trim(request->filters.fac_list[i].name),"'")
    ENDIF
   FOOT REPORT
    br_parse = concat(br_parse,")"), stat = alterlist(fac_list->fac,fac_count)
   WITH nocounter
  ;end select
 ELSE
  SET stat = alterlist(fac_list->fac,fac_count)
  FOR (i = 1 TO fac_count)
   SET fac_list->fac[i].name = request->filters.fac_list[i].name
   IF (i=1)
    SET br_parse = concat(br_parse," and (b.facility = '",trim(request->filters.fac_list[i].name),"'"
     )
   ELSE
    SET br_parse = concat(br_parse," or b.facility = '",trim(request->filters.fac_list[i].name),"'")
   ENDIF
  ENDFOR
  SET br_parse = concat(br_parse,")")
 ENDIF
 CALL echo(br_parse)
 SELECT INTO "NL:"
  upper_long = cnvtupper(b.long_desc), upper_short = cnvtupper(b.short_desc)
  FROM br_oc_work b,
   br_oc_pricing bp
  PLAN (b
   WHERE parser(br_parse))
   JOIN (bp
   WHERE bp.oc_id=outerjoin(b.oc_id)
    AND bp.billcode_sched_cd=outerjoin(cpt4_code_value))
  ORDER BY b.facility, upper_long, upper_short DESC
  HEAD REPORT
   tot_nbr_client_orderables = 0, client_orc_count = 0
  DETAIL
   tot_nbr_client_orderables = (tot_nbr_client_orderables+ 1), client_orc_count = (client_orc_count+
   1), syn_count = 0
   IF (client_orc_count > 100)
    stat = alterlist(client_orderable_list->orderable,(tot_nbr_client_orderables+ 100)),
    client_orc_count = 0
   ENDIF
   client_orderable_list->orderable[tot_nbr_client_orderables].oc_id = b.oc_id, client_orderable_list
   ->orderable[tot_nbr_client_orderables].facility = b.facility, client_orderable_list->orderable[
   tot_nbr_client_orderables].short_desc = trim(upper_short),
   client_orderable_list->orderable[tot_nbr_client_orderables].long_desc = trim(upper_long),
   client_orderable_list->orderable[tot_nbr_client_orderables].cpt4_code = bp.billcode,
   client_orderable_list->orderable[tot_nbr_client_orderables].loinc_code = b.loinc_code,
   client_orderable_list->orderable[tot_nbr_client_orderables].match_ind = b.match_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->matches,100)
 SET stat = alterlist(one_to_one_match->olist,100)
 IF (fac_count > 0)
  SELECT INTO "NL:"
   FROM br_oc_work b,
    (dummyt d  WITH seq = fac_count)
   PLAN (d)
    JOIN (b
    WHERE (b.facility=fac_list->fac[d.seq].name)
     AND b.match_orderable_cd > 0)
   HEAD REPORT
    tot_nbr_one_matches = 0, one_match_count = 0
   DETAIL
    tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
    IF (one_match_count > 100)
     stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 0
    ENDIF
    one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = b.match_orderable_cd, one_to_one_match
    ->olist[tot_nbr_one_matches].facility = b.facility
   WITH nocounter
  ;end select
 ENDIF
 IF (tot_nbr_one_matches > 0)
  SELECT INTO "NL"
   FROM (dummyt d  WITH seq = tot_nbr_one_matches),
    order_catalog oc
   PLAN (d)
    JOIN (oc
    WHERE (oc.catalog_cd=one_to_one_match->olist[d.seq].catalog_cd))
   DETAIL
    one_to_one_match->olist[d.seq].concept_cki = oc.concept_cki
   WITH nocounter
  ;end select
  SELECT INTO "NL"
   FROM (dummyt d  WITH seq = tot_nbr_one_matches),
    br_auto_order_catalog oc
   PLAN (d
    WHERE (one_to_one_match->olist[d.seq].concept_cki="  "))
    JOIN (oc
    WHERE (oc.catalog_cd=one_to_one_match->olist[d.seq].catalog_cd))
   DETAIL
    one_to_one_match->olist[d.seq].concept_cki = oc.concept_cki
   WITH skipbedrock = 1, nocounter
  ;end select
 ENDIF
 IF ((request->load.match_type=1))
  IF (tot_nbr_client_orderables > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
     order_catalog_synonym syn,
     order_catalog oc
    PLAN (d
     WHERE (client_orderable_list->orderable[d.seq].match_ind=0))
     JOIN (syn
     WHERE (((syn.mnemonic_key_cap=client_orderable_list->orderable[d.seq].short_desc)) OR ((syn
     .mnemonic_key_cap=client_orderable_list->orderable[d.seq].long_desc)))
      AND syn.mnemonic != "zz*"
      AND syn.mnemonic_type_cd=primary_code_value
      AND (syn.catalog_type_cd=request->filters.catalog_type_code_value)
      AND (((syn.activity_type_cd=request->filters.activity_type_code_value)) OR ((request->filters.
     activity_type_code_value=0)))
      AND (((syn.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
     filters.subactivity_type_code_value=0))) )
     JOIN (oc
     WHERE oc.catalog_cd=syn.catalog_cd
      AND oc.orderable_type_flag != 6
      AND oc.orderable_type_flag != 2)
    DETAIL
     already_matched = 0, another_fac = 0
     FOR (x = 1 TO tot_nbr_one_matches)
       IF ((oc.concept_cki=one_to_one_match->olist[x].concept_cki))
        IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
         already_matched = 1
        ELSE
         another_fac = 1
        ENDIF
       ENDIF
     ENDFOR
     IF (already_matched=0)
      tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
      IF (one_match_count > 100)
       stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 0
      ENDIF
      one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = syn.catalog_cd, one_to_one_match->
      olist[tot_nbr_one_matches].facility = client_orderable_list->orderable[d.seq].facility,
      one_to_one_match->olist[tot_nbr_one_matches].concept_cki = oc.concept_cki,
      client_orderable_list->orderable[d.seq].match_ind = 1, match_count = (match_count+ 1),
      tot_match = (tot_match+ 1)
      IF (match_count > 100)
       stat = alterlist(reply->matches,(tot_match+ 100)), match_count = 0
      ENDIF
      stat = alterlist(reply->matches[tot_match].possible_match,1), tot_poss_match = 1, reply->
      matches[tot_match].oc_id = client_orderable_list->orderable[d.seq].oc_id,
      reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility, reply->
      matches[tot_match].short_desc = client_orderable_list->orderable[d.seq].short_desc, reply->
      matches[tot_match].long_desc = client_orderable_list->orderable[d.seq].long_desc,
      reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility, reply->
      matches[tot_match].possible_match[1].catalog_code_value = syn.catalog_cd, reply->matches[
      tot_match].possible_match[1].primary_name = oc.primary_mnemonic,
      reply->matches[tot_match].possible_match[1].description = oc.description, reply->matches[
      tot_match].possible_match[1].match_value = syn.mnemonic, reply->matches[tot_match].
      possible_match[1].match_type = 1
      IF (another_fac=1)
       reply->matches[tot_match].possible_match[1].already_matched_ind = 1
      ELSE
       reply->matches[tot_match].possible_match[1].already_matched_ind = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
     br_auto_oc_synonym syn,
     br_auto_order_catalog oc
    PLAN (d
     WHERE (client_orderable_list->orderable[d.seq].match_ind=0))
     JOIN (syn
     WHERE (((syn.mnemonic_key_cap=client_orderable_list->orderable[d.seq].short_desc)) OR ((syn
     .mnemonic_key_cap=client_orderable_list->orderable[d.seq].long_desc)))
      AND syn.mnemonic_type_cd=primary_code_value
      AND (syn.catalog_type_cd=request->filters.catalog_type_code_value)
      AND (((((syn.activity_type_cd=request->filters.activity_type_code_value)) OR ((request->filters
     .activity_type_code_value=0))) ) OR (cat_surgery_ind=1))
      AND (((((syn.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
     filters.subactivity_type_code_value=0))) ) OR (cat_surgery_ind=1)) )
     JOIN (oc
     WHERE oc.catalog_cd=syn.catalog_cd
      AND ((cat_surgery_ind=0) OR (oc.surgery_ind=1)) )
    DETAIL
     already_matched = 0, another_fac = 0
     FOR (x = 1 TO tot_nbr_one_matches)
       IF ((oc.concept_cki=one_to_one_match->olist[x].concept_cki))
        IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
         already_matched = 1
        ELSE
         another_fac = 1
        ENDIF
       ENDIF
     ENDFOR
     IF (already_matched=0)
      tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
      IF (one_match_count > 100)
       stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 0
      ENDIF
      one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = syn.catalog_cd, one_to_one_match->
      olist[tot_nbr_one_matches].facility = client_orderable_list->orderable[d.seq].facility,
      one_to_one_match->olist[tot_nbr_one_matches].concept_cki = oc.concept_cki,
      client_orderable_list->orderable[d.seq].match_ind = 1, match_count = (match_count+ 1),
      tot_match = (tot_match+ 1)
      IF (match_count > 100)
       stat = alterlist(reply->matches,(tot_match+ 100)), match_count = 0
      ENDIF
      stat = alterlist(reply->matches[tot_match].possible_match,1), tot_poss_match = 1, reply->
      matches[tot_match].oc_id = client_orderable_list->orderable[d.seq].oc_id,
      reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility, reply->
      matches[tot_match].short_desc = client_orderable_list->orderable[d.seq].short_desc, reply->
      matches[tot_match].long_desc = client_orderable_list->orderable[d.seq].long_desc,
      reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility, reply->
      matches[tot_match].possible_match[1].catalog_code_value = syn.catalog_cd, reply->matches[
      tot_match].possible_match[1].primary_name = oc.primary_mnemonic,
      reply->matches[tot_match].possible_match[1].description = oc.description, reply->matches[
      tot_match].possible_match[1].match_value = syn.mnemonic, reply->matches[tot_match].
      possible_match[1].match_type = 1
      IF (another_fac=1)
       reply->matches[tot_match].possible_match[1].already_matched_ind = 1
      ELSE
       reply->matches[tot_match].possible_match[1].already_matched_ind = 0
      ENDIF
     ENDIF
    WITH skipbedrock = 1, nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
     br_other_names bon,
     order_catalog orc
    PLAN (d
     WHERE (client_orderable_list->orderable[d.seq].match_ind=0))
     JOIN (bon
     WHERE bon.parent_entity_name="ORDER_CATALOG"
      AND (((bon.alias_name_key_cap=client_orderable_list->orderable[d.seq].short_desc)) OR ((bon
     .alias_name_key_cap=client_orderable_list->orderable[d.seq].long_desc))) )
     JOIN (orc
     WHERE orc.catalog_cd=bon.parent_entity_id
      AND (orc.catalog_type_cd=request->filters.catalog_type_code_value)
      AND orc.orderable_type_flag != 6
      AND orc.orderable_type_flag != 2
      AND orc.primary_mnemonic != "zz*"
      AND (((orc.activity_type_cd=request->filters.activity_type_code_value)) OR ((request->filters.
     activity_type_code_value=0)))
      AND (((orc.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
     filters.subactivity_type_code_value=0))) )
    DETAIL
     already_matched = 0, another_fac = 0
     FOR (x = 1 TO tot_nbr_one_matches)
       IF ((orc.concept_cki=one_to_one_match->olist[x].concept_cki))
        IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
         already_matched = 1
        ELSE
         another_fac = 1
        ENDIF
       ENDIF
     ENDFOR
     IF (already_matched=0)
      tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
      IF (one_match_count > 100)
       stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 0
      ENDIF
      one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = orc.catalog_cd, one_to_one_match->
      olist[tot_nbr_one_matches].facility = client_orderable_list->orderable[d.seq].facility,
      one_to_one_match->olist[tot_nbr_one_matches].concept_cki = orc.concept_cki,
      client_orderable_list->orderable[d.seq].match_ind = 1, match_count = (match_count+ 1),
      tot_match = (tot_match+ 1)
      IF (match_count > 100)
       stat = alterlist(reply->matches,(tot_match+ 100)), match_count = 0
      ENDIF
      stat = alterlist(reply->matches[tot_match].possible_match,1), tot_poss_match = 1, reply->
      matches[tot_match].oc_id = client_orderable_list->orderable[d.seq].oc_id,
      reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility, reply->
      matches[tot_match].short_desc = trim(client_orderable_list->orderable[d.seq].short_desc), reply
      ->matches[tot_match].long_desc = trim(client_orderable_list->orderable[d.seq].long_desc),
      reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility, reply->
      matches[tot_match].possible_match[1].catalog_code_value = orc.catalog_cd, reply->matches[
      tot_match].possible_match[1].primary_name = orc.primary_mnemonic,
      reply->matches[tot_match].possible_match[1].description = orc.description, reply->matches[
      tot_match].possible_match[1].match_value = bon.alias_name, reply->matches[tot_match].
      possible_match[1].match_type = 1
      IF (another_fac=1)
       reply->matches[tot_match].possible_match[1].already_matched_ind = 1
      ELSE
       reply->matches[tot_match].possible_match[1].already_matched_ind = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
     br_other_names bon,
     br_auto_order_catalog orc
    PLAN (d
     WHERE (client_orderable_list->orderable[d.seq].match_ind=0))
     JOIN (bon
     WHERE bon.parent_entity_name="BR_AUTO_ORDER_CATALOG"
      AND (((bon.alias_name_key_cap=client_orderable_list->orderable[d.seq].short_desc)) OR ((bon
     .alias_name_key_cap=client_orderable_list->orderable[d.seq].long_desc))) )
     JOIN (orc
     WHERE orc.catalog_cd=bon.parent_entity_id
      AND (orc.catalog_type_cd=request->filters.catalog_type_code_value)
      AND (((((orc.activity_type_cd=request->filters.activity_type_code_value)) OR ((request->filters
     .activity_type_code_value=0))) ) OR (cat_surgery_ind=1))
      AND (((((orc.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
     filters.subactivity_type_code_value=0))) ) OR (cat_surgery_ind=1))
      AND ((cat_surgery_ind=0) OR (orc.surgery_ind=1)) )
    DETAIL
     already_matched = 0, another_fac = 0
     FOR (x = 1 TO tot_nbr_one_matches)
       IF ((orc.concept_cki=one_to_one_match->olist[x].concept_cki))
        IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
         already_matched = 1
        ELSE
         another_fac = 1
        ENDIF
       ENDIF
     ENDFOR
     IF (already_matched=0)
      tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
      IF (one_match_count > 100)
       stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 0
      ENDIF
      one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = orc.catalog_cd, one_to_one_match->
      olist[tot_nbr_one_matches].facility = client_orderable_list->orderable[d.seq].facility,
      one_to_one_match->olist[tot_nbr_one_matches].concept_cki = orc.concept_cki,
      client_orderable_list->orderable[d.seq].match_ind = 1, match_count = (match_count+ 1),
      tot_match = (tot_match+ 1)
      IF (match_count > 100)
       stat = alterlist(reply->matches,(tot_match+ 100)), match_count = 0
      ENDIF
      stat = alterlist(reply->matches[tot_match].possible_match,1), tot_poss_match = 1, reply->
      matches[tot_match].oc_id = client_orderable_list->orderable[d.seq].oc_id,
      reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility, reply->
      matches[tot_match].short_desc = trim(client_orderable_list->orderable[d.seq].short_desc), reply
      ->matches[tot_match].long_desc = trim(client_orderable_list->orderable[d.seq].long_desc),
      reply->matches[tot_match].possible_match[1].catalog_code_value = orc.catalog_cd, reply->
      matches[tot_match].possible_match[1].primary_name = orc.primary_mnemonic, reply->matches[
      tot_match].possible_match[1].description = orc.description,
      reply->matches[tot_match].possible_match[1].match_value = bon.alias_name, reply->matches[
      tot_match].possible_match[1].match_type = 1
      IF (another_fac=1)
       reply->matches[tot_match].possible_match[1].already_matched_ind = 1
      ELSE
       reply->matches[tot_match].possible_match[1].already_matched_ind = 0
      ENDIF
     ENDIF
    WITH skipbedrock = 1, nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
     order_catalog_synonym syn,
     order_catalog oc
    PLAN (d
     WHERE (client_orderable_list->orderable[d.seq].match_ind=0))
     JOIN (syn
     WHERE (((syn.mnemonic_key_cap=client_orderable_list->orderable[d.seq].short_desc)) OR ((syn
     .mnemonic_key_cap=client_orderable_list->orderable[d.seq].long_desc)))
      AND syn.mnemonic != "zz*"
      AND ((syn.mnemonic_type_cd=ancillary_code_value) OR (syn.mnemonic_type_cd=dcp_code_value))
      AND (syn.catalog_type_cd=request->filters.catalog_type_code_value)
      AND (((syn.activity_type_cd=request->filters.activity_type_code_value)) OR ((request->filters.
     activity_type_code_value=0)))
      AND (((syn.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
     filters.subactivity_type_code_value=0))) )
     JOIN (oc
     WHERE oc.catalog_cd=syn.catalog_cd
      AND oc.orderable_type_flag != 6
      AND oc.orderable_type_flag != 2)
    DETAIL
     already_matched = 0, another_fac = 0
     FOR (x = 1 TO tot_nbr_one_matches)
       IF ((oc.concept_cki=one_to_one_match->olist[x].concept_cki))
        IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
         already_matched = 1
        ELSE
         another_fac = 1
        ENDIF
       ENDIF
     ENDFOR
     IF (already_matched=0)
      tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
      IF (one_match_count > 100)
       stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 0
      ENDIF
      one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = syn.catalog_cd, one_to_one_match->
      olist[tot_nbr_one_matches].facility = client_orderable_list->orderable[d.seq].facility,
      one_to_one_match->olist[tot_nbr_one_matches].concept_cki = oc.concept_cki,
      client_orderable_list->orderable[d.seq].match_ind = 1, match_count = (match_count+ 1),
      tot_match = (tot_match+ 1)
      IF (match_count > 100)
       stat = alterlist(reply->matches,(tot_match+ 100)), match_count = 0
      ENDIF
      stat = alterlist(reply->matches[tot_match].possible_match,1), tot_poss_match = 1, reply->
      matches[tot_match].oc_id = client_orderable_list->orderable[d.seq].oc_id,
      reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility, reply->
      matches[tot_match].short_desc = trim(client_orderable_list->orderable[d.seq].short_desc), reply
      ->matches[tot_match].long_desc = trim(client_orderable_list->orderable[d.seq].long_desc),
      reply->matches[tot_match].possible_match[1].catalog_code_value = syn.catalog_cd, reply->
      matches[tot_match].possible_match[1].primary_name = oc.primary_mnemonic, reply->matches[
      tot_match].possible_match[1].description = oc.description,
      reply->matches[tot_match].possible_match[1].match_value = syn.mnemonic, reply->matches[
      tot_match].possible_match[1].match_type = 1
      IF (another_fac=1)
       reply->matches[tot_match].possible_match[1].already_matched_ind = 1
      ELSE
       reply->matches[tot_match].possible_match[1].already_matched_ind = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
     br_auto_oc_synonym syn,
     br_auto_order_catalog oc
    PLAN (d
     WHERE (client_orderable_list->orderable[d.seq].match_ind=0))
     JOIN (syn
     WHERE (((syn.mnemonic_key_cap=client_orderable_list->orderable[d.seq].short_desc)) OR ((syn
     .mnemonic_key_cap=client_orderable_list->orderable[d.seq].long_desc)))
      AND syn.mnemonic_type_cd=ancillary_code_value
      AND (syn.catalog_type_cd=request->filters.catalog_type_code_value)
      AND (((((syn.activity_type_cd=request->filters.activity_type_code_value)) OR ((request->filters
     .activity_type_code_value=0))) ) OR (cat_surgery_ind=1))
      AND (((((syn.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
     filters.subactivity_type_code_value=0))) ) OR (cat_surgery_ind=1)) )
     JOIN (oc
     WHERE oc.catalog_cd=syn.catalog_cd
      AND ((cat_surgery_ind=0) OR (oc.surgery_ind=1)) )
    DETAIL
     already_matched = 0, another_fac = 0
     FOR (x = 1 TO tot_nbr_one_matches)
       IF ((oc.concept_cki=one_to_one_match->olist[x].concept_cki))
        IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
         already_matched = 1
        ELSE
         another_fac = 1
        ENDIF
       ENDIF
     ENDFOR
     IF (already_matched=0)
      tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
      IF (one_match_count > 100)
       stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 0
      ENDIF
      one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = syn.catalog_cd, one_to_one_match->
      olist[tot_nbr_one_matches].facility = client_orderable_list->orderable[d.seq].facility,
      one_to_one_match->olist[tot_nbr_one_matches].concept_cki = oc.concept_cki,
      client_orderable_list->orderable[d.seq].match_ind = 1, match_count = (match_count+ 1),
      tot_match = (tot_match+ 1)
      IF (match_count > 100)
       stat = alterlist(reply->matches,(tot_match+ 100)), match_count = 0
      ENDIF
      stat = alterlist(reply->matches[tot_match].possible_match,1), tot_poss_match = 1, reply->
      matches[tot_match].oc_id = client_orderable_list->orderable[d.seq].oc_id,
      reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility, reply->
      matches[tot_match].short_desc = trim(client_orderable_list->orderable[d.seq].short_desc), reply
      ->matches[tot_match].long_desc = trim(client_orderable_list->orderable[d.seq].long_desc),
      reply->matches[tot_match].possible_match[1].catalog_code_value = syn.catalog_cd, reply->
      matches[tot_match].possible_match[1].primary_name = oc.primary_mnemonic, reply->matches[
      tot_match].possible_match[1].description = oc.description,
      reply->matches[tot_match].possible_match[1].match_value = syn.mnemonic, reply->matches[
      tot_match].possible_match[1].match_type = 1
      IF (another_fac=1)
       reply->matches[tot_match].possible_match[1].already_matched_ind = 1
      ELSE
       reply->matches[tot_match].possible_match[1].already_matched_ind = 0
      ENDIF
     ENDIF
    WITH skipbedrock = 1, nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
     br_auto_oc_synonym syn,
     br_auto_order_catalog oc
    PLAN (d
     WHERE (client_orderable_list->orderable[d.seq].match_ind=0))
     JOIN (syn
     WHERE (((syn.mnemonic_key_cap=client_orderable_list->orderable[d.seq].short_desc)) OR ((syn
     .mnemonic_key_cap=client_orderable_list->orderable[d.seq].long_desc)))
      AND syn.mnemonic_type_cd=dcp_code_value
      AND (syn.catalog_type_cd=request->filters.catalog_type_code_value)
      AND (((((syn.activity_type_cd=request->filters.activity_type_code_value)) OR ((request->filters
     .activity_type_code_value=0))) ) OR (cat_surgery_ind=1))
      AND (((((syn.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
     filters.subactivity_type_code_value=0))) ) OR (cat_surgery_ind=1)) )
     JOIN (oc
     WHERE oc.catalog_cd=syn.catalog_cd
      AND cat_surgery_ind=0
      AND oc.surgery_ind=1)
    DETAIL
     already_matched = 0, another_fac = 0
     FOR (x = 1 TO tot_nbr_one_matches)
       IF ((oc.concept_cki=one_to_one_match->olist[x].concept_cki))
        IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
         already_matched = 1
        ELSE
         another_fac = 1
        ENDIF
       ENDIF
     ENDFOR
     IF (already_matched=0)
      tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
      IF (one_match_count > 100)
       stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 0
      ENDIF
      one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = syn.catalog_cd, one_to_one_match->
      olist[tot_nbr_one_matches].facility = client_orderable_list->orderable[d.seq].facility,
      one_to_one_match->olist[tot_nbr_one_matches].concept_cki = oc.concept_cki,
      client_orderable_list->orderable[d.seq].match_ind = 1, match_count = (match_count+ 1),
      tot_match = (tot_match+ 1)
      IF (match_count > 100)
       stat = alterlist(reply->matches,(tot_match+ 100)), match_count = 0
      ENDIF
      stat = alterlist(reply->matches[tot_match].possible_match,1), tot_poss_match = 1, reply->
      matches[tot_match].oc_id = client_orderable_list->orderable[d.seq].oc_id,
      reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility, reply->
      matches[tot_match].short_desc = trim(client_orderable_list->orderable[d.seq].short_desc), reply
      ->matches[tot_match].long_desc = trim(client_orderable_list->orderable[d.seq].long_desc),
      reply->matches[tot_match].possible_match[1].catalog_code_value = syn.catalog_cd, reply->
      matches[tot_match].possible_match[1].primary_name = oc.primary_mnemonic, reply->matches[
      tot_match].possible_match[1].description = oc.description,
      reply->matches[tot_match].possible_match[1].match_value = syn.mnemonic, reply->matches[
      tot_match].possible_match[1].match_type = 1
      IF (another_fac=1)
       reply->matches[tot_match].possible_match[1].already_matched_ind = 1
      ELSE
       reply->matches[tot_match].possible_match[1].already_matched_ind = 0
      ENDIF
     ENDIF
    WITH skipbedrock = 1, nocounter
   ;end select
  ENDIF
  SET stat = alterlist(reply->matches,tot_match)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp_reply->matches,100)
 IF ((request->load.match_type=2))
  CALL echo("loading other names")
  IF (tot_nbr_client_orderables > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
     br_other_names bon,
     order_catalog orc
    PLAN (d
     WHERE (client_orderable_list->orderable[d.seq].match_ind=0))
     JOIN (bon
     WHERE bon.parent_entity_name="CODE_VALUE"
      AND (bon.alias_name_key_cap=client_orderable_list->orderable[d.seq].short_desc))
     JOIN (orc
     WHERE orc.primary_mnemonic != "zz*"
      AND orc.orderable_type_flag != 6
      AND orc.orderable_type_flag != 2
      AND orc.catalog_cd=bon.parent_entity_id
      AND ((orc.catalog_type_cd+ 0)=request->filters.catalog_type_code_value)
      AND ((((orc.activity_type_cd+ 0)=request->filters.activity_type_code_value)) OR ((request->
     filters.activity_type_code_value=0)))
      AND (((orc.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
     filters.subactivity_type_code_value=0))) )
    DETAIL
     already_matched = 0, another_fac = 0
     FOR (x = 1 TO tot_nbr_one_matches)
       IF ((orc.concept_cki=one_to_one_match->olist[x].concept_cki))
        IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
         already_matched = 1
        ELSE
         another_fac = 1
        ENDIF
       ENDIF
     ENDFOR
     IF (already_matched=0)
      tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
      IF (one_match_count > 100)
       stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 0
      ENDIF
      one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = bon.parent_entity_id,
      one_to_one_match->olist[tot_nbr_one_matches].facility = client_orderable_list->orderable[d.seq]
      .facility, one_to_one_match->olist[tot_nbr_one_matches].concept_cki = orc.concept_cki,
      client_orderable_list->orderable[d.seq].match_ind = 1, match_count = (match_count+ 1),
      tot_match = (tot_match+ 1)
      IF (match_count > 100)
       stat = alterlist(temp_reply->matches,(tot_match+ 100)), match_count = 0
      ENDIF
      stat = alterlist(temp_reply->matches[tot_match].possible_match,1), tot_poss_match = 1,
      temp_reply->matches[tot_match].oc_id = client_orderable_list->orderable[d.seq].oc_id,
      temp_reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility,
      temp_reply->matches[tot_match].short_desc = client_orderable_list->orderable[d.seq].short_desc,
      temp_reply->matches[tot_match].long_desc = client_orderable_list->orderable[d.seq].long_desc,
      temp_reply->matches[tot_match].possible_match[1].catalog_code_value = bon.parent_entity_id,
      temp_reply->matches[tot_match].possible_match[1].primary_name = orc.primary_mnemonic,
      temp_reply->matches[tot_match].possible_match[1].description = orc.description,
      temp_reply->matches[tot_match].possible_match[1].match_value = bon.alias_name, temp_reply->
      matches[tot_match].possible_match[1].match_type = 2, temp_reply->matches[tot_match].
      possible_match[1].concept_cki = orc.concept_cki
      IF (another_fac=1)
       temp_reply->matches[tot_match].possible_match[1].already_matched_ind = 1
      ELSE
       temp_reply->matches[tot_match].possible_match[1].already_matched_ind = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
     br_other_names bon,
     order_catalog orc
    PLAN (d
     WHERE (client_orderable_list->orderable[d.seq].match_ind=0))
     JOIN (bon
     WHERE bon.parent_entity_name="CODE_VALUE"
      AND (bon.alias_name_key_cap=client_orderable_list->orderable[d.seq].long_desc))
     JOIN (orc
     WHERE orc.catalog_cd=bon.parent_entity_id
      AND orc.primary_mnemonic != "zz*"
      AND orc.orderable_type_flag != 6
      AND orc.orderable_type_flag != 2
      AND ((orc.catalog_type_cd+ 0)=request->filters.catalog_type_code_value)
      AND ((((orc.activity_type_cd+ 0)=request->filters.activity_type_code_value)) OR ((request->
     filters.activity_type_code_value=0)))
      AND (((orc.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
     filters.subactivity_type_code_value=0))) )
    DETAIL
     already_matched = 0, another_fac = 0
     FOR (x = 1 TO tot_nbr_one_matches)
       IF ((orc.concept_cki=one_to_one_match->olist[x].concept_cki))
        IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
         already_matched = 1
        ELSE
         another_fac = 1
        ENDIF
       ENDIF
     ENDFOR
     IF (already_matched=0)
      tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
      IF (one_match_count > 100)
       stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 0
      ENDIF
      one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = bon.parent_entity_id,
      one_to_one_match->olist[tot_nbr_one_matches].facility = client_orderable_list->orderable[d.seq]
      .facility, one_to_one_match->olist[tot_nbr_one_matches].concept_cki = orc.concept_cki,
      client_orderable_list->orderable[d.seq].match_ind = 1, match_count = (match_count+ 1),
      tot_match = (tot_match+ 1)
      IF (match_count > 100)
       stat = alterlist(temp_reply->matches,(tot_match+ 100)), match_count = 0
      ENDIF
      stat = alterlist(temp_reply->matches[tot_match].possible_match,1), tot_poss_match = 1,
      temp_reply->matches[tot_match].oc_id = client_orderable_list->orderable[d.seq].oc_id,
      temp_reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility,
      temp_reply->matches[tot_match].short_desc = client_orderable_list->orderable[d.seq].short_desc,
      temp_reply->matches[tot_match].long_desc = client_orderable_list->orderable[d.seq].long_desc,
      temp_reply->matches[tot_match].possible_match[1].catalog_code_value = bon.parent_entity_id,
      temp_reply->matches[tot_match].possible_match[1].primary_name = orc.primary_mnemonic,
      temp_reply->matches[tot_match].possible_match[1].description = orc.description,
      temp_reply->matches[tot_match].possible_match[1].match_value = bon.alias_name, temp_reply->
      matches[tot_match].possible_match[1].match_type = 2, temp_reply->matches[tot_match].
      possible_match[1].concept_cki = orc.concept_cki
      IF (another_fac=1)
       temp_reply->matches[tot_match].possible_match[1].already_matched_ind = 1
      ELSE
       temp_reply->matches[tot_match].possible_match[1].already_matched_ind = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL echo("loading autobuild other names")
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
     br_other_names bon,
     br_auto_order_catalog orc
    PLAN (d
     WHERE (client_orderable_list->orderable[d.seq].match_ind=0))
     JOIN (bon
     WHERE bon.parent_entity_name="CODE_VALUE"
      AND (bon.alias_name_key_cap=client_orderable_list->orderable[d.seq].short_desc))
     JOIN (orc
     WHERE orc.catalog_cd=bon.parent_entity_id
      AND ((orc.catalog_type_cd+ 0)=request->filters.catalog_type_code_value)
      AND ((((((orc.activity_type_cd+ 0)=request->filters.activity_type_code_value)) OR ((request->
     filters.activity_type_code_value=0))) ) OR (cat_surgery_ind=1))
      AND (((((orc.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
     filters.subactivity_type_code_value=0))) ) OR (cat_surgery_ind=1))
      AND ((cat_surgery_ind=0) OR (orc.surgery_ind=1)) )
    DETAIL
     already_matched = 0, another_fac = 0
     FOR (x = 1 TO tot_nbr_one_matches)
       IF ((orc.concept_cki=one_to_one_match->olist[x].concept_cki))
        IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
         already_matched = 1
        ELSE
         another_fac = 1
        ENDIF
       ENDIF
     ENDFOR
     IF (already_matched=0)
      tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
      IF (one_match_count > 100)
       stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 0
      ENDIF
      one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = bon.parent_entity_id,
      one_to_one_match->olist[tot_nbr_one_matches].facility = client_orderable_list->orderable[d.seq]
      .facility, one_to_one_match->olist[tot_nbr_one_matches].concept_cki = orc.concept_cki,
      client_orderable_list->orderable[d.seq].match_ind = 1, match_count = (match_count+ 1),
      tot_match = (tot_match+ 1)
      IF (match_count > 100)
       stat = alterlist(temp_reply->matches,(tot_match+ 100)), match_count = 0
      ENDIF
      stat = alterlist(temp_reply->matches[tot_match].possible_match,1), tot_poss_match = 1,
      temp_reply->matches[tot_match].oc_id = client_orderable_list->orderable[d.seq].oc_id,
      temp_reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility,
      temp_reply->matches[tot_match].short_desc = client_orderable_list->orderable[d.seq].short_desc,
      temp_reply->matches[tot_match].long_desc = client_orderable_list->orderable[d.seq].long_desc,
      temp_reply->matches[tot_match].possible_match[1].catalog_code_value = bon.parent_entity_id,
      temp_reply->matches[tot_match].possible_match[1].primary_name = orc.primary_mnemonic,
      temp_reply->matches[tot_match].possible_match[1].description = orc.description,
      temp_reply->matches[tot_match].possible_match[1].match_value = bon.alias_name, temp_reply->
      matches[tot_match].possible_match[1].match_type = 2, temp_reply->matches[tot_match].
      possible_match[1].concept_cki = orc.concept_cki
      IF (another_fac=1)
       temp_reply->matches[tot_match].possible_match[1].already_matched_ind = 1
      ELSE
       temp_reply->matches[tot_match].possible_match[1].already_matched_ind = 0
      ENDIF
     ENDIF
    WITH skipbedrock = 1, nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
     br_other_names bon,
     br_auto_order_catalog orc
    PLAN (d
     WHERE (client_orderable_list->orderable[d.seq].match_ind=0))
     JOIN (bon
     WHERE bon.parent_entity_name="CODE_VALUE"
      AND (bon.alias_name_key_cap=client_orderable_list->orderable[d.seq].long_desc))
     JOIN (orc
     WHERE orc.catalog_cd=bon.parent_entity_id
      AND ((orc.catalog_type_cd+ 0)=request->filters.catalog_type_code_value)
      AND ((((((orc.activity_type_cd+ 0)=request->filters.activity_type_code_value)) OR ((request->
     filters.activity_type_code_value=0))) ) OR (cat_surgery_ind=1))
      AND (((((orc.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
     filters.subactivity_type_code_value=0))) ) OR (cat_surgery_ind=1))
      AND ((cat_surgery_ind=0) OR (orc.surgery_ind=1)) )
    DETAIL
     already_matched = 0, another_fac = 0
     FOR (x = 1 TO tot_nbr_one_matches)
       IF ((orc.concept_cki=one_to_one_match->olist[x].concept_cki))
        IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
         already_matched = 1
        ELSE
         another_fac = 1
        ENDIF
       ENDIF
     ENDFOR
     IF (already_matched=0)
      tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
      IF (one_match_count > 100)
       stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 0
      ENDIF
      one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = bon.parent_entity_id,
      one_to_one_match->olist[tot_nbr_one_matches].facility = client_orderable_list->orderable[d.seq]
      .facility, one_to_one_match->olist[tot_nbr_one_matches].concept_cki = orc.concept_cki,
      client_orderable_list->orderable[d.seq].match_ind = 1, match_count = (match_count+ 1),
      tot_match = (tot_match+ 1)
      IF (match_count > 100)
       stat = alterlist(temp_reply->matches,(tot_match+ 100)), match_count = 0
      ENDIF
      stat = alterlist(temp_reply->matches[tot_match].possible_match,1), tot_poss_match = 1,
      temp_reply->matches[tot_match].oc_id = client_orderable_list->orderable[d.seq].oc_id,
      temp_reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility,
      temp_reply->matches[tot_match].short_desc = client_orderable_list->orderable[d.seq].short_desc,
      temp_reply->matches[tot_match].long_desc = client_orderable_list->orderable[d.seq].long_desc,
      temp_reply->matches[tot_match].possible_match[1].catalog_code_value = bon.parent_entity_id,
      temp_reply->matches[tot_match].possible_match[1].primary_name = orc.primary_mnemonic,
      temp_reply->matches[tot_match].possible_match[1].description = orc.description,
      temp_reply->matches[tot_match].possible_match[1].match_value = bon.alias_name, temp_reply->
      matches[tot_match].possible_match[1].match_type = 2, temp_reply->matches[tot_match].
      possible_match[1].concept_cki = orc.concept_cki
      IF (another_fac=1)
       temp_reply->matches[tot_match].possible_match[1].already_matched_ind = 1
      ELSE
       temp_reply->matches[tot_match].possible_match[1].already_matched_ind = 0
      ENDIF
     ENDIF
    WITH skipbedrock = 1, nocounter
   ;end select
  ENDIF
 ENDIF
 IF (tot_nbr_client_orderables > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
    br_auto_order_catalog orc
   PLAN (d
    WHERE (client_orderable_list->orderable[d.seq].match_ind=0)
     AND (client_orderable_list->orderable[d.seq].loinc_code > "    *"))
    JOIN (orc
    WHERE (orc.loinc=client_orderable_list->orderable[d.seq].loinc_code))
   HEAD d.seq
    stat = alterlist(client_orderable_list->orderable[d.seq].llist,20), count = 0, tot_count = 0
   DETAIL
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (count > 20)
     stat = alterlist(client_orderable_list->orderable[d.seq].llist,(tot_count+ 20)), count = 1
    ENDIF
    client_orderable_list->orderable[d.seq].llist[tot_count].concept_cki = orc.concept_cki
   FOOT  d.seq
    stat = alterlist(client_orderable_list->orderable[d.seq].llist,tot_count)
   WITH skipbedrock = 1, nocounter
  ;end select
 ENDIF
 SET stat = alterlist(client_orderable_list->orderable,tot_nbr_client_orderables)
 FOR (i = 1 TO tot_nbr_client_orderables)
   IF ((client_orderable_list->orderable[i].match_ind=0))
    IF (size(client_orderable_list->orderable[i].llist,5) > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = size(client_orderable_list->orderable[i].llist,5)),
       order_catalog orc
      PLAN (d
       WHERE (client_orderable_list->orderable[i].llist[d.seq].concept_cki > "    *"))
       JOIN (orc
       WHERE orc.primary_mnemonic != "zz*"
        AND (orc.concept_cki=client_orderable_list->orderable[i].llist[d.seq].concept_cki)
        AND orc.orderable_type_flag != 6
        AND orc.orderable_type_flag != 2
        AND ((orc.catalog_type_cd+ 0)=request->filters.catalog_type_code_value)
        AND ((((orc.activity_type_cd+ 0)=request->filters.activity_type_code_value)) OR ((request->
       filters.activity_type_code_value=0)))
        AND (((orc.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
       filters.subactivity_type_code_value=0))) )
      HEAD d.seq
       already_matched = 0, already_fac = 0
       FOR (x = 1 TO tot_nbr_one_matches)
         IF ((orc.concept_cki=one_to_one_match->olist[x].concept_cki))
          IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
           already_matched = 1
          ELSE
           another_fac = 1
          ENDIF
         ENDIF
       ENDFOR
       IF (already_matched=0)
        IF ((temp_reply->matches[tot_match].oc_id != client_orderable_list->orderable[i].oc_id))
         match_count = (match_count+ 1), tot_match = (tot_match+ 1)
         IF (match_count > 100)
          stat = alterlist(temp_reply->matches,(tot_match+ 100)), match_count = 0
         ENDIF
         stat = alterlist(temp_reply->matches[tot_match].possible_match,5), tot_poss_match = 0,
         poss_match_count = 0,
         temp_reply->matches[tot_match].oc_id = client_orderable_list->orderable[d.seq].oc_id,
         temp_reply->matches[tot_match].facility = client_orderable_list->orderable[d.seq].facility,
         temp_reply->matches[tot_match].short_desc = trim(client_orderable_list->orderable[d.seq].
          short_desc),
         temp_reply->matches[tot_match].long_desc = trim(client_orderable_list->orderable[d.seq].
          long_desc)
        ENDIF
       ENDIF
       IF (already_matched=0)
        client_orderable_list->orderable[i].match_ind = 4, poss_match_count = (poss_match_count+ 1),
        tot_poss_match = (tot_poss_match+ 1)
        IF (poss_match_count > 5)
         stat = alterlist(temp_reply->matches[tot_match].possible_match,(tot_poss_match+ 5)),
         poss_match_count = 1
        ENDIF
        temp_reply->matches[tot_match].possible_match[tot_poss_match].catalog_code_value = orc
        .catalog_cd, temp_reply->matches[tot_match].possible_match[tot_poss_match].primary_name = orc
        .primary_mnemonic, temp_reply->matches[tot_match].possible_match[tot_poss_match].description
         = orc.description,
        temp_reply->matches[tot_match].possible_match[tot_poss_match].match_value = trim(
         client_orderable_list->orderable[i].loinc_code), temp_reply->matches[tot_match].
        possible_match[tot_poss_match].match_type = 4, temp_reply->matches[tot_match].possible_match[
        tot_poss_match].concept_cki = orc.concept_cki
        IF (another_fac=1)
         temp_reply->matches[tot_match].possible_match[1].already_matched_ind = 1
        ELSE
         temp_reply->matches[tot_match].possible_match[1].already_matched_ind = 0
        ENDIF
       ENDIF
      FOOT REPORT
       IF (tot_match > 0)
        stat = alterlist(temp_reply->matches[tot_match].possible_match,tot_poss_match)
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("checking cpt4")
 IF (tot_nbr_client_orderables > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
    br_auto_order_catalog orc
   PLAN (d
    WHERE (client_orderable_list->orderable[d.seq].match_ind=0)
     AND (client_orderable_list->orderable[d.seq].cpt4_code > "    *"))
    JOIN (orc
    WHERE (orc.cpt4=client_orderable_list->orderable[d.seq].cpt4_code))
   HEAD d.seq
    stat = alterlist(client_orderable_list->orderable[d.seq].clist,20), count = 0, tot_count = 0
   DETAIL
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (count > 20)
     stat = alterlist(client_orderable_list->orderable[d.seq].clist,(tot_count+ 20)), count = 1
    ENDIF
    client_orderable_list->orderable[d.seq].clist[tot_count].concept_cki = orc.concept_cki
   FOOT  d.seq
    stat = alterlist(client_orderable_list->orderable[d.seq].clist,tot_count)
   WITH skipbedrock = 1, nocounter
  ;end select
 ENDIF
 SET stat = alterlist(client_orderable_list->orderable,tot_nbr_client_orderables)
 FOR (i = 1 TO tot_nbr_client_orderables)
   IF ((client_orderable_list->orderable[i].match_ind=0))
    IF (size(client_orderable_list->orderable[i].clist,5) > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = size(client_orderable_list->orderable[i].clist,5)),
       order_catalog orc
      PLAN (d
       WHERE (client_orderable_list->orderable[i].clist[d.seq].concept_cki > "    *"))
       JOIN (orc
       WHERE orc.primary_mnemonic != "zz*"
        AND (orc.concept_cki=client_orderable_list->orderable[i].clist[d.seq].concept_cki)
        AND orc.orderable_type_flag != 6
        AND orc.orderable_type_flag != 2
        AND ((orc.catalog_type_cd+ 0)=request->filters.catalog_type_code_value)
        AND ((((orc.activity_type_cd+ 0)=request->filters.activity_type_code_value)) OR ((request->
       filters.activity_type_code_value=0)))
        AND (((orc.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
       filters.subactivity_type_code_value=0))) )
      HEAD d.seq
       already_matched = 0, another_fac = 0
       FOR (x = 1 TO tot_nbr_one_matches)
         IF ((orc.concept_cki=one_to_one_match->olist[x].concept_cki))
          IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
           already_matched = 1
          ELSE
           another_fac = 1
          ENDIF
         ENDIF
       ENDFOR
       IF (already_matched=0)
        IF ((temp_reply->matches[tot_match].oc_id != client_orderable_list->orderable[i].oc_id))
         match_count = (match_count+ 1), tot_match = (tot_match+ 1)
         IF (match_count > 100)
          stat = alterlist(temp_reply->matches,(tot_match+ 100)), match_count = 0
         ENDIF
         stat = alterlist(temp_reply->matches[tot_match].possible_match,5), tot_poss_match = 0,
         poss_match_count = 0,
         temp_reply->matches[tot_match].oc_id = client_orderable_list->orderable[i].oc_id, temp_reply
         ->matches[tot_match].facility = client_orderable_list->orderable[i].facility, temp_reply->
         matches[tot_match].short_desc = trim(client_orderable_list->orderable[i].short_desc),
         temp_reply->matches[tot_match].long_desc = trim(client_orderable_list->orderable[i].
          long_desc)
        ENDIF
       ENDIF
       IF (already_matched=0)
        client_orderable_list->orderable[i].match_ind = 3, poss_match_count = (poss_match_count+ 1),
        tot_poss_match = (tot_poss_match+ 1)
        IF (poss_match_count > 5)
         stat = alterlist(temp_reply->matches[tot_match].possible_match,(tot_poss_match+ 5)),
         poss_match_count = 1
        ENDIF
        temp_reply->matches[tot_match].possible_match[tot_poss_match].catalog_code_value = orc
        .catalog_cd, temp_reply->matches[tot_match].possible_match[tot_poss_match].primary_name = orc
        .primary_mnemonic, temp_reply->matches[tot_match].possible_match[tot_poss_match].description
         = orc.description,
        temp_reply->matches[tot_match].possible_match[tot_poss_match].match_value = trim(
         client_orderable_list->orderable[i].cpt4_code), temp_reply->matches[tot_match].
        possible_match[tot_poss_match].match_type = 3, temp_reply->matches[tot_match].possible_match[
        tot_poss_match].concept_cki = orc.concept_cki
        IF (another_fac=1)
         temp_reply->matches[tot_match].possible_match[1].already_matched_ind = 1
        ELSE
         temp_reply->matches[tot_match].possible_match[1].already_matched_ind = 0
        ENDIF
       ENDIF
      FOOT REPORT
       IF (tot_match > 0)
        stat = alterlist(temp_reply->matches[tot_match].possible_match,tot_poss_match)
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("checking autobuild cpt4")
 IF (tot_nbr_client_orderables > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
    br_auto_order_catalog orc
   PLAN (d
    WHERE (client_orderable_list->orderable[d.seq].match_ind != 1)
     AND (client_orderable_list->orderable[d.seq].cpt4_code > "    *"))
    JOIN (orc
    WHERE orc.cpt4=trim(client_orderable_list->orderable[d.seq].cpt4_code)
     AND ((orc.catalog_type_cd+ 0)=request->filters.catalog_type_code_value)
     AND ((((((orc.activity_type_cd+ 0)=request->filters.activity_type_code_value)) OR ((request->
    filters.activity_type_code_value=0))) ) OR (cat_surgery_ind=1))
     AND (((((orc.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
    filters.subactivity_type_code_value=0))) ) OR (cat_surgery_ind=1))
     AND ((cat_surgery_ind=0) OR (orc.surgery_ind=1)) )
   HEAD d.seq
    reply_count = 0
    FOR (y = 1 TO tot_match)
      IF ((temp_reply->matches[y].oc_id=client_orderable_list->orderable[d.seq].oc_id)
       AND (temp_reply->matches[y].facility=client_orderable_list->orderable[d.seq].facility))
       reply_count = y, tot_poss_match = size(temp_reply->matches[reply_count].possible_match,5),
       stat = alterlist(temp_reply->matches[reply_count].possible_match,(tot_poss_match+ 5)),
       poss_match_count = 0, y = (tot_match+ 1)
      ENDIF
    ENDFOR
   DETAIL
    already_matched = 0, another_fac = 0
    FOR (x = 1 TO tot_nbr_one_matches)
      IF ((orc.concept_cki=one_to_one_match->olist[x].concept_cki))
       IF ((client_orderable_list->orderable[d.seq].facility=one_to_one_match->olist[x].facility))
        already_matched = 1
       ELSE
        another_fac = 1
       ENDIF
      ENDIF
    ENDFOR
    IF (already_matched=0)
     IF (reply_count=0)
      match_count = (match_count+ 1), tot_match = (tot_match+ 1), reply_count = tot_match
      IF (match_count > 100)
       stat = alterlist(temp_reply->matches,(tot_match+ 100)), match_count = 0
      ENDIF
      stat = alterlist(temp_reply->matches[reply_count].possible_match,5), client_orderable_list->
      orderable[d.seq].match_ind = 3, temp_reply->matches[reply_count].oc_id = client_orderable_list
      ->orderable[d.seq].oc_id,
      temp_reply->matches[reply_count].facility = client_orderable_list->orderable[d.seq].facility,
      temp_reply->matches[reply_count].short_desc = trim(client_orderable_list->orderable[d.seq].
       short_desc), temp_reply->matches[reply_count].long_desc = trim(client_orderable_list->
       orderable[d.seq].long_desc),
      poss_match_count = 0, tot_poss_match = 0, stat = alterlist(temp_reply->matches[reply_count].
       possible_match,5)
     ENDIF
     found_concept = 0
     IF (tot_poss_match > 0)
      FOR (i = 1 TO tot_poss_match)
        IF ((temp_reply->matches[reply_count].possible_match[i].concept_cki=orc.concept_cki))
         i = tot_poss_match, found_concept = 1
        ENDIF
      ENDFOR
     ENDIF
     IF (found_concept=0)
      poss_match_count = (poss_match_count+ 1), tot_poss_match = (tot_poss_match+ 1)
      IF (poss_match_count > 5)
       stat = alterlist(temp_reply->matches[reply_count].possible_match,(tot_poss_match+ 5)),
       poss_match_count = 1
      ENDIF
      temp_reply->matches[reply_count].possible_match[tot_poss_match].catalog_code_value = orc
      .catalog_cd, temp_reply->matches[reply_count].possible_match[tot_poss_match].primary_name = orc
      .primary_mnemonic, temp_reply->matches[reply_count].possible_match[tot_poss_match].description
       = orc.description,
      temp_reply->matches[reply_count].possible_match[tot_poss_match].match_value = trim(
       client_orderable_list->orderable[d.seq].cpt4_code), temp_reply->matches[reply_count].
      possible_match[tot_poss_match].match_type = 3
      IF (another_fac=1)
       temp_reply->matches[reply_count].possible_match[1].already_matched_ind = 1
      ELSE
       temp_reply->matches[reply_count].possible_match[1].already_matched_ind = 0
      ENDIF
     ENDIF
    ENDIF
   FOOT  d.seq
    IF (reply_count > 0)
     stat = alterlist(temp_reply->matches[reply_count].possible_match,tot_poss_match)
    ENDIF
   WITH skipbedrock = 1, nocounter
  ;end select
 ENDIF
 SET stat = alterlist(temp_reply->matches,tot_match)
 SET icnt = tot_match
 FOR (i = 1 TO tot_match)
   IF (i <= icnt)
    SET match_cnt = size(temp_reply->matches[i].possible_match,5)
    IF (match_cnt=1)
     IF ((request->load.match_type=3))
      SET icnt = (icnt - 1)
      SET i = (i - 1)
      SET stat = alterlist(temp_reply->matches,icnt,i)
     ENDIF
    ELSE
     IF ((request->load.multi_value_ind != 1))
      SET stat = alterlist(temp_reply->matches[i].possible_match,0)
     ENDIF
     IF ((request->load.match_type=2))
      SET icnt = (icnt - 1)
      SET i = (i - 1)
      SET stat = alterlist(temp_reply->matches,icnt,i)
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->matches,icnt)
 SET stat = alterlist(temp_reply->matches,icnt)
 IF (icnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = icnt)
   HEAD d.seq
    reply->matches[d.seq].oc_id = temp_reply->matches[d.seq].oc_id, reply->matches[d.seq].facility =
    temp_reply->matches[d.seq].facility, reply->matches[d.seq].short_desc = temp_reply->matches[d.seq
    ].short_desc,
    reply->matches[d.seq].long_desc = temp_reply->matches[d.seq].long_desc
   DETAIL
    tot_poss_match = size(temp_reply->matches[d.seq].possible_match,5), stat = alterlist(reply->
     matches[d.seq].possible_match,tot_poss_match)
    FOR (x = 1 TO tot_poss_match)
      reply->matches[d.seq].possible_match[x].catalog_code_value = temp_reply->matches[d.seq].
      possible_match[x].catalog_code_value, reply->matches[d.seq].possible_match[x].primary_name =
      temp_reply->matches[d.seq].possible_match[x].primary_name, reply->matches[d.seq].
      possible_match[x].description = temp_reply->matches[d.seq].possible_match[x].description,
      reply->matches[d.seq].possible_match[x].match_value = temp_reply->matches[d.seq].
      possible_match[x].match_value, reply->matches[d.seq].possible_match[x].match_type = temp_reply
      ->matches[d.seq].possible_match[x].match_type, reply->matches[d.seq].possible_match[x].
      already_matched_ind = temp_reply->matches[d.seq].possible_match[x].already_matched_ind
    ENDFOR
  ;end select
 ENDIF
 GO TO exit_script
#exit_script
 SET tot_match = size(reply->matches,5)
 IF (tot_match > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_match)
   PLAN (d
    WHERE (reply->matches[d.seq].oc_id > 0)
     AND size(reply->matches[d.seq].possible_match,5) > 0)
   DETAIL
    reply->matches[d.seq].possible_match[1].already_matched_ind = 0
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_match),
    br_oc_work b
   PLAN (d
    WHERE (reply->matches[d.seq].oc_id > 0)
     AND size(reply->matches[d.seq].possible_match,5) > 0)
    JOIN (b
    WHERE (b.match_orderable_cd=reply->matches[d.seq].possible_match[1].catalog_code_value)
     AND (b.facility != reply->matches[d.seq].facility))
   DETAIL
    reply->matches[d.seq].possible_match[1].already_matched_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_match),
    br_auto_order_catalog b,
    order_catalog oc,
    code_value cv,
    br_oc_work bw
   PLAN (d
    WHERE (reply->matches[d.seq].oc_id > 0)
     AND size(reply->matches[d.seq].possible_match,5) > 0)
    JOIN (b
    WHERE (b.catalog_cd=reply->matches[d.seq].possible_match[1].catalog_code_value))
    JOIN (oc
    WHERE oc.primary_mnemonic=b.primary_mnemonic)
    JOIN (cv
    WHERE cv.code_set=outerjoin(200)
     AND cv.code_value=outerjoin(b.catalog_cd))
    JOIN (bw
    WHERE bw.match_orderable_cd=outerjoin(oc.catalog_cd)
     AND bw.facility != outerjoin(reply->matches[d.seq].facility))
   DETAIL
    IF (cv.code_value=0
     AND bw.oc_id > 0)
     reply->matches[d.seq].possible_match[1].already_matched_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_match),
    br_auto_order_catalog b,
    order_catalog oc,
    code_value cv,
    br_oc_work bw
   PLAN (d
    WHERE (reply->matches[d.seq].oc_id > 0)
     AND size(reply->matches[d.seq].possible_match,5) > 0)
    JOIN (b
    WHERE (b.catalog_cd=reply->matches[d.seq].possible_match[1].catalog_code_value))
    JOIN (oc
    WHERE oc.concept_cki=b.concept_cki)
    JOIN (cv
    WHERE cv.code_set=outerjoin(200)
     AND cv.code_value=outerjoin(b.catalog_cd))
    JOIN (bw
    WHERE bw.match_orderable_cd=outerjoin(oc.catalog_cd)
     AND bw.facility != outerjoin(reply->matches[d.seq].facility))
   DETAIL
    IF (cv.code_value=0
     AND bw.oc_id > 0)
     reply->matches[d.seq].possible_match[1].already_matched_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (tot_match=0)
  SET reply->status_data.status = "Z"
 ELSEIF (tot_match > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
