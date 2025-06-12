CREATE PROGRAM bed_get_pharm_oc_cnum:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 primary_mnemonics[*]
      2 synonym_id = f8
      2 mnemonic = vc
      2 cnum = vc
      2 dnum = vc
      2 ignore_ind = i2
      2 synonyms[*]
        3 synonym_id = f8
        3 mnemonic = vc
        3 ignore_ind = i2
        3 mnemonic_type_code_value = f8
        3 mnemonic_type_display = vc
        3 mnemonic_type_meaning = vc
      2 catalog_code_value = f8
      2 dnum_concept_cki = vc
      2 cnum_concept_cki = vc
      2 synonym_type_code = f8
      2 synonym_type_disp = vc
      2 synonym_type_mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD catalog_cd(
   1 catalog[*]
     2 code_value = f8
     2 dnum = vc
     2 concept_cki = vc
 )
 DECLARE pharmacy_cd = f8
 DECLARE primary_cd = f8
 DECLARE primary_code_value = f8
 DECLARE brand_code_value = f8
 DECLARE dcp_code_value = f8
 DECLARE c_code_value = f8
 DECLARE e_code_value = f8
 DECLARE m_code_value = f8
 DECLARE n_code_value = f8
 DECLARE z_code_value = f8
 DECLARE y_code_value = f8
 DECLARE dcp_cd = f8
 DECLARE brandname_cd = f8
 DECLARE genericname_cd = f8
 DECLARE genericprod_cd = f8
 DECLARE ivname_cd = f8
 DECLARE tradeprod_cd = f8
 DECLARE tradetop_cd = f8
 DECLARE cnt = i4
 DECLARE list_count = i4
 DECLARE len = i4
 DECLARE sub_cnt = i4
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_count = 0
 SET len = 0
 SET sub_cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   pharmacy_cd = cv.code_value
  WITH nocounter
 ;end select
 SET primary_code_value = 0.0
 SET primary_code_value = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET brand_code_value = 0.0
 SET brand_code_value = uar_get_code_by("MEANING",6011,"BRANDNAME")
 SET dcp_code_value = 0.0
 SET dcp_code_value = uar_get_code_by("MEANING",6011,"DCP")
 SET c_code_value = 0.0
 SET c_code_value = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET e_code_value = 0.0
 SET e_code_value = uar_get_code_by("MEANING",6011,"IVNAME")
 SET m_code_value = 0.0
 SET m_code_value = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET n_code_value = 0.0
 SET n_code_value = uar_get_code_by("MEANING",6011,"TRADETOP")
 SET z_code_value = 0.0
 SET z_code_value = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET y_code_value = 0.0
 SET y_code_value = uar_get_code_by("MEANING",6011,"GENERICPROD")
 SELECT DISTINCT INTO "nl:"
  oc.catalog_cd
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   mltm_order_catalog_load m
  PLAN (oc
   WHERE oc.catalog_type_cd=pharmacy_cd
    AND ((oc.orderable_type_flag=1) OR (oc.orderable_type_flag=0))
    AND ((oc.cki="MUL.MMDC!*") OR (oc.cki="MUL.ORD!*"))
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ((ocs.cki=" ") OR (((ocs.cki=null) OR (ocs.cki="")) ))
    AND ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value, c_code_value,
   e_code_value,
   m_code_value, n_code_value, z_code_value, y_code_value)
    AND ocs.active_ind=1)
   JOIN (m
   WHERE m.catalog_cki=oc.cki)
  ORDER BY oc.catalog_cd
  HEAD REPORT
   cnt = 0, list_count = 0, stat = alterlist(catalog_cd->catalog,100)
  HEAD oc.catalog_cd
   list_count = (list_count+ 1), cnt = (cnt+ 1)
   IF (list_count > 100)
    stat = alterlist(catalog_cd->catalog,(cnt+ 100)), list_count = 1
   ENDIF
   catalog_cd->catalog[cnt].code_value = oc.catalog_cd, catalog_cd->catalog[cnt].dnum = oc.cki,
   catalog_cd->catalog[cnt].concept_cki = m.catalog_concept_cki
  FOOT REPORT
   stat = alterlist(catalog_cd->catalog,cnt)
  WITH nocoutner
 ;end select
 SET stat = alterlist(reply->primary_mnemonics,cnt)
 DECLARE ocnt = i4
 IF (cnt > 0)
  SET ocnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    order_catalog_synonym ocs,
    code_value cv
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.catalog_cd=catalog_cd->catalog[d.seq].code_value)
     AND ocs.mnemonic_type_cd=primary_code_value
     AND ocs.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.active_ind=1
     AND cv.code_set=6011)
   ORDER BY ocs.catalog_cd
   HEAD REPORT
    ocnt = 0, stat = alterlist(reply->primary_mnemonics,cnt)
   HEAD ocs.catalog_cd
    ocnt = (ocnt+ 1), reply->primary_mnemonics[ocnt].synonym_id = ocs.synonym_id, reply->
    primary_mnemonics[ocnt].mnemonic = ocs.mnemonic,
    reply->primary_mnemonics[ocnt].dnum = catalog_cd->catalog[d.seq].dnum, reply->primary_mnemonics[
    ocnt].dnum_concept_cki = catalog_cd->catalog[d.seq].concept_cki, reply->primary_mnemonics[ocnt].
    cnum = ocs.cki,
    reply->primary_mnemonics[ocnt].cnum_concept_cki = ocs.concept_cki, reply->primary_mnemonics[ocnt]
    .ignore_ind = 0, reply->primary_mnemonics[ocnt].catalog_code_value = ocs.catalog_cd,
    reply->primary_mnemonics[ocnt].synonym_type_code = ocs.mnemonic_type_cd, reply->
    primary_mnemonics[ocnt].synonym_type_disp = cv.display, reply->primary_mnemonics[ocnt].
    synonym_type_mean = cv.cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->primary_mnemonics,ocnt)
   WITH nocounter
  ;end select
  IF (ocnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = ocnt),
     order_catalog_synonym ocs,
     code_value cv
    PLAN (d)
     JOIN (ocs
     WHERE (ocs.catalog_cd=reply->primary_mnemonics[d.seq].catalog_code_value)
      AND ((ocs.cki=" ") OR (((ocs.cki=null) OR (ocs.cki="")) ))
      AND ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value, c_code_value,
     e_code_value,
     m_code_value, n_code_value, z_code_value, y_code_value)
      AND ocs.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=ocs.mnemonic_type_cd
      AND cv.active_ind=1
      AND cv.code_set=6011)
    HEAD d.seq
     sub_cnt = 0, list_count = 0, stat = alterlist(reply->primary_mnemonics[d.seq].synonyms,10)
    DETAIL
     list_count = (list_count+ 1), sub_cnt = (sub_cnt+ 1)
     IF (list_count > 10)
      stat = alterlist(reply->primary_mnemonics[d.seq].synonyms,(sub_cnt+ 10)), list_count = 1
     ENDIF
     reply->primary_mnemonics[d.seq].synonyms[sub_cnt].synonym_id = ocs.synonym_id, reply->
     primary_mnemonics[d.seq].synonyms[sub_cnt].mnemonic = ocs.mnemonic, reply->primary_mnemonics[d
     .seq].synonyms[sub_cnt].ignore_ind = 0,
     reply->primary_mnemonics[d.seq].synonyms[sub_cnt].mnemonic_type_code_value = ocs
     .mnemonic_type_cd, reply->primary_mnemonics[d.seq].synonyms[sub_cnt].mnemonic_type_display = cv
     .display, reply->primary_mnemonics[d.seq].synonyms[sub_cnt].mnemonic_type_meaning = cv
     .cdf_meaning
    FOOT  d.seq
     stat = alterlist(reply->primary_mnemonics[d.seq].synonyms,sub_cnt)
    WITH nocoutner
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = ocnt),
     br_name_value b
    PLAN (d)
     JOIN (b
     WHERE (cnvtreal(trim(b.br_value))=reply->primary_mnemonics[d.seq].synonym_id)
      AND b.br_nv_key1="MLTM_IGN_CNUM"
      AND b.br_name="ORDER_CATALOG_SYNONYM")
    DETAIL
     reply->primary_mnemonics[d.seq].ignore_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = ocnt),
     (dummyt d2  WITH seq = 1),
     br_name_value b
    PLAN (d
     WHERE maxrec(d2,size(reply->primary_mnemonics[d.seq].synonyms,5)) > 0)
     JOIN (d2)
     JOIN (b
     WHERE (cnvtreal(trim(b.br_value))=reply->primary_mnemonics[d.seq].synonyms[d2.seq].synonym_id)
      AND b.br_nv_key1="MLTM_IGN_CNUM"
      AND b.br_name="ORDER_CATALOG_SYNONYM")
    DETAIL
     reply->primary_mnemonics[d.seq].synonyms[d2.seq].ignore_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
