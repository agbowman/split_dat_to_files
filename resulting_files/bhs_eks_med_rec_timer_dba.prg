CREATE PROGRAM bhs_eks_med_rec_timer:dba
 SET eid = trigger_encntrid
 SET retval = 100
 SET 600_sec_ago = cnvtlookbehind("600,S",cnvtdatetime(curdate,curtime3))
 CALL echo(build("eid:",eid))
 SELECT INTO "nl:"
  FROM eks_dlg_event e
  PLAN (e
   WHERE e.encntr_id=eid
    AND e.dlg_name IN ("BHS_EKM!BHS_SYN_MED_REC_ADM2")
    AND e.updt_dt_tm >= cnvtdatetime(600_sec_ago))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 0
 ENDIF
#exit_prog
END GO
