CREATE PROGRAM bhs_req_oco:dba
 DECLARE call_program = vc WITH public
 SET call_program = curprog
 EXECUTE bhs_req_04_layout call_program
END GO
