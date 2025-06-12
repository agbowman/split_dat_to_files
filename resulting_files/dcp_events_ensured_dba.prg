CREATE PROGRAM dcp_events_ensured:dba
 SET count1 = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET e_cnt = size(request->elist,5)
#exit_script
END GO
