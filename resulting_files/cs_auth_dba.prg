CREATE PROGRAM cs_auth:dba
 PAINT
#top
 CALL box(3,1,22,80)
 CALL text(2,1,"CodeSet Authenticator",w)
 CALL text(4,2,"Range or Specific codesets (R/W)?")
 CALL accept(4,36,"p;cu","S"
  WHERE curaccept IN ("R", "S"))
 SET r_type = curaccept
 RECORD cs_rec(
   1 qual[*]
     2 code_set = f8
 )
 IF (r_type="R")
  CALL text(5,2,"Enter start code set: ")
  CALL text(6,2,"Enter ending code set: ")
  CALL accept(5,25,"nnnnnnnnnnn",0.0)
  SET s_cs = curaccept
  CALL accept(6,25,"nnnnnnnnnnn",0.0)
  SET e_cs = curaccept
  CALL text(23,1,"Correct (Y/N)?")
  CALL accept(23,16,"p;cu","Y"
   WHERE curaccept IN ("Y", "N"))
  CALL clear(23,1,50)
  IF (curaccept="N")
   CALL clear(1,1)
   GO TO top
  ENDIF
  SET num_cs = ((e_cs - s_cs)+ 1)
  SET stat = alterlist(cs_rec->qual,num_cs)
  FOR (lvar = 1 TO num_cs)
    SET cs_rec->qual[lvar].code_set = ((s_cs+ lvar) - 1)
  ENDFOR
 ELSE
  CALL text(5,2,"Enter code set (0 when done): ")
  SET done = "F"
  SET num_cs = 0
  WHILE (done="F")
   CALL accept(5,32,"nnnnnnnnnnn",0.0)
   IF (curaccept > 0)
    SET num_cs = (num_cs+ 1)
    IF (num_cs <= 16)
     CALL text((5+ num_cs),2,cnvtstring(curaccept))
    ELSEIF (num_cs BETWEEN 18 AND 33)
     CALL text((5+ (num_cs - 17)),20,cnvtstring(curaccept))
    ELSEIF (num_cs BETWEEN 34 AND 49)
     CALL text((5+ (num_cs - 33)),40,cnvtstring(curaccept))
    ENDIF
    SET stat = alterlist(cs_rec->qual,num_cs)
    SET cs_rec->qual[num_cs].code_set = curaccept
   ELSE
    SET done = "T"
   ENDIF
  ENDWHILE
  CALL text(23,1,"Correct (Y/N)?")
  CALL accept(23,16,"p;cu","Y"
   WHERE curaccept IN ("Y", "N"))
  CALL clear(23,1,50)
  IF (curaccept="N")
   CALL clear(1,1)
   GO TO top
  ENDIF
 ENDIF
 SET active_cd = 0.0
 SET unauth_cd = 0.0
 SET auth_cd = 0.0
 RECORD task_rec(
   1 numrecs = i4
   1 qual[*]
     2 task_no = f8
 )
 SET numrecs = 0
 SELECT INTO "nl:"
  a.task_number
  FROM application_task_r a
  PLAN (a
   WHERE a.application_number=12000)
  HEAD REPORT
   numrecs = 0
  DETAIL
   numrecs = (numrecs+ 1), stat = alterlist(task_rec->qual,numrecs), task_rec->qual[numrecs].task_no
    = a.task_number
  FOOT REPORT
   task_rec->numrecs = numrecs
  WITH counter
 ;end select
 SET task_rec->numrecs = (task_rec->numrecs+ 1)
 SET stat = alterlist(task_rec->qual,task_rec->numrecs)
 SET task_rec->qual[task_rec->numrecs].task_no = 2218
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="ACTIVE"
    AND c.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN c.begin_effective_dt_tm AND c.end_effective_dt_tm)
  DETAIL
   active_cd = c.code_value
  WITH counter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  PLAN (c
   WHERE c.code_set=8
    AND c.cdf_meaning="UNAUTH"
    AND c.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN c.begin_effective_dt_tm AND c.end_effective_dt_tm)
  DETAIL
   unauth_cd = c.code_value
  WITH counter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  PLAN (c
   WHERE c.code_set=8
    AND c.cdf_meaning="AUTH"
    AND c.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN c.begin_effective_dt_tm AND c.end_effective_dt_tm)
  DETAIL
   auth_cd = c.code_value
  WITH counter
 ;end select
 UPDATE  FROM code_value c,
   (dummyt d  WITH seq = value(num_cs))
  SET c.data_status_cd = auth_cd, c.data_status_dt_tm = cnvtdatetime(curdate,curtime3), c
   .data_status_prsnl_id = 999988,
   c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = 999988,
   c.updt_id = 999988, c.updt_applctx = 1
  PLAN (d
   WHERE  NOT ((cs_rec->qual[d.seq].code_set IN (220, 93, 72))))
   JOIN (c
   WHERE (cs_rec->qual[d.seq].code_set=c.code_set)
    AND ((c.active_ind=1) OR (c.active_type_cd=active_cd))
    AND ((c.data_status_cd = null) OR (((c.data_status_cd=0) OR (c.data_status_cd=unauth_cd)) ))
    AND c.cdf_meaning > " ")
 ;end update
 UPDATE  FROM code_value c,
   (dummyt d  WITH seq = value(num_cs)),
   (dummyt d2  WITH seq = value(task_rec->numrecs))
  SET c.data_status_cd = auth_cd, c.data_status_dt_tm = cnvtdatetime(curdate,curtime3), c
   .data_status_prsnl_id = 999988,
   c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = 999988,
   c.updt_id = 999988, c.updt_applctx = 1
  PLAN (d
   WHERE  NOT ((cs_rec->qual[d.seq].code_set IN (220, 93, 72))))
   JOIN (d2)
   JOIN (c
   WHERE (cs_rec->qual[d.seq].code_set=c.code_set)
    AND ((c.active_ind=1) OR (c.active_type_cd=active_cd))
    AND ((c.data_status_cd = null) OR (((c.data_status_cd=0) OR (c.data_status_cd=unauth_cd)) ))
    AND c.cdf_meaning <= " "
    AND (c.updt_task=task_rec->qual[d2.seq].task_no))
  WITH counter
 ;end update
 COMMIT
END GO
