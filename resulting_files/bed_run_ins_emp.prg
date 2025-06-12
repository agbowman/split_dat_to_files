CREATE PROGRAM bed_run_ins_emp
 FREE SET tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_INS_EMP.CSV"
 SET scriptname = "bed_imp_ins_emp"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
