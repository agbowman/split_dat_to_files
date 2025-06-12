CREATE PROGRAM cps_t_hm_diag:dba
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  Beginning of program cps_t_hm_diag  *******"),1,0)
 RECORD diagnosis_listlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 SET orig_param = diagnosis_list
 EXECUTE eks_t_parse_list  WITH replace(reply,diagnosis_listlist)
 FREE SET orig_param
 RECORD type_listlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 SET orig_param = type_list
 EXECUTE eks_t_parse_list  WITH replace(reply,type_listlist)
 FREE SET orig_param
 DECLARE status_size = i4 WITH public, constant(size(type_listlist->qual,5))
 DECLARE diagnosis_size = i4 WITH public, constant(size(diagnosis_listlist->qual,5))
 DECLARE request_size = i4 WITH public, constant(size(request->diagnosis,5))
 IF (status_size < 1)
  SET retval = - (1)
  CALL echo("ERROR: Status list in the rule is empty.")
  GO TO exit_script
 ENDIF
 IF (diagnosis_size < 1)
  SET retval = - (1)
  CALL echo("ERROR: Diagnosis list in the rule is empty.")
  GO TO exit_script
 ENDIF
 IF (request_size < 1)
  SET retval = 0
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(status_size)),
   (dummyt d2  WITH seq = value(request_size)),
   (dummyt d3  WITH seq = value(diagnosis_size))
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (d2
   WHERE (request->diagnosis[d2.seq].diag_type_cd=cnvtreal(type_listlist->qual[d1.seq].value)))
   JOIN (d3
   WHERE (cnvtreal(diagnosis_listlist->qual[d3.seq].value)=request->diagnosis[d2.seq].nomenclature_id
   ))
  DETAIL
   retval = 100
  WITH nocounter
 ;end select
 IF (retval=100)
  CALL echo("****Diagnosis Found****")
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
   "  *******  End of program cps_t_hm_diag  *******"),1,0)
END GO
