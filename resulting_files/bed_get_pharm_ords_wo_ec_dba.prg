CREATE PROGRAM bed_get_pharm_ords_wo_ec:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orders[*]
      2 catalog_code_value = f8
      2 description = vc
      2 primary_mnemonic = vc
      2 immunization_ind = i2
      2 order_cki = vc
      2 ignore_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_rep
 RECORD temp_rep(
   1 orders[*]
     2 dnum = vc
 )
 SET reply->status_data.status = "F"
 DECLARE cat_parse_txt = vc
 SET pharmacy_ct_code_value = 0.0
 SET primary_code_value = 0.0
 SET pharmacy_ct_code_value = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET primary_code_value = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET immunization_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=93
   AND cv.display_key="IMMUNIZATIONS"
   AND cv.active_ind=1
  DETAIL
   immunization_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   code_value c,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.catalog_type_cd=pharmacy_ct_code_value
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    cr.parent_cd
    FROM code_value_event_r cr
    WHERE cr.parent_cd=oc.catalog_cd))))
   JOIN (c
   WHERE c.code_value=oc.catalog_cd
    AND c.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=c.code_value
    AND ocs.mnemonic_type_cd=primary_code_value
    AND ocs.active_ind=1)
  ORDER BY oc.catalog_cd
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->orders,100),
   stat = alterlist(temp_rep->orders,100)
  HEAD oc.catalog_cd
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->orders,(tcnt+ 100)), stat = alterlist(temp_rep->orders,(tcnt+ 100)), cnt
     = 1
   ENDIF
   reply->orders[tcnt].catalog_code_value = oc.catalog_cd, reply->orders[tcnt].description = oc
   .description, reply->orders[tcnt].primary_mnemonic = ocs.mnemonic,
   reply->orders[tcnt].order_cki = oc.cki
   IF (oc.cki="MUL.ORD!*")
    dnumlen = textlen(oc.cki), temp_rep->orders[tcnt].dnum = substring(9,dnumlen,oc.cki)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->orders,tcnt), stat = alterlist(temp_rep->orders,tcnt)
  WITH nocounter
 ;end select
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET drug_cat_id = 0.0
 SELECT INTO "nl:"
  FROM mltm_drug_categories mdc
  WHERE cnvtupper(mdc.category_name)="IMMUNOLOGIC AGENTS"
  DETAIL
   drug_cat_id = mdc.multum_category_id
  WITH nocounter
 ;end select
 SET cat_parse_txt = "x.multum_category_id IN ("
 SELECT INTO "nl:"
  FROM mltm_category_sub_xref mcs
  WHERE mcs.multum_category_id=drug_cat_id
  DETAIL
   cat_parse_txt = build(cat_parse_txt,mcs.sub_category_id,",")
  WITH nocounter
 ;end select
 SET cat_parse_txt = build(cat_parse_txt,drug_cat_id,")")
 SET immunization_ind = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tcnt)),
   mltm_drug_name m,
   mltm_drug_name_map mm,
   mltm_category_drug_xref x
  PLAN (d)
   JOIN (mm
   WHERE (mm.drug_identifier=temp_rep->orders[d.seq].dnum)
    AND mm.function_id=16)
   JOIN (m
   WHERE m.drug_synonym_id=mm.drug_synonym_id)
   JOIN (x
   WHERE x.drug_identifier=mm.drug_identifier
    AND parser(cat_parse_txt))
  ORDER BY d.seq
  DETAIL
   reply->orders[d.seq].immunization_ind = 1
  WITH nocounter
 ;end select
 SET reply_cnt = size(reply->orders,5)
 IF (reply_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(reply_cnt)),
    br_name_value b
   PLAN (d)
    JOIN (b
    WHERE b.br_nv_key1="MLTM_IGN_ORDS_WO_EC"
     AND (cnvtreal(trim(b.br_value))=reply->orders[d.seq].catalog_code_value)
     AND b.br_name="ORDER_CATALOG")
   DETAIL
    reply->orders[d.seq].ignore_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
