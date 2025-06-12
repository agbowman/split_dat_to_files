CREATE PROGRAM cclconserror
 SELECT INTO mine
  a.constraint_type, a.table_name, a.r_constraint_name,
  a.delete_rule, a.status
  FROM all_constraints a
  WHERE a.constraint_name=cnvtstring(value( $1))
 ;end select
END GO
