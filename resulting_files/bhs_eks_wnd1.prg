CREATE PROGRAM bhs_eks_wnd1
 SET eid = trigger_encntrid
 SET pid = trigger_personid
 SET retval = 100
 SELECT
  FROM encounter en,
   eks_module_audit e,
   eks_module_audit_det em
  PLAN (en
   WHERE en.encntr_id=eid)
   JOIN (e
   WHERE e.begin_dt_tm > en.reg_dt_tm
    AND e.module_name="BHS_ASY_WND_MGMT1"
    AND e.conclude=2)
   JOIN (em
   WHERE em.module_audit_id=e.rec_id
    AND em.encntr_id=en.encntr_id
    AND em.person_id=en.person_id)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 0
 ENDIF
END GO
