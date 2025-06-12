CREATE PROGRAM cps_get_nomen_by_cki:dba
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 vocab_cd = f8
     2 vocab_mean = c12
     2 source_ident = vc
     2 nomenclature_id = f8
     2 source_string = vc
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE active_ind = i2
 DECLARE ddate = dq8
 DECLARE req_get_detail = i2
 IF (validate(request->all_ind,1)=1)
  SET active_ind = - (1)
  SET ddate = cnvtdatetime("01-JAN-1800 00:00:00")
 ELSE
  SET active_ind = 0
  SET ddate = cnvtdatetime(curdate,curtime3)
 ENDIF
 IF (validate(request->get_detail,0)=1)
  SET req_get_detail = 1
 ELSE
  SET req_get_detail = 0
 ENDIF
 SET reply->status_data.status = "F"
 SET dvar = 0
 SET knt = 0
 SELECT DISTINCT INTO "nl:"
  n.nomenclature_id, n.source_vocabulary_cd, n.source_identifier,
  n.end_effective_dt_tm, n.active_ind
  FROM nomenclature n,
   code_value c,
   (dummyt d  WITH seq = value(request->item_knt))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (n
   WHERE (n.source_identifier=request->item[d.seq].source_ident)
    AND n.active_ind > active_ind
    AND n.end_effective_dt_tm >= cnvtdatetime(ddate))
   JOIN (c
   WHERE c.code_value=n.source_vocabulary_cd
    AND c.cdf_meaning=cnvtupper(substring(1,12,request->item[d.seq].vocab_mean)))
  ORDER BY n.source_vocabulary_cd, n.source_identifier, cnvtdatetime(n.end_effective_dt_tm) DESC,
   n.active_ind DESC, n.nomenclature_id
  HEAD REPORT
   knt = 0
  HEAD n.source_vocabulary_cd
   dvar
  HEAD n.source_identifier
   IF (req_get_detail=0)
    knt = (knt+ 1)
    IF (mod(knt,10)=1)
     stat = alterlist(reply->qual,(knt+ 9))
    ENDIF
    reply->qual[knt].vocab_cd = n.source_vocabulary_cd, reply->qual[knt].vocab_mean = request->item[d
    .seq].vocab_mean, reply->qual[knt].source_ident = n.source_identifier,
    reply->qual[knt].nomenclature_id = n.nomenclature_id, reply->qual[knt].source_string = n
    .source_string, reply->qual[knt].concept_cki = n.concept_cki
   ENDIF
  DETAIL
   IF (req_get_detail=1)
    knt = (knt+ 1)
    IF (mod(knt,10)=1)
     stat = alterlist(reply->qual,(knt+ 9))
    ENDIF
    reply->qual[knt].vocab_cd = n.source_vocabulary_cd, reply->qual[knt].vocab_mean = request->item[d
    .seq].vocab_mean, reply->qual[knt].source_ident = n.source_identifier,
    reply->qual[knt].nomenclature_id = n.nomenclature_id, reply->qual[knt].source_string = n
    .source_string, reply->qual[knt].concept_cki = n.concept_cki
   ENDIF
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SET script_version = "002 08/21/13 KK021475"
END GO
