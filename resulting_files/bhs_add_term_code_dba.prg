CREATE PROGRAM bhs_add_term_code:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.username = concat(p.username,"Y08"), p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p
   .updt_cnt = (p.updt_cnt+ 1),
   p.updt_id = 99999999
  WHERE p.physician_ind != 1
   AND p.active_ind=1
   AND p.active_status_cd=194.00
   AND ((p.username="Z99999999xyz") OR (((p.username="SN01842") OR (((p.username="SN61780") OR (((p
  .username="SN61782") OR (((p.username="SN61783") OR (((p.username="SN61961") OR (((p.username=
  "SN62342") OR (((p.username="SN62343") OR (((p.username="SN62368") OR (((p.username="SN62825") OR (
  ((p.username="SN62841") OR (((p.username="SN63057") OR (((p.username="SN63528") OR (((p.username=
  "SN63529") OR (((p.username="SN64546") OR (((p.username="SN65947") OR (((p.username="SN66200") OR (
  ((p.username="SN66201") OR (((p.username="SN66212") OR (((p.username="SN66220") OR (((p.username=
  "SN66232") OR (((p.username="SN66537") OR (((p.username="SN67426") OR (((p.username="SN67669") OR (
  ((p.username="SN68108") OR (((p.username="SN68122") OR (((p.username="SN68124") OR (((p.username=
  "SN68128") OR (((p.username="SN69587") OR (p.username="SN69957")) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  WITH maxrec = 100
 ;end update
 COMMIT
END GO
