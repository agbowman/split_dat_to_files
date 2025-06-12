CREATE PROGRAM bhs_inact_username_v2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.username = concat("NA-",p.username,"_",format(curdate,"YYYYMMDD;;d")), p.end_effective_dt_tm
    = cnvtdatetime(curdate,curtime3), p.active_status_cd = 194,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = 99999999
  WHERE ((p.physician_ind != 1) OR (p.physician_ind=1
   AND p.position_cd=228835487))
   AND p.active_ind=1
   AND p.active_status_cd != 189.00
   AND p.active_status_cd != 194.00
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,0)
   AND ((p.username="Z99999999") OR (((p.username="EN43934") OR (((p.username="EN10946") OR (((p
  .username="EN23494") OR (((p.username="EN05858") OR (((p.username="EN43070") OR (((p.username=
  "EN14401") OR (((p.username="EN48109") OR (((p.username="SN62821") OR (((p.username="EN14705") OR (
  ((p.username="EN11996") OR (((p.username="PN55233") OR (((p.username="EN45290") OR (((p.username=
  "EN06642") OR (((p.username="EN42084") OR (((p.username="PN60687") OR (((p.username="EN11924") OR (
  ((p.username="EN05424") OR (((p.username="EN42596") OR (((p.username="EN44875") OR (((p.username=
  "EN14649") OR (((p.username="PN61676") OR (p.username="EN43211")) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) ))
  WITH maxrec = 100
 ;end update
 COMMIT
END GO
