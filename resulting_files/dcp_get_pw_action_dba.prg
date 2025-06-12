CREATE PROGRAM dcp_get_pw_action:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 pathway_id = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 action_cnt = i2
    1 action_qual[*]
      2 pw_action_seq = i2
      2 pw_action_cd = f8
      2 pw_action_disp = vc
      2 pw_action_mean = c12
      2 pw_status_cd = f8
      2 pw_status_disp = vc
      2 pw_status_mean = c12
      2 action_dt_tm = dq8
      2 action_prsnl_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET act_cnt = 0
 SELECT INTO "nl:"
  pa.pw_action_seq, pa.action_type_cd, pa.pw_status_cd,
  pa.action_dt_tm, name = trim(pr.name_full_formatted,3)
  FROM pathway_action pa,
   prsnl pr
  PLAN (pa
   WHERE (pa.pathway_id=request->pathway_id))
   JOIN (pr
   WHERE pa.action_prsnl_id=pr.person_id)
  ORDER BY pa.pw_action_seq DESC
  HEAD REPORT
   act_cnt = 0
  HEAD pa.pw_action_seq
   act_cnt = (act_cnt+ 1), stat = alterlist(reply->action_qual,act_cnt), reply->action_qual[act_cnt].
   pw_action_seq = pa.pw_action_seq,
   reply->action_qual[act_cnt].pw_action_cd = pa.action_type_cd, reply->action_qual[act_cnt].
   pw_status_cd = pa.pw_status_cd, reply->action_qual[act_cnt].action_dt_tm = pa.action_dt_tm,
   reply->action_qual[act_cnt].action_prsnl_name = name
  FOOT REPORT
   reply->action_cnt = act_cnt
  WITH nocounter
 ;end select
 IF ((reply->status_data.status != "F")
  AND (reply->status_data.status != "Z"))
  SET reply->status_data.status = "S"
 ENDIF
END GO
