CREATE PROGRAM cps_t_hm_sched_series:dba
 SET rev_inc = "708"
 SET ininc = "eks_tell_ekscommon"
 SET ttemp = trim(eks_common->cur_module_name)
 SET eksmodule = trim(ttemp)
 FREE SET ttemp
 SET ttemp = trim(eks_common->event_name)
 SET eksevent = ttemp
 SET eksrequest = eks_common->request_number
 FREE SET ttemp
 DECLARE tcurindex = i4
 DECLARE tinx = i4
 SET tcurindex = 1
 SET tinx = 1
 SET evoke_inx = 1
 SET data_inx = 2
 SET logic_inx = 3
 SET action_inx = 4
 IF ( NOT (validate(eksdata->tqual,"Y")="Y"
  AND validate(eksdata->tqual,"Z")="Z"))
  FREE SET templatetype
  IF (conclude > 0)
   SET templatetype = "ACTION"
   SET basecurindex = (logiccnt+ evokecnt)
   SET tcurindex = 4
  ELSE
   SET templatetype = "LOGIC"
   SET basecurindex = evokecnt
   SET tcurindex = 3
  ENDIF
  SET cbinx = curindex
  SET tinx = logic_inx
 ELSE
  SET templatetype = "EVOKE"
  SET curindex = 0
  SET tcurindex = 0
  SET tinx = 0
 ENDIF
 CALL echo(concat("****  ",format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "     Module:  ",
   trim(eksmodule),"  ****"),1,0)
 IF (validate(tname,"Y")="Y"
  AND validate(tname,"Z")="Z")
  IF (templatetype != "EVOKE")
   CALL echo(concat("****  EKM Beginning of ",trim(templatetype)," Template(",build(curindex),
     ")           Event:  ",
     trim(eksevent),"         Request number:  ",cnvtstring(eksrequest)),1,10)
  ELSE
   CALL echo(concat("****  EKM Beginning an Evoke Template","           Event:  ",trim(eksevent),
     "         Request number:  ",cnvtstring(eksrequest)),1,10)
  ENDIF
 ELSE
  IF (templatetype != "EVOKE")
   CALL echo(concat("****  EKM Beginning of ",trim(templatetype)," Template(",build(curindex),"):  ",
     trim(tname),"       Event:  ",trim(eksevent),"         Request number:  ",cnvtstring(eksrequest)
     ),1,10)
  ELSE
   CALL echo(concat("****  EKM Beginning Evoke Template:  ",trim(tname),"       Event:  ",trim(
      eksevent),"         Request number:  ",
     cnvtstring(eksrequest)),1,10)
  ENDIF
 ENDIF
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  Beginning of program cps_t_hm_sched_series  *******"),1,0)
 RECORD schedulelist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 SET orig_param = schedule
 EXECUTE eks_t_parse_list  WITH replace(reply,schedulelist)
 FREE SET orig_param
 SET retval = 0
 IF ((schedulelist->cnt != 1))
  CALL echo("Only one schedule is allowed per rule")
  GO TO exit_script
 ENDIF
 RECORD serieslist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 SET orig_param = series
 EXECUTE eks_t_parse_list  WITH replace(reply,serieslist)
 FREE SET orig_param
 IF ((serieslist->cnt != 1))
  CALL echo("Only one series is allowed per rule")
  GO TO exit_script
 ENDIF
 SET es_size = size(request->expect_sched,5)
 IF (es_size < 1)
  CALL echo("No schedules were specified in the request")
  GO TO exit_script
 ENDIF
 SET sched_found = 0
 SET sknt = 1
 WHILE (sknt <= es_size
  AND sched_found=0)
  IF ((request->expect_sched[sknt].expect_sched_mean=schedulelist->qual[1].value))
   SET sched_found = 1
  ENDIF
  SET sknt += 1
 ENDWHILE
 IF (sched_found=1)
  SET retval = 100
 ELSE
  GO TO exit_script
 ENDIF
 IF (validate(reply,"0")="0")
  CALL echo("ERROR: Reply does not yet exist")
  GO TO exit_script
 ENDIF
 SET current_index = (size(reply->expectation_series,5)+ 1)
 SET stat = alterlist(reply->expectation_series,current_index)
 SET reply->expectation_series[current_index].expect_series_mean = serieslist->qual[1].value
 SET reply->expectation_series[current_index].expect_sched_mean = schedulelist->qual[1].value
 SET reply->expectation_series[current_index].status_flag = 0
#exit_script
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  Ending of program cps_t_hm_sched_series  *******"),1,0)
 SET script_version = "001 04/08/03 SF3151"
END GO
