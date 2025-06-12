CREATE PROGRAM ct_get_prescreen_job_details:dba
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 jobdetails = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE builddetails(info=vc,newlineind=i2) = i2
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE startdt = vc WITH protect, noconstant("")
 DECLARE enddt = vc WITH protect, noconstant("")
 DECLARE encountertypes = vc WITH protect, noconstant("")
 DECLARE facilities = vc WITH protect, noconstant("")
 DECLARE protocols = vc WITH protect, noconstant("")
 DECLARE protcnt = i4 WITH protect, noconstant(0)
 DECLARE agequal = vc WITH protect, noconstant("")
 DECLARE genderqual = vc WITH protect, noconstant("")
 DECLARE indx = i4 WITH protect, noconstant(0)
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
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET protcnt = size(request->protlist,5)
 IF (protcnt > 0)
  FOR (indx = 1 TO protcnt)
    IF (indx=1)
     SET protocols = uar_i18nbuildmessage(i18nhandle,"PROTOCOLS","Protocols: %1","s",nullterm(
       request->protlist[indx].primary_mnemonic))
    ELSE
     SET protocols = concat(protocols,", ",nullterm(request->protlist[indx].primary_mnemonic))
    ENDIF
  ENDFOR
  CALL builddetails(protocols,0)
  SET startdt = uar_i18nbuildmessage(i18nhandle,"START_DT","Evaluation Start Date: %1","s",format(
    request->startdttm,"@LONGDATETIME;;Q"))
  CALL builddetails(startdt,1)
  SET enddt = uar_i18nbuildmessage(i18nhandle,"END_DT","Evaluation End Date: %1","s",format(request
    ->enddttm,"@LONGDATETIME;;Q"))
  CALL builddetails(enddt,1)
  IF ((request->eanyflag=1))
   SET encountertypes = uar_i18ngetmessage(i18nhandle,"ENCNTR_TYPE_ANY","Encounter Type: Any")
  ELSE
   FOR (indx = 1 TO size(request->enctrlist,5))
     IF (indx=1)
      SET encountertypes = uar_i18nbuildmessage(i18nhandle,"ENCNTR_TYPE","Encounter Type: %1","s",
       uar_get_code_display(request->enctrlist[indx].etypecd))
     ELSE
      SET encountertypes = concat(encountertypes,", ",uar_get_code_display(request->enctrlist[indx].
        etypecd))
     ENDIF
   ENDFOR
  ENDIF
  CALL builddetails(encountertypes,1)
  IF ((request->fanyflag=1))
   SET facilities = uar_i18ngetmessage(i18nhandle,"FACILITY_ANY","Facility: Any")
  ELSE
   FOR (indx = 1 TO size(request->facilitylist,5))
     IF (indx=1)
      SET facilities = uar_i18nbuildmessage(i18nhandle,"FACILITY","Facility: %1","s",
       uar_get_code_display(request->facilitylist[indx].faccd))
     ELSE
      SET facilities = concat(facilities,", ",uar_get_code_display(request->facilitylist[indx].faccd)
       )
     ENDIF
   ENDFOR
  ENDIF
  CALL builddetails(facilities,1)
  IF ((request->agequalifiercd > 0.0))
   IF ((request->age2 > 0))
    SET agequal = uar_i18nbuildmessage(i18nhandle,"AGE_QUAL2","Age: %1 %2 and %3","sii",nullterm(
      uar_get_code_display(request->agequalifiercd)),
     request->age1,request->age2)
   ELSE
    SET agequal = uar_i18nbuildmessage(i18nhandle,"AGE_QUAL1","Age: %1 %2","si",nullterm(
      uar_get_code_display(request->agequalifiercd)),
     request->age1)
   ENDIF
   CALL builddetails(agequal,1)
  ENDIF
  IF ((request->gendercd > 0.0))
   SET genderqual = uar_i18nbuildmessage(i18nhandle,"GENDER","Gender: %1","s",uar_get_code_display(
     request->gendercd))
   CALL builddetails(genderqual,1)
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE builddetails(info,newlineind)
  IF (newlineind > 0)
   SET reply->jobdetails = concat(reply->jobdetails,"\r\n",info)
  ELSE
   SET reply->jobdetails = concat(info,"\r\n")
  ENDIF
  RETURN(1)
 END ;Subroutine
#exit_script
 SET last_mod = "001"
 SET mod_date = "May 04, 2010"
END GO
