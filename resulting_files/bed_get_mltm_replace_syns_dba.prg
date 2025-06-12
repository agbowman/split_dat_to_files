CREATE PROGRAM bed_get_mltm_replace_syns:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 synonyms[*]
      2 synonym_id = f8
      2 catalog_cd = f8
      2 mnemonic = vc
      2 mmdc = i4
      2 ndc_type = i2
      2 brand_name = vc
      2 synonym_type
        3 code_value = f8
        3 display = vc
        3 meaning = vc
      2 order_entry_format
        3 oe_format_id = f8
        3 name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE multum_order_cki_prefix = vc WITH protect, constant("MUL.ORD-SYN!")
 DECLARE true = vc WITH protect, constant("T")
 DECLARE cs48_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE cs6003_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE catalog_cd = f8 WITH protect, noconstant(0.0)
 DECLARE synonym_count = i4 WITH protect, noconstant(0)
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
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs
  WHERE (ocs.synonym_id=request->synonym_id)
   AND ocs.active_ind=1
   AND ocs.active_status_cd=cs48_active_cd
  DETAIL
   catalog_cd = ocs.catalog_cd
  WITH nocounter
 ;end select
 CALL bederrorcheck("ERROR 001: Can't get catalog code for inputed synonym.")
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   code_value cv,
   order_entry_format oef,
   mltm_drug_name mdn,
   mltm_drug_name_map md,
   mltm_mmdc_name_map mm,
   mltm_ndc_core_description mn,
   mltm_ndc_brand_name mbn
  PLAN (ocs
   WHERE ocs.catalog_cd=catalog_cd
    AND (ocs.synonym_id != request->synonym_id)
    AND ocs.active_ind=1
    AND ocs.active_status_cd=cs48_active_cd)
   JOIN (cv
   WHERE cv.code_value=ocs.mnemonic_type_cd)
   JOIN (oef
   WHERE oef.oe_format_id=ocs.oe_format_id
    AND oef.action_type_cd=cs6003_order_cd)
   JOIN (mdn
   WHERE concat("MUL.ORD-SYN!",cnvtstring(mdn.drug_synonym_id))=outerjoin(ocs.cki))
   JOIN (md
   WHERE md.drug_synonym_id=outerjoin(mdn.drug_synonym_id))
   JOIN (mm
   WHERE mm.drug_synonym_id=outerjoin(mdn.drug_synonym_id))
   JOIN (mn
   WHERE mn.main_multum_drug_code=outerjoin(mm.main_multum_drug_code))
   JOIN (mbn
   WHERE mbn.brand_code=outerjoin(mn.brand_code))
  ORDER BY ocs.mnemonic, ocs.synonym_id
  HEAD ocs.synonym_id
   IF (cnvtupper(mdn.is_obsolete) != true)
    synonym_count = (synonym_count+ 1), stat = alterlist(reply->synonyms,synonym_count), reply->
    synonyms[synonym_count].synonym_id = ocs.synonym_id,
    reply->synonyms[synonym_count].catalog_cd = ocs.catalog_cd, reply->synonyms[synonym_count].
    mnemonic = ocs.mnemonic, reply->synonyms[synonym_count].synonym_type.code_value = cv.code_value,
    reply->synonyms[synonym_count].synonym_type.display = cv.display, reply->synonyms[synonym_count].
    synonym_type.meaning = cv.cdf_meaning, reply->synonyms[synonym_count].order_entry_format.
    oe_format_id = oef.oe_format_id,
    reply->synonyms[synonym_count].order_entry_format.name = oef.oe_format_name
    IF (mm.main_multum_drug_code != null)
     reply->synonyms[synonym_count].mmdc = mm.main_multum_drug_code, reply->synonyms[synonym_count].
     brand_name = mbn.brand_description
     IF (md.function_id=17)
      reply->synonyms[synonym_count].ndc_type = 1
     ELSEIF (md.function_id > 0)
      reply->synonyms[synonym_count].ndc_type = 2
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("ERROR 002: Can't load synonyms and multum data.")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
