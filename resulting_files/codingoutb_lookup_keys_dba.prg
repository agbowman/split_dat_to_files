CREATE PROGRAM codingoutb_lookup_keys:dba
 RECORD reply(
   1 codes[*]
     2 source_key = vc
     2 code_key = vc
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
 DECLARE totalcodecnt = i4 WITH public, noconstant(0)
 SET totalcodecnt = size(request->codes,5)
 IF (totalcodecnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = totalcodecnt),
    code_value_outbound c
   PLAN (d)
    JOIN (c
    WHERE c.code_value=cnvtreal(request->codes[d.seq].code_key)
     AND c.contributor_source_cd=cnvtreal(request->codes[d.seq].source_key))
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
    codes[codecnt].source_key = request->codes[d.seq].source_key,
    reply->codes[codecnt].changed = c.updt_dt_tm
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->codes,codecnt)
 ENDIF
 IF (codecnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
