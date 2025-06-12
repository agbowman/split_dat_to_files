CREATE PROGRAM cpm_get_codevaluet:dba
 RECORD reply(
   1 codesetlist[*]
     2 code = f8
     2 display = c15
     2 description = c50
     2 meaning = c12
     2 display_key = c15
     2 active_ind = i2
     2 definition = c100
     2 collation_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echo(build("user:",curuser))
 CALL echo(request->codeset)
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE (c.code_set=request->codeset)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->codesetlist,count1), reply->codesetlist[count1].code
    = c.code_value,
   reply->codesetlist[count1].display = c.display, reply->codesetlist[count1].description = c
   .description, reply->codesetlist[count1].meaning = c.cdf_meaning,
   reply->codesetlist[count1].display_key = c.display_key, reply->codesetlist[count1].active_ind = c
   .active_ind, reply->codesetlist[count1].definition = c.definition,
   reply->codesetlist[count1].collation_seq = c.collation_seq
  WITH counter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
