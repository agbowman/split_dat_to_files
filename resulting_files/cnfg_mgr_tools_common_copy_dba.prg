CREATE PROGRAM cnfg_mgr_tools_common_copy:dba
 DECLARE PUBLIC::validateserviceurl(url_str=vc) = i4 WITH protect, copy
 DECLARE PUBLIC::get_locale_data_sub(locale=vc) = vc WITH protect, copy
 IF (checkfun("CNFG_MGR_TOOLS_COMMON_MAIN")=7)
  CALL cnfg_mgr_tools_common_main(null)
 ENDIF
 SUBROUTINE (PUBLIC::getstaticcontentroot(applicationname=vc,relative_path=vc) =vc WITH protect, copy
  )
   DECLARE winintel_str = vc WITH protect, constant("winintel")
   DECLARE warehousepath = vc WITH protect, noconstant("")
   DECLARE contentservicepath = vc WITH protect, noconstant("")
   DECLARE root_path_str = vc WITH protect, noconstant("")
   DECLARE contentserviceurl = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="INS"
     AND di.info_name IN ("FE_WH", "CONTENT_SERVICE_URL")
    DETAIL
     IF (di.info_name="FE_WH")
      warehousepath = trim(di.info_char,3)
     ELSEIF (di.info_name="CONTENT_SERVICE_URL")
      contentservicepath = trim(di.info_char,3)
     ENDIF
    WITH nocounter
   ;end select
   CALL errorstackcheck("Retrieve dm_info name and char")
   IF (contentservicepath != "")
    SET root_path_str = concat(contentservicepath,"/")
    SET root_path_str = replace(root_path_str,"\","/",0)
    SET root_path_str = replace(root_path_str," ","%20",0)
    SET contentserviceurl = concat(root_path_str,relative_path)
    SET contentserviceurl = replace(contentserviceurl,"\","/",0)
    SET contentserviceurl = replace(contentserviceurl," ","%20",0)
    IF (validateserviceurl(contentserviceurl))
     RETURN(root_path_str)
    ELSE
     SET root_path_str = ""
    ENDIF
   ENDIF
   IF (warehousepath != "")
    IF (findstring(winintel_str,cnvtlower(warehousepath))=0)
     IF (substring(size(warehousepath),size(warehousepath),warehousepath) IN ("\", "/"))
      SET root_path_str = concat("file:///",warehousepath,winintel_str,"/static_content/")
     ELSE
      SET root_path_str = concat("file:///",warehousepath,"/",winintel_str,"/static_content/")
     ENDIF
    ELSE
     SET root_path_str = concat("file:///",warehousepath,"/static_content/")
    ENDIF
    SET root_path_str = replace(root_path_str,"\","/",0)
    SET root_path_str = replace(root_path_str," ","%20",0)
    RETURN(root_path_str)
   ENDIF
   IF (trim(root_path_str)="")
    DECLARE i18nkey = vc WITH protect, noconstant(concat(trim(applicationname,3),"_CONTENT_NOT_FOUND"
      ))
    SET i18nkey = cnvtupper(replace(i18nkey," ","_",0))
    SET _memory_reply_string = get_i18n_message(i18nkey,nullterm(concat("The path to the ",
       applicationname," content could not be determined.")))
    GO TO exit_script
   ENDIF
   RETURN(root_path_str)
 END ;Subroutine
 SUBROUTINE validateserviceurl(url_str)
   DECLARE cpm_http_transaction = i4 WITH protect, constant(2000)
   DECLARE srv_message = i4 WITH protect, noconstant(0)
   DECLARE srv_request = i4 WITH protect, noconstant(0)
   DECLARE srv_reply = i4 WITH protect, noconstant(0)
   DECLARE srv_status = i4 WITH protect, noconstant(0)
   DECLARE srv_execute = i4 WITH protect, noconstant(0)
   SET srv_message = uar_srvselectmessage(cpm_http_transaction)
   SET srv_request = uar_srvcreaterequest(srv_message)
   SET srv_reply = uar_srvcreatereply(srv_message)
   SET srv_status = uar_srvsetstringfixed(srv_request,"uri",nullterm(url_str),size(url_str,1))
   SET srv_status = uar_srvsetstring(srv_request,"Method",nullterm("HEAD"))
   SET srv_execute = uar_srvexecute(srv_message,srv_request,srv_reply)
   SET srv_status = uar_srvgetlong(srv_reply,"http_status_code")
   IF (srv_status=200)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE (PUBLIC::errorstackcheck(operation=vc) =null WITH protect, copy)
   DECLARE errormsg = c255 WITH protect, noconstant("")
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    WHILE (errorcode != 0)
     SET _memory_reply_string = build2("Operation:",operation," Error Number:",errorcode,
      " Error Message:",
      errormsg)
     SET errorcode = error(errormsg,0)
    ENDWHILE
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (PUBLIC::get_i18n_message(i18nkey=vc,fallbacktext=vc) =vc WITH protect, copy)
   DECLARE i18nhandle = i4 WITH protect
   DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH protect
   DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH protect
   DECLARE i18ninitsuccess = i4 WITH protect, noconstant(uar_i18nlocalizationinit(i18nhandle,
     "CNFG_MGR_TOOLS_COMMON","",curcclrev))
   DECLARE i18n_message = vc WITH protect, noconstant(uar_i18ngetmessage(i18nhandle,i18nkey,
     fallbacktext))
   RETURN(i18n_message)
 END ;Subroutine
 SUBROUTINE get_locale_data_sub(locale)
   DECLARE language_localization_str = vc WITH protect, noconstant("")
   DECLARE language_str = vc WITH protect, noconstant("")
   DECLARE localization_str = vc WITH protect, noconstant("")
   IF (textlen(trim(locale,3)) > 0)
    SET language_localization_str = locale
   ELSE
    SET language_localization_str = logical("CCL_LANG")
    IF (language_localization_str="")
     SET language_localization_str = logical("LANG")
    ENDIF
   ENDIF
   SET language_str = cnvtlower(substring(1,2,language_localization_str))
   SET localization_str = cnvtlower(substring(4,2,language_localization_str))
   CASE (language_str)
    OF "en":
     IF (localization_str="au")
      RETURN("i18n.en_AU.js")
     ELSEIF (localization_str="gb")
      RETURN("i18n.en_GB.js")
     ELSE
      RETURN("i18n.en_US.js")
     ENDIF
    OF "es":
     RETURN("i18n.es.js")
    OF "de":
     RETURN("i18n.de.js")
    OF "fr":
     RETURN("i18n.fr.js")
    OF "pt":
     RETURN("i18n.pt_BR.js")
    ELSE
     RETURN("i18n.en_US.js")
   ENDCASE
 END ;Subroutine
 SUBROUTINE (PUBLIC::geti18nfilepath(dminfoidentifier=vc) =vc WITH protect, copy)
   DECLARE i18nfilepath = vc WITH noconstant(trim("")), protect
   IF (textlen(trim(dminfoidentifier,3)) > 0)
    SELECT INTO "NL:"
     d.info_char
     FROM dm_info d
     WHERE d.info_domain="INS"
      AND d.info_name=dminfoidentifier
     DETAIL
      i18nfilepath = d.info_char
     WITH nocounter
    ;end select
   ENDIF
   CALL errorstackcheck("Retrieve dm_info i18n name and char")
   IF (substring(1,1,i18nfilepath)="/")
    SET i18nfilepath = substring(2,(textlen(i18nfilepath) - 1),i18nfilepath)
   ENDIF
   RETURN(i18nfilepath)
 END ;Subroutine
END GO
