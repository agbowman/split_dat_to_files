CREATE PROGRAM codesdk_get_inbnd_alias:dba
 RECORD reply(
   1 aliases[*]
     2 alias = vc
     2 alias_type_meaning = vc
     2 code_set = i4
     2 code_value = f8
     2 contributor_source_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE cap = i4 WITH public, noconstant(0)
 IF ((request->by_codeset.code_set > 0))
  SELECT INTO "nl:"
   FROM code_value_alias c
   WHERE (c.alias=request->by_codeset.alias)
    AND (c.code_set=request->by_codeset.code_set)
    AND (c.contributor_source_cd=request->by_codeset.contributor_source_cd)
   DETAIL
    IF (cnt=cap)
     IF (cap=0)
      cap = 4
     ELSE
      cap = (cap * 2)
     ENDIF
     stat = alterlist(reply->aliases,cap)
    ENDIF
    cnt = (cnt+ 1), reply->aliases[cnt].alias = c.alias, reply->aliases[cnt].alias_type_meaning = c
    .alias_type_meaning,
    reply->aliases[cnt].code_set = c.code_set, reply->aliases[cnt].code_value = c.code_value, reply->
    aliases[cnt].contributor_source_cd = c.contributor_source_cd
   FOOT REPORT
    stat = alterlist(reply->aliases,cnt)
   WITH nocounter
  ;end select
  IF (cnt=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSEIF ((request->by_code.code_value > 0.0))
  SELECT INTO "nl:"
   FROM code_value_alias c
   WHERE (c.code_value=request->by_code.code_value)
    AND (c.contributor_source_cd=request->by_code.contributor_source_cd)
   DETAIL
    IF (cnt=cap)
     IF (cap=0)
      cap = 4
     ELSE
      cap = (cap * 2)
     ENDIF
     stat = alterlist(reply->aliases,cap)
    ENDIF
    cnt = (cnt+ 1), reply->aliases[cnt].alias = c.alias, reply->aliases[cnt].alias_type_meaning = c
    .alias_type_meaning,
    reply->aliases[cnt].code_set = c.code_set, reply->aliases[cnt].code_value = c.code_value, reply->
    aliases[cnt].contributor_source_cd = c.contributor_source_cd
   FOOT REPORT
    stat = alterlist(reply->aliases,cnt)
   WITH nocounter
  ;end select
  IF (cnt=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
