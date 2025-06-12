CREATE PROGRAM codecache_getset:dba
 RECORD reply(
   1 cvcount = ui4
   1 cvlistarray[*]
     2 cvlist[*]
       3 code_value = f8
       3 code_set = i4
       3 cdf_meaning = c12
       3 display = c40
       3 display_key = c40
       3 description = c60
       3 definition = c100
       3 collation_seq = i4
       3 cki = c255
       3 concept_cki = c255
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
   DECLARE cvcount = i4 WITH noconstant(0)
   DECLARE cvindex = i4 WITH noconstant(0)
   DECLARE cvouterindex = i4 WITH noconstant(0)
   DECLARE cvinnerindex = i4 WITH noconstant(0)
   DECLARE cvremainder = i4 WITH noconstant(0)
   SET cvcount = countcacheablecodevaluesinset(request->code_set)
   IF (cvcount=0)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE (cv.code_set=request->code_set)
     AND cv.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN cv.begin_effective_dt_tm AND cv.end_effective_dt_tm
    ORDER BY cv.code_value
    HEAD REPORT
     cvindex = 0
    DETAIL
     cvindex = (cvindex+ 1)
     IF (cvindex <= cvcount)
      cvouterindex = (((cvindex+ listmax) - 1)/ listmax), cvinnerindex = (mod(((cvindex+ listmax) - 1
       ),listmax)+ 1)
      IF (cvinnerindex=1)
       stat = alterlist(reply->cvlistarray,cvouterindex), cvremainder = ((cvcount - cvindex)+ 1),
       stat = alterlist(reply->cvlistarray[cvouterindex].cvlist,minval(cvremainder,listmax))
      ENDIF
      reply->cvlistarray[cvouterindex].cvlist[cvinnerindex].code_value = cv.code_value, reply->
      cvlistarray[cvouterindex].cvlist[cvinnerindex].code_set = cv.code_set, reply->cvlistarray[
      cvouterindex].cvlist[cvinnerindex].cdf_meaning = cv.cdf_meaning,
      reply->cvlistarray[cvouterindex].cvlist[cvinnerindex].display = cv.display, reply->cvlistarray[
      cvouterindex].cvlist[cvinnerindex].display_key = cv.display_key, reply->cvlistarray[
      cvouterindex].cvlist[cvinnerindex].description = cv.description,
      reply->cvlistarray[cvouterindex].cvlist[cvinnerindex].definition = cv.definition, reply->
      cvlistarray[cvouterindex].cvlist[cvinnerindex].collation_seq = cv.collation_seq, reply->
      cvlistarray[cvouterindex].cvlist[cvinnerindex].cki = cv.cki,
      reply->cvlistarray[cvouterindex].cvlist[cvinnerindex].concept_cki = cv.concept_cki
     ENDIF
    FOOT REPORT
     IF (cvindex < cvcount)
      stat = alterlist(reply->cvlistarray[cvouterindex].cvlist,cvinnerindex)
     ENDIF
     reply->cvcount = cvindex
    WITH nocounter
   ;end select
 END ;Subroutine
 CALL populatereply(null)
END GO
