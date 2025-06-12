CREATE PROGRAM cpmdecoder_loadcodeset:dba
 RECORD reply(
   1 qual[1]
     2 value_cd = f8
     2 code_disp = c50
     2 code_descr = c100
     2 meaning = c12
     2 code_set = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 CALL echo(build("loading code set:",request->code_set))
 SET ctime = format(curtime3,"hh:mm:ss;;mm")
 CALL echo(build("Start Time:",ctime))
 SELECT INTO "nl:"
  c.code_value, c.display, c.description,
  c.cdf_meaning, c.code_set
  FROM code_value c
  WHERE (c.code_set=request->code_set)
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY c.code_set, c.collation_seq, c.display_key
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alter(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].value_cd = c.code_value, reply->qual[count1].code_disp = c.display, reply->
   qual[count1].code_descr = c.description,
   reply->qual[count1].meaning = c.cdf_meaning, reply->qual[count1].code_set = c.code_set
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ENDIF
 SET ctime = format(curtime3,"hh:mm:ss;;mm")
 CALL echo(build("End Time:",ctime))
 SET stat = alter(reply->qual,count1)
END GO
