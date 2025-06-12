CREATE PROGRAM cpm_check_decoder:dba
 RECORD reply(
   1 codesetlist[*]
     2 code_cd = f8
     2 code_disp = vc
     2 code_desc = vc
     2 code_mean = vc
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
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE (c.code_set=request->codeset)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->codesetlist,count1), reply->codesetlist[count1].
   code_cd = c.code_value
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
