CREATE PROGRAM cps_get_nomen_code:dba
 RECORD reply(
   1 qual[*]
     2 source_identifier = vc
     2 active_ind = i2
     2 source_string = vc
     2 string_identifier = c18
     2 concept_identifier = c18
     2 concept_source_cd = f8
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c40
     2 string_source_cd = f8
     2 string_source_disp = c40
     2 principle_type_cd = f8
     2 principle_type_disp = c40
     2 nomenclature_id = f8
     2 vocab_axis_cd = f8
     2 vocab_axis_disp = c40
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET list_cnt = size(request->qual,5)
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n,
   (dummyt d  WITH seq = value(list_cnt))
  PLAN (d)
   JOIN (n
   WHERE (n.source_identifier=request->qual[d.seq].code_string)
    AND (n.source_vocabulary_cd=request->qual[d.seq].source_vocabulary_cd)
    AND ((n.vocab_axis_cd+ 0)=request->qual[d.seq].vocab_axis_cd)
    AND n.active_ind=1
    AND n.beg_effective_dt_tm <= cnvtdatetime(request->qual[d.seq].compare_dt_tm)
    AND n.end_effective_dt_tm >= cnvtdatetime(request->qual[d.seq].compare_dt_tm))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].source_string = n.source_string, reply->qual[count1].string_identifier = n
   .string_identifier, reply->qual[count1].source_identifier = n.source_identifier,
   reply->qual[count1].concept_identifier = n.concept_identifier, reply->qual[count1].
   concept_source_cd = n.concept_source_cd, reply->qual[count1].source_vocabulary_cd = n
   .source_vocabulary_cd,
   reply->qual[count1].string_source_cd = n.string_source_cd, reply->qual[count1].principle_type_cd
    = n.principle_type_cd, reply->qual[count1].nomenclature_id = n.nomenclature_id,
   reply->qual[count1].vocab_axis_cd = n.vocab_axis_cd, reply->qual[count1].contributor_system_cd = n
   .contributor_system_cd, reply->qual[count1].active_ind = n.active_ind
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 CALL echo(concat("Count: ",cnvtstring(count1)))
 SET idx = 0
 FOR (idx = 1 TO count1)
  CALL echo(concat("Qual: ",cnvtstring(idx)))
  CALL echo(reply->qual[idx].source_identifier)
 ENDFOR
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  IF (count1=list_cnt)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "P"
  ENDIF
 ENDIF
END GO
