CREATE PROGRAM bhs_syn_med_rec_query5_ev:dba
 FREE RECORD t_record
 RECORD t_record(
   1 encntr_id = f8
   1 perf_dt_tm = dq8
 )
 SET retval = 0
 SET t_record->encntr_id = trigger_encntrid
 DECLARE med_rec_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MEDRECONCILIATION"))
 DECLARE pharm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE compliance_ind = i2
 DECLARE recon_ind = i2
 SELECT INTO "nl:"
  FROM order_compliance oc
  PLAN (oc
   WHERE (oc.encntr_id=t_record->encntr_id))
  ORDER BY oc.performed_dt_tm DESC
  HEAD oc.performed_dt_tm
   t_record->perf_dt_tm = oc.performed_dt_tm, compliance_ind = 1
 ;end select
 SET log_message = build("order_compliance retval = ",retval) WITH nocounter
 SET log_message = build(log_message,"after select = ",retval)
 SELECT INTO "nl:"
  FROM order_recon orc
  PLAN (orc
   WHERE (orc.encntr_id=t_record->encntr_id)
    AND orc.recon_type_flag=1
    AND orc.performed_dt_tm >= cnvtdatetime(t_record->perf_dt_tm))
  DETAIL
   recon_ind = 1
  WITH nocounter
 ;end select
 IF (recon_ind=1)
  SET retval = 0
 ELSE
  SET retval = 100
 ENDIF
 SET log_message = build(log_message,"2nd select retval = ",retval)
 SET log_message = build(log_message,"compliance_ind = ",compliance_ind)
 SET log_message = build(log_message,"recon_ind = ",recon_ind)
 CALL echo(retval)
END GO
