CREATE PROGRAM bbd_import_donor_crossref:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 SET modify = predeclare
 DECLARE logtofile(smsg=vc,ncol=i2,nappend=i2) = null
 DECLARE script_name = c25 WITH protect, constant("BBD_IMPORT_DONOR_CROSSREF")
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE sline = c65 WITH protect, constant(fillstring(65,"*"))
 DECLARE csv_cnt = i4 WITH protect, constant(size(requestin->list_0,5))
 DECLARE nhead_col = i2 WITH protect, constant(1)
 DECLARE nbody_col = i2 WITH protect, constant(5)
 DECLARE nno_append_ind = i2 WITH protect, constant(0)
 DECLARE nappend_ind = i2 WITH protect, constant(1)
 DECLARE sindent = c5 WITH protect, constant(fillstring(5," "))
 DECLARE sspace = c1 WITH protect, constant(fillstring(1," "))
 DECLARE senter = vc WITH protect, constant(char(13))
 DECLARE hold_product_id = f8 WITH protect, noconstant(0.0)
 DECLARE hold_code_value = f8 WITH protect, noconstant(0.0)
 DECLARE display_key = vc WITH protect, noconstant(" ")
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE logfilename = vc WITH protect, constant(build("cer_log:",cnvtlower(script_name),".log"))
 DECLARE sdate = vc WITH protect, noconstant(" ")
 SET reply->status_data.status = "F"
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 contributor_system = vc
   1 unit_cross_reference = vc
   1 donor_cross_reference = vc
   1 product_id = vc
   1 script_start = vc
   1 script_end = vc
   1 success_execution = vc
   1 failure_execution = vc
   1 updated = vc
   1 not_updated = vc
   1 script_success = vc
   1 script_failure = vc
   1 echo_display = vc
 )
 SET captions->contributor_system = uar_i18ngetmessage(i18nhandle,"contributor_system",
  "Contributor System    =")
 SET captions->unit_cross_reference = uar_i18ngetmessage(i18nhandle,"unit_cross_reference",
  "Unit Cross Reference  =")
 SET captions->donor_cross_reference = uar_i18ngetmessage(i18nhandle,"donor_cross_reference",
  "Donor Cross Reference =")
 SET captions->product_id = uar_i18ngetmessage(i18nhandle,"product_id","product_id            =")
 SET captions->script_start = uar_i18ngetmessage(i18nhandle,"script_start","SCRIPT START (")
 SET captions->script_end = uar_i18ngetmessage(i18nhandle,"script_end","...SCRIPT END (")
 SET captions->success_execution = uar_i18ngetmessage(i18nhandle,"success_execution","SUCCESS: Unit "
  )
 SET captions->failure_execution = uar_i18ngetmessage(i18nhandle,"failure_execution","FAILURE: Unit "
  )
 SET captions->updated = uar_i18ngetmessage(i18nhandle,"updated"," updated.")
 SET captions->not_updated = uar_i18ngetmessage(i18nhandle,"not_updated"," not updated.")
 SET captions->script_success = uar_i18ngetmessage(i18nhandle,"script_success",
  "Execution successful... ")
 SET captions->script_failure = uar_i18ngetmessage(i18nhandle,"script_failure",
  "Execution failure... ")
 SET captions->echo_display = uar_i18ngetmessage(i18nhandle,"echo_display",
  "See log file for details...")
 SET sdate = build("[",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME;;d"),"]")
 CALL logtofile(concat(captions->script_start,script_name,") - ",sdate,"..."),nhead_col,
  nno_append_ind)
 FOR (idx = 1 TO csv_cnt)
   CALL logtofile(sline,nhead_col,nappend_ind)
   CALL logtofile(concat(captions->contributor_system,sspace,trim(requestin->list_0[idx].
      contributor_system_display),senter,sindent,
     captions->unit_cross_reference,sspace,trim(requestin->list_0[idx].unit_cross_reference),senter,
     sindent,
     captions->donor_cross_reference,sspace,requestin->list_0[idx].donor_cross_reference),nbody_col,
    nappend_ind)
   SET hold_product_id = 0.0
   SET display_key = cnvtupper(cnvtalphanum(requestin->list_0[idx].contributor_system_display))
   SET hold_code_value = uar_get_code_by("DISPLAYKEY",89,display_key)
   IF (hold_code_value < 0.0)
    SET reply->status_data.status = "F"
    CALL subevent_add("Invalid ContributorSystem","F","BBD_IMPORT_DONOR_CROSSREF.PRG",errmsg)
    CALL logtofile(concat(captions->failure_execution,sspace,requestin->list_0[idx].
      unit_cross_reference,sspace,captions->not_updated),nbody_col,nappend_ind)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    bp.product_id
    FROM bbhist_product bp
    WHERE (bp.cross_reference=requestin->list_0[idx].unit_cross_reference)
     AND bp.contributor_system_cd=hold_code_value
    DETAIL
     hold_product_id = bp.product_id
    WITH nocounter, forupdate(bp)
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    SET reply->status_data.status = "F"
    CALL subevent_add("Select BBHIST_PRODUCT","F","BBD_IMPORT_DONOR_CROSSREF.PRG",errmsg)
    CALL logtofile(concat(captions->failure_execution,sspace,requestin->list_0[idx].
      unit_cross_reference,sspace,captions->not_updated),nbody_col,nappend_ind)
    GO TO exit_script
   ENDIF
   IF (curqual=1)
    CALL logtofile(concat(captions->product_id,sspace,cnvtstring(hold_product_id)),nbody_col,
     nappend_ind)
    UPDATE  FROM bbhist_product bp
     SET bp.donor_xref_txt = requestin->list_0[idx].donor_cross_reference
     WHERE bp.product_id=hold_product_id
     WITH nocounter
    ;end update
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     SET reply->status_data.status = "F"
     CALL subevent_add("Update BBHIST_PRODUCT","F","BBD_IMPORT_DONOR_CROSSREF.PRG",errmsg)
     CALL logtofile(concat(captions->failure_execution,sspace,requestin->list_0[idx].
       unit_cross_reference,sspace,captions->not_updated),nbody_col,nappend_ind)
     GO TO exit_script
    ENDIF
    IF (curqual=1)
     CALL logtofile(concat(captions->success_execution,sspace,requestin->list_0[idx].
       unit_cross_reference,captions->updated),nbody_col,nappend_ind)
     COMMIT
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    CALL subevent_add("Unit number not found.","F","BBD_IMPORT_DONOR_CROSSREF.PRG",errmsg)
    CALL logtofile(concat(captions->failure_execution,sspace,requestin->list_0[idx].
      unit_cross_reference,sspace,captions->not_updated),nbody_col,nappend_ind)
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE logtofile(smsg,ncol,nappend)
   IF (nappend=1)
    SELECT INTO value(logfilename)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      col ncol, smsg
     WITH nocounter, append, noheading
    ;end select
   ELSE
    SELECT INTO value(logfilename)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      col ncol, smsg
     WITH nocounter, noheading
    ;end select
   ENDIF
 END ;Subroutine
#set_status
 SET reply->status_data.status = "S"
#exit_script
 CALL logtofile(sline,nhead_col,nappend_ind)
 CALL echorecord(reply,logfilename,1)
 SET sdate = build("[",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME;;d"),"]")
 CALL logtofile(sline,nhead_col,nappend_ind)
 CALL logtofile(concat(captions->script_end,script_name,") - ",reply->status_data.status," - ",
   sdate),nhead_col,nappend_ind)
 IF ((reply->status_data.status="S"))
  CALL echo(captions->script_success)
 ELSE
  CALL echo(captions->script_failure)
 ENDIF
 CALL echo(captions->echo_display)
 CALL echo(logfilename)
END GO
