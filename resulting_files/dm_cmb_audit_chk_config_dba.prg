CREATE PROGRAM dm_cmb_audit_chk_config:dba
 DECLARE cmb_audit_chk_emsg = vc WITH protect, noconstant("")
 DECLARE dcacc = i2 WITH protect, noconstant(0)
 FREE RECORD cmb_audit_chk
 RECORD cmb_audit_chk(
   1 cnt = i2
   1 list[*]
     2 parent_table = vc
     2 log_level = i2
 )
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="COMBINE_AUDIT_LOG_LEVEL::*"
  DETAIL
   cmb_audit_chk->cnt += 1, stat = alterlist(cmb_audit_chk->list,cmb_audit_chk->cnt), cmb_audit_chk->
   list[cmb_audit_chk->cnt].parent_table = substring((findstring("::",di.info_name)+ 2),size(di
     .info_name),di.info_name),
   cmb_audit_chk->list[cmb_audit_chk->cnt].log_level = di.info_number
  WITH nocounter
 ;end select
 IF (error(cmb_audit_chk_emsg,1) != 0)
  CALL echo(fillstring(90,"*"))
  CALL echo(concat("ERROR: ",cmb_audit_chk_emsg))
  CALL echo(fillstring(90,"*"))
  GO TO exit_program
 ENDIF
 CALL echo("*")
 CALL echo(fillstring(90,"*"))
 CALL echo(" The combine audit logging levels are currently set at:")
 FOR (dcacc = 1 TO cmb_audit_chk->cnt)
   CALL echo(concat("    ",cmb_audit_chk->list[dcacc].parent_table," -- ",cnvtstring(cmb_audit_chk->
      list[dcacc].log_level)))
 ENDFOR
 CALL echo(fillstring(90,"*"))
 CALL echo(" -- 1=combine level logging, 2=combine and table level logging, 0=no logging")
 CALL echo(" -- PERSON and PRSNL share a common logging level")
 CALL echo(" -- Combine types not shown will be defaulted with a logging level of 1")
 CALL echo(fillstring(90,"*"))
 CALL echo("*")
#exit_program
 FREE RECORD cmb_audit_chk
END GO
