CREATE PROGRAM dm_dmcv
 SELECT
  *
  FROM dm_merge_constraints_view
  WHERE ((child_table=cnvtupper( $1)) OR (parent_table=cnvtupper( $1)))
  WITH nocounter
 ;end select
END GO
