CREATE PROGRAM act_get_codes:dba
 RECORD reply(
   1 cd[*]
     2 code_set = i4
     2 code[*]
       3 code = f8
       3 description = vc
       3 display = vc
       3 meaning = vc
       3 definition = vc
       3 collation_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET nbr_to_get = size(request->codes,5)
 IF (nbr_to_get=1
  AND (request->codes[1].code_set=0))
  SET nbr_to_get = 0
  GO TO exit_program
 ENDIF
 SET j = 0
 SET i = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   code_value c
  PLAN (d)
   JOIN (c
   WHERE (c.code_set=request->codes[d.seq].code_set)
    AND ((c.active_ind+ 0)=1)
    AND ((c.begin_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((c.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
  ORDER BY c.code_set, c.display_key
  HEAD c.code_set
   i = 0, j = (j+ 1), stat = alterlist(reply->cd,j),
   reply->cd[j].code_set = c.code_set
  DETAIL
   i = (i+ 1), stat = alterlist(reply->cd[j].code,i), reply->cd[j].code[i].code = c.code_value,
   reply->cd[j].code[i].description = trim(c.description,3), reply->cd[j].code[i].display = trim(c
    .display,3), reply->cd[j].code[i].meaning = trim(c.cdf_meaning,3),
   reply->cd[j].code[i].definition = trim(c.definition,3), reply->cd[j].code[i].collation_seq = c
   .collation_seq
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_program
END GO
