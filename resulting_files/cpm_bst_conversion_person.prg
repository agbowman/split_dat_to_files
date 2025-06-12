CREATE PROGRAM cpm_bst_conversion_person
 DECLARE to_europe_london_tz_plsql(dttm) = c255
 DECLARE loopflag = i4 WITH noconstant(1)
 DECLARE last_person_id = f8 WITH noconstant(0.0)
 DECLARE first_time = i2 WITH noconstant(0)
 DECLARE qual_size = i4 WITH noconstant(0)
 DECLARE total_cnt = i4 WITH noconstant(0)
 DECLARE sinfodomainperson = vc WITH constant("CPM_BST_CONVERSION_PERSON")
 SET statusmsg = fillstring(132," ")
 SET errormsg = fillstring(132," ")
 SET status = "S"
 FREE RECORD person_rec
 RECORD person_rec(
   1 qual[*]
     2 person_id = f8
     2 local_birth_dt_tm = dq8
     2 local_deceased_dt_tm = dq8
 )
 IF ((xxcclseclogin->loggedin=0))
  EXECUTE cclseclogin2
 ENDIF
 IF ((xxcclseclogin->loggedin=0))
  SET status = "L"
  GO TO exit_script
 ENDIF
 CALL clear(1,1)
 CALL echo("BRITISH SUMMER TIME CONVERSION UTILITY")
 CALL echo("")
 CALL echo("Purpose:")
 CALL echo("   This utility is designed to modify dates that have been converted")
 CALL echo("   by Orcale rules to UTC during the MPI upload of person data.  Once")
 CALL echo("   completed, the dates and times will correspond to the rules used")
 CALL echo("   by Millennium systems for UTC conversions.")
 CALL echo("")
 CALL echo("Table(s) Updated:")
 CALL echo("   PERSON")
 CALL echo("")
 CALL echo("   Use the CPM_BST_CONVERSION_PRSNL_RELTN utility to update")
 CALL echo("   the PERSON_PRSNL_RELTN table.")
 CALL echo("")
 CALL video(n)
 CALL echo("*** Do not continue with this utility unless  ***")
 CALL echo("*** instructed to by the Cerner project team. ***")
 CALL video(l)
 CALL echo("")
 CALL echo("")
 CALL echo("DO YOU WISH TO CONTINUE? (Y/N)")
 CALL accept(19,33,"P;CU","N"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  CALL clear(1,1)
  SET status = "C"
  GO TO exit_script
 ENDIF
 IF (curutc=0)
  CALL clear(1,1)
  SET status = "U"
  GO TO exit_script
 ENDIF
 CALL clear(1,1)
 CALL echo("ENTER CONTRIBUTOR_SYSTEM_CD: ")
 CALL accept(1,30,"N(15);CH","0.00")
 SET contrib_system_cd = cnvtreal(curaccept)
 CALL video(l)
 CALL clear(1,1)
 SET errorcode = error(errormsg,1)
 SET errorcode = 0
 SET message = noinformation
 CALL echo("Processing the PERSON table...")
 SET statusmsg = concat("   Contributor System CD: ",cnvtstring(contrib_system_cd))
 CALL echo(statusmsg)
 CALL echo("")
 WHILE (loopflag=1)
   SELECT INTO "nl:"
    d.info_number
    FROM dm_info d
    WHERE d.info_domain=sinfodomainperson
     AND d.info_name=cnvtstring(contrib_system_cd)
    DETAIL
     last_person_id = d.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET last_person_id = - (1.0)
    SET first_time = 1
   ENDIF
   SELECT INTO "nl:"
    p.person_id, temp_birth_dt_tm = cnvtdatetime(to_europe_london_tz_plsql(p.birth_dt_tm)),
    temp_deceased_dt_tm = cnvtdatetime(to_europe_london_tz_plsql(p.deceased_dt_tm))
    FROM person p
    WHERE p.person_id > last_person_id
     AND (p.updt_id=- (10000))
     AND p.contributor_system_cd=contrib_system_cd
    HEAD REPORT
     stat = alterlist(person_rec->qual,10000), qual_size = 0
    DETAIL
     qual_size = (qual_size+ 1), person_rec->qual[qual_size].person_id = p.person_id, person_rec->
     qual[qual_size].local_birth_dt_tm = temp_birth_dt_tm,
     person_rec->qual[qual_size].local_deceased_dt_tm = temp_deceased_dt_tm
    FOOT REPORT
     stat = alterlist(person_rec->qual,qual_size)
    WITH forupdate(p), maxrec = 10000, nocounter
   ;end select
   IF (qual_size < 10000)
    SET loopflag = 0
   ENDIF
   UPDATE  FROM (dummyt d  WITH seq = value(qual_size)),
     person p
    SET p.birth_dt_tm = cnvtdatetimeutc(person_rec->qual[d.seq].local_birth_dt_tm,3), p
     .deceased_dt_tm = cnvtdatetimeutc(person_rec->qual[d.seq].local_deceased_dt_tm,3), p.updt_id =
     - (11073.00)
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=person_rec->qual[d.seq].person_id)
      AND ((p.birth_dt_tm != cnvtdatetimeutc(person_rec->qual[d.seq].local_birth_dt_tm,3)) OR (p
     .deceased_dt_tm != cnvtdatetimeutc(person_rec->qual[d.seq].local_deceased_dt_tm,3))) )
    WITH nocounter
   ;end update
   SET last_person_id = person_rec->qual[qual_size].person_id
   IF (first_time=1)
    SET first_time = 0
    INSERT  FROM dm_info d
     SET d.info_domain = sinfodomainperson, d.info_name = cnvtstring(contrib_system_cd), d
      .info_number = last_person_id
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = last_person_id
     WHERE d.info_domain=sinfodomainperson
      AND d.info_name=cnvtstring(contrib_system_cd)
     WITH nocounter
    ;end update
   ENDIF
   SET errorcode = error(errormsg,0)
   IF (errorcode=1)
    SET status = "F"
    GO TO exit_script
   ENDIF
   COMMIT
   SET total_cnt = (total_cnt+ qual_size)
   CALL echo("Processing the PERSON table...")
   SET statusmsg = concat("   Contributor System CD: ",cnvtstring(contrib_system_cd))
   CALL echo(statusmsg)
   SET statusmsg = concat("   Records Completed:     ",cnvtstring(total_cnt))
   CALL echo(statusmsg)
   CALL echo("")
 ENDWHILE
#exit_script
 IF (status="S")
  CALL echo("PERSON table successfully updated.")
  CALL echo("")
 ELSEIF (status="L")
  CALL echo("Login Failed...")
  CALL echo("")
 ELSEIF (status="C")
  CALL echo("Utility cancelled by user...")
  CALL echo("")
 ELSEIF (status="U")
  CALL echo("Database is not in UTC mode.  This utility")
  CALL echo("does not need to be run for a non-UTC database.")
  CALL echo("")
 ELSE
  ROLLBACK
  CALL echo("The following error has occurred...")
  CALL echo(errormsg)
 ENDIF
END GO
