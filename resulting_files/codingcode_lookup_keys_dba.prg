CREATE PROGRAM codingcode_lookup_keys:dba
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
 DECLARE totalcodecnt = i4 WITH public, noconstant(0)
 DECLARE totalcodesetcnt = i4 WITH public, noconstant(0)
 DECLARE totalckicnt = i4 WITH public, noconstant(0)
 DECLARE totalconceptckicnt = i4 WITH public, noconstant(0)
 SET totalcodecnt = size(request->codes,5)
 SET totalcodesetcnt = size(request->codesets,5)
 SET totalckicnt = size(request->ckis,5)
 SET totalconceptckicnt = size(request->concept_ckis,5)
 IF (totalcodecnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = totalcodecnt),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE c.code_value=cnvtreal(request->codes[d.seq].key_id))
   DETAIL
    IF (codecnt=codecap)
     IF (codecap=0)
      codecap = 4
     ELSE
      codecap = (codecap * 2)
     ENDIF
     stat = alterlist(reply->codes,codecap)
    ENDIF
    codecnt = (codecnt+ 1), reply->codes[codecnt].key_id = request->codes[d.seq].key_id, reply->
    codes[codecnt].changed = c.updt_dt_tm
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->codes,codecnt)
 ENDIF
 IF (totalcodesetcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = totalcodesetcnt),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE c.code_set=cnvtreal(request->codesets[d.seq].key_id))
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
    codesetcnt = (codesetcnt+ 1), reply->codesets[codesetcnt].key_id = request->codesets[d.seq].
    key_id, reply->codesets[codesetcnt].changed = c.updt_dt_tm
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->codesets,codesetcnt)
 ENDIF
 IF (totalckicnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = totalckicnt),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE (c.cki=request->ckis[d.seq].key_id))
   DETAIL
    IF (ckicnt=ckicap)
     IF (ckicap=0)
      ckicap = 4
     ELSE
      ckicap = (ckicap * 2)
     ENDIF
     stat = alterlist(reply->ckis,ckicap)
    ENDIF
    ckicnt = (ckicnt+ 1), reply->ckis[ckicnt].key_id = request->ckis[d.seq].key_id, reply->ckis[
    ckicnt].changed = c.updt_dt_tm
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->ckis,ckicnt)
 ENDIF
 IF (totalconceptckicnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = totalconceptckicnt),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE (c.concept_cki=request->concept_ckis[d.seq].key_id))
   DETAIL
    IF (conceptckicnt=conceptckicap)
     IF (conceptckicap=0)
      conceptckicap = 4
     ELSE
      conceptckicap = (conceptckicap * 2)
     ENDIF
     stat = alterlist(reply->concept_ckis,conceptckicap)
    ENDIF
    conceptckicnt = (conceptckicnt+ 1), reply->concept_ckis[conceptckicnt].key_id = request->
    concept_ckis[d.seq].key_id, reply->concept_ckis[conceptckicnt].changed = c.updt_dt_tm
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->concept_ckis,conceptckicnt)
 ENDIF
 IF (codecnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
