CREATE PROGRAM bhs_find_diagnosis:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter DX to find:" = "",
  "Select diagnosis value:" = "",
  "Find children or parent:" = 0,
  "Calling progam:" = 0,
  "Source code type:" = 0
  WITH outdev, finddx, diagval,
  findtype, callprog, sourcecode
 DECLARE snmct = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE icd9 = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"ICD9"))
 DECLARE nextcnt = i2 WITH protect, noconstant(0)
 DECLARE allckicnt = i2 WITH protect, noconstant(0)
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE start = i4 WITH noconstant(1), public
 DECLARE sourcecd = f8 WITH noconstant(0.0)
 DECLARE promptvalueerr = i2 WITH protect, noconstant(0)
 DECLARE blankpromptmsg = vc WITH protect, noconstant(" ")
 IF (validate(allcki->qual) <= 0)
  CALL echo("declaring allCki")
  RECORD allcki(
    1 qual[*]
      2 sourcestring = vc
      2 cki = vc
      2 nomenid = f8
      2 sourcecd = f8
      2 level = i4
  )
 ENDIF
 RECORD nextlevel(
   1 qual[*]
     2 nextlevelcki = vc
 )
 RECORD tempnextlevel(
   1 qual[*]
     2 nextlevelcki = vc
 )
 IF (textlen(trim( $DIAGVAL,3)) <= 0)
  SET promptvalueerr = 1
  SET blankpromptmsg = "You must select a diagnosis value"
 ELSEIF (( $FINDTYPE=0))
  SET promptvalueerr = 1
  SET blankpromptmsg = "You must select a find type of child or parent"
 ELSEIF (( $CALLPROG=0))
  SET promptvalueerr = 1
  SET blankpromptmsg = "You must select a calling progam"
 ELSEIF (( $SOURCECODE=0))
  SET promptvalueerr = 1
  SET blankpromptmsg = "You must select a list."
 ENDIF
 IF (promptvalueerr=1)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = blankpromptmsg, msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/12}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_script
 ENDIF
 IF (( $SOURCECODE=1))
  SET sourcecd = snmct
 ELSEIF (( $SOURCECODE=2))
  SET sourcecd = icd9
 ENDIF
 IF (( $CALLPROG=1))
  SET stat = alterlist(allcki->qual,1)
  SET allcki->qual[1].sourcestring = trim(cnvtupper( $DIAGVAL),3)
  CALL echo("locating nextlevel of Diagnosis")
  SELECT INTO "NL:"
   FROM nomenclature n,
    nomenclature n2,
    (dummyt d  WITH seq = size(allcki->qual,5))
   PLAN (d)
    JOIN (n
    WHERE n.source_string_keycap=trim(cnvtupper( $DIAGVAL),3)
     AND n.active_ind=1
     AND ((n.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
     AND ((n.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))
     AND ((n.source_vocabulary_cd+ 0)=sourcecd))
    JOIN (n2
    WHERE n2.concept_cki=outerjoin(n.concept_cki)
     AND n2.nomenclature_id != outerjoin(n.nomenclature_id)
     AND ((n2.beg_effective_dt_tm+ 0) <= outerjoin(cnvtdatetime(curdate,curtime3)))
     AND ((n2.end_effective_dt_tm+ 0) >= outerjoin(cnvtdatetime(curdate,curtime3)))
     AND ((n2.source_vocabulary_cd+ 0)=outerjoin(sourcecd)))
   ORDER BY n.concept_cki, n2.source_identifier_keycap
   HEAD n.nomenclature_id
    allckicnt = (allckicnt+ 1), allcki->qual[d.seq].cki = n.concept_cki, allcki->qual[d.seq].
    sourcestring = n.source_string,
    allcki->qual[d.seq].sourcecd = n.source_vocabulary_cd, allcki->qual[d.seq].nomenid = n
    .nomenclature_id, allcki->qual[d.seq].level = 1,
    nextcnt = (nextcnt+ 1), stat = alterlist(nextlevel->qual,nextcnt), nextlevel->qual[nextcnt].
    nextlevelcki = n.concept_cki,
    CALL echo("ID")
   HEAD n2.source_string_keycap
    IF (n2.nomenclature_id > 0)
     allckicnt = (allckicnt+ 1), stat = alterlist(allcki->qual,allckicnt), allcki->qual[allckicnt].
     cki = n2.concept_cki,
     allcki->qual[allckicnt].nomenid = n2.nomenclature_id, allcki->qual[allckicnt].sourcestring = n2
     .source_string, allcki->qual[allckicnt].sourcecd = n2.source_vocabulary_cd,
     allcki->qual[allckicnt].level = 1
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  FOR (x = 1 TO size(allcki->qual,5))
    SET allckicnt = (allckicnt+ 1)
    SET nextcnt = (nextcnt+ 1)
    SET stat = alterlist(nextlevel->qual,nextcnt)
    SET nextlevel->qual[nextcnt].nextlevelcki = allcki->qual[allckicnt].cki
  ENDFOR
 ENDIF
 CALL echo(build("SourceCd:",sourcecd))
 CALL echorecord(allcki)
 CALL echorecord(nextlevel)
 SET cnt = 0
 WHILE (size(nextlevel->qual,5) > 0
  AND cnt < 9)
   SET cnt = (cnt+ 1)
   SET nextcnt = 0
   SELECT INTO  $OUTDEV
    FROM cmt_concept_reltn ccr,
     nomenclature n,
     (dummyt d  WITH seq = size(nextlevel->qual,5))
    PLAN (d)
     JOIN (ccr
     WHERE ((( $FINDTYPE=1)
      AND (ccr.concept_cki2=nextlevel->qual[d.seq].nextlevelcki)) OR (( $FINDTYPE=2)
      AND (ccr.concept_cki1=nextlevel->qual[d.seq].nextlevelcki)))
      AND trim(ccr.concept_cki1,3) > " "
      AND ccr.concept_cki2 != ccr.concept_cki1
      AND ccr.active_ind=1
      AND ccr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ccr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND cnvtupper(ccr.relation_cki)="SNOMED!116680003")
     JOIN (n
     WHERE ((( $FINDTYPE=1)
      AND n.concept_cki=ccr.concept_cki1) OR (( $FINDTYPE=2)
      AND n.concept_cki=ccr.concept_cki2))
      AND ((n.source_vocabulary_cd+ 0)=sourcecd))
    DETAIL
     pos = 0, pos = locateval(num,start,size(allcki->qual,5),n.nomenclature_id,allcki->qual[num].
      nomenid)
     IF (pos <= 0)
      nextcnt = (nextcnt+ 1), stat = alterlist(tempnextlevel->qual,nextcnt), tempnextlevel->qual[
      nextcnt].nextlevelcki = n.concept_cki,
      allckicnt = (allckicnt+ 1), stat = alterlist(allcki->qual,allckicnt), allcki->qual[allckicnt].
      sourcestring = n.source_string,
      allcki->qual[allckicnt].cki = n.concept_cki, allcki->qual[allckicnt].nomenid = n
      .nomenclature_id, allcki->qual[allckicnt].sourcecd = n.source_vocabulary_cd,
      allcki->qual[allckicnt].level = (cnt+ 1)
     ENDIF
    WITH format, separator = " ", time = 100
   ;end select
   SET stat = alterlist(nextlevel->qual,0)
   SET nextlevel = tempnextlevel
   SET stat = alterlist(tempnextlevel->qual,0)
 ENDWHILE
 CALL echo(build("nextLevels: ",cnt))
 CALL echo(build("AllCkiCnt:",allckicnt))
 CALL echorecord(allcki)
 SELECT INTO  $OUTDEV
  cki = allcki->qual[d.seq].cki, parentsource = substring(0,140,allcki->qual[d.seq].sourcestring),
  sourcecd = uar_get_code_display(allcki->qual[d.seq].sourcecd),
  nomenid = allcki->qual[d.seq].nomenid, level = allcki->qual[d.seq].level
  FROM (dummyt d  WITH seq = size(allcki->qual,5))
  PLAN (d
   WHERE (allcki->qual[d.seq].nomenid > 0))
  WITH format, separator = " "
 ;end select
#exit_script
END GO
