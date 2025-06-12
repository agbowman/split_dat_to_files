CREATE PROGRAM bhs_prax_read_problem_list
 DECLARE per_id = f8 WITH constant( $2)
 SELECT INTO  $1
  p_problem_id = cnvtint(p.problem_id), p_person_id = cnvtint(p.person_id), n_concept_identifier = n
  .concept_identifier,
  n_concept_source_cd = cnvtint(n.concept_source_cd), n_concept_source_disp = trim(replace(replace(
     replace(replace(replace(uar_get_code_display(n.concept_source_cd),"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), n_concept_source_mean = trim(replace(replace(
     replace(replace(replace(uar_get_code_meaning(n.concept_source_cd),"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  n_mnemonic = trim(replace(replace(replace(replace(replace(n.mnemonic,"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), n_nomenclature_id = cnvtint(n.nomenclature_id
   ), n_principle_type_cd = cnvtint(n.principle_type_cd),
  n_principle_type_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(n
         .principle_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), n_principle_type_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(
         n.principle_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), n_short_string = trim(replace(replace(replace(replace(replace(n.short_string,"&","&amp;",0
        ),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  n_source_identifier = trim(replace(replace(replace(replace(replace(n.source_identifier,"&","&amp;",
        0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), n_source_string = trim(
   replace(replace(replace(replace(replace(n.source_string,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
     "'","&apos;",0),'"',"&quot;",0),3), n_source_vocabulary_cd = cnvtint(n.source_vocabulary_cd),
  n_source_vocabulary_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(n
         .source_vocabulary_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), n_source_vocabulary_mean = trim(replace(replace(replace(replace(replace(
        uar_get_code_meaning(n.source_vocabulary_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), n_vocab_axis_cd = cnvtint(n.vocab_axis_cd),
  n_vocab_axis_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(n
         .vocab_axis_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
   ), n_vocab_axis_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(n
         .vocab_axis_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
   ), p_problem_ftdesc = trim(replace(replace(replace(replace(replace(p.problem_ftdesc,"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_estimated_resolution_dt_tm = format(p.estimated_resolution_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  p_actual_resolution_dt_tm = format(p.actual_resolution_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  p_classification_cd = cnvtint(p.classification_cd),
  p_classification_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(p
         .classification_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), p_classification_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(
         p.classification_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), p_persistence_cd = cnvtint(p.persistence_cd),
  p_confirmation_status_cd = cnvtint(p.confirmation_status_cd), p_persistence_disp = trim(replace(
    replace(replace(replace(replace(uar_get_code_display(p.persistence_cd),"&","&amp;",0),"<","&lt;",
       0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), p_persistence_mean = trim(replace(replace
    (replace(replace(replace(uar_get_code_meaning(p.persistence_cd),"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_confirmation_status_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(p
         .confirmation_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), p_confirmation_status_mean = trim(replace(replace(replace(replace(replace(
        uar_get_code_meaning(p.confirmation_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), p_life_cycle_status_cd = cnvtint(p.life_cycle_status_cd),
  p_life_cycle_status_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(p
         .life_cycle_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), p_life_cycle_status_mean = trim(replace(replace(replace(replace(replace(
        uar_get_code_meaning(p.life_cycle_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), p_life_cycle_dt_tm = format(p.life_cycle_dt_tm,
   "YYYY-MM-DD HH:MM:SS;;D"),
  p_onset_dt_tm = format(p.onset_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"), p_onset_dt_flag = p.onset_dt_flag,
  p_annotated_display = trim(replace(replace(replace(replace(replace(p.annotated_display,"&","&amp;",
        0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_ranking_cd = cnvtint(p.ranking_cd), p_ranking_disp = trim(replace(replace(replace(replace(replace
       (uar_get_code_display(p.ranking_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
    '"',"&quot;",0),3), p_ranking_mean = trim(replace(replace(replace(replace(replace(
        uar_get_code_meaning(p.ranking_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
    '"',"&quot;",0),3),
  p_certainty_cd = cnvtint(p.certainty_cd), p_certainty_disp = trim(replace(replace(replace(replace(
       replace(uar_get_code_display(p.certainty_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), p_certainty_mean = trim(replace(replace(replace(replace(replace(
        uar_get_code_meaning(p.certainty_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
     0),'"',"&quot;",0),3),
  p_probability = p.probability, p_person_aware_cd = cnvtint(p.person_aware_cd), p_person_aware_disp
   = trim(replace(replace(replace(replace(replace(uar_get_code_display(p.person_aware_cd),"&","&amp;",
        0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_person_aware_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(p
         .person_aware_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3), p_prognosis_cd = cnvtint(p.prognosis_cd), p_prognosis_disp = trim(replace(replace(replace(
      replace(replace(uar_get_code_display(p.prognosis_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
     "'","&apos;",0),'"',"&quot;",0),3),
  p_prognosis_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(p.prognosis_cd
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_person_aware_prognosis_cd = cnvtint(p.person_aware_prognosis_cd), p_person_aware_prognosis_disp
   = trim(replace(replace(replace(replace(replace(uar_get_code_display(p.person_aware_prognosis_cd),
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_person_aware_prognosis_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(p
         .person_aware_prognosis_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), p_family_aware_cd = cnvtint(p.family_aware_cd), p_family_aware_disp = trim(
   replace(replace(replace(replace(replace(uar_get_code_display(p.family_aware_cd),"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_family_aware_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(p
         .family_aware_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3), p_sensitivity = p.sensitivity, p_course_cd = cnvtint(p.course_cd),
  p_course_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(p.course_cd),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), p_course_mean =
  trim(replace(replace(replace(replace(replace(uar_get_code_meaning(p.course_cd),"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), p_cancel_reason_cd = cnvtint(p
   .cancel_reason_cd),
  p_cancel_reason_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(p
         .cancel_reason_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3), p_cancel_reason_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(p
         .cancel_reason_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3), p_updt_id = cnvtint(p.updt_id),
  prup_full_name = trim(replace(replace(replace(replace(replace(prup.name_full_formatted,"&","&amp;",
        0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), p_updt_dt_tm = format(p
   .updt_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"), p_beg_effective_dt_tm = format(p.beg_effective_dt_tm,
   "YYYY-MM-DD HH:MM:SS;;D"),
  p_beg_effective_tz = substring(21,3,datetimezoneformat(p.beg_effective_dt_tm,p.beg_effective_tz,
    "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), p_end_effective_dt_tm = format(p.end_effective_dt_tm,
   "YYYY-MM-DD HH:MM:SS;;D"), pc_problem_id = cnvtint(pc.problem_id),
  pc_problem_comment_id = cnvtint(pc.problem_comment_id), pc_comment_dt_tm = format(pc.comment_dt_tm,
   "YYYY-MM-DD HH:MM:SS;;D"), pc_comment_tz = substring(21,3,datetimezoneformat(pc.comment_dt_tm,pc
    .comment_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)),
  pc_comment_prsnl_id = cnvtint(pc.comment_prsnl_id), pcpr_full_name = trim(replace(replace(replace(
      replace(replace(pcpr.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), pc_problem_comment = trim(replace(replace(replace(replace(
       replace(pc.problem_comment,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3),
  pc_beg_effective_dt_tm = format(pc.beg_effective_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  pc_beg_effective_tz = substring(21,3,datetimezoneformat(pc.beg_effective_dt_tm,pc.beg_effective_tz,
    "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), pc_end_effective_dt_tm = format(pc
   .end_effective_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  ppr_problem_id = cnvtint(ppr.problem_id), ppr_problem_prsnl_id = cnvtint(ppr.problem_prsnl_id),
  ppr_problem_reltn_dt_tm = format(ppr.problem_reltn_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  ppr_problem_reltn_prsnl_id = cnvtint(ppr.problem_reltn_prsnl_id), ppr_pr_full_name = trim(replace(
    replace(replace(replace(replace(ppr_pr.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), ppr_problem_reltn_cd = cnvtint(ppr
   .problem_reltn_cd),
  ppr_problem_reltn_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(ppr
         .problem_reltn_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3), ppr_problem_reltn_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(
         ppr.problem_reltn_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), ppr_beg_effective_dt_tm = format(ppr.beg_effective_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"
   ),
  ppr_end_effective_dt_tm = format(ppr.end_effective_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  ppr_r_problem_id = cnvtint(ppr_r.problem_id), ppr_r_problem_prsnl_id = cnvtint(ppr_r
   .problem_prsnl_id),
  ppr_r_problem_reltn_dt_tm = format(ppr_r.problem_reltn_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  ppr_r_problem_reltn_prsnl_id = cnvtint(ppr_r.problem_reltn_prsnl_id), ppr_pr_r_full_name = trim(
   replace(replace(replace(replace(replace(ppr_pr_r.name_full_formatted,"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  ppr_r_problem_reltn_cd = cnvtint(ppr_r.problem_reltn_cd), ppr_r_problem_reltn_disp = trim(replace(
    replace(replace(replace(replace(uar_get_code_display(ppr_r.problem_reltn_cd),"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), ppr_r_problem_reltn_mean = trim(
   replace(replace(replace(replace(replace(uar_get_code_meaning(ppr_r.problem_reltn_cd),"&","&amp;",0
        ),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  ppr_r_beg_effective_dt_tm = format(ppr_r.beg_effective_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  ppr_r_end_effective_dt_tm = format(ppr_r.end_effective_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  p_onset_dt_cd = cnvtint(p.onset_dt_cd),
  p_onset_dt_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(p.onset_dt_cd),
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_onset_dt_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(p.onset_dt_cd),
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_life_cycle_dt_cd = cnvtint(p.life_cycle_dt_cd),
  p_life_cycle_dt_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(p
         .life_cycle_dt_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3), p_life_cycle_dt_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(p
         .life_cycle_dt_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3), p_qualifier_cd = cnvtint(p.qualifier_cd),
  p_qualifier_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(p.qualifier_cd
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_qualifier_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(p.qualifier_cd
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_severity_class_cd = cnvtint(p.severity_class_cd),
  p_severity_class_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(p
         .severity_class_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), p_severity_class_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(
         p.severity_class_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), p_severity_cd = cnvtint(p.severity_cd),
  p_severity_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(p.severity_cd),
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_severity_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(p.severity_cd),
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_status_updt_precision_cd = cnvtint(p.status_updt_precision_cd),
  p_status_updt_precision_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(p
         .status_updt_precision_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), p_status_updt_precision_mean = trim(replace(replace(replace(replace(replace(
        uar_get_code_meaning(p.status_updt_precision_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
     "'","&apos;",0),'"',"&quot;",0),3), p_status_updt_dt_tm = format(p.status_updt_dt_tm,
   "YYYY-MM-DD HH:MM:SS;;D"),
  p_life_cycle_dt_flag = p.life_cycle_dt_flag, p_status_updt_flag = p.status_updt_flag,
  p_show_in_pm_history_ind = p.show_in_pm_history_ind,
  p_problem_instance_id = cnvtint(p.problem_instance_id)
  FROM problem p,
   nomenclature n,
   problem_comment pc,
   prsnl prup,
   prsnl pcpr,
   problem_prsnl_r ppr,
   prsnl ppr_pr,
   problem_prsnl_r ppr_r,
   prsnl ppr_pr_r
  PLAN (p
   WHERE p.active_ind=1
    AND p.person_id=per_id)
   JOIN (n
   WHERE p.nomenclature_id=n.nomenclature_id)
   JOIN (pc
   WHERE pc.problem_id=outerjoin(p.problem_id))
   JOIN (prup
   WHERE prup.person_id=p.updt_id)
   JOIN (pcpr
   WHERE pcpr.person_id=outerjoin(pc.comment_prsnl_id))
   JOIN (ppr
   WHERE ppr.problem_id=outerjoin(p.problem_id)
    AND ppr.problem_reltn_cd=outerjoin(3322))
   JOIN (ppr_pr
   WHERE ppr_pr.person_id=outerjoin(ppr.problem_reltn_prsnl_id))
   JOIN (ppr_r
   WHERE ppr_r.problem_id=outerjoin(p.problem_id)
    AND ppr_r.problem_reltn_cd=outerjoin(3321))
   JOIN (ppr_pr_r
   WHERE ppr_pr_r.person_id=outerjoin(ppr_r.problem_reltn_prsnl_id))
  ORDER BY p.problem_id
  HEAD REPORT
   html_tag = build("<?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1, col + 1, "<Problems>",
   row + 1
  HEAD p.problem_id
   col + 1, "<Problem>", row + 1,
   p_per_id = build("<PersonId>",p_person_id,"</PersonId>"), col + 1, p_per_id,
   row + 1, p_prob_id = build("<ProblemId>",p_problem_id,"</ProblemId>"), col + 1,
   p_prob_id, row + 1, p_prob_in_id = build("<ProblemInstanceId>",p_problem_instance_id,
    "</ProblemInstanceId>"),
   col + 1, p_prob_in_id, row + 1,
   col + 1, "<Nomenclature>", row + 1,
   n_nom_id = build("<NomenclatureId>",n_nomenclature_id,"</NomenclatureId>"), col + 1, n_nom_id,
   row + 1, n_src_iden = build("<SourceIdentifier>",n_source_identifier,"</SourceIdentifier>"), col
    + 1,
   n_src_iden, row + 1, n_con_iden = build("<ConceptIdentifier>",n_concept_identifier,
    "</ConceptIdentifier>"),
   col + 1, n_con_iden, row + 1,
   n_src_str = build("<SourceString>",n_source_string,"</SourceString>"), col + 1, n_src_str,
   row + 1, prob_id = build("<Mnemonic>",n_mnemonic,"</Mnemonic>"), col + 1,
   prob_id, row + 1, prob_id = build("<ShortString>",n_short_string,"</ShortString>"),
   col + 1, prob_id, row + 1
   IF (n_concept_source_cd != 0)
    col + 1, "<ConceptSource>", row + 1,
    n_con_src_d = build("<Display>",n_concept_source_disp,"</Display>"), col + 1, n_con_src_d,
    row + 1, n_con_src_m = build("<Meaning>",n_concept_source_mean,"</Meaning>"), col + 1,
    n_con_src_m, row + 1, n_con_src_v = build("<Value>",n_concept_source_cd,"</Value>"),
    col + 1, n_con_src_v, row + 1,
    col + 1, "</ConceptSource>", row + 1
   ENDIF
   IF (n_principle_type_cd != 0)
    col + 1, "<PrincipleType>", row + 1,
    n_pr_typ_d = build("<Display>",n_principle_type_disp,"</Display>"), col + 1, n_pr_typ_d,
    row + 1, n_pr_typ_m = build("<Meaning>",n_principle_type_mean,"</Meaning>"), col + 1,
    n_pr_typ_m, row + 1, n_pr_typ_v = build("<Value>",n_principle_type_cd,"</Value>"),
    col + 1, n_pr_typ_v, row + 1,
    col + 1, "</PrincipleType>", row + 1
   ENDIF
   IF (n_source_vocabulary_cd != 0)
    col + 1, "<SourceVocabulary>", row + 1,
    n_src_vocab_d = build("<Display>",n_source_vocabulary_disp,"</Display>"), col + 1, n_src_vocab_d,
    row + 1, n_src_vocab_m = build("<Meaning>",n_source_vocabulary_mean,"</Meaning>"), col + 1,
    n_src_vocab_m, row + 1, n_src_vocab_v = build("<Value>",n_source_vocabulary_cd,"</Value>"),
    col + 1, n_src_vocab_v, row + 1,
    col + 1, "</SourceVocabulary>", row + 1
   ENDIF
   IF (n_vocab_axis_cd != 0)
    col + 1, "<VocabularyAxis>", row + 1,
    n_vocab_ax_d = build("<Display>",n_vocab_axis_disp,"</Display>"), col + 1, n_vocab_ax_d,
    row + 1, n_vocab_ax_m = build("<Meaning>",n_vocab_axis_mean,"</Meaning>"), col + 1,
    n_vocab_ax_m, row + 1, n_vocab_ax_v = build("<Value>",n_vocab_axis_cd,"</Value>"),
    col + 1, n_vocab_ax_v, row + 1,
    col + 1, "</VocabularyAxis>", row + 1
   ENDIF
   col + 1, "</Nomenclature>", row + 1
   IF (n_source_vocabulary_cd != 0)
    col + 1, "<SourceVocabulary>", row + 1,
    p_src_vocab_d = build("<Display>",n_source_vocabulary_disp,"</Display>"), col + 1, p_src_vocab_d,
    row + 1, p_src_vocab_m = build("<Meaning>",n_source_vocabulary_mean,"</Meaning>"), col + 1,
    p_src_vocab_m, row + 1, p_src_vocab_v = build("<Value>",n_source_vocabulary_cd,"</Value>"),
    col + 1, p_src_vocab_v, row + 1,
    col + 1, "</SourceVocabulary>", row + 1
   ENDIF
   p_ft_desc = build("<ProblemFreeTextDescription>",p_problem_ftdesc,"</ProblemFreeTextDescription>"),
   col + 1, p_ft_desc,
   row + 1, p_est_res_dt = build("<EstimatedResolutionDateTime>",p_estimated_resolution_dt_tm,
    "</EstimatedResolutionDateTime>"), col + 1,
   p_est_res_dt, row + 1, p_act_res_dt = build("<ActualResolutionDateTime>",p_actual_resolution_dt_tm,
    "</ActualResolutionDateTime>"),
   col + 1, p_act_res_dt, row + 1
   IF (p_classification_cd != 0)
    col + 1, "<Classification>", row + 1,
    p_class_d = build("<Display>",p_classification_disp,"</Display>"), col + 1, p_class_d,
    row + 1, p_class_m = build("<Meaning>",p_classification_mean,"</Meaning>"), col + 1,
    p_class_m, row + 1, p_class_v = build("<Value>",p_classification_cd,"</Value>"),
    col + 1, p_class_v, row + 1,
    col + 1, "</Classification>", row + 1
   ENDIF
   IF (p_persistence_cd != 0)
    col + 1, "<Persistence>", row + 1,
    p_pers_d = build("<Display>",p_persistence_disp,"</Display>"), col + 1, p_pers_d,
    row + 1, p_pers_m = build("<Meaning>",p_persistence_mean,"</Meaning>"), col + 1,
    p_pers_m, row + 1, p_pers_v = build("<Value>",p_persistence_cd,"</Value>"),
    col + 1, p_pers_v, row + 1,
    col + 1, "</Persistence>", row + 1
   ENDIF
   IF (p_confirmation_status_cd != 0)
    col + 1, "<ConfirmationStatus>", row + 1,
    p_conf_st_d = build("<Display>",p_confirmation_status_disp,"</Display>"), col + 1, p_conf_st_d,
    row + 1, p_conf_st_m = build("<Meaning>",p_confirmation_status_mean,"</Meaning>"), col + 1,
    p_conf_st_m, row + 1, p_conf_st_v = build("<Value>",p_confirmation_status_cd,"</Value>"),
    col + 1, p_conf_st_v, row + 1,
    col + 1, "</ConfirmationStatus>", row + 1
   ENDIF
   IF (p_life_cycle_status_cd != 0)
    col + 1, "<LifeCycleStatus>", row + 1,
    p_lyf_cycl_d = build("<Display>",p_life_cycle_status_disp,"</Display>"), col + 1, p_lyf_cycl_d,
    row + 1, p_lyf_cycl_m = build("<Meaning>",p_life_cycle_status_mean,"</Meaning>"), col + 1,
    p_lyf_cycl_m, row + 1, p_lyf_cycl_v = build("<Value>",p_life_cycle_status_cd,"</Value>"),
    col + 1, p_lyf_cycl_v, row + 1,
    col + 1, "</LifeCycleStatus>", row + 1
   ENDIF
   p_lyf_cycl_dt = build("<LifeCycleDateTime>",p_life_cycle_dt_tm,"</LifeCycleDateTime>"), col + 1,
   p_lyf_cycl_dt,
   row + 1, p_onset_dt = build("<OnsetDateTime>",p_onset_dt_tm,"</OnsetDateTime>"), col + 1,
   p_onset_dt, row + 1, p_onset_dt_flg = build("<OnsetDateTimeFlag>",p_onset_dt_flag,
    "</OnsetDateTimeFlag>"),
   col + 1, p_onset_dt_flg, row + 1
   IF (p_ranking_cd != 0)
    col + 1, "<Ranking>", row + 1,
    p_rnk_d = build("<Display>",p_ranking_disp,"</Display>"), col + 1, p_rnk_d,
    row + 1, p_rnk_m = build("<Meaning>",p_ranking_mean,"</Meaning>"), col + 1,
    p_rnk_m, row + 1, p_rnk_v = build("<Value>",p_ranking_cd,"</Value>"),
    col + 1, p_rnk_v, row + 1,
    col + 1, "</Ranking>", row + 1
   ENDIF
   IF (p_certainty_cd != 0)
    col + 1, "<Certainty>", row + 1,
    p_cert_d = build("<Display>",p_certainty_disp,"</Display>"), col + 1, p_cert_d,
    row + 1, p_cert_m = build("<Meaning>",p_certainty_mean,"</Meaning>"), col + 1,
    p_cert_m, row + 1, p_cert_v = build("<Value>",p_certainty_cd,"</Value>"),
    col + 1, p_cert_v, row + 1,
    col + 1, "</Certainty>", row + 1
   ENDIF
   p_probabilty = build("<Probability>",p_probability,"</Probability>"), col + 1, p_probabilty,
   row + 1
   IF (p_person_aware_cd != 0)
    col + 1, "<PersonAwareness>", row + 1,
    p_per_aw_d = build("<Display>",p_person_aware_disp,"</Display>"), col + 1, p_per_aw_d,
    row + 1, p_per_aw_m = build("<Meaning>",p_person_aware_mean,"</Meaning>"), col + 1,
    p_per_aw_m, row + 1, p_per_aw_v = build("<Value>",p_person_aware_cd,"</Value>"),
    col + 1, p_per_aw_v, row + 1,
    col + 1, "</PersonAwareness>", row + 1
   ENDIF
   IF (p_prognosis_cd != 0)
    col + 1, "<Prognosis>", row + 1,
    p_prog_d = build("<Display>",p_prognosis_disp,"</Display>"), col + 1, p_prog_d,
    row + 1, p_prog_m = build("<Meaning>",p_prognosis_mean,"</Meaning>"), col + 1,
    p_prog_m, row + 1, p_prog_v = build("<Value>",p_prognosis_cd,"</Value>"),
    col + 1, p_prog_v, row + 1,
    col + 1, "</Prognosis>", row + 1
   ENDIF
   IF (p_person_aware_prognosis_cd != 0)
    col + 1, "<PersonAwarePrognosis>", row + 1,
    p_per_aw_prog_d = build("<Display>",p_person_aware_prognosis_disp,"</Display>"), col + 1,
    p_per_aw_prog_d,
    row + 1, p_per_aw_prog_m = build("<Meaning>",p_person_aware_prognosis_mean,"</Meaning>"), col + 1,
    p_per_aw_prog_m, row + 1, p_per_aw_prog_v = build("<Value>",p_person_aware_prognosis_cd,
     "</Value>"),
    col + 1, p_per_aw_prog_v, row + 1,
    col + 1, "</PersonAwarePrognosis>", row + 1
   ENDIF
   IF (p_family_aware_cd != 0)
    col + 1, "<FamilyAware>", row + 1,
    p_fam_aw_d = build("<Display>",p_family_aware_disp,"</Display>"), col + 1, p_fam_aw_d,
    row + 1, p_fam_aw_m = build("<Meaning>",p_family_aware_mean,"</Meaning>"), col + 1,
    p_fam_aw_m, row + 1, p_fam_aw_v = build("<Value>",p_family_aware_cd,"</Value>"),
    col + 1, p_fam_aw_v, row + 1,
    col + 1, "</FamilyAware>", row + 1
   ENDIF
   p_sens = build("<Sensitivity>",p_sensitivity,"</Sensitivity>"), col + 1, p_sens,
   row + 1
   IF (p_course_cd != 0)
    col + 1, "<Course>", row + 1,
    p_course_d = build("<Display>",p_course_disp,"</Display>"), col + 1, p_course_d,
    row + 1, p_course_m = build("<Meaning>",p_course_mean,"</Meaning>"), col + 1,
    p_course_m, row + 1, p_course_v = build("<Value>",p_course_cd,"</Value>"),
    col + 1, p_course_v, row + 1,
    col + 1, "</Course>", row + 1
   ENDIF
   IF (p_cancel_reason_cd != 0)
    col + 1, "<CancelReason>", row + 1,
    p_can_res_d = build("<Display>",p_cancel_reason_disp,"</Display>"), col + 1, p_can_res_d,
    row + 1, p_can_res_m = build("<Meaning>",p_cancel_reason_mean,"</Meaning>"), col + 1,
    p_can_res_m, row + 1, p_can_res_v = build("<Value>",p_cancel_reason_cd,"</Value>"),
    col + 1, p_can_res_v, row + 1,
    col + 1, "</CancelReason>", row + 1
   ENDIF
   IF (p_onset_dt_cd != 0)
    col + 1, "<OnsetDateCode>", row + 1,
    p_onset_d = build("<Display>",p_onset_dt_disp,"</Display>"), col + 1, p_onset_d,
    row + 1, p_onset_m = build("<Meaning>",p_onset_dt_mean,"</Meaning>"), col + 1,
    p_onset_m, row + 1, p_onset_v = build("<Value>",p_onset_dt_cd,"</Value>"),
    col + 1, p_onset_v, row + 1,
    col + 1, "</OnsetDateCode>", row + 1
   ENDIF
   IF (p_life_cycle_dt_cd != 0)
    col + 1, "<LifeCycleDateCode>", row + 1,
    p_lyf_cd_d = build("<Display>",p_life_cycle_dt_disp,"</Display>"), col + 1, p_lyf_cd_d,
    row + 1, p_lyf_cd_m = build("<Meaning>",p_life_cycle_dt_mean,"</Meaning>"), col + 1,
    p_lyf_cd_m, row + 1, p_lyf_cd_v = build("<Value>",p_life_cycle_dt_cd,"</Value>"),
    col + 1, p_lyf_cd_v, row + 1,
    col + 1, "</LifeCycleDateCode>", row + 1
   ENDIF
   IF (p_qualifier_cd)
    col + 1, "<Qualifier>", row + 1,
    p_qua_d = build("<Display>",p_qualifier_disp,"</Display>"), col + 1, p_qua_d,
    row + 1, p_qua_m = build("<Meaning>",p_qualifier_mean,"</Meaning>"), col + 1,
    p_qua_m, row + 1, p_qua_v = build("<Value>",p_qualifier_cd,"</Value>"),
    col + 1, p_qua_v, row + 1,
    col + 1, "</Qualifier>", row + 1
   ENDIF
   IF (p_severity_class_cd != 0)
    col + 1, "<SeverityClass>", row + 1,
    p_sev_cls_d = build("<Display>",p_severity_class_disp,"</Display>"), col + 1, p_sev_cls_d,
    row + 1, p_sev_cls_m = build("<Meaning>",p_severity_class_mean,"</Meaning>"), col + 1,
    p_sev_cls_m, row + 1, p_sev_cls_v = build("<Value>",p_severity_class_cd,"</Value>"),
    col + 1, p_sev_cls_v, row + 1,
    col + 1, "</SeverityClass>", row + 1
   ENDIF
   IF (p_severity_cd != 0)
    col + 1, "<Severity>", row + 1,
    p_sev_d = build("<Display>",p_severity_disp,"</Display>"), col + 1, p_sev_d,
    row + 1, p_sev_m = build("<Meaning>",p_severity_mean,"</Meaning>"), col + 1,
    p_sev_m, row + 1, p_sev_v = build("<Value>",p_severity_cd,"</Value>"),
    col + 1, p_sev_v, row + 1,
    col + 1, "</Severity>", row + 1
   ENDIF
   IF (p_status_updt_precision_cd != 0)
    col + 1, "<StatusUpdatePrecision>", row + 1,
    p_pres_d = build("<Display>",p_status_updt_precision_disp,"</Display>"), col + 1, p_pres_d,
    row + 1, p_pres_m = build("<Meaning>",p_status_updt_precision_mean,"</Meaning>"), col + 1,
    p_pres_m, row + 1, p_pres_v = build("<Value>",p_status_updt_precision_cd,"</Value>"),
    col + 1, p_pres_v, row + 1,
    col + 1, "</StatusUpdatePrecision>", row + 1
   ENDIF
   p_st_up_dt = build("<StatusUpdateDateTime>",p_status_updt_dt_tm,"</StatusUpdateDateTime>"), col +
   1, p_st_up_dt,
   row + 1, p_st_up_fl = build("<StatusUpdateFlag>",p_status_updt_flag,"</StatusUpdateFlag>"), col +
   1,
   p_st_up_fl, row + 1, p_lyf_dt_fl = build("<LifeCycleDateFlag>",p_life_cycle_dt_flag,
    "</LifeCycleDateFlag>"),
   col + 1, p_lyf_dt_fl, row + 1,
   p_pm_hist_fl = build("<ShowInHistoryIndicator>",p_show_in_pm_history_ind,
    "</ShowInHistoryIndicator>"), col + 1, p_pm_hist_fl,
   row + 1, col + 1, "<UpdatePrsnl>",
   row + 1, prup_prsnl_name = build("<FullName>",prup_full_name,"</FullName>"), col + 1,
   prup_prsnl_name, row + 1, p_updt_prsnl_id = build("<PrsnlId>",p_updt_id,"</PrsnlId>"),
   col + 1, p_updt_prsnl_id, row + 1,
   col + 1, "</UpdatePrsnl>", row + 1,
   p_updt_dt = build("<UpdateDateTime>",p_updt_dt_tm,"</UpdateDateTime>"), col + 1, p_updt_dt,
   row + 1, p_beg_eff_dt = build("<BeginEffectiveDateTime>",p_beg_effective_dt_tm,
    "</BeginEffectiveDateTime>"), col + 1,
   p_beg_eff_dt, row + 1, p_end_eff_dt = build("<EndEffectiveDateTime>",p_end_effective_dt_tm,
    "</EndEffectiveDateTime>"),
   col + 1, p_end_eff_dt, row + 1,
   p_annot_disp = build("<AnnotatedDisplay>",p_annotated_display,"</AnnotatedDisplay>"), col + 1,
   p_annot_disp,
   row + 1
  HEAD pc.problem_comment_id
   col + 1, "<ProblemComments>", row + 1
  DETAIL
   IF (pc.problem_comment_id != 0)
    col + 1, "<ProblemComment>", row + 1,
    pc_prob_id = build("<ProblemId>",pc_problem_id,"</ProblemId>"), col + 1, pc_prob_id,
    row + 1, pc_cmnt_id = build("<ProblemCommentId>",pc_problem_comment_id,"</ProblemCommentId>"),
    col + 1,
    pc_cmnt_id, row + 1, pc_dt = build("<ProblemCommentId>",pc_comment_dt_tm,"</ProblemCommentId>"),
    col + 1, pc_dt, row + 1,
    col + 1, "<CommentPrsnl>", row + 1,
    pc_pr_fn = build("<FullName>",pcpr_full_name,"</FullName>"), col + 1, pc_pr_fn,
    row + 1, pc_pr_id = build("<PrsnlId>",pc_comment_prsnl_id,"</PrsnlId>"), col + 1,
    pc_pr_id, row + 1, col + 1,
    "</CommentPrsnl>", row + 1, pc_cmnt = build("<ProblemComment>",pc_problem_comment,
     "</ProblemComment>"),
    col + 1, pc_cmnt, row + 1,
    pc_beg_eff_dt = build("<BeginEffectiveDateTime>",pc_beg_effective_dt_tm,
     "</BeginEffectiveDateTime>"), col + 1, pc_beg_eff_dt,
    row + 1, pc_end_eff_dt = build("<EndEffectiveDateTime>",pc_end_effective_dt_tm,
     "</EndEffectiveDateTime>"), col + 1,
    pc_end_eff_dt, row + 1, col + 1,
    "</ProblemComment>", row + 1
   ENDIF
  FOOT  pc.problem_comment_id
   col + 1, "</ProblemComments>", row + 1,
   col + 1, "<ProblemPrsnlRelations>", row + 1
   IF (ppr.problem_reltn_prsnl_id != 0)
    col + 1, "<ProblemPrsnlRelation>", row + 1,
    ppr_prob_id = build("<ProblemId>",ppr_problem_id,"</ProblemId>"), col + 1, ppr_prob_id,
    row + 1, ppr_id = build("<ProblemPrsnlRelationId>",ppr_problem_prsnl_id,
     "</ProblemPrsnlRelationId>"), col + 1,
    ppr_id, row + 1, col + 1,
    "<ProblemRelationPrsnl>", row + 1, ppr_pr_prsnl_name = build("<FullName>",ppr_pr_full_name,
     "</FullName>"),
    col + 1, ppr_pr_prsnl_name, row + 1,
    ppr_prsnl_id = build("<PrsnlId>",ppr_problem_reltn_prsnl_id,"</PrsnlId>"), col + 1, ppr_prsnl_id,
    row + 1, col + 1, "</ProblemRelationPrsnl>",
    row + 1, col + 1, "<ProblemRelation>",
    row + 1, ppr_rel_d = build("<Display>",ppr_problem_reltn_disp,"</Display>"), col + 1,
    ppr_rel_d, row + 1, ppr_rel_m = build("<Meaning>",ppr_problem_reltn_mean,"</Meaning>"),
    col + 1, ppr_rel_m, row + 1,
    ppr_rel_v = build("<Value>",ppr_problem_reltn_cd,"</Value>"), col + 1, ppr_rel_v,
    row + 1, col + 1, "</ProblemRelation>",
    row + 1, ppr_beg_eff_dt = build("<BeginEffectiveDateTime>",ppr_beg_effective_dt_tm,
     "</BeginEffectiveDateTime>"), col + 1,
    ppr_beg_eff_dt, row + 1, ppr_end_eff_dt = build("<EndEffectiveDateTime>",ppr_end_effective_dt_tm,
     "</EndEffectiveDateTime>"),
    col + 1, ppr_end_eff_dt, row + 1,
    col + 1, "</ProblemPrsnlRelation>", row + 1
   ENDIF
   IF (ppr_r.problem_reltn_prsnl_id != 0)
    col + 1, "<ProblemPrsnlRelation>", row + 1,
    ppr_r_prob_id = build("<ProblemId>",ppr_r_problem_id,"</ProblemId>"), col + 1, ppr_r_prob_id,
    row + 1, ppr_r_id = build("<ProblemPrsnlRelationId>",ppr_r_problem_prsnl_id,
     "</ProblemPrsnlRelationId>"), col + 1,
    ppr_r_id, row + 1, col + 1,
    "<ProblemRelationPrsnl>", row + 1, ppr_r_pr_prsnl_name = build("<FullName>",ppr_pr_r_full_name,
     "</FullName>"),
    col + 1, ppr_r_pr_prsnl_name, row + 1,
    ppr_r_prsnl_id = build("<PrsnlId>",ppr_r_problem_reltn_prsnl_id,"</PrsnlId>"), col + 1,
    ppr_r_prsnl_id,
    row + 1, col + 1, "</ProblemRelationPrsnl>",
    row + 1, col + 1, "<ProblemRelation>",
    row + 1, ppr_r_rel_d = build("<Display>",ppr_r_problem_reltn_disp,"</Display>"), col + 1,
    ppr_r_rel_d, row + 1, ppr_r_rel_m = build("<Meaning>",ppr_r_problem_reltn_mean,"</Meaning>"),
    col + 1, ppr_r_rel_m, row + 1,
    ppr_r_rel_v = build("<Value>",ppr_r_problem_reltn_cd,"</Value>"), col + 1, ppr_r_rel_v,
    row + 1, col + 1, "</ProblemRelation>",
    row + 1, ppr_r_beg_eff_dt = build("<BeginEffectiveDateTime>",ppr_r_beg_effective_dt_tm,
     "</BeginEffectiveDateTime>"), col + 1,
    ppr_r_beg_eff_dt, row + 1, ppr_r_end_eff_dt = build("<EndEffectiveDateTime>",
     ppr_r_end_effective_dt_tm,"</EndEffectiveDateTime>"),
    col + 1, ppr_r_end_eff_dt, row + 1,
    col + 1, "</ProblemPrsnlRelation>", row + 1
   ENDIF
   col + 1, "</ProblemPrsnlRelations>", row + 1
  FOOT  p.problem_id
   col + 1, "</Problem>", row + 1
  FOOT REPORT
   col + 1, "</Problems>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 50000, format = variable, maxrow = 0,
   time = 30, append
 ;end select
 SELECT INTO  $1
  pd_problem_id = cnvtint(pd.problem_id), pd_problem_discipline_id = cnvtint(pd.problem_discipline_id
   ), pd_management_discipline_cd = cnvtint(pd.management_discipline_cd),
  pd_management_discipline_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(
         pd.management_discipline_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), pd_management_discipline_mean = trim(replace(replace(replace(replace(replace(
        uar_get_code_meaning(pd.management_discipline_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
     "'","&apos;",0),'"',"&quot;",0),3), pd_beg_effective_dt_tm = format(pd.beg_effective_dt_tm,
   "YYYY-MM-DD HH:MM:SS;;D"),
  pd_end_effective_dt_tm = format(pd.end_effective_dt_tm,"YYYY-MM-DD HH:MM:SS;;D")
  FROM problem p,
   problem_discipline pd
  PLAN (p
   WHERE p.active_ind=1
    AND p.person_id=per_id)
   JOIN (pd
   WHERE pd.problem_id=outerjoin(p.problem_id)
    AND pd.active_ind=1)
  ORDER BY p.problem_id
  HEAD REPORT
   col + 1, "<ProblemDisciplines>", row + 1
  HEAD pd.problem_discipline_id
   IF (pd_problem_discipline_id != 0)
    col + 1, "<ProblemDiscipline>", row + 1,
    pd_prob_id = build("<ProblemId>",pd_problem_id,"</ProblemId>"), col + 1, pd_prob_id,
    row + 1, pd_id = build("<ProblemDisciplineId>",pd_problem_discipline_id,"</ProblemDisciplineId>"),
    col + 1,
    pd_id, row + 1, col + 1,
    "<ManagementDiscipline>", row + 1, pd_mng_dis_d = build("<Display>",pd_management_discipline_disp,
     "</Display>"),
    col + 1, pd_mng_dis_d, row + 1,
    pd_mng_dis_m = build("<Meaning>",pd_management_discipline_mean,"</Meaning>"), col + 1,
    pd_mng_dis_m,
    row + 1, pd_mng_dis_v = build("<Value>",pd_management_discipline_cd,"</Value>"), col + 1,
    pd_mng_dis_v, row + 1, col + 1,
    "</ManagementDiscipline>", row + 1, pd_beg_eff_dt = build("<BeginEffectiveDateTime>",
     pd_beg_effective_dt_tm,"</BeginEffectiveDateTime>"),
    col + 1, pd_beg_eff_dt, row + 1,
    pd_end_eff_dt = build("<EndEffectiveDateTime>",pd_end_effective_dt_tm,"</EndEffectiveDateTime>"),
    col + 1, pd_end_eff_dt,
    row + 1, col + 1, "</ProblemDiscipline>",
    row + 1
   ENDIF
  FOOT REPORT
   col + 1, "</ProblemDisciplines>", row + 1,
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 50000, format = variable, maxrow = 0,
   time = 30, append
 ;end select
END GO
