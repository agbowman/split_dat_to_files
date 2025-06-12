CREATE PROGRAM cps_t_hm_month_range:dba
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  Beginning of program cps_t_hm_month_range *******"),1,0)
 DECLARE getmonth(month_string=vc) = i2
 SET retval = 0
 SET cur_series_index = size(reply->expectation_series,5)
 IF (cnvtdate(request->eval_start_dt_tm) > cnvtdate(request->eval_end_dt_tm))
  CALL echo("ERROR: The evaluation start date is greater than the end date.")
  GO TO exit_script
 ENDIF
 SET req_start_month = month(request->eval_start_dt_tm)
 SET req_end_month = month(request->eval_end_dt_tm)
 SET diff_in_years = (year(request->eval_end_dt_tm) - year(request->eval_start_dt_tm))
 SET req_end_month = (req_end_month+ (12 * diff_in_years))
 IF (((req_end_month - req_start_month) >= 11))
  SET retval = 100
  GO TO exit_script
 ENDIF
 SET rule_start_month = getmonth(start_month)
 IF (rule_start_month=0)
  CALL echo("Could not get the rule start month. GetMonth returned 0")
  GO TO exit_script
 ENDIF
 SET rule_end_month = getmonth(end_month)
 IF (rule_end_month=0)
  CALL echo("Could not get the rule end month. GetMonth returned 0")
  GO TO exit_script
 ENDIF
 IF (rule_start_month > rule_end_month)
  SET rule_end_month = (rule_end_month+ 12)
 ENDIF
 IF (((rule_end_month - rule_start_month) >= 11))
  SET retval = 100
  GO TO exit_script
 ENDIF
 IF (req_start_month >= rule_start_date
  AND req_start_month <= rule_end_date)
  SET retval = 100
  GO TO exit_script
 ENDIF
 IF (req_end_month >= rule_start_date
  AND req_end_month <= rule_end_date)
  SET retval = 100
  GO TO exit_script
 ENDIF
 IF (rule_start_month >= req_start_date
  AND rule_start_month <= req_end_date)
  SET retval = 100
  GO TO exit_script
 ENDIF
 IF (rule_end_month >= req_start_date
  AND rule_end_month <= req_end_date)
  SET retval = 100
  GO TO exit_script
 ENDIF
#exit_script
 IF (retval=100)
  SET reply->expectation_series[cur_series_index].qualify_explanation = concat(reply->
   expectation_series[cur_series_index].qualify_explanation," ",trim(true_text))
 ELSE
  SET reply->expectation_series[cur_series_index].qualify_explanation = concat(reply->
   expectation_series[cur_series_index].qualify_explanation," ",trim(false_text))
 ENDIF
 SUBROUTINE getmonth(month_string)
  CASE (month_string)
   OF "January (01)":
    RETURN(1)
   OF "February (02)":
    RETURN(2)
   OF "March (03)":
    RETURN(3)
   OF "April (04)":
    RETURN(4)
   OF "May (05)":
    RETURN(5)
   OF "June (06)":
    RETURN(6)
   OF "July (07)":
    RETURN(7)
   OF "August (08)":
    RETURN(8)
   OF "September (09)":
    RETURN(9)
   OF "October (10)":
    RETURN(10)
   OF "November (11)":
    RETURN(11)
   OF "December (12)":
    RETURN(12)
   ELSE
    CALL echo("GetMonth failed because the input string did not match any case statement")
    RETURN(0)
  ENDCASE
  RETURN(0)
 END ;Subroutine
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  End of program cps_t_hm_month_range *******"),1,0)
END GO
