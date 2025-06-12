CREATE PROGRAM bhs_req_rad:dba
 DECLARE call_program = vc WITH public
 SET call_program = curprog
 EXECUTE bhs_req_rad_layout call_program
END GO
