CREATE PROGRAM dcp_get_nomenid_by_srciden:dba
 RECORD reply(
   1 cnt = i4
   1 qual[*]
     2 nomenclature_id = f8
     2 source_identifier = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 SET drug_cd = 0
 SET allg_cd = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 400
 SET cdf_meaning = "MUL.DRUG"
 EXECUTE cpm_get_cd_for_cdf
 SET drug_cd = code_value
 SET cdf_meaning = "MUL.ALGCAT"
 EXECUTE cpm_get_cd_for_cdf
 SET allg_cd = code_value
 SET nbr_to_get = cnvtint(size(request->qual,5))
 FOR (x = 1 TO nbr_to_get)
  SET dstring = substring(1,1,request->qual[x].source_identifier)
  IF (cnvtupper(dstring)="D")
   SELECT INTO "nl:"
    FROM nomenclature n,
     (dummyt d  WITH seq = value(nbr_to_get))
    PLAN (d)
     JOIN (n
     WHERE trim(request->qual[d.seq].source_identifier)=n.source_identifier
      AND drug_cd=n.source_vocabulary_cd)
    DETAIL
     cnt = (cnt+ 1)
     IF (cnt > size(reply->qual,5))
      stat = alterlist(reply->qual,(cnt+ 10))
     ENDIF
     reply->qual[cnt].nomenclature_id = n.nomenclature_id, reply->qual[cnt].source_identifier = n
     .source_identifier
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM nomenclature n,
     (dummyt d  WITH seq = value(nbr_to_get))
    PLAN (d)
     JOIN (n
     WHERE trim(request->qual[d.seq].source_identifier)=n.source_identifier
      AND allg_cd=n.source_vocabulary_cd)
    DETAIL
     cnt = (cnt+ 1)
     IF (cnt > size(reply->qual,5))
      stat = alterlist(reply->qual,(cnt+ 10))
     ENDIF
     reply->qual[cnt].nomenclature_id = n.nomenclature_id, reply->qual[cnt].source_identifier = n
     .source_identifier
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->qual,cnt)
END GO
