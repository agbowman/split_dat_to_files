CREATE PROGRAM dm2_downtime_checker_rpt:dba
 DECLARE ddcr_calling_script = vc WITH protect, noconstant("DM2_DOWNTIME_CHECKER_RPT")
 RECORD request(
   1 plan_id = f8
   1 check_option = vc
 )
 SET request->plan_id =  $1
 SET request->check_option =  $2
 EXECUTE dm2_downtime_checker
END GO
