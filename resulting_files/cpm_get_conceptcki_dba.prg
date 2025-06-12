CREATE PROGRAM cpm_get_conceptcki:dba
 RECORD reply(
   1 conceptcki = vc
 )
 CALL echorecord(request)
 IF (size(request->codevaluelist,5) > 0)
  SELECT INTO "nl:"
   cv.conceptcki
   FROM code_value cv
   WHERE (cv.code_value=request->codevaluelist[1].code_value)
   DETAIL
    reply->conceptcki = cv.concept_cki
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(reply)
END GO
