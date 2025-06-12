CREATE PROGRAM bed_get_concki_matches:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 millennium
       3 code_value = f8
       3 mnemonic = vc
       3 description = vc
     2 matches[*]
       3 code_value = f8
       3 mnemonic = vc
       3 description = vc
       3 match_type_flag = i2
       3 match_value = vc
       3 concept_cki = vc
       3 existing_match_ind = i2
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
 SET cpt4_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=14002
    AND c.cki="CKI.CODEVALUE!3600"
    AND c.active_ind=1)
  DETAIL
   cpt4_cd = c.code_value
  WITH nocounter
 ;end select
 SET ord_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=13016
    AND c.cdf_meaning="ORD CAT"
    AND c.active_ind=1)
  DETAIL
   ord_cd = c.code_value
  WITH nocounter
 ;end select
 SET bill_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=13019
    AND c.cdf_meaning="BILL CODE"
    AND c.active_ind=1)
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
    AND c.cdf_meaning IN ("DCP", "ANCILLARY", "PRIMARY")
    AND c.active_ind=1)
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
 SET lab_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6000
    AND c.cdf_meaning="GENERAL LAB"
    AND c.active_ind=1)
  DETAIL
   lab_cd = c.code_value
  WITH nocounter
 ;end select
 SET rad_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6000
    AND c.cdf_meaning="RADIOLOGY"
    AND c.active_ind=1)
  DETAIL
   rad_cd = c.code_value
  WITH nocounter
 ;end select
 SET surg_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6000
    AND c.cdf_meaning="SURGERY"
    AND c.active_ind=1)
  DETAIL
   surg_cd = c.code_value
  WITH nocounter
 ;end select
 SET pharm_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6000
    AND c.cdf_meaning="PHARMACY"
    AND c.active_ind=1)
  DETAIL
   pharm_cd = c.code_value
  WITH nocounter
 ;end select
 DECLARE c_string = vc
 CASE (request->content_ind)
  OF 1:
   SET c_string = concat("c.patient_care_ind = 1")
  OF 2:
   SET c_string = concat("c.laboratory_ind = 1")
  OF 3:
   SET c_string = concat("c.radiology_ind = 1")
  OF 4:
   SET c_string = concat("c.surgery_ind = 1")
  OF 5:
   SET c_string = concat("c.cardiology_ind = 1")
 ENDCASE
 RECORD temp(
   1 qual[*]
     2 m_cd = f8
     2 m_mnemonic = vc
     2 m_desc = vc
     2 m_mnemonic2 = vc
     2 m_desc2 = vc
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
 DECLARE o_string = vc
 SET o_string = build("o.catalog_type_cd = ",request->catalog_type_code_value)
 IF ((request->activity_type_code_value > 0))
  SET o_string = build(o_string," and o.activity_type_cd = ",request->activity_type_code_value)
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog o
  PLAN (o
   WHERE parser(o_string)
    AND o.concept_cki IN ("", " ", null))
  ORDER BY o.primary_mnemonic
  HEAD o.primary_mnemonic
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].m_cd = o.catalog_cd,
   temp->qual[cnt].m_mnemonic = cnvtupper(o.primary_mnemonic), temp->qual[cnt].m_desc = cnvtupper(o
    .description), temp->qual[cnt].m_mnemonic2 = o.primary_mnemonic,
   temp->qual[cnt].m_desc2 = o.description, temp->qual[cnt].match_ind = 0
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
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
    WHERE parser(c_string)
     AND c.catalog_cd=s.catalog_cd)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0, temp->qual[d.seq].match_ind = 1
   HEAD c.catalog_cd
    mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt), temp->qual[d.seq].match[mcnt].
    b_cd = c.catalog_cd,
    temp->qual[d.seq].match[mcnt].b_mnemonic = c.primary_mnemonic, temp->qual[d.seq].match[mcnt].
    b_desc = c.description, temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki,
    temp->qual[d.seq].match[mcnt].type = 1, temp->qual[d.seq].match[mcnt].value = s.mnemonic
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
     AND (((n.alias_name_key_cap=temp->qual[d.seq].m_mnemonic)) OR ((n.alias_name_key_cap=temp->qual[
    d.seq].m_desc))) )
    JOIN (c
    WHERE parser(c_string)
     AND c.catalog_cd=n.parent_entity_id)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0, temp->qual[d.seq].match_ind = 1
   HEAD c.catalog_cd
    mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt), temp->qual[d.seq].match[mcnt].
    b_cd = c.catalog_cd,
    temp->qual[d.seq].match[mcnt].b_mnemonic = c.primary_mnemonic, temp->qual[d.seq].match[mcnt].
    b_desc = c.description, temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki,
    temp->qual[d.seq].match[mcnt].type = 1, temp->qual[d.seq].match[mcnt].value = n.alias_name
   WITH nocounter, skipbedrock = 1
  ;end select
  SET rcnt = 0
  FOR (x = 1 TO cnt)
    IF ((temp->qual[x].match_ind=1))
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->orderables,rcnt)
     SET reply->orderables[rcnt].millennium.code_value = temp->qual[x].m_cd
     SET reply->orderables[rcnt].millennium.mnemonic = temp->qual[x].m_mnemonic2
     SET reply->orderables[rcnt].millennium.description = temp->qual[x].m_desc2
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
  IF (rcnt=0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rcnt)),
    order_catalog o
   PLAN (d)
    JOIN (o
    WHERE (o.concept_cki=reply->orderables[d.seq].matches[1].concept_cki))
   ORDER BY d.seq
   HEAD d.seq
    reply->orderables[d.seq].matches[1].existing_match_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->match_option_flag=2))
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
    WHERE parser(c_string)
     AND c.catalog_cd=n.parent_entity_id)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0
   DETAIL
    temp->qual[d.seq].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt),
    temp->qual[d.seq].match[mcnt].b_cd = c.catalog_cd, temp->qual[d.seq].match[mcnt].b_mnemonic = c
    .primary_mnemonic, temp->qual[d.seq].match[mcnt].b_desc = c.description,
    temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki, temp->qual[d.seq].match[mcnt].type = 2, temp
    ->qual[d.seq].match[mcnt].value = n.alias_name
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
    WHERE parser(c_string)
     AND c.catalog_cd=n.parent_entity_id)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = 0
   DETAIL
    temp->qual[d.seq].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[d.seq].match,mcnt),
    temp->qual[d.seq].match[mcnt].b_cd = c.catalog_cd, temp->qual[d.seq].match[mcnt].b_mnemonic = c
    .primary_mnemonic, temp->qual[d.seq].match[mcnt].b_desc = c.description,
    temp->qual[d.seq].match[mcnt].b_cki = c.concept_cki, temp->qual[d.seq].match[mcnt].type = 2, temp
    ->qual[d.seq].match[mcnt].value = n.alias_name
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
       WHERE parser(c_string)
        AND (c.cpt4=temp->qual[x].m_cpt[d.seq].cpt))
      ORDER BY c.primary_mnemonic
      HEAD REPORT
       mcnt = 0
      DETAIL
       temp->qual[x].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[x].match,mcnt),
       temp->qual[x].match[mcnt].b_cd = c.catalog_cd, temp->qual[x].match[mcnt].b_mnemonic = c
       .primary_mnemonic, temp->qual[x].match[mcnt].b_desc = c.description,
       temp->qual[x].match[mcnt].b_cki = c.concept_cki, temp->qual[x].match[mcnt].type = 3, temp->
       qual[x].match[mcnt].value = c.cpt4
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
     SET reply->orderables[rcnt].millennium.code_value = temp->qual[x].m_cd
     SET reply->orderables[rcnt].millennium.mnemonic = temp->qual[x].m_mnemonic2
     SET reply->orderables[rcnt].millennium.description = temp->qual[x].m_desc2
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
  IF (rcnt=0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rcnt)),
    order_catalog o
   PLAN (d)
    JOIN (o
    WHERE (o.concept_cki=reply->orderables[d.seq].matches[1].concept_cki))
   ORDER BY d.seq
   HEAD d.seq
    reply->orderables[d.seq].matches[1].existing_match_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->match_option_flag=3))
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
       WHERE parser(c_string)
        AND (c.cpt4=temp->qual[x].m_cpt[d.seq].cpt))
      ORDER BY c.primary_mnemonic
      HEAD REPORT
       mcnt = 0
      DETAIL
       temp->qual[x].match_ind = 1, mcnt = (mcnt+ 1), stat = alterlist(temp->qual[x].match,mcnt),
       temp->qual[x].match[mcnt].b_cd = c.catalog_cd, temp->qual[x].match[mcnt].b_mnemonic = c
       .primary_mnemonic, temp->qual[x].match[mcnt].b_desc = c.description,
       temp->qual[x].match[mcnt].b_cki = c.concept_cki, temp->qual[x].match[mcnt].type = 3, temp->
       qual[x].match[mcnt].value = c.cpt4
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
     SET reply->orderables[rcnt].millennium.code_value = temp->qual[x].m_cd
     SET reply->orderables[rcnt].millennium.mnemonic = temp->qual[x].m_mnemonic2
     SET reply->orderables[rcnt].millennium.description = temp->qual[x].m_desc2
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
  IF (rcnt=0)
   GO TO exit_script
  ENDIF
  FOR (x = 1 TO rcnt)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(reply->orderables[x].matches,5))),
      order_catalog o
     PLAN (d)
      JOIN (o
      WHERE (o.concept_cki=reply->orderables[x].matches[d.seq].concept_cki))
     ORDER BY d.seq
     HEAD d.seq
      reply->orderables[x].matches[d.seq].existing_match_ind = 1
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
