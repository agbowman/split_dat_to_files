CREATE PROGRAM bed_get_oc_synonym:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 synonyms[*]
      2 id = f8
      2 name = c100
      2 type_flag = i2
      2 order_entry_format_id = f8
      2 catalog_code
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 mnemonic_type
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 catalog_type
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 activity_type
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 subactivity_type
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 clinical_category
        3 code_value = f8
        3 display = vc
        3 mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->synonym_ids,5)
 SET scnt = 0
 SET stat = alterlist(reply->synonyms,req_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = req_cnt),
   order_catalog_synonym ocs,
   code_value catalog_code,
   code_value mnemonic_type,
   code_value catalog_type,
   code_value activity_type,
   code_value subactivity_type,
   code_value clinical_category
  PLAN (d)
   JOIN (ocs
   WHERE (ocs.synonym_id=request->synonym_ids[d.seq].id))
   JOIN (catalog_code
   WHERE catalog_code.code_value=ocs.catalog_cd
    AND catalog_code.active_ind=1)
   JOIN (mnemonic_type
   WHERE mnemonic_type.code_value=ocs.mnemonic_type_cd
    AND mnemonic_type.active_ind=1)
   JOIN (catalog_type
   WHERE catalog_type.code_value=ocs.catalog_type_cd
    AND catalog_type.active_ind=1)
   JOIN (activity_type
   WHERE activity_type.code_value=ocs.activity_type_cd
    AND activity_type.active_ind=1)
   JOIN (subactivity_type
   WHERE subactivity_type.code_value=outerjoin(ocs.activity_subtype_cd)
    AND subactivity_type.active_ind=outerjoin(1))
   JOIN (clinical_category
   WHERE clinical_category.code_value=outerjoin(ocs.dcp_clin_cat_cd)
    AND clinical_category.active_ind=outerjoin(1))
  ORDER BY ocs.mnemonic
  DETAIL
   scnt = (scnt+ 1), reply->synonyms[scnt].id = ocs.synonym_id, reply->synonyms[scnt].name = ocs
   .mnemonic,
   reply->synonyms[scnt].type_flag = ocs.orderable_type_flag, reply->synonyms[scnt].
   order_entry_format_id = ocs.oe_format_id, reply->synonyms[scnt].catalog_code.code_value =
   catalog_code.code_value,
   reply->synonyms[scnt].catalog_code.display = catalog_code.display, reply->synonyms[scnt].
   catalog_code.mean = catalog_code.cdf_meaning, reply->synonyms[scnt].mnemonic_type.code_value =
   mnemonic_type.code_value,
   reply->synonyms[scnt].mnemonic_type.display = mnemonic_type.display, reply->synonyms[scnt].
   mnemonic_type.mean = mnemonic_type.cdf_meaning, reply->synonyms[scnt].catalog_type.code_value =
   catalog_type.code_value,
   reply->synonyms[scnt].catalog_type.display = catalog_type.display, reply->synonyms[scnt].
   catalog_type.mean = catalog_type.cdf_meaning, reply->synonyms[scnt].activity_type.code_value =
   activity_type.code_value,
   reply->synonyms[scnt].activity_type.display = activity_type.display, reply->synonyms[scnt].
   activity_type.mean = activity_type.cdf_meaning, reply->synonyms[scnt].subactivity_type.code_value
    = subactivity_type.code_value,
   reply->synonyms[scnt].subactivity_type.display = subactivity_type.display, reply->synonyms[scnt].
   subactivity_type.mean = subactivity_type.cdf_meaning, reply->synonyms[scnt].clinical_category.
   code_value = clinical_category.code_value,
   reply->synonyms[scnt].clinical_category.display = clinical_category.display, reply->synonyms[scnt]
   .clinical_category.mean = clinical_category.cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->synonyms,scnt)
#exit_script
 SET reply->status_data.status = "S"
END GO
