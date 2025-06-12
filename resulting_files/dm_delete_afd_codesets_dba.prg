CREATE PROGRAM dm_delete_afd_codesets:dba
 SET tempstr = fillstring(255," ")
 SET cnumber = cnvtstring(afd_nbr)
 DELETE  FROM dm_afd_code_value_set
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_code_value
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_code_value_alias
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_code_value_extension
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_code_set_extension
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_common_data_foundation
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 SELECT INTO value(fname)
  *
  FROM dual
  DETAIL
   "set trace symbol mark go", row + 2, tempstr =
   "delete from dm_afd_code_value_set where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_code_value where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_code_value_alias where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_code_value_extension where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_code_set_extension where alpha_feature_nbr = ",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, tempstr = "delete from dm_afd_common_data_foundation where alpha_feature_nbr =",
   tempstr, row + 1, tempstr = build(cnumber," with nocounter go"),
   tempstr, row + 1, "commit  go",
   row + 3
  WITH nocounter, maxcol = 512, format = variable,
   formfeed = none, append, maxrow = 1
 ;end select
END GO
