CREATE PROGRAM codinginb_discover_keys:dba
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
 SELECT INTO "nl:"
  FROM code_value_alias c
  PLAN (c
   WHERE c.updt_dt_tm > cnvtdatetime(request->since))
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
   codecnt = (codecnt+ 1), reply->codes[codecnt].source_key = cnvtstring(c.contributor_source_cd),
   reply->codes[codecnt].code_key = cnvtstring(c.code_value),
   reply->codes[codecnt].changed = c.updt_dt_tm
  FOOT REPORT
   stat = alterlist(reply->codes,codecnt)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  c.contributor_source_cd, c.code_set, c.alias
  FROM code_value_alias c
  PLAN (c
   WHERE c.updt_dt_tm > cnvtdatetime(request->since))
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
   codesetcnt = (codesetcnt+ 1), reply->codesets[codesetcnt].source_key = cnvtstring(c
    .contributor_source_cd), reply->codesets[codesetcnt].codeset_key = cnvtstring(c.code_set),
   reply->codesets[codesetcnt].alias_key = c.alias, reply->codesets[codesetcnt].changed = c
   .updt_dt_tm
  FOOT REPORT
   stat = alterlist(reply->codesets,codesetcnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
