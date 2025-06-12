CREATE PROGRAM cps_t_hm_set_series:dba
 DECLARE appendqualifyexplanation(index=i4) = null
 DECLARE setstatusflag(index=i4) = null
 CALL echo("###########################################################")
 CALL echo("###                                                     ###")
 CALL echo("###    Entering program cps_t_hm_set_series             ###")
 CALL echo("###                                                     ###")
 CALL echo("###########################################################")
 RECORD schedulelist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 SET orig_param = schedule
 EXECUTE eks_t_parse_list  WITH replace(reply,schedulelist)
 FREE SET orig_param
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
 WHILE (sknt <= size(request->expect_sched,5)
  AND sched_found=0)
  IF ((request->expect_sched[sknt].expect_sched_mean=schedulelist->qual[1].value))
   SET sched_found = 1
  ENDIF
  SET sknt = (sknt+ 1)
 ENDWHILE
 IF (sched_found=0)
  CALL echo("The schedule set in the action template was not found in the request.")
  GO TO exit_script
 ENDIF
 SET new_size = (size(reply->expectation_series,5)+ 1)
 SET stat = alterlist(reply->expectation_series,new_size)
 CALL echo(concat("size(eksdata->tqual[3].qual, 5):",trim(cnvtstring(size(eksdata->tqual[3].qual,5)))
   ))
 FOR (sknt = 1 TO size(eksdata->tqual[3].qual,5))
   IF ((eksdata->tqual[3].qual[sknt].cnt=1))
    SET tmp_pos = findstring("^",eksdata->tqual[3].qual[sknt].data[1].misc,1)
    IF (tmp_pos > 0)
     SET reply->expectation_series[new_size].expect_series_mean = serieslist->qual[1].value
     SET reply->expectation_series[new_size].expect_sched_mean = schedulelist->qual[1].value
     CALL setstatusflag(sknt)
     CALL appendqualifyexplanation(sknt)
    ENDIF
   ELSEIF ((eksdata->tqual[3].qual[sknt].cnt > 1))
    CALL echo("The data element for a logic template contained more than one item")
   ENDIF
 ENDFOR
#exit_script
 SUBROUTINE setstatusflag(index)
   CALL echo("Entering SetStatusFlag. eksdata->tqual[3].qual[index ].data[1].misc=")
   CALL echo(eksdata->tqual[3].qual[index].data[1].misc)
   SET delim_pos = findstring("^",eksdata->tqual[3].qual[index].data[1].misc,1)
   IF (delim_pos > 1)
    CALL echo("SetStatusFlag substring = ")
    CALL echo(trim(substring(1,(delim_pos - 1),eksdata->tqual[3].qual[index].data[1].misc)))
    IF (trim(substring(1,(delim_pos - 1),eksdata->tqual[3].qual[index].data[1].misc))="1")
     SET reply->expectation_series[new_size].satisfy_flag = 1
    ELSE
     SET reply->expectation_series[new_size].satisfy_flag = 0
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE appendqualifyexplanation(index)
   CALL echo("Entering AppendQualifyExplanation. eksdata->tqual[3].qual[index ].data[1].misc=")
   CALL echo(eksdata->tqual[3].qual[index].data[1].misc)
   SET delim_pos = findstring("^",eksdata->tqual[3].qual[index].data[1].misc,1)
   IF (delim_pos > 1)
    CALL echo("SetStatusFlag substring = ")
    CALL echo(trim(substring((delim_pos+ 1),(size(trim(stringparam)) - delim_pos),eksdata->tqual[3].
       qual[index].data[1].misc)))
    SET reply->expectation_series[new_size].qualify_explanation = trim(concat(reply->
      expectation_series[new_size].qualify_explanation," ",trim(substring((delim_pos+ 1),(size(trim(
          stringparam)) - delim_pos),eksdata->tqual[3].qual[index].data[1].misc))))
   ENDIF
 END ;Subroutine
END GO
