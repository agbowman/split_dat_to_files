CREATE PROGRAM dm_rpt_bad_combines:dba
 PROMPT
  "Enter Person or Encounter type (default Person):  " = "P"
 IF (build( $1)="")
  IF (curenv=0)
   CALL echo(concat("Usage:  ",curprog," 'PERSON' GO"))
  ENDIF
  GO TO exit_program
 ENDIF
 SET c_mod = "DM_RPT_BAD_COMBINES 000"
 EXECUTE FROM 1000_init_start TO 1000_init_end
 SET drbc->i_type = substring(1,1,cnvtupper( $1))
 CASE (drbc->i_type)
  OF "P":
   SET drbc->i_type = "PERSON"
  OF "E":
   SET drbc->i_type = "ENCNTR"
  ELSE
   CALL echo(concat("Usage: ",curprog," 'PERSON' GO"))
   GO TO exit_program
 ENDCASE
 CASE (drbc->i_type)
  OF "PERSON":
   SET drbc->stat = drbc_sub_person(1)
  OF "ENCNTR":
   CALL echo("Report for encounter combines not available.")
   GO TO exit_program
 ENDCASE
 IF ((drbc->stat=0))
  CALL echo("Report didn't successfully run to retrieve initial rows.  Discontinuing activity.")
  GO TO exit_program
 ENDIF
 CASE (drbc->i_type)
  OF "PERSON":
   SET drbc->stat = drbc_sub_get_other_p(1)
  OF "ENCNTR":
   SET drbc->stat = drbc_sub_get_other_e(1)
 ENDCASE
 IF ((drbc->stat=0))
  CALL echo("Report didn't successfully run to retrieve additional rows.  Discontinuing activity.")
  GO TO exit_program
 ENDIF
 SET drbc->stat = drbc_sub_create_report(1)
 GO TO exit_program
#1000_init_start
 FREE RECORD rec_c
 RECORD rec_c(
   1 qual[*]
     2 c_id = f8
     2 c_to_id = f8
     2 problem_ind = i4
     2 cqual[*]
       3 to_id = f8
       3 from_id = f8
       3 active_ind = i4
       3 active_status_cd = f8
       3 updt_dt_tm = f8
       3 to_fullname = vc
       3 to_active_ind = i4
       3 to_active_status_cd = f8
       3 fr_fullname = vc
       3 fr_active_ind = i4
       3 fr_active_status_cd = f8
 )
 FREE RECORD drbc
 RECORD drbc(
   1 active_cd = f8
   1 combine_cd = f8
   1 inactive_cd = f8
   1 cnt = i4
   1 qcnt = i4
   1 stat = i4
   1 i_type = vc
   1 ok = i4
   1 str = vc
   1 rpt_str = vc
   1 combine_id_lbl = vc
 )
 DECLARE drbc_i = i4
 DECLARE drbc_j = i4
 DECLARE drbc_sub_person(0) = i4
 DECLARE drbc_sub_encntr(0) = i4
#1000_init_end
 SUBROUTINE drbc_sub_person(p_ind1)
   SET drbc->cnt = 0
   SET drbc->stat = 0
   SELECT DISTINCT INTO "nl:"
    pc.from_person_id, pc.to_person_id
    FROM person_combine pc
    PLAN (pc
     WHERE pc.encntr_id=0
      AND pc.active_ind=1)
    ORDER BY pc.from_person_id, pc.to_person_id, pc.updt_dt_tm DESC
    DETAIL
     drbc->cnt += 1
     IF (mod(drbc->cnt,10)=1)
      drbc->stat = alterlist(rec_c->qual,(drbc->cnt+ 9))
     ENDIF
     rec_c->qual[drbc->cnt].c_id = pc.from_person_id, rec_c->qual[drbc->cnt].c_to_id = pc
     .to_person_id, drbc->stat = alterlist(rec_c->qual[drbc->cnt].cqual,1),
     rec_c->qual[drbc->cnt].cqual[1].to_id = rec_c->qual[drbc->cnt].c_to_id, rec_c->qual[drbc->cnt].
     cqual[1].from_id = rec_c->qual[drbc->cnt].c_id
    FOOT REPORT
     drbc->stat = alterlist(rec_c->qual,drbc->cnt), drbc->stat = 1
    WITH nocounter
   ;end select
   RETURN(drbc->stat)
 END ;Subroutine
 SUBROUTINE drbc_sub_encntr(p_ind2)
   SET drbc->cnt = 0
   SET drbc->stat = 0
   SELECT INTO "nl:"
    pc.from_encntr_id
    FROM encntr_combine ec
    PLAN (ec
     WHERE ec.active_ind=1)
    ORDER BY ec.from_encntr_id, ec.updt_dt_tm DESC
    DETAIL
     drbc->cnt += 1
     IF (mod(drbc->cnt,10)=1)
      drbc->stat = alterlist(rec_c->qual,(drbc->cnt+ 9))
     ENDIF
     rec_c->qual[drbc->cnt].c_id = ec.from_encntr_id, rec_c->qual[drbc->cnt].c_to_id = ec
     .to_encntr_id, drbc->stat = alterlist(rec_c->qual[drbc->cnt].cqual,1),
     rec_c->qual[drbc->cnt].cqual[1].to_id = rec_c->qual[drbc->cnt].c_to_id, rec_c->qual[drbc->cnt].
     cqual[1].from_id = rec_c->qual[drbc->cnt].c_id
    FOOT REPORT
     drbc->stat = alterlist(rec_c->qual,drbc->cnt), drbc->stat = 1
    WITH nocounter
   ;end select
   RETURN(drbc->stat)
 END ;Subroutine
 SUBROUTINE drbc_sub_get_other_p(p_ind3)
   SET c_id = 0.0
   SET drbc->ok = 1
   SET rec_c->qual[drbc->cnt].problem_ind = 0
   SET drbc->qcnt = size(rec_c->qual,5)
   FOR (drbc_j = 1 TO drbc->qcnt)
     SET drbc->cnt = size(rec_c->qual[drbc_j].cqual,5)
     SET c_id = rec_c->qual[drbc_j].c_to_id
     CALL echo(concat("Processing data for person_id: ",build(cnvtint(rec_c->qual[drbc_j].c_id))),1,0
      )
     SET drbc->ok = 1
     WHILE (drbc->ok)
       SET drbc->ok = 0
       SELECT INTO "nl:"
        pc.to_person_id
        FROM person_combine pc,
         person p,
         person p2
        PLAN (pc
         WHERE pc.from_person_id=c_id
          AND pc.encntr_id=0
          AND pc.active_ind=1)
         JOIN (p
         WHERE p.person_id=pc.to_person_id)
         JOIN (p2
         WHERE p2.person_id=pc.from_person_id)
        ORDER BY pc.updt_dt_tm DESC
        HEAD REPORT
         detail_cnt = 0
        DETAIL
         drbc->ok = 1, detail_cnt += 1
         IF (detail_cnt=1)
          drbc->cnt += 1, drbc->stat = alterlist(rec_c->qual[drbc_j].cqual,drbc->cnt), c_id = pc
          .to_person_id,
          rec_c->qual[drbc_j].cqual[drbc->cnt].to_id = c_id, rec_c->qual[drbc_j].cqual[drbc->cnt].
          from_id = pc.from_person_id, rec_c->qual[drbc_j].cqual[drbc->cnt].to_fullname = p
          .name_full_formatted,
          rec_c->qual[drbc_j].cqual[drbc->cnt].to_active_ind = p.active_ind, rec_c->qual[drbc_j].
          cqual[drbc->cnt].to_active_status_cd = p.active_status_cd, rec_c->qual[drbc_j].cqual[drbc->
          cnt].fr_fullname = p2.name_full_formatted,
          rec_c->qual[drbc_j].cqual[drbc->cnt].fr_active_ind = p2.active_ind, rec_c->qual[drbc_j].
          cqual[drbc->cnt].fr_active_status_cd = p2.active_status_cd
         ENDIF
        WITH nocounter
       ;end select
       IF (drbc->ok)
        FOR (drbc_i = 1 TO drbc->cnt)
          IF ((c_id=rec_c->qual[drbc_j].cqual[drbc_i].from_id))
           IF (drbc_i=1)
            SET rec_c->qual[drbc_j].problem_ind = 1
           ENDIF
           SET drbc_i = drbc->cnt
           SET drbc->ok = 0
          ENDIF
        ENDFOR
       ENDIF
     ENDWHILE
     IF ((rec_c->qual[drbc_j].problem_ind=0))
      SET drbc->stat = alterlist(rec_c->qual[drbc_j].cqual,0)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE drbc_sub_get_other_e(p_ind4)
   SET c_id = 0.0
   SET drbc->ok = 1
   SET rec_c->qual[drbc->cnt].problem_ind = 0
   SET drbc->qcnt = size(rec_c->qual,5)
   FOR (drbc_j = 1 TO drbc->qcnt)
     SET drbc->cnt = 0
     SET c_id = rec_c->qual[drbc_j].c_id
     CALL echo(concat("Processing data for encntr_id: ",build(c_id)),1,0)
     SET drbc->ok = 1
     WHILE (drbc->ok)
       SET drbc->ok = 0
       SELECT INTO "nl:"
        ec.to_person_id
        FROM encntr_combine ec
        WHERE ec.from_encntr_id=c_id
         AND ec.encntr_id=0
         AND ec.active_ind=1
        ORDER BY ec.updt_dt_tm DESC
        DETAIL
         drbc->ok = 1, drbc->cnt += 1, drbc->stat = alterlist(rec_c->qual[drbc_j].cqual,drbc->cnt),
         c_id = ec.to_encntr_id, rec_c->qual[drbc_j].cqual[drbc->cnt].to_id = c_id, rec_c->qual[
         drbc_j].cqual[drbc->cnt].from_id = ec.from_encntr_id,
         rec_c->qual[drbc_j].cqual[drbc->cnt].active_ind = ec.active_ind, rec_c->qual[drbc_j].cqual[
         drbc->cnt].active_status_cd = ec.active_status_cd, rec_c->qual[drbc_j].cqual[drbc->cnt].
         updt_dt_tm = cnvtreal(ec.updt_dt_tm)
        WITH nocounter
       ;end select
       IF (drbc->ok)
        FOR (drbc_i = 1 TO (drbc->cnt - 1))
          IF ((c_id=rec_c->qual[drbc_j].cqual[drbc_i].from_id))
           SET rec_c->qual[drbc_j].problem_ind = 1
           SET drbc_i = drbc->cnt
           SET drbc->ok = 0
          ENDIF
        ENDFOR
       ENDIF
     ENDWHILE
     IF ((rec_c->qual[drbc_j].problem_ind=0))
      SET drbc->stat = alterlist(rec_c->qual[drbc_j].cqual,0)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE drbc_sub_create_report(p_ind5)
   CASE (drbc->i_type)
    OF "PERSON":
     SET drbc->combine_id_lbl = "Person_combine_id: "
    OF "ENCNTR":
     SET drbc->combine_id_lbl = "Encntr_combine_id: "
   ENDCASE
   SET drbc->cnt = size(rec_c->qual,5)
   IF ((drbc->cnt > 0))
    SELECT
     IF ((drbc->i_type="PERSON"))
      FROM (dummyt d  WITH seq = value(drbc->cnt)),
       person p
      PLAN (d
       WHERE (rec_c->qual[d.seq].problem_ind=1))
       JOIN (p
       WHERE (p.person_id=rec_c->qual[d.seq].c_id))
     ELSE
      FROM (dummyt d  WITH seq = value(drbc->cnt)),
       encounter e,
       person p
      PLAN (d
       WHERE (rec_c->qual[d.seq].problem_ind=1))
       JOIN (e
       WHERE (e.encntr_id=rec_c->qual[d.seq].c_id))
       JOIN (p
       WHERE p.person_id=e.person_id)
     ENDIF
     p.person_id
     ORDER BY p.person_id
     HEAD REPORT
      stat = 0
     HEAD PAGE
      stat = 0, drbc->str = format(cnvtdatetime(sysdate),";;q"), row 1,
      "Report of problem combines", row + 1, col 0,
      "Date/Time:", drbc->str, row + 1
     DETAIL
      drbc->str = cnvtupper(p.name_full_formatted), drbc->cnt = size(rec_c->qual[d.seq].cqual,5)
      IF ((drbc->i_type="PERSON"))
       drbc->rpt_str = concat("PERSON_ID ",build(cnvtint(p.person_id))," (name: '",drbc->str,
        "') is recursive back to itself.  The last PERSON_ID was ",
        build(cnvtint(rec_c->qual[d.seq].cqual[drbc->cnt].from_id)),".")
      ELSE
       drbc->rpt_str = concat("Encntr_id: ",build(cnvtint(rec_c->qual[d.seq].c_id)),"  Person_id: ",
        build(cnvtint(p.person_id)),"  Name: ",
        drbc->str)
      ENDIF
      row + 1, drbc->rpt_str, drbc->rpt_str = "",
      CALL drbc_subr_active_str(p.active_ind), drbc->rpt_str = concat(drbc->str," person_id ",build(
        cnvtint(rec_c->qual[d.seq].c_id))," is combined into"),
      CALL drbc_subr_active_str(rec_c->qual[d.seq].cqual[2].fr_active_ind),
      drbc->rpt_str = concat(drbc->rpt_str," ",drbc->str," person_id ",build(cnvtint(rec_c->qual[d
         .seq].cqual[2].from_id))), row + 1, drbc->rpt_str
      FOR (drbc_i = 2 TO drbc->cnt)
        drbc->rpt_str = "",
        CALL drbc_subr_active_str(rec_c->qual[d.seq].cqual[drbc_i].fr_active_ind), drbc->rpt_str =
        concat(drbc->str," person_id ",build(cnvtint(rec_c->qual[d.seq].cqual[drbc_i].from_id)),
         " is combined into"),
        CALL drbc_subr_active_str(rec_c->qual[d.seq].cqual[drbc_i].to_active_ind), drbc->rpt_str =
        concat(drbc->rpt_str," ",drbc->str," person_id ",build(cnvtint(rec_c->qual[d.seq].cqual[
           drbc_i].to_id))), row + 1,
        drbc->rpt_str
      ENDFOR
      row + 1,
      SUBROUTINE drbc_subr_active_str(p_active_ind)
        IF (p_active_ind=1)
         drbc->str = "ACTIVE"
        ELSE
         drbc->str = "INACTIVE"
        ENDIF
      END ;Subroutine report
     WITH nocounter, maxcol = 400
    ;end select
   ENDIF
 END ;Subroutine
#exit_program
END GO
