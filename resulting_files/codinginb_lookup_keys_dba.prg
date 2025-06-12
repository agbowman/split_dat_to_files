CREATE PROGRAM codinginb_lookup_keys:dba
 RECORD reply(
   1 codes[*]
     2 source_key = vc
     2 code_key = vc
     2 changed = dq8
   1 codesets[*]
     2 source_key = vc
     2 codeset_key = vc
     2 alias_key = vc
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
 DECLARE totalcodecnt = i4 WITH public, noconstant(0)
 DECLARE totalcodesetcnt = i4 WITH public, noconstant(0)
 SET totalcodecnt = size(request->codes,5)
 SET totalcodesetcnt = size(request->codesets,5)
 IF (totalcodecnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = totalcodecnt),
    code_value_alias c
   PLAN (d)
    JOIN (c
    WHERE c.code_value=cnvtreal(request->codes[d.seq].code_key)
     AND c.contributor_source_cd=cnvtreal(request->codes[d.seq].source_key))
   ORDER BY c.code_value, c.updt_dt_tm DESC
   HEAD c.code_value
    IF (codecnt=codecap)
     IF (codecap=0)
      codecap = 4
     ELSE
      codecap = (codecap * 2)
     ENDIF
     stat = alterlist(reply->codes,codecap)
    ENDIF
    codecnt = (codecnt+ 1), reply->codes[codecnt].code_key = request->codes[d.seq].code_key, reply->
    codes[codecnt].source_key = request->codes[d.seq].source_key,
    reply->codes[codecnt].changed = c.updt_dt_tm
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->codes,codecnt)
 ENDIF
 IF (totalcodesetcnt > 0)
  SELECT DISTINCT INTO "nl:"
   c.contributor_source_cd, c.code_set, c.alias
   FROM (dummyt d  WITH seq = totalcodesetcnt),
    code_value_alias c
   PLAN (d)
    JOIN (c
    WHERE c.code_set=cnvtreal(request->codesets[d.seq].codeset_key)
     AND c.contributor_source_cd=cnvtreal(request->codesets[d.seq].source_key)
     AND (c.alias=request->codesets[d.seq].alias_key))
   ORDER BY c.contributor_source_cd, c.code_set, c.alias,
    c.updt_dt_tm DESC
   DETAIL
    IF (codesetcnt=codesetcap)
     IF (codesetcap=0)
      codesetcap = 4
     ELSE
      codesetcap = (codesetcap * 2)
     ENDIF
     stat = alterlist(reply->codesets,codesetcap)
    ENDIF
    codesetcnt = (codesetcnt+ 1), reply->codesets[codesetcnt].codeset_key = request->codesets[d.seq].
    codeset_key, reply->codesets[codesetcnt].alias_key = request->codesets[d.seq].alias_key,
    reply->codesets[codesetcnt].source_key = request->codesets[d.seq].source_key, reply->codesets[
    codesetcnt].changed = c.updt_dt_tm
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->codesets,codesetcnt)
 ENDIF
 IF (codecnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
