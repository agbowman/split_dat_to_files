CREATE PROGRAM bhs_athn_read_problems
 RECORD orequest(
   1 person_id = f8
   1 person[*]
     2 person_id = f8
   1 cancel_ind = i2
   1 problem[*]
     2 problem_id = f8
 )
 FREE RECORD resp
 RECORD resp(
   1 person_id = vc
   1 problem_cnt = vc
   1 problem[*]
     2 person_id = vc
     2 problem_id = vc
     2 problem_instance_id = vc
     2 nomenclature_id = vc
     2 source_string = vc
     2 source_vocabulary_cd = vc
     2 source_vocabulary_disp = vc
     2 source_vocabulary_mean = vc
     2 source_identifier = vc
     2 problem_ftdesc = vc
     2 estimated_resolution_dt_tm = vc
     2 actual_resolution_dt_tm = vc
     2 annotated_display = vc
     2 classification_cd = vc
     2 classification_disp = vc
     2 classification_mean = vc
     2 persistence_cd = vc
     2 persistence_disp = vc
     2 persistence_mean = vc
     2 confirmation_status_cd = vc
     2 confirmation_status_disp = vc
     2 confirmation_status_mean = vc
     2 life_cycle_status_cd = vc
     2 life_cycle_status_disp = vc
     2 life_cycle_status_mean = vc
     2 life_cycle_dt_tm = vc
     2 onset_dt_cd = vc
     2 onset_dt_disp = vc
     2 onset_dt_mean = vc
     2 onset_dt_tm = vc
     2 ranking_cd = vc
     2 ranking_disp = vc
     2 ranking_mean = vc
     2 certainty_cd = vc
     2 certainty_disp = vc
     2 certainty_mean = vc
     2 probability = f8
     2 person_awareness_cd = vc
     2 person_awareness_disp = vc
     2 person_awareness_mean = vc
     2 prognosis_cd = vc
     2 prognosis_disp = vc
     2 prognosis_mean = vc
     2 person_aware_prognosis_cd = vc
     2 person_aware_prognosis_disp = vc
     2 person_aware_prognosis_mean = vc
     2 family_aware_cd = vc
     2 family_aware_disp = vc
     2 family_aware_mean = vc
     2 sensitivity = vc
     2 course_cd = vc
     2 course_disp = vc
     2 course_mean = vc
     2 cancel_reason_cd = vc
     2 cancel_reason_disp = vc
     2 cancel_reason_mean = vc
     2 comment_ind = vc
     2 problem_comment_id = vc
     2 problem_prsnl_id = vc
     2 problem_reltn_cd = vc
     2 problem_reltn_disp = vc
     2 problem_reltn_mean = vc
     2 problem_reltn_prsnl_id = vc
     2 problem_prsnl_full_name = vc
     2 respon_prsnl_id = vc
     2 respon_prsnl_name = vc
     2 beg_effective_dt_tm = vc
     2 end_effective_dt_tm = vc
     2 updt_id = vc
     2 updt_dt_tm = vc
     2 updt_name_full_formatted = vc
     2 problem_discipline_knt = vc
     2 problem_prsnl_knt = vc
     2 contributor_system_cd = vc
     2 contributor_system_disp = vc
     2 contributor_system_mean = vc
     2 comment_qual = vc
     2 onset_dt_flag = vc
     2 problem_discipline[*]
       3 problem_discipline_id = vc
       3 management_discipline_cd = vc
       3 management_discipline_disp = vc
       3 management_discipline_mean = vc
       3 beg_effective_dt_tm = vc
       3 end_effective_dt_tm = vc
     2 problem_prsnl[*]
       3 problem_id = vc
       3 problem_reltn_prsnl_id = vc
       3 problem_prsnl_name = vc
       3 problem_reltn_cd = vc
       3 problem_reltn_disp = vc
       3 problem_reltn_mean = vc
       3 problem_reltn_dt_tm = vc
       3 beg_effective_dt_tm = vc
       3 end_effective_dt_tm = vc
     2 problem_comment[*]
       3 problem_id = vc
       3 problem_comment_id = vc
       3 comment_dt_tm = vc
       3 comment_prsnl_id = vc
       3 name_full_formatted = vc
       3 problem_comment = vc
       3 beg_effective_dt_tm = vc
       3 end_effective_dt_tm = vc
       3 data_status_dt_tm = vc
       3 data_status_cd = vc
       3 data_status_prsnl_id = vc
       3 contributor_system_cd = vc
   1 status = vc
 )
 IF (( $2 > 0))
  SET orequest->person_id =  $2
 ENDIF
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET cnt = 0
 SET t_line =  $3
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET cnt += 1
    SET stat = alterlist(orequest->problem,cnt)
    SET orequest->problem[cnt].problem_id = cnvtreal(t_line)
    SET done = 1
   ELSE
    SET cnt += 1
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(orequest->problem,cnt)
    SET orequest->problem[cnt].problem_id = cnvtreal(t_line2)
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 SET orequest->cancel_ind =  $4
 SET stat = tdbexecute(3200000,3200061,963030,"REC",orequest,
  "REC",oreply)
 SET resp->status = oreply->status_data.status
 IF ((resp->status="S"))
  SET stat = alterlist(resp->problem,size(oreply->person[1].problem,5))
  SET resp->person_id = cnvtstring(oreply->person[1].person_id)
  SET resp->problem_cnt = cnvtstring(oreply->person[1].problem_cnt)
  FOR (i = 1 TO size(oreply->person[1].problem,5))
    SET resp->problem[i].person_id = cnvtstring(oreply->person[1].person_id)
    SET resp->problem[i].problem_id = cnvtstring(oreply->person[1].problem[i].problem_id)
    SET resp->problem[i].problem_instance_id = cnvtstring(oreply->person[1].problem[i].
     problem_instance_id)
    SET resp->problem[i].nomenclature_id = cnvtstring(oreply->person[1].problem[i].nomenclature_id)
    SET resp->problem[i].source_string = oreply->person[1].problem[i].source_string
    SET resp->problem[i].source_vocabulary_cd = cnvtstring(oreply->person[1].problem[i].
     source_vocabulary_cd)
    SET resp->problem[i].source_vocabulary_disp = oreply->person[1].problem[i].source_vocabulary_disp
    SET resp->problem[i].source_vocabulary_mean = oreply->person[1].problem[i].source_vocabulary_mean
    SET resp->problem[i].source_identifier = cnvtstring(oreply->person[1].problem[i].
     source_identifier)
    SET resp->problem[i].problem_ftdesc = oreply->person[1].problem[i].problem_ftdesc
    SET resp->problem[i].estimated_resolution_dt_tm = datetimezoneformat(oreply->person[1].problem[i]
     .estimated_resolution_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
    SET resp->problem[i].actual_resolution_dt_tm = datetimezoneformat(oreply->person[1].problem[i].
     actual_resolution_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
    SET resp->problem[i].annotated_display = oreply->person[1].problem[i].annotated_display
    SET resp->problem[i].classification_cd = cnvtstring(oreply->person[1].problem[i].
     classification_cd)
    SET resp->problem[i].classification_disp = oreply->person[1].problem[i].classification_disp
    SET resp->problem[i].classification_mean = oreply->person[1].problem[i].classification_mean
    SET resp->problem[i].persistence_cd = cnvtstring(oreply->person[1].problem[i].persistence_cd)
    SET resp->problem[i].persistence_disp = oreply->person[1].problem[i].persistence_disp
    SET resp->problem[i].persistence_mean = oreply->person[1].problem[i].persistence_mean
    SET resp->problem[i].confirmation_status_cd = cnvtstring(oreply->person[1].problem[i].
     confirmation_status_cd)
    SET resp->problem[i].confirmation_status_disp = oreply->person[1].problem[i].
    confirmation_status_disp
    SET resp->problem[i].confirmation_status_mean = oreply->person[1].problem[i].
    confirmation_status_mean
    SET resp->problem[i].life_cycle_status_cd = cnvtstring(oreply->person[1].problem[i].
     life_cycle_status_cd)
    SET resp->problem[i].life_cycle_status_disp = oreply->person[1].problem[i].life_cycle_status_disp
    SET resp->problem[i].life_cycle_status_mean = oreply->person[1].problem[i].life_cycle_status_mean
    SET resp->problem[i].life_cycle_dt_tm = datetimezoneformat(oreply->person[1].problem[i].
     life_cycle_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
    SET resp->problem[i].onset_dt_flag = cnvtstring(oreply->person[1].problem[i].onset_dt_flag)
    SET resp->problem[i].onset_dt_cd = cnvtstring(oreply->person[1].problem[i].onset_dt_cd)
    SET resp->problem[i].onset_dt_disp = oreply->person[1].problem[i].onset_dt_disp
    SET resp->problem[i].onset_dt_mean = oreply->person[1].problem[i].onset_dt_mean
    SET resp->problem[i].onset_dt_tm = datetimezoneformat(oreply->person[1].problem[i].onset_dt_tm,
     curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
    SET resp->problem[i].ranking_cd = cnvtstring(oreply->person[1].problem[i].ranking_cd)
    SET resp->problem[i].ranking_disp = oreply->person[1].problem[i].ranking_disp
    SET resp->problem[i].ranking_mean = oreply->person[1].problem[i].ranking_mean
    SET resp->problem[i].certainty_cd = cnvtstring(oreply->person[1].problem[i].certainty_cd)
    SET resp->problem[i].certainty_disp = oreply->person[1].problem[i].certainty_disp
    SET resp->problem[i].certainty_mean = oreply->person[1].problem[i].certainty_mean
    SET resp->problem[i].probability = oreply->person[1].problem[i].probability
    SET resp->problem[i].person_awareness_cd = cnvtstring(oreply->person[1].problem[i].
     person_awareness_cd)
    SET resp->problem[i].person_awareness_disp = oreply->person[1].problem[i].person_awareness_disp
    SET resp->problem[i].person_awareness_mean = oreply->person[1].problem[i].person_awareness_mean
    SET resp->problem[i].prognosis_cd = cnvtstring(oreply->person[1].problem[i].prognosis_cd)
    SET resp->problem[i].prognosis_disp = oreply->person[1].problem[i].prognosis_disp
    SET resp->problem[i].prognosis_mean = oreply->person[1].problem[i].prognosis_mean
    SET resp->problem[i].person_aware_prognosis_cd = cnvtstring(oreply->person[1].problem[i].
     person_aware_prognosis_cd)
    SET resp->problem[i].person_aware_prognosis_disp = oreply->person[1].problem[i].
    person_aware_prognosis_disp
    SET resp->problem[i].person_aware_prognosis_mean = oreply->person[1].problem[i].
    person_aware_prognosis_mean
    SET resp->problem[i].family_aware_cd = cnvtstring(oreply->person[1].problem[i].family_aware_cd)
    SET resp->problem[i].family_aware_disp = oreply->person[1].problem[i].family_aware_disp
    SET resp->problem[i].family_aware_mean = oreply->person[1].problem[i].family_aware_mean
    SET resp->problem[i].sensitivity = cnvtstring(oreply->person[1].problem[i].sensitivity)
    SET resp->problem[i].course_cd = cnvtstring(oreply->person[1].problem[i].course_cd)
    SET resp->problem[i].course_disp = oreply->person[1].problem[i].course_disp
    SET resp->problem[i].course_mean = oreply->person[1].problem[i].course_mean
    SET resp->problem[i].cancel_reason_cd = cnvtstring(oreply->person[1].problem[i].cancel_reason_cd)
    SET resp->problem[i].cancel_reason_disp = oreply->person[1].problem[i].cancel_reason_disp
    SET resp->problem[i].cancel_reason_mean = oreply->person[1].problem[i].cancel_reason_mean
    SET resp->problem[i].comment_ind = cnvtstring(oreply->person[1].problem[i].comment_ind)
    SET resp->problem[i].problem_comment_id = cnvtstring(oreply->person[1].problem[i].
     problem_comment_id)
    SET resp->problem[i].problem_prsnl_id = cnvtstring(oreply->person[1].problem[i].problem_prsnl_id)
    SET resp->problem[i].problem_reltn_cd = cnvtstring(oreply->person[1].problem[i].problem_reltn_cd)
    SET resp->problem[i].problem_reltn_disp = oreply->person[1].problem[i].problem_reltn_disp
    SET resp->problem[i].problem_reltn_mean = oreply->person[1].problem[i].problem_reltn_mean
    SET resp->problem[i].problem_reltn_prsnl_id = cnvtstring(oreply->person[1].problem[i].
     problem_reltn_prsnl_id)
    SET resp->problem[i].problem_prsnl_full_name = oreply->person[1].problem[i].
    problem_prsnl_full_name
    SET resp->problem[i].respon_prsnl_id = cnvtstring(oreply->person[1].problem[i].respon_prsnl_id)
    SET resp->problem[i].respon_prsnl_name = oreply->person[1].problem[i].respon_prsnl_name
    SET resp->problem[i].beg_effective_dt_tm = datetimezoneformat(oreply->person[1].problem[i].
     beg_effective_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
    SET resp->problem[i].end_effective_dt_tm = datetimezoneformat(oreply->person[1].problem[i].
     end_effective_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
    SET resp->problem[i].updt_id = cnvtstring(oreply->person[1].problem[i].updt_id)
    SET resp->problem[i].updt_dt_tm = datetimezoneformat(oreply->person[1].problem[i].updt_dt_tm,
     curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
    SET resp->problem[i].updt_name_full_formatted = oreply->person[1].problem[i].
    updt_name_full_formatted
    SET resp->problem[i].contributor_system_cd = cnvtstring(oreply->person[1].problem[i].
     contributor_system_cd)
    SET resp->problem[i].contributor_system_disp = oreply->person[1].problem[i].
    contributor_system_disp
    SET resp->problem[i].contributor_system_mean = oreply->person[1].problem[i].
    contributor_system_mean
    SET resp->problem[i].problem_discipline_knt = cnvtstring(oreply->person[1].problem[i].
     problem_discipline_knt)
    SET stat = alterlist(resp->problem[i].problem_discipline,size(oreply->person[1].problem[i].
      problem_discipline,5))
    FOR (j = 1 TO size(oreply->person[1].problem[i].problem_discipline,5))
      SET resp->problem[i].problem_discipline[j].problem_discipline_id = cnvtstring(oreply->person[1]
       .problem[i].problem_discipline[j].problem_discipline_id)
      SET resp->problem[i].problem_discipline[j].management_discipline_cd = cnvtstring(oreply->
       person[1].problem[i].problem_discipline[j].management_discipline_cd)
      SET resp->problem[i].problem_discipline[j].management_discipline_disp = uar_get_code_display(
       oreply->person[1].problem[i].problem_discipline[j].management_discipline_cd)
      SET resp->problem[i].problem_discipline[j].management_discipline_mean = uar_get_code_meaning(
       oreply->person[1].problem[i].problem_discipline[j].management_discipline_cd)
      SET resp->problem[i].problem_discipline[j].beg_effective_dt_tm = datetimezoneformat(oreply->
       person[1].problem[i].problem_discipline[j].beg_effective_dt_tm,curtimezonesys,
       "yyyy-MM-dd HH:mm:ss",curtimezonedef)
      SET resp->problem[i].problem_discipline[j].end_effective_dt_tm = datetimezoneformat(oreply->
       person[1].problem[i].problem_discipline[j].end_effective_dt_tm,curtimezonesys,
       "yyyy-MM-dd HH:mm:ss",curtimezonedef)
    ENDFOR
    SET resp->problem[i].problem_prsnl_knt = cnvtstring(oreply->person[1].problem[i].
     problem_prsnl_knt)
    SET stat = alterlist(resp->problem[i].problem_prsnl,size(oreply->person[1].problem[i].
      problem_prsnl,5))
    FOR (j = 1 TO size(oreply->person[1].problem[i].problem_prsnl,5))
      SET resp->problem[i].problem_prsnl[j].problem_id = cnvtstring(oreply->person[1].problem[i].
       problem_id)
      SET resp->problem[i].problem_prsnl[j].problem_reltn_prsnl_id = cnvtstring(oreply->person[1].
       problem[i].problem_prsnl[j].problem_reltn_prsnl_id)
      SET resp->problem[i].problem_prsnl[j].problem_prsnl_name = oreply->person[1].problem[i].
      problem_prsnl[j].problem_prsnl_name
      SET resp->problem[i].problem_prsnl[j].problem_reltn_cd = cnvtstring(oreply->person[1].problem[i
       ].problem_prsnl[j].problem_reltn_cd)
      SET resp->problem[i].problem_prsnl[j].problem_reltn_disp = uar_get_code_display(oreply->person[
       1].problem[i].problem_prsnl[j].problem_reltn_cd)
      SET resp->problem[i].problem_prsnl[j].problem_reltn_mean = uar_get_code_meaning(oreply->person[
       1].problem[i].problem_prsnl[j].problem_reltn_cd)
      SET resp->problem[i].problem_prsnl[j].problem_reltn_dt_tm = datetimezoneformat(oreply->person[1
       ].problem[i].problem_prsnl[j].problem_reltn_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
       curtimezonedef)
      SET resp->problem[i].problem_prsnl[j].beg_effective_dt_tm = datetimezoneformat(oreply->person[1
       ].problem[i].problem_prsnl[j].beg_effective_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
       curtimezonedef)
      SET resp->problem[i].problem_prsnl[j].end_effective_dt_tm = datetimezoneformat(oreply->person[1
       ].problem[i].problem_prsnl[j].end_effective_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
       curtimezonedef)
    ENDFOR
    SET resp->problem[i].comment_qual = cnvtstring(oreply->person[1].problem[i].comment_qual)
    SET stat = alterlist(resp->problem[i].problem_comment,size(oreply->person[1].problem[i].
      problem_comment,5))
    FOR (j = 1 TO size(oreply->person[1].problem[i].problem_comment,5))
      SET resp->problem[i].problem_comment[j].problem_id = cnvtstring(oreply->person[1].problem[i].
       problem_id)
      SET resp->problem[i].problem_comment[j].problem_comment_id = cnvtstring(oreply->person[1].
       problem[i].problem_comment[j].problem_comment_id)
      SET resp->problem[i].problem_comment[j].comment_prsnl_id = cnvtstring(oreply->person[1].
       problem[i].problem_comment[j].comment_prsnl_id)
      SET resp->problem[i].problem_comment[j].name_full_formatted = oreply->person[1].problem[i].
      problem_comment[j].name_full_formatted
      SET resp->problem[i].problem_comment[j].problem_comment = oreply->person[1].problem[i].
      problem_comment[j].problem_comment
      SET resp->problem[i].problem_comment[j].comment_dt_tm = datetimezoneformat(oreply->person[1].
       problem[i].problem_comment[j].comment_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
       curtimezonedef)
      SET resp->problem[i].problem_comment[j].data_status_cd = cnvtstring(oreply->person[1].problem[i
       ].problem_comment[j].data_status_cd)
      SET resp->problem[i].problem_comment[j].data_status_prsnl_id = cnvtstring(oreply->person[1].
       problem[i].problem_comment[j].data_status_prsnl_id)
      SET resp->problem[i].problem_comment[j].data_status_dt_tm = datetimezoneformat(oreply->person[1
       ].problem[i].problem_comment[j].data_status_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
       curtimezonedef)
      SET resp->problem[i].problem_comment[j].beg_effective_dt_tm = datetimezoneformat(oreply->
       person[1].problem[i].problem_comment[j].beg_effective_dt_tm,curtimezonesys,
       "yyyy-MM-dd HH:mm:ss",curtimezonedef)
      SET resp->problem[i].problem_comment[j].end_effective_dt_tm = datetimezoneformat(oreply->
       person[1].problem[i].problem_comment[j].end_effective_dt_tm,curtimezonesys,
       "yyyy-MM-dd HH:mm:ss",curtimezonedef)
    ENDFOR
  ENDFOR
 ENDIF
 IF (validate(_memory_reply_string))
  SET _memory_reply_string = cnvtrectojson(resp)
 ELSE
  CALL echojson(resp, $1)
 ENDIF
 FREE RECORD resp
END GO
