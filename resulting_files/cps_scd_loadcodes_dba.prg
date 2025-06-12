CREATE PROGRAM cps_scd_loadcodes:dba
 RECORD reply(
   1 qual[*]
     2 value_cd = f8
     2 code_disp = vc
     2 code_descr = vc
     2 meaning = c12
     2 code_set = i4
     2 code_def = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT
  IF ((request->start_value=0))
   WHERE ((cs.code_set BETWEEN 14409 AND 14422) OR (((cs.code_set BETWEEN 15749 AND 15752) OR (cs
   .code_set IN (8, 17, 12100, 36, 14449,
   14450, 14709, 23, 54, 120,
   48, 12100, 29520, 31337, 31339))) ))
    AND c.code_set=cs.code_set
    AND c.active_ind=1
    AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ELSE
   WHERE (c.code_value=request->start_value)
    AND cs.code_set=c.code_set
   WITH nocounter
  ENDIF
  INTO "nl:"
  FROM code_value c,
   code_value_set cs
  ORDER BY c.code_value
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,100)=1)
    stat = alterlist(reply->qual,(count1+ 99))
   ENDIF
   reply->qual[count1].value_cd = c.code_value, reply->qual[count1].code_disp = c.display, reply->
   qual[count1].code_descr = c.description,
   reply->qual[count1].meaning = c.cdf_meaning, reply->qual[count1].code_set = c.code_set, reply->
   qual[count1].code_def = c.definition
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
