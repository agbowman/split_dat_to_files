CREATE PROGRAM bhs_fh_user_auth:dba
 PROMPT
  "FH Application Name" = "MINE"
  WITH s_fh_app_name
 DECLARE ms_fh_app = vc WITH protect, noconstant(trim(cnvtupper( $S_FH_APP_NAME)))
 DECLARE mc_authorized = c1 WITH protect, noconstant("F")
 DECLARE ms_username = vc WITH protect, noconstant(" ")
 DECLARE ms_extsec_email = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
   AND p.active_ind=1
   AND p.end_effective_dt_tm > sysdate
   AND p.username != "TERM*"
  HEAD p.person_id
   ms_username = trim(cnvtupper(p.username))
  WITH nocounter
 ;end select
 SET mc_authorized = "S"
 SET _memory_reply_string = concat('{"STATUS":"',mc_authorized,'",','"USERID":"',trim(cnvtstring(
    reqinfo->updt_id)),
  '","USERNAME":"',trim(ms_username),'",','"POSITION":"',trim(uar_get_code_display(reqinfo->
    position_cd)),
  '"}')
 CALL echo(_memory_reply_string)
#exit_script
END GO
