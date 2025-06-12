CREATE PROGRAM dms_utils:dba
 PAINT
 DECLARE sscriptstatus = c1 WITH protected, noconstant("F")
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE sdmssync = c1 WITH protected, noconstant(" ")
 DECLARE sdistflag = c1 WITH protected, noconstant(" ")
 DECLARE printer_cv = f8 WITH noconstant(0.0)
 DECLARE i18nsheader = vc WITH protected, noconstant("")
 DECLARE i18nsfailms = vc WITH protected, noconstant("")
 DECLARE i18nspromptmsg = vc WITH private, noconstant(" ")
 DECLARE i18nspromptmsg1 = vc WITH private, noconstant(" ")
 DECLARE i18nsupdsuccessmsg = vc WITH private, noconstant(" ")
 DECLARE i18nsupdfailedmsg = vc WITH private, noconstant(" ")
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
 IF ( NOT (validate(ppr_i18nstatus,0)))
  DECLARE ppr_i18nhandle = i4 WITH protect, noconstant(0)
  DECLARE ppr_i18nstatus = i4 WITH protect, noconstant(0)
  SET ppr_i18nstatus = uar_i18nlocalizationinit(ppr_i18nhandle,curprog,"",curcclrev)
 ENDIF
 SUBROUTINE (ppr_i18ngetmessage(param1=vc(value),param2=vc(value)) =vc WITH protect)
   DECLARE eventstring = vc WITH private, noconstant(" ")
   DECLARE stringtoi18n = vc WITH private, noconstant(" ")
   DECLARE returnval = vc WITH protect, noconstant(" ")
   SET eventstring = param1
   SET stringtoi18n = param2
   SET returnval = uar_i18ngetmessage(ppr_i18nhandle,eventstring,stringtoi18n)
   RETURN(returnval)
 END ;Subroutine
 SET i18nsheader = uar_i18ngetmessage(ppr_i18nhandle,"UTIL_HEADER","DMS Utility")
 SET i18nspromptmsg = uar_i18ngetmessage(ppr_i18nhandle,"SET_DMS_SYNC",
  "Synchronize Deviceviewer and DMS(Yes/No):")
 SET i18nspromptmsg1 = uar_i18ngetmessage(ppr_i18nhandle,"SET_DIST_FLAG",
  "External Distribution(Enable all/Disable all/Skip):")
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=3000
   AND c.cdf_meaning="PRINTER"
   AND c.active_ind=1
  DETAIL
   printer_cv = c.code_value
  WITH nocounter
 ;end select
 IF (printer_cv < 1)
  SET i18nsfailmsg = uar_i18ngetmessage(ppr_i18nhandle,"INVALID_PRINTER_TYPE_CD",
   "Invalid Printer Type Code Value")
  GO TO exit_script
 ENDIF
 CALL video(n)
 CALL clear(1,1)
 CALL box(2,1,4,80)
 CALL text(3,3,i18nsheader)
 CALL text(6,3,i18nspromptmsg)
 CALL accept(6,45,"P;UC","")
 SET sdmssync = curaccept
 CALL text(7,3,i18nspromptmsg1)
 CALL accept(7,55,"P;UC","")
 SET sdistflag = curaccept
 IF (sdmssync="Y")
  CALL devicedmssysnc(1)
 ENDIF
 IF (sdistflag="E")
  CALL enabledist(1)
 ELSEIF (sdistflag="D")
  CALL disabledist(1)
 ENDIF
 SUBROUTINE (enabledist(ndummy=i2(value)) =i2 WITH protect)
   UPDATE  FROM device d
    SET d.distribution_flag = 1
    WHERE d.dms_service_id > 0
     AND d.device_type_cd=printer_cv
   ;end update
 END ;Subroutine
 SUBROUTINE (disabledist(ndummy=i2(value)) =i2 WITH protect)
   UPDATE  FROM device d
    SET d.distribution_flag = 0
    WHERE d.dms_service_id > 0
     AND d.device_type_cd=printer_cv
   ;end update
 END ;Subroutine
 SUBROUTINE (devicedmssysnc(ndummy=i2(value)) =i2 WITH protect)
   RECORD rec1(
     1 qual[*]
       2 service_name = vc
       2 service_type = vc
       2 dest_server_name = c32
       2 device_cd = f8
       2 dms_service_id = f8
       2 phy_device_name = vc
   )
   DECLARE dms_service_id = f8 WITH noconstant(0.0)
   DECLARE dms_service_name = vc WITH noconstant(" ")
   DECLARE count1 = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    d.device_cd
    FROM device d
    WHERE d.device_type_cd=printer_cv
     AND d.dms_service_id=0
    ORDER BY d.device_type_cd
    HEAD REPORT
     stat = alterlist(rec1->qual,10), count1 = 0
    DETAIL
     count1 += 1
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(rec1->qual,(count1+ 9))
     ENDIF
     rec1->qual[count1].service_name = build(d.name,"@DMS@PRINTER"), rec1->qual[count1].device_cd = d
     .device_cd
    FOOT REPORT
     stat = alterlist(rec1->qual,count1)
   ;end select
   SET temp = 0
   FOR (i = 1 TO count1)
     SELECT INTO "nl:"
      nextseqnum = seq(dms_seq,nextval)"####################;rp0"
      FROM dual
      DETAIL
       dms_service_id = nextseqnum
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      SET i18nsfailmsg = uar_i18ngetmessage(ppr_i18nhandle,"INVALID_SEQ","Invalid DMS Service ID")
      GO TO exit_script
     ENDIF
     INSERT  FROM dms_service ds
      SET ds.dms_service_id = dms_service_id, ds.host_name = " ", ds.service_name = rec1->qual[i].
       service_name,
       ds.service_type = "WIN_PRINT_SERVICE", ds.updt_dt_tm = cnvtdatetime(sysdate), ds.updt_id =
       reqinfo->updt_id,
       ds.updt_task = reqinfo->updt_task, ds.updt_cnt = 0, ds.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET i18nsfailmsg = uar_i18ngetmessage(ppr_i18nhandle,"INSERT_ERROR",
       "Insert error in dms_service table")
      GO TO exit_script
     ENDIF
     SELECT INTO "nl:"
      d.*
      FROM device d
      WHERE (d.device_cd=rec1->qual[i].device_cd)
      WITH nocounter, forupdate(d)
     ;end select
     IF (curqual=0)
      SET i18nsfailmsg = uar_i18ngetmessage(ppr_i18nhandle,"UPDT_LOCK_ERROR",
       "Update lock row error in device table")
      GO TO exit_script
     ENDIF
     UPDATE  FROM device d
      SET d.dms_service_id = dms_service_id, d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id =
       reqinfo->updt_id,
       d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1), d.updt_applctx = reqinfo->
       updt_applctx
      WHERE (d.device_cd=rec1->qual[i].device_cd)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET i18nsfailmsg = uar_i18ngetmessage(ppr_i18nhandle,"UPDT_ERROR",
       "Update error in device table")
      GO TO exit_script
     ENDIF
   ENDFOR
 END ;Subroutine
 COMMIT
 SET sscriptstatus = "S"
#exit_script
 IF (sscriptstatus="F")
  SET sfailmsg = concat("Failure: ",sfailmsg)
  CALL text(14,2,sfailmsg)
 ENDIF
END GO
