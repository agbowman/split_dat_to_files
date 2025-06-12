CREATE PROGRAM bhs_term_username_v2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.username = concat("SPND",p.username,"_",format(curdate,"YYYYMMDD;;d")), p.end_effective_dt_tm
    = cnvtdatetime(curdate,curtime3), p.active_status_cd = 194,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = 99999999
  WHERE ((p.physician_ind != 1) OR (p.physician_ind=1
   AND p.position_cd=228835487))
   AND p.active_ind=1
   AND p.active_status_cd != 189.00
   AND p.active_status_cd != 194.00
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,0)
   AND ((p.username="Z99999999") OR (((p.username="EN12767") OR (((p.username="EN10873") OR (((p
  .username="EN16778") OR (((p.username="EN14536") OR (((p.username="EN49182") OR (((p.username=
  "EN15944") OR (((p.username="EN01999") OR (((p.username="EN16717") OR (((p.username="EN07290") OR (
  ((p.username="EN13552") OR (((p.username="EN15949") OR (((p.username="EN13513") OR (((p.username=
  "EN13575") OR (((p.username="EN47250") OR (((p.username="EN15727") OR (((p.username="EN16384") OR (
  ((p.username="EN15811") OR (((p.username="EN15809") OR (((p.username="EN47005") OR (((p.username=
  "EN11768") OR (((p.username="EN13256") OR (((p.username="EN15417") OR (((p.username="EN15899") OR (
  ((p.username="EN15900") OR (((p.username="EN14222") OR (((p.username="EN16001") OR (((p.username=
  "EN48763") OR (p.username="EN06083")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) ))
  WITH maxrec = 100
 ;end update
 COMMIT
END GO
