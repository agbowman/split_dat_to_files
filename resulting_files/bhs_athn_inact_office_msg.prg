CREATE PROGRAM bhs_athn_inact_office_msg
 RECORD orequest(
   1 assign_list[*]
     2 assign_type = i2
     2 delete_ind = i2
     2 task_id = f8
     2 updt_cnt = i4
     2 assign_prsnl_list[*]
       3 assign_prsnl_id = f8
       3 updt_cnt = i4
       3 task_status_cd = f8
       3 msg_text_id = f8
     2 assign_person_list[*]
       3 assign_person_id = f8
       3 updt_cnt = i4
       3 task_status_cd = f8
       3 msg_text_id = f8
     2 assign_prsnl_group_list[*]
       3 assign_prsnl_group_id = f8
       3 assign_prsnl_id = f8
       3 updt_cnt = i4
 )
 DECLARE ta_updt_cnt = i4
 DECLARE taa_updt_cnt = i4
 SELECT INTO "nl:"
  FROM task_activity ta,
   task_activity_assignment taa
  PLAN (ta
   WHERE (ta.task_id= $2))
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND (taa.assign_prsnl_id= $3))
  HEAD REPORT
   ta_updt_cnt = ta.updt_cnt, taa_updt_cnt = taa.updt_cnt
  WITH nocounter, time = 30
 ;end select
 SET stat = alterlist(orequest->assign_list,1)
 SET orequest->assign_list[1].task_id =  $2
 SET orequest->assign_list[1].assign_type = 3
 SET orequest->assign_list[1].delete_ind = 1
 SET orequest->assign_list[1].updt_cnt = ta_updt_cnt
 SET stat = alterlist(orequest->assign_list[1].assign_prsnl_list,1)
 SET orequest->assign_list[1].assign_prsnl_list[1].assign_prsnl_id =  $3
 SET orequest->assign_list[1].assign_prsnl_list[1].updt_cnt = taa_updt_cnt
 SET stat = tdbexecute(3200000,3200604,967103,"REC",orequest,
  "REC",oreply)
 CALL echojson(oreply, $1)
END GO
