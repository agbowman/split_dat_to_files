CREATE PROGRAM ccl_upd_rpt_audit_config:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Add or Delete?" = 1,
  "Audit type:" = "",
  "CCL Program:" = "",
  "Select User:" = ""
  WITH outdev, add_delete, audit_type,
  ccl_program, username
 DECLARE saudittype = vc WITH constant( $AUDIT_TYPE)
 DECLARE sauditname = vc
 DECLARE susername = vc
 DECLARE sdisplaytext = vc
 DECLARE info_number = f8 WITH noconstant(1.0)
 DECLARE serrorccl = vc WITH noconstant(fillstring(255," "))
 SET sauditname = cnvtupper(trim( $CCL_PROGRAM))
 IF (textlen(sauditname)=0)
  SET susername = cnvtupper(trim( $USERNAME))
  IF (textlen(susername)=0)
   SET sdisplaytext = "CCL Program Name and User Name Invalid! DM_INFO update not performed."
   GO TO exit_error
  ENDIF
 ENDIF
 IF (textlen(susername) > 0)
  SELECT INTO "nl:"
   p.person_id
   FROM prsnl p
   WHERE p.username=susername
   DETAIL
    info_number = p.person_id
   WITH nocounter
  ;end select
  SET sauditname = susername
 ENDIF
 IF (( $ADD_DELETE=1))
  INSERT  FROM dm_info d
   SET d.info_domain = "CCL_REPORT_AUDIT", d.info_name = sauditname, d.info_number = info_number,
    d.info_date = cnvtdatetime(sysdate), d.info_char = saudittype, d.updt_dt_tm = cnvtdatetime(
     curdate,curtime),
    d.updt_id = reqinfo->updt_id, d.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
 ELSEIF (( $ADD_DELETE=2))
  DELETE  FROM dm_info d
   WHERE d.info_domain="CCL_REPORT_AUDIT"
    AND d.info_name=sauditname
    AND d.info_number=info_number
    AND d.info_char=saudittype
   WITH nocounter
  ;end delete
 ENDIF
 IF (curqual=1)
  COMMIT
  SET sdisplaytext = build("Action: ",evaluate( $ADD_DELETE,1,"INSERT",2,"DELETE"),", Audit Type= ",
   saudittype,", Name= ",
   sauditname)
  SELECT INTO  $OUTDEV
   d.*
   FROM dummyt d
   HEAD REPORT
    col 0, "DM_INFO row updated successfully.", row + 1,
    col 0, sdisplaytext, row + 1
   WITH nocounter
  ;end select
  GO TO exit_script
 ELSE
  SET sdisplaytext = build("Failed to update DM_INFO row! Action: ",evaluate( $ADD_DELETE,1,"INSERT",
    2,"DELETE"),", Audit Type= ",saudittype,", Name= ",
   sauditname)
  SET errcode = error(serrorccl,1)
  IF (errcode != 0)
   CALL echo(serrorccl)
   SET failed = "T"
   GO TO exit_error
  ENDIF
 ENDIF
#exit_error
 SELECT INTO  $OUTDEV
  d.*, errortext = trim(substring(1,130,serrorccl))
  FROM dummyt d
  HEAD REPORT
   col 0, sdisplaytext, row + 1,
   col 0, errortext, row + 1
  WITH nocounter
 ;end select
#exit_script
END GO
