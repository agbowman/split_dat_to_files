CREATE PROGRAM bed_get_oc_multi_match_fac:dba
 FREE SET reply
 RECORD reply(
   1 possible_match[*]
     2 primary_name = c100
     2 description = c100
     2 catalog_code_value = f8
     2 match_type = i2
     2 match_value = c100
     2 already_matched_ind = i2
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
   1 possible_match[*]
     2 primary_name = c100
     2 description = c100
     2 catalog_code_value = f8
     2 match_type = i2
     2 match_value = c100
     2 already_matched_ind = i2
     2 concept_cki = vc
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
 )
 FREE SET one_to_one_match
 RECORD one_to_one_match(
   1 olist[*]
     2 catalog_cd = f8
     2 facility = vc
     2 concept_cki = vc
 )
 SET rec_cnt = 0
 SET tot_nbr_client_orderables = 0
 SET tot_nbr_one_matches = 0
 SET one_match_count = 0
 SET poss_match_count = 0
 SET tot_poss_match = 0
 SET already_matched = 0
 SET another_fac = 0
 SET found_match = 0
 SET count = 0
 SET tot_count = 0
 SET stat = alterlist(client_orderable_list->orderable,100)
 SET stat = alterlist(one_to_one_match->olist,100)
 SET stat = alterlist(temp_reply->possible_match,5)
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
 SET tot_nbr_client_orderables = 0
 SELECT INTO "NL:"
  upper_long = cnvtupper(b.long_desc), upper_short = cnvtupper(b.short_desc)
  FROM br_oc_work b,
   br_oc_pricing bp
  PLAN (b
   WHERE (b.oc_id=request->oc_id))
   JOIN (bp
   WHERE bp.oc_id=outerjoin(b.oc_id)
    AND bp.billcode_sched_cd=outerjoin(cpt4_code_value))
  HEAD REPORT
   client_orc_count = 0
  DETAIL
   tot_nbr_client_orderables = (tot_nbr_client_orderables+ 1), client_orc_count = (client_orc_count+
   1), syn_count = 0
   IF (client_orc_count > 100)
    stat = alterlist(client_orderable_list->orderable,(tot_nbr_client_orderables+ 100)),
    client_orc_count = 1
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
 SET stat = alterlist(client_orderable_list->orderable,tot_nbr_client_orderables)
 SELECT INTO "NL:"
  FROM br_oc_work b
  WHERE b.match_orderable_cd > 0
  HEAD REPORT
   tot_nbr_one_matches = 0, one_match_count = 0
  DETAIL
   tot_nbr_one_matches = (tot_nbr_one_matches+ 1), one_match_count = (one_match_count+ 1)
   IF (one_match_count > 100)
    stat = alterlist(one_to_one_match->olist,(tot_nbr_one_matches+ 100)), one_match_count = 1
   ENDIF
   one_to_one_match->olist[tot_nbr_one_matches].catalog_cd = b.match_orderable_cd, one_to_one_match->
   olist[tot_nbr_one_matches].facility = b.facility
  WITH nocounter
 ;end select
 SET stat = alterlist(one_to_one_match->olist,tot_nbr_one_matches)
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
 SET tot_poss_match = 0
 SET poss_match_count = 0
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
 IF (tot_nbr_client_orderables > 0
  AND tot_count > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
    (dummyt d2  WITH seq = tot_count),
    order_catalog orc
   PLAN (d
    WHERE (client_orderable_list->orderable[d.seq].match_ind=0))
    JOIN (d2
    WHERE (client_orderable_list->orderable[d.seq].clist[d2.seq].concept_cki > "    *"))
    JOIN (orc
    WHERE orc.primary_mnemonic != "zz*"
     AND (orc.concept_cki=client_orderable_list->orderable[d.seq].clist[d2.seq].concept_cki)
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
     poss_match_count = (poss_match_count+ 1), tot_poss_match = (tot_poss_match+ 1)
     IF (poss_match_count > 5)
      stat = alterlist(temp_reply->possible_match,(tot_poss_match+ 5)), poss_match_count = 1
     ENDIF
     temp_reply->possible_match[tot_poss_match].catalog_code_value = orc.catalog_cd, temp_reply->
     possible_match[tot_poss_match].primary_name = orc.primary_mnemonic, temp_reply->possible_match[
     tot_poss_match].description = orc.description,
     temp_reply->possible_match[tot_poss_match].match_value = trim(client_orderable_list->orderable[d
      .seq].cpt4_code), temp_reply->possible_match[tot_poss_match].match_type = 3, temp_reply->
     possible_match[tot_poss_match].concept_cki = orc.concept_cki
     IF (another_fac=1)
      temp_reply->possible_match[tot_poss_match].already_matched_ind = 1
     ELSE
      temp_reply->possible_match[tot_poss_match].already_matched_ind = 0
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (tot_nbr_client_orderables > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_nbr_client_orderables),
    br_auto_order_catalog orc
   PLAN (d
    WHERE (client_orderable_list->orderable[d.seq].match_ind=0)
     AND (client_orderable_list->orderable[d.seq].cpt4_code > "    *"))
    JOIN (orc
    WHERE orc.cpt4=trim(client_orderable_list->orderable[d.seq].cpt4_code)
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
        already_matched = 1, x = (tot_nbr_one_matches+ 1)
       ELSE
        another_fac = 1
       ENDIF
      ENDIF
    ENDFOR
    IF (already_matched=0)
     FOR (x = 1 TO tot_poss_match)
       IF ((temp_reply->possible_match[x].catalog_code_value=orc.catalog_cd))
        already_matched = 1, x = (tot_poss_match+ 1)
       ENDIF
     ENDFOR
    ENDIF
    IF (already_matched=0)
     found_concept = 0
     IF (tot_poss_match > 0)
      FOR (i = 1 TO tot_poss_match)
        IF ((temp_reply->possible_match[i].concept_cki=orc.concept_cki))
         i = tot_poss_match, found_concept = 1
        ENDIF
      ENDFOR
     ENDIF
     IF (found_concept=0)
      poss_match_count = (poss_match_count+ 1), tot_poss_match = (tot_poss_match+ 1)
      IF (poss_match_count > 5)
       stat = alterlist(temp_reply->possible_match,(tot_poss_match+ 5)), poss_match_count = 0
      ENDIF
      temp_reply->possible_match[tot_poss_match].catalog_code_value = orc.catalog_cd, temp_reply->
      possible_match[tot_poss_match].primary_name = orc.primary_mnemonic, temp_reply->possible_match[
      tot_poss_match].description = orc.description,
      temp_reply->possible_match[tot_poss_match].match_value = trim(client_orderable_list->orderable[
       d.seq].cpt4_code), temp_reply->possible_match[tot_poss_match].match_type = 3, temp_reply->
      possible_match[tot_poss_match].concept_cki = orc.concept_cki
      IF (another_fac=1)
       temp_reply->possible_match[tot_poss_match].already_matched_ind = 1
      ELSE
       temp_reply->possible_match[tot_poss_match].already_matched_ind = 0
      ENDIF
     ENDIF
    ENDIF
   WITH skipbedrock = 1, nocounter
  ;end select
 ENDIF
#exit_script
 SET stat = alterlist(temp_reply->possible_match,tot_poss_match)
 SET stat = alterlist(reply->possible_match,tot_poss_match)
 IF (tot_poss_match > 0)
  SELECT INTO "NL"
   FROM (dummyt d  WITH seq = tot_poss_match)
   DETAIL
    reply->possible_match[d.seq].catalog_code_value = temp_reply->possible_match[d.seq].
    catalog_code_value, reply->possible_match[d.seq].primary_name = temp_reply->possible_match[d.seq]
    .primary_name, reply->possible_match[d.seq].description = temp_reply->possible_match[d.seq].
    description,
    reply->possible_match[d.seq].match_value = temp_reply->possible_match[d.seq].match_value, reply->
    possible_match[d.seq].match_type = temp_reply->possible_match[d.seq].match_type, reply->
    possible_match[d.seq].already_matched_ind = temp_reply->possible_match[d.seq].already_matched_ind
   WITH nocounter
  ;end select
 ENDIF
 IF (tot_poss_match > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
