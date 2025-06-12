CREATE PROGRAM bed_get_ocrec_matches:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 legacy
       3 id = f8
       3 short_desc = vc
       3 long_desc = vc
       3 alias = vc
     2 millennium
       3 code_value = f8
       3 mnemonic = vc
       3 concept_cki = vc
     2 matches[*]
       3 code_value = f8
       3 mnemonic = vc
       3 description = vc
       3 match_type_flag = i2
       3 match_value = vc
       3 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET mcnt = 0
 SET rcnt = 0
 DECLARE br_string = vc
 SET br_string = "b.catalog_type = request->catalog_type"
 IF ((request->activity_type > " "))
  SET br_string = concat(br_string," and b.activity_type = request->activity_type")
 ENDIF
 IF ((request->facility > " "))
  SET br_string = concat(br_string," and b.facility = request->facility")
 ENDIF
 DECLARE b_string = vc
 SET b_string = "b.match_orderable_cd > 0"
 IF ((request->facility > " "))
  SET b_string = concat(b_string," and b.facility = request->facility")
 ENDIF
 SET cpt4_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=14002
    AND c.cki="CKI.CODEVALUE!3600")
  DETAIL
   cpt4_cd = c.code_value
  WITH nocounter
 ;end select
 SET ord_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=13016
    AND c.cdf_meaning="ORD CAT")
  DETAIL
   ord_cd = c.code_value
  WITH nocounter
 ;end select
 SET bill_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=13019
    AND c.cdf_meaning="BILL CODE")
  DETAIL
   bill_cd = c.code_value
  WITH nocounter
 ;end select
 SET dcp_cd = 0.0
 SET ancillary_cd = 0.0
 SET primary_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6011
    AND c.cdf_meaning IN ("DCP", "ANCILLARY", "PRIMARY"))
  DETAIL
   CASE (c.cdf_meaning)
    OF "DCP":
     dcp_cd = c.code_value
    OF "ANCILLARY":
     ancillary_cd = c.code_value
    OF "PRIMARY":
     primary_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET brcnt = 0
 RECORD br(
   1 qual[*]
     2 cd = f8
 )
 RECORD temp(
   1 qual[*]
     2 l_id = f8
     2 l_mnemonic = vc
     2 l_desc = vc
     2 l_mnemonic2 = vc
     2 l_desc2 = vc
     2 l_alias = vc
     2 l_cpt = vc
     2 m_cd = f8
     2 m_mnemonic = vc
     2 m_desc = vc
     2 m_mnemonic2 = vc
     2 m_desc2 = vc
     2 m_cki = vc
     2 m_concept_cki = vc
     2 m_cpt[*]
       3 cpt = vc
     2 match_ind = i2
     2 match[*]
       3 b_cd = f8
       3 b_mnemonic = vc
       3 b_desc = vc
       3 b_cki = vc
       3 type = i2
       3 value = vc
 )
 SELECT INTO "nl:"
  FROM br_oc_work b,
   dummyt d,
   code_value_alias a,
   order_catalog o
  PLAN (b
   WHERE parser(br_string)
    AND b.status_ind=0)
   JOIN (d)
   JOIN (a
   WHERE a.code_set=200
    AND (a.contributor_source_cd=request->contributor_source_code_value)
    AND ((a.alias=b.alias1) OR (a.alias=b.alias2)) )
   JOIN (o
   WHERE o.catalog_cd=a.code_value)
  ORDER BY b.short_desc
  HEAD b.oc_id
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].l_id = b.oc_id,
   temp->qual[cnt].l_mnemonic = cnvtupper(b.short_desc), temp->qual[cnt].l_desc = cnvtupper(b
    .long_desc), temp->qual[cnt].l_mnemonic2 = b.short_desc,
   temp->qual[cnt].l_desc2 = b.long_desc
   IF (b.alias1 > " ")
    temp->qual[cnt].l_alias = b.alias1
   ELSE
    temp->qual[cnt].l_alias = b.alias2
   ENDIF
   temp->qual[cnt].m_cd = o.catalog_cd, temp->qual[cnt].m_mnemonic = cnvtupper(o.primary_mnemonic),
   temp->qual[cnt].m_desc = cnvtupper(o.description),
   temp->qual[cnt].m_mnemonic2 = o.primary_mnemonic, temp->qual[cnt].m_desc2 = o.description, temp->
   qual[cnt].m_cki = o.cki,
   temp->qual[cnt].m_concept_cki = o.concept_cki, temp->qual[cnt].match_ind = 0
  WITH nocounter, outerjoin = d
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_oc_pricing p
  PLAN (d)
   JOIN (p
   WHERE (p.oc_id=temp->qual[d.seq].l_id)
    AND p.billcode_sched_cd=cpt4_cd)
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].l_cpt = p.billcode
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   bill_item b,
   bill_item_modifier m
  PLAN (d)
   JOIN (b
   WHERE (b.ext_parent_reference_id=temp->qual[d.seq].m_cd)
    AND b.ext_parent_contributor_cd=ord_cd)
   JOIN (m
   WHERE m.bill_item_id=b.bill_item_id
    AND m.bill_item_type_cd=bill_cd
    AND m.key1_entity_name="CODE_VALUE")
  ORDER BY d.seq
  HEAD d.seq
   ccnt = 0
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(temp->qual[d.seq].m_cpt,ccnt), temp->qual[d.seq].m_cpt[ccnt].
   cpt = m.key6
  WITH nocounter
 ;end select
 RECORD match_oc(
   1 qual[*]
     2 cd = f8
 )
 SET match_oc_cnt = 0
 SELECT INTO "nl:"
  FROM br_oc_work b
  PLAN (b
   WHERE parser(b_string))
  DETAIL
   match_oc_cnt = (match_oc_cnt+ 1), stat = alterlist(match_oc->qual,match_oc_cnt), match_oc->qual[
   match_oc_cnt].cd = b.match_orderable_cd
  WITH nocounter
 ;end select
 DECLARE match_oc_string = vc
 IF (match_oc_cnt=0)
  SET match_oc_string = "0 = 0"
 ELSE
  FOR (x = 1 TO match_oc_cnt)
    IF (x=1)
     SET match_oc_string = build("c.catalog_cd+0 not in (",match_oc->qual[x].cd)
    ELSE
     SET match_oc_string = build(trim(match_oc_string),",",match_oc->qual[x].cd)
    ENDIF
  ENDFOR
  SET match_oc_string = concat(trim(match_oc_string),")")
 ENDIF
 RECORD match_cki(
   1 qual[*]
     2 cki = vc
 )
 SET match_cki_cnt = 0
 SELECT INTO "nl:"
  FROM br_oc_work b,
   order_catalog o
  PLAN (b
   WHERE parser(b_string))
   JOIN (o
   WHERE o.catalog_cd=b.match_orderable_cd
    AND o.concept_cki > " ")
  DETAIL
   match_cki_cnt = (match_cki_cnt+ 1), stat = alterlist(match_cki->qual,match_cki_cnt), match_cki->
   qual[match_cki_cnt].cki = o.concept_cki
  WITH nocounter
 ;end select
 DECLARE match_cki_string = vc
 IF (match_cki_cnt=0)
  SET match_cki_string = "0 = 0"
 ELSE
  FOR (x = 1 TO match_cki_cnt)
    IF (x=1)
     SET match_cki_string = concat("trim(c.concept_cki) not in (",'"',match_cki->qual[x].cki,'"')
    ELSE
     SET match_cki_string = concat(trim(match_cki_string),",",'"',match_cki->qual[x].cki,'"')
    ENDIF
  ENDFOR
  SET match_cki_string = concat(trim(match_cki_string),")")
 ENDIF
 IF ((request->match_option_flag=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_auto_oc_synonym s,
    br_auto_order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (s
    WHERE (((s.mnemonic_key_cap=temp->qual[d.seq].m_mnemonic)) OR ((s.mnemonic_key_cap=temp->qual[d
    .seq].m_desc)))
     AND s.mnemonic_type_cd IN (dcp_cd, ancillary_cd, primary_cd))
    JOIN (c
    WHERE c.catalog_cd=s.catalog_cd)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0, match = 1
   HEAD c.catalog_cd
    FOR (x = 1 TO match_oc_cnt)
      IF ((c.catalog_cd=match_oc->qual[x].cd))
       match = 0
      ENDIF
    ENDFOR
    FOR (x = 1 TO match_cki_cnt)
      IF ((c.concept_cki=match_cki->qual[x].cki))
       match = 0
      ENDIF
    ENDFOR
    IF (match=1)
     temp->qual[d.seq].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt
      ),
     temp->qual[d.seq].match[mcnt].b_cd = c.catalog_cd, temp->qual[d.seq].match[mcnt].b_mnemonic = c
     .primary_mnemonic, temp->qual[d.seq].match[mcnt].b_desc = c.description,
     temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki, temp->qual[d.seq].match[mcnt].type = 1,
     temp->qual[d.seq].match[mcnt].value = s.mnemonic
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_auto_oc_synonym s,
    br_auto_order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (s
    WHERE (((s.mnemonic_key_cap=temp->qual[d.seq].l_mnemonic)) OR ((s.mnemonic_key_cap=temp->qual[d
    .seq].l_desc)))
     AND s.mnemonic_type_cd IN (dcp_cd, ancillary_cd, primary_cd))
    JOIN (c
    WHERE c.catalog_cd=s.catalog_cd)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0, match = 1
   HEAD c.catalog_cd
    FOR (x = 1 TO match_oc_cnt)
      IF ((c.catalog_cd=match_oc->qual[x].cd))
       match = 0
      ENDIF
    ENDFOR
    FOR (x = 1 TO match_cki_cnt)
      IF ((c.concept_cki=match_cki->qual[x].cki))
       match = 0
      ENDIF
    ENDFOR
    IF (match=1)
     temp->qual[d.seq].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt
      ),
     temp->qual[d.seq].match[mcnt].b_cd = c.catalog_cd, temp->qual[d.seq].match[mcnt].b_mnemonic = c
     .primary_mnemonic, temp->qual[d.seq].match[mcnt].b_desc = c.description,
     temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki, temp->qual[d.seq].match[mcnt].type = 1,
     temp->qual[d.seq].match[mcnt].value = s.mnemonic
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_other_names n,
    br_auto_order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (n
    WHERE n.parent_entity_name="BR_AUTO_ORDER_CATALOG"
     AND (((n.alias_name_key_cap=temp->qual[d.seq].l_mnemonic)) OR ((((n.alias_name_key_cap=temp->
    qual[d.seq].l_desc)) OR ((((n.alias_name_key_cap=temp->qual[d.seq].m_mnemonic)) OR ((n
    .alias_name_key_cap=temp->qual[d.seq].m_desc))) )) )) )
    JOIN (c
    WHERE c.catalog_cd=n.parent_entity_id)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0, match = 1
   HEAD c.catalog_cd
    FOR (x = 1 TO match_oc_cnt)
      IF ((c.catalog_cd=match_oc->qual[x].cd))
       match = 0
      ENDIF
    ENDFOR
    FOR (x = 1 TO match_cki_cnt)
      IF ((c.concept_cki=match_cki->qual[x].cki))
       match = 0
      ENDIF
    ENDFOR
    IF (match=1)
     temp->qual[d.seq].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt
      ),
     temp->qual[d.seq].match[mcnt].b_cd = c.catalog_cd, temp->qual[d.seq].match[mcnt].b_mnemonic = c
     .primary_mnemonic, temp->qual[d.seq].match[mcnt].b_desc = c.description,
     temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki, temp->qual[d.seq].match[mcnt].type = 1,
     temp->qual[d.seq].match[mcnt].value = n.alias_name
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SET rcnt = 0
  FOR (x = 1 TO cnt)
    IF ((temp->qual[x].match_ind=1))
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->orderables,rcnt)
     SET reply->orderables[rcnt].legacy.id = temp->qual[x].l_id
     SET reply->orderables[rcnt].legacy.short_desc = temp->qual[x].l_mnemonic2
     SET reply->orderables[rcnt].legacy.long_desc = temp->qual[x].l_desc2
     SET reply->orderables[rcnt].legacy.alias = temp->qual[x].l_alias
     SET reply->orderables[rcnt].millennium.code_value = temp->qual[x].m_cd
     SET reply->orderables[rcnt].millennium.mnemonic = temp->qual[x].m_mnemonic2
     SET reply->orderables[rcnt].millennium.concept_cki = temp->qual[x].m_concept_cki
     FOR (y = 1 TO size(temp->qual[x].match,5))
       SET stat = alterlist(reply->orderables[rcnt].matches,y)
       SET reply->orderables[rcnt].matches[y].code_value = temp->qual[x].match[y].b_cd
       SET reply->orderables[rcnt].matches[y].mnemonic = temp->qual[x].match[y].b_mnemonic
       SET reply->orderables[rcnt].matches[y].description = temp->qual[x].match[y].b_desc
       SET reply->orderables[rcnt].matches[y].match_type_flag = temp->qual[x].match[y].type
       SET reply->orderables[rcnt].matches[y].match_value = temp->qual[x].match[y].value
       SET reply->orderables[rcnt].matches[y].concept_cki = temp->qual[x].match[y].b_cki
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 IF ((request->match_option_flag=2))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_auto_order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (c
    WHERE (c.concept_cki=temp->qual[d.seq].m_concept_cki))
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0, match = 1
   DETAIL
    FOR (x = 1 TO match_oc_cnt)
      IF ((c.catalog_cd=match_oc->qual[x].cd))
       match = 0
      ENDIF
    ENDFOR
    FOR (x = 1 TO match_cki_cnt)
      IF ((c.concept_cki=match_cki->qual[x].cki))
       match = 0
      ENDIF
    ENDFOR
    brcnt = size(br->qual,5), br_found = 0
    FOR (x = 1 TO brcnt)
      IF ((c.catalog_cd=br->qual[x].cd))
       br_found = 1
      ENDIF
    ENDFOR
    IF (br_found=0
     AND match=1)
     temp->qual[d.seq].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt
      ),
     temp->qual[d.seq].match[mcnt].b_cd = c.catalog_cd, temp->qual[d.seq].match[mcnt].b_mnemonic = c
     .primary_mnemonic, temp->qual[d.seq].match[mcnt].b_desc = c.description,
     temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki, temp->qual[d.seq].match[mcnt].type = 6,
     temp->qual[d.seq].match[mcnt].value = c.concept_cki,
     brcnt = (brcnt+ 1), stat = alterlist(br->qual,brcnt), br->qual[brcnt].cd = c.catalog_cd
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_other_names n,
    br_auto_order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (n
    WHERE n.parent_entity_name="CODE_VALUE"
     AND (n.alias_name_key_cap=temp->qual[d.seq].l_mnemonic))
    JOIN (c
    WHERE c.catalog_cd=n.parent_entity_id)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0, match = 1
   DETAIL
    FOR (x = 1 TO match_oc_cnt)
      IF ((c.catalog_cd=match_oc->qual[x].cd))
       match = 0
      ENDIF
    ENDFOR
    FOR (x = 1 TO match_cki_cnt)
      IF ((c.concept_cki=match_cki->qual[x].cki))
       match = 0
      ENDIF
    ENDFOR
    brcnt = size(br->qual,5), br_found = 0
    FOR (x = 1 TO brcnt)
      IF ((c.catalog_cd=br->qual[x].cd))
       br_found = 1
      ENDIF
    ENDFOR
    IF (br_found=0
     AND match=1)
     temp->qual[d.seq].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt
      ),
     temp->qual[d.seq].match[mcnt].b_cd = c.catalog_cd, temp->qual[d.seq].match[mcnt].b_mnemonic = c
     .primary_mnemonic, temp->qual[d.seq].match[mcnt].b_desc = c.description,
     temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki, temp->qual[d.seq].match[mcnt].type = 2,
     temp->qual[d.seq].match[mcnt].value = n.alias_name,
     brcnt = (brcnt+ 1), stat = alterlist(br->qual,brcnt), br->qual[brcnt].cd = c.catalog_cd
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_other_names n,
    br_auto_order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (n
    WHERE n.parent_entity_name="CODE_VALUE"
     AND (n.alias_name_key_cap=temp->qual[d.seq].l_desc))
    JOIN (c
    WHERE c.catalog_cd=n.parent_entity_id)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0, match = 1
   DETAIL
    FOR (x = 1 TO match_oc_cnt)
      IF ((c.catalog_cd=match_oc->qual[x].cd))
       match = 0
      ENDIF
    ENDFOR
    FOR (x = 1 TO match_cki_cnt)
      IF ((c.concept_cki=match_cki->qual[x].cki))
       match = 0
      ENDIF
    ENDFOR
    brcnt = size(br->qual,5), br_found = 0
    FOR (x = 1 TO brcnt)
      IF ((c.catalog_cd=br->qual[x].cd))
       br_found = 1
      ENDIF
    ENDFOR
    IF (br_found=0
     AND match=1)
     temp->qual[d.seq].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt
      ),
     temp->qual[d.seq].match[mcnt].b_cd = c.catalog_cd, temp->qual[d.seq].match[mcnt].b_mnemonic = c
     .primary_mnemonic, temp->qual[d.seq].match[mcnt].b_desc = c.description,
     temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki, temp->qual[d.seq].match[mcnt].type = 2,
     temp->qual[d.seq].match[mcnt].value = n.alias_name,
     brcnt = (brcnt+ 1), stat = alterlist(br->qual,brcnt), br->qual[brcnt].cd = c.catalog_cd
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_other_names n,
    br_auto_order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (n
    WHERE n.parent_entity_name="CODE_VALUE"
     AND (n.alias_name_key_cap=temp->qual[d.seq].m_mnemonic))
    JOIN (c
    WHERE c.catalog_cd=n.parent_entity_id)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0, match = 1
   DETAIL
    FOR (x = 1 TO match_oc_cnt)
      IF ((c.catalog_cd=match_oc->qual[x].cd))
       match = 0
      ENDIF
    ENDFOR
    FOR (x = 1 TO match_cki_cnt)
      IF ((c.concept_cki=match_cki->qual[x].cki))
       match = 0
      ENDIF
    ENDFOR
    brcnt = size(br->qual,5), br_found = 0
    FOR (x = 1 TO brcnt)
      IF ((c.catalog_cd=br->qual[x].cd))
       br_found = 1
      ENDIF
    ENDFOR
    IF (br_found=0
     AND match=1)
     temp->qual[d.seq].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt
      ),
     temp->qual[d.seq].match[mcnt].b_cd = c.catalog_cd, temp->qual[d.seq].match[mcnt].b_mnemonic = c
     .primary_mnemonic, temp->qual[d.seq].match[mcnt].b_desc = c.description,
     temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki, temp->qual[d.seq].match[mcnt].type = 2,
     temp->qual[d.seq].match[mcnt].value = n.alias_name,
     brcnt = (brcnt+ 1), stat = alterlist(br->qual,brcnt), br->qual[brcnt].cd = c.catalog_cd
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_other_names n,
    br_auto_order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (n
    WHERE n.parent_entity_name="CODE_VALUE"
     AND (n.alias_name_key_cap=temp->qual[d.seq].m_desc))
    JOIN (c
    WHERE c.catalog_cd=n.parent_entity_id)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0, match = 1
   DETAIL
    FOR (x = 1 TO match_oc_cnt)
      IF ((c.catalog_cd=match_oc->qual[x].cd))
       match = 0
      ENDIF
    ENDFOR
    FOR (x = 1 TO match_cki_cnt)
      IF ((c.concept_cki=match_cki->qual[x].cki))
       match = 0
      ENDIF
    ENDFOR
    brcnt = size(br->qual,5), br_found = 0
    FOR (x = 1 TO brcnt)
      IF ((c.catalog_cd=br->qual[x].cd))
       br_found = 1
      ENDIF
    ENDFOR
    IF (br_found=0
     AND match=1)
     temp->qual[d.seq].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt
      ),
     temp->qual[d.seq].match[mcnt].b_cd = c.catalog_cd, temp->qual[d.seq].match[mcnt].b_mnemonic = c
     .primary_mnemonic, temp->qual[d.seq].match[mcnt].b_desc = c.description,
     temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki, temp->qual[d.seq].match[mcnt].type = 2,
     temp->qual[d.seq].match[mcnt].value = n.alias_name,
     brcnt = (brcnt+ 1), stat = alterlist(br->qual,brcnt), br->qual[brcnt].cd = c.catalog_cd
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_auto_order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (c
    WHERE (c.cpt4=temp->qual[d.seq].l_cpt))
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0, match = 1
   DETAIL
    FOR (x = 1 TO match_oc_cnt)
      IF ((c.catalog_cd=match_oc->qual[x].cd))
       match = 0
      ENDIF
    ENDFOR
    FOR (x = 1 TO match_cki_cnt)
      IF ((c.concept_cki=match_cki->qual[x].cki))
       match = 0
      ENDIF
    ENDFOR
    brcnt = size(br->qual,5), br_found = 0
    FOR (x = 1 TO brcnt)
      IF ((c.catalog_cd=br->qual[x].cd))
       br_found = 1
      ENDIF
    ENDFOR
    IF (br_found=0
     AND match=1)
     temp->qual[d.seq].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt
      ),
     temp->qual[d.seq].match[mcnt].b_cd = c.catalog_cd, temp->qual[d.seq].match[mcnt].b_mnemonic = c
     .primary_mnemonic, temp->qual[d.seq].match[mcnt].b_desc = c.description,
     temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki, temp->qual[d.seq].match[mcnt].type = 3,
     temp->qual[d.seq].match[mcnt].value = c.cpt4,
     brcnt = (brcnt+ 1), stat = alterlist(br->qual,brcnt), br->qual[brcnt].cd = c.catalog_cd
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  FOR (x = 1 TO cnt)
   SET cpt_cnt = 0
   IF ((temp->qual[x].match_ind=0))
    SET cpt_cnt = size(temp->qual[x].m_cpt,5)
    IF (cpt_cnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(cpt_cnt)),
       br_auto_order_catalog c
      PLAN (d)
       JOIN (c
       WHERE (c.cpt4=temp->qual[x].m_cpt[d.seq].cpt))
      ORDER BY c.primary_mnemonic
      HEAD REPORT
       mcnt = 0
      DETAIL
       match = 1
       FOR (q = 1 TO match_oc_cnt)
         IF ((c.catalog_cd=match_oc->qual[q].cd))
          match = 0
         ENDIF
       ENDFOR
       FOR (q = 1 TO match_cki_cnt)
         IF ((c.concept_cki=match_cki->qual[q].cki))
          match = 0
         ENDIF
       ENDFOR
       brcnt = size(br->qual,5), br_found = 0
       FOR (q = 1 TO brcnt)
         IF ((c.catalog_cd=br->qual[q].cd))
          br_found = 1
         ENDIF
       ENDFOR
       IF (br_found=0
        AND match=1)
        temp->qual[x].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[x].match,mcnt),
        temp->qual[x].match[mcnt].b_cd = c.catalog_cd, temp->qual[x].match[mcnt].b_mnemonic = c
        .primary_mnemonic, temp->qual[x].match[mcnt].b_desc = c.description,
        temp->qual[x].match[mcnt].b_cki = c.concept_cki, temp->qual[x].match[mcnt].type = 3, temp->
        qual[x].match[mcnt].value = c.cpt4,
        brcnt = (brcnt+ 1), stat = alterlist(br->qual,brcnt), br->qual[brcnt].cd = c.catalog_cd
       ENDIF
      WITH nocounter, skipbedrock = 1
     ;end select
    ENDIF
   ENDIF
  ENDFOR
  SET rcnt = 0
  FOR (x = 1 TO cnt)
    IF ((temp->qual[x].match_ind=1)
     AND size(temp->qual[x].match,5)=1)
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->orderables,rcnt)
     SET reply->orderables[rcnt].legacy.id = temp->qual[x].l_id
     SET reply->orderables[rcnt].legacy.short_desc = temp->qual[x].l_mnemonic2
     SET reply->orderables[rcnt].legacy.long_desc = temp->qual[x].l_desc2
     SET reply->orderables[rcnt].legacy.alias = temp->qual[x].l_alias
     SET reply->orderables[rcnt].millennium.code_value = temp->qual[x].m_cd
     SET reply->orderables[rcnt].millennium.mnemonic = temp->qual[x].m_mnemonic2
     SET reply->orderables[rcnt].millennium.concept_cki = temp->qual[x].m_concept_cki
     FOR (y = 1 TO size(temp->qual[x].match,5))
       SET stat = alterlist(reply->orderables[rcnt].matches,y)
       SET reply->orderables[rcnt].matches[y].code_value = temp->qual[x].match[y].b_cd
       SET reply->orderables[rcnt].matches[y].mnemonic = temp->qual[x].match[y].b_mnemonic
       SET reply->orderables[rcnt].matches[y].description = temp->qual[x].match[y].b_desc
       SET reply->orderables[rcnt].matches[y].match_type_flag = temp->qual[x].match[y].type
       SET reply->orderables[rcnt].matches[y].match_value = temp->qual[x].match[y].value
       SET reply->orderables[rcnt].matches[y].concept_cki = temp->qual[x].match[y].b_cki
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 IF ((request->match_option_flag=3))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_auto_order_catalog c
   PLAN (d)
    JOIN (c
    WHERE (c.cpt4=temp->qual[d.seq].l_cpt))
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0, match = 1
   DETAIL
    FOR (x = 1 TO match_oc_cnt)
      IF ((c.catalog_cd=match_oc->qual[x].cd))
       match = 0
      ENDIF
    ENDFOR
    FOR (x = 1 TO match_cki_cnt)
      IF ((c.concept_cki=match_cki->qual[x].cki))
       match = 0
      ENDIF
    ENDFOR
    brcnt = size(br->qual,5), br_found = 0
    FOR (x = 1 TO brcnt)
      IF ((c.catalog_cd=br->qual[x].cd))
       br_found = 1
      ENDIF
    ENDFOR
    IF (br_found=0
     AND match=1)
     temp->qual[d.seq].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt
      ),
     temp->qual[d.seq].match[mcnt].b_cd = c.catalog_cd, temp->qual[d.seq].match[mcnt].b_mnemonic = c
     .primary_mnemonic, temp->qual[d.seq].match[mcnt].b_desc = c.description,
     temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki, temp->qual[d.seq].match[mcnt].type = 3,
     temp->qual[d.seq].match[mcnt].value = c.cpt4,
     brcnt = (brcnt+ 1), stat = alterlist(br->qual,brcnt), br->qual[brcnt].cd = c.catalog_cd
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  FOR (x = 1 TO cnt)
   SET cpt_cnt = 0
   IF ((temp->qual[x].match_ind=0))
    SET cpt_cnt = size(temp->qual[x].m_cpt,5)
    IF (cpt_cnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(cpt_cnt)),
       br_auto_order_catalog c
      PLAN (d)
       JOIN (c
       WHERE (c.cpt4=temp->qual[x].m_cpt[d.seq].cpt))
      ORDER BY c.primary_mnemonic
      HEAD REPORT
       mcnt = 0
      DETAIL
       match = 1
       FOR (q = 1 TO match_oc_cnt)
         IF ((c.catalog_cd=match_oc->qual[q].cd))
          match = 0
         ENDIF
       ENDFOR
       FOR (q = 1 TO match_cki_cnt)
         IF ((c.concept_cki=match_cki->qual[q].cki))
          match = 0
         ENDIF
       ENDFOR
       brcnt = size(br->qual,5), br_found = 0
       FOR (q = 1 TO brcnt)
         IF ((c.catalog_cd=br->qual[q].cd))
          br_found = 1
         ENDIF
       ENDFOR
       IF (br_found=0
        AND match=1)
        temp->qual[x].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[x].match,mcnt),
        temp->qual[x].match[mcnt].b_cd = c.catalog_cd, temp->qual[x].match[mcnt].b_mnemonic = c
        .primary_mnemonic, temp->qual[x].match[mcnt].b_desc = c.description,
        temp->qual[x].match[mcnt].b_cki = c.concept_cki, temp->qual[x].match[mcnt].type = 3, temp->
        qual[x].match[mcnt].value = c.cpt4,
        brcnt = (brcnt+ 1), stat = alterlist(br->qual,brcnt), br->qual[brcnt].cd = c.catalog_cd
       ENDIF
      WITH nocounter, skipbedrock = 1
     ;end select
    ENDIF
   ENDIF
  ENDFOR
  SET rcnt = 0
  FOR (x = 1 TO cnt)
    IF ((temp->qual[x].match_ind=1)
     AND size(temp->qual[x].match,5) > 1)
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->orderables,rcnt)
     SET reply->orderables[rcnt].legacy.id = temp->qual[x].l_id
     SET reply->orderables[rcnt].legacy.short_desc = temp->qual[x].l_mnemonic2
     SET reply->orderables[rcnt].legacy.long_desc = temp->qual[x].l_desc2
     SET reply->orderables[rcnt].legacy.alias = temp->qual[x].l_alias
     SET reply->orderables[rcnt].millennium.code_value = temp->qual[x].m_cd
     SET reply->orderables[rcnt].millennium.mnemonic = temp->qual[x].m_mnemonic2
     SET reply->orderables[rcnt].millennium.concept_cki = temp->qual[x].m_concept_cki
     FOR (y = 1 TO size(temp->qual[x].match,5))
       SET stat = alterlist(reply->orderables[rcnt].matches,y)
       SET reply->orderables[rcnt].matches[y].code_value = temp->qual[x].match[y].b_cd
       SET reply->orderables[rcnt].matches[y].mnemonic = temp->qual[x].match[y].b_mnemonic
       SET reply->orderables[rcnt].matches[y].description = temp->qual[x].match[y].b_desc
       SET reply->orderables[rcnt].matches[y].match_type_flag = temp->qual[x].match[y].type
       SET reply->orderables[rcnt].matches[y].match_value = temp->qual[x].match[y].value
       SET reply->orderables[rcnt].matches[y].concept_cki = temp->qual[x].match[y].b_cki
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 CALL echorecord(reply)
#exit_script
 IF (rcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
