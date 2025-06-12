CREATE PROGRAM cpm_get_by_conceptcki:dba
 CALL echorecord(request)
 RECORD reply(
   1 codevaluelist[*]
     2 code_set = i4
     2 code_value = f8
 )
 DECLARE cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE (cv.concept_cki=request->cki)
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY cv.code_set, cv.collation_seq, cv.display_key,
   cv.code_value
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->codevaluelist,cnt), reply->codevaluelist[cnt].code_set =
   cv.code_set,
   reply->codevaluelist[cnt].code_value = cv.code_value
  WITH nocounter
 ;end select
 CALL echorecord(reply)
END GO
