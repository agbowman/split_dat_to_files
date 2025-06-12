CREATE PROGRAM bhs_inact_username_v2a:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_cd = 194, p.updt_dt_tm
    = cnvtdatetime(curdate,curtime3),
   p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = 99999999
  WHERE ((p.physician_ind != 1) OR (p.physician_ind=1
   AND p.position_cd=925850))
   AND p.active_ind=1
   AND p.active_status_cd != 189.00
   AND p.active_status_cd != 194.00
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,0)
   AND ((p.username="Z99999999") OR (((p.username="SN70173") OR (((p.username="EN23801") OR (((p
  .username="EN49035") OR (((p.username="EN47582") OR (((p.username="SN65947") OR (((p.username=
  "EN13470") OR (((p.username="DB014062") OR (((p.username="EN47485") OR (((p.username="EN42484") OR
  (((p.username="EN48953") OR (((p.username="PN53997") OR (((p.username="PN61876") OR (((p.username=
  "EN10110") OR (((p.username="EN03632") OR (((p.username="EN10724") OR (((p.username="EN46113") OR (
  ((p.username="EN45730") OR (((p.username="SN62342") OR (((p.username="SN70199") OR (((p.username=
  "EN10999") OR (((p.username="EN11617") OR (((p.username="PN71007") OR (((p.username="SPNDEN48914")
   OR (((p.username="EN10369") OR (((p.username="EN04602") OR (((p.username="SI01133") OR (((p
  .username="PN65162") OR (((p.username="SPNDEN46495") OR (((p.username="EN03543") OR (((p.username=
  "EN10691") OR (((p.username="SN68128") OR (((p.username="EN46516") OR (((p.username="SPNDEN47519")
   OR (((p.username="EN03789") OR (((p.username="SN65395") OR (((p.username="SN62343") OR (((p
  .username="PN65185") OR (((p.username="EN12329") OR (((p.username="EN06468") OR (((p.username=
  "EN00412") OR (((p.username="PN61939") OR (((p.username="EN46462") OR (((p.username="EN02378") OR (
  ((p.username="EN13809") OR (((p.username="SN64865") OR (((p.username="EN10394") OR (((p.username=
  "SN65459") OR (((p.username="EN11736") OR (((p.username="EN12121") OR (((p.username="EN12996") OR (
  p.username="EN26764")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  WITH maxrec = 100
 ;end update
 COMMIT
END GO
