CREATE PROGRAM dm_ref_domain_r:dba
 INSERT  FROM dm_ref_domain_r r
  SET r.group_name = cnvtupper(requestin->list_0[1].group_name), r.ref_domain_name = cnvtupper(
    requestin->list_0[1].ref_domain_name)
  WITH nocounter
 ;end insert
 COMMIT
END GO
