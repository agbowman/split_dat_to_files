CREATE PROGRAM bed_get_datamart_ords_by_syn:dba
 FREE SET reply
 RECORD reply(
   1 synonyms[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 mnemonic_type
       3 code_value = f8
       3 meaning = vc
       3 display = vc
     2 oe_format_id = f8
     2 orderable
       3 code_value = f8
       3 description = vc
       3 primary_mnemonic = vc
       3 o_active_ind = i2
     2 s_active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->synonyms,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->synonyms,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->synonyms[x].synonym_id = request->synonyms[x].synonym_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   order_catalog_synonym ocs,
   order_catalog oc,
   code_value cv
  PLAN (d)
   JOIN (ocs
   WHERE (ocs.synonym_id=request->synonyms[d.seq].synonym_id))
   JOIN (cv
   WHERE cv.code_value=ocs.mnemonic_type_cd
    AND cv.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd)
  ORDER BY d.seq
  HEAD d.seq
   reply->synonyms[d.seq].mnemonic = ocs.mnemonic, reply->synonyms[d.seq].oe_format_id = ocs
   .oe_format_id, reply->synonyms[d.seq].mnemonic_type.code_value = cv.code_value,
   reply->synonyms[d.seq].mnemonic_type.display = cv.display, reply->synonyms[d.seq].mnemonic_type.
   meaning = cv.cdf_meaning, reply->synonyms[d.seq].orderable.code_value = oc.catalog_cd,
   reply->synonyms[d.seq].orderable.description = oc.description, reply->synonyms[d.seq].orderable.
   primary_mnemonic = oc.primary_mnemonic, reply->synonyms[d.seq].orderable.o_active_ind = oc
   .active_ind,
   reply->synonyms[d.seq].s_active_ind = ocs.active_ind
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
