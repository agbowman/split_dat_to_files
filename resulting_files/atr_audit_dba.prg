CREATE PROGRAM atr_audit:dba
 PAINT
 DECLARE appnbr = i4
 DECLARE aname = c100
#start
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,22,80)
 CALL line(3,1,80,xhoraz)
 CALL text(2,3,"CRM Troubleshooting")
 CALL text(5,5,"Application Number: ")
#startaccept
 SET help =
 SELECT INTO "nl:"
  a.application_number, a.description
  FROM application a
 ;end select
 CALL accept(5,25,"99999999;N")
 SET appnbr = curaccept
 SET help = off
 SELECT INTO "nl:"
  FROM application a
  WHERE a.application_number=appnbr
   AND appnbr > 0
  DETAIL
   aname = a.description
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL text(10,5,"Application Number not Found")
  GO TO startaccept
 ENDIF
 CALL text(5,25,cnvtstring(appnbr,8,0,r))
 CALL text(5,40,aname)
 SELECT
  t.task_number, task_desc = substring(1,30,t.description), r.request_number,
  request_desc = substring(1,30,r.description)
  FROM application_task_r atr,
   application_task t,
   task_request_r trr,
   request r
  WHERE atr.application_number=appnbr
   AND atr.task_number=t.task_number
   AND t.task_number=trr.task_number
   AND trr.request_number=r.request_number
  ORDER BY t.task_number, r.request_number
 ;end select
END GO
