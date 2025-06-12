CREATE PROGRAM ams_em_set_rrd_untransmitted
 SET reqinfo->updt_id = 2.00
 UPDATE  FROM report_queue
  SET transmission_status_cd =
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=2209
     AND cdf_meaning="UNXMITTED"), updt_id = reqinfo->updt_id, updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   updt_cnt = (updt_cnt+ 1), updt_task = 0, updt_applctx = 0
  WHERE (transmission_status_cd=
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=2209
    AND cdf_meaning="ERROR"))
   AND converted_file_name="UNCONVERTED"
   AND original_dt_tm > cnvtdatetime((curdate - 1),curtime3)
 ;end update
 COMMIT
END GO
