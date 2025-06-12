CREATE PROGRAM cv_get_cd_fro_cdfmng:dba
 RECORD reply(
   1 get_list[*]
     2 code_value = f8
     2 cdfmng = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->cdfmng_list,5))
 SET cdf_meaning = fillstring(15,"")
 SELECT INTO "nl:"
  c.cdf_meaning
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   code_value c
  PLAN (d)
   JOIN (c
   WHERE c.cdf_meaning=cnvtupper(request->cdfmng_list[d.seq].cdf_meaning)
    AND c.active_ind=1
    AND c.code_set IN (22309, 22310))
  ORDER BY c.cdf_meaning
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->get_list,5))
    stat = alterlist(reply->get_list,(count1+ 10))
   ENDIF
   reply->get_list[count1].code_value = c.code_value, reply->get_list[count1].cdfmng = c.cdf_meaning
  FOOT REPORT
   stat = alterlist(reply->get_list,count1)
  WITH nocounter
 ;end select
 SET count = 0
 FOR (count = 1 TO count1)
   CALL echo(build("This is the code_value",reply->get_list[count].code_value))
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
