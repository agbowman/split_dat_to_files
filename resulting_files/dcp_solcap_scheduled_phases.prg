CREATE PROGRAM dcp_solcap_scheduled_phases
 DECLARE planned_pw_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"PLANNED"))
 DECLARE future_pw_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"FUTURE"))
 DECLARE initiated_review_pw_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "INITREVIEW"))
 DECLARE future_review_pw_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "FUTUREREVIEW"))
 DECLARE schedule_modify_pw_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,
   "SCHEDMODIFY"))
 SET stat = alterlist(reply->solcap,6)
 SET reply->solcap[1].identifier = "2012.1.00127.1"
 SELECT INTO "nl:"
  phases = count(DISTINCT pa.pathway_id)
  FROM pathway_action pa
  WHERE pa.pathway_id > 0
   AND pa.action_type_cd=schedule_modify_pw_action_cd
   AND pa.updt_task=3202004
   AND pa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm
   )
  DETAIL
   reply->solcap[1].degree_of_use_num = phases
  WITH nocounter
 ;end select
 SET reply->solcap[2].identifier = "2012.1.00127.2"
 SELECT INTO "nl:"
  phases = count(DISTINCT pa.pathway_id)
  FROM pathway_action pa
  WHERE pa.pathway_id > 0
   AND pa.action_type_cd=schedule_modify_pw_action_cd
   AND pa.pw_status_cd IN (initiated_review_pw_cd, future_review_pw_cd)
   AND pa.updt_task=3202004
   AND pa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm
   )
  DETAIL
   reply->solcap[2].degree_of_use_num = phases
  WITH nocounter
 ;end select
 SET reply->solcap[3].identifier = "2012.1.00127.3"
 SELECT INTO "nl:"
  phases = count(DISTINCT pa.pathway_id)
  FROM pathway_action pa
  WHERE pa.pathway_id > 0
   AND pa.action_type_cd=schedule_modify_pw_action_cd
   AND pa.pw_status_cd=planned_pw_cd
   AND pa.updt_task=3202004
   AND pa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm
   )
  DETAIL
   reply->solcap[3].degree_of_use_num = phases
  WITH nocounter
 ;end select
 SET reply->solcap[4].identifier = "2012.1.00127.4"
 SELECT INTO "nl:"
  phases = count(DISTINCT pa.pathway_id)
  FROM pathway_action pa
  WHERE pa.pathway_id > 0
   AND pa.action_type_cd=schedule_modify_pw_action_cd
   AND pa.pw_status_cd=future_pw_cd
   AND pa.updt_task=3202004
   AND pa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm
   )
  DETAIL
   reply->solcap[4].degree_of_use_num = phases
  WITH nocounter
 ;end select
 SET reply->solcap[5].identifier = "2015.1.00217.2"
 SET reply->solcap[6].identifier = "2015.1.00217.3"
 DECLARE hasscheduledanchorordersintreatment = i2 WITH protect, noconstant(0)
 SELECT DISTINCT INTO "nl:"
  pw1.pw_group_nbr, pcar.act_pw_comp_id, apc.pathway_id,
  pw2.pathway_group_id
  FROM pathway pw1,
   pw_comp_act_reltn pcar,
   act_pw_comp apc,
   pathway pw2
  PLAN (pw1
   WHERE pw1.order_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND pw1.type_mean IN ("CAREPLAN", "PHASE", "DOT"))
   JOIN (pcar
   WHERE pcar.pathway_id=pw1.pathway_id
    AND pcar.type_mean="SCHEDANCHOR")
   JOIN (apc
   WHERE apc.act_pw_comp_id=pcar.act_pw_comp_id
    AND apc.included_ind=1)
   JOIN (pw2
   WHERE pw2.pathway_id=apc.pathway_id)
  ORDER BY pw1.pw_group_nbr
  HEAD REPORT
   dummy = 0
  HEAD pw1.pw_group_nbr
   reply->solcap[5].degree_of_use_num += 1, hasscheduledanchorordersintreatment = 0
  DETAIL
   IF (apc.pathway_id=pw2.pathway_group_id)
    hasscheduledanchorordersintreatment = 1
   ENDIF
  FOOT  pw1.pw_group_nbr
   IF (hasscheduledanchorordersintreatment > 0)
    reply->solcap[6].degree_of_use_num += 1
   ENDIF
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
END GO
