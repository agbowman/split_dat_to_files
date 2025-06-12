CREATE PROGRAM bhs_disch_cnvt_encntr:dba
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
 SET discharged_cd = uar_get_code_by("meaning",261,"DISCHARGED")
 SET recurringop_cd = uar_get_code_by("displaykey",71,"RECURRINGOP")
 SET dischrecurringop_cd = uar_get_code_by("displaykey",71,"DISCHRECURRINGOP")
 SET onetimeop_cd = uar_get_code_by("displaykey",71,"ONETIMEOP")
 SET preop_cd = uar_get_code_by("displaykey",71,"PREOUTPT")
 SET conversion_cd = uar_get_code_by("displaykey",34,"CONVERSION")
 FREE SET encntrs
 RECORD encntrs(
   1 qual_cnt = i4
   1 encntr[*]
     2 encntr_id = f8
     2 reg_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 encntr_status = f8
     2 encntr_type = f8
     2 flag = f8
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
    FROM encounter e
    WHERE (e.encntr_id > rows->qual[qq].id_start)
     AND (e.encntr_id <= rows->qual[qq].id_end)
     AND ((e.active_ind+ 0)=1)
     AND ((e.med_service_cd+ 0)=conversion_cd)
     AND ((e.encntr_type_cd+ 0) IN (679655, 679672, 679658, 679653, 679660,
    679654, 309310, 679673, 679664, 679667,
    679682, 679670, 2495726, 679662, 679679,
    679656))
     AND ((e.disch_dt_tm IS NOT null
     AND ((e.encntr_status_cd+ 0) != discharged_cd)) OR (e.disch_dt_tm = null))
    DETAIL
     encntr_count = (encntr_count+ 1)
     IF (mod(encntr_count,10)=1)
      stat = alterlist(encntrs->encntr,(encntr_count+ 10))
     ENDIF
     encntrs->encntr[encntr_count].encntr_id = e.encntr_id, encntrs->encntr[encntr_count].reg_dt_tm
      = cnvtdatetime(e.reg_dt_tm), encntrs->encntr[encntr_count].encntr_status = e.encntr_status_cd,
     encntrs->encntr[encntr_count].encntr_type = e.encntr_type_cd, encntrs->encntr[encntr_count].
     disch_dt_tm = cnvtdatetime(e.disch_dt_tm)
    FOOT REPORT
     stat = alterlist(encntrs->encntr,encntr_count)
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
      IF ((encntrs->encntr[x].reg_dt_tm > 0))
       UPDATE  FROM encounter e
        SET e.updt_task = 99999, e.updt_cnt = (e.updt_cnt+ 1), e.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         e.updt_id = 99999, e.encntr_status_cd = 856, e.disch_dt_tm = e.reg_dt_tm
        WHERE (e.encntr_id=encntrs->encntr[i].encntr_id)
        WITH nocounter, maxcommit = 100
       ;end update
       COMMIT
      ELSE
       UPDATE  FROM encounter e
        SET e.updt_task = 99999, e.updt_cnt = (e.updt_cnt+ 1), e.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         e.updt_id = 99999, e.encntr_status_cd = 856, e.disch_dt_tm = e.create_dt_tm
        WHERE (e.encntr_id=encntrs->encntr[i].encntr_id)
        WITH nocounter, maxcommit = 100
       ;end update
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
