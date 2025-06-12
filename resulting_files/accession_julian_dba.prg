CREATE PROGRAM accession_julian:dba
 SET commit_ind = 0
#julian_accession_bucket
 RECORD j_bucket(
   1 qual[*]
     2 code_value = f8
     2 cdf_ind = i2
 )
 SET format_cd = 0
 SET j_bucket_count = 0
 SET commit_ind = 1
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=2057
   AND c.active_ind=1
  HEAD REPORT
   count = 0
  DETAIL
   IF (((c.display=" ") OR (c.display="")) )
    count = (count+ 1)
    IF (count > size(j_bucket->qual,5))
     stat = alterlist(j_bucket->qual,(count+ 10))
    ENDIF
    j_bucket->qual[count].code_value = c.code_value
    IF (c.cdf_meaning="JULIANDATE")
     j_bucket->qual[count].cdf_ind = 1
    ELSE
     j_bucket->qual[count].cdf_ind = 0
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(j_bucket->qual,count)
  WITH nocounter
 ;end select
 IF (size(j_bucket->qual,5) > 0)
  FOR (i = 1 TO size(j_bucket->qual,5))
   SELECT INTO "nl:"
    aax.*
    FROM accession_assign_xref aax
    WHERE (aax.accession_format_cd=j_bucket->qual[i].code_value)
     AND aax.site_prefix_cd=0
    WITH nocounter
   ;end select
   IF (curqual > 0)
    IF ((j_bucket->qual[i].cdf_ind=0))
     UPDATE  FROM code_value c
      SET c.cdf_meaning = "JULIANDATE", c.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), c
       .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00.00")
      WHERE (c.code_value=j_bucket->qual[i].code_value)
     ;end update
    ENDIF
    SET j_bucket_count = (j_bucket_count+ 1)
   ELSE
    UPDATE  FROM code_value c
     SET c.active_ind = 0, c.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (c.code_value=j_bucket->qual[i].code_value)
    ;end update
   ENDIF
  ENDFOR
 ENDIF
 IF (j_bucket_count=0)
  SELECT INTO "nl:"
   c.*
   FROM code_value c
   WHERE c.code_set=2057
    AND c.cdf_meaning="JULIANDATE"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET commit_ind = 0
   GO TO exit_script
  ENDIF
 ELSE
  IF (j_bucket_count > 1)
   SET commit_ind = 0
   GO TO exit_script
  ENDIF
 ENDIF
 IF (commit_ind=1)
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
#remove_julian
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=2057
   AND c.cdf_meaning="JULIANDATE"
   AND c.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 1)
  GO TO exit_script
 ENDIF
 SET format_cd = 0
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=2057
   AND c.cdf_meaning="JULIANDATE"
   AND c.active_ind=1
  DETAIL
   format_cd = c.code_value
  WITH nocounter
 ;end select
 IF (format_cd > 0)
  UPDATE  FROM code_value c
   SET c.active_ind = 0, c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00.00"), c.updt_dt_tm
     = cnvtdatetime(curdate,curtime3),
    c.updt_id = 0, c.updt_cnt = 0, c.updt_task = 0,
    c.updt_applctx = 0
   WHERE c.code_value=format_cd
   WITH nocounter
  ;end update
  IF (curqual=0)
   GO TO exit_script
  ENDIF
  SET cnt = 0
  SELECT INTO "nl:"
   a.accession_class_cd
   FROM accession_class a
   WHERE a.accession_format_cd=format_cd
   DETAIL
    cnt = (cnt+ 1)
   WITH nocounter
  ;end select
  IF (cnt > 0)
   UPDATE  FROM accession_class a
    SET a.accession_format_cd = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = 0,
     a.updt_cnt = 0, a.updt_task = 0, a.updt_applctx = 0
    WHERE a.accession_format_cd=format_cd
    WITH nocounter
   ;end update
   IF (curqual != cnt)
    GO TO exit_script
   ENDIF
  ENDIF
  SET cnt = 0
  SELECT INTO "nl:"
   aax.accession_format_cd, aax.site_prefix_cd
   FROM accession_assign_xref aax
   WHERE aax.accession_format_cd=format_cd
   DETAIL
    cnt = (cnt+ 1)
   WITH nocounter
  ;end select
  IF (cnt > 0)
   SELECT INTO "nl:"
    aax.accession_format_cd, aax.site_prefix_cd
    FROM accession_assign_xref aax
    WHERE aax.accession_format_cd=0
     AND aax.site_prefix_cd=0
    WITH nocounter
   ;end select
   IF (curqual > 0)
    DELETE  FROM accession_assign_xref aax
     WHERE aax.accession_format_cd=0
      AND aax.site_prefix_cd=0
    ;end delete
    IF (curqual=0)
     GO TO exit_script
    ENDIF
   ENDIF
   UPDATE  FROM accession_assign_xref aax
    SET aax.accession_format_cd = 0, aax.updt_dt_tm = cnvtdatetime(curdate,curtime3), aax.updt_id = 0,
     aax.updt_cnt = 0, aax.updt_task = 0, aax.updt_applctx = 0
    WHERE aax.accession_format_cd=format_cd
    WITH nocounter
   ;end update
   IF (curqual != cnt)
    GO TO exit_script
   ENDIF
  ENDIF
  SET commit_ind = 1
 ENDIF
#exit_script
 IF (commit_ind=1)
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
