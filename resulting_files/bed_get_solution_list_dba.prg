CREATE PROGRAM bed_get_solution_list:dba
 FREE SET reply
 RECORD reply(
   01 slist[*]
     02 solution_mean = vc
     02 solution_disp = vc
     02 steplist[*]
       03 step_mean = vc
       03 step_disp = vc
       03 step_cat_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = 0
 SELECT INTO "nl:"
  FROM br_solution bs,
   br_solution_step bss,
   br_step bsp
  PLAN (bs)
   JOIN (bss
   WHERE bss.solution_mean=outerjoin(bs.solution_mean))
   JOIN (bsp
   WHERE bsp.step_mean=outerjoin(bss.step_mean))
  ORDER BY bs.solution_disp, bss.sequence
  HEAD REPORT
   scnt = 0
  HEAD bs.solution_disp
   scnt = (scnt+ 1), stat = alterlist(reply->slist,scnt), reply->slist[scnt].solution_mean = bs
   .solution_mean,
   reply->slist[scnt].solution_disp = bs.solution_disp, stepcnt = 0
  DETAIL
   stepcnt = (stepcnt+ 1), stat = alterlist(reply->slist[scnt].steplist,stepcnt), reply->slist[scnt].
   steplist[stepcnt].step_mean = bsp.step_mean,
   reply->slist[scnt].steplist[stepcnt].step_disp = bsp.step_disp, reply->slist[scnt].steplist[
   stepcnt].step_cat_mean = bsp.step_cat_mean
  WITH nocounter
 ;end select
 IF (scnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
