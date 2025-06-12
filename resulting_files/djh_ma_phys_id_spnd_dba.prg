CREATE PROGRAM djh_ma_phys_id_spnd:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.username = concat("TERMHR",p.username,"_",format(curdate,"YYYYMMDD;;d")), p.updt_dt_tm =
   cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1),
   p.updt_id = 99999999
  WHERE p.active_ind=1
   AND p.username != "SPND*"
   AND p.username != "TERM*"
   AND p.active_status_cd != 189.00
   AND p.active_status_cd != 194.00
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,0)
   AND ((p.username="Z99999999") OR (((p.username="EN10705") OR (((p.username="EN10713") OR (((p
  .username="EN12067") OR (((p.username="EN12126") OR (((p.username="EN13492") OR (((p.username=
  "EN13505") OR (((p.username="EN13515") OR (((p.username="EN13525") OR (((p.username="EN13537") OR (
  ((p.username="EN13540") OR (((p.username="EN13558") OR (((p.username="EN14549") OR (((p.username=
  "EN14556") OR (((p.username="EN14557") OR (((p.username="EN14570") OR (((p.username="EN14572") OR (
  ((p.username="EN14583") OR (((p.username="EN14584") OR (((p.username="EN14588") OR (((p.username=
  "EN14589") OR (((p.username="EN14596") OR (((p.username="EN14597") OR (((p.username="EN14599") OR (
  ((p.username="EN14602") OR (((p.username="EN14605") OR (((p.username="EN14609") OR (((p.username=
  "EN14610") OR (((p.username="EN14611") OR (((p.username="EN14613") OR (((p.username="EN14619") OR (
  ((p.username="EN14630") OR (((p.username="EN14632") OR (((p.username="EN14639") OR (((p.username=
  "EN14640") OR (((p.username="EN14643") OR (((p.username="EN15502") OR (((p.username="EN15516") OR (
  ((p.username="EN15520") OR (((p.username="EN15521") OR (((p.username="EN15522") OR (((p.username=
  "EN15523") OR (((p.username="EN15524") OR (((p.username="EN15535") OR (((p.username="EN15548") OR (
  ((p.username="EN15550") OR (((p.username="EN15553") OR (((p.username="EN15558") OR (((p.username=
  "EN15560") OR (((p.username="EN15574") OR (((p.username="EN15576") OR (((p.username="EN15578") OR (
  ((p.username="EN15579") OR (((p.username="EN15580") OR (((p.username="EN15585") OR (((p.username=
  "EN15588") OR (((p.username="EN15590") OR (((p.username="EN15594") OR (((p.username="EN15600") OR (
  ((p.username="EN15601") OR (((p.username="EN15602") OR (((p.username="EN16557") OR (((p.username=
  "EN16563") OR (((p.username="EN16592") OR (((p.username="EN16593") OR (((p.username="EN16598") OR (
  ((p.username="EN16605") OR (((p.username="EN16610") OR (((p.username="EN16616") OR (((p.username=
  "EN17232") OR (((p.username="EN17233") OR (((p.username="EN17234") OR (((p.username="EN17251") OR (
  ((p.username="EN17265") OR (((p.username="EN17267") OR (((p.username="EN17269") OR (((p.username=
  "EN17271") OR (((p.username="EN17273") OR (((p.username="EN17282") OR (((p.username="EN17283") OR (
  ((p.username="EN17292") OR (((p.username="EN17310") OR (((p.username="EN17321") OR (((p.username=
  "EN17322") OR (((p.username="EN17329") OR (p.username="EN48993")) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) ))
  WITH maxrec = 100
 ;end update
 COMMIT
END GO
