CREATE PROGRAM bed_get_ocrec_unmatch_mil:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 mnemonic = vc
     2 concept_cki = vc
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
 SET rcnt = 0
 DECLARE b_string = vc
 SET b_string = "b.match_orderable_cd = temp->qual[d.seq].cd"
 IF ((request->facility > " "))
  SET b_string = concat(b_string," and b.facility = request->facility")
 ENDIF
 DECLARE br_string = vc
 SET br_string = "b.match_orderable_cd = bedrock_cd"
 IF ((request->facility > " "))
  SET br_string = concat(br_string," and b.facility = request->facility")
 ENDIF
 RECORD temp(
   1 qual[*]
     2 cd = f8
     2 mnemonic = vc
     2 concept_cki = vc
     2 match_ind = i2
 )
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE (oc.catalog_type_cd=request->catalog_type_code_value)
    AND (oc.activity_type_cd=request->activity_type_code_value)
    AND  NOT (oc.orderable_type_flag IN (2, 6))
    AND oc.active_ind=1)
  ORDER BY oc.primary_mnemonic
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].cd = oc.catalog_cd,
   temp->qual[cnt].mnemonic = oc.primary_mnemonic, temp->qual[cnt].concept_cki = oc.concept_cki
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_oc_work b
  PLAN (d)
   JOIN (b
   WHERE parser(b_string))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].match_ind = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
  SET bedrock_cd = 0.0
  IF ((temp->qual[x].match_ind=0))
   IF ((temp->qual[x].concept_cki > " "))
    SELECT INTO "nl:"
     FROM br_auto_order_catalog b
     PLAN (b
      WHERE (b.concept_cki=temp->qual[x].concept_cki))
     DETAIL
      bedrock_cd = b.catalog_cd
     WITH nocounter, skipbedrock = 1
    ;end select
   ENDIF
   IF (bedrock_cd > 0)
    SELECT INTO "nl:"
     FROM br_oc_work b
     PLAN (b
      WHERE parser(br_string))
     DETAIL
      temp->qual[x].match_ind = 1
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDFOR
 FOR (x = 1 TO cnt)
   IF ((temp->qual[x].match_ind=0))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->orderables,rcnt)
    SET reply->orderables[rcnt].code_value = temp->qual[x].cd
    SET reply->orderables[rcnt].mnemonic = temp->qual[x].mnemonic
    SET reply->orderables[rcnt].concept_cki = temp->qual[x].concept_cki
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (rcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
