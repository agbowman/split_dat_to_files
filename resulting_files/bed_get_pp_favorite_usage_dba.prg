CREATE PROGRAM bed_get_pp_favorite_usage:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 personnel[*]
      2 id = f8
      2 name_full_formatted = vc
      2 customized_plans[*]
        3 id = f8
        3 power_plan_id = f8
        3 plan_name = vc
        3 creation_date_time = dq8
        3 status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temprequest
 RECORD temprequest(
   1 power_plans[*]
     2 power_plan_id = f8
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET power_plan_count = 0
 SET table_exists = checkdic("PATHWAY_CUSTOMIZED_PLAN","T",0)
 IF (table_exists != 2)
  GO TO exit_script
 ENDIF
 IF (validate(request->power_plans))
  SET power_plan_count = size(request->power_plans,5)
  SET stat = alterlist(temprequest->power_plans,power_plan_count)
  FOR (index = 1 TO power_plan_count)
    SET temprequest->power_plans[index].power_plan_id = request->power_plans[index].power_plan_id
  ENDFOR
 ENDIF
 IF ((request->power_plan_id > 0))
  SET power_plan_count = (power_plan_count+ 1)
  SET stat = alterlist(temprequest->power_plans,power_plan_count)
  SET temprequest->power_plans[power_plan_count].power_plan_id = request->power_plan_id
 ENDIF
 IF (power_plan_count=0)
  GO TO exit_script
 ENDIF
 SET personnelcnt = 0
 SET totalpersonnelcnt = 0
 SET powerplancount = 0
 SET totalpowerplancount = 0
 SELECT INTO "nl:"
  FROM pathway_catalog pc,
   pathway_catalog pc2,
   pathway_customized_plan pcp,
   prsnl p,
   (dummyt d  WITH seq = value(power_plan_count))
  PLAN (d)
   JOIN (pc
   WHERE (pc.pathway_catalog_id=temprequest->power_plans[d.seq].power_plan_id))
   JOIN (pc2
   WHERE pc2.version_pw_cat_id=pc.version_pw_cat_id)
   JOIN (pcp
   WHERE pcp.pathway_catalog_id=pc2.pathway_catalog_id)
   JOIN (p
   WHERE p.person_id=pcp.prsnl_id)
  HEAD REPORT
   personnelcnt = 0, totalpersonnelcnt = 0, stat = alterlist(reply->personnel,10)
  HEAD p.person_id
   personnelcnt = (personnelcnt+ 1), totalpersonnelcnt = (totalpersonnelcnt+ 1)
   IF (personnelcnt > 10)
    personnelcnt = 1, stat = alterlist(reply->personnel,(totalpersonnelcnt+ 10))
   ENDIF
   reply->personnel[totalpersonnelcnt].id = p.person_id, reply->personnel[totalpersonnelcnt].
   name_full_formatted = p.name_full_formatted, powerplancount = 0,
   totalpowerplancount = 0, stat = alterlist(reply->personnel[totalpersonnelcnt].customized_plans,10)
  DETAIL
   powerplancount = (powerplancount+ 1), totalpowerplancount = (totalpowerplancount+ 1)
   IF (powerplancount > 10)
    powerplancount = 1, stat = alterlist(reply->personnel[totalpersonnelcnt].customized_plans,(
     totalpowerplancount+ 10))
   ENDIF
   reply->personnel[totalpersonnelcnt].customized_plans[totalpowerplancount].id = pcp
   .pathway_customized_plan_id, reply->personnel[totalpersonnelcnt].customized_plans[
   totalpowerplancount].power_plan_id = pcp.pathway_catalog_id, reply->personnel[totalpersonnelcnt].
   customized_plans[totalpowerplancount].plan_name = pcp.plan_name,
   reply->personnel[totalpersonnelcnt].customized_plans[totalpowerplancount].creation_date_time = pcp
   .create_dt_tm, reply->personnel[totalpersonnelcnt].customized_plans[totalpowerplancount].
   status_flag = pcp.status_flag
  FOOT  p.person_id
   stat = alterlist(reply->personnel[totalpersonnelcnt].customized_plans,totalpowerplancount)
  FOOT REPORT
   stat = alterlist(reply->personnel,totalpersonnelcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
