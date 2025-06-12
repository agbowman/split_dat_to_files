CREATE PROGRAM bed_get_synonyms:dba
 FREE SET reply
 RECORD reply(
   1 synonyms[*]
     2 id = f8
     2 mnemonic = vc
     2 oe_format_id = f8
     2 catalog_code_value = f8
     2 catalog_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 mnemonic_type
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
 SET reply->status_data.status = "F"
 DECLARE search_string = vc
 IF ((request->search_type_string IN ("S", "C")))
  SET search_string = "*"
 ENDIF
 IF ((request->search_type_string="S"))
  SET search_string = concat('"',trim(request->search_string),'*"')
 ELSEIF ((request->search_type_string="C"))
  SET search_string = concat('"*',trim(request->search_string),'*"')
 ENDIF
 SET search_string = cnvtupper(search_string)
 DECLARE ocs_string = vc
 SET ocs_string = concat(ocs_string," ocs.active_ind = 1 ")
 IF ((request->activity_type_code_value > 0))
  SET ocs_string = concat(ocs_string," and ocs.activity_type_cd = request->activity_type_code_value "
   )
 ENDIF
 IF ((request->subactivity_type_code_value > 0))
  SET ocs_string = concat(ocs_string,
   " and ocs.activity_subtype_cd = request->subactivity_type_code_value ")
 ENDIF
 IF ((request->subactivity_type_code_value=- (1)))
  SET ocs_string = concat(ocs_string," and ocs.activity_subtype_cd in (0,NULL) ")
 ENDIF
 IF ((request->catalog_type_code_value > 0))
  SET ocs_string = concat(ocs_string," and ocs.catalog_type_cd = request->catalog_type_code_value ")
 ENDIF
 IF (search_string > " ")
  SET ocs_string = concat(ocs_string," and cnvtupper(ocs.mnemonic) = ",search_string)
 ENDIF
 SET cnt = 0
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   code_value c,
   code_value c2
  PLAN (ocs
   WHERE parser(ocs_string))
   JOIN (c
   WHERE c.code_value=ocs.mnemonic_type_cd)
   JOIN (c2
   WHERE c2.code_value=ocs.catalog_type_cd)
  ORDER BY ocs.mnemonic
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->synonyms,100)
  HEAD ocs.mnemonic
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (tcnt > 100)
    stat = alterlist(reply->synonyms,(cnt+ 100)), tcnt = 1
   ENDIF
   reply->synonyms[cnt].id = ocs.synonym_id, reply->synonyms[cnt].catalog_code_value = ocs.catalog_cd,
   reply->synonyms[cnt].mnemonic = ocs.mnemonic,
   reply->synonyms[cnt].oe_format_id = ocs.oe_format_id, reply->synonyms[cnt].catalog_type.code_value
    = c2.code_value, reply->synonyms[cnt].catalog_type.display = c2.display,
   reply->synonyms[cnt].catalog_type.mean = c2.cdf_meaning, reply->synonyms[cnt].mnemonic_type.
   code_value = c.code_value, reply->synonyms[cnt].mnemonic_type.display = c.display,
   reply->synonyms[cnt].mnemonic_type.mean = c.cdf_meaning
  FOOT REPORT
   stat = alterlist(reply->synonyms,cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
