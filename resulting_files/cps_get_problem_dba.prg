CREATE PROGRAM cps_get_problem:dba
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
   1 problem_cnt = i4
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
     2 comment_ind = i2
     2 problem_comment_id = f8
     2 problem_prsnl_id = f8
     2 problem_reltn_cd = f8
     2 problem_reltn_disp = c40
     2 problem_reltn_mean = c40
     2 problem_reltn_prsnl_id = f8
     2 problem_prsnl_full_name = vc
     2 respon_prsnl_id = f8
     2 respon_prsnl_name = vc
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 end_effective_dt_tm = dq8
     2 updt_id = f8
     2 updt_dt_tm = dq8
     2 updt_name_full_formatted = vc
     2 problem_discipline_knt = i4
     2 problem_discipline[*]
       3 problem_discipline_id = f8
       3 management_discipline_cd = f8
       3 management_discipline_disp = c20
       3 management_discipline_mean = c20
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 data_status_dt_tm = dq8
       3 data_status_cd = f8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
       3 contributor_system_disp = c20
       3 contributor_system_mean = c20
     2 problem_prsnl_knt = i4
     2 problem_prsnl[*]
       3 problem_reltn_prsnl_id = f8
       3 problem_prsnl_name = vc
       3 problem_reltn_cd = f8
     2 contributor_system_cd = f8
     2 contributor_system_disp = c20
     2 contributor_system_mean = c20
     2 comment_qual = i4
     2 problem_comment[*]
       3 problem_comment_id = f8
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 name_full_formatted = vc
       3 problem_comment = vc
       3 beg_effective_dt_tm = dq8
       3 beg_effective_tz = i4
       3 end_effective_dt_tm = dq8
       3 data_status_dt_tm = dq8
       3 data_status_cd = f8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE idx = i4 WITH public, noconstant(0)
 DECLARE i_pos = i4 WITH public, noconstant(0)
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET code_set = 12038
 SET prob_record_cd = 0.0
 SET prob_repons_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,"RECORDER",code_cnt,prob_record_cd)
 SET stat = uar_get_meaning_by_codeset(code_set,"RESPONSIBLE",code_cnt,prob_repons_cd)
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning RECORDER ","and/or RESPONSIBLE")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.problem_id
  FROM problem p,
   nomenclature n,
   prsnl pr2,
   problem_prsnl_r ppr,
   prsnl pr
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.problem_id > 0
    AND ((p.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((p.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
   JOIN (pr2
   WHERE pr2.person_id=p.updt_id)
   JOIN (ppr
   WHERE ppr.problem_id=outerjoin(p.problem_id)
    AND ppr.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ppr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime))
    AND ppr.active_ind=outerjoin(1))
   JOIN (pr
   WHERE pr.person_id=outerjoin(ppr.problem_reltn_prsnl_id)
    AND pr.active_ind=outerjoin(1))
  HEAD REPORT
   knt = 0, stat = alterlist(reply->problem,10)
  HEAD p.problem_id
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->problem,(knt+ 9))
   ENDIF
   reply->problem[knt].problem_instance_id = p.problem_instance_id, reply->problem[knt].problem_id =
   p.problem_id, reply->problem[knt].problem_ftdesc = p.problem_ftdesc,
   reply->problem[knt].nomenclature_id = p.nomenclature_id, reply->problem[knt].source_string = n
   .source_string, reply->problem[knt].source_identifier = n.source_identifier,
   reply->problem[knt].source_vocabulary_cd = n.source_vocabulary_cd, reply->problem[knt].
   estimated_resolution_dt_tm = p.estimated_resolution_dt_tm, reply->problem[knt].
   actual_resolution_dt_tm = p.actual_resolution_dt_tm,
   reply->problem[knt].classification_cd = p.classification_cd, reply->problem[knt].persistence_cd =
   p.persistence_cd, reply->problem[knt].confirmation_status_cd = p.confirmation_status_cd,
   reply->problem[knt].life_cycle_status_cd = p.life_cycle_status_cd, reply->problem[knt].
   life_cycle_dt_tm = p.life_cycle_dt_tm, reply->problem[knt].life_cycle_tz = p.life_cycle_tz,
   reply->problem[knt].onset_dt_cd = p.onset_dt_cd, reply->problem[knt].onset_dt_tm = p.onset_dt_tm,
   reply->problem[knt].onset_tz = p.onset_tz,
   reply->problem[knt].ranking_cd = p.ranking_cd, reply->problem[knt].certainty_cd = p.certainty_cd,
   reply->problem[knt].probability = p.probability,
   reply->problem[knt].person_awareness_cd = p.person_aware_cd, reply->problem[knt].prognosis_cd = p
   .prognosis_cd, reply->problem[knt].person_aware_prognosis_cd = p.person_aware_prognosis_cd,
   reply->problem[knt].family_aware_cd = p.family_aware_cd, reply->problem[knt].sensitivity = p
   .sensitivity, reply->problem[knt].course_cd = p.course_cd,
   reply->problem[knt].cancel_reason_cd = p.cancel_reason_cd, reply->problem[knt].beg_effective_dt_tm
    = p.beg_effective_dt_tm, reply->problem[knt].beg_effective_tz = p.beg_effective_tz,
   reply->problem[knt].end_effective_dt_tm = p.end_effective_dt_tm, reply->problem[knt].updt_id = p
   .updt_id, reply->problem[knt].updt_dt_tm = p.updt_dt_tm,
   reply->problem[knt].contributor_system_cd = p.contributor_system_cd, reply->problem[knt].
   updt_name_full_formatted = pr2.name_full_formatted, ppknt = 0
  HEAD ppr.problem_prsnl_id
   IF (ppr.problem_prsnl_id > 0)
    ppknt = (ppknt+ 1)
    IF (mod(ppknt,10)=1)
     stat = alterlist(reply->problem[knt].problem_prsnl,(ppknt+ 9))
    ENDIF
    reply->problem[knt].problem_prsnl[ppknt].problem_reltn_prsnl_id = ppr.problem_reltn_prsnl_id,
    reply->problem[knt].problem_prsnl[ppknt].problem_prsnl_name = pr.name_full_formatted, reply->
    problem[knt].problem_prsnl[ppknt].problem_reltn_cd = ppr.problem_reltn_cd
    IF (ppr.problem_reltn_cd=prob_record_cd)
     reply->problem[knt].problem_prsnl_id = ppr.problem_prsnl_id, reply->problem[knt].
     problem_reltn_prsnl_id = ppr.problem_reltn_prsnl_id, reply->problem[knt].problem_reltn_cd = ppr
     .problem_reltn_cd,
     reply->problem[knt].problem_prsnl_full_name = pr.name_full_formatted
    ENDIF
    IF (ppr.problem_reltn_cd=prob_repons_cd)
     reply->problem[knt].respon_prsnl_id = ppr.problem_reltn_prsnl_id, reply->problem[knt].
     respon_prsnl_name = pr.name_full_formatted
    ENDIF
   ENDIF
  FOOT  p.problem_id
   reply->problem[knt].problem_prsnl_knt = ppknt, stat = alterlist(reply->problem[knt].problem_prsnl,
    ppknt)
  FOOT REPORT
   reply->problem_cnt = knt, stat = alterlist(reply->problem,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PROBLEM"
  GO TO exit_script
 ENDIF
 IF ((reply->problem_cnt < 1))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM problem_comment pc,
   prsnl pr3
  PLAN (pc
   WHERE expand(idx,1,reply->problem_cnt,pc.problem_id,reply->problem[idx].problem_id)
    AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pc.active_ind=1)
   JOIN (pr3
   WHERE pr3.person_id=pc.comment_prsnl_id)
  HEAD pc.problem_id
   i_pos = 0, i_pos = locateval(i_pos,1,reply->problem_cnt,pc.problem_id,reply->problem[i_pos].
    problem_id), cknt = 0
  HEAD pc.problem_comment_id
   IF (pc.problem_comment_id > 0
    AND i_pos > 0)
    cknt = (cknt+ 1)
    IF (mod(cknt,10)=1)
     stat = alterlist(reply->problem[i_pos].problem_comment,(cknt+ 9))
    ENDIF
    reply->problem[i_pos].problem_comment[cknt].problem_comment_id = pc.problem_comment_id, reply->
    problem[i_pos].problem_comment[cknt].comment_dt_tm = pc.comment_dt_tm, reply->problem[i_pos].
    problem_comment[cknt].comment_tz = pc.comment_tz,
    reply->problem[i_pos].problem_comment[cknt].comment_prsnl_id = pc.comment_prsnl_id, reply->
    problem[i_pos].problem_comment[cknt].name_full_formatted = pr3.name_full_formatted, reply->
    problem[i_pos].problem_comment[cknt].problem_comment = pc.problem_comment,
    reply->problem[i_pos].problem_comment[cknt].beg_effective_dt_tm = pc.beg_effective_dt_tm, reply->
    problem[i_pos].problem_comment[cknt].beg_effective_tz = pc.beg_effective_tz, reply->problem[i_pos
    ].problem_comment[cknt].end_effective_dt_tm = pc.end_effective_dt_tm,
    reply->problem[i_pos].problem_comment[cknt].data_status_dt_tm = pc.data_status_dt_tm, reply->
    problem[i_pos].problem_comment[cknt].data_status_cd = pc.data_status_cd, reply->problem[i_pos].
    problem_comment[cknt].data_status_prsnl_id = pc.data_status_prsnl_id,
    reply->problem[i_pos].problem_comment[cknt].contributor_system_cd = pc.contributor_system_cd
   ENDIF
  FOOT  pc.problem_id
   IF (i_pos > 0)
    IF (cknt > 0)
     reply->problem[i_pos].comment_ind = 1
    ENDIF
    stat = alterlist(reply->problem[i_pos].problem_comment,cknt), reply->problem[i_pos].comment_qual
     = cknt
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PROBLEM_COMMENT"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM problem_discipline pd
  PLAN (pd
   WHERE expand(idx,1,reply->problem_cnt,pd.problem_id,reply->problem[idx].problem_id)
    AND pd.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pd.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pd.active_ind=1)
  HEAD pd.problem_id
   i_pos = 0, i_pos = locateval(i_pos,1,reply->problem_cnt,pd.problem_id,reply->problem[i_pos].
    problem_id), dknt = 0
  HEAD pd.problem_discipline_id
   IF (pd.problem_discipline_id > 0
    AND i_pos > 0)
    dknt = (dknt+ 1)
    IF (mod(dknt,10)=1)
     stat = alterlist(reply->problem[i_pos].problem_discipline,(dknt+ 9))
    ENDIF
    reply->problem[i_pos].problem_discipline[dknt].management_discipline_cd = pd
    .management_discipline_cd, reply->problem[i_pos].problem_discipline[dknt].problem_discipline_id
     = pd.problem_discipline_id, reply->problem[i_pos].problem_discipline[dknt].beg_effective_dt_tm
     = pd.beg_effective_dt_tm,
    reply->problem[i_pos].problem_discipline[dknt].end_effective_dt_tm = pd.end_effective_dt_tm,
    reply->problem[i_pos].problem_discipline[dknt].data_status_dt_tm = pd.data_status_dt_tm, reply->
    problem[i_pos].problem_discipline[dknt].data_status_cd = pd.data_status_cd,
    reply->problem[i_pos].problem_discipline[dknt].data_status_prsnl_id = pd.data_status_prsnl_id,
    reply->problem[i_pos].problem_discipline[dknt].contributor_system_cd = pd.contributor_system_cd
   ENDIF
  FOOT  pd.problem_id
   IF (i_pos > 0)
    reply->problem[i_pos].problem_discipline_knt = dknt, stat = alterlist(reply->problem[i_pos].
     problem_discipline,dknt)
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PROBLEM_DISCIPLINE"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "PCO_SEQ GENERATION"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSEIF ((reply->problem_cnt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "014 01/03/04 SF3151"
END GO
