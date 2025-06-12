CREATE PROGRAM bhs_ma_purge_encntr_domain:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH noconstant(""), private
 ENDIF
 SET last_mod = "ZS002"
 SET last_mod = "43935"
 SET last_mod = "47589"
 SET last_mod = "47589b"
 FREE RECORD reply
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 DECLARE cancelled_cd = f8 WITH noconstant(0.0), public
 DECLARE census_type_cd = f8 WITH noconstant(0.0), public
 DECLARE loops = i4 WITH protect, noconstant(0)
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_purge TO 2999_purge_exit
 GO TO 9999_exit_program
#1000_initialize
 SET reply->status_data.status = "F"
 SET reply->ops_event = "An error occurred in the script (pm_purge_encntr_domain)."
 IF ((validate(days,- (99))=- (99)))
  SET days = 30
 ENDIF
 SET chunk = 10000.0
 ROLLBACK
 SET census_type_cd = uar_get_code_by("MEANING",339,nullterm("CENSUS"))
 SET cancelled_cd = uar_get_code_by("MEANING",261,nullterm("CANCELLED"))
 IF (validate(request->batch_selection,"!") != "!")
  SET temp_days = cnvtint(request->batch_selection)
  IF (temp_days > 0)
   SET days = temp_days
  ENDIF
 ENDIF
 DECLARE bpurgeopt = i2 WITH noconstant(false)
 DECLARE dpurgecmb = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(20790,"PURGECMB",1,dpurgecmb)
 SELECT INTO "nl:"
  FROM code_value_extension cve
  WHERE cve.code_value=dpurgecmb
   AND cve.field_name="OPTION"
   AND cve.code_set=20790
  DETAIL
   IF (trim(cve.field_value,3)="1")
    bpurgeopt = true
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(" ")
#1999_initialize_exit
#2000_purge
 SET min_encntr_domain_id = 0.0
 SET max_encntr_domain_id = 0.0
 SET loops = 0
 SET start_id = 0.0
 SET finish_id = 0.0
 SET counter = 0
 SET flag = 1
 SET i = 0
 SET x = 0.0
 WHILE (flag)
   SET flag = 0
   SET x += 1
   SET max_encntr_domain_id = (x * chunk)
   SELECT INTO "nl:"
    d.encntr_domain_id
    FROM encntr_domain d
    WHERE d.encntr_domain_id > max_encntr_domain_id
    DETAIL
     flag = 1
    WITH nocounter, maxqual(d,1)
   ;end select
 ENDWHILE
 SET loops = (cnvtint((max_encntr_domain_id/ chunk))+ 1)
 CALL echo(loops)
 FOR (i = 1 TO loops)
   SET start_id = (chunk * (i - 1))
   SET finish_id = ((start_id+ chunk) - 1)
   CALL echo(concat("Loop ",trim(cnvtstring(i))," of ",trim(cnvtstring(loops)),
     ": Processing IDs from ",
     trim(cnvtstring(start_id),3)," to ",trim(cnvtstring(finish_id),3),"."))
   SET t_side = 0.0
   DELETE  FROM encntr_domain d
    WHERE d.encntr_domain_id IN (
    (SELECT
     ed.encntr_domain_id
     FROM encntr_domain ed,
      encounter e
     WHERE ed.encntr_domain_id BETWEEN start_id AND finish_id
      AND ((ed.encntr_domain_type_cd+ 0)=census_type_cd)
      AND ((ed.end_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
      AND e.encntr_id=ed.encntr_id
      AND ((e.disch_dt_tm+ 0) > cnvtdatetime("01-JAN-1800 00:00:00.00"))
      AND ((e.disch_dt_tm+ 0) <= cnvtdatetime((curdate - days),curtime3))
     WITH nocounter))
    WITH nocounter
   ;end delete
   SET counter += curqual
   DELETE  FROM encntr_domain d
    WHERE d.encntr_domain_id IN (
    (SELECT
     ed.encntr_domain_id
     FROM encntr_domain ed,
      encounter e
     WHERE ed.encntr_domain_id BETWEEN start_id AND finish_id
      AND ((ed.encntr_domain_type_cd+ 0)=census_type_cd)
      AND ed.active_ind=0
      AND e.encntr_id=ed.encntr_id
      AND ((e.encntr_status_cd+ 0)=cancelled_cd)
      AND e.active_ind=0
     WITH nocounter))
    WITH nocounter
   ;end delete
   SET counter += curqual
   COMMIT
   IF (bpurgeopt)
    DELETE  FROM encntr_domain d
     WHERE d.encntr_domain_id IN (
     (SELECT
      ed.encntr_domain_id
      FROM encntr_domain ed
      WHERE ed.encntr_domain_id BETWEEN start_id AND finish_id
       AND ed.encntr_domain_type_cd=census_type_cd
       AND ed.active_ind=0
       AND (ed.active_status_cd=reqdata->combined_cd)
      WITH nocounter))
     WITH nocounter
    ;end delete
    SET counter += curqual
    COMMIT
   ENDIF
   IF (((i=loops) OR (mod(i,10)=0)) )
    CALL echo(" ")
    CALL echo(concat("Total deletes: ",trim(cnvtstring(counter),3),"."))
    CALL echo(" ")
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 IF (counter > 0)
  IF (counter > 1)
   SET reply->ops_event = concat("Successful run.  ",trim(cnvtstring(counter),3)," rows purged.")
  ELSE
   SET reply->ops_event = "Successful run.  1 row purged."
  ENDIF
 ELSE
  SET reply->ops_event = "Successful run.  No rows needed to be purged."
 ENDIF
#2999_purge_exit
#9999_exit_program
END GO
