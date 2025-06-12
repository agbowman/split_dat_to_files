CREATE PROGRAM bbt_chk_long_text:dba
 SET success_ind = 1
 SET serrormsg = fillstring(255," ")
 SET nerrorstatus = error(serrormsg,1)
 SELECT INTO "nl:"
  FROM long_text lt,
   interp_result ir,
   (dummyt d_ltr  WITH seq = 1),
   long_text_reference ltr
  PLAN (lt
   WHERE lt.long_text_id > 0)
   JOIN (ir
   WHERE ir.long_text_id=lt.long_text_id)
   JOIN (d_ltr)
   JOIN (ltr
   WHERE ltr.long_text_id=ir.long_text_id)
  ORDER BY lt.long_text_id, ltr.long_text_id
  HEAD REPORT
   success_ind = 1, lt_count = 0, ltr_count = 0
  HEAD lt.long_text_id
   lt_count = (lt_count+ 1)
  HEAD ltr.long_text_id
   ltr_count = (ltr_count+ 1)
  DETAIL
   IF (lt.active_ind=1)
    success_ind = 0
   ENDIF
  FOOT REPORT
   IF (lt_count != ltr_count)
    success_ind = 0
   ENDIF
  WITH nocounter, outerjoin(d_ltr)
 ;end select
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus=0)
  IF (success_ind=0)
   SET request->setup_proc[1].success_ind = 0
  ELSE
   SET request->setup_proc[1].success_ind = 1
  ENDIF
 ELSE
  SET request->setup_proc[1].success_ind = 0
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
