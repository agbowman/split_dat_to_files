CREATE PROGRAM afc_code_sets
 SELECT INTO "afc_code_sets.dat"
  c.code_set, c.cdf_meaning, c.display,
  c.display_key, c.description, c.definition,
  c.collation_seq, c.active_ind
  FROM code_value c
  WHERE c.code_set IN (106, 13016, 13017, 13018, 13019,
  13020, 13028, 13029, 13030, 13031,
  13032, 13035, 13036, 14160, 14002,
  13024, 13025, 14118)
  ORDER BY c.code_set, cdf_meaning
 ;end select
END GO
