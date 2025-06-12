CREATE PROGRAM djh_prsnl_std_chng
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.active_ind = 0, p.active_status_cd = 192, p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   p.updt_id = 99999999
  WHERE ((p.username != "DUM*") OR (physician_ind != 1))
   AND p.username="EN97753"
 ;end update
 COMMIT
END GO
