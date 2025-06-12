CREATE PROGRAM afc_fix_tier_sequences:dba
 FREE SET requestforscript
 RECORD requestforscript(
   1 code_set = i4
   1 qual[*]
     2 code_value = f8
     2 cdf_meaning = vc
     2 display = vc
     2 display_key = vc
     2 description = vc
     2 definition = vc
     2 collation_seq = i4
     2 active_type_cd = f8
     2 active_ind = i2
     2 authentic_ind = i2
     2 updt_cnt = i2
 )
 SET reqdata->active_status_cd = 14815.0000
 RECORD tiergroup_cv(
   1 tier_num = i2
   1 tier_cs = f8
 )
 SET count1 = 0
 SET code_set = 13036
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=code_set
   AND cv.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(requestforscript->qual,count1), requestforscript->qual[
   count1].code_value = cv.code_value,
   requestforscript->qual[count1].cdf_meaning = cv.cdf_meaning, requestforscript->qual[count1].
   display = cv.display, requestforscript->qual[count1].display_key = cv.display_key,
   requestforscript->qual[count1].description = cv.description, requestforscript->qual[count1].
   definition = cv.definition, requestforscript->qual[count1].collation_seq = cv.collation_seq,
   requestforscript->qual[count1].active_type_cd = cv.active_type_cd, requestforscript->qual[count1].
   authentic_ind = 0, requestforscript->qual[count1].active_ind = cv.active_ind,
   requestforscript->qual[count1].updt_cnt = cv.updt_cnt
  WITH nocounter
 ;end select
 SET tiergroup_cv->tier_cs = code_set
 SET tiergroup_cv->tier_num = count1
 SET requestforscript->code_set = tiergroup_cv->tier_cs
 SET reqinfo->updt_id = 301402
 SET reqinfo->updt_applctx = 950000
 SET reqinfo->updt_task = 950000
 SET count1 = 0
 FOR (count1 = 1 TO tiergroup_cv->tier_num)
  CASE (requestforscript->qual[count1].cdf_meaning)
   OF "FIN CLASS":
    SET requestforscript->qual[count1].collation_seq = 1
   OF "VISITTYPE":
    SET requestforscript->qual[count1].collation_seq = 2
   OF "ORG":
    SET requestforscript->qual[count1].collation_seq = 3
   OF "ORD LOC":
    SET requestforscript->qual[count1].collation_seq = 4
   OF "SERVICERES":
    SET requestforscript->qual[count1].collation_seq = 5
   OF "RPT PRIORITY":
    SET requestforscript->qual[count1].collation_seq = 6
   OF "PAT LOC":
    SET requestforscript->qual[count1].collation_seq = 7
   OF "COL PRIORITY":
    SET requestforscript->qual[count1].collation_seq = 8
   OF "PERF LOC":
    SET requestforscript->qual[count1].collation_seq = 9
   OF "ACTCODE":
    SET requestforscript->qual[count1].collation_seq = 10
   OF "HEALTHPLAN":
    SET requestforscript->qual[count1].collation_seq = 11
   OF "PRIORITY":
    SET requestforscript->qual[count1].collation_seq = 12
   OF "SEPARATOR":
    SET requestforscript->qual[count1].collation_seq = 13
   OF "CHARGE POINT":
    SET requestforscript->qual[count1].collation_seq = 14
   OF "PRICESCHED":
    SET requestforscript->qual[count1].collation_seq = 15
   OF "LPRICESCHED":
    SET requestforscript->qual[count1].collation_seq = 16
   OF "CDM_SCHED":
    SET requestforscript->qual[count1].collation_seq = 17
   OF "CPT4":
    SET requestforscript->qual[count1].collation_seq = 18
   OF "MODIFIER":
    SET requestforscript->qual[count1].collation_seq = 19
   OF "ICD9":
    SET requestforscript->qual[count1].collation_seq = 20
   OF "PROCCODE":
    SET requestforscript->qual[count1].collation_seq = 22
   OF "REVENUE":
    SET requestforscript->qual[count1].collation_seq = 23
   OF "HOLD_SUSP":
    SET requestforscript->qual[count1].collation_seq = 24
   OF "GL":
    SET requestforscript->qual[count1].collation_seq = 25
   OF "DIAGREQD":
    SET requestforscript->qual[count1].collation_seq = 26
   OF "PHYSREQD":
    SET requestforscript->qual[count1].collation_seq = 27
   OF "FLAT_DISC":
    SET requestforscript->qual[count1].collation_seq = 28
   OF "ADD ON":
    SET requestforscript->qual[count1].collation_seq = 29
   OF "INTERFACE":
    SET requestforscript->qual[count1].collation_seq = 30
   OF "INSTFINNBR":
    SET requestforscript->qual[count1].collation_seq = 31
   OF "COSTCENTER":
    SET requestforscript->qual[count1].collation_seq = 32
   OF "CLNTRPTTYPE":
    SET requestforscript->qual[count1].collation_seq = 33
  ENDCASE
  CALL update_codeset(count1)
 ENDFOR
 SUBROUTINE update_codeset(i)
   CALL echo(build("meaning: ",requestforscript->qual[i].cdf_meaning," collatiion_seq: ",
     requestforscript->qual[i].collation_seq))
   UPDATE  FROM code_value c
    SET c.collation_seq = requestforscript->qual[i].collation_seq
    WHERE c.code_set=13036
     AND c.active_ind=1
     AND (c.code_value=requestforscript->qual[i].code_value)
   ;end update
   COMMIT
 END ;Subroutine
 FREE SET tiergroup_cv
 FREE SET requestforscript
END GO
