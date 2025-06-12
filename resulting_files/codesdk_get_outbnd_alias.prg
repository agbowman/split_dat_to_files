CREATE PROGRAM codesdk_get_outbnd_alias
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
 SELECT INTO "nl:"
  FROM code_value_outbound c
  WHERE (c.code_value=request->code_value)
   AND (c.contributor_source_cd=request->contributor_source_cd)
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
END GO
