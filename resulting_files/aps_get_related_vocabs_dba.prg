CREATE PROGRAM aps_get_related_vocabs:dba
 RECORD reply(
   1 qual[10]
     2 source_vocabulary_cd = f8
     2 cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 IF ((request->prefix_id > 0))
  SELECT INTO "nl:"
   ap.prefix_id, asvr.source_vocabulary_cd, cv.code_value,
   cv1.code_value
   FROM ap_prefix ap,
    ap_source_vocabulary_r asvr,
    code_value cv,
    code_value cv1,
    (dummyt d1  WITH seq = 1)
   PLAN (ap
    WHERE (ap.prefix_id=request->prefix_id))
    JOIN (cv
    WHERE ap.diag_coding_vocabulary_cd=cv.code_value
     AND cv.active_ind=1)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (asvr
    WHERE ap.diag_coding_vocabulary_cd=asvr.source_vocabulary_cd)
    JOIN (cv1
    WHERE asvr.include_source_vocabulary_cd=cv1.code_value
     AND cv1.active_ind=1)
   HEAD REPORT
    reply->qual[1].source_vocabulary_cd = ap.diag_coding_vocabulary_cd, reply->qual[1].cdf_meaning =
    cv.cdf_meaning, cnt = 1
   DETAIL
    IF (asvr.include_source_vocabulary_cd > 0)
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1
      AND cnt != 1)
      stat = alter(reply->qual,(cnt+ 9))
     ENDIF
     reply->qual[cnt].source_vocabulary_cd = asvr.include_source_vocabulary_cd, reply->qual[cnt].
     cdf_meaning = cv1.cdf_meaning
    ENDIF
   FOOT REPORT
    stat = alter(reply->qual,cnt)
   WITH nocounter, outerjoin = d1
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET x = 0
  SELECT INTO "nl:"
   asvr.include_source_vocabulary_cd, cv.code_value
   FROM ap_source_vocabulary_r asvr,
    code_value cv
   PLAN (asvr
    WHERE (request->source_vocab_cd=asvr.source_vocabulary_cd))
    JOIN (cv
    WHERE asvr.include_source_vocabulary_cd=cv.code_value
     AND cv.active_ind=1)
   HEAD REPORT
    x = 0
   DETAIL
    x = (x+ 1)
    IF (mod(x,10)=1
     AND x != 1)
     stat = alter(reply->qual,(x+ 9))
    ENDIF
    reply->qual[x].source_vocabulary_cd = asvr.include_source_vocabulary_cd, reply->qual[x].
    cdf_meaning = cv.cdf_meaning
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus.operationname = "SELECT"
   SET reply->status_data.subeventstatus.operationstatus = "Z"
   SET reply->status_data.subeventstatus.targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus.targetobjectvalue = "AP_SOURCE_VOCABULARY_R"
  ELSE
   SET stat = alter(reply->qual,x)
  ENDIF
  IF (x=0)
   SET reply->status_data.status = "Z"
   SET stat = alter(reply->qual,0)
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
