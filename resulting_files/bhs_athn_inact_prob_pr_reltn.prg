CREATE PROGRAM bhs_athn_inact_prob_pr_reltn
 RECORD orequest(
   1 person_id = f8
   1 problem_cnt = i4
   1 problem[*]
     2 problem_id = f8
     2 problem_instance_id = f8
     2 nomenclature_id = f8
     2 annotated_display = vc
     2 classification_cd = f8
     2 confirmation_status_cd = f8
     2 life_cycle_status_cd = f8
     2 onset_dt_cd = f8
     2 ranking_cd = f8
     2 persistence_cd = f8
     2 certainty_cd = f8
     2 probability = f8
     2 person_aware_cd = f8
     2 prognosis_cd = f8
     2 person_aware_prognosis_cd = f8
     2 family_aware_cd = f8
     2 course_cd = f8
     2 cancel_reason_cd = f8
     2 data_status_cd = f8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 estimated_resolution_dt_tm = dq8
     2 actual_resolution_dt_tm = dq8
     2 life_cycle_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 onset_dt_tm = dq8
     2 data_status_dt_tm = dq8
     2 problem_ftdesc = vc
     2 sensitivity = i4
     2 problem_action_ind = i2
     2 comment_only = i2
     2 prsnl_only = i2
     2 discipline_only = i2
     2 problem_comment_cnt = i4
     2 problem_prsnl_cnt = i4
     2 problem_discipline_cnt = i4
     2 problem_comment[*]
       3 comment_action_ind = i2
       3 problem_comment_id = f8
       3 data_status_cd = f8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
       3 comment_dt_tm = dq8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 data_status_dt_tm = dq8
       3 comment_prsnl_id = f8
       3 problem_comment = vc
     2 problem_discipline[*]
       3 discipline_action_ind = i2
       3 problem_discipline_id = f8
       3 management_discipline_cd = f8
       3 data_status_cd = f8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 data_status_dt_tm = dq8
     2 problem_prsnl[*]
       3 prsnl_action_ind = i2
       3 problem_prsnl_id = f8
       3 problem_reltn_cd = f8
       3 problem_reltn_prsnl_id = f8
       3 data_status_cd = f8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
       3 problem_reltn_dt_tm = dq8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 data_status_dt_tm = dq8
 )
 RECORD out_rec(
   1 problem_prsnl_id = vc
 )
 DECLARE username = vc
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $3)
    AND p.active_ind=1)
  HEAD p.person_id
   username = p.username
  WITH nocounter, time = 30
 ;end select
 SET namelen = (textlen(username)+ 1)
 SET domainnamelen = (textlen(curdomain)+ 2)
 SET statval = memalloc(name,1,build("C",namelen))
 SET statval = memalloc(domainname,1,build("C",domainnamelen))
 SET name = username
 SET domainname = curdomain
 SET setcntxt = uar_secimpersonate(nullterm(username),nullterm(domainname))
 SET orequest->problem_cnt = 1
 SET stat = alterlist(orequest->problem,orequest->problem_cnt)
 SET orequest->problem[orequest->problem_cnt].problem_id =  $2
 SET orequest->problem[orequest->problem_cnt].prsnl_only = 1
 SET orequest->problem[orequest->problem_cnt].problem_prsnl_cnt = 1
 SET stat = alterlist(orequest->problem[orequest->problem_cnt].problem_prsnl,orequest->problem[
  orequest->problem_cnt].problem_prsnl_cnt)
 SET orequest->problem[orequest->problem_cnt].problem_prsnl[1].prsnl_action_ind = 3
 SET orequest->problem[orequest->problem_cnt].problem_prsnl[1].problem_reltn_prsnl_id =  $3
 SET orequest->problem[orequest->problem_cnt].problem_prsnl[1].end_effective_dt_tm = cnvtdatetime(
  curdate,curtime)
 SET orequest->problem[orequest->problem_cnt].problem_prsnl[1].problem_reltn_cd =  $4
 SET stat = tdbexecute(600005,3202004,963035,"REC",orequest,
  "REC",oreply)
 FOR (i = 1 TO size(oreply->problem_list,5))
   FOR (j = 1 TO size(oreply->problem_list[i].prsnl_list,5))
     SET out_rec->problem_prsnl_id = cnvtstring(oreply->problem_list[i].prsnl_list.problem_prsnl_id)
   ENDFOR
 ENDFOR
 CALL echojson(out_rec, $1)
END GO
