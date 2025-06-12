CREATE PROGRAM dm_add_ap_soft_cons:dba
 INSERT  FROM dm_soft_constraints
  (parent_table, child_table, parent_column,
  child_column, child_where)
  VALUES("CODE_VALUE", "SPECIMEN_GROUPING_R", "CODE_VALUE",
  "CATEGORY_CD", "  ")
 ;end insert
 COMMIT
END GO
