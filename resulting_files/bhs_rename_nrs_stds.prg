CREATE PROGRAM bhs_rename_nrs_stds
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.username = concat(p.username,"Y",format(curdate,"YYMM;;d")), p.end_effective_dt_tm =
   cnvtdatetime(curdate,curtime3), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   p.updt_id = 99999999
  WHERE p.active_status_cd=194
   AND p.active_ind=1
   AND p.position_cd=457
   AND p.username != "*Y0*"
   AND p.username="SN99*"
  WITH maxrec = 5
 ;end update
 COMMIT
END GO
