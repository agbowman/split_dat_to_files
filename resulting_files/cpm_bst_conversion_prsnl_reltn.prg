CREATE PROGRAM cpm_bst_conversion_prsnl_reltn
 DECLARE to_europe_london_tz_plsql(dttm) = c255
 DECLARE loopflag = i4 WITH noconstant(1)
 DECLARE last_reltn_id = f8 WITH noconstant(0.0)
 DECLARE first_time = i2 WITH noconstant(0)
 DECLARE qual_size = i4 WITH noconstant(0)
 DECLARE total_cnt = i4 WITH noconstant(0)
 DECLARE sinfodomainreltn = vc WITH constant("CPM_BST_CONVERSION_PRSNL_RELTN")
 SET statusmsg = fillstring(132," ")
 SET errormsg = fillstring(132," ")
 SET status = "S"
 FREE RECORD reltn_rec
 RECORD reltn_rec(
   1 qual[*]
     2 reltn_id = f8
     2 local_beg_eff_dt_tm = dq8
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
 CALL echo("   PERSON_PRSNL_RELTN")
 CALL echo("")
 CALL echo("   Use the CPM_BST_CONVERSION_PERSON utility to update the")
 CALL echo("   PERSON table.")
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
 CALL echo("Processing the PERSON_PRSNL_RELTN table...")
 SET statusmsg = concat("   Contributor System CD: ",cnvtstring(contrib_system_cd))
 CALL echo(statusmsg)
 CALL echo("")
 WHILE (loopflag=1)
   SELECT INTO "nl:"
    d.info_number
    FROM dm_info d
    WHERE d.info_domain=sinfodomainreltn
     AND d.info_name=cnvtstring(contrib_system_cd)
    DETAIL
     last_reltn_id = d.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET last_reltn_id = - (1.0)
    SET first_time = 1
   ENDIF
   SELECT INTO "nl:"
    ppr.person_prsnl_reltn_id, temp_local_beg_eff_dt_tm = cnvtdatetime(to_europe_london_tz_plsql(ppr
      .beg_effective_dt_tm))
    FROM person_prsnl_reltn ppr
    WHERE ppr.person_prsnl_reltn_id > last_reltn_id
     AND (ppr.updt_id=- (10000))
     AND ppr.contributor_system_cd=contrib_system_cd
    HEAD REPORT
     stat = alterlist(reltn_rec->qual,10000), qual_size = 0
    DETAIL
     qual_size = (qual_size+ 1), reltn_rec->qual[qual_size].reltn_id = ppr.person_prsnl_reltn_id,
     reltn_rec->qual[qual_size].local_beg_eff_dt_tm = temp_local_beg_eff_dt_tm
    FOOT REPORT
     stat = alterlist(reltn_rec->qual,qual_size)
    WITH forupdate(ppr), maxrec = 10000, nocounter
   ;end select
   IF (qual_size < 10000)
    SET loopflag = 0
   ENDIF
   UPDATE  FROM (dummyt d  WITH seq = value(qual_size)),
     person_prsnl_reltn ppr
    SET ppr.beg_effective_dt_tm = cnvtdatetimeutc(reltn_rec->qual[d.seq].local_beg_eff_dt_tm,3), ppr
     .updt_id = - (11073.00)
    PLAN (d)
     JOIN (ppr
     WHERE (ppr.person_prsnl_reltn_id=reltn_rec->qual[d.seq].reltn_id)
      AND ppr.beg_effective_dt_tm != cnvtdatetimeutc(reltn_rec->qual[d.seq].local_beg_eff_dt_tm,3))
    WITH nocounter
   ;end update
   SET last_reltn_id = reltn_rec->qual[qual_size].reltn_id
   IF (first_time=1)
    SET first_time = 0
    INSERT  FROM dm_info d
     SET d.info_domain = sinfodomainreltn, d.info_name = cnvtstring(contrib_system_cd), d.info_number
       = last_reltn_id
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = last_reltn_id
     WHERE d.info_domain=sinfodomainreltn
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
   CALL echo("Processing the PERSON_PRSNL_RELTN table...")
   SET statusmsg = concat("   Contributor System CD: ",cnvtstring(contrib_system_cd))
   CALL echo(statusmsg)
   SET statusmsg = concat("   Records Completed:     ",cnvtstring(total_cnt))
   CALL echo(statusmsg)
   CALL echo("")
 ENDWHILE
#exit_script
 IF (status="S")
  CALL echo("PERSON_PRSNL_RELTN table successfully updated.")
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
