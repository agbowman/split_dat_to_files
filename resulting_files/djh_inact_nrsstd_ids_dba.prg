CREATE PROGRAM djh_inact_nrsstd_ids:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.username = concat(p.username,"_",format(curdate,"YYYYMMDD;;d")), p.end_effective_dt_tm =
   cnvtdatetime(curdate,curtime3), p.active_status_cd = 194,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = 99999999
  WHERE p.active_ind=1
   AND p.active_status_cd != 189.00
   AND p.active_status_cd != 194.00
   AND ((p.username="Z99999999") OR (((p.username="SN60440") OR (((p.username="SN60448") OR (((p
  .username="SN70801") OR (((p.username="SN72587") OR (((p.username="SN72589") OR (((p.username=
  "SN72591") OR (((p.username="SN72593") OR (((p.username="SN72594") OR (((p.username="SN72811") OR (
  ((p.username="SN72866") OR (((p.username="SN72873") OR (((p.username="SN72874") OR (((p.username=
  "SN72875") OR (((p.username="SN72876") OR (((p.username="SN72884") OR (((p.username="SN72885") OR (
  ((p.username="SN72886") OR (((p.username="SN73259") OR (((p.username="SN73260") OR (((p.username=
  "SN73336") OR (((p.username="SN73347") OR (((p.username="SN73348") OR (((p.username="SN73351") OR (
  ((p.username="SN73352") OR (((p.username="SN73353") OR (((p.username="SN73355") OR (((p.username=
  "SN73362") OR (((p.username="SN73369") OR (((p.username="SN73506") OR (((p.username="SN75615") OR (
  p.username="SN75934")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) ))
 ;end update
 COMMIT
END GO
