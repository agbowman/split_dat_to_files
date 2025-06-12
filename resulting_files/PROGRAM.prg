 CALL parser(build("DROP PROGRAM _",script_name,":",group_name,"  GO"))
 SET stat = remove("RDM_SCRIPTSCORE1.PRG;*")
 INSERT  FROM dm_eval_script_score caf
  SET caf.environment_id = rm_temp_id, caf.script = script_name, caf.run_dt_tm = cnvtdatetime(curdate,
    curtime3),
   caf.score = final_score, caf.ss_comment = tbl_str
  WITH nocounter
 ;end insert
 COMMIT
END GO
