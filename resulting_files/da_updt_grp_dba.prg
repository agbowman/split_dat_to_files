CREATE PROGRAM da_updt_grp:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person Name" = 0,
  "Select Action" = "",
  "Select Group" = 0
  WITH outdev, pname, actn_in,
  group_cd
 DECLARE grp_typ = vc WITH noconstant
 DECLARE grp_name = vc WITH noconstant
 DECLARE tab_cnt = i2 WITH noconstant(0)
 DECLARE p_name = vc WITH noconstant
 DECLARE newrltnid = f8
 DECLARE line_msg = vc WITH noconstant("Unexpected script failure")
 DECLARE userinfoid = f8 WITH noconstant(0.0)
 DECLARE userinfoactiveind = i2 WITH noconstant(0)
 DECLARE reportingcd = f8 WITH noconstant(0)
 DECLARE activestatuscd = f8 WITH noconstant(0)
 DECLARE stat = i4 WITH private, noconstant(0)
 DECLARE errormsg = vc WITH private, noconstant("")
 SET newrltnid = 0
 SET p_id =  $PNAME
 SET actn =  $ACTN_IN
 SET grp_cd =  $GROUP_CD
 RECORD temprpt(
   1 person_id = f8
   1 name_full_formatted = vc
   1 hassec = f8
   1 possecd = vc
   1 negsecd = vc
   1 possec_cd = f8
   1 negsec_cd = f8
   1 rowcnt = f8
   1 sec_typ = vc
   1 item_name = vc
 )
 SET grp_typ = uar_get_code_meaning(grp_cd)
 SET grp_name = uar_get_code_display(grp_cd)
 IF (((size(grp_typ,1)=0) OR (size(grp_name,1)=0)) )
  SET line_msg = "Group Code entered does not exist."
  GO TO end_now
 ENDIF
 SET activestatuscd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET tab_cnt = 0
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.person_id=p_id
  DETAIL
   tab_cnt += 1, p_name = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (tab_cnt=0)
  SET line_msg = "Person entered does not exist."
  GO TO end_now
 ENDIF
 SET reportingcd = uar_get_code_by_cki("CKI.CODEVALUE!4100899206")
 IF ((reportingcd=- (1)))
  SET errormsg = "No REPORTING code found in code set 355"
  GO TO end_now
 ENDIF
 SELECT INTO "nl:"
  pi.prsnl_info_id, pi.active_ind
  FROM prsnl_info pi
  WHERE pi.person_id=p_id
   AND info_type_cd=reportingcd
  DETAIL
   CALL echo(build("***** found info row=",pi.prsnl_info_id))
   IF (userinfoactiveind=0)
    userinfoid = pi.prsnl_info_id, userinfoactiveind = pi.active_ind
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(concat("Person name is ",p_name))
 CALL echo(build("PRSNL_INFO row id=",userinfoid,", active=",userinfoactiveind))
 SET stat = error(errormsg,1)
 IF (userinfoactiveind=0)
  IF (userinfoid=0)
   CALL echo("***** inserting new row into prsnl_info")
   INSERT  FROM prsnl_info
    SET prsnl_info_id = seq(prsnl_seq,nextval), person_id = p_id, info_type_cd = reportingcd,
     active_ind = 1, active_status_cd = activestatuscd, active_status_dt_tm = cnvtdatetime(sysdate),
     active_status_prsnl_id = reqinfo->updt_id, beg_effective_dt_tm = cnvtdatetime(sysdate),
     end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
     chartable_ind = 0, contributor_system_cd = 0, info_sub_type_cd = 0,
     long_text_id = 0, value_numeric = 0, updt_applctx = reqinfo->updt_app,
     updt_task = reqinfo->updt_task, updt_cnt = 0, updt_id = reqinfo->updt_id,
     updt_dt_tm = cnvtdatetime(sysdate)
    WITH nocounter
   ;end insert
  ELSE
   CALL echo(build("***** updating prsnl_info row, id=",userinfoid))
   UPDATE  FROM prsnl_info
    SET active_ind = 1, active_status_cd = activestatuscd, active_status_dt_tm = cnvtdatetime(sysdate
      ),
     active_status_prsnl_id = reqinfo->updt_id, end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00"), updt_applctx = reqinfo->updt_app,
     updt_task = reqinfo->updt_task, updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id,
     updt_dt_tm = cnvtdatetime(sysdate)
    WHERE prsnl_info_id=userinfoid
    WITH nocounter
   ;end update
  ENDIF
  IF (error(errormsg,1) != 0)
   SET errormsg = concat("Unable to set prsnl_info row: ",errormsg)
   GO TO end_now
  ENDIF
 ENDIF
 IF (actn="D")
  SET stat = error(errormsg,1)
  SET tab_cnt = 0
  SELECT INTO "nl:"
   FROM da_group_user_reltn gur
   PLAN (gur
    WHERE gur.group_cd=grp_cd
     AND gur.prsnl_id=p_id)
   DETAIL
    tab_cnt += 1
   WITH nocounter
  ;end select
  IF (tab_cnt=0)
   SET line_msg = "Record does not exist."
   GO TO end_now
  ENDIF
  DELETE  FROM da_group_user_reltn gur
   WHERE gur.group_cd=grp_cd
    AND gur.prsnl_id=p_id
  ;end delete
  IF (error(errormsg,0) != 0)
   SET line_msg = errormsg
  ELSE
   SET line_msg = "Record successfully deleted."
   COMMIT
  ENDIF
 ELSEIF (actn="A")
  SET stat = error(errormsg,1)
  SELECT INTO "nl:"
   nextseq = seq(da_seq,nextval)
   FROM dual
   DETAIL
    newrltnid = cnvtreal(nextseq)
   WITH counter, format
  ;end select
  INSERT  FROM da_group_user_reltn gur
   SET gur.da_group_user_reltn_id = newrltnid, gur.group_cd = grp_cd, gur.prsnl_id = p_id,
    gur.updt_dt_tm = cnvtdatetime(sysdate), gur.updt_id = reqinfo->updt_id, gur.updt_cnt = 0,
    gur.updt_task = reqinfo->updt_task, gur.updt_applctx = reqinfo->updt_app
  ;end insert
  IF (error(errormsg,0) != 0)
   SET line_msg = errormsg
  ELSE
   SET line_msg = "Record inserted."
   COMMIT
  ENDIF
 ELSE
  SET line_msg = "Invalid action."
  GO TO end_now
 ENDIF
#end_now
 SELECT INTO  $OUTDEV
  line_msg
  FROM dummyt
  WITH nocounter, separator = " ", format
 ;end select
END GO
