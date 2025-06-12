CREATE PROGRAM bhs_eks_eval_reg_hours:dba
 DECLARE mf_eid = f8 WITH noconstant(0), protect
 DECLARE mf_end_hours = f8 WITH noconstant(0), protect
 DECLARE mf_start_hours = f8 WITH noconstant(0), protect
 DECLARE mf_diff_hours = f8 WITH noconstant(0), protect
 SET mf_eid = trigger_encntrid
 SET retval = - (1)
 SET mf_start_hours = parameter(1,0)
 SET mf_end_hours = parameter(2,0)
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=mf_eid)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   mf_diff_hours = datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm,3)
  WITH nocounter
 ;end select
 IF (mf_diff_hours < 0)
  SET mf_diff_hours = 0
 ENDIF
 IF (mf_diff_hours BETWEEN mf_start_hours AND mf_end_hours)
  SET retval = 100
  SET log_message = build2("Success",format(mf_diff_hours,"####.##")," hour(s) range is between :",
   format(mf_start_hours,"##.#")," and ",
   format(mf_end_hours,"##.#"))
 ELSE
  SET retval = 0
  SET log_message = build2("False",format(mf_diff_hours,"####.##"),"out of range.",format(
    mf_start_hours,"##.#")," and ",
   format(mf_end_hours,"##.#"))
 ENDIF
#exit_prog
END GO
