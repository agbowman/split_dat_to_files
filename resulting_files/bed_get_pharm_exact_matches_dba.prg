CREATE PROGRAM bed_get_pharm_exact_matches:dba
 FREE SET reply
 RECORD reply(
   1 matches[*]
     2 ndc = vc
     2 legacy_facility
       3 code_value = f8
       3 display = vc
     2 legacy_description = vc
     2 mill_description = vc
     2 mill_package_size_nbr = f8
     2 mill_package_size_unit = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET vocab_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=400
   AND cv.cdf_meaning="MUL.MMDC"
  DETAIL
   vocab_cd = cv.code_value
  WITH nocounter
 ;end select
 SET mcnt = 0
 SET alterlist_mcnt = 0
 SET stat = alterlist(reply->matches,100)
 IF ((request->return_dup_ndc_ind=1))
  SELECT INTO "NL:"
   b.ndc
   FROM br_pharm_product_work b,
    mltm_ndc_core_description d,
    nomenclature n,
    br_auto_multum a,
    mltm_units u,
    code_value cv
   PLAN (b
    WHERE b.match_ind=0)
    JOIN (d
    WHERE d.ndc_code=b.ndc)
    JOIN (n
    WHERE n.source_identifier=cnvtstring(d.main_multum_drug_code)
     AND n.source_vocabulary_cd=vocab_cd
     AND n.primary_vterm_ind=1
     AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND n.active_ind=1)
    JOIN (a
    WHERE a.mmdc=outerjoin(concat("MUL.FRMLTN!",trim(cnvtstring(d.main_multum_drug_code)))))
    JOIN (u
    WHERE u.unit_id=outerjoin(d.inner_package_desc_code))
    JOIN (cv
    WHERE cv.code_value=outerjoin(b.facility_cd))
   ORDER BY b.ndc
   DETAIL
    mcnt = (mcnt+ 1), alterlist_mcnt = (alterlist_mcnt+ 1)
    IF (alterlist_mcnt > 100)
     stat = alterlist(reply->matches,(mcnt+ 100)), alterlist_mcnt = 1
    ENDIF
    reply->matches[mcnt].ndc = b.ndc, reply->matches[mcnt].legacy_facility.code_value = b.facility_cd
    IF (b.facility_cd > 0.0)
     reply->matches[mcnt].legacy_facility.display = cv.display
    ENDIF
    reply->matches[mcnt].legacy_description = b.description
    IF (a.label_description > " ")
     reply->matches[mcnt].mill_description = a.label_description
    ELSE
     reply->matches[mcnt].mill_description = n.source_string
    ENDIF
    IF (d.inner_package_desc_code=0)
     reply->matches[mcnt].mill_package_size_unit = "EA"
    ELSE
     reply->matches[mcnt].mill_package_size_unit = trim(u.unit_abbr)
    ENDIF
    reply->matches[mcnt].mill_package_size_nbr = d.inner_package_size
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "NL:"
   b.facility_cd, b.ndc
   FROM br_pharm_product_work b,
    mltm_ndc_core_description d,
    nomenclature n,
    br_auto_multum a,
    mltm_units u,
    code_value cv
   PLAN (b
    WHERE b.match_ind=0)
    JOIN (d
    WHERE d.ndc_code=b.ndc)
    JOIN (n
    WHERE n.source_identifier=cnvtstring(d.main_multum_drug_code)
     AND n.source_vocabulary_cd=vocab_cd
     AND n.primary_vterm_ind=1
     AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND n.active_ind=1)
    JOIN (a
    WHERE a.mmdc=outerjoin(concat("MUL.FRMLTN!",trim(cnvtstring(d.main_multum_drug_code)))))
    JOIN (u
    WHERE u.unit_id=outerjoin(d.inner_package_desc_code))
    JOIN (cv
    WHERE cv.code_value=outerjoin(b.facility_cd))
   ORDER BY b.facility_cd, b.ndc
   HEAD b.facility_cd
    mcnt = mcnt
   HEAD b.ndc
    mcnt = (mcnt+ 1), alterlist_mcnt = (alterlist_mcnt+ 1)
    IF (alterlist_mcnt > 100)
     stat = alterlist(reply->matches,(mcnt+ 100)), alterlist_mcnt = 1
    ENDIF
    reply->matches[mcnt].ndc = b.ndc, reply->matches[mcnt].legacy_facility.code_value = b.facility_cd
    IF (b.facility_cd > 0.0)
     reply->matches[mcnt].legacy_facility.display = cv.display
    ENDIF
    reply->matches[mcnt].legacy_description = b.description
    IF (a.label_description > " ")
     reply->matches[mcnt].mill_description = a.label_description
    ELSE
     reply->matches[mcnt].mill_description = n.source_string
    ENDIF
    IF (d.inner_package_desc_code=0)
     reply->matches[mcnt].mill_package_size_unit = "EA"
    ELSE
     reply->matches[mcnt].mill_package_size_unit = trim(u.unit_abbr)
    ENDIF
    reply->matches[mcnt].mill_package_size_nbr = d.inner_package_size
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->matches,mcnt)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
