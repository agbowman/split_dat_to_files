CREATE PROGRAM dcp_solcap_handling_precaution:dba
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "PJ001908.1"
 SET reply->solcap[1].degree_of_use_num = 0
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   ocs_handling_precautions ocshp
  PLAN (ocs)
   JOIN (ocshp
   WHERE ocs.synonym_id=ocshp.synonym_id
    AND ocs.active_ind=1)
  DETAIL
   reply->solcap[1].degree_of_use_num += 1
  WITH nocounter
 ;end select
 SET last_mod = "001"
END GO
