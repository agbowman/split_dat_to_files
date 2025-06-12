CREATE PROGRAM bed_get_proposed_sr_room:dba
 FREE SET reply
 RECORD reply(
   01 rlist[*]
     02 display = vc
     02 description = vc
     02 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET count = 0
 SET tot_count = 0
 SET option_nbr = 0
 IF ((request->srvres_option_nbr > 0))
  SET option_nbr = request->srvres_option_nbr
 ELSE
  SET option_nbr = 1
 ENDIF
 SELECT INTO "nl:"
  FROM br_proposed_srvres bps1,
   br_proposed_srvres bps2
  PLAN (bps1
   WHERE bps1.srvres_option_nbr=option_nbr
    AND bps1.srvres_level=3
    AND bps1.meaning=cnvtupper(request->ss_mean))
   JOIN (bps2
   WHERE bps2.parent_id=bps1.br_proposed_srvres_id
    AND bps2.srvres_option_nbr=option_nbr
    AND bps2.srvres_level=4)
  ORDER BY bps2.br_proposed_srvres_id
  HEAD REPORT
   stat = alterlist(reply->rlist,20)
  DETAIL
   count = (count+ 1), tot_count = (tot_count+ 1)
   IF (count > 20)
    stat = alterlist(reply->rlist,(tot_count+ 20)), count = 1
   ENDIF
   reply->rlist[tot_count].display = bps2.display, reply->rlist[tot_count].description = bps2
   .description, reply->rlist[tot_count].mean = bps2.meaning
  FOOT REPORT
   stat = alterlist(reply->rlist,tot_count)
  WITH nocounter
 ;end select
#exit_script
 CALL echorecord(reply)
END GO
