CREATE PROGRAM bed_get_sd_dept_types:dba
 FREE SET reply
 RECORD reply(
   1 dept_types[*]
     2 dept_type_id = f8
     2 display = vc
     2 prefix = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM br_sched_dept_type bsdt
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->dept_types,100)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->dept_types,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->dept_types[tot_cnt].dept_type_id = bsdt.dept_type_id, reply->dept_types[tot_cnt].display =
   bsdt.dept_type_display, reply->dept_types[tot_cnt].prefix = bsdt.dept_type_prefix
  FOOT REPORT
   stat = alterlist(reply->dept_types,tot_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
