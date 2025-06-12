CREATE PROGRAM br_get_all_steps:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 step_mean = vc
     2 step_disp = vc
     2 step_cat_mean = vc
     2 step_cat_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_step bs
  PLAN (bs)
  ORDER BY bs.step_cat_mean, bs.default_seq
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->slist,cnt), reply->slist[cnt].step_mean = bs.step_mean,
   reply->slist[cnt].step_disp = bs.step_disp, reply->slist[cnt].step_cat_mean = bs.step_cat_mean,
   reply->slist[cnt].step_cat_disp = bs.step_cat_disp
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
