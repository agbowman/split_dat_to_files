CREATE PROGRAM bed_get_lab_sr:dba
 FREE SET reply
 RECORD reply(
   1 sr_list[*]
     2 code_value = f8
     2 short_desc = vc
     2 long_desc = vc
     2 cdf_meaning = vc
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
 SET stat = alterlist(reply->sr_list,50)
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=221
   AND cv.active_ind=1
   AND ((cv.cdf_meaning="BENCH") OR (cv.cdf_meaning="INSTRUMENT"))
  ORDER BY cv.cdf_meaning, cv.display_key
  DETAIL
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 50)
    stat = alterlist(reply->sr_list,(tot_count+ 50)), count = 1
   ENDIF
   reply->sr_list[tot_count].code_value = cv.code_value, reply->sr_list[tot_count].short_desc = cv
   .display, reply->sr_list[tot_count].long_desc = cv.description,
   reply->sr_list[tot_count].cdf_meaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv,
   sub_section s
  PLAN (cv
   WHERE cv.code_set=221
    AND cv.active_ind=1
    AND cv.cdf_meaning="SUBSECTION")
   JOIN (s
   WHERE s.multiplexor_ind=1
    AND s.service_resource_cd=cv.code_value)
  ORDER BY cv.display_key
  DETAIL
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 50)
    stat = alterlist(reply->sr_list,(tot_count+ 50)), count = 1
   ENDIF
   reply->sr_list[tot_count].code_value = cv.code_value, reply->sr_list[tot_count].short_desc = cv
   .display, reply->sr_list[tot_count].long_desc = cv.description,
   reply->sr_list[tot_count].cdf_meaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->sr_list,tot_count)
 IF (tot_count=0)
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
