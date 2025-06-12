CREATE PROGRAM dm_drop_ap_soft_cons:dba
 DELETE  FROM dm_soft_constraints
  WHERE parent_table="CODE_VALUE"
   AND child_table IN ("SPECIMEN_GROUPING_R")
 ;end delete
 COMMIT
END GO
