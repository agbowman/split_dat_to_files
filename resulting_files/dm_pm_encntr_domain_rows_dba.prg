CREATE PROGRAM dm_pm_encntr_domain_rows:dba
 CALL echo("***** dm_pm_encntr_domain_rows - 47589 *****")
 CALL echo("***** dm_pm_encntr_domain_rows - 47589b *****")
 CALL echo("***** dm_pm_encntr_domain_rows - 47589c *****")
 CALL echo("***** dm_pm_encntr_domain_rows - 186432 *****")
 CALL echo("***** dm_pm_encntr_domain_rows - 608886 *****")
 DECLARE bskipcombinepurgeopt = i2 WITH noconstant(false)
 DECLARE ldaystokeep = i4 WITH protect, noconstant(- (1))
 DECLARE lerrcode = i4 WITH protect, noconstant(0)
 DECLARE lrowsleft = i4 WITH protect, noconstant(request->max_rows)
 DECLARE lrowcnt = i4 WITH protect, noconstant(0)
 DECLARE l18nhandle = i4 WITH public, noconstant(0)
 DECLARE l18nstatus = i4 WITH public, noconstant(0)
 DECLARE ltokencnt = i4 WITH public, noconstant(0)
 DECLARE dcancelledcd = f8 WITH protect, noconstant(0.0)
 DECLARE dcensustypecd = f8 WITH protect, noconstant(- (1.0))
 DECLARE dpurgecmb = f8 WITH noconstant(0.0)
 DECLARE serrmsg = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SET l18nhandle = 0
 SET l18nstatus = uar_i18nlocalizationinit(l18nhandle,curprog,"",curcclrev)
 FOR (ltokencnt = 1 TO size(request->tokens,5))
   IF ((request->tokens[ltokencnt].token_str="DAYSTOKEEP"))
    SET ldaystokeep = ceil(cnvtreal(request->tokens[ltokencnt].value))
    SET ltokencnt = (size(request->tokens,5)+ 1)
   ENDIF
 ENDFOR
 IF (ldaystokeep < 7)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(l18nhandle,"KEEPDAYS",
   "You must keep at least 7 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",ldaystokeep)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->table_name = "ENCNTR_DOMAIN"
  SET reply->rows_between_commit = minval(10000,request->max_rows)
  SET stat = uar_get_meaning_by_codeset(20790,"PURGECMB",1,dpurgecmb)
  IF (dpurgecmb=0.0)
   SET reply->err_code = - (1)
   SET reply->status_data.status = "F"
   SET reply->err_msg = uar_i18ngetmessage(l18nhandle,"PURGECMB",
    "Unable to find CDF meaning PURGECMB in code set 20790.")
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM code_value_extension cve
   WHERE cve.code_value=dpurgecmb
    AND cve.field_name="OPTION"
    AND cve.code_set=20790
   DETAIL
    IF (trim(cve.field_value,3)="1")
     bskipcombinepurgeopt = true
    ENDIF
   WITH nocounter
  ;end select
  SET dcensustypecd = uar_get_code_by("MEANING",339,"CENSUS")
  SET dcancelledcd = uar_get_code_by("MEANING",261,"CANCELLED")
  IF (dcensustypecd=0.0)
   SET reply->status_data.status = "F"
   SET reply->err_msg = uar_i18ngetmessage(l18nhandle,"CENSUS",
    "Could not find CDF meaning 'CENSUS' in code set 339.")
   SET reply->err_code = - (1)
   GO TO exit_script
  ELSEIF (dcancelledcd=0.0)
   SET reply->status_data.status = "F"
   SET reply->err_msg = uar_i18ngetmessage(l18nhandle,"CANCELLED",
    "Could not find CDF meaning 'CANCELLED' in code set 261.")
   SET reply->err_code = - (1)
   GO TO exit_script
  ELSE
   IF (bskipcombinepurgeopt=true)
    CALL echo("+")
    CALL echo("***********************")
    CALL echo("***Exclude Combines****")
    CALL echo("***********************")
    CALL echo("+")
    SELECT DISTINCT INTO "nl:"
     ed.rowid
     FROM encntr_domain ed
     WHERE (ed.active_status_cd != reqdata->combined_cd)
      AND ed.encntr_domain_type_cd=dcensustypecd
      AND ed.encntr_domain_id > 0.0
      AND ((ed.end_effective_dt_tm <= cnvtdatetime((curdate - ldaystokeep),curtime3)) OR (ed
     .active_ind=0))
     DETAIL
      lrowcnt += 1
      IF (lrowcnt > size(reply->rows,5))
       stat = alterlist(reply->rows,(lrowcnt+ 1000))
      ENDIF
      reply->rows[lrowcnt].row_id = ed.rowid
     WITH nocounter, maxqual(ed,value(lrowsleft))
    ;end select
   ELSE
    CALL echo("+")
    CALL echo("***********************")
    CALL echo("***Include Combines****")
    CALL echo("***********************")
    CALL echo("+")
    SELECT DISTINCT INTO "nl:"
     ed.rowid
     FROM encntr_domain ed
     WHERE ed.encntr_domain_type_cd=dcensustypecd
      AND ed.encntr_domain_id > 0.0
      AND ((ed.end_effective_dt_tm <= cnvtdatetime((curdate - ldaystokeep),curtime3)) OR (ed
     .active_ind=0))
     DETAIL
      lrowcnt += 1
      IF (lrowcnt > size(reply->rows,5))
       stat = alterlist(reply->rows,(lrowcnt+ 1000))
      ENDIF
      reply->rows[lrowcnt].row_id = ed.rowid
     WITH nocounter, maxqual(ed,value(lrowsleft))
    ;end select
   ENDIF
   SET lerrcode = error(serrmsg,1)
   IF (lerrcode > 0)
    SET reply->err_code = lerrcode
    SET reply->err_msg = uar_i18nbuildmessage(l18nhandle,"ENCNTR_DOMAIN",
     "Failed in row selection: %1","s",nullterm(serrmsg))
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(reply->rows,lrowcnt)
   SET reply->status_data.status = "S"
   SET reply->err_code = 0
  ENDIF
 ENDIF
#exit_script
END GO
