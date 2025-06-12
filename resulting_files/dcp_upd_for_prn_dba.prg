CREATE PROGRAM dcp_upd_for_prn:dba
 UPDATE  FROM frequency_schedule fs
  SET fs.prn_default_ind = 1, fs.frequency_type = 5
  WHERE fs.frequency_type=6
  WITH nocounter
 ;end update
 COMMIT
#exit_program
END GO
