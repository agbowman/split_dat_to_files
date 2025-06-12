CREATE PROGRAM bed_get_cdf:dba
 FREE SET reply
 RECORD reply(
   1 meanings[*]
     2 mean = vc
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE parse_data = vc
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET parse_data = build("c.code_set = ",request->code_set)
 IF ((request->definition > " "))
  SET parse_data = build(parse_data,' and c.definition = "',request->definition,'"')
 ENDIF
 SELECT INTO "nl:"
  FROM common_data_foundation c
  WHERE parser(parse_data)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,20)=1)
    stat = alterlist(reply->meanings,(cnt+ 19))
   ENDIF
   reply->meanings[cnt].mean = c.cdf_meaning, reply->meanings[cnt].display = c.display
  FOOT REPORT
   stat = alterlist(reply->meanings,cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
