CREATE PROGRAM djh_ma_sn_id_spnd:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.username = concat(p.username,"Y",format(curdate,"YYMM;;d")), p.end_effective_dt_tm =
   cnvtdatetime(curdate,curtime3), p.active_status_cd = 194,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = 99999999
  WHERE p.active_ind=1
   AND p.active_status_cd != 189.00
   AND p.active_status_cd != 194.00
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,0)
   AND ((p.username="Z99999999") OR (((p.username="SN51278") OR (((p.username="SN50309") OR (((p
  .username="SN60154") OR (((p.username="SN60091") OR (((p.username="SN60015") OR (((p.username=
  "SN50398") OR (((p.username="SN62236") OR (((p.username="SN53760") OR (((p.username="SN50473") OR (
  ((p.username="SN62205") OR (((p.username="SN62004") OR (((p.username="SN50077") OR (((p.username=
  "SN53834") OR (((p.username="SN50380") OR (((p.username="SN63231") OR (((p.username="SN61090") OR (
  ((p.username="SN50428") OR (((p.username="SN63556") OR (((p.username="SN69095") OR (((p.username=
  "SN51062") OR (((p.username="SN62059") OR (((p.username="SN51160") OR (((p.username="SN50429") OR (
  ((p.username="SN73384") OR (((p.username="SN51082") OR (((p.username="SN60300") OR (((p.username=
  "SN61655") OR (((p.username="SN61659") OR (((p.username="SN51283") OR (((p.username="SN60254") OR (
  ((p.username="SN60666") OR (((p.username="SN60667") OR (((p.username="SN53503") OR (((p.username=
  "SN50435") OR (((p.username="SN50038") OR (((p.username="SN79155") OR (((p.username="SN61779") OR (
  ((p.username="SN62367") OR (((p.username="SN62139") OR (((p.username="SN62824") OR (((p.username=
  "SN61026") OR (((p.username="SN51555") OR (((p.username="SN60806") OR (((p.username="SN62818") OR (
  ((p.username="SN62817") OR (((p.username="SN62816") OR (((p.username="SN50143") OR (((p.username=
  "SN60262") OR (((p.username="SN60261") OR (((p.username="SN60267") OR (((p.username="SN60263") OR (
  ((p.username="SN60265") OR (((p.username="SN60266") OR (p.username="SN60268")) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  WITH maxrec = 100
 ;end update
 COMMIT
END GO
