CREATE PROGRAM cp_get_final_adden_cumadd_ops:dba
 RECORD reply(
   1 nbr_of_fin_add_cumadd_ops = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SELECT INTO "nl:"
  co2.batch_name
  FROM charting_operations co1,
   charting_operations co2
  PLAN (co1
   WHERE co1.param_type_flag=2
    AND co1.param=cnvtstring(request->distribution_id)
    AND co1.active_ind=1)
   JOIN (co2
   WHERE co2.charting_operations_id=co1.charting_operations_id
    AND co2.param_type_flag=5
    AND co2.param IN ("FINAL", "ADDENDUM", "CUM ADDENDUM"))
  WITH nocounter
 ;end select
 SET reply->nbr_of_fin_add_cumadd_ops = curqual
 CALL echo(build("count: ",reply->nbr_of_fin_add_cumadd_ops))
END GO
