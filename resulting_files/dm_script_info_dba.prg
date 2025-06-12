CREATE PROGRAM dm_script_info:dba
 FREE RECORD dm_script
 RECORD dm_script(
   1 dm_environ_id = f8
   1 project_instance = f8
   1 script_list[*]
     2 script_name = vc
 )
 IF ( NOT (validate(dm_script_scanner_reply,0)))
  FREE RECORD dm_script_scanner_reply
  RECORD dm_script_scanner_reply(
    1 script_name = vc
    1 fail_ind = i2
    1 err_list[*]
      2 fail_number = i4
      2 fail_message = vc
  )
 ENDIF
 DECLARE dm_err = i2 WITH public, noconstant(0)
 DECLARE dm_script_cnt = i4 WITH public, noconstant(0)
 DECLARE dm_err_msg = vc WITH public, noconstant(" ")
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE d_exception = i2 WITH public, noconstant(0)
 DECLARE dm_str = vc WITH public, noconstant(" ")
 DECLARE dclcom = vc WITH public, noconstant(" ")
 DECLARE dm_unique_dat1x = vc
 DECLARE dm_unique_dat_outputx = vc
 DECLARE dm_unique_planx = vc
 DECLARE d_exception_name = vc
 SET d_exception = 0
 SET full_tab_cnt = 0
 SET dm_unique_dat1x = concat(cnvtlower(curuser),trim(cnvtstring(curtime3),3))
 SET dm_unique_dat_outputx = concat(dm_unique_dat1x,"output")
 SET dm_unique_planx = concat(dm_unique_dat1x,"plan")
 SET dm_script->project_instance =  $2
 SET trace = nordbdebug
 SET trace = nordbbind
 SET trace = nordbplan
 IF (findstring("*", $1) > 0)
  DECLARE dm_error_ind = i2
  SELECT INTO "nl:"
   d.object_name
   FROM dprotect d
   WHERE d.object_name=patstring(cnvtupper( $1))
    AND d.object="P"
   ORDER BY d.object_name
   HEAD REPORT
    dm_script_cnt = 0
   DETAIL
    dm_script_cnt = (dm_script_cnt+ 1)
    IF (mod(dm_script_cnt,10)=1)
     stat = alterlist(dm_script->script_list,(dm_script_cnt+ 9))
    ENDIF
    dm_script->script_list[dm_script_cnt].script_name = d.object_name
   FOOT REPORT
    stat = alterlist(dm_script->script_list,dm_script_cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo("*************************************************")
   CALL echo(concat(dm_script->script_list[dm_script_cnt].script_name,
     " was not found in the dictionary."))
   CALL echo("*************************************************")
   SET dm_error_ind = 1
   GO TO very_bottom
  ENDIF
 ELSE
  SET dm_script_cnt = 1
  SET stat = alterlist(dm_script->script_list,1)
  SET dm_script->script_list[dm_script_cnt].script_name = cnvtupper( $1)
  SET d_exception = 0
  SELECT INTO "nl:"
   FROM script_scan_exception sse
   WHERE (sse.name=dm_script->script_list[dm_script_cnt].script_name)
   DETAIL
    d_exception = 1, d_exception_name = sse.error_text
   WITH nocounter
  ;end select
  IF (d_exception=1)
   IF (((d_exception_name="'DM*' SCRIPT") OR (d_exception_name="EMERGENCY*")) )
    SET dm_script_scanner_reply->fail_ind = 0
    SET dm_error_ind = 1
    SET dm_err = (dm_err+ 1)
    SET stat = alterlist(dm_script_scanner_reply->err_list,dm_err)
    SET dm_script_scanner_reply->err_list[dm_err].fail_message = "Success"
    GO TO very_bottom
   ELSE
    DELETE  FROM script_scan_exception sse
     WHERE (sse.name=dm_script->script_list[dm_script_cnt].script_name)
     WITH nocounter
    ;end delete
    COMMIT
   ENDIF
  ELSE
   IF (findstring("DM",substring(1,2,dm_script->script_list[dm_script_cnt].script_name)) > 0)
    INSERT  FROM script_scan_exception sse
     SET sse.name = dm_script->script_list[dm_script_cnt].script_name, sse.error_text =
      "'DM*' SCRIPT"
     WITH nocounter
    ;end insert
    COMMIT
    SET dm_script_scanner_reply->fail_ind = 0
    SET dm_error_ind = 1
    SET dm_err = (dm_err+ 1)
    SET stat = alterlist(dm_script_scanner_reply->err_list,dm_err)
    SET dm_script_scanner_reply->err_list[dm_err].fail_message = "Success"
    GO TO very_bottom
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   dm_script->dm_environ_id = di.info_number
  WITH nocounter
 ;end select
 FOR (dm_cnt = 1 TO dm_script_cnt)
   SET trace symbol mark
   EXECUTE dm_script_info_c
   SET trace symbol release
 ENDFOR
 COMMIT
#end_program
 FREE RECORD dm_script
 CALL echo("*** Removing DAT files ***")
 IF (cursys="AIX")
  SET dclcom = concat("rm ",dm_unique_dat1x,"*.*")
 ELSE
  SET dclcom = build("delete ccluserdir:",dm_unique_dat1x,"*.*;*")
 ENDIF
 SET len = size(trim(dclcom))
 SET status = 0
 CALL dcl(dclcom,len,status)
 IF (status=0)
  CALL echo("** Removal of DAT Files Failed **")
 ELSE
  CALL echo(concat("** Removal of:",dm_unique_dat1x,"*.* complete **"))
 ENDIF
#very_bottom
END GO
