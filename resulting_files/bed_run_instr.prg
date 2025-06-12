CREATE PROGRAM bed_run_instr
 SET filename = "CER_INSTALL:instr.csv"
 SET scriptname = "bed_imp_instr"
 DELETE  FROM br_instr b
  WHERE b.br_instr_id > 0
  WITH nocounter
 ;end delete
 EXECUTE bed_dm_dbimport filename, scriptname, 15000
END GO
