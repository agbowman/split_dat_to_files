CREATE PROGRAM bed_get_pharm_multum_items:dba
 FREE SET reply
 RECORD reply(
   1 mill[*]
     2 ndc = vc
     2 description = vc
     2 package_size_nbr = f8
     2 package_size_unit = vc
   1 end_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->end_ind = 0
 SET vocab_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=400
   AND cv.cdf_meaning="MUL.MMDC"
  DETAIL
   vocab_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE last_ndc = f8
 SET last_ndc = cnvtreal(request->last_ndc)
 SET mcnt = 0
 SET stat = alterlist(reply->mill,50000)
 SELECT INTO "NL:"
  FROM mltm_ndc_core_description d,
   nomenclature n,
   br_auto_multum a,
   mltm_units u
  PLAN (d
   WHERE cnvtreal(d.ndc_code) > last_ndc)
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
  ORDER BY d.ndc_code
  DETAIL
   mcnt = (mcnt+ 1), reply->mill[mcnt].ndc = d.ndc_code
   IF (a.label_description > " ")
    reply->mill[mcnt].description = a.label_description
   ELSE
    reply->mill[mcnt].description = n.source_string
   ENDIF
   IF (d.inner_package_desc_code=0)
    reply->mill[mcnt].package_size_unit = "EA"
   ELSE
    reply->mill[mcnt].package_size_unit = trim(u.unit_abbr)
   ENDIF
   reply->mill[mcnt].package_size_nbr = d.inner_package_size
  WITH nocounter, maxread(d,50000)
 ;end select
 IF (mcnt < 50000)
  SET stat = alterlist(reply->mill,mcnt)
  SET reply->end_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
