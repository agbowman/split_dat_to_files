CREATE PROGRAM dm_stat_gather_solcap_test:dba
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 DECLARE mss_capability_name = vc
 DECLARE mss_start_time = dq8
 DECLARE mss_end_time = dq8
 DECLARE script_start_time = dq8
 DECLARE script_end_time = dq8
 DECLARE displaystring = vc
 DECLARE issuecount = i4
 DECLARE idx = i4 WITH noconstant, protect
 DECLARE idx2 = i4 WITH noconstant, protect
 DECLARE idx3 = i4 WITH noconstant, protect
 DECLARE d_err_msg = c132
 FREE RECORD request
 RECORD request(
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
 )
 FREE RECORD reply
 RECORD reply(
   1 solcap[*]
     2 identifier = vc
     2 degree_of_use_num = i4
     2 degree_of_use_str = vc
     2 distinct_user_count = i4
     2 position[*]
       3 display = vc
       3 value_num = i4
       3 value_str = vc
     2 facility[*]
       3 display = vc
       3 value_num = i4
       3 value_str = vc
     2 other[*]
       3 category_name = vc
       3 value[*]
         4 display = vc
         4 value_num = i4
         4 value_str = vc
 )
 FREE RECORD issues
 RECORD issues(
   1 issue[*]
     2 issuetext = vc
 )
 SET prev_date = cnvtdate(datetimeadd(cnvtdatetime(curdate,0),- (1)))
 SET default_from_dt = cnvtdatetime(prev_date,0)
 SET default_to_dt = cnvtdatetime(prev_date,235959)
 CALL clear(1,1)
 CALL echo(build("Please enter the capability name and the time range for the data to export ",
   "Default: yesterday, midnight to midnight)"))
 CALL echo("Capability: ")
 CALL echo("Start time: ")
 CALL echo("Stop time: ")
 CALL accept(2,13,"p(40);cu","DM_STAT_SOLCAP_TEST_COLLECTOR")
 SET mss_capability_name = trim(curaccept)
 CALL accept(3,13,"99DAAAD9999D99D99D99;CU",format(default_from_dt,"dd-mmm-yyyy hh:mm:ss;;D")
  WHERE cnvtint(substring(1,2,curaccept)) >= 1
   AND cnvtint(substring(1,2,curaccept)) <= 31
   AND substring(4,3,curaccept) IN ("JAN", "FEB", "MAR", "APR", "MAY",
  "JUN", "JUL", "AUG", "SEP", "OCT",
  "NOV", "DEC")
   AND cnvtint(substring(8,4,curaccept)) >= 1800
   AND cnvtint(substring(13,2,curaccept)) >= 0
   AND cnvtint(substring(13,2,curaccept)) < 24
   AND cnvtint(substring(16,2,curaccept)) >= 0
   AND cnvtint(substring(16,2,curaccept)) < 60
   AND cnvtint(substring(19,2,curaccept)) >= 0
   AND cnvtint(substring(19,2,curaccept)) < 60)
 SET mss_start_time = cnvtdatetime(curaccept)
 CALL accept(4,13,"99DAAAD9999D99D99D99;CU",format(default_to_dt,"dd-mmm-yyyy hh:mm:ss;;D")
  WHERE cnvtint(substring(1,2,curaccept)) >= 1
   AND cnvtint(substring(1,2,curaccept)) <= 31
   AND substring(4,3,curaccept) IN ("JAN", "FEB", "MAR", "APR", "MAY",
  "JUN", "JUL", "AUG", "SEP", "OCT",
  "NOV", "DEC")
   AND cnvtint(substring(8,4,curaccept)) >= 1800
   AND cnvtint(substring(13,2,curaccept)) >= 0
   AND cnvtint(substring(13,2,curaccept)) < 24
   AND cnvtint(substring(16,2,curaccept)) >= 0
   AND cnvtint(substring(16,2,curaccept)) < 60
   AND cnvtint(substring(19,2,curaccept)) >= 0
   AND cnvtint(substring(19,2,curaccept)) < 60)
 SET mss_end_time = cnvtdatetime(curaccept)
 SET request->start_dt_tm = mss_start_time
 SET request->end_dt_tm = mss_end_time
 SET stat = alterlist(reply->solcap,100)
 SET idx = 0
 WHILE (idx < 100)
   SET idx = (idx+ 1)
   SET reply->solcap[idx].degree_of_use_num = - (1)
   SET reply->solcap[idx].degree_of_use_str = "NA"
   SET reply->solcap[idx].distinct_user_count = - (1)
 ENDWHILE
 SET request->start_dt_tm = mss_start_time
 SET request->end_dt_tm = mss_end_time
 SET script_start_time = cnvtdatetime(curdate,curtime3)
 EXECUTE value(mss_capability_name)
 SET script_end_time = cnvtdatetime(curdate,curtime3)
 IF (error(d_err_msg,0) != 0)
  IF ((findstring("not found in the object lib",d_err_msg) > - (1)))
   SELECT
    *
    FROM dummyt
    HEAD REPORT
     col 0, "SOLUTION CAPABILITY AUDIT REPORT", row + 2,
     displaystring = build2("***WARNING*** Script: ",mss_capability_name,
      " was not found, please try again"), col 0, displaystring
    WITH nocounter, formfeed = none, maxcol = 1024
   ;end select
   GO TO exit_program
  ENDIF
 ENDIF
 CALL auditreply("x")
 CALL generatereport("x")
 SUBROUTINE generatereport(x)
   SELECT
    *
    FROM dummyt
    HEAD REPORT
     col 0, "SOLUTION CAPABILITY AUDIT REPORT", row + 2,
     displaystring = trim(cnvtstring(datetimediff(script_end_time,script_start_time,5))), col 0,
     "Execution Time: ",
     displaystring, " second(s)", row + 2,
     col 0, "Issues Found:", row + 1
     FOR (issueidx = 1 TO issuecount)
       row + 1, col 2, issues->issue[issueidx].issuetext
     ENDFOR
     row + 4, col 0, "CAPABILITY DATA"
    DETAIL
     idx = 0, idx2 = 0, idx3 = 0
     WHILE (idx < size(reply->solcap,5))
       idx = (idx+ 1), row + 2, displaystring = build2("Capability Identifier: ",trim(substring(1,80,
          reply->solcap[idx].identifier))),
       col 0, displaystring, row + 1,
       displaystring = build2("Degree of Use: ",trim(cnvtstring(reply->solcap[idx].degree_of_use_num)
         )," (",trim(substring(1,1024,reply->solcap[idx].degree_of_use_str)),")"), col 2,
       displaystring,
       row + 1, displaystring = build2("Distinct Users: ",trim(cnvtstring(reply->solcap[idx].
          distinct_user_count))), col 2,
       displaystring
       IF (size(reply->solcap[idx].position,5) > 0)
        row + 2, col 2, "POSITION",
        col 60, "VALUE"
       ENDIF
       idx2 = 0
       WHILE (idx2 < size(reply->solcap[idx].position,5))
         idx2 = (idx2+ 1), row + 1, displaystring = trim(substring(1,55,reply->solcap[idx].position[
           idx2].display)),
         col 2, displaystring, displaystring = build2(trim(cnvtstring(reply->solcap[idx].position[
            idx2].value_num))," (",trim(substring(1,1024,reply->solcap[idx].position[idx2].value_str)
           ),")"),
         col 60, displaystring
       ENDWHILE
       IF (size(reply->solcap[idx].facility,5))
        row + 2, col 2, "FACILITY",
        col 60, "VALUE"
       ENDIF
       idx2 = 0
       WHILE ((idx2 < size(reply->solcap[idx].facility,5) > 0))
         idx2 = (idx2+ 1), row + 1, displaystring = trim(substring(1,55,reply->solcap[idx].facility[
           idx2].display)),
         col 2, displaystring, displaystring = build2(trim(cnvtstring(reply->solcap[idx].facility[
            idx2].value_num))," (",trim(substring(1,1024,reply->solcap[idx].facility[idx2].value_str)
           ),")"),
         col 60, displaystring
       ENDWHILE
       idx2 = 0
       WHILE (idx2 < size(reply->solcap[idx].other,5))
         idx2 = (idx2+ 1), idx3 = 0, displaystring = cnvtupper(trim(substring(1,55,reply->solcap[idx]
            .other[idx2].category_name))),
         row + 2, col 2, displaystring,
         col 60, "VALUE"
         WHILE (idx3 < size(reply->solcap[idx].other[idx2].value,5))
           idx3 = (idx3+ 1), row + 1, displaystring = trim(substring(1,55,reply->solcap[idx].other[
             idx2].value[idx3].display)),
           col 2, displaystring, displaystring = build2(trim(cnvtstring(reply->solcap[idx].other[idx2
              ].value[idx3].value_num))," (",trim(substring(1,1024,reply->solcap[idx].other[idx2].
              value[idx3].value_str)),")"),
           col 60, displaystring
         ENDWHILE
       ENDWHILE
     ENDWHILE
    WITH nocounter, formfeed = none, maxcol = 2048
   ;end select
 END ;Subroutine
 SUBROUTINE auditreply(x)
   SET idx = 0
   SET idx2 = 0
   SET idx3 = 0
   SET issuecount = 0
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_STAT_SOLCAP_SCRIPT"
     AND cnvtupper(di.info_name)=trim(mss_capability_name)
    DETAIL
     IF (curqual > 1)
      CALL addissue("Multiple entries for the specified capability exist.  Please delete duplicates")
     ENDIF
     IF (di.info_char != "EOD 1 NODE")
      CALL addissue(build2("DM_INFO entry for the specified script must have 'EOD 1 NODE' ",
       "in the info_char column.  Current Value: ",di.info_char))
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL addissue(build2("No entry exists in the dm_info table for ",mss_capability_name))
   ENDIF
   IF (size(reply->solcap,5)=0)
    CALL addissue(build2("No Capabilities were returned by the script ",mss_capability_name))
   ENDIF
   IF (size(reply->solcap,5)=100)
    IF ((reply->solcap[100].identifier=""))
     CALL addissue(build2("Script does not reize the reply to the number of capabilities.",
       "Please perform this action in your the script: ",mss_capability_name))
    ENDIF
   ENDIF
   WHILE (idx < size(reply->solcap,5))
     SET idx = (idx+ 1)
     IF (substring(1,7,reply->solcap[idx].identifier)="2009.01")
      CALL addissue(build2("Capability: ",reply->solcap[idx].identifier,
        " should not start with 2009.01"))
     ENDIF
     IF (size(reply->solcap[idx].identifier,3) > 80)
      CALL addissue(build2("Capability: ",reply->solcap[idx].identifier,
        " cannot be more than 80 characters.  Size: ",trim(cnvtstring(size(reply->solcap[idx].
           identifier,3)))))
     ENDIF
     IF (size(reply->solcap[idx].identifier,3)=0)
      CALL addissue(build2("Capability identifier is empty for capability number ",trim(cnvtstring(
          idx))))
     ENDIF
     IF ((reply->solcap[idx].degree_of_use_num < 0)
      AND (reply->solcap[idx].degree_of_use_str="NA"))
      CALL addissue(build2("Either Degree_of_use_num or Degree_of_use_Str must be filled out for",
        reply->solcap[idx].identifier))
     ENDIF
     IF (size(reply->solcap[idx].degree_of_use_str,3) > 1024)
      CALL addissue(build2("Degree of Use Str for ",reply->solcap[idx].identifier,
        " cannot be more than 1024 characters. ","Size: ",trim(cnvtstring(size(reply->solcap[idx].
           degree_of_use_str,3)))))
     ENDIF
     IF (cnvtupper(reply->solcap[idx].degree_of_use_str) != "NA"
      AND cnvtupper(reply->solcap[idx].degree_of_use_str) != "NO"
      AND cnvtupper(reply->solcap[idx].degree_of_use_str) != "YES"
      AND (reply->solcap[idx].degree_of_use_str != ""))
      CALL addissue(build2("Degree of Use Str for ",reply->solcap[idx].identifier,
        " must have a value of 'YES', 'NO', '', or 'NA'. Current value: ",reply->solcap[idx].
        degree_of_use_str))
     ENDIF
     SET idx2 = 0
     WHILE (idx2 < size(reply->solcap[idx].position,5))
       SET idx2 = (idx2+ 1)
       IF (size(reply->solcap[idx].position[idx2].display,3) > 128)
        CALL addissue(build2("Position display cannot be more than 128 characters. ","Size: ",trim(
           cnvtstring(size(reply->solcap[idx].position[idx2].display,3)))))
       ENDIF
       IF ((reply->solcap[idx].position[idx2].value_num < 0))
        CALL addissue(build2("Value_num for position field cannot be less than zero"))
       ENDIF
       IF (size(reply->solcap[idx].position[idx2].value_str,3) > 1024)
        CALL addissue(build2("Position value_str cannot be more than 1024 characters. ","Size: ",trim
          (cnvtstring(size(reply->solcap[idx].position[idx2].value_str,3)))))
       ENDIF
     ENDWHILE
     SET idx2 = 0
     WHILE (idx2 < size(reply->solcap[idx].facility,5))
       SET idx2 = (idx2+ 1)
       IF (size(reply->solcap[idx].facility[idx2].display,3) > 128)
        CALL addissue(build2("Facility display cannot be more than 128 characters. ","Size: ",trim(
           cnvtstring(size(reply->solcap[idx].facility[idx2].display,3)))))
       ENDIF
       IF ((reply->solcap[idx].facility[idx2].value_num < 0))
        CALL addissue(build2("Value_num for facility field cannot be less than zero"))
       ENDIF
       IF (size(reply->solcap[idx].facility[idx2].value_str,3) > 1024)
        CALL addissue(build2("Facility value_str cannot be more than 1024 characters. ","Size: ",trim
          (cnvtstring(size(reply->solcap[idx].facility[idx2].value_str,3)))))
       ENDIF
     ENDWHILE
     SET idx2 = 0
     WHILE (idx2 < size(reply->solcap[idx].other,5))
       SET idx2 = (idx2+ 1)
       SET idx3 = 0
       IF (size(reply->solcap[idx].other[idx2].category_name,3) > 255)
        CALL addissue(build2("Category Name cannot be more than 255 characters. ","Size: ",trim(
           cnvtstring(size(reply->solcap[idx].other[idx2].category_name,3)))))
       ENDIF
       IF (size(reply->solcap[idx].other[idx2].category_name,3)=0)
        CALL addissue(build2("Category Name cannot be empty. "))
       ENDIF
       WHILE (idx3 < size(reply->solcap[idx].other[idx2].value,5))
         SET idx3 = (idx3+ 1)
         IF (size(reply->solcap[idx].other[idx2].value[idx3].display,3) > 128)
          CALL addissue(build2("Value display cannot be more than 128 characters. ","Size: ",trim(
             cnvtstring(size(reply->solcap[idx].other[idx2].value[idx3].display,3)))))
         ENDIF
         IF (size(reply->solcap[idx].other[idx2].value[idx3].value_str,3) > 1024)
          CALL addissue(build2("Value value_str cannot be more than 1024 characters. ","Size: ",trim(
             cnvtstring(size(reply->solcap[idx].other[idx2].value[idx3].value_str,3)))))
         ENDIF
         IF ((reply->solcap[idx].other[idx2].value[idx3].value_num < 0))
          CALL addissue(build2("Value_num for Value field cannot be less than zero"))
         ENDIF
       ENDWHILE
       SET idx3 = 0
     ENDWHILE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE addissue(text)
   SET issuecount = (issuecount+ 1)
   SET stat = alterlist(issues->issue,issuecount)
   SET issues->issue[issuecount].issuetext = text
 END ;Subroutine
#exit_program
END GO
