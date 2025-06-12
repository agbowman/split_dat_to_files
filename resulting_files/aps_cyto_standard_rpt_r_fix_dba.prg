CREATE PROGRAM aps_cyto_standard_rpt_r_fix:dba
 UPDATE  FROM cyto_standard_rpt_r csrr
  SET csrr.nomenclature_id = csrr.result_cd
  WHERE 1=1
  WITH nocounter
 ;end update
 COMMIT
END GO
