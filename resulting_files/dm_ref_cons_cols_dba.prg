CREATE PROGRAM dm_ref_cons_cols:dba
 DELETE  FROM dm_ref_cons_cols
  WHERE 1=1
 ;end delete
 COMMIT
 INSERT  FROM dm_ref_cons_cols
  (child_table, child_constraint, child_column,
  child_position, parent_table, parent_column)(SELECT
   b.table_name, c.constraint_name, c.column_name,
   c.position, a.table_name, d.column_name
   FROM user_constraints a,
    user_cons_columns c,
    user_cons_columns d,
    user_constraints b,
    dm_tables_doc e
   WHERE b.constraint_type="R"
    AND b.table_name=e.table_name
    AND e.reference_ind=1
    AND b.r_constraint_name=a.constraint_name
    AND b.constraint_name=c.constraint_name
    AND a.owner=b.owner
    AND a.constraint_name=d.constraint_name
    AND c.position=d.position
    AND a.table_name != b.table_name
    AND a.owner="V500"
    AND (((( NOT (a.table_name IN ("CODE_VALUE", "PRSNL", "V500_EVENT_CODE", "LONG_TEXT"))) OR (((a
   .table_name="CODE_VALUE"
    AND b.table_name IN ("CODE_VALUE_ALIAS", "CODE_VALUE_EXTENSION", "CODE_VALUE_GROUP",
   "CODE_VALUE_OUTBOUND")) OR (a.table_name="PRSNL"
    AND b.table_name="PRSNL*")) )) ) OR (a.table_name="PERSON"
    AND b.table_name IN ("PERSON_NAME", "PERSON_ALIAS", "PERSON_INFO", "PERSON"))) )
 ;end insert
 COMMIT
END GO
