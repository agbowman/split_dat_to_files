CREATE PROGRAM codecache_count:dba
 RECORD reply(
   1 codeset_count = ui4
   1 codevalue_count = ui4
 )
 DECLARE listmax = i4 WITH constant(65535)
 DECLARE etable_codeset = i4 WITH constant(1)
 DECLARE etable_codevalue = i4 WITH constant(2)
 DECLARE countcodesets(etable=i4(value)) = i4
 DECLARE countcacheablecodevalues(null) = i4
 DECLARE countcacheablecodevaluesinset(cs=i4(value)) = i4
 SUBROUTINE countcodesets(etable)
   DECLARE retval = i4 WITH noconstant(0)
   CASE (etable)
    OF etable_codeset:
     SELECT INTO "nl:"
      n = count(*)
      FROM code_value_set
      DETAIL
       retval = n
      WITH nocounter
     ;end select
    OF etable_codevalue:
     SELECT INTO "nl:"
      n = count(DISTINCT code_set)
      FROM code_value
      DETAIL
       retval = n
      WITH nocounter
     ;end select
   ENDCASE
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE countcacheablecodevalues(null)
   DECLARE retval = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    n = count(*)
    FROM code_value cv,
     code_value_set cs
    PLAN (cv
     WHERE cv.active_ind=1
      AND cnvtdatetime(curdate,curtime3) BETWEEN cv.begin_effective_dt_tm AND cv.end_effective_dt_tm)
     JOIN (cs
     WHERE cs.code_set=cv.code_set)
    DETAIL
     retval = n
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE countcacheablecodevaluesinset(cs)
   DECLARE retval = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    n = count(*)
    FROM code_value cv,
     code_value_set cs
    PLAN (cv
     WHERE cv.code_set=cs
      AND cv.active_ind=1
      AND cnvtdatetime(curdate,curtime3) BETWEEN cv.begin_effective_dt_tm AND cv.end_effective_dt_tm)
     JOIN (cs
     WHERE cs.code_set=cv.code_set)
    DETAIL
     retval = n
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SET reply->codeset_count = countcodesets(etable_codeset)
 SET reply->codevalue_count = countcacheablecodevalues(null)
END GO
