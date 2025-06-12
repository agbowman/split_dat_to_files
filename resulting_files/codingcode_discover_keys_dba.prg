CREATE PROGRAM codingcode_discover_keys:dba
 RECORD reply(
   1 codes[*]
     2 key_id = vc
     2 changed = dq8
   1 codesets[*]
     2 key_id = vc
     2 changed = dq8
   1 ckis[*]
     2 key_id = vc
     2 changed = dq8
   1 concept_ckis[*]
     2 key_id = vc
     2 changed = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE codecnt = i4 WITH public, noconstant(0)
 DECLARE codecap = i4 WITH public, noconstant(0)
 DECLARE codesetcnt = i4 WITH public, noconstant(0)
 DECLARE codesetcap = i4 WITH public, noconstant(0)
 DECLARE ckicnt = i4 WITH public, noconstant(0)
 DECLARE ckicap = i4 WITH public, noconstant(0)
 DECLARE conceptckicnt = i4 WITH public, noconstant(0)
 DECLARE conceptckicap = i4 WITH public, noconstant(0)
 DECLARE cki = vc WITH public
 DECLARE conceptcki = vc WITH public
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.updt_dt_tm > cnvtdatetime(request->since))
  ORDER BY c.code_set, c.updt_dt_tm DESC
  HEAD c.code_set
   IF (codesetcnt=codesetcap)
    IF (codesetcap=0)
     codesetcap = 4
    ELSE
     codesetcap = (codesetcap * 2)
    ENDIF
    stat = alterlist(reply->codesets,codesetcap)
   ENDIF
   codesetcnt = (codesetcnt+ 1), reply->codesets[codesetcnt].key_id = cnvtstring(c.code_set), reply->
   codesets[codesetcnt].changed = c.updt_dt_tm
  DETAIL
   IF (codecnt >= codecap)
    IF (codecap=0)
     codecap = 4
    ELSE
     codecap = (codecap * 2)
    ENDIF
    stat = alterlist(reply->codes,codecap)
   ENDIF
   codecnt = (codecnt+ 1), reply->codes[codecnt].key_id = cnvtstring(c.code_value), reply->codes[
   codecnt].changed = c.updt_dt_tm,
   cki = trim(c.cki)
   IF (cki != "")
    IF (ckicnt >= ckicap)
     IF (ckicap=0)
      ckicap = 4
     ELSE
      ckicap = (ckicap * 2)
     ENDIF
     stat = alterlist(reply->ckis,ckicap)
    ENDIF
    ckicnt = (ckicnt+ 1), reply->ckis[ckicnt].key_id = c.cki, reply->ckis[ckicnt].changed = c
    .updt_dt_tm
   ENDIF
   conceptcki = trim(c.concept_cki)
   IF (conceptcki != "")
    IF (conceptckicnt >= conceptckicap)
     IF (conceptckicap=0)
      conceptckicap = 4
     ELSE
      conceptckicap = (conceptckicap * 2)
     ENDIF
     stat = alterlist(reply->concept_ckis,conceptckicap)
    ENDIF
    conceptckicnt = (conceptckicnt+ 1), reply->concept_ckis[conceptckicnt].key_id = c.concept_cki,
    reply->concept_ckis[conceptckicnt].changed = c.updt_dt_tm
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->codes,codecnt), stat = alterlist(reply->codesets,codesetcnt), stat =
   alterlist(reply->ckis,ckicnt),
   stat = alterlist(reply->concept_ckis,conceptckicnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
