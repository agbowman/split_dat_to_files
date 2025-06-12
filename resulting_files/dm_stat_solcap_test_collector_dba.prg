CREATE PROGRAM dm_stat_solcap_test_collector:dba
 SET stat = alterlist(reply->solcap,0)
END GO
