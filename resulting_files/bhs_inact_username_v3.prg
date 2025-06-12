CREATE PROGRAM bhs_inact_username_v3
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.active_status_cd = 194, p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_dt_tm
    = cnvtdatetime(curdate,curtime3),
   p.updt_id = 99999999
  WHERE p.physician_ind != 1
   AND p.active_ind=1
   AND p.active_status_cd != 189.00
   AND ((p.username="Z99999999") OR (p.username="SN99439"))
 ;end update
 IF (p.position_cd=457)
  SET p.username = concat(p.username,"Y",format(curdate,"YYMM;;d"))
 ENDIF
 COMMIT
END GO
