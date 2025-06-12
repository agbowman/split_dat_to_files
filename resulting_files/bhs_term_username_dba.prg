CREATE PROGRAM bhs_term_username:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.username = concat("TERM",p.username,"_",format(curdate,"YYYYMMDD;;d")), p.end_effective_dt_tm
    = cnvtdatetime(curdate,curtime3), p.active_status_cd = 194,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = 99999999
  WHERE ((p.physician_ind != 1) OR (p.physician_ind=1
   AND ((p.position_cd=227480046) OR (p.position_cd=228835487))
   AND p.active_ind=1))
   AND p.active_status_cd != 189.00
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,0)
   AND ((p.username="Z99999999") OR (((p.username="EN01494") OR (((p.username="EN11884") OR (((p
  .username="EN15177") OR (((p.username="EN15868") OR (((p.username="EN17657") OR (((p.username=
  "EN17757") OR (((p.username="EN17826") OR (((p.username="EN45832") OR (((p.username="EN47392") OR (
  p.username="EN48741")) )) )) )) )) )) )) )) )) ))
   AND p.username != "*RF*"
  WITH maxrec = 100
 ;end update
 COMMIT
END GO
