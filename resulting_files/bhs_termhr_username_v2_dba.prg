CREATE PROGRAM bhs_termhr_username_v2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.username = concat("TERMHR",p.username,"Y",format(curdate,"YYMM;;d")), p.end_effective_dt_tm
    = cnvtdatetime(curdate,curtime3), p.active_status_cd = 194,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = 99999999
  WHERE p.physician_ind != 1
   AND p.active_ind=1
   AND p.active_status_cd != 189.00
   AND p.active_status_cd != 194.00
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,0)
   AND ((p.username="Z99999999") OR (p.username="EN11177"))
  WITH maxrec = 100
 ;end update
 COMMIT
END GO
