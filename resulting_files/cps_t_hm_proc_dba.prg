CREATE PROGRAM cps_t_hm_proc:dba
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  Beginning of program cps_t_hm_proc  *******"),1,0)
 RECORD procedure_listlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 SET orig_param = procedure_list
 EXECUTE eks_t_parse_list  WITH replace(reply,procedure_listlist)
 FREE SET orig_param
 DECLARE procedure_size = i4 WITH public, constant(size(procedure_listlist->qual,5))
 DECLARE request_size = i4 WITH public, constant(size(request->procedure,5))
 IF (procedure_size < 1)
  SET retval = - (1)
  CALL echo("ERROR: Procedure list in the rule is empty.")
  GO TO exit_script
 ENDIF
 IF (request_size < 1)
  SET retval = 0
  GO TO exit_script
 ENDIF
 CALL echo("$$$$$$$$$$$ Starting Proc Compare $$$$$$$$$$$$$$")
 SET req_index = 1
 WHILE (req_index <= request_size
  AND retval != 100)
   SET rule_index = 1
   WHILE (rule_index <= procedure_size
    AND retval != 100)
    IF (cnvtint(procedure_listlist->qual[rule_index].value)=0)
     CALL echo(concat("qual ",cnvtstring(rule_index)," is not a valid nomenclature ID"))
     CALL echorecord(procedure_listlist)
    ELSE
     IF ((request->procedure[req_index].nomenclature_id=cnvtint(procedure_listlist->qual[rule_index].
      value)))
      SET retval = 100
     ENDIF
    ENDIF
    SET rule_index = (rule_index+ 1)
   ENDWHILE
   SET req_index = (req_index+ 1)
 ENDWHILE
 IF (retval=100)
  CALL echo("****Procedure Found****")
 ENDIF
#exit_script
 SET cur_series_index = size(reply->expectation_series,5)
 IF (retval=0)
  CALL echo("**** retval = 0 ****")
  SET reply->expectation_series[cur_series_index].qualify_explanation = concat(reply->
   expectation_series[cur_series_index].qualify_explanation," ",trim(false_text))
 ELSE
  CALL echo("**** retval != 0 ****")
  SET reply->expectation_series[cur_series_index].qualify_explanation = concat(reply->
   expectation_series[cur_series_index].qualify_explanation," ",trim(true_text))
 ENDIF
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  End of program cps_t_hm_proc  *******"),1,0)
END GO
