CREATE PROGRAM bhs_eks_chk_same_dt_of_serv:dba
 DECLARE date_chk = f8 WITH protect
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE trigger_encntrid=e.encntr_id)
  ORDER BY e.encntr_id
  DETAIL
   date_chk = datetimecmp(e.reg_dt_tm,cnvtdatetime(curdate,curtime3))
  WITH nocounter
 ;end select
 SET log_message = build("date_chk = ",date_chk)
 IF (date_chk=0
  AND curqual > 0)
  SET retval = 100
 ELSE
  SET retval = 0
 ENDIF
END GO
