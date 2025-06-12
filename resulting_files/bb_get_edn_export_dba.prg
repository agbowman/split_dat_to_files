CREATE PROGRAM bb_get_edn_export:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
     2 node = vc
     2 data_blob = gvc
     2 data_blob_size = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationstatus))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectvalue))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt += 1
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
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
 FREE RECORD ekssourcerequest
 RECORD ekssourcerequest(
   1 module_dir = vc
   1 module_name = vc
   1 basblob = i2
 )
 FREE RECORD eksreply
 RECORD eksreply(
   1 info_line[*]
     2 new_line = vc
   1 data_blob = gvc
   1 data_blob_size = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (readexportfile(fullfilepath=vc) =null)
   SET stat = initrec(ekssourcerequest)
   SET stat = initrec(eksreply)
   DECLARE filename = vc WITH protect, noconstant
   DECLARE file_dir = vc WITH protect, noconstant
   DECLARE separator_pos = i2 WITH protect, noconstant(0)
   SET separator_pos = 0
   SET separator_pos = cnvtint(value(findstring(":",fullfilepath,1,1)))
   IF (separator_pos <= 0)
    SET separator_pos = cnvtint(value(findstring("/",fullfilepath,1,1)))
   ENDIF
   SET file_dir = concat(substring(1,(separator_pos - 1),fullfilepath),":")
   SET filename = substring((separator_pos+ 1),(size(fullfilepath) - separator_pos),fullfilepath)
   SET ekssourcerequest->module_dir = file_dir
   SET ekssourcerequest->module_name = filename
   SET ekssourcerequest->basblob = 1
   EXECUTE eks_get_source  WITH replace("REQUEST",ekssourcerequest), replace("REPLY",eksreply)
   RETURN
 END ;Subroutine
 SET log_program_name = "BB_GET_EDN_EXPORT"
 CALL log_message("Starting BB_GET_EDN_EXPORT...",log_level_debug)
 RECORD captions(
   1 filename = vc
   1 exportdatetime = vc
   1 begindatetime = vc
   1 enddatetime = vc
   1 ownerarea = vc
   1 orderdatetime = vc
   1 ordernumber = vc
   1 productnumber = vc
   1 producttype = vc
   1 deliverytype = vc
 )
 CALL log_message("Translating captions...",log_level_debug)
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET captions->filename = uar_i18ngetmessage(i18nhandle,"filename",'"Filename"')
 SET captions->exportdatetime = uar_i18ngetmessage(i18nhandle,"export_date_time",
  '"Export Date and Time"')
 SET captions->begindatetime = uar_i18ngetmessage(i18nhandle,"begin_date_time",
  '"Begin Date and Time"')
 SET captions->enddatetime = uar_i18ngetmessage(i18nhandle,"end_date_time",'"End Date and Time"')
 SET captions->ownerarea = uar_i18ngetmessage(i18nhandle,"owner_area",'"Owner Area"')
 SET captions->orderdatetime = uar_i18ngetmessage(i18nhandle,"order_date_time",
  '"Order Date and Time"')
 SET captions->ordernumber = uar_i18ngetmessage(i18nhandle,"order_number",'"Order Number"')
 SET captions->productnumber = uar_i18ngetmessage(i18nhandle,"product_number",'"Product Number"')
 SET captions->producttype = uar_i18ngetmessage(i18nhandle,"product_type",'"Product Type"')
 SET captions->deliverytype = uar_i18ngetmessage(i18nhandle,"delivery_type",'"Delivery Type"')
 DECLARE sscript_name = vc WITH protect, constant("BB_GET_EDN_EXPORT")
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE beg_dt_tm = dq8 WITH protect, constant(cnvtdatetime(request->beg_dt_tm))
 DECLARE end_dt_tm = dq8 WITH protect, constant(cnvtdatetime(request->end_dt_tm))
 DECLARE cur_dt_tm = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE cur_owner_area_cd = f8 WITH protect, constant(request->cur_owner_area_cd)
 DECLARE owner_area_display = vc WITH protect, constant(trim(uar_get_code_display(request->
    cur_owner_area_cd)))
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE deliverytypedisplay = vc WITH protect, noconstant("")
 DECLARE ordernumber = vc WITH protect, noconstant("")
 DECLARE productnumber = vc WITH protect, noconstant("")
 DECLARE producttypedisplay = vc WITH protect, noconstant("")
 DECLARE stat = i2 WITH protect, noconstant(0)
 CALL log_message("Opening file ELEC_BLD_ORDER...",log_level_debug)
 EXECUTE cpm_create_file_name_logical "ELEC_BLD_ORDER", "csv", "x"
 CALL log_message("Writing file...",log_level_debug)
 SELECT INTO cpm_cfn_info->file_name_logical
  admin.admin_dt_tm, admin.order_nbr_ident
  FROM bb_edn_admin admin,
   bb_edn_product edn_prod,
   product prod,
   bb_edn_dscrpncy_ovrd edn_ovrd
  PLAN (admin
   WHERE admin.admin_dt_tm BETWEEN cnvtdatetime(beg_dt_tm) AND cnvtdatetime(end_dt_tm)
    AND admin.destination_loc_cd=cur_owner_area_cd)
   JOIN (edn_prod
   WHERE edn_prod.bb_edn_admin_id=admin.bb_edn_admin_id
    AND edn_prod.product_id > 0
    AND edn_prod.bb_edn_product_id > 0)
   JOIN (prod
   WHERE prod.product_id=edn_prod.product_id)
   JOIN (edn_ovrd
   WHERE (edn_ovrd.bb_edn_product_id= Outerjoin(edn_prod.bb_edn_product_id))
    AND (edn_ovrd.product_id> Outerjoin(0)) )
  ORDER BY admin.admin_dt_tm, admin.order_nbr_ident
  HEAD REPORT
   row 0, col 1, captions->filename,
   ", ", col col, captions->exportdatetime,
   ", ", col col, captions->begindatetime,
   ", ", col col, captions->enddatetime,
   ", ", col col, captions->ownerarea,
   ", ", col col, captions->orderdatetime,
   ", ", col col, captions->ordernumber,
   ", ", col col, captions->productnumber,
   ", ", col col, captions->producttype,
   ", ", col col, captions->deliverytype
  DETAIL
   row + 1, col 1, '"',
   "Elec_Bld_Order", '"', ", ",
   col col, '"', cur_dt_tm"mm/dd/yyyy hh:mm;;d",
   '"', ", ", col col,
   '"', beg_dt_tm"mm/dd/yyyy hh:mm;;d", '"',
   ", ", col col, '"',
   end_dt_tm"mm/dd/yyyy hh:mm;;d", '"', ", ",
   col col, '"', owner_area_display,
   '"', ", ", col col,
   '"', admin.admin_dt_tm"mm/dd/yyyy hh:mm;;d", '"',
   ", ", ordernumber = trim(admin.order_nbr_ident), col col,
   '"', ordernumber, '"',
   ", "
   IF (edn_ovrd.bb_edn_dscrpncy_ovrd_id > 0)
    productnumber = trim(edn_ovrd.edn_product_nbr_ident)
   ELSE
    productnumber = trim(edn_prod.edn_product_nbr_ident)
   ENDIF
   col col, '"', productnumber,
   '"', ", "
   IF (edn_ovrd.bb_edn_dscrpncy_ovrd_id > 0)
    producttypedisplay = trim(uar_get_code_display(edn_ovrd.product_cd))
   ELSE
    producttypedisplay = trim(uar_get_code_display(prod.product_cd))
   ENDIF
   col col, '"', producttypedisplay,
   '"', ", "
   IF (edn_prod.delivery_type_cd=0)
    deliverytypedisplay = " "
   ELSE
    deliverytypedisplay = trim(uar_get_code_display(edn_prod.delivery_type_cd))
   ENDIF
   col col, '"', deliverytypedisplay,
   '"'
  WITH maxrow = 5000, maxcol = 260, nullreport,
   nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select EDN Purge Rows",errmsg)
 ENDIF
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET lstat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = sscript_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
 SET stat = alterlist(reply->rpt_list,1)
 SET reply->rpt_list[1].rpt_filename = cpm_cfn_info->file_name_path
 SET reply->rpt_list[1].node = curnode
 CALL readexportfile(reply->rpt_list[1].rpt_filename)
 IF ((eksreply->status_data[1].status="S"))
  SET reply->rpt_list[1].data_blob = eksreply->data_blob
  SET reply->rpt_list[1].data_blob_size = eksreply->data_blob_size
 ELSE
  CALL errorhandler("F","BB_GET_EDN_EXPORT","Failure to read the EDN EXPORT file")
 ENDIF
 SET reply->status_data.status = "S"
 CALL log_message("Ending BB_GET_EDN_EXPORT...",log_level_debug)
#exit_script
END GO
