CREATE PROGRAM aps_get_case_icd9_codes:dba
 RECORD reply(
   1 nomen_entity_qual[*]
     2 nomen_entity_reltn_id = f8
     2 diagnosis_code = c50
     2 nomenclature_id = f8
     2 diagnosis_desc = vc
     2 diag_priority = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET accn_icd9_cd = uar_get_code_by("MEANING",23549,"ACCNICD9")
 SET code_value = 0.0
 SET nomen_entity_cnt = 0
 SET cdf_meaning = fillstring(10," ")
 SELECT INTO "nl:"
  ner.nomenclature_id
  FROM nomen_entity_reltn ner,
   nomenclature n
  PLAN (ner
   WHERE ner.parent_entity_name="ACCESSION"
    AND (ner.parent_entity_id=request->case_id)
    AND ner.active_ind=1
    AND ner.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ner.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND ner.reltn_type_cd=accn_icd9_cd)
   JOIN (n
   WHERE n.nomenclature_id=ner.nomenclature_id)
  ORDER BY ner.priority
  HEAD REPORT
   nomen_entity_cnt = 0
  DETAIL
   nomen_entity_cnt += 1, stat = alterlist(reply->nomen_entity_qual,nomen_entity_cnt), reply->
   nomen_entity_qual[nomen_entity_cnt].nomen_entity_reltn_id = ner.nomen_entity_reltn_id,
   reply->nomen_entity_qual[nomen_entity_cnt].nomenclature_id = n.nomenclature_id, reply->
   nomen_entity_qual[nomen_entity_cnt].diagnosis_code = n.source_identifier, reply->
   nomen_entity_qual[nomen_entity_cnt].diagnosis_desc = n.source_string,
   reply->nomen_entity_qual[nomen_entity_cnt].diag_priority = ner.priority
  FOOT REPORT
   stat = alterlist(reply->nomen_entity_qual,nomen_entity_cnt)
  WITH nocounter
 ;end select
 IF (nomen_entity_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
