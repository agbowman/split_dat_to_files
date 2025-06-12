CREATE PROGRAM bhs_gen_disch_status_updt:dba
 SET trace = nocost
 SET message = noinformation
 FREE RECORD rows
 RECORD rows(
   1 qual[*]
     2 id_start = f8
     2 id_end = f8
 )
 DECLARE fillcontrolstructure(inmax=f8,inbatch=i2) = i2
 SUBROUTINE fillcontrolstructure(inmax,inbatch)
   SET loopcnt = (cnvtint((inmax/ inbatch))+ 1)
   SET stat = alterlist(rows->qual,loopcnt)
   FOR (sub_xx = 1 TO loopcnt)
     SET rows->qual[sub_xx].id_start = (inbatch * (sub_xx - 1))
     SET rows->qual[sub_xx].id_end = (rows->qual[sub_xx].id_start+ inbatch)
     IF ((rows->qual[sub_xx].id_end > inmax))
      SET rows->qual[sub_xx].id_end = (inmax+ 1)
     ENDIF
     CALL echo(build("start:",rows->qual[sub_xx].id_start))
     CALL echo(build("end:",rows->qual[sub_xx].id_end))
   ENDFOR
 END ;Subroutine
 SET discharged_cd = 0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=261
   AND c.cdf_meaning="DISCHARGED"
  DETAIL
   discharged_cd = c.code_value
  WITH nocounter
 ;end select
 IF (discharged_cd=0)
  GO TO 9999_end_program
 ENDIF
 FREE SET encntrs
 RECORD encntrs(
   1 qual_cnt = i4
   1 encntr[*]
     2 encntr_id = f8
     2 reg_dt_tm = dq8
 )
 SET maxencntr_id = 0.0
 SET minencntr_id = 0.0
 SELECT INTO "nl:"
  u.last_number
  FROM user_sequences u
  WHERE u.sequence_name="ENCOUNTER_ONLY_SEQ"
  DETAIL
   maxencntr_id = u.last_number, minencntr_id = 1
  WITH nocounter
 ;end select
 CALL fillcontrolstructure(maxencntr_id,100000)
 SET encntrs_processed = 0
 FOR (qq = 1 TO size(rows->qual,5))
   SET encntr_count = 0
   SET stat = alterlist(encntrs->encntr,0)
   SELECT INTO "nl:"
    e.seq
    FROM encounter e
    WHERE (e.encntr_id > rows->qual[qq].id_start)
     AND (e.encntr_id <= rows->qual[qq].id_end)
     AND ((e.active_ind+ 0)=1)
     AND ((e.med_service_cd+ 0)=703444)
     AND e.disch_dt_tm IS NOT null
     AND ((e.encntr_status_cd+ 0) != 856)
     AND ((e.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
     AND ((e.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))
    DETAIL
     encntr_count = (encntr_count+ 1), stat = alterlist(encntrs->encntr,encntr_count), encntrs->
     encntr[encntr_count].encntr_id = e.encntr_id,
     encntrs->encntr[encntr_count].reg_dt_tm = cnvtdatetime(e.reg_dt_tm)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo(concat("no records found for this batch: ",trim(cnvtstring(qq),3)))
   ELSE
    SELECT INTO "bhs_gen_disch_audit"
     d.seq
     FROM dummyt d
     PLAN (d)
     HEAD REPORT
      cur_dt_tm = format(cnvtdatetime(curdate,curtime3),"MM/DD/YYYY HH:MM:SS;;D"), col 0,
      "******************************* ",
      cur_dt_tm, " *******************************", row + 2
     DETAIL
      FOR (k = 1 TO encntr_count)
        col 0, encntrs->encntr[k].encntr_id, row + 1
      ENDFOR
     WITH append, nocounter
    ;end select
    SET encntrs_processed = (encntrs_processed+ encntr_count)
    FOR (i = 1 TO encntr_count)
     UPDATE  FROM encounter e
      SET e.updt_task = 3366, e.updt_cnt = (e.updt_cnt+ 1), e.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       e.updt_id = 3366, e.encntr_status_cd = 856
      WHERE (e.encntr_id=encntrs->encntr[i].encntr_id)
      WITH nocounter
     ;end update
     IF (((mod(i,10)=0) OR (i=encntr_count)) )
      COMMIT
     ENDIF
    ENDFOR
   ENDIF
   CALL echo(concat("batch ",trim(cnvtstring(qq),3)," of ",trim(cnvtstring(size(rows->qual,5)),3),
     " complete. records processed:",
     trim(cnvtstring(encntrs_processed),3)))
 ENDFOR
 COMMIT
#9999_end_program
END GO
