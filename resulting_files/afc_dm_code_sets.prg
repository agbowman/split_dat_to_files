CREATE PROGRAM afc_dm_code_sets
 SELECT INTO "afc_DM_code_sets.dat"
  c.code_set, c.cdf_meaning, c.display,
  c.display_key, c.description, c.definition,
  c.collation_seq, c.active_ind
  FROM dm_code_value c
  WHERE c.code_set IN (106, 13016, 13017, 13018, 13019,
  13020, 13028, 13029, 13030, 13031,
  13032, 13035, 13036, 14160, 14002,
  13024, 13025, 14118, 14274, 14275,
  14276)
  ORDER BY c.code_set, cdf_meaning
  HEAD REPORT
   col 30, "C H A R G E   S E R V I C E S - C O D E   S E T S", row + 2
  HEAD PAGE
   col 01, "CODE SET", col 10,
   "CDF_MEANING", col 25, "DISPLAY",
   col 48, "DISPLAY KEY", col 70,
   "DESCRIPTION", col 112, "COL",
   col 116, "ACT", row + 1,
   col 01, "-----------------------------------------------------", col 50,
   "-----------------------------------------------------", col 100, "--------------------",
   row + 1
  DETAIL
   col 01, c.code_set"#####", col 10,
   c.cdf_meaning"##############", col 25, c.display"####################",
   col 48, c.display_key"####################", col 70,
   c.description"###################################", col 112, c.collation_seq"##",
   col 117, c.active_ind"#", row + 1
  FOOT  c.code_set
   row + 1
 ;end select
END GO
