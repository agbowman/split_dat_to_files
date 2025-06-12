CREATE PROGRAM afc_purge_ic:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 IF (validate(request->ops_date,999)=999)
  EXECUTE cclseclogin
  SET message = nowindow
 ENDIF
 SET reply->status_data.status = "F"
 SET retention_days = cnvtint( $1)
 CALL echo(build("the # of retention days is: ",retention_days))
 SET test_mode = cnvtint( $2)
 IF (test_mode=1)
  CALL echo("Running in test mode.")
 ELSE
  CALL echo("Running in commit mode.")
 ENDIF
 SET num_to_purge = cnvtint( $3)
 CALL echo(build("purging: ",num_to_purge," rows"))
 SET today = cnvtdatetime(curdate,curtime3)
 SET today_dt = cnvtdatetime(concat(format(today,"DD-MMM-YYYY;;D")," 23:59:59.99"))
 SET from_date = datetimeadd(today_dt,- (retention_days))
 CALL echo(build("the from date is: ",format(from_date,"DD-MMM-YYYY HH:MM;;d")))
 SET finished = 0
 WHILE (finished=0)
   CALL echo("Checking for charges to purge from interface_charge . . .")
   SELECT INTO TABLE t_ic_purge
    i.interface_charge_id
    FROM interface_charge i
    WHERE i.process_flg != 0
     AND i.posted_dt_tm <= cnvtdatetime(from_date)
    WITH counter, maxqual(i,value(num_to_purge))
   ;end select
   CALL echo(build("# of charges that qualified to be purged is: ",curqual))
   IF (curqual <= 0)
    CALL echo("No charges qualified")
    SET reply->status_data.status = "Z"
    SET finished = 1
    IF (cursys="AIX")
     SET syscmd = "rm $CCLUSERDIR/t_ic_purge.*"
     SET len = size(trim(syscmd))
     SET status = 0
     CALL dcl(syscmd,len,status)
    ELSE
     SET clean = remove("ccluserdir:t_ic_purge.dat;*")
    ENDIF
   ELSE
    IF (curqual < num_to_purge)
     CALL echo("*****Last Time*****")
     SET finished = 1
    ENDIF
    DELETE  FROM interface_charge ic,
      t_ic_purge t
     SET ic.seq = 1
     PLAN (t)
      JOIN (ic
      WHERE ic.interface_charge_id=t.interface_charge_id)
     WITH nocounter
    ;end delete
    IF (test_mode=0)
     COMMIT
    ENDIF
    IF (cursys="AIX")
     SET syscmd = "rm $CCLUSERDIR/t_ic_purge.*"
     SET len = size(trim(syscmd))
     SET status = 0
     CALL dcl(syscmd,len,status)
    ELSE
     SET clean = remove("ccluserdir:t_ic_purge.dat;*")
    ENDIF
    SET reply->status_data.status = "S"
   ENDIF
 ENDWHILE
 CALL echo("Finished.")
 CALL echo(build("Beg Time: "," ",format(today,"DD-MMM-YYYY;;d"),format(today," HH:MM:SS;;S")))
 CALL echo(build("End Time: "," ",format(curdate,"DD-MMM-YYYY;;D"),format(curtime," HH:MM:SS;;S")))
END GO
