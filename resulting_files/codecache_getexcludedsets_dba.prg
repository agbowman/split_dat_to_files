CREATE PROGRAM codecache_getexcludedsets:dba
 RECORD reply(
   1 cscount = ui4
   1 cslist[*]
     2 code_set = i4
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
 SUBROUTINE populatereply(null)
   DECLARE cscount = i4 WITH noconstant(0)
   DECLARE csindex = i4 WITH noconstant(0)
   SET cscount = countcodesets(etable_codevalue)
   IF (cscount=0)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN cv.begin_effective_dt_tm AND cv.end_effective_dt_tm
    GROUP BY cv.code_set
    HAVING count(*) > 65535
    HEAD REPORT
     csindex = 0, stat = alterlist(reply->cslist,cscount)
    DETAIL
     csindex = (csindex+ 1)
     IF (csindex <= cscount)
      reply->cslist[csindex].code_set = cs.code_set
     ENDIF
    FOOT REPORT
     IF (csindex < cscount)
      stat = alterlist(reply->cslist,csindex)
     ENDIF
     reply->cscount = csindex
    WITH nocounter
   ;end select
 END ;Subroutine
 CALL populatereply(null)
END GO
