CREATE PROGRAM bhs_hm_l_execute_ccl:dba
 DECLARE out = vc WITH protect, noconstant(" ")
 DECLARE name = vc WITH protect, noconstant(" ")
 DECLARE log_message = vc WITH protect, noconstant(" ")
 DECLARE personid = f8 WITH public
 DECLARE tempscriptcall = vc WITH noconstant(" ")
 RECORD ekssub(
   1 orig = vc
   1 parse_ind = i2
   1 num_dec_places = i2
   1 mod = vc
   1 status_flag = i2
   1 msg = vc
   1 format_flag = i4
   1 time_zone = i4
   1 skip_curdate_ind = i2
   1 curdate_fnd_ind = i2
 )
 SET retval = 0
 SET personid = reply->person_id
 SET trigger_personid = reply->person_id
 SET log_message = build2("ruleTemplate - PERSONID:",personid)
 SET tempscriptcall = concat("execute ",program_name," go")
 SET tempvalues = trim(opt_list_type,3)
 IF (checkprg(cnvtupper(program_name)))
  IF (cnvtupper(trim(tempvalues,3))="")
   SET tempvalues = " "
  ELSE
   IF (findstring("@",tempvalues) > 0)
    SET ekssub->parse_ind = 0
    SET ekssub->orig = tempvalues
    EXECUTE eks_t_subcalc
    SET tempvalues = trim(ekssub->mod)
    SET tempvalues = replace(tempvalues,char(10)," ",0)
   ENDIF
  ENDIF
  SET tempscriptcall = concat("execute ",program_name," ",tempvalues," go")
  CALL echo(tempscriptcall)
 ELSE
  SET log_message = "error with program"
  SET retval = - (1)
 ENDIF
 SET log_message = tempscriptcall
 CALL parser(tempscriptcall)
 CALL echo(build("Left program: ",program_name))
 SET cur_series_index = size(reply->expectation_series,5)
 IF (retval <= 0)
  SET reply->expectation_series[cur_series_index].qualify_explanation = build2(reply->
   expectation_series[cur_series_index].qualify_explanation," ",trim(opt_true_text,3))
 ELSE
  SET reply->expectation_series[cur_series_index].qualify_explanation = build2(reply->
   expectation_series[cur_series_index].qualify_explanation," ",trim(opt_false_text,3))
 ENDIF
 SET eksdata->tqual[3].qual[curindex].person_id = personid
 SET eksdata->tqual[3].qual[curindex].logging = log_message
 CALL echo(build2("RETVAL:",retval,"__",format(cnvtdatetime(curdate,curtime3),";;q")))
 CALL echo(build2("log_message:",log_message))
END GO
