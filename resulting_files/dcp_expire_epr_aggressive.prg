CREATE PROGRAM dcp_expire_epr_aggressive
 PROMPT
  "Days Discharged (0 to not use): " = "30",
  "Discharge Exception Code (0 to not use): " = "0",
  "Days Admitted (0 to not use): " = "0",
  "Admitted Exception Code (0 to not use): " = "0",
  "Days Begin Effective (0 to not use): " = "0",
  "Begin Effective Exception Code (0 to not use): " = "0",
  "Days Encounter Inactive (0 to not use): " = "0",
  "Encounter Inactive Exception Code (0 to not use): " = "0"
  WITH dischdays, dischexceptioncd, admitdays,
  admitexceptioncd, begineffdays, begineffexceptioncd,
  inacencdays, inacencexceptioncd
 DECLARE expireaggressive(null) = null
 DECLARE endofdatetime = dq8 WITH constant(cnvtdatetime("31-DEC-2100 00:00:00"))
 DECLARE currentdatetime = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE continue = i2 WITH noconstant(1), private
 DECLARE totalreltnexpired = i4 WITH noconstant(0)
 DECLARE startdttm = dq8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE startdttmtotal = dq8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 CALL expireaggressive(null)
 CALL echo(build("TIMER::Start Time: ",format(startdttmtotal,"@LONGDATETIME")))
 CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
 SUBROUTINE expireaggressive(null)
   IF (cnvtint( $DISCHDAYS) > 0)
    CALL echo(build2chk(
      "LOG::Begin expiring rows that have an end_effective_dt_tm of 2100 and have an ",
      "encounter that has been discharged for more than ", $DISCHDAYS," days in the past."))
    IF (cnvtint( $DISCHEXCEPTIONCD) > 0)
     CALL echo(build2chk("LOG::Excluding rows where encntr_prsnl_r_cd = ", $DISCHEXCEPTIONCD))
    ENDIF
    SET startdttm = cnvtdatetime(curdate,curtime3)
    SET continue = 1
    WHILE (continue=1)
      CALL echo("LOG::Updating current batch of rows")
      UPDATE  FROM encntr_prsnl_reltn epr
       SET epr.expire_dt_tm = cnvtdatetime(curdate,curtime3), epr.expiration_ind = 1, epr.updt_cnt =
        (epr.updt_cnt+ 1),
        epr.updt_dt_tm = cnvtdatetime(curdate,curtime3), epr.updt_id = reqinfo->updt_id, epr
        .updt_applctx = reqinfo->updt_applctx,
        epr.updt_task = reqinfo->updt_task
       WHERE epr.encntr_prsnl_reltn_id IN (
       (SELECT
        epr2.encntr_prsnl_reltn_id
        FROM encntr_prsnl_reltn epr2,
         encounter e
        WHERE epr2.expiration_ind=0
         AND epr2.encntr_prsnl_r_cd != cnvtreal( $DISCHEXCEPTIONCD)
         AND ((epr2.encntr_id+ 0)=e.encntr_id)
         AND e.disch_dt_tm <= datetimeadd(cnvtdatetime(curdate,curtime3),- (cnvtint( $DISCHDAYS)))
         AND epr2.end_effective_dt_tm >= cnvtdatetime(endofdatetime)
         AND sqlpassthru(" rownum < 5000")))
       WITH nocounter
      ;end update
      CALL echo(build("LOG::Updated and Committed: ",curqual,"rows"))
      COMMIT
      IF (curqual < 4999)
       SET continue = 0
       CALL echo("LOG::This was the last batch.")
       SET totalreltnexpired = (totalreltnexpired+ curqual)
       CALL echo(build("LOG::Total rows committed: ",totalreltnexpired))
      ELSE
       SET totalreltnexpired = (totalreltnexpired+ curqual)
       CALL echo(build("LOG::Total rows committed so far: ",totalreltnexpired))
       CALL echo("LOG::Start next batch")
      ENDIF
    ENDWHILE
    CALL echo(build2chk(
      "LOG::Done expiring rows that have an end_effective_dt_tm of 2100 and have an ",
      "encounter that has been discharged for more than ", $DISCHDAYS," days in the past."))
    CALL echo(build("TIMER::Start Time: ",format(startdttm,"@LONGDATETIME")))
    CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
   ENDIF
   IF (cnvtint( $ADMITDAYS) > 0)
    CALL echo(build2chk(
      "LOG::Begin expiring rows that have an end_effective_dt_tm of 2100 and have an ",
      "encounter that has been admitted for more than ", $ADMITDAYS," days in the past."))
    IF (cnvtint( $ADMITEXCEPTIONCD) > 0)
     CALL echo(build2chk("LOG::Excluding rows where encntr_prsnl_r_cd = ", $ADMITEXCEPTIONCD))
    ENDIF
    SET startdttm = cnvtdatetime(curdate,curtime3)
    SET continue = 1
    WHILE (continue=1)
      CALL echo("LOG::Updating current batch of rows")
      UPDATE  FROM encntr_prsnl_reltn epr
       SET epr.expire_dt_tm = cnvtdatetime(curdate,curtime3), epr.expiration_ind = 1, epr.updt_cnt =
        (epr.updt_cnt+ 1),
        epr.updt_dt_tm = cnvtdatetime(curdate,curtime3), epr.updt_id = reqinfo->updt_id, epr
        .updt_applctx = reqinfo->updt_applctx,
        epr.updt_task = reqinfo->updt_task
       WHERE epr.encntr_prsnl_reltn_id IN (
       (SELECT
        epr2.encntr_prsnl_reltn_id
        FROM encntr_prsnl_reltn epr2,
         encounter e
        WHERE epr2.expiration_ind=0
         AND epr2.encntr_prsnl_r_cd != cnvtreal( $ADMITEXCEPTIONCD)
         AND ((epr2.encntr_id+ 0)=e.encntr_id)
         AND e.reg_dt_tm <= datetimeadd(cnvtdatetime(curdate,curtime3),- (cnvtint( $ADMITDAYS)))
         AND epr2.end_effective_dt_tm >= cnvtdatetime(endofdatetime)
         AND sqlpassthru(" rownum < 5000")))
       WITH nocounter
      ;end update
      CALL echo(build("LOG::Updated and Committed: ",curqual,"rows"))
      COMMIT
      IF (curqual < 4999)
       SET continue = 0
       CALL echo("LOG::This was the last batch.")
       SET totalreltnexpired = (totalreltnexpired+ curqual)
       CALL echo(build("LOG::Total rows committed: ",totalreltnexpired))
      ELSE
       SET totalreltnexpired = (totalreltnexpired+ curqual)
       CALL echo(build("LOG::Total rows committed so far: ",totalreltnexpired))
       CALL echo("LOG::Start next batch")
      ENDIF
    ENDWHILE
    CALL echo(build2chk(
      "LOG::Done expiring rows that have an end_effective_dt_tm of 2100 and have an ",
      "encounter that has been admitted for more than ", $ADMITDAYS," days in the past."))
    CALL echo(build("TIMER::Start Time: ",format(startdttm,"@LONGDATETIME")))
    CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
   ENDIF
   IF (cnvtint( $BEGINEFFDAYS) > 0)
    CALL echo(build2chk(
      "LOG::Begin expiring rows that have an end_effective_dt_tm of 2100 and have a ",
      "begin effective day greater than ", $BEGINEFFDAYS," days in the past."))
    IF (cnvtint( $BEGINEFFEXCEPTIONCD) > 0)
     CALL echo(build2chk("LOG::Excluding rows where encntr_prsnl_r_cd = ", $BEGINEFFEXCEPTIONCD))
    ENDIF
    SET startdttm = cnvtdatetime(curdate,curtime3)
    SET continue = 1
    WHILE (continue=1)
      CALL echo("LOG::Updating current batch of rows")
      UPDATE  FROM encntr_prsnl_reltn epr
       SET epr.expire_dt_tm = cnvtdatetime(curdate,curtime3), epr.expiration_ind = 1, epr.updt_cnt =
        (epr.updt_cnt+ 1),
        epr.updt_dt_tm = cnvtdatetime(curdate,curtime3), epr.updt_id = reqinfo->updt_id, epr
        .updt_applctx = reqinfo->updt_applctx,
        epr.updt_task = reqinfo->updt_task
       WHERE epr.expiration_ind=0
        AND epr.encntr_prsnl_r_cd != cnvtreal( $BEGINEFFEXCEPTIONCD)
        AND epr.beg_effective_dt_tm <= datetimeadd(cnvtdatetime(curdate,curtime3),- (cnvtint(
          $BEGINEFFDAYS)))
        AND epr.end_effective_dt_tm >= cnvtdatetime(endofdatetime)
        AND sqlpassthru(" rownum < 5000")
       WITH nocounter
      ;end update
      CALL echo(build("LOG::Updated and Committed: ",curqual,"rows"))
      COMMIT
      IF (curqual < 4999)
       SET continue = 0
       CALL echo("LOG::This was the last batch.")
       SET totalreltnexpired = (totalreltnexpired+ curqual)
       CALL echo(build("LOG::Total rows committed: ",totalreltnexpired))
      ELSE
       SET totalreltnexpired = (totalreltnexpired+ curqual)
       CALL echo(build("LOG::Total rows committed so far: ",totalreltnexpired))
       CALL echo("LOG::Start next batch")
      ENDIF
    ENDWHILE
    CALL echo(build2chk(
      "LOG::Done expiring rows that have an end_effective_dt_tm of 2100 and have aa ",
      "begin effective day greater than ", $BEGINEFFDAYS," days in the past."))
    CALL echo(build("TIMER::Start Time: ",format(startdttm,"@LONGDATETIME")))
    CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
   ENDIF
   IF (cnvtint( $INACENCDAYS) > 0)
    CALL echo(build2chk(
      "LOG::Begin expiring rows that have an end_effective_dt_tm of 2100 and have an ",
      "encounter that has been inactive greater than ", $INACENCDAYS," days in the past."))
    IF (cnvtint( $INACENCEXCEPTIONCD) > 0)
     CALL echo(build2chk("LOG::Excluding rows where encntr_prsnl_r_cd = ", $INACENCEXCEPTIONCD))
    ENDIF
    SET startdttm = cnvtdatetime(curdate,curtime3)
    SET continue = 1
    WHILE (continue=1)
      CALL echo("LOG::Updating current batch of rows")
      UPDATE  FROM encntr_prsnl_reltn epr
       SET epr.expire_dt_tm = cnvtdatetime(curdate,curtime3), epr.expiration_ind = 1, epr.updt_cnt =
        (epr.updt_cnt+ 1),
        epr.updt_dt_tm = cnvtdatetime(curdate,curtime3), epr.updt_id = reqinfo->updt_id, epr
        .updt_applctx = reqinfo->updt_applctx,
        epr.updt_task = reqinfo->updt_task
       WHERE epr.encntr_prsnl_reltn_id IN (
       (SELECT
        epr2.encntr_prsnl_reltn_id
        FROM encntr_prsnl_reltn epr2,
         encounter e
        WHERE epr2.expiration_ind=0
         AND epr2.encntr_prsnl_r_cd != cnvtreal( $INACENCEXCEPTIONCD)
         AND ((epr2.encntr_id+ 0)=e.encntr_id)
         AND e.active_ind=0
         AND e.active_status_dt_tm <= datetimeadd(cnvtdatetime(curdate,curtime3),- (cnvtint(
           $INACENCDAYS)))
         AND epr2.end_effective_dt_tm >= cnvtdatetime(endofdatetime)
         AND sqlpassthru(" rownum < 5000")))
       WITH nocounter
      ;end update
      CALL echo(build("LOG::Updated and Committed: ",curqual,"rows"))
      COMMIT
      IF (curqual < 4999)
       SET continue = 0
       CALL echo("LOG::This was the last batch.")
       SET totalreltnexpired = (totalreltnexpired+ curqual)
       CALL echo(build("LOG::Total rows committed: ",totalreltnexpired))
      ELSE
       SET totalreltnexpired = (totalreltnexpired+ curqual)
       CALL echo(build("LOG::Total rows committed so far: ",totalreltnexpired))
       CALL echo("LOG::Start next batch")
      ENDIF
    ENDWHILE
    CALL echo(build2chk(
      "LOG::Done expiring rows that have an end_effective_dt_tm of 2100 and have an ",
      "encounter that nas been inactive greater than ", $INACENCDAYS," days in the past."))
    CALL echo(build("TIMER::Start Time: ",format(startdttm,"@LONGDATETIME")))
    CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
   ENDIF
 END ;Subroutine
END GO
