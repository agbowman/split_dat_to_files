CREATE PROGRAM accession_pool:dba
 RECORD acc_pool(
   1 qual[*]
     2 pool_id = f8
     2 reset_frequency = i2
     2 activity_type_cd = f8
 )
#begin
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
 IF (size(acc_pool->qual,5) > 0)
  UPDATE  FROM accession_assign_pool aap,
    (dummyt d1  WITH seq = value(size(acc_pool->qual,5)))
   SET aap.activity_type_cd = acc_pool->qual[d1.seq].activity_type_cd, aap.reset_frequency = acc_pool
    ->qual[d1.seq].reset_frequency, aap.updt_applctx = 0,
    aap.updt_dt_tm = cnvtdatetime(curdate,curtime3), aap.updt_id = 0, aap.updt_cnt = (aap.updt_cnt+ 1
    ),
    aap.updt_task = 0
   PLAN (d1)
    JOIN (aap
    WHERE (aap.accession_assignment_pool_id=acc_pool->qual[d1.seq].pool_id))
   WITH nocounter
  ;end update
  IF (curqual=size(acc_pool->qual,5))
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
 ENDIF
#exit_script
END GO
