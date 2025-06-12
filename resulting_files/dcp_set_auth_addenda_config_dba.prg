CREATE PROGRAM dcp_set_auth_addenda_config:dba
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
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET istat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE sprompt = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PREF_NAME",
   "Enable the configuration setting for Authenticate Addenda Without Sign Document Privilege (Y/N):"
   ))
 CALL clear(1,1)
 CALL text(1,1,sprompt)
 CALL accept(2,20,"A;CU","N")
 DECLARE pref_domain = vc WITH constant("TRANSCRIPTION")
 DECLARE pref_name = vc WITH constant("Authenticate Addenda Without Sign Document Privilege")
 DECLARE pref_value_on = vc WITH constant("TRUE")
 DECLARE pref_value_off = vc WITH constant("FALSE")
 IF (curaccept != "N")
  UPDATE  FROM dm_info di
   SET di.info_date = cnvtdatetime(curdate,curtime3), di.info_char = pref_value_on, di.updt_cnt = (di
    .updt_cnt+ 1),
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx, di
    .updt_id = reqinfo->updt_id,
    di.updt_task = reqinfo->updt_task
   WHERE di.info_domain=pref_domain
    AND di.info_name=pref_name
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM dm_info di
    SET di.info_date = cnvtdatetime(curdate,curtime3), di.info_domain = pref_domain, di.info_name =
     pref_name,
     di.info_char = pref_value_on, di.updt_cnt = 1, di.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     di.updt_applctx = reqinfo->updt_applctx, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
     updt_task
    WITH nocounter
   ;end insert
  ENDIF
  IF (curqual=0)
   CALL echo(uar_i18ngetmessage(i18nhandle,"ERROR_INSERT_UPDATE",
     "Error Inserting/Updating configuration settings for Addenda"))
  ENDIF
 ELSE
  UPDATE  FROM dm_info di
   SET di.info_date = cnvtdatetime(curdate,curtime3), di.info_char = pref_value_off, di.updt_cnt = (
    di.updt_cnt+ 1),
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx, di
    .updt_id = reqinfo->updt_id,
    di.updt_task = reqinfo->updt_task
   WHERE di.info_domain=pref_domain
    AND di.info_name=pref_name
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM dm_info di
    SET di.info_date = cnvtdatetime(curdate,curtime3), di.info_domain = pref_domain, di.info_name =
     pref_name,
     di.info_char = pref_value_off, di.updt_cnt = 1, di.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     di.updt_applctx = reqinfo->updt_applctx, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
     updt_task
    WITH nocounter
   ;end insert
  ENDIF
  IF (curqual=0)
   CALL echo(uar_i18ngetmessage(i18nhandle,"ERROR_INSERT_UPDATE",
     "Error Inserting/Updating configuration settings for Addenda"))
  ENDIF
 ENDIF
 IF (curqual != 0)
  COMMIT
  CALL echo(uar_i18ngetmessage(i18nhandle,"INSERT_UPDATE",
    "Configuration setting for authenticating addenda without sign privilege has been successfully updated."
    ))
 ENDIF
END GO
