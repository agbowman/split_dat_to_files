CREATE PROGRAM dm_delete_afd_tables:dba
 SET tempstr = fillstring(255," ")
 SET cnumber = cnvtstring(afd_nbr)
 SET cdate = cnvtdatetime(curdate,curtime3)
 DELETE  FROM dm_afd_tables
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_columns
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_constraints
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_cons_columns
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_indexes
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_index_columns
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 SELECT INTO value(fname)
  *
  FROM dual
  DETAIL
   "set trace symbol mark go ", row + 2, tempstr =
   "delete from dm_afd_tables where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_columns where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_constraints where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_cons_columns where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_indexes where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_index_columns where alpha_feature_nbr =",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, "commit go ",
   row + 3
  WITH nocounter, maxcol = 512, format = variable,
   formfeed = none, append, maxrow = 1
 ;end select
END GO
