CREATE PROGRAM dcp_upd_normalcy_values:dba
 DECLARE updatenormalcyvalues(null) = null
 DECLARE normal_var = f8 WITH constant(uar_get_code_by("MEANING",52,"NORMAL")), protect
 DECLARE low_var = f8 WITH constant(uar_get_code_by("MEANING",52,"LOW")), protect
 DECLARE high_var = f8 WITH constant(uar_get_code_by("MEANING",52,"HIGH")), protect
 DECLARE critical_var = f8 WITH constant(uar_get_code_by("MEANING",52,"CRITICAL")), protect
 DECLARE failed = i2 WITH noconstant(0)
 DECLARE error_msg = vc
 DECLARE task_assay_cd = f8 WITH noconstant(0.0)
 DECLARE bmi_percentile = f8 WITH noconstant(0.0)
 DECLARE normal_low = c20
 DECLARE normal_high = c20
 DECLARE critical_low = c20
 DECLARE critical_high = c20
 DECLARE normalcy_cd = f8 WITH noconstant(normal_var)
 IF (link_clineventid <= 0)
  SET failed = 1
  SET error_msg = "Error retrieving clinical event id from trigger."
  GO TO exit_script
 ENDIF
 CALL updatenormalcyvalues(null)
 GO TO exit_script
 SUBROUTINE updatenormalcyvalues(null)
   SELECT INTO "nl:"
    FROM clinical_event ce,
     discrete_task_assay dta
    PLAN (ce
     WHERE ce.clinical_event_id=link_clineventid
      AND ce.event_cd != 0.0)
     JOIN (dta
     WHERE ce.event_cd=dta.event_cd
      AND dta.active_ind=1)
    DETAIL
     IF (dta.task_assay_cd=0.0)
      failed = 1
     ELSE
      task_assay_cd = dta.task_assay_cd
     ENDIF
     bmi_percentile = cnvtreal(ce.result_val)
    WITH nocounter
   ;end select
   IF (((failed=1) OR (curqual=0)) )
    SET error_msg = "Error retrieving Discrete Task Assay code."
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM reference_range_factor rrf
    WHERE rrf.task_assay_cd=task_assay_cd
     AND rrf.active_ind=1
    DETAIL
     normal_high = cnvtupper(cnvtstring(rrf.normal_high)), normal_low = cnvtupper(cnvtstring(rrf
       .normal_low)), critical_high = cnvtupper(cnvtstring(rrf.critical_high)),
     critical_low = cnvtupper(cnvtstring(rrf.critical_low))
     IF (rrf.normal_high != 0.0
      AND bmi_percentile >= rrf.normal_high)
      normalcy_cd = high_var
     ENDIF
     IF (rrf.normal_low != 0.0
      AND bmi_percentile <= rrf.normal_low)
      normalcy_cd = low_var
     ENDIF
     IF (((rrf.critical_low != 0.0
      AND bmi_percentile <= rrf.critical_low) OR (rrf.critical_high != 0.0
      AND bmi_percentile >= rrf.critical_high)) )
      normalcy_cd = critical_var
     ENDIF
    WITH nocounter
   ;end select
   IF (((failed=1) OR (curqual=0)) )
    SET error_msg = "Error retrieving normalcy values."
    GO TO exit_script
   ENDIF
   UPDATE  FROM clinical_event ce
    SET ce.normal_high = normal_high, ce.normal_low = normal_low, ce.critical_high = critical_high,
     ce.critical_low = critical_low, ce.normalcy_cd = normalcy_cd, ce.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     ce.updt_applctx = reqinfo->updt_applctx, ce.updt_id = reqinfo->updt_id, ce.updt_cnt = (ce
     .updt_cnt+ 1),
     ce.updt_task = reqinfo->updt_task
    WHERE ce.clinical_event_id=link_clineventid
    WITH nocounter
   ;end update
   IF (error(error_msg,0) != 0)
    SET failed = 1
    GO TO exit_script
   ENDIF
   COMMIT
 END ;Subroutine
#exit_script
 SET log_misc1 = concat("normal_high: ",trim(cnvtstring(normal_high,4))," normal_low: ",trim(
   cnvtstring(normal_low,4))," critical_high: ",
  trim(cnvtstring(critical_high,4))," critical_low: ",trim(cnvtstring(critical_low,4)),
  " normalcy_cd: ",trim(cnvtstring(normalcy_cd,4)))
 CALL echo(build("Normalcy Values: ",log_misc1))
 IF (failed=1)
  SET retval = 0
  SET log_message = error_msg
 ELSE
  SET retval = 100
  SET log_message = "Normalcy values updated successfully."
 ENDIF
END GO
