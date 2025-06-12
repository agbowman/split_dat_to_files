CREATE PROGRAM bed_run_org_alias_pools:dba
 FREE SET tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_ORG_ALIAS_POOLS.CSV"
 SET scriptname = "BED_IMP_ORG_ALIAS_POOLS"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
