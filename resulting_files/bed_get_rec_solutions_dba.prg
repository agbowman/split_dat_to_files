CREATE PROGRAM bed_get_rec_solutions:dba
 FREE SET reply
 RECORD reply(
   1 solutions[*]
     2 meaning = vc
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM br_rec br,
   br_rec_r brr,
   br_name_value b
  PLAN (br
   WHERE br.active_ind=1
    AND br.client_view_ind=1)
   JOIN (brr
   WHERE brr.rec_id=br.rec_id
    AND brr.solution_mean > " ")
   JOIN (b
   WHERE b.br_name=brr.solution_mean
    AND b.br_nv_key1="DIAGNOSTICSOLUTIONS")
  ORDER BY b.br_name
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->solutions,10)
  HEAD b.br_name
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->solutions,(tcnt+ 10)), cnt = 1
   ENDIF
   reply->solutions[tcnt].meaning = b.br_name, reply->solutions[tcnt].display = b.br_value
  FOOT REPORT
   stat = alterlist(reply->solutions,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
