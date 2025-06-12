CREATE PROGRAM codecache_getvalue:dba
 RECORD reply(
   1 codevalue = f8
   1 display = c40
   1 meaning = c12
   1 descrip = c60
   1 codeset = i4
   1 collseq = i4
   1 dispkey = c40
   1 cki = c255
   1 concki = c255
   1 definition = c255
 )
 SET reply->codevalue = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE (c.code_value=request->codevalue)
   AND c.active_ind=1
   AND cnvtdatetime(curdate,curtime3) BETWEEN c.begin_effective_dt_tm AND c.end_effective_dt_tm
  DETAIL
   reply->codevalue = c.code_value, reply->display = c.display, reply->descrip = c.description,
   reply->meaning = c.cdf_meaning, reply->codeset = c.code_set, reply->collseq = c.collation_seq,
   reply->dispkey = c.display_key, reply->cki = c.cki, reply->concki = c.concept_cki,
   reply->definition = c.definition
  WITH nocounter
 ;end select
END GO
