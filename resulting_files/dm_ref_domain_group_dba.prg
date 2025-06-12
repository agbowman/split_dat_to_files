CREATE PROGRAM dm_ref_domain_group:dba
 INSERT  FROM dm_ref_domain_group dg
  SET dg.group_name = cnvtupper(requestin->list_0[1].group_name), dg.description = cnvtupper(
    requestin->list_0[1].description)
  WITH nocounter
 ;end insert
 COMMIT
END GO
