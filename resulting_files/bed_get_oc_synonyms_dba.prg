CREATE PROGRAM bed_get_oc_synonyms:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 olist[*]
      2 catalog_cd = f8
      2 catalog_description = c100
      2 catalog_type_cd = f8
      2 catalog_type_display = c40
      2 catalog_type_cdf_meaning = c12
      2 legacy_names[*]
        3 short_desc = vc
        3 long_desc = vc
        3 facility = vc
      2 slist[*]
        3 synonym_type_cd = f8
        3 synonym_type_display = c40
        3 synonym_type_cdf_meaning = c12
        3 synonym_id = f8
        3 synonym_name = c100
        3 order_entry_format_id = f8
        3 order_entry_format_name = c200
        3 active_ind = i2
        3 hide_flag = i2
        3 med_admin_mask = i2
        3 care_sets[*]
          4 catalog_cd = f8
          4 description = c100
        3 order_folders[*]
          4 category_id = f8
          4 long_description = c500
          4 person_id = f8
          4 name_full_formatted = vc
        3 power_plans[*]
          4 power_plan_id = f8
          4 power_plan_description = vc
        3 titratable_ind = i2
        3 synonym_facility_ind = i2
        3 facility_count = i4
      2 bedrock_synonyms[*]
        3 synonym_id = f8
        3 mnemonic = vc
        3 synonym_type
          4 code_value = f8
          4 display = vc
          4 meaning = vc
        3 order_entry_format_id = f8
      2 bedrock_dept_name = vc
      2 orderable_facility_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  )
 ENDIF
 IF ( NOT (validate(tempsynlist,0)))
  RECORD tempsynlist(
    1 slist[*]
      2 synonym_id = f8
      2 synonym_facility_ind = i2
      2 facility_count = i4
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE new_phase_x_match_ind = i2 WITH protect, noconstant(0)
 DECLARE catalog_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE activity_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE qual_parse_string = vc WITH protect, noconstant("")
 DECLARE populateparsestringbasedonrequest(dummyvar=i2) = vc
 DECLARE syn_type_size = i4 WITH protect, noconstant(0)
 DECLARE fcnt = i4 WITH protect
 DECLARE ocnt = i4 WITH protect
 DECLARE lcnt = i4 WITH protect
 DECLARE tot_syns = i4 WITH protect
 DECLARE max_cnt = i4 WITH protect
 DECLARE order_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE alterlist_scnt = i4 WITH protect
 DECLARE scnt = i4 WITH protect
 DECLARE temp_catalog_cd = f8 WITH protect
 DECLARE num = i4 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE allcounter = i4 WITH protect
 DECLARE nonecounter = i4 WITH protect
 DECLARE counter = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET ocnt = 0
 SET ocnt = size(request->oclist,5)
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->olist,ocnt)
 SELECT INTO "nl:"
  FROM order_catalog o
  PLAN (o
   WHERE (o.catalog_cd=request->oclist[1].catalog_cd))
  DETAIL
   catalog_type_cd = o.catalog_type_cd, activity_type_cd = o.activity_type_cd
  WITH nocounter
 ;end select
 CALL bederrorcheck("Catalog type/Activity type fetch error")
 SELECT INTO "nl:"
  FROM br_name_value br,
   dummyt d
  PLAN (br
   WHERE br.br_nv_key1="NEW_PHASE_X_MATCH")
   JOIN (d
   WHERE cnvtreal(trim(br.br_name))=catalog_type_cd
    AND cnvtreal(trim(br.br_value))=activity_type_cd)
  DETAIL
   new_phase_x_match_ind = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("Name Value fetch error")
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = ocnt),
   order_catalog oc,
   code_value cv
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=request->oclist[d.seq].catalog_cd))
   JOIN (cv
   WHERE cv.code_value=outerjoin(oc.catalog_type_cd))
  DETAIL
   reply->olist[d.seq].catalog_cd = oc.catalog_cd, reply->olist[d.seq].catalog_description = oc
   .description, reply->olist[d.seq].catalog_type_cd = cv.code_value,
   reply->olist[d.seq].catalog_type_display = cv.display, reply->olist[d.seq].
   catalog_type_cdf_meaning = cv.cdf_meaning, reply->olist[d.seq].orderable_facility_ind = 0
  WITH nocounter
 ;end select
 CALL bederrorcheck("Order Catalog details fetch Error")
 SET max_cnt = 0
 SET max_cnt = request->max_reply
 SET tot_syns = 0
 SET qual_parse_string = populateparsestringbasedonrequest(0)
 CALL echo(build("PARSER VALUE-->",qual_parse_string))
 FOR (o = 1 TO ocnt)
   SET stat = alterlist(reply->olist[o].slist,10)
   SET alterlist_scnt = 0
   SET scnt = 0
   SELECT INTO "NL:"
    FROM order_catalog_synonym ocs,
     order_entry_format oef,
     code_value cv
    PLAN (ocs
     WHERE parser(qual_parse_string)
      AND (ocs.catalog_cd=reply->olist[o].catalog_cd))
     JOIN (oef
     WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
      AND oef.action_type_cd=outerjoin(order_action_cd))
     JOIN (cv
     WHERE cv.code_value=outerjoin(ocs.mnemonic_type_cd))
    DETAIL
     alterlist_scnt = (alterlist_scnt+ 1)
     IF (alterlist_scnt > 10)
      stat = alterlist(reply->olist[o].slist,(scnt+ 10)), alterlist_scnt = 1
     ENDIF
     scnt = (scnt+ 1), reply->olist[o].slist[scnt].synonym_type_cd = ocs.mnemonic_type_cd, reply->
     olist[o].slist[scnt].synonym_type_display = cv.display,
     reply->olist[o].slist[scnt].synonym_type_cdf_meaning = cv.cdf_meaning, reply->olist[o].slist[
     scnt].synonym_id = ocs.synonym_id, reply->olist[o].slist[scnt].synonym_name = ocs.mnemonic,
     reply->olist[o].slist[scnt].order_entry_format_id = ocs.oe_format_id, reply->olist[o].slist[scnt
     ].order_entry_format_name = oef.oe_format_name, reply->olist[o].slist[scnt].active_ind = ocs
     .active_ind,
     reply->olist[o].slist[scnt].hide_flag = ocs.hide_flag, reply->olist[o].slist[scnt].
     med_admin_mask = ocs.rx_mask, reply->olist[o].slist[scnt].titratable_ind = ocs
     .ingredient_rate_conversion_ind,
     reply->olist[o].slist[scnt].synonym_facility_ind = 0, tot_syns = (tot_syns+ 1)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Synonym details fetch Error")
   SET stat = alterlist(reply->olist[o].slist,scnt)
   IF (max_cnt > 0
    AND tot_syns > max_cnt
    AND size(reply->olist[1].slist,5) < max_cnt)
    SET stat = alterlist(reply->olist,(o - 1))
    SET o = (ocnt+ 1)
   ELSEIF (max_cnt > 0
    AND tot_syns > max_cnt
    AND size(reply->olist[1].slist,5) > max_cnt)
    SET stat = alterlist(reply->olist[o].slist,0)
    SET stat = alterlist(reply->olist,1)
    SET o = (ocnt+ 1)
   ENDIF
 ENDFOR
 FOR (i = 1 TO size(reply->olist,5))
   FOR (j = 1 TO size(reply->olist[i].slist,5))
     SET counter = (counter+ 1)
     SET stat = alterlist(tempsynlist->slist,counter)
     SET tempsynlist->slist[counter].synonym_id = reply->olist[i].slist[j].synonym_id
     SET tempsynlist->slist[counter].synonym_facility_ind = 0
     SET tempsynlist->slist[counter].facility_count = 0
   ENDFOR
 ENDFOR
 SELECT
  ofrc.synonym_id, ofrc.fcnt, vv_flag = evaluate(ofr.facility_cd,0,1,2)
  FROM (
   (
   (SELECT
    ofr.synonym_id, fcnt = count(*)
    FROM ocs_facility_r ofr
    WHERE expand(num,1,size(tempsynlist->slist,5),ofr.synonym_id,tempsynlist->slist[num].synonym_id)
    GROUP BY ofr.synonym_id
    WITH expand = 2, sqltype("F8","I4")))
   ofrc),
   ocs_facility_r ofr
  PLAN (ofrc)
   JOIN (ofr
   WHERE ofr.synonym_id=ofrc.synonym_id)
  HEAD ofrc.synonym_id
   idx = locateval(num,1,size(tempsynlist->slist,5),ofrc.synonym_id,tempsynlist->slist[num].
    synonym_id)
   IF (idx > 0)
    tempsynlist->slist[idx].synonym_facility_ind = vv_flag, tempsynlist->slist[idx].facility_count =
    evaluate(vv_flag,1,0,ofrc.fcnt)
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Facility count fetch error")
 FOR (i = 1 TO size(reply->olist,5))
   SET allcounter = 0
   SET nonecounter = 0
   FOR (j = 1 TO size(reply->olist[i].slist,5))
     SET idx = locateval(num,1,size(tempsynlist->slist,5),reply->olist[i].slist[j].synonym_id,
      tempsynlist->slist[num].synonym_id)
     SET reply->olist[i].slist[j].synonym_facility_ind = tempsynlist->slist[idx].synonym_facility_ind
     SET reply->olist[i].slist[j].facility_count = tempsynlist->slist[idx].facility_count
     IF ((reply->olist[i].slist[j].synonym_facility_ind=0))
      SET nonecounter = (nonecounter+ 1)
     ENDIF
     IF ((reply->olist[i].slist[j].synonym_facility_ind=1))
      SET allcounter = (allcounter+ 1)
     ENDIF
   ENDFOR
   IF (size(reply->olist[i].slist,5)=nonecounter)
    SET reply->olist[i].orderable_facility_ind = 0
   ELSEIF (size(reply->olist[i].slist,5)=allcounter)
    SET reply->olist[i].orderable_facility_ind = 1
   ELSE
    SET reply->olist[i].orderable_facility_ind = 2
   ENDIF
 ENDFOR
 FOR (x = 1 TO size(reply->olist,5))
   IF (size(reply->olist[x].slist,5) > 0)
    IF (validate(request->load_care_sets_ind)=1)
     IF ((request->load_care_sets_ind=1))
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(size(reply->olist[x].slist,5))),
        cs_component csc,
        order_catalog oc
       PLAN (d)
        JOIN (csc
        WHERE (csc.comp_id=reply->olist[x].slist[d.seq].synonym_id))
        JOIN (oc
        WHERE oc.catalog_cd=csc.catalog_cd)
       ORDER BY d.seq
       HEAD d.seq
        ccnt = 0
       HEAD oc.catalog_cd
        ccnt = (ccnt+ 1), stat = alterlist(reply->olist[x].slist[d.seq].care_sets,ccnt), reply->
        olist[x].slist[d.seq].care_sets[ccnt].catalog_cd = oc.catalog_cd,
        reply->olist[x].slist[d.seq].care_sets[ccnt].description = oc.description
       WITH nocounter
      ;end select
      CALL bederrorcheck("Care sets fetch error")
     ENDIF
    ENDIF
    IF (validate(request->load_order_folders_ind)=1)
     IF ((request->load_order_folders_ind=1))
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(size(reply->olist[x].slist,5))),
        alt_sel_list l,
        alt_sel_cat c,
        prsnl p
       PLAN (d)
        JOIN (l
        WHERE (l.synonym_id=reply->olist[x].slist[d.seq].synonym_id))
        JOIN (c
        WHERE c.alt_sel_category_id=l.alt_sel_category_id
         AND c.adhoc_ind IN (0, null)
         AND c.ahfs_ind IN (0, null))
        JOIN (p
        WHERE p.person_id=c.owner_id)
       ORDER BY d.seq
       HEAD d.seq
        fcnt = 0
       HEAD c.alt_sel_category_id
        fcnt = (fcnt+ 1), stat = alterlist(reply->olist[x].slist[d.seq].order_folders,fcnt), reply->
        olist[x].slist[d.seq].order_folders[fcnt].category_id = c.alt_sel_category_id,
        reply->olist[x].slist[d.seq].order_folders[fcnt].long_description = c.long_description, reply
        ->olist[x].slist[d.seq].order_folders[fcnt].person_id = p.person_id, reply->olist[x].slist[d
        .seq].order_folders[fcnt].name_full_formatted = p.name_full_formatted
       WITH nocounter
      ;end select
      CALL bederrorcheck("Order Folders fetch error")
     ENDIF
    ENDIF
    IF (validate(request->load_power_plans_ind)=1)
     IF ((request->load_power_plans_ind=1))
      DECLARE plancnt = i4 WITH protect, noconstant(0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(size(reply->olist[x].slist,5))),
        pathway_comp pc,
        pathway_catalog p1,
        pw_cat_reltn pcr,
        pathway_catalog p2
       PLAN (d)
        JOIN (pc
        WHERE (pc.parent_entity_id=reply->olist[x].slist[d.seq].synonym_id)
         AND pc.parent_entity_name="ORDER_CATALOG_SYNONYM"
         AND pc.active_ind=1)
        JOIN (p1
        WHERE p1.pathway_catalog_id=pc.pathway_catalog_id
         AND p1.active_ind=1
         AND p1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND p1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
         AND p1.active_ind=1)
        JOIN (pcr
        WHERE pcr.pw_cat_t_id=outerjoin(p1.pathway_catalog_id)
         AND pcr.type_mean=outerjoin("GROUP"))
        JOIN (p2
        WHERE p2.pathway_catalog_id=outerjoin(pcr.pw_cat_s_id))
       ORDER BY d.seq, p1.pathway_catalog_id, p2.pathway_catalog_id
       HEAD d.seq
        plancnt = 0
       HEAD p1.pathway_catalog_id
        IF (p1.type_mean="CAREPLAN")
         num = 0, start = 0, found = locateval(num,start,plancnt,p1.pathway_catalog_id,reply->olist[x
          ].slist[d.seq].power_plans[num].power_plan_id)
         IF (found=0)
          plancnt = (plancnt+ 1), stat = alterlist(reply->olist[x].slist[d.seq].power_plans,plancnt),
          reply->olist[x].slist[d.seq].power_plans[plancnt].power_plan_id = p1.pathway_catalog_id,
          reply->olist[x].slist[d.seq].power_plans[plancnt].power_plan_description = p1.description
         ENDIF
        ENDIF
       HEAD p2.pathway_catalog_id
        IF (p2.type_mean="PATHWAY")
         num = 0, start = 0, found = locateval(num,start,plancnt,p2.pathway_catalog_id,reply->olist[x
          ].slist[d.seq].power_plans[num].power_plan_id)
         IF (found=0)
          plancnt = (plancnt+ 1), stat = alterlist(reply->olist[x].slist[d.seq].power_plans,plancnt),
          reply->olist[x].slist[d.seq].power_plans[plancnt].power_plan_id = p2.pathway_catalog_id,
          reply->olist[x].slist[d.seq].power_plans[plancnt].power_plan_description = p2.description
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      CALL bederrorcheck("PowerPlans fetch error")
     ENDIF
    ENDIF
   ENDIF
   SET temp_catalog_cd = 0.0
   DECLARE temp_concept_cki = vc
   SELECT INTO "nl:"
    FROM order_catalog oc
    PLAN (oc
     WHERE (oc.catalog_cd=reply->olist[x].catalog_cd))
    DETAIL
     temp_concept_cki = oc.concept_cki
    WITH nocounter
   ;end select
   SET lcnt = 0
   IF (temp_concept_cki > " ")
    SELECT INTO "nl:"
     FROM br_auto_order_catalog b
     PLAN (b
      WHERE b.concept_cki=temp_concept_cki)
     DETAIL
      temp_catalog_cd = b.catalog_cd, reply->olist[x].bedrock_dept_name = b.dept_name
     WITH nocounter, skipbedrock = 1
    ;end select
    IF (temp_catalog_cd > 0)
     SELECT INTO "nl:"
      FROM br_auto_oc_synonym b
      PLAN (b
       WHERE b.catalog_cd=temp_catalog_cd)
      HEAD REPORT
       cnt = 0, list_cnt = 0, stat = alterlist(reply->olist[x].bedrock_synonyms,10)
      DETAIL
       cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
       IF (list_cnt > 10)
        stat = alterlist(reply->olist[x].bedrock_synonyms,(cnt+ 10)), list_cnt = 1
       ENDIF
       reply->olist[x].bedrock_synonyms[cnt].synonym_id = b.synonym_id, reply->olist[x].
       bedrock_synonyms[cnt].mnemonic = b.mnemonic, reply->olist[x].bedrock_synonyms[cnt].
       synonym_type.code_value = b.mnemonic_type_cd,
       reply->olist[x].bedrock_synonyms[cnt].order_entry_format_id = b.oe_format_id
      FOOT REPORT
       stat = alterlist(reply->olist[x].bedrock_synonyms,cnt)
      WITH nocounter, skipbedrock = 1
     ;end select
     IF (size(reply->olist[x].bedrock_synonyms,5) > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(size(reply->olist[x].bedrock_synonyms,5))),
        code_value cv
       PLAN (d)
        JOIN (cv
        WHERE (cv.code_value=reply->olist[x].bedrock_synonyms[d.seq].synonym_type.code_value))
       ORDER BY d.seq
       DETAIL
        reply->olist[x].bedrock_synonyms[d.seq].synonym_type.display = cv.display, reply->olist[x].
        bedrock_synonyms[d.seq].synonym_type.meaning = cv.cdf_meaning
       WITH nocounter
      ;end select
     ENDIF
     IF (new_phase_x_match_ind=1)
      SET phase_x_match = 0
      SELECT INTO "nl:"
       FROM br_name_value n,
        dummyt d1,
        br_oc_work b,
        dummyt d2
       PLAN (n
        WHERE n.br_nv_key1="PHASE_X_MATCH")
        JOIN (d1
        WHERE (cnvtreal(trim(n.br_value))=reply->olist[x].catalog_cd))
        JOIN (b)
        JOIN (d2
        WHERE b.oc_id=cnvtreal(trim(n.br_name)))
       DETAIL
        phase_x_match = 1
       WITH nocounter
      ;end select
      IF (phase_x_match=0)
       SELECT INTO "nl:"
        FROM code_value_alias cva,
         br_name_value nv,
         br_oc_work b
        PLAN (cva
         WHERE (cva.code_value=reply->olist[x].catalog_cd)
          AND cva.code_set=200)
         JOIN (nv
         WHERE nv.br_nv_key1="REL_CONTRIBUTOR_FACILITY"
          AND cnvtreal(trim(nv.br_name))=cva.contributor_source_cd)
         JOIN (b
         WHERE ((b.alias1=cva.alias) OR (b.alias2=cva.alias))
          AND b.facility=nv.br_value)
        HEAD REPORT
         lcnt = 0, tot_cnt = 0, stat = alterlist(reply->olist[x].legacy_names,10)
        DETAIL
         lcnt = (lcnt+ 1), tot_cnt = (tot_cnt+ 1)
         IF (tot_cnt > 10)
          stat = alterlist(reply->olist[x].legacy_names,(lcnt+ 10)), tot_cnt = 1
         ENDIF
         reply->olist[x].legacy_names[lcnt].short_desc = b.short_desc, reply->olist[x].legacy_names[
         lcnt].long_desc = b.long_desc, reply->olist[x].legacy_names[lcnt].facility = b.facility
        FOOT REPORT
         stat = alterlist(reply->olist[x].legacy_names,lcnt)
        WITH nocounter
       ;end select
      ELSE
       SELECT INTO "nl:"
        FROM br_name_value n,
         dummyt d1,
         br_oc_work b,
         dummyt d2
        PLAN (n
         WHERE n.br_nv_key1="PHASE_X_MATCH")
         JOIN (d1
         WHERE (cnvtreal(trim(n.br_value))=reply->olist[x].catalog_cd))
         JOIN (b)
         JOIN (d2
         WHERE b.oc_id=cnvtreal(trim(n.br_name)))
        HEAD REPORT
         lcnt = 0, tot_cnt = 0, stat = alterlist(reply->olist[x].legacy_names,10)
        DETAIL
         lcnt = (lcnt+ 1), tot_cnt = (tot_cnt+ 1)
         IF (tot_cnt > 10)
          stat = alterlist(reply->olist[x].legacy_names,(lcnt+ 10)), tot_cnt = 1
         ENDIF
         reply->olist[x].legacy_names[lcnt].short_desc = b.short_desc, reply->olist[x].legacy_names[
         lcnt].long_desc = b.long_desc, reply->olist[x].legacy_names[lcnt].facility = b.facility
        FOOT REPORT
         stat = alterlist(reply->olist[x].legacy_names,lcnt)
        WITH nocounter
       ;end select
      ENDIF
     ELSE
      SELECT INTO "nl:"
       FROM br_oc_work b
       PLAN (b
        WHERE b.match_orderable_cd=temp_catalog_cd)
       HEAD REPORT
        lcnt = 0, tot_cnt = 0, stat = alterlist(reply->olist[x].legacy_names,10)
       DETAIL
        lcnt = (lcnt+ 1), tot_cnt = (tot_cnt+ 1)
        IF (tot_cnt > 10)
         stat = alterlist(reply->olist[x].legacy_names,(lcnt+ 10)), tot_cnt = 1
        ENDIF
        reply->olist[x].legacy_names[lcnt].short_desc = b.short_desc, reply->olist[x].legacy_names[
        lcnt].long_desc = b.long_desc, reply->olist[x].legacy_names[lcnt].facility = b.facility
       FOOT REPORT
        stat = alterlist(reply->olist[x].legacy_names,lcnt)
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ELSE
    IF ((reply->olist[x].catalog_cd > 0))
     SELECT INTO "nl:"
      FROM code_value_alias cva,
       br_oc_work b
      PLAN (cva
       WHERE (cva.code_value=reply->olist[x].catalog_cd)
        AND cva.code_set=200)
       JOIN (b
       WHERE ((b.alias1=cva.alias) OR (b.alias2=cva.alias))
        AND b.facility=" ")
      HEAD REPORT
       lcnt = 0, tot_cnt = 0, stat = alterlist(reply->olist[x].legacy_names,10)
      DETAIL
       lcnt = (lcnt+ 1), tot_cnt = (tot_cnt+ 1)
       IF (tot_cnt > 10)
        stat = alterlist(reply->olist[x].legacy_names,(lcnt+ 10)), tot_cnt = 1
       ENDIF
       reply->olist[x].legacy_names[lcnt].short_desc = b.short_desc, reply->olist[x].legacy_names[
       lcnt].long_desc = b.long_desc, reply->olist[x].legacy_names[lcnt].facility = b.facility
      FOOT REPORT
       stat = alterlist(reply->olist[x].legacy_names,lcnt)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM code_value_alias cva,
       br_name_value nv,
       br_oc_work b
      PLAN (cva
       WHERE (cva.code_value=reply->olist[x].catalog_cd)
        AND cva.code_set=200)
       JOIN (nv
       WHERE nv.br_nv_key1="REL_CONTRIBUTOR_FACILITY"
        AND cnvtreal(trim(nv.br_name))=cva.contributor_source_cd)
       JOIN (b
       WHERE ((b.alias1=cva.alias) OR (b.alias2=cva.alias))
        AND b.facility=nv.br_value)
      HEAD REPORT
       lcnt = 0, tot_cnt = 0, stat = alterlist(reply->olist[x].legacy_names,10)
      DETAIL
       lcnt = (lcnt+ 1), tot_cnt = (tot_cnt+ 1)
       IF (tot_cnt > 10)
        stat = alterlist(reply->olist[x].legacy_names,(lcnt+ 10)), tot_cnt = 1
       ENDIF
       reply->olist[x].legacy_names[lcnt].short_desc = b.short_desc, reply->olist[x].legacy_names[
       lcnt].long_desc = b.long_desc, reply->olist[x].legacy_names[lcnt].facility = b.facility
      FOOT REPORT
       stat = alterlist(reply->olist[x].legacy_names,lcnt)
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (lcnt=0
    AND (reply->olist[x].catalog_cd > 0))
    SELECT INTO "nl:"
     FROM br_oc_work b
     PLAN (b
      WHERE (b.match_orderable_cd=reply->olist[x].catalog_cd))
     HEAD REPORT
      lcnt = 0, tot_cnt = 0, stat = alterlist(reply->olist[x].legacy_names,10)
     DETAIL
      lcnt = (lcnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (tot_cnt > 10)
       stat = alterlist(reply->olist[x].legacy_names,(lcnt+ 10)), tot_cnt = 1
      ENDIF
      reply->olist[x].legacy_names[lcnt].short_desc = b.short_desc, reply->olist[x].legacy_names[lcnt
      ].long_desc = b.long_desc, reply->olist[x].legacy_names[lcnt].facility = b.facility
     FOOT REPORT
      stat = alterlist(reply->olist[x].legacy_names,lcnt)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SUBROUTINE populateparsestringbasedonrequest(dummyvar)
   DECLARE string_to_parse = vc WITH protect, noconstant("ocs.synonym_id != 0.0")
   IF (validate(request->mnemonic_search_string,"") > " ")
    IF ((request->starts_with_contains_type IN ("S", "s"))
     AND (request->mnemonic_search_string > " "))
     SET string_to_parse = concat(string_to_parse," and cnvtupper(ocs.mnemonic) = '",cnvtupper(trim(
        request->mnemonic_search_string)),"*'")
    ELSEIF ((request->starts_with_contains_type IN ("C", "c"))
     AND (request->mnemonic_search_string > " "))
     SET string_to_parse = concat(string_to_parse," and cnvtupper(ocs.mnemonic) = '*",cnvtupper(trim(
        request->mnemonic_search_string)),"*'")
    ENDIF
    IF ((request->return_inactives_ind=1))
     SET string_to_parse = concat(string_to_parse," and ocs.active_ind in (0, 1)")
    ELSEIF ((request->return_inactives_ind=0))
     SET string_to_parse = concat(string_to_parse," and ocs.active_ind = 1 ")
    ENDIF
    IF ((request->return_hidden_ind=1))
     SET string_to_parse = concat(string_to_parse," and ocs.hide_flag in (0, 1)")
    ELSEIF ((request->return_hidden_ind=0))
     SET string_to_parse = concat(string_to_parse," and ocs.hide_flag = 0 ")
    ENDIF
   ENDIF
   IF (validate(request->synonym_types)=1)
    SET syn_type_size = size(request->synonym_types,5)
    IF (syn_type_size > 0)
     IF (string_to_parse > "")
      SET string_to_parse = concat(string_to_parse," and ocs.mnemonic_type_cd in ( ")
     ELSE
      SET string_to_parse = concat(string_to_parse," ocs.mnemonic_type_cd in ( ")
     ENDIF
    ENDIF
    FOR (x = 1 TO syn_type_size)
     SET string_to_parse = build(string_to_parse,request->synonym_types[x].code_value)
     IF (x < syn_type_size)
      SET string_to_parse = concat(string_to_parse,", ")
     ENDIF
    ENDFOR
    IF (syn_type_size > 0)
     SET string_to_parse = concat(string_to_parse," ) ")
    ENDIF
   ENDIF
   IF (validate(request->return_inactives_ind)=1)
    IF ((request->return_inactives_ind=1))
     SET string_to_parse = concat(string_to_parse," and ocs.active_ind in (0, 1)")
    ELSEIF ((request->return_inactives_ind=0))
     SET string_to_parse = concat(string_to_parse," and ocs.active_ind = 1 ")
    ENDIF
   ELSE
    SET string_to_parse = concat(string_to_parse," and ocs.active_ind in (0, 1)")
   ENDIF
   IF (validate(request->return_hidden_ind)=1)
    IF ((request->return_hidden_ind=1))
     SET string_to_parse = concat(string_to_parse," and ocs.hide_flag in (0, 1)")
    ELSEIF ((request->return_hidden_ind=0))
     SET string_to_parse = concat(string_to_parse," and ocs.hide_flag = 0 ")
    ENDIF
   ELSE
    SET string_to_parse = concat(string_to_parse," and ocs.hide_flag in (0, 1)")
   ENDIF
   RETURN(string_to_parse)
 END ;Subroutine
 IF (tot_syns=0)
  SET reply->status_data.status = "Z"
 ELSEIF (max_cnt > 0
  AND tot_syns > max_cnt)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
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
