CREATE PROGRAM bed_get_pharm_unmatched_items:dba
 FREE SET reply
 RECORD reply(
   1 mill[*]
     2 ndc = vc
     2 description = vc
     2 package_size = vc
     2 generic_name = vc
     2 brand_name = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET max_cnt = 0
 IF ((request->max_reply > 0))
  SET max_cnt = request->max_reply
 ELSE
  SET max_cnt = 5000
 ENDIF
 DECLARE search_string = vc
 IF ((request->search_type_ind=3))
  SET request->search_string = replace(request->search_string,"-","",0)
 ENDIF
 SET search_string = concat('"',trim(request->search_string),'*"')
 SET search_string = cnvtupper(search_string)
 CALL echo(search_string)
 SET mcnt = 0
 SET alterlist_mcnt = 0
 SET stat = alterlist(reply->mill,100)
 IF ((request->search_type_ind=1))
  DECLARE drug_name_parse = vc
  SET drug_name_parse = concat("cnvtupper(n.drug_name) = ",search_string)
  SELECT INTO "NL:"
   FROM mltm_ndc_core_description d,
    mltm_mmdc_name_map m,
    mltm_drug_name n,
    br_auto_multum a,
    mltm_units u
   PLAN (d)
    JOIN (m
    WHERE m.main_multum_drug_code=d.main_multum_drug_code)
    JOIN (n
    WHERE n.drug_synonym_id=m.drug_synonym_id
     AND parser(drug_name_parse))
    JOIN (a
    WHERE a.mmdc=outerjoin(concat("MUL.FRMLTN!",trim(cnvtstring(d.main_multum_drug_code)))))
    JOIN (u
    WHERE u.unit_id=outerjoin(d.inner_package_desc_code))
   ORDER BY d.ndc_code
   DETAIL
    mcnt = (mcnt+ 1), alterlist_mcnt = (alterlist_mcnt+ 1)
    IF (alterlist_mcnt > 100)
     stat = alterlist(reply->mill,(mcnt+ 100)), alterlist_mcnt = 1
    ENDIF
    reply->mill[mcnt].ndc = d.ndc_code
    IF (a.label_description > " ")
     reply->mill[mcnt].description = a.label_description
    ELSE
     reply->mill[mcnt].description = n.drug_name
    ENDIF
    reply->mill[mcnt].generic_name = n.drug_name
    IF (d.inner_package_desc_code=0)
     reply->mill[mcnt].package_size = concat(trim(cnvtstring(d.inner_package_size))," EA")
    ELSE
     reply->mill[mcnt].package_size = concat(trim(cnvtstring(d.inner_package_size))," ",trim(u
       .unit_abbr))
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((request->search_type_ind=2))
  DECLARE brand_name_parse = vc
  SET brand_name_parse = concat("cnvtupper(b.brand_description) = ",search_string)
  SELECT INTO "NL:"
   FROM mltm_ndc_core_description d,
    mltm_ndc_brand_name b,
    mltm_mmdc_name_map m,
    mltm_drug_name n,
    br_auto_multum a,
    mltm_units u
   PLAN (d)
    JOIN (b
    WHERE b.brand_code=d.brand_code
     AND parser(brand_name_parse))
    JOIN (m
    WHERE m.main_multum_drug_code=d.main_multum_drug_code)
    JOIN (n
    WHERE n.drug_synonym_id=m.drug_synonym_id)
    JOIN (a
    WHERE a.mmdc=outerjoin(concat("MUL.FRMLTN!",trim(cnvtstring(d.main_multum_drug_code)))))
    JOIN (u
    WHERE u.unit_id=outerjoin(d.inner_package_desc_code))
   ORDER BY d.ndc_code
   HEAD d.ndc_code
    mcnt = (mcnt+ 1), alterlist_mcnt = (alterlist_mcnt+ 1)
    IF (alterlist_mcnt > 100)
     stat = alterlist(reply->mill,(mcnt+ 100)), alterlist_mcnt = 1
    ENDIF
    reply->mill[mcnt].ndc = d.ndc_code
    IF (a.label_description > " ")
     reply->mill[mcnt].description = a.label_description
    ELSE
     reply->mill[mcnt].description = n.drug_name
    ENDIF
    reply->mill[mcnt].generic_name = n.drug_name, reply->mill[mcnt].brand_name = b.brand_description
    IF (d.inner_package_desc_code=0)
     reply->mill[mcnt].package_size = concat(trim(cnvtstring(d.inner_package_size))," EA")
    ELSE
     reply->mill[mcnt].package_size = concat(trim(cnvtstring(d.inner_package_size))," ",trim(u
       .unit_abbr))
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((request->search_type_ind=3))
  DECLARE ndc_parse = vc
  SET ndc_parse = concat("cnvtupper(d.ndc_code) = ",search_string)
  SELECT INTO "NL:"
   FROM mltm_ndc_core_description d,
    mltm_mmdc_name_map m,
    mltm_drug_name n,
    br_auto_multum a,
    mltm_units u
   PLAN (d
    WHERE parser(ndc_parse))
    JOIN (m
    WHERE m.main_multum_drug_code=d.main_multum_drug_code)
    JOIN (n
    WHERE n.drug_synonym_id=m.drug_synonym_id)
    JOIN (a
    WHERE a.mmdc=outerjoin(concat("MUL.FRMLTN!",trim(cnvtstring(d.main_multum_drug_code)))))
    JOIN (u
    WHERE u.unit_id=outerjoin(d.inner_package_desc_code))
   ORDER BY d.ndc_code
   HEAD d.ndc_code
    mcnt = (mcnt+ 1), alterlist_mcnt = (alterlist_mcnt+ 1)
    IF (alterlist_mcnt > 100)
     stat = alterlist(reply->mill,(mcnt+ 100)), alterlist_mcnt = 1
    ENDIF
    reply->mill[mcnt].ndc = d.ndc_code
    IF (a.label_description > " ")
     reply->mill[mcnt].description = a.label_description
    ELSE
     reply->mill[mcnt].description = n.drug_name
    ENDIF
    reply->mill[mcnt].generic_name = n.drug_name
    IF (d.inner_package_desc_code=0)
     reply->mill[mcnt].package_size = concat(trim(cnvtstring(d.inner_package_size))," EA")
    ELSE
     reply->mill[mcnt].package_size = concat(trim(cnvtstring(d.inner_package_size))," ",trim(u
       .unit_abbr))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->mill,mcnt)
 IF (mcnt > 0)
  IF (mcnt > max_cnt)
   SET stat = alterlist(reply->mill,0)
   SET reply->too_many_results_ind = 1
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
