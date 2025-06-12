CREATE PROGRAM bhs_eks_modified_labs_v2
 DECLARE final_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE oldresultdisp = vc
 DECLARE newresultdisp = vc
 DECLARE orig_date = vc
 DECLARE corrected_date = vc
 DECLARE procedure = vc
 DECLARE orig_result = vc
 DECLARE corrected_result = vc
 DECLARE pat_name = vc
 DECLARE display_line = vc
 SET eid = 0
 SET ce_id = link_clineventid
 SET retval = 0
 FOR (x = 1 TO size(request->clin_detail_list,5))
   IF ((request->clin_detail_list[x].result_status_cd=modified_cd))
    SELECT INTO "nl:"
     FROM clinical_event ce,
      clinical_event ce2,
      person p
     PLAN (ce
      WHERE (ce.clinical_event_id=request->clin_detail_list[x].clinical_event_id)
       AND ce.result_status_cd=modified_cd
       AND ce.view_level=1)
      JOIN (ce2
      WHERE ce2.parent_event_id=ce.parent_event_id
       AND ce2.result_status_cd=final_cd
       AND ce2.view_level=1)
      JOIN (p
      WHERE p.person_id=ce.person_id)
     HEAD REPORT
      oldresultdisp = "", newresultdisp = "", orig_date = "",
      corrected_date = "", procedure = "", orig_result = "",
      corrected_result = ""
     DETAIL
      eid = ce.encntr_id, oldresultdisp = concat(trim(uar_get_code_display(ce2.event_cd)),": ",trim(
        ce2.result_val)," ",trim(uar_get_code_display(ce2.result_units_cd)),
       " Resulted on ",format(ce2.clinsig_updt_dt_tm,"mm/dd/yyyy hh:mm;;q")), newresultdisp = concat(
       trim(uar_get_code_display(ce.event_cd)),": ",trim(ce.result_val)," ",trim(uar_get_code_display
        (ce.result_units_cd)),
       " Modified on ",format(ce.clinsig_updt_dt_tm,"mm/dd/yyyy hh:mm;;q")),
      orig_date = trim(format(ce2.clinsig_updt_dt_tm,"mm/dd/yyyy hh:mm;;q")), corrected_date = trim(
       format(ce.clinsig_updt_dt_tm,"mm/dd/yyyy hh:mm;;q")), procedure = trim(uar_get_code_display(ce
        .event_cd)),
      orig_result = concat(trim(ce2.result_val)," ",trim(uar_get_code_display(ce2.result_units_cd))),
      corrected_result = concat(trim(ce.result_val)," ",trim(uar_get_code_display(ce.result_units_cd)
        )), pat_name = trim(p.name_full_formatted)
     FOOT REPORT
      display_line = concat(trim(display_line)," The ",procedure," previously resulted as [",
       orig_result,
       "]"," on [",orig_date,"] for this patient was modified / updated to [",corrected_result,
       "]"," on [",corrected_date,"]."), retval = 100
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF (retval=100)
  SET log_misc1 = concat(
   "this notification is intended to alert you to a modification and /or update",
   " to a laboratory result for ",pat_name," because you are either the ordering",
   " or the attending physician or both.",
   trim(display_line),
   " For additional question please contact Laboratory on-call manager (Beeper: 4-5227)")
  SET log_message = concat(
   "this notification is intended to alert you to a modification and /or update",
   " to a laboratory result for ",pat_name," because you are either the ordering",
   " or the attending physician or both.",
   trim(display_line),
   " For additional question please contact Laboratory on-call manager (Beeper: 4-5227)")
 ENDIF
END GO
