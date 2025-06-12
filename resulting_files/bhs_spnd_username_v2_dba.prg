CREATE PROGRAM bhs_spnd_username_v2:dba
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
   AND ((p.username="Z99999999") OR (((p.username="EN00748") OR (((p.username="EN02289") OR (((p
  .username="EN06133") OR (((p.username="EN09271") OR (((p.username="EN13463") OR (((p.username=
  "EN14258") OR (((p.username="EN14297") OR (((p.username="EN14311") OR (((p.username="EN15446") OR (
  ((p.username="EN15604") OR (((p.username="EN15966") OR (((p.username="EN16255") OR (((p.username=
  "EN16284") OR (((p.username="EN17667") OR (((p.username="EN31027") OR (((p.username="EN36247") OR (
  ((p.username="EN45113") OR (((p.username="EN46541") OR (p.username="EN48165")) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) ))
  WITH maxrec = 100
 ;end update
 COMMIT
END GO
