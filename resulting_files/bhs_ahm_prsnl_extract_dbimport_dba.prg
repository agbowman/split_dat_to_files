CREATE PROGRAM bhs_ahm_prsnl_extract_dbimport:dba
 SET ms_dclcom = "cp /cerner/cmsftp/ahmemp.txt $bhscust"
 SET ml_stat = - (1)
 CALL echo(build("Copy Command1: ",ms_dclcom))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 SET ms_dclcom = "cp /cerner/cmsftp/provider.txt $bhscust"
 SET ml_stat = - (1)
 CALL echo(build("Copy Command2: ",ms_dclcom))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 EXECUTE dm_dbimport "bhscust:provider.txt", "bhs_ahm_prsnl_extract", 100000
END GO
