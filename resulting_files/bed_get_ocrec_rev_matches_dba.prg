CREATE PROGRAM bed_get_ocrec_rev_matches:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 legacy
       3 id = f8
       3 short_desc = vc
       3 long_desc = vc
       3 alias = vc
     2 millennium
       3 code_value = f8
       3 mnemonic = vc
       3 concept_cki = vc
     2 bedrock
       3 code_value = f8
       3 mnemonic = vc
       3 description = vc
       3 concept_cki = vc
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
 SET mcnt = 0
 SET new_phase_x_match_ind = 0
 SELECT INTO "nl:"
  FROM br_name_value br,
   dummyt d
  PLAN (br
   WHERE br.br_nv_key1="NEW_PHASE_X_MATCH")
   JOIN (d
   WHERE (cnvtint(br.br_name)=request->catalog_type_code_value)
    AND (cnvtint(br.br_value)=request->activity_type_code_value))
  DETAIL
   new_phase_x_match_ind = 1
  WITH nocounter
 ;end select
 DECLARE br_string = vc
 SET br_string = "b.catalog_type = request->catalog_type"
 IF ((request->activity_type > " "))
  SET br_string = concat(br_string," and b.activity_type = request->activity_type")
 ENDIF
 IF ((request->facility > " "))
  SET br_string = concat(br_string," and b.facility = request->facility")
 ENDIF
 DECLARE b_string = vc
 SET b_string = "b.catalog_type_cd = request->catalog_type_code_value"
 IF ((request->activity_type_code_value > 0))
  SET b_string = concat(b_string," and b.activity_type_cd = request->activity_type_code_value")
 ENDIF
 RECORD temp(
   1 qual[*]
     2 cd = f8
     2 legacy
       3 id = f8
       3 short_desc = vc
       3 long_desc = vc
       3 alias = vc
     2 millennium
       3 code_value = f8
       3 mnemonic = vc
       3 concept_cki = vc
     2 bedrock
       3 code_value = f8
       3 mnemonic = vc
       3 description = vc
       3 concept_cki = vc
 )
 SELECT INTO "nl:"
  FROM br_oc_work b
  PLAN (b
   WHERE parser(br_string)
    AND b.match_orderable_cd > 0)
  ORDER BY b.short_desc
  HEAD b.oc_id
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].legacy.id = b.oc_id,
   temp->qual[cnt].legacy.short_desc = b.short_desc, temp->qual[cnt].legacy.long_desc = b.long_desc
   IF (b.alias1 > " ")
    temp->qual[cnt].legacy.alias = b.alias1
   ELSE
    temp->qual[cnt].legacy.alias = b.alias2
   ENDIF
   temp->qual[cnt].cd = b.match_orderable_cd
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_auto_order_catalog b
  PLAN (d)
   JOIN (b
   WHERE (b.catalog_cd=temp->qual[d.seq].cd)
    AND parser(b_string))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].bedrock.code_value = b.catalog_cd, temp->qual[d.seq].bedrock.mnemonic = b
   .primary_mnemonic, temp->qual[d.seq].bedrock.description = b.description,
   temp->qual[d.seq].bedrock.concept_cki = b.concept_cki
  WITH nocounter, skipbedrock = 1
 ;end select
 IF (new_phase_x_match_ind=0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    order_catalog o
   PLAN (d
    WHERE (temp->qual[d.seq].bedrock.concept_cki > " "))
    JOIN (o
    WHERE (o.concept_cki=temp->qual[d.seq].bedrock.concept_cki))
   ORDER BY d.seq
   HEAD d.seq
    temp->qual[d.seq].millennium.code_value = o.catalog_cd, temp->qual[d.seq].millennium.mnemonic = o
    .primary_mnemonic, temp->qual[d.seq].millennium.concept_cki = o.concept_cki
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    order_catalog o
   PLAN (d)
    JOIN (o
    WHERE (o.catalog_cd=temp->qual[d.seq].cd)
     AND (temp->qual[d.seq].millennium.code_value=0))
   ORDER BY d.seq
   HEAD d.seq
    temp->qual[d.seq].millennium.code_value = o.catalog_cd, temp->qual[d.seq].millennium.mnemonic = o
    .primary_mnemonic, temp->qual[d.seq].millennium.concept_cki = o.concept_cki
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_name_value b,
    order_catalog o,
    dummyt d1,
    dummyt d2
   PLAN (d)
    JOIN (b
    WHERE b.br_nv_key1="PHASE_X_MATCH")
    JOIN (d2
    WHERE (cnvtint(trim(b.br_name))=temp->qual[d.seq].legacy.id))
    JOIN (o)
    JOIN (d1
    WHERE o.catalog_cd=cnvtint(b.br_value))
   ORDER BY d.seq
   HEAD d.seq
    temp->qual[d.seq].millennium.code_value = o.catalog_cd, temp->qual[d.seq].millennium.mnemonic = o
    .primary_mnemonic, temp->qual[d.seq].millennium.concept_cki = o.concept_cki
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO cnt)
   IF ((temp->qual[x].millennium.code_value > 0))
    SET mcnt = (mcnt+ 1)
    SET stat = alterlist(reply->orderables,mcnt)
    SET reply->orderables[mcnt].legacy.id = temp->qual[x].legacy.id
    SET reply->orderables[mcnt].legacy.short_desc = temp->qual[x].legacy.short_desc
    SET reply->orderables[mcnt].legacy.long_desc = temp->qual[x].legacy.long_desc
    SET reply->orderables[mcnt].legacy.alias = temp->qual[x].legacy.alias
    SET reply->orderables[mcnt].bedrock.code_value = temp->qual[x].bedrock.code_value
    SET reply->orderables[mcnt].bedrock.mnemonic = temp->qual[x].bedrock.mnemonic
    SET reply->orderables[mcnt].bedrock.description = temp->qual[x].bedrock.description
    SET reply->orderables[mcnt].bedrock.concept_cki = temp->qual[x].bedrock.concept_cki
    SET reply->orderables[mcnt].millennium.code_value = temp->qual[x].millennium.code_value
    SET reply->orderables[mcnt].millennium.mnemonic = temp->qual[x].millennium.mnemonic
    SET reply->orderables[mcnt].millennium.concept_cki = temp->qual[x].millennium.concept_cki
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (mcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
