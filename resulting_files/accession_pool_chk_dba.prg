CREATE PROGRAM accession_pool_chk:dba
#begin
 RECORD acc_pool(
   1 qual[*]
     2 pool_id = f8
     2 reset_frequency = i2
     2 activity_type_cd = f8
 )
 SELECT INTO "nl:"
  aax.accession_format_cd, cv.display, cv.cdf_meaning,
  aax.site_prefix_cd, aax.accession_assignment_pool_id, aax.activity_type_cd
  FROM accession_assign_xref aax,
   code_value cv
  PLAN (aax
   WHERE aax.accession_format_cd > 0)
   JOIN (cv
   WHERE aax.accession_format_cd=cv.code_value)
  ORDER BY aax.accession_assignment_pool_id
  HEAD REPORT
   x = 0
  HEAD aax.accession_assignment_pool_id
   alpha_cnt = 0, activity_type_cd = 0.0, x = (x+ 1)
   IF (x > size(acc_pool->qual,5))
    stat = alterlist(acc_pool->qual,(x+ 10))
   ENDIF
   acc_pool->qual[x].pool_id = aax.accession_assignment_pool_id, acc_pool->qual[x].reset_frequency =
   0, acc_pool->qual[x].activity_type_cd = 0.0
  DETAIL
   IF (cv.display > " ")
    alpha_cnt = (alpha_cnt+ 1)
   ENDIF
   IF ((aax.activity_type_cd != acc_pool->qual[x].activity_type_cd)
    AND (acc_pool->qual[x].activity_type_cd=0))
    acc_pool->qual[x].activity_type_cd = aax.activity_type_cd
   ENDIF
  FOOT  aax.accession_assignment_pool_id
   IF (alpha_cnt > 0)
    acc_pool->qual[x].reset_frequency = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(acc_pool->qual,x)
  WITH nocounter
 ;end select
 SET status = 0
 SET error_ind = 0
 SET txt = fillstring(100," ")
 SET sze = size(acc_pool->qual,5)
 IF (sze > 0)
  FOR (i = 1 TO sze)
    SET activity_type_cd = 0.0
    SET reset_frequency = 0
    SELECT INTO "nl:"
     aap.accession_assignment_pool_id, aap.reset_frequency, aap.activity_type_cd
     FROM accession_assign_pool aap
     WHERE (aap.accession_assignment_pool_id=acc_pool->qual[i].pool_id)
     DETAIL
      activity_type_cd = aap.activity_type_cd, reset_frequency = aap.reset_frequency
     WITH nocounter
    ;end select
    IF ((((activity_type_cd != acc_pool->qual[i].activity_type_cd)) OR ((reset_frequency != acc_pool
    ->qual[i].reset_frequency))) )
     SET error_ind = 1
    ENDIF
  ENDFOR
  IF (error_ind=1)
   SET status = 0
   SET txt = "Accession Assignment Pools Not Setup Correctly."
  ELSE
   SET status = 1
   SET txt = "Accession Assignment Pools Setup Correctly."
  ENDIF
 ELSE
  SET status = 1
  SET txt = "No Accession Assignment Relationships Exist."
 ENDIF
 IF (validate(request,0))
  SET request->setup_proc[1].success_ind = status
  SET request->setup_proc[1].error_msg = txt
  EXECUTE dm_add_upt_setup_proc_log
 ELSE
  CALL echo(build(txt," (status: ",status,")"))
 ENDIF
END GO
