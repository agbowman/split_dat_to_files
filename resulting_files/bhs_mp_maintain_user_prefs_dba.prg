CREATE PROGRAM bhs_mp_maintain_user_prefs:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "User ID:" = "",
  "Preference Identifier:" = "",
  "String with user preferences:" = "",
  "Command (GET, SET):" = ""
  WITH outdev, s_prsnl_id, s_prefs_name,
  s_prefs_string, s_command
 EXECUTE bhs_hlp_ccl
 DECLARE mf_prsnl_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_prefs_name = vc WITH protect, noconstant(" ")
 DECLARE ms_prefs_name_key = vc WITH protect, noconstant(" ")
 DECLARE ms_prefs_string_in = vc WITH protect, noconstant(" ")
 DECLARE ms_prefs_string_out = vc WITH protect, noconstant(" ")
 DECLARE ms_command = vc WITH protect, noconstant(" ")
 DECLARE ms_errmsg = vc WITH protect, noconstant(" ")
 DECLARE ml_errcode = i4 WITH protect, noconstant(0)
 DECLARE ms_msg = vc WITH protect, noconstant(" ")
 DECLARE ms_script_status = vc WITH protect, noconstant(" ")
 DECLARE sbr_removespecchar(ps_strtoclean=vc) = vc
 CALL bhs_sbr_log("start","",0,"",0.0,
  "","Begin Script","")
 SET mf_prsnl_id = cnvtreal(trim( $S_PRSNL_ID,3))
 SET ms_prefs_name = trim( $S_PREFS_NAME,3)
 SET ms_prefs_string_in = trim( $S_PREFS_STRING,3)
 SET ms_command = cnvtupper(trim( $S_COMMAND,3))
 SET ms_prefs_name_key = sbr_removespecchar(cnvtupper(ms_prefs_name))
 IF (mf_prsnl_id=0.00)
  SET ms_prefs_string_out = "ERROR: User ID is zero"
  SET ms_msg = ms_prefs_string_out
  SET ms_script_status = "F"
  CALL bhs_sbr_log("log","",0,"prsnl_id",mf_prsnl_id,
   "ERROR",build(ms_msg,":",mf_prsnl_id),ms_script_status)
  GO TO exit_script
 ENDIF
 IF (ms_command="GET")
  SELECT INTO "nl:"
   FROM bhs_mpage_prefs b
   WHERE b.prsnl_id=mf_prsnl_id
    AND b.prefs_name_key=ms_prefs_name_key
    AND b.active_ind=1
   DETAIL
    ms_prefs_string_out = b.prefs_value
   WITH nocounter
  ;end select
  SET ml_errcode = error(ms_errmsg,1)
  IF (ml_errcode > 0)
   SET ms_prefs_string_out = concat("ERROR:",trim(ms_errmsg,3))
   SET ms_msg = trim(ms_errmsg,3)
   SET ms_script_status = "F"
   CALL bhs_sbr_log("err","",0,"prsnl_id",mf_prsnl_id,
    "ERROR",trim(ms_errmsg,3),ms_script_status)
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   SET ms_prefs_string_out = "No prefs found"
   SET ms_msg = ms_prefs_string_out
   SET ms_script_status = "S"
   CALL bhs_sbr_log("log","",0,"prsnl_id",mf_prsnl_id,
    ms_msg,build("No ",ms_prefs_name_key," prefs found for prsnl_id: ",mf_prsnl_id),ms_script_status)
   GO TO exit_script
  ENDIF
  SET ms_script_status = "S"
 ELSEIF (ms_command="SET")
  UPDATE  FROM bhs_mpage_prefs b
   SET b.prefs_value = ms_prefs_string_in, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = sysdate,
    b.updt_id = reqinfo->updt_id
   WHERE b.prsnl_id=mf_prsnl_id
    AND b.prefs_name_key=ms_prefs_name_key
    AND b.active_ind=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM bhs_mpage_prefs b
    SET b.active_ind = 1, b.prefs_name = ms_prefs_name, b.prefs_name_key = ms_prefs_name_key,
     b.mpage_prefs_id = seq(bhs_eks_seq,nextval), b.prefs_value = ms_prefs_string_in, b.prsnl_id =
     mf_prsnl_id,
     b.updt_cnt = 0, b.updt_dt_tm = sysdate, b.updt_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
  ENDIF
  COMMIT
  SET ml_errcode = error(ms_errmsg,1)
  IF (ml_errcode > 0)
   SET ms_prefs_string_out = concat("ERROR:",trim(ms_errmsg,3))
   SET ms_msg = trim(ms_errmsg,3)
   SET ms_script_status = "F"
   CALL bhs_sbr_log("err","",0,"prsnl_id",mf_prsnl_id,
    "ERROR",trim(ms_errmsg,3),ms_script_status)
   GO TO exit_script
  ENDIF
  SET ms_script_status = "S"
  SET ms_prefs_string_out = ms_prefs_string_in
 ENDIF
 SUBROUTINE sbr_removespecchar(ps_strtoclean)
   DECLARE ps_out = vc WITH noconstant(" ")
   SET ps_strtoclean = replace(ps_strtoclean,"$","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"#","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"/","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"$","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"%","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"*","",0)
   SET ps_strtoclean = replace(ps_strtoclean," ","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"_","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"&","",0)
   SET ps_strtoclean = replace(ps_strtoclean,",","",0)
   SET ps_strtoclean = replace(ps_strtoclean,".","",0)
   SET ps_strtoclean = replace(ps_strtoclean,'"',"",0)
   SET ps_strtoclean = replace(ps_strtoclean,"'","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"=","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"+","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"\","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"-","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"*","",0)
   SET ps_strtoclean = replace(ps_strtoclean,":","",0)
   SET ps_strtoclean = replace(ps_strtoclean,";","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"~","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"?","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"<","",0)
   SET ps_strtoclean = replace(ps_strtoclean,">","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"{","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"}","",0)
   SET ps_strtoclean = replace(ps_strtoclean,"(","",0)
   SET ps_strtoclean = replace(ps_strtoclean,")","",0)
   SET ps_out = ps_strtoclean
   RETURN(ps_out)
 END ;Subroutine
#exit_script
 CALL bhs_sbr_log("stop","",0,"",0.0,
  build(ms_prefs_name_key," prefs for prsnl_id: ",mf_prsnl_id),ms_msg,ms_script_status)
 SET _memory_reply_string = ms_prefs_string_out
 FREE SUBROUTINE sbr_removespecchar
END GO
