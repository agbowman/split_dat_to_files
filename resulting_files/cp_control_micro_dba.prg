CREATE PROGRAM cp_control_micro:dba
 CALL echo("making reply")
 RECORD reply(
   1 num_lines = f8
   1 qual[*]
     2 line = c255
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echo("done with setting up reply")
 SET max_no_of_orgs_horiz = 3
 SET noofopts = size(request->option_list,5)
 SET xkount = 0
 SET curropt = 0
 SET forceout = 0
 SET scriptoption = 2
 WHILE (xkount < noofopts
  AND forceout=0)
  SET xkount = (xkount+ 1)
  IF ((request->option_list[xkount].option_flag=1))
   SET scriptoption = cnvtint(request->option_list[xkount].option_value)
   SET forceout = 1
  ENDIF
 ENDWHILE
 CALL echo(build("scriptOption = ",scriptoption))
 IF (scriptoption=1)
  EXECUTE cp_iso_micro_chart
 ELSE
  EXECUTE cp_dyn_micro_chart
 ENDIF
#exit_script
END GO
