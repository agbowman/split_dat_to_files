CREATE PROGRAM bhs_fix_dup_ids
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.physician_ind = 0, p.username = concat(p.username,"_",format(curdate,"YYYYMMDD;;d")), p
   .active_status_cd = 192,
   p.updt_id = 99999999
  WHERE p.person_id=5790414
 ;end update
 COMMIT
END GO
