CREATE PROGRAM codingext_lookup_keys:dba
 RECORD reply(
   1 codes[*]
     2 code_key = vc
     2 changed = dq8
   1 codesets[*]
     2 codeset_key = vc
     2 name_key = vc
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
    code_value_extension c
   PLAN (d)
    JOIN (c
    WHERE c.code_value=cnvtreal(request->codes[d.seq].code_key))
   DETAIL
    IF (codecnt=codecap)
     IF (codecap=0)
      codecap = 4
     ELSE
      codecap = (codecap * 2)
     ENDIF
     stat = alterlist(reply->codes,codecap)
    ENDIF
    codecnt = (codecnt+ 1), reply->codes[codecnt].code_key = request->codes[d.seq].code_key, reply->
    codes[codecnt].changed = c.updt_dt_tm
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->codes,codecnt)
 ENDIF
 IF (totalcodesetcnt > 0)
  FOR (ctr = 1 TO totalcodesetcnt)
    SELECT INTO "nl:"
     FROM code_value_extension c
     PLAN (c
      WHERE c.code_set=cnvtreal(request->codesets[ctr].codeset_key)
       AND (c.field_name=request->codesets[ctr].name_key))
     ORDER BY c.updt_dt_tm DESC
     HEAD c.code_set
      IF (codesetcnt=codesetcap)
       IF (codesetcap=0)
        codesetcap = 4
       ELSE
        codesetcap = (codesetcap * 2)
       ENDIF
       stat = alterlist(reply->codesets,codesetcap)
      ENDIF
      codesetcnt = (codesetcnt+ 1), reply->codesets[codesetcnt].codeset_key = request->codesets[ctr].
      codeset_key, reply->codesets[codesetcnt].name_key = request->codesets[ctr].name_key,
      reply->codesets[codesetcnt].changed = c.updt_dt_tm
     WITH nocounter
    ;end select
  ENDFOR
  SET stat = alterlist(reply->codesets,codesetcnt)
 ENDIF
 IF (codecnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
