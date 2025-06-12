CREATE PROGRAM edw_execute_cclscript:dba
 DECLARE installtype = vc WITH private, noconstant(" ")
 DECLARE scriptname = vc WITH private, noconstant(" ")
 DECLARE fieldstat = i4 WITH private, noconstant(0)
 DECLARE dynamicwhereclause = vc WITH private, noconstant(" ")
 DECLARE loopcnt = i4 WITH private, noconstant(0)
 DECLARE scriptcount = i4 WITH protect, noconstant(0)
 DECLARE edwexecutescript(edwscriptname=vc(value)) = null WITH protect
 DECLARE edw_write_to_msg_log(script_name=vc,severity=i2,message=vc,updttask=vc) = i2 WITH public
 SUBROUTINE edw_write_to_msg_log(script_name,severity,message,updttask)
   IF (((script_name=null) OR (((((severity > 3) OR (severity < 1)) ) OR (message=null)) )) )
    CALL echo("The parameters to write_to_msg_log() are incorrect")
    RETURN(1)
   ELSE
    INSERT  FROM wh_oth_process_msg_log msg_log
     SET msg_log.object_name = script_name, msg_log.severity_flg = severity, msg_log.message_text =
      message,
      msg_log.process_dt_tm = cnvtdatetime(curdate,curtime3), msg_log.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), msg_log.updt_task = updttask,
      msg_log.updt_user = "CCL"
     WITH nocounter
    ;end insert
    COMMIT
    RETURN(0)
   ENDIF
 END ;Subroutine
 RECORD edwscriptnames(
   1 qual[*]
     2 script_name = vc
 )
 SET installtype = trim( $1)
 SET scriptname = trim( $2)
 IF (size(installtype) <= 0
  AND size(scriptname) <= 0)
  CALL edw_write_to_msg_log("edw_execute_cclscript",3,
   "No Scripts Executed, No valid params passed-in","INSTALL")
  GO TO exit_script
 ENDIF
 IF (size(installtype) > 0)
  SET installtype = build("'",installtype,"'")
  SET dynamicwhereclause = concat(" WOCV.CNFG_VALUE_TYPE  = ",installtype)
  SELECT INTO "nl:"
   FROM wh_oth_cnfg_val wocv
   WHERE wocv.cnfg_value_range BETWEEN 3502 AND 4000
    AND wocv.cnfg_value_use="1"
    AND parser(dynamicwhereclause)
   DETAIL
    scriptcount = (scriptcount+ 1)
    IF (mod(scriptcount,10)=1)
     fieldstat = alterlist(edwscriptnames->qual,(scriptcount+ 9))
    ENDIF
    IF (wocv.cnfg_value > "")
     edwscriptnames->qual[scriptcount].script_name = wocv.cnfg_value
    ENDIF
   WITH nocounter
  ;end select
  SET fieldstat = alterlist(edwscriptnames->qual,scriptcount)
  IF (scriptcount <= 0)
   CALL edw_write_to_msg_log("edw_execute_cclscript",3,
    "No Scripts Executed, Select did not return any for the wh_oth_cnfg_val table","INSTALL")
   GO TO exit_script
  ENDIF
  FOR (loopcnt = 1 TO scriptcount)
    CALL edwexecutescript(edwscriptnames->qual[loopcnt].script_name)
  ENDFOR
 ENDIF
 IF (size(scriptname) > 0)
  CALL edwexecutescript(scriptname)
 ENDIF
 SUBROUTINE edwexecutescript(edwscriptname)
   EXECUTE value(edwscriptname)
 END ;Subroutine
#exit_script
 FREE RECORD edwscriptnames
END GO
