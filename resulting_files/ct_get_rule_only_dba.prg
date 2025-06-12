CREATE PROGRAM ct_get_rule_only:dba
 RECORD reply(
   1 rule_list[10]
     2 ct_rule_id = f8
     2 description = c100
     2 action_cd = f8
     2 action_disp = c40
     2 action_mean = c12
     2 action_desc = c60
     2 duration_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM ct_rule r
  WHERE r.active_ind=1
  ORDER BY r.description
  DETAIL
   cnt = (cnt+ 1), stat = alter(reply->rule_list,cnt), reply->rule_list[cnt].ct_rule_id = r
   .ct_rule_id,
   reply->rule_list[cnt].description = r.description, reply->rule_list[cnt].action_cd = r.action_cd,
   reply->rule_list[cnt].duration_cd = r.duration_cd,
   reply->rule_list[cnt].beg_effective_dt_tm = r.beg_effective_dt_tm, reply->rule_list[cnt].
   end_effective_dt_tm = r.end_effective_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CT_RULE"
 ENDIF
 SET stat = alter(reply->rule_list,cnt)
END GO
