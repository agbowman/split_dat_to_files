CREATE PROGRAM bed_get_synonym_duplicate:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 synonyms[*]
      2 synonym_id = f8
      2 duplicate_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET tempreq
 RECORD tempreq(
   1 synonyms[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 mnemonic_type_code = f8
     2 catalog_code_value = f8
 ) WITH protect
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
 DECLARE req_size = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE primary_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 SET req_size = size(request->synonyms,5)
 IF (req_size=0)
  CALL bederror("Request is empty.")
 ENDIF
 SET stat = alterlist(tempreq->synonyms,req_size)
 SET stat = alterlist(reply->synonyms,req_size)
 FOR (i = 1 TO req_size)
   SET tempreq->synonyms[i].synonym_id = request->synonyms[i].synonym_id
   SET tempreq->synonyms[i].mnemonic = request->synonyms[i].mnemonic
   SET tempreq->synonyms[i].mnemonic_type_code = request->synonyms[i].mnemonic_type_code
   SET reply->synonyms[i].synonym_id = tempreq->synonyms[i].synonym_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = req_size),
   order_catalog_synonym o
  PLAN (d)
   JOIN (o
   WHERE (o.synonym_id=tempreq->synonyms[d.seq].synonym_id))
  DETAIL
   tempreq->synonyms[d.seq].catalog_code_value = o.catalog_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = req_size),
   order_catalog_synonym os1
  PLAN (d
   WHERE (tempreq->synonyms[d.seq].mnemonic_type_code != primary_code_value))
   JOIN (os1
   WHERE (os1.catalog_cd=tempreq->synonyms[d.seq].catalog_code_value)
    AND (os1.mnemonic_type_cd=tempreq->synonyms[d.seq].mnemonic_type_code)
    AND (os1.synonym_id != tempreq->synonyms[d.seq].synonym_id)
    AND os1.mnemonic_key_cap=cnvtupper(trim(tempreq->synonyms[d.seq].mnemonic)))
  ORDER BY d.seq
  DETAIL
   reply->synonyms[d.seq].duplicate_ind = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("NonPrimaryErr")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = req_size),
   order_catalog_synonym os
  PLAN (d
   WHERE (tempreq->synonyms[d.seq].mnemonic_type_code=primary_code_value))
   JOIN (os
   WHERE (os.mnemonic_type_cd=tempreq->synonyms[d.seq].mnemonic_type_code)
    AND (os.synonym_id != tempreq->synonyms[d.seq].synonym_id)
    AND os.mnemonic_key_cap=cnvtupper(trim(tempreq->synonyms[d.seq].mnemonic)))
  ORDER BY d.seq
  DETAIL
   reply->synonyms[d.seq].duplicate_ind = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("PrimaryErr1")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = req_size),
   order_catalog oc
  PLAN (d
   WHERE (tempreq->synonyms[d.seq].mnemonic_type_code=primary_code_value)
    AND (reply->synonyms[d.seq].duplicate_ind=0))
   JOIN (oc
   WHERE oc.primary_mnemonic=trim(tempreq->synonyms[d.seq].mnemonic))
  ORDER BY d.seq
  DETAIL
   IF ((oc.catalog_cd != tempreq->synonyms[d.seq].catalog_code_value))
    reply->synonyms[d.seq].duplicate_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("PrimaryErr2")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
