CREATE PROGRAM bed_get_pharm_multum_matches:dba
 FREE SET reply
 RECORD reply(
   1 mill[*]
     2 ndc = vc
     2 description = vc
     2 package_size_nbr = f8
     2 package_size_unit = vc
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
 DECLARE search_string = vc
 DECLARE ndc_parse = vc
 DECLARE start_pos = i4
 DECLARE legacy_first_word = vc
 DECLARE mill_first_word = vc
 SET mcnt = 0
 SET alterlist_mcnt = 0
 SET stat = alterlist(reply->mill,100)
 IF ((request->match_type_ind=1))
  SET search_string = concat(substring(1,9,request->legacy_ndc),"*")
  SET ndc_parse = concat("m.ndc_code = '",search_string,"'")
  SELECT INTO "NL:"
   FROM mltm_ndc_core_description m,
    nomenclature n,
    br_auto_multum a,
    mltm_units u
   PLAN (m
    WHERE parser(ndc_parse))
    JOIN (n
    WHERE n.source_identifier=cnvtstring(m.main_multum_drug_code)
     AND n.source_vocabulary_cd=vocab_cd
     AND n.primary_vterm_ind=1
     AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND n.active_ind=1)
    JOIN (a
    WHERE a.mmdc=outerjoin(concat("MUL.FRMLTN!",trim(cnvtstring(m.main_multum_drug_code)))))
    JOIN (u
    WHERE u.unit_id=outerjoin(m.inner_package_desc_code))
   DETAIL
    mcnt = (mcnt+ 1), alterlist_mcnt = (alterlist_mcnt+ 1)
    IF (alterlist_mcnt > 100)
     stat = alterlist(reply->mill,(mcnt+ 100)), alterlist_mcnt = 1
    ENDIF
    reply->mill[mcnt].ndc = m.ndc_code
    IF (a.label_description > " ")
     reply->mill[mcnt].description = a.label_description
    ELSE
     reply->mill[mcnt].description = n.source_string
    ENDIF
    IF (m.inner_package_desc_code=0)
     reply->mill[mcnt].package_size_unit = "EA"
    ELSE
     reply->mill[mcnt].package_size_unit = trim(u.unit_abbr)
    ENDIF
    reply->mill[mcnt].package_size_nbr = m.inner_package_size
   WITH nocounter
  ;end select
 ELSE
  SET legacy_first_word = " "
  SET space_pos = 0
  SET space_pos = findstring(" ",request->legacy_description,1)
  IF (space_pos > 0)
   SET legacy_first_word = substring(1,(space_pos - 1),request->legacy_description)
  ELSE
   SET legacy_first_word = request->legacy_description
  ENDIF
  SET search_string = concat(substring(1,5,request->legacy_ndc),"*")
  SET ndc_parse = concat("m.ndc_code = '",search_string,"'")
  SELECT INTO "NL:"
   FROM mltm_ndc_core_description m,
    nomenclature n,
    br_auto_multum a,
    mltm_units u
   PLAN (m
    WHERE parser(ndc_parse))
    JOIN (n
    WHERE n.source_identifier=cnvtstring(m.main_multum_drug_code)
     AND n.source_vocabulary_cd=vocab_cd
     AND n.primary_vterm_ind=1
     AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND n.active_ind=1)
    JOIN (a
    WHERE a.mmdc=outerjoin(concat("MUL.FRMLTN!",trim(cnvtstring(m.main_multum_drug_code)))))
    JOIN (u
    WHERE u.unit_id=outerjoin(m.inner_package_desc_code))
   DETAIL
    mill_first_word = " ", space_pos = 0
    IF (a.label_description > " ")
     space_pos = findstring(" ",a.label_description,1)
     IF (space_pos > 0)
      mill_first_word = substring(1,(space_pos - 1),a.label_description)
     ELSE
      mill_first_word = a.label_description
     ENDIF
    ELSE
     space_pos = findstring(" ",n.source_string,1)
     IF (space_pos > 0)
      mill_first_word = substring(1,(space_pos - 1),n.source_string)
     ELSE
      mill_first_word = n.source_string
     ENDIF
    ENDIF
    IF (cnvtupper(legacy_first_word)=cnvtupper(mill_first_word))
     mcnt = (mcnt+ 1), alterlist_mcnt = (alterlist_mcnt+ 1)
     IF (alterlist_mcnt > 100)
      stat = alterlist(reply->mill,(mcnt+ 100)), alterlist_mcnt = 1
     ENDIF
     reply->mill[mcnt].ndc = m.ndc_code
     IF (a.label_description > " ")
      reply->mill[mcnt].description = a.label_description
     ELSE
      reply->mill[mcnt].description = n.source_string
     ENDIF
     IF (m.inner_package_desc_code=0)
      reply->mill[mcnt].package_size_unit = "EA"
     ELSE
      reply->mill[mcnt].package_size_unit = trim(u.unit_abbr)
     ENDIF
    ENDIF
    reply->mill[mcnt].package_size_nbr = m.inner_package_size
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->mill,mcnt)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
