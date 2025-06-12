CREATE PROGRAM bhs_athn_past_medical_hx
 FREE RECORD problem_procedure_hx
 RECORD problem_procedure_hx(
   1 person_id = f8
   1 problem_hx[*]
     2 problem_id = vc
     2 problem_name = vc
     2 annotated_display = vc
     2 onset_dt_tm = vc
     2 life_cycle_dt_tm = vc
     2 life_cycle_status = vc
     2 life_cycle_status_code = vc
     2 life_cycle_status_cd = vc
     2 code = vc
     2 vocabulary = vc
     2 comments[*]
       3 comment_dt_tm = vc
       3 comment_added_by = vc
       3 comment_description = vc
 )
 DECLARE vcnt = i4
 DECLARE ccnt = i4
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE primary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",12034,"PRIMARY"))
 DECLARE mpersonid = f8 WITH protect, constant( $2)
 SET problem_procedure_hx->person_id = mpersonid
 SELECT INTO "NL:"
  n.source_string, p.annotated_display, onset_dt_tm = format(p.onset_dt_tm,"MM/DD/YYYY HH:MM"),
  life_cycle_dt_tm = format(p.life_cycle_dt_tm,"MM/DD/YYYY HH:MM"), p_life_cycle_status_disp =
  uar_get_code_display(p.life_cycle_status_cd), p_life_cycle_status_mean = uar_get_code_meaning(p
   .life_cycle_status_cd),
  p_life_cycle_status_cd = p.life_cycle_status_cd, pc.problem_comment, comment_added_by = pr1
  .name_full_formatted,
  comment_dt_tm = format(pc.comment_dt_tm,"MM/DD/YYYY HH:MM"), n.source_identifier,
  n_source_vocabulary_disp = uar_get_code_display(n.source_vocabulary_cd)
  FROM problem p,
   nomenclature n,
   problem_comment pc,
   prsnl pr1
  PLAN (p
   WHERE p.person_id=mpersonid
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate
    AND p.show_in_pm_history_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
   JOIN (pc
   WHERE pc.problem_id=outerjoin(p.problem_id))
   JOIN (pr1
   WHERE pr1.person_id=outerjoin(pc.comment_prsnl_id))
  ORDER BY p.problem_id
  HEAD p.problem_id
   vcnt = (vcnt+ 1), stat = alterlist(problem_procedure_hx->problem_hx,vcnt), problem_procedure_hx->
   problem_hx[vcnt].problem_id = cnvtstring(p.problem_id),
   problem_procedure_hx->problem_hx[vcnt].life_cycle_status = p_life_cycle_status_disp,
   problem_procedure_hx->problem_hx[vcnt].life_cycle_status_code = p_life_cycle_status_mean,
   problem_procedure_hx->problem_hx[vcnt].life_cycle_status_cd = cnvtstring(p_life_cycle_status_cd),
   problem_procedure_hx->problem_hx[vcnt].life_cycle_dt_tm = life_cycle_dt_tm, problem_procedure_hx->
   problem_hx[vcnt].onset_dt_tm = onset_dt_tm, problem_procedure_hx->problem_hx[vcnt].
   annotated_display = p.annotated_display,
   problem_procedure_hx->problem_hx[vcnt].problem_name = n.source_string, problem_procedure_hx->
   problem_hx[vcnt].code = n.source_identifier, problem_procedure_hx->problem_hx[vcnt].vocabulary =
   n_source_vocabulary_disp,
   ccnt = 0
  DETAIL
   IF (pc.problem_comment_id != 0)
    ccnt = (ccnt+ 1), stat = alterlist(problem_procedure_hx->problem_hx[vcnt].comments,ccnt),
    problem_procedure_hx->problem_hx[vcnt].comments[ccnt].comment_added_by = comment_added_by,
    problem_procedure_hx->problem_hx[vcnt].comments[ccnt].comment_description = pc.problem_comment,
    problem_procedure_hx->problem_hx[vcnt].comments[ccnt].comment_dt_tm = comment_dt_tm
   ENDIF
  WITH nocounter, separator = " ", format,
   time = 30
 ;end select
 CALL echojson(problem_procedure_hx, $1)
END GO
