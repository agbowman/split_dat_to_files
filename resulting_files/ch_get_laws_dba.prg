CREATE PROGRAM ch_get_laws:dba
 RECORD reply(
   1 qual[*]
     2 law_id = f8
     2 law_descr = vc
     2 logical_domain_id = f8
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
 SET start_name = 0
 SELECT DISTINCT INTO "nl:"
  c.law_descr
  FROM chart_law c
  WHERE (c.law_id >= request->start_name)
   AND c.active_ind=1
  ORDER BY c.law_descr
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].law_descr = c.law_descr, reply->qual[count1].law_id = c.law_id, reply->qual[
   count1].logical_domain_id = c.logical_domain_id
  WITH nocounter, maxqual(c,value(request->maxqual))
 ;end select
 SET stat = alterlist(reply->qual,count1)
 SET size_reply = 0
 SET size_reply = size(reply->qual,5)
 SET x = 0
 FOR (x = 1 TO size_reply)
   CALL echo(reply->qual[x].law_id)
   CALL echo(reply->qual[x].law_descr)
   CALL echo(reply->qual[x].logical_domain_id)
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  CALL echo("Z")
 ELSE
  SET reply->status_data.status = "S"
  CALL echo("S")
 ENDIF
END GO
