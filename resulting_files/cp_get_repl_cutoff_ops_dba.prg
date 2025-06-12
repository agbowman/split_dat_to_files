CREATE PROGRAM cp_get_repl_cutoff_ops:dba
 RECORD reply(
   1 nbr_of_repl_cutoff_ops = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET reply->nbr_of_repl_cutoff_ops = 0
 SET dist_id_chr = cnvtstring(request->distribution_id)
 SELECT INTO "nl:"
  FROM charting_operations co1,
   charting_operations co2
  PLAN (co1
   WHERE co1.param_type_flag=2
    AND co1.param=dist_id_chr
    AND co1.active_ind=1)
   JOIN (co2
   WHERE co2.charting_operations_id=co1.charting_operations_id
    AND co2.param_type_flag=5
    AND co2.param IN ("REPLACEMENT", "CUTOFF"))
  HEAD REPORT
   reply->nbr_of_repl_cutoff_ops = 0
  DETAIL
   reply->nbr_of_repl_cutoff_ops = (reply->nbr_of_repl_cutoff_ops+ 1)
  WITH nocounter
 ;end select
 CALL echo(build("count: ",reply->nbr_of_repl_cutoff_ops))
END GO
