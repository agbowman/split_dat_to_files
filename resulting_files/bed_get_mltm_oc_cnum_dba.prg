CREATE PROGRAM bed_get_mltm_oc_cnum:dba
 FREE SET reply
 RECORD reply(
   1 synonyms[*]
     2 display = vc
     2 cnum = vc
     2 cnum_concept_cki = vc
     2 type_code_value = f8
     2 type_meaning = vc
     2 type_display = vc
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
 SET list_count = 0
 DECLARE parse_txt = vc
 SET parse_txt = concat("m.catalog_cki = '",request->dnum,"' ")
 IF (validate(request->dnum_concept_cki))
  IF ((request->dnum_concept_cki > " "))
   SET parse_txt = concat(parse_txt," and m.catalog_concept_cki = '",request->dnum_concept_cki,"' ")
  ELSE
   SET parse_txt = concat(parse_txt," and m.catalog_concept_cki in ('', ' ', null) ")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM mltm_order_catalog_load m,
   code_value cv
  PLAN (m
   WHERE parser(parse_txt))
   JOIN (cv
   WHERE ((cv.cdf_meaning=m.mnemonic_type_mean
    AND m.mnemonic_type_mean > " ") OR (cnvtupper(cv.display)=cnvtupper(m.mnemonic_type)
    AND  NOT (m.mnemonic_type_mean > " ")))
    AND cv.code_set=6011
    AND cv.active_ind=1)
  ORDER BY m.synonym_cki, m.synonym_concept_cki
  HEAD REPORT
   cnt = 0, list_count = 0, stat = alterlist(reply->synonyms,200)
  HEAD m.synonym_cki
   cnt = cnt
  HEAD m.synonym_concept_cki
   list_count = (list_count+ 1), cnt = (cnt+ 1)
   IF (list_count > 200)
    stat = alterlist(reply->synonyms,(cnt+ 200)), list_count = 1
   ENDIF
   reply->synonyms[cnt].display = m.mnemonic, reply->synonyms[cnt].cnum = m.synonym_cki, reply->
   synonyms[cnt].cnum_concept_cki = m.synonym_concept_cki,
   reply->synonyms[cnt].type_code_value = cv.code_value, reply->synonyms[cnt].type_display = cv
   .display, reply->synonyms[cnt].type_meaning = cv.cdf_meaning
  FOOT REPORT
   stat = alterlist(reply->synonyms,cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
