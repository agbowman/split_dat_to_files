CREATE PROGRAM djh_inact_medstd:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.username = concat("TERM",p.username,"_",format(curdate,"YYYYMMDD;;d")), p.end_effective_dt_tm
    = cnvtdatetime(curdate,curtime3), p.active_status_cd = 194,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = 99999999
  WHERE p.position_cd=227477522
   AND p.active_ind=1
   AND p.active_status_cd != 189.00
   AND p.active_status_cd != 194.00
   AND ((p.username="Z99999999") OR (((p.username="SN75129*") OR (((p.username="SN74637*") OR (((p
  .username="SN78888*") OR (((p.username="SN75349*") OR (((p.username="SN75127*") OR (((p.username=
  "SN75130*") OR (((p.username="SN78814*") OR (((p.username="SN77845*") OR (((p.username="SN74674*")
   OR (((p.username="SN78816*") OR (((p.username="SN77849*") OR (((p.username="SN77846*") OR (((p
  .username="SN77775*") OR (((p.username="SN75134*") OR (((p.username="SN74678*") OR (((p.username=
  "SN75135*") OR (((p.username="SN75136*") OR (((p.username="SN77533*") OR (((p.username="SN75137*")
   OR (((p.username="SN75150*") OR (((p.username="SN74642*") OR (((p.username="SN78817*") OR (((p
  .username="SN78818*") OR (((p.username="SN78823*") OR (((p.username="SN75139*") OR (((p.username=
  "SN79743*") OR (((p.username="SN75093*") OR (((p.username="SN74644*") OR (((p.username="SN74657*")
   OR (((p.username="SN63155*") OR (((p.username="SN77850*") OR (((p.username="SN75141*") OR (((p
  .username="SN75142*") OR (((p.username="SN75806*") OR (((p.username="SN74645*") OR (((p.username=
  "SN77783*") OR (((p.username="SN70645*") OR (((p.username="SN74676*") OR (((p.username="SN75144*")
   OR (((p.username="SN74648*") OR (((p.username="SN76344*") OR (((p.username="SN75149*") OR (((p
  .username="SN72365*") OR (((p.username="SN62359*") OR (((p.username="SN75146*") OR (((p.username=
  "SN75147*") OR (((p.username="SN74649*") OR (((p.username="SN74650*") OR (((p.username="SN78810*")
   OR (((p.username="SN74651*") OR (((p.username="SN75128*") OR (((p.username="SN78824*") OR (((p
  .username="SN74652*") OR (((p.username="SN75148*") OR (((p.username="SN74680*") OR (((p.username=
  "SN77847*") OR (((p.username="SN74653*") OR (((p.username="SN77538*") OR (((p.username="SN75151*")
   OR (((p.username="SN75108*") OR (((p.username="SN77541*") OR (((p.username="SN77852*") OR (((p
  .username="SN74656*") OR (p.username="SN77848*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) ))
 ;end update
 COMMIT
END GO
