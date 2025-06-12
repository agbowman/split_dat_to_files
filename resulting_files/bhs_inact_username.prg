CREATE PROGRAM bhs_inact_username
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.active_ind = 0, p.active_status_cd = 192, p.end_effective_dt_tm = cnvtdatetime(curdate,
    curtime3),
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = 99999999
  WHERE ((p.username="Z99999999") OR (((p.username="EN46455") OR (((p.username="EN00714") OR (((p
  .username="EN42243") OR (((p.username="EN42245") OR (((p.username="EN45207") OR (((p.username=
  "EN45176") OR (((p.username="EN47515") OR (p.username="EN43628")) )) )) )) )) )) )) ))
 ;end update
 COMMIT
END GO
