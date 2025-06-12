CREATE PROGRAM bbd_get_act_cd_cdf_disp:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 display = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE (c.code_set=request->code_set)
   AND c.code_value > 0
   AND c.active_ind=1
   AND cnvtdatetime(curdate,curtime3) >= c.begin_effective_dt_tm
   AND cnvtdatetime(curdate,curtime3) <= c.end_effective_dt_tm
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].code_value = c
   .code_value,
   reply->qual[count].cdf_meaning = c.cdf_meaning, reply->qual[count].display = c.display
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
