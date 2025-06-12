CREATE PROGRAM bhs_inact_username_blnks:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.username = concat(p.username,"Y0608"), p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p
   .updt_cnt = (p.updt_cnt+ 1),
   p.updt_id = 99999999
  WHERE p.physician_ind != 1
   AND p.active_ind=1
   AND p.active_status_cd != 189.00
   AND p.active_status_cd=194.00
   AND p.position_cd <= 0
   AND ((p.username="Z99999999") OR (p.username="SN97961"))
  WITH maxrec = 10
 ;end update
 COMMIT
END GO
