CREATE PROGRAM dcp_solcap_therasubcombo:dba
 SET stat = alterlist(reply->solcap,1)
 SET comborulecount = 0
 SET reply->solcap[1].identifier = "2012.1.00105.4"
 SELECT INTO "nl:"
  FROM rx_therap_sbsttn_to tst
  WHERE tst.active_ind=1
   AND tst.to_synonym_id > 0.0
  HEAD tst.therap_sbsttn_from_id
   count = 0
  DETAIL
   count += 1
   IF (count > 1)
    comborulecount += 1
   ENDIF
  WITH nocounter
 ;end select
 SET reply->solcap[1].degree_of_use_num = comborulecount
 SET last_mod = "001"
END GO
