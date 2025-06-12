CREATE PROGRAM dcp_expire_epr_cleanup
 DECLARE expirecleanup(null) = null
 DECLARE expireduplicates(null) = null
 DECLARE expirecancelledencounter(null) = null
 DECLARE expireinvalidencounter(null) = null
 DECLARE endofdatetime = dq8 WITH constant(cnvtdatetime("31-DEC-2100 00:00:00"))
 DECLARE currentdatetime = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE continue = i2 WITH noconstant(1), private
 DECLARE totalreltnexpired = i4 WITH noconstant(0)
 DECLARE startdttm = dq8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE startdttmtotal = dq8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE cancelledcd = f8 WITH constant(uar_get_code_by("MEANING",261,"CANCELLED")), protect
 CALL expirecleanup(null)
 CALL expireduplicates(null)
 CALL expirecancelledencounter(null)
 CALL expireinvalidencounter(null)
 CALL echo(build("TIMER::Start Time: ",format(startdttmtotal,"@LONGDATETIME")))
 CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
 SUBROUTINE expirecleanup(null)
   CALL echo("LOG::Begin expiring rows that have a prsnl_person_id = 0")
   SET startdttm = cnvtdatetime(curdate,curtime3)
   SET continue = 1
   WHILE (continue=1)
     CALL echo("LOG::Updating current batch of rows")
     UPDATE  FROM encntr_prsnl_reltn epr
      SET epr.expire_dt_tm = cnvtdatetime(currentdatetime), epr.expiration_ind = 1, epr.updt_cnt = (
       epr.updt_cnt+ 1),
       epr.updt_dt_tm = cnvtdatetime(curdate,curtime3), epr.updt_id = reqinfo->updt_id, epr
       .updt_applctx = reqinfo->updt_applctx,
       epr.updt_task = reqinfo->updt_task
      WHERE epr.expiration_ind=0
       AND epr.prsnl_person_id=0
      WITH nocounter, maxqual(epr,5000)
     ;end update
     CALL echo(build("LOG::Updated and Committed: ",curqual,"rows"))
     COMMIT
     IF (curqual < 5000)
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
   CALL echo("LOG::Done expiring rows that have a prsnl_person_id = 0")
   CALL echo(build("TIMER::Start Time: ",format(startdttm,"@LONGDATETIME")))
   CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
   CALL echo("LOG::Begin expiring rows that have a encntr_prsnl_r_cd = 0")
   SET startdttm = cnvtdatetime(curdate,curtime3)
   SET continue = 1
   WHILE (continue=1)
     CALL echo("LOG::Updating current batch of rows")
     UPDATE  FROM encntr_prsnl_reltn epr
      SET epr.expire_dt_tm = cnvtdatetime(currentdatetime), epr.expiration_ind = 1, epr.updt_cnt = (
       epr.updt_cnt+ 1),
       epr.updt_dt_tm = cnvtdatetime(curdate,curtime3), epr.updt_id = reqinfo->updt_id, epr
       .updt_applctx = reqinfo->updt_applctx,
       epr.updt_task = reqinfo->updt_task
      WHERE epr.expiration_ind=0
       AND epr.encntr_prsnl_r_cd=0
      WITH nocounter, maxqual(epr,5000)
     ;end update
     CALL echo(build("LOG::Updated and Committed: ",curqual,"rows"))
     COMMIT
     IF (curqual < 5000)
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
   CALL echo("LOG::Done expiring rows that have a encntr_prsnl_r_cd = 0")
   CALL echo(build("TIMER::Start Time: ",format(startdttm,"@LONGDATETIME")))
   CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
   CALL echo("LOG::Begin expiring rows that have an active_ind = 0")
   SET startdttm = cnvtdatetime(curdate,curtime3)
   SET continue = 1
   WHILE (continue=1)
     CALL echo("LOG::Updating current batch of rows")
     UPDATE  FROM encntr_prsnl_reltn epr
      SET epr.expire_dt_tm = cnvtdatetime(currentdatetime), epr.expiration_ind = 1, epr.updt_cnt = (
       epr.updt_cnt+ 1),
       epr.updt_dt_tm = cnvtdatetime(curdate,curtime3), epr.updt_id = reqinfo->updt_id, epr
       .updt_applctx = reqinfo->updt_applctx,
       epr.updt_task = reqinfo->updt_task
      WHERE epr.expiration_ind=0
       AND epr.active_ind=0
      WITH nocounter, maxqual(epr,5000)
     ;end update
     CALL echo(build("LOG::Updated and Committed: ",curqual,"rows"))
     COMMIT
     IF (curqual < 5000)
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
   CALL echo("LOG::Done expiring rows that have an active_ind = 0")
   CALL echo(build("TIMER::Start Time: ",format(startdttm,"@LONGDATETIME")))
   CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
   CALL echo("LOG::Begin expiring rows that have an end_effective_dt_tm passed")
   SET startdttm = cnvtdatetime(curdate,curtime3)
   SET continue = 1
   WHILE (continue=1)
     CALL echo("LOG::Updating current batch of rows")
     UPDATE  FROM encntr_prsnl_reltn epr
      SET epr.expire_dt_tm = cnvtdatetime(currentdatetime), epr.expiration_ind = 1, epr.updt_cnt = (
       epr.updt_cnt+ 1),
       epr.updt_dt_tm = cnvtdatetime(curdate,curtime3), epr.updt_id = reqinfo->updt_id, epr
       .updt_applctx = reqinfo->updt_applctx,
       epr.updt_task = reqinfo->updt_task
      WHERE epr.expiration_ind=0
       AND epr.end_effective_dt_tm < cnvtdatetime(currentdatetime)
      WITH nocounter, maxqual(epr,5000)
     ;end update
     CALL echo(build("LOG::Updated and Committed: ",curqual,"rows"))
     COMMIT
     IF (curqual < 5000)
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
   CALL echo("LOG::Done expiring rows that have an end_effective_dt_tm passed")
   CALL echo(build("TIMER::Start Time: ",format(startdttm,"@LONGDATETIME")))
   CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
 END ;Subroutine
 SUBROUTINE expireduplicates(null)
   CALL echo(concat(
     "LOG::Begin expiring rows that have a duplicate based on encntr_id, prsnl_person_id, encntr_prsnl_r_cd.",
     "  It must also have a past or 2100 end_effective_dt_tm.  We also don't expire the most recent of the duplicates based ",
     " on encntr_prsnl_reltn_id."))
   SET startdttm = cnvtdatetime(curdate,curtime3)
   SET continue = 1
   WHILE (continue=1)
     CALL echo("LOG::Updating current batch of rows")
     UPDATE  FROM encntr_prsnl_reltn epr4
      SET epr4.expire_dt_tm = cnvtdatetime(curdate,curtime3), epr4.expiration_ind = 1, epr4.updt_cnt
        = (epr4.updt_cnt+ 1),
       epr4.updt_dt_tm = cnvtdatetime(curdate,curtime3), epr4.updt_id = reqinfo->updt_id, epr4
       .updt_applctx = reqinfo->updt_applctx,
       epr4.updt_task = reqinfo->updt_task
      WHERE epr4.encntr_prsnl_reltn_id IN (
      (SELECT
       min(epr2.encntr_prsnl_reltn_id)
       FROM encntr_prsnl_reltn epr2,
        (
        (
        (SELECT
         epr.encntr_id, epr.prsnl_person_id, epr.encntr_prsnl_r_cd
         FROM encntr_prsnl_reltn epr
         WHERE epr.expiration_ind=0
          AND epr.end_effective_dt_tm > sysdate
          AND epr.beg_effective_dt_tm < sysdate
          AND epr.active_ind=1
         GROUP BY epr.encntr_id, epr.prsnl_person_id, epr.encntr_prsnl_r_cd
         HAVING count(*) > 1
         WITH sqltype("f8","f8","f8")))
        epr3)
       WHERE epr2.encntr_id=epr3.encntr_id
        AND epr2.prsnl_person_id=epr3.prsnl_person_id
        AND epr2.encntr_prsnl_r_cd=epr3.encntr_prsnl_r_cd
        AND epr2.expiration_ind=0
        AND epr2.end_effective_dt_tm > sysdate
        AND epr2.beg_effective_dt_tm < sysdate
        AND epr2.active_ind=1
       GROUP BY epr2.encntr_id, epr2.prsnl_person_id, epr2.encntr_prsnl_r_cd))
      WITH maxqual(epr4,5000)
     ;end update
     CALL echo(build("LOG::Updated and Committed: ",curqual,"rows"))
     COMMIT
     IF (curqual=0)
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
   CALL echo(concat(
     "LOG::Done expiring rows that have a duplicate based on encntr_id, prsnl_person_id, encntr_prsnl_r_cd.",
     "  It must also have a past or 2100 end_effective_dt_tm.  We also don't expire the most recent of the duplicates based ",
     " on encntr_prsnl_reltn_id."))
   CALL echo(build("TIMER::Start Time: ",format(startdttm,"@LONGDATETIME")))
   CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
 END ;Subroutine
 SUBROUTINE expirecancelledencounter(null)
   CALL echo(concat("LOG::Begin ExpireCancelledEncounter"))
   SET startdttm = cnvtdatetime(curdate,curtime3)
   CALL echo("LOG::Updating current batch of rows")
   UPDATE  FROM encntr_prsnl_reltn epr
    SET epr.expire_dt_tm = cnvtdatetime(curdate,curtime3), epr.expiration_ind = 1, epr.updt_cnt = (
     epr.updt_cnt+ 1),
     epr.updt_dt_tm = cnvtdatetime(curdate,curtime3), epr.updt_id = reqinfo->updt_id, epr
     .updt_applctx = reqinfo->updt_applctx,
     epr.updt_task = reqinfo->updt_task
    WHERE epr.expiration_ind=0
     AND epr.encntr_id IN (
    (SELECT
     e.encntr_id
     FROM encounter e
     WHERE ((e.encntr_status_cd=cancelledcd) OR (e.active_ind=0)) ))
    WITH nocounter
   ;end update
   CALL echo(build("LOG::Updated and Committed: ",curqual,"rows"))
   COMMIT
   CALL echo(concat("LOG::End ExpireCancelledEncounter"))
   CALL echo(build("TIMER::Start Time: ",format(startdttm,"@LONGDATETIME")))
   CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
 END ;Subroutine
 SUBROUTINE expireinvalidencounter(null)
   CALL echo(concat("LOG::Begin ExpireInvalidEncounter"))
   SET startdttm = cnvtdatetime(curdate,curtime3)
   CALL echo("LOG::Updating current batch of rows")
   UPDATE  FROM encntr_prsnl_reltn epr
    SET epr.expire_dt_tm = cnvtdatetime(curdate,curtime3), epr.expiration_ind = 1, epr.updt_cnt = (
     epr.updt_cnt+ 1),
     epr.updt_dt_tm = cnvtdatetime(curdate,curtime3), epr.updt_id = reqinfo->updt_id, epr
     .updt_applctx = reqinfo->updt_applctx,
     epr.updt_task = reqinfo->updt_task
    WHERE epr.expiration_ind=0
     AND  NOT (epr.encntr_id IN (
    (SELECT
     e1.encntr_id
     FROM encounter e1)))
    WITH nocounter
   ;end update
   CALL echo(build("LOG::Updated and Committed: ",curqual,"rows"))
   COMMIT
   CALL echo(concat("LOG::End ExpireInvalidEncounter."))
   CALL echo(build("TIMER::Start Time: ",format(startdttm,"@LONGDATETIME")))
   CALL echo(build("TIMER::End Time: ",format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")))
 END ;Subroutine
END GO
