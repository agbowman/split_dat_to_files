CREATE PROGRAM cp_get_problem_detail:dba
 RECORD reply(
   1 problem_qual = i4
   1 problem[*]
     2 problem_id = f8
     2 problem_instance_id = f8
     2 nomenclature_id = f8
     2 source_string = vc
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c40
     2 source_vocabulary_mean = c80
     2 source_identifier = c20
     2 problem_ftdesc = vc
     2 estimated_resolution_dt_tm = dq8
     2 actual_resolution_dt_tm = dq8
     2 classification_cd = f8
     2 classification_disp = c20
     2 classification_mean = c20
     2 persistence_cd = f8
     2 persistence_disp = c20
     2 persistence_mean = c20
     2 confirmation_status_cd = f8
     2 confirmation_status_disp = c20
     2 confirmation_status_mean = c20
     2 life_cycle_status_cd = f8
     2 life_cycle_status_disp = c20
     2 life_cycle_status_mean = c20
     2 life_cycle_dt_tm = dq8
     2 life_cycle_tz = i4
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 end_effective_dt_tm = dq8
     2 onset_dt_cd = f8
     2 onset_dt_disp = c40
     2 onset_dt_mean = c40
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 ranking_cd = f8
     2 ranking_disp = c20
     2 ranking_mean = c20
     2 certainty_cd = f8
     2 certainty_disp = c20
     2 certainty_mean = c20
     2 probability = f8
     2 person_awareness_cd = f8
     2 person_awareness_disp = c20
     2 person_awareness_mean = c20
     2 prognosis_cd = f8
     2 prognosis_disp = c10
     2 prognosis_mean = c10
     2 person_aware_prognosis_cd = f8
     2 person_aware_prognosis_disp = c20
     2 person_aware_prognosis_mean = c20
     2 family_aware_cd = f8
     2 family_aware_disp = c20
     2 family_aware_mean = c20
     2 sensitivity = i4
     2 course_cd = f8
     2 course_disp = c20
     2 course_mean = c20
     2 cancel_reason_cd = f8
     2 cancel_reason_disp = c20
     2 cancel_reason_mean = c20
     2 data_status_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 updt_id = f8
     2 updt_dt_tm = dq8
     2 updt_name_full_formatted = vc
     2 comment_qual = i4
     2 problem_comment[*]
       3 problem_comment_id = f8
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 name_full_formatted = vc
       3 problem_comment = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 data_status_dt_tm = dq8
       3 data_status_cd = f8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
     2 prsnl_qual = i4
     2 problem_prsnl[*]
       3 problem_prsnl_id = f8
       3 problem_reltn_dt_tm = dq8
       3 problem_reltn_cd = f8
       3 problem_reltn_disp = c40
       3 problem_reltn_mean = c40
       3 problem_reltn_prsnl_id = f8
       3 problem_prsnl_full_name = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 data_status_dt_tm = dq8
       3 data_status_cd = f8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
       3 updt_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE failed = vc
 SET failed = "FALSE"
 DECLARE resp_prov_cd = f8
 SET stat = uar_get_meaning_by_codeset(12038,"RESPONSIBLE",1,resp_prov_cd)
 SELECT INTO "NL:"
  p.problem_instance_id, p.problem_id, p.nomenclature_id,
  p.problem_ftdesc, p.estimated_resolution_dt_tm, p.actual_resolution_dt_tm,
  p.classification_cd, p.persistence_cd, p.confirmation_status_cd,
  p.life_cycle_status_cd, p.life_cycle_dt_tm, p.beg_effective_dt_tm,
  p.end_effective_dt_tm, p.onset_dt_cd, p.onset_dt_tm,
  p.ranking_cd, p.certainty_cd, p.probability,
  p.person_aware_cd, p.prognosis_cd, p.person_aware_prognosis_cd,
  p.family_aware_cd, p.sensitivity, p.course_cd,
  p.cancel_reason_cd, p.data_status_dt_tm, p.data_status_prsnl_id,
  p.data_status_cd, p.updt_id, p.updt_dt_tm,
  p.contributor_system_cd, n.source_vocabulary_cd, n.source_string,
  n.source_identifier
  FROM problem p,
   nomenclature n
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
  ORDER BY p.problem_id, cnvtdatetime(p.updt_dt_tm)
  HEAD REPORT
   prob_count = 0
  DETAIL
   prob_count = (prob_count+ 1)
   IF (mod(prob_count,10)=1)
    stat = alterlist(reply->problem,(prob_count+ 10))
   ENDIF
   reply->problem[prob_count].problem_instance_id = p.problem_instance_id, reply->problem[prob_count]
   .problem_id = p.problem_id
   IF (p.nomenclature_id > 0)
    reply->problem[prob_count].nomenclature_id = p.nomenclature_id, reply->problem[prob_count].
    source_string = n.source_string, reply->problem[prob_count].source_identifier = n
    .source_identifier,
    reply->problem[prob_count].source_vocabulary_cd = n.source_vocabulary_cd
   ELSE
    reply->problem[prob_count].source_string = p.problem_ftdesc
   ENDIF
   reply->problem[prob_count].estimated_resolution_dt_tm = p.estimated_resolution_dt_tm, reply->
   problem[prob_count].actual_resolution_dt_tm = p.actual_resolution_dt_tm, reply->problem[prob_count
   ].classification_cd = p.classification_cd,
   reply->problem[prob_count].persistence_cd = p.persistence_cd, reply->problem[prob_count].
   confirmation_status_cd = p.confirmation_status_cd, reply->problem[prob_count].life_cycle_status_cd
    = p.life_cycle_status_cd,
   reply->problem[prob_count].life_cycle_dt_tm = p.life_cycle_dt_tm, reply->problem[prob_count].
   life_cycle_tz = validate(p.life_cycle_tz,0), reply->problem[prob_count].beg_effective_dt_tm = p
   .beg_effective_dt_tm,
   reply->problem[prob_count].beg_effective_tz = validate(p.beg_effective_tz,0), reply->problem[
   prob_count].end_effective_dt_tm = p.end_effective_dt_tm, reply->problem[prob_count].onset_dt_cd =
   p.onset_dt_cd,
   reply->problem[prob_count].onset_dt_tm = p.onset_dt_tm, reply->problem[prob_count].onset_tz =
   validate(p.onset_tz,0), reply->problem[prob_count].ranking_cd = p.ranking_cd,
   reply->problem[prob_count].certainty_cd = p.certainty_cd, reply->problem[prob_count].probability
    = p.probability, reply->problem[prob_count].person_awareness_cd = p.person_aware_cd,
   reply->problem[prob_count].prognosis_cd = p.prognosis_cd, reply->problem[prob_count].
   person_aware_prognosis_cd = p.person_aware_prognosis_cd, reply->problem[prob_count].
   family_aware_cd = p.family_aware_cd,
   reply->problem[prob_count].sensitivity = p.sensitivity, reply->problem[prob_count].course_cd = p
   .course_cd, reply->problem[prob_count].cancel_reason_cd = p.cancel_reason_cd,
   reply->problem[prob_count].data_status_dt_tm = p.data_status_dt_tm, reply->problem[prob_count].
   data_status_cd = p.data_status_cd, reply->problem[prob_count].data_status_prsnl_id = p
   .data_status_prsnl_id,
   reply->problem[prob_count].contributor_system_cd = p.contributor_system_cd, reply->problem[
   prob_count].updt_id = p.updt_id, reply->problem[prob_count].updt_dt_tm = p.updt_dt_tm
  FOOT REPORT
   stat = alterlist(reply->problem,prob_count), reply->problem_qual = prob_count
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET failed = "TRUE"
  SET reply->status_data.status = "Z"
  GO TO error_check
 ENDIF
 SELECT
  IF ((request->order_seq=1))
   ORDER BY d3.seq, pc.problem_id, pc.problem_comment_id
  ELSE
   ORDER BY d3.seq, pc.problem_id, pc.problem_comment_id DESC
  ENDIF
  INTO "NL:"
  pc.problem_id, pc.problem_comment_id, pc.comment_dt_tm,
  pc.comment_prsnl_id, pc.problem_comment, pc.beg_effective_dt_tm,
  pc.end_effective_dt_tm, pc.data_status_dt_tm, pc.data_status_prsnl_id,
  pc.data_status_cd, pc.contributor_system_cd
  FROM (dummyt d3  WITH seq = value(reply->problem_qual)),
   problem_comment pc
  PLAN (d3)
   JOIN (pc
   WHERE (pc.problem_id=reply->problem[d3.seq].problem_id))
  HEAD REPORT
   comm_count = 0, prev_prob_id = 0, new_id = 0
  HEAD d3.seq
   do_nothing = 0
  HEAD pc.problem_id
   IF (prev_prob_id != pc.problem_id)
    new_id = 1
   ENDIF
  DETAIL
   IF (new_id=1)
    comm_count = (comm_count+ 1)
    IF (mod(comm_count,10)=1)
     stat = alterlist(reply->problem[d3.seq].problem_comment,(comm_count+ 10))
    ENDIF
    reply->problem[d3.seq].problem_comment[comm_count].problem_comment_id = pc.problem_comment_id,
    reply->problem[d3.seq].problem_comment[comm_count].comment_dt_tm = pc.comment_dt_tm, reply->
    problem[d3.seq].problem_comment[comm_count].comment_prsnl_id = pc.comment_prsnl_id,
    reply->problem[d3.seq].problem_comment[comm_count].comment_tz = validate(pc.comment_tz,0), reply
    ->problem[d3.seq].problem_comment[comm_count].problem_comment = pc.problem_comment, reply->
    problem[d3.seq].problem_comment[comm_count].beg_effective_dt_tm = pc.beg_effective_dt_tm,
    reply->problem[d3.seq].problem_comment[comm_count].end_effective_dt_tm = pc.end_effective_dt_tm,
    reply->problem[d3.seq].problem_comment[comm_count].data_status_dt_tm = pc.data_status_dt_tm,
    reply->problem[d3.seq].problem_comment[comm_count].data_status_cd = pc.data_status_cd,
    reply->problem[d3.seq].problem_comment[comm_count].data_status_prsnl_id = pc.data_status_prsnl_id,
    reply->problem[d3.seq].problem_comment[comm_count].contributor_system_cd = pc
    .contributor_system_cd
   ENDIF
  FOOT  pc.problem_id
   prev_prob_id = reply->problem[d3.seq].problem_id, new_id = 0
  FOOT  d3.seq
   stat = alterlist(reply->problem[d3.seq].problem_comment,comm_count), reply->problem[d3.seq].
   comment_qual = comm_count, comm_count = 0
  FOOT REPORT
   do_nothing = 0
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  ppr.problem_id, ppr.problem_prsnl_id, ppr.problem_reltn_dt_tm,
  ppr.problem_reltn_cd, ppr.problem_reltn_prsnl_id, ppr.beg_effective_dt_tm,
  ppr.end_effective_dt_tm, ppr.data_status_dt_tm, ppr.data_status_prsnl_id,
  ppr.data_status_cd, ppr.contributor_system_cd
  FROM (dummyt d4  WITH seq = value(reply->problem_qual)),
   problem_prsnl_r ppr
  PLAN (d4)
   JOIN (ppr
   WHERE (ppr.problem_id=reply->problem[d4.seq].problem_id)
    AND ppr.problem_reltn_cd=resp_prov_cd)
  HEAD REPORT
   prsnl_count = 0
  HEAD d4.seq
   do_nothing = 0
  DETAIL
   prsnl_count = (prsnl_count+ 1)
   IF (mod(prsnl_count,10)=1)
    stat = alterlist(reply->problem[d4.seq].problem_prsnl,(prsnl_count+ 10))
   ENDIF
   reply->problem[d4.seq].problem_prsnl[prsnl_count].problem_prsnl_id = ppr.problem_prsnl_id, reply->
   problem[d4.seq].problem_prsnl[prsnl_count].problem_reltn_dt_tm = ppr.problem_reltn_dt_tm, reply->
   problem[d4.seq].problem_prsnl[prsnl_count].problem_reltn_cd = ppr.problem_reltn_cd,
   reply->problem[d4.seq].problem_prsnl[prsnl_count].problem_reltn_prsnl_id = ppr
   .problem_reltn_prsnl_id, reply->problem[d4.seq].problem_prsnl[prsnl_count].beg_effective_dt_tm =
   ppr.beg_effective_dt_tm, reply->problem[d4.seq].problem_prsnl[prsnl_count].end_effective_dt_tm =
   ppr.end_effective_dt_tm,
   reply->problem[d4.seq].problem_prsnl[prsnl_count].contributor_system_cd = ppr
   .contributor_system_cd, reply->problem[d4.seq].problem_prsnl[prsnl_count].data_status_dt_tm = ppr
   .data_status_dt_tm, reply->problem[d4.seq].problem_prsnl[prsnl_count].data_status_cd = ppr
   .data_status_cd,
   reply->problem[d4.seq].problem_prsnl[prsnl_count].data_status_prsnl_id = ppr.data_status_prsnl_id
  FOOT  d4.seq
   stat = alterlist(reply->problem[d4.seq].problem_prsnl,prsnl_count), reply->problem[d4.seq].
   prsnl_qual = prsnl_count, prsnl_count = 0
  FOOT REPORT
   do_nothing = 0
  WITH nocounter
 ;end select
#error_check
 IF (failed="FALSE")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROBLEM"
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
#end_program
END GO
