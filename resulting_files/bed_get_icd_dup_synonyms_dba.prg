CREATE PROGRAM bed_get_icd_dup_synonyms:dba
 FREE SET reply
 RECORD reply(
   1 items[*]
     2 nomenclature_id = f8
     2 source_vocab_code_value = f8
     2 code = vc
     2 term = vc
     2 principle_type_code_value = f8
     2 duplicate_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_cnt = 0
 SET req_cnt = size(request->items,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->items,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->items[x].code = request->items[x].code
   SET reply->items[x].term = request->items[x].term
   SET reply->items[x].nomenclature_id = request->items[x].nomenclature_id
   SET reply->items[x].principle_type_code_value = request->items[x].principle_type_code_value
   SET reply->items[x].source_vocab_code_value = request->items[x].source_vocab_code_value
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   nomenclature n
  PLAN (d)
   JOIN (n
   WHERE (n.source_vocabulary_cd=reply->items[d.seq].source_vocab_code_value)
    AND cnvtupper(n.source_identifier)=cnvtupper(reply->items[d.seq].code)
    AND cnvtupper(n.source_string)=cnvtupper(reply->items[d.seq].term)
    AND (n.principle_type_cd=reply->items[d.seq].principle_type_code_value))
  ORDER BY d.seq
  DETAIL
   IF ((n.nomenclature_id != reply->items[d.seq].nomenclature_id))
    reply->items[d.seq].duplicate_ind = 1
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
