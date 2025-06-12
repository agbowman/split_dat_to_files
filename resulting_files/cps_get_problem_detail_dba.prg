CREATE PROGRAM cps_get_problem_detail:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 problem_qual = i4
   1 problem[1]
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
     2 annotated_display = vc
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
   1 comment_qual = i4
   1 problem_comment[*]
     2 problem_comment_id = f8
     2 comment_dt_tm = dq8
     2 comment_tz = i4
     2 comment_prsnl_id = f8
     2 name_full_formatted = vc
     2 problem_comment = vc
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 end_effective_dt_tm = dq8
     2 data_status_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
   1 prsnl_qual = i4
   1 problem_prsnl[*]
     2 problem_prsnl_id = f8
     2 problem_reltn_dt_tm = dq8
     2 problem_reltn_cd = f8
     2 problem_reltn_disp = c40
     2 problem_reltn_mean = c40
     2 problem_reltn_prsnl_id = f8
     2 problem_prsnl_full_name = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 data_status_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 updt_ind = i2
   1 discipline_qual = i4
   1 problem_discipline[*]
     2 problem_discipline_id = f8
     2 management_discipline_cd = f8
     2 management_discipline_disp = c20
     2 management_discipline_mean = c20
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 data_status_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET table_name = "PROBLEM"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET failed = false
 SET prob_count = 0
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
  n.source_identifier, pr.name_full_formatted
  FROM problem p,
   (dummyt d2  WITH seq = 1),
   nomenclature n,
   prsnl pr
  PLAN (p
   WHERE (p.problem_id=request->problem_id))
   JOIN (d2)
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
   JOIN (pr
   WHERE pr.person_id=p.updt_id)
  ORDER BY cnvtdatetime(p.updt_dt_tm) DESC, p.problem_instance_id DESC
  HEAD p.problem_id
   prob_count = 0
  DETAIL
   prob_count = (prob_count+ 1)
   IF (mod(prob_count,10)=1)
    stat = alter(reply->problem,(prob_count+ 10))
   ENDIF
   reply->problem[prob_count].problem_instance_id = p.problem_instance_id, reply->problem[prob_count]
   .problem_id = p.problem_id, reply->problem[prob_count].problem_ftdesc = p.problem_ftdesc,
   reply->problem[prob_count].nomenclature_id = p.nomenclature_id, reply->problem[prob_count].
   source_string = n.source_string, reply->problem[prob_count].source_identifier = n
   .source_identifier,
   reply->problem[prob_count].source_vocabulary_cd = n.source_vocabulary_cd, reply->problem[
   prob_count].estimated_resolution_dt_tm = p.estimated_resolution_dt_tm, reply->problem[prob_count].
   actual_resolution_dt_tm = p.actual_resolution_dt_tm,
   reply->problem[prob_count].annotated_display = p.annotated_display, reply->problem[prob_count].
   classification_cd = p.classification_cd, reply->problem[prob_count].persistence_cd = p
   .persistence_cd,
   reply->problem[prob_count].confirmation_status_cd = p.confirmation_status_cd, reply->problem[
   prob_count].life_cycle_status_cd = p.life_cycle_status_cd, reply->problem[prob_count].
   life_cycle_dt_tm = p.life_cycle_dt_tm,
   reply->problem[prob_count].life_cycle_tz = p.life_cycle_tz, reply->problem[prob_count].
   beg_effective_dt_tm = p.beg_effective_dt_tm, reply->problem[prob_count].beg_effective_tz = p
   .beg_effective_tz,
   reply->problem[prob_count].end_effective_dt_tm = p.end_effective_dt_tm, reply->problem[prob_count]
   .onset_dt_cd = p.onset_dt_cd, reply->problem[prob_count].onset_dt_tm = p.onset_dt_tm,
   reply->problem[prob_count].onset_tz = p.onset_tz, reply->problem[prob_count].ranking_cd = p
   .ranking_cd, reply->problem[prob_count].certainty_cd = p.certainty_cd,
   reply->problem[prob_count].probability = p.probability, reply->problem[prob_count].
   person_awareness_cd = p.person_aware_cd, reply->problem[prob_count].prognosis_cd = p.prognosis_cd,
   reply->problem[prob_count].person_aware_prognosis_cd = p.person_aware_prognosis_cd, reply->
   problem[prob_count].family_aware_cd = p.family_aware_cd, reply->problem[prob_count].sensitivity =
   p.sensitivity,
   reply->problem[prob_count].course_cd = p.course_cd, reply->problem[prob_count].cancel_reason_cd =
   p.cancel_reason_cd, reply->problem[prob_count].data_status_dt_tm = p.data_status_dt_tm,
   reply->problem[prob_count].data_status_cd = p.data_status_cd, reply->problem[prob_count].
   data_status_prsnl_id = p.data_status_prsnl_id, reply->problem[prob_count].contributor_system_cd =
   p.contributor_system_cd,
   reply->problem[prob_count].updt_id = p.updt_id, reply->problem[prob_count].updt_dt_tm = p
   .updt_dt_tm, reply->problem[prob_count].updt_name_full_formatted = pr.name_full_formatted
  FOOT  p.problem_id
   stat = alter(reply->problem,prob_count), reply->problem_qual = prob_count
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  GO TO error_check
 ENDIF
 SET table_name = "PROBLEM_COMMENT"
 SET failed = false
 SET comm_count = 0
 SELECT INTO "NL:"
  pc.problem_id, pc.problem_comment_id, pc.comment_dt_tm,
  pc.comment_prsnl_id, pc.problem_comment, pc.beg_effective_dt_tm,
  pc.end_effective_dt_tm, pc.data_status_dt_tm, pc.data_status_prsnl_id,
  pc.data_status_cd, pc.contributor_system_cd, p.name_full_formatted
  FROM problem_comment pc,
   prsnl p
  PLAN (pc
   WHERE (pc.problem_id=request->problem_id))
   JOIN (p
   WHERE p.person_id=pc.comment_prsnl_id)
  HEAD pc.problem_id
   comm_count = 0
  DETAIL
   comm_count = (comm_count+ 1)
   IF (mod(comm_count,10)=1)
    stat = alterlist(reply->problem_comment,(comm_count+ 10))
   ENDIF
   reply->problem_comment[comm_count].problem_comment_id = pc.problem_comment_id, reply->
   problem_comment[comm_count].comment_dt_tm = pc.comment_dt_tm, reply->problem_comment[comm_count].
   comment_tz = pc.comment_tz,
   reply->problem_comment[comm_count].comment_prsnl_id = pc.comment_prsnl_id, reply->problem_comment[
   comm_count].problem_comment = pc.problem_comment, reply->problem_comment[comm_count].
   name_full_formatted = p.name_full_formatted,
   reply->problem_comment[comm_count].beg_effective_dt_tm = pc.beg_effective_dt_tm, reply->
   problem_comment[comm_count].beg_effective_tz = pc.beg_effective_tz, reply->problem_comment[
   comm_count].end_effective_dt_tm = pc.end_effective_dt_tm,
   reply->problem_comment[comm_count].data_status_dt_tm = pc.data_status_dt_tm, reply->
   problem_comment[comm_count].data_status_cd = pc.data_status_cd, reply->problem_comment[comm_count]
   .data_status_prsnl_id = pc.data_status_prsnl_id,
   reply->problem_comment[comm_count].contributor_system_cd = pc.contributor_system_cd
  FOOT  pc.problem_id
   stat = alterlist(reply->problem_comment,comm_count)
  WITH nocounter
 ;end select
 SET reply->comment_qual = comm_count
 SET table_name = "PROBLEM_PRSNL_R"
 SET failed = false
 SET prsnl_count = 0
 SET dt = cnvtdatetime("31-dec-2100")
 SELECT INTO "NL:"
  ppr.problem_id, ppr.problem_prsnl_id, ppr.problem_reltn_dt_tm,
  ppr.problem_reltn_cd, ppr.problem_reltn_prsnl_id, ppr.beg_effective_dt_tm,
  ppr.end_effective_dt_tm, ppr.data_status_dt_tm, ppr.data_status_prsnl_id,
  ppr.data_status_cd, ppr.contributor_system_cd, p.name_full_formatted
  FROM problem_prsnl_r ppr,
   prsnl p,
   (dummyt d2  WITH seq = 1)
  PLAN (ppr
   WHERE (ppr.problem_id=request->problem_id))
   JOIN (d2)
   JOIN (p
   WHERE p.person_id=ppr.problem_reltn_prsnl_id)
  HEAD ppr.problem_id
   prsnl_count = 0
  DETAIL
   prsnl_count = (prsnl_count+ 1)
   IF (mod(prsnl_count,10)=1)
    stat = alterlist(reply->problem_prsnl,(prsnl_count+ 10))
   ENDIF
   reply->problem_prsnl[prsnl_count].problem_prsnl_id = ppr.problem_prsnl_id, reply->problem_prsnl[
   prsnl_count].problem_reltn_dt_tm = ppr.problem_reltn_dt_tm, reply->problem_prsnl[prsnl_count].
   problem_reltn_cd = ppr.problem_reltn_cd,
   reply->problem_prsnl[prsnl_count].problem_reltn_prsnl_id = ppr.problem_reltn_prsnl_id, reply->
   problem_prsnl[prsnl_count].problem_prsnl_full_name = p.name_full_formatted, reply->problem_prsnl[
   prsnl_count].beg_effective_dt_tm = ppr.beg_effective_dt_tm,
   reply->problem_prsnl[prsnl_count].end_effective_dt_tm = ppr.end_effective_dt_tm, reply->
   problem_prsnl[prsnl_count].contributor_system_cd = ppr.contributor_system_cd, reply->
   problem_prsnl[prsnl_count].data_status_dt_tm = ppr.data_status_dt_tm,
   reply->problem_prsnl[prsnl_count].data_status_cd = ppr.data_status_cd, reply->problem_prsnl[
   prsnl_count].data_status_prsnl_id = ppr.data_status_prsnl_id
   IF (ppr.end_effective_dt_tm=dt)
    reply->problem_prsnl[prsnl_count].updt_ind = 1
   ELSE
    reply->problem_prsnl[prsnl_count].updt_ind = 0
   ENDIF
  FOOT  ppr.problem_id
   stat = alterlist(reply->problem_prsnl,prsnl_count), reply->prsnl_qual = prsnl_count
  WITH nocounter, outerjoin = d2
 ;end select
 IF (curqual < 0)
  SET failed = select_error
  GO TO error_check
 ENDIF
 SET table_name = "PROBLEM_DISCIPLINE"
 SET failed = false
 SET displ_count = 0
 SELECT INTO "nl:"
  pd.problem_discipline_id, pd.problem_id, pd.beg_effective_dt_tm,
  pd.end_effective_dt_tm, pd.management_discipline_cd, pd.data_status_dt_tm,
  pd.data_status_prsnl_id, pd.data_status_cd, pd.contributor_system_cd
  FROM problem_discipline pd
  PLAN (pd
   WHERE (pd.problem_id=request->problem_id))
  HEAD pd.problem_id
   displ_count = 0
  DETAIL
   displ_count = (displ_count+ 1)
   IF (mod(displ_count,10)=1)
    stat = alterlist(reply->problem_discipline,(displ_count+ 10))
   ENDIF
   reply->problem_discipline[displ_count].problem_discipline_id = pd.problem_discipline_id, reply->
   problem_discipline[displ_count].management_discipline_cd = pd.management_discipline_cd, reply->
   problem_discipline[displ_count].beg_effective_dt_tm = pd.beg_effective_dt_tm,
   reply->problem_discipline[displ_count].end_effective_dt_tm = pd.end_effective_dt_tm, reply->
   problem_discipline[displ_count].data_status_dt_tm = pd.data_status_dt_tm, reply->
   problem_discipline[displ_count].contributor_system_cd = pd.contributor_system_cd,
   reply->problem_discipline[displ_count].data_status_prsnl_id = pd.data_status_prsnl_id, reply->
   problem_discipline[displ_count].data_status_cd = pd.data_status_cd
  FOOT  pd.problem_id
   stat = alterlist(reply->problem_discipline,displ_count)
  WITH nocounter
 ;end select
 SET reply->discipline_qual = displ_count
 GO TO error_check
#error_check
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF select_error:
    SET reply->status_data.subeventstatus[1].operationname = "GET"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
 ENDIF
 GO TO end_program
#end_program
 SET script_version = "004 05/07/03 SF3151"
END GO
