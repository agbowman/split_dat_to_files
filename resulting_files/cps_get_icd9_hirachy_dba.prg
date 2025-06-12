CREATE PROGRAM cps_get_icd9_hirachy:dba
 RECORD reply(
   1 item_cnt = i2
   1 items[*]
     2 active_ind = i2
     2 source_string = vc
     2 string_identifier = c18
     2 source_identifier = vc
     2 concept_identifier = c18
     2 concept_source_cd = f8
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c40
     2 string_source_cd = f8
     2 string_source_cd = c40
     2 principle_type_cd = f8
     2 principle_type_disp = c40
     2 nomenclature_id = f8
     2 vocab_axis_cd = f8
     2 vocab_axis_disp = c40
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
   1 errormsg = c255
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET uplimit = concat(trim(request->codestring),".9999")
 SET stat = alterlist(reply->items,10)
 SET source_vocab_cd = 0.0
 SET code_value = 0.0
 SET code_set = 400
 SET cdf_meaning = "ICD9"
 EXECUTE cpm_get_cd_for_cdf
 SET source_vocab_cd = code_value
 IF (code_value < 1)
  SET reply->err_msg = "Failed to find cdf_meaning ICD9"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  n.nomenclature_id, n.concept_source_cd, n.source_string,
  n.source_identifier, n.string_identifier, n.principle_type_cd,
  n.source_vocabulary_cd, n.string_source_cd, n.concept_identifier
  FROM nomenclature n
  WHERE (n.source_identifier >= request->codestring)
   AND n.source_identifier < uplimit
   AND n.source_vocabulary_cd=source_vocab_cd
  ORDER BY n.source_identifier
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->items,(count1+ 9))
   ENDIF
   reply->items[count1].source_string = n.source_string, reply->items[count1].string_identifier = n
   .string_identifier, reply->items[count1].source_identifier = n.source_identifier,
   reply->items[count1].concept_identifier = n.concept_identifier, reply->items[count1].
   concept_source_cd = n.concept_source_cd, reply->items[count1].source_vocabulary_cd = n
   .source_vocabulary_cd,
   reply->items[count1].string_source_cd = n.string_source_cd, reply->items[count1].principle_type_cd
    = n.principle_type_cd, reply->items[count1].nomenclature_id = n.nomenclature_id,
   reply->items[count1].vocab_axis_cd = n.vocab_axis_cd, reply->items[count1].contributor_system_cd
    = n.contributor_system_cd, reply->items[count1].active_ind = n.active_ind
  WITH nocounter
 ;end select
 SET reply->item_cnt = count1
 SET stat = alterlist(reply->items,count1)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
