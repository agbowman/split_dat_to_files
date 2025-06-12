CREATE PROGRAM dc_mp_get_allqm:dba
 DECLARE iqrversioncontrol(category_topic_mean=vc,beg_time=dq8) = f8 WITH protect
 DECLARE emeasversioncontrol(category_mean=vc,beg_time=dq8) = i4 WITH protect
 DECLARE getcombinedviewtype(iqrversion=f8,emeasversion=i4,iqrvenuecatmean=vc,emeasvenuecatmean=vc,
  cvflexid=f8,
  cvdomainid=f8) = i2 WITH protect
 DECLARE getcombinedviewtypestring(iqrversion=vc,emeasversion=i4,iqrvenuecatmean=vc,emeasvenuecatmean
  =vc,cvflexid=f8,
  cvdomainid=f8) = i2 WITH protect
 DECLARE getflexid(positioncd=f8) = f8 WITH protect
 DECLARE getdomainid(prsnlid=f8) = f8 WITH protect
 DECLARE getpositioncd(prsnlid=f8) = f8 WITH protect
 DECLARE checkemeasureenabled(flexid=f8,logicaldomainid=f8,categorymean=vc,filtermean=vc(value,
   "QM_COMP_CONTROL"),freetextdesc=vc(value,"1")) = i2 WITH protect
 DECLARE lhprint(text=vc) = null WITH protect
 DECLARE lhelapsedtime(name=vc,beg_time=dq8) = null WITH protect
 DECLARE lhstartscript(name=vc) = null WITH protect
 DECLARE checkfilterexisted(category_topic_mean=vc,filter_mean=vc) = i2 WITH protect
 DECLARE checkvenuedefined(flexid=f8,logicaldomainid=f8,categorymean=vc) = i2 WITH protect
 DECLARE versioncheck(version=vc,minversion=vc) = i2 WITH protect
 DECLARE iqrversioncontrolstring(category_topic_mean=vc,beg_time=dq8) = vc WITH protect
 SUBROUTINE iqrversioncontrol(category_topic_mean,beg_time)
   CALL lhprint("*** Start IQRVersionControl subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE nhiqm_category_mean = vc WITH protect, noconstant("")
   DECLARE version_number = f8 WITH protect, noconstant(0.0)
   DECLARE start_loc = i4 WITH protect, noconstant(0)
   DECLARE len = i4 WITH protect, noconstant(0)
   SELECT DISTINCT INTO "nl:"
    FROM br_datamart_category cat
    WHERE cnvtupper(trim(cat.category_topic_mean,3))=cnvtupper(trim(category_topic_mean,3))
     AND cnvtdatetime(beg_time) BETWEEN cat.beg_effective_dt_tm AND cat.end_effective_dt_tm
    DETAIL
     nhiqm_category_mean = cnvtupper(trim(cat.category_mean,3)), start_loc = (findstring("_V",
      nhiqm_category_mean,1,1)+ 2), len = (size(nhiqm_category_mean,1) - start_loc)
     IF (start_loc > 2)
      version_number = cnvtreal(concat(substring(start_loc,len,nhiqm_category_mean),".",substring((
         start_loc+ len),1,nhiqm_category_mean)))
     ENDIF
    WITH nocounter
   ;end select
   CALL lhelapsedtime("IQRVersionControl",begin_dt_tm)
   RETURN(version_number)
 END ;Subroutine
 SUBROUTINE emeasversioncontrol(category_mean,beg_time)
   CALL lhprint("*** Start EMEASVersionControl subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE exe_string = vc WITH protect, constant(concat("cat.category_mean = '",category_mean,"*'"))
   DECLARE version_number = i4 WITH protect, noconstant(0)
   DECLARE len = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category cat
    WHERE cnvtdatetime(beg_time) >= cat.beg_effective_dt_tm
     AND parser(exe_string)
    ORDER BY cat.beg_effective_dt_tm DESC
    HEAD REPORT
     len = size(trim(cat.category_mean,3),1), version_number = cnvtint(substring((len - 3),len,trim(
        cat.category_mean,3)))
    WITH nocounter
   ;end select
   CALL lhelapsedtime("EMEASVersionControl",begin_dt_tm)
   RETURN(version_number)
 END ;Subroutine
 SUBROUTINE getcombinedviewtype(iqrversion,emeasversion,iqrvenuecatmean,emeasvenuecatmean,cvflexid,
  cvdomainid)
   DECLARE cvtype = i2 WITH noconstant(0), protect
   DECLARE emeashascontrol = i2 WITH constant(checkfilterexisted(emeasvenuecatmean,"QM_COMP_CONTROL")
    ), protect
   DECLARE emeasenabled = i2 WITH constant(checkemeasureenabled(cvflexid,cvdomainid,emeasvenuecatmean
     )), protect
   DECLARE iqrvenuedefined = i2 WITH constant(checkvenuedefined(cvflexid,cvdomainid,iqrvenuecatmean)),
   protect
   DECLARE emeasvenuedefined = i2 WITH constant(checkvenuedefined(cvflexid,cvdomainid,
     emeasvenuecatmean)), protect
   IF (emeasversion >= 2016)
    IF (iqrversion >= 4.4)
     IF (iqrvenuedefined=1
      AND emeasvenuedefined=1)
      SET cvtype = 3
     ELSEIF (iqrvenuedefined=0
      AND emeasvenuedefined=1)
      SET cvtype = 1
     ELSEIF (iqrvenuedefined=1
      AND emeasvenuedefined=0)
      SET cvtype = 2
     ENDIF
    ELSE
     IF (emeasvenuedefined=1)
      SET cvtype = 1
     ELSEIF (iqrvenuedefined=1
      AND emeasvenuedefined=0)
      SET cvtype = 2
     ENDIF
    ENDIF
   ELSE
    IF (((emeashascontrol=1
     AND emeasenabled=0) OR (emeashascontrol=0)) )
     SET cvtype = 2
    ELSEIF (emeasenabled=1)
     SET cvtype = 1
    ENDIF
   ENDIF
   RETURN(cvtype)
 END ;Subroutine
 SUBROUTINE getcombinedviewtypestring(iqrversionstring,emeasversion,iqrvenuecatmean,emeasvenuecatmean,
  cvflexid,cvdomainid)
   DECLARE cvtype = i2 WITH noconstant(0), protect
   DECLARE emeashascontrol = i2 WITH constant(checkfilterexisted(emeasvenuecatmean,"QM_COMP_CONTROL")
    ), protect
   DECLARE emeasenabled = i2 WITH constant(checkemeasureenabled(cvflexid,cvdomainid,emeasvenuecatmean
     )), protect
   DECLARE iqrvenuedefined = i2 WITH constant(checkvenuedefined(cvflexid,cvdomainid,iqrvenuecatmean)),
   protect
   DECLARE emeasvenuedefined = i2 WITH constant(checkvenuedefined(cvflexid,cvdomainid,
     emeasvenuecatmean)), protect
   SET min_version = cnvtstring(4.4,3,1)
   SET version_check = versioncheck(iqrversionstring,min_version)
   IF (emeasversion >= 2016)
    IF (version_check=1)
     IF (iqrvenuedefined=1
      AND emeasvenuedefined=1)
      SET cvtype = 3
     ELSEIF (iqrvenuedefined=0
      AND emeasvenuedefined=1)
      SET cvtype = 1
     ELSEIF (iqrvenuedefined=1
      AND emeasvenuedefined=0)
      SET cvtype = 2
     ENDIF
    ELSE
     IF (emeasvenuedefined=1)
      SET cvtype = 1
     ELSEIF (iqrvenuedefined=1
      AND emeasvenuedefined=0)
      SET cvtype = 2
     ENDIF
    ENDIF
   ELSE
    IF (((emeashascontrol=1
     AND emeasenabled=0) OR (emeashascontrol=0)) )
     SET cvtype = 2
    ELSEIF (emeasenabled=1)
     SET cvtype = 1
    ENDIF
   ENDIF
   RETURN(cvtype)
 END ;Subroutine
 SUBROUTINE getflexid(positioncd)
   CALL lhprint("*** Start getFlexId subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE flexid = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM br_datamart_flex b
    PLAN (b
     WHERE b.parent_entity_id=positioncd
      AND b.grouper_ind=0)
    DETAIL
     flexid = b.br_datamart_flex_id
    WITH nocounter
   ;end select
   CALL lhelapsedtime("getFlexId",begin_dt_tm)
   RETURN(flexid)
 END ;Subroutine
 SUBROUTINE getdomainid(prsnlid)
   CALL lhprint("*** Start getDomainId subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE logicaldomainid = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE p.person_id=prsnlid
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     logicaldomainid = p.logical_domain_id
    WITH nocounter
   ;end select
   CALL lhelapsedtime("getDomainId",begin_dt_tm)
   RETURN(logicaldomainid)
 END ;Subroutine
 SUBROUTINE getpositioncd(prsnlid)
   CALL lhprint("*** Start getPositionCD subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE positioncd = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE p.person_id=prsnlid
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     positioncd = p.position_cd
    WITH nocounter
   ;end select
   CALL lhelapsedtime("getPositionCD",begin_dt_tm)
   RETURN(positioncd)
 END ;Subroutine
 SUBROUTINE checkemeasureenabled(flexid,logicaldomainid,categorymean,filtermean,freetextdesc)
   CALL lhprint("*** Start checkEMeasureEnabled subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE measureenabled = i2 WITH noconstant(0)
   DECLARE i = i2 WITH noconstant(0)
   FOR (i = 1 TO 2)
    SELECT INTO "nl:"
     FROM br_datamart_category b,
      br_datamart_filter bf,
      br_datamart_value bv
     PLAN (b
      WHERE b.category_mean=categorymean)
      JOIN (bf
      WHERE bf.br_datamart_category_id=b.br_datamart_category_id)
      JOIN (bv
      WHERE bv.br_datamart_filter_id=bf.br_datamart_filter_id
       AND bv.br_datamart_flex_id=flexid
       AND bv.logical_domain_id=logicaldomainid)
     DETAIL
      IF (bv.freetext_desc=freetextdesc
       AND bf.filter_mean=filtermean)
       measureenabled = 1
      ENDIF
     WITH nocounter, orahintcbo("LEADING(B BF BV) USE_NL(BF BV) INDEX(BV XIE4BR_DATAMART_VALUE)")
    ;end select
    IF (curqual > 0)
     SET i = 3
    ELSE
     SET flexid = 0.0
    ENDIF
   ENDFOR
   CALL lhelapsedtime("checkEMeasureEnabled",begin_dt_tm)
   RETURN(measureenabled)
 END ;Subroutine
 SUBROUTINE lhprint(text)
   IF (validate(debug_lh_mp_audit_file_ind,0)=1)
    IF (validate(audit_filename))
     SELECT INTO value(audit_filename)
      FROM dummyt
      DETAIL
       IF (size(text,1) < 35000)
        CALL print(text)
       ENDIF
      WITH noheading, nocounter, format = lfstream,
       maxcol = 35000, maxrow = 1, append
     ;end select
    ELSE
     CALL echo(text)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE lhelapsedtime(name,beg_time)
   CALL lhprint(concat("*** Summary : ",name," ***"))
   CALL lhprint(concat(";Start time: ",format(beg_time,"MM/DD/YYYY HH:MM:SS;;D")))
   CALL lhprint(concat(";End time: ",format(cnvtdatetime(curdate,curtime3),"MM/DD/YYYY HH:MM:SS;;D"))
    )
   CALL lhprint(build(";Elapsed Time in seconds:",datetimediff(cnvtdatetime(curdate,curtime3),
      beg_time,5)))
   DECLARE errcode = i4 WITH noconstant(0), protect
   DECLARE errmsg = vc WITH noconstant(""), protect
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    CALL lhprint(concat("Error while running query for <",name,">"))
    CALL lhprint("The last error on the top of stack: ")
    CALL lhprint(errmsg)
   ENDIF
   SET errcode = error(errmsg,1)
   CALL lhprint(" ")
   CALL lhprint("================================================= ")
 END ;Subroutine
 SUBROUTINE lhstartscript(name)
   CALL lhprint("")
   CALL lhprint("***************************************** ")
   CALL lhprint(concat("; Start Script: ",name))
   CALL lhprint("***************************************** ")
   CALL lhprint("")
 END ;Subroutine
 SUBROUTINE checkfilterexisted(category_topic_mean,filter_mean)
   CALL lhprint("*** Start checkFilterExisted subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE filterexisted = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM br_datamart_category b,
     br_datamart_filter bf
    PLAN (b
     WHERE b.category_mean=category_topic_mean)
     JOIN (bf
     WHERE bf.br_datamart_category_id=b.br_datamart_category_id
      AND bf.filter_mean=filter_mean)
    DETAIL
     filterexisted = 1
    WITH nocounter
   ;end select
   CALL lhelapsedtime("checkFilterExisted",begin_dt_tm)
   RETURN(filterexisted)
 END ;Subroutine
 SUBROUTINE checkvenuedefined(flexid,logicaldomainid,categorymean)
   CALL lhprint("*** Start checkVenueDefined subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE venuedefined = i2 WITH noconstant(0), protect
   DECLARE positionind = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category b,
     br_datamart_filter bf,
     br_datamart_value bv
    PLAN (b
     WHERE b.category_mean=categorymean)
     JOIN (bf
     WHERE bf.br_datamart_category_id=b.br_datamart_category_id)
     JOIN (bv
     WHERE bv.br_datamart_filter_id=bf.br_datamart_filter_id
      AND bv.br_datamart_flex_id=flexid
      AND bv.logical_domain_id=logicaldomainid)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET flexid = 0.0
   ENDIF
   SELECT INTO "nl:"
    FROM br_datamart_category b,
     br_datamart_filter bf,
     br_datamart_value bv
    PLAN (b
     WHERE b.category_mean=categorymean)
     JOIN (bf
     WHERE bf.br_datamart_category_id=b.br_datamart_category_id
      AND ((bf.filter_mean="*_VENUE*") OR (bf.filter_mean IN ("MP_PC_BMF_MOM", "MP_PC_BMF_INF",
     "MP_PC_UCN_MOM", "MP_PC_UCN_INF"))) )
     JOIN (bv
     WHERE bv.br_datamart_filter_id=bf.br_datamart_filter_id
      AND bv.br_datamart_flex_id=flexid
      AND bv.logical_domain_id=logicaldomainid)
    DETAIL
     venuedefined = 1
    WITH nocounter, orahintcbo("LEADING(B BF BV) USE_NL(BF BV) INDEX(BV XIE4BR_DATAMART_VALUE)")
   ;end select
   CALL lhelapsedtime("checkVenueDefined",begin_dt_tm)
   RETURN(venuedefined)
 END ;Subroutine
 SUBROUTINE versioncheck(version,minversion)
   DECLARE versioncheckind = i2 WITH noconstant(0)
   IF (((cnvtint(version) > cnvtint(minversion)) OR (((cnvtint(version) >= cnvtint(minversion)
    AND size(version,1) > size(minversion)) OR (cnvtreal(version) >= cnvtreal(minversion)
    AND size(version,1) >= size(minversion))) )) )
    SET versioncheckind = 1
   ENDIF
   RETURN(versioncheckind)
 END ;Subroutine
 SUBROUTINE iqrversioncontrolstring(category_topic_mean,beg_time)
   CALL lhprint("*** Start IQRVersionControl subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE nhiqm_category_mean = vc WITH protect, noconstant("")
   DECLARE version_number = vc WITH protect, noconstant("")
   DECLARE start_loc = i4 WITH protect, noconstant(0)
   DECLARE len = i4 WITH protect, noconstant(0)
   SELECT DISTINCT INTO "nl:"
    FROM br_datamart_category cat
    WHERE cnvtupper(trim(cat.category_topic_mean,3))=cnvtupper(trim(category_topic_mean,3))
     AND cnvtdatetime(beg_time) BETWEEN cat.beg_effective_dt_tm AND cat.end_effective_dt_tm
    DETAIL
     nhiqm_category_mean = cnvtupper(trim(cat.category_mean,3)), start_loc = (findstring("_V",
      nhiqm_category_mean,1,1)+ 2), len = (size(nhiqm_category_mean,1) - start_loc)
     IF (start_loc > 2)
      version_number = concat(substring(start_loc,1,nhiqm_category_mean),".",substring((start_loc+ 1),
        len,nhiqm_category_mean))
     ENDIF
    WITH nocounter
   ;end select
   CALL lhelapsedtime("IQRVersionControlString",begin_dt_tm)
   RETURN(version_number)
 END ;Subroutine
 IF ( NOT (validate(ptreply)))
  RECORD ptreply(
    1 pt_cnt = i4
    1 page_cnt = i4
    1 tabname = vc
    1 prsnlid = f8
    1 positioncd = f8
    1 viewprefsid = f8
    1 amiind = i2
    1 amijson = vc
    1 hfind = i2
    1 hfjson = vc
    1 pnind = i2
    1 pnjson = vc
    1 cacind = i2
    1 cacjson = vc
    1 vteind = i2
    1 vtejson = vc
    1 stkind = i2
    1 stkjson = vc
    1 scipind = i2
    1 scipjson = vc
    1 pulcerind = i2
    1 pulcerjson = vc
    1 criind = i2
    1 crijson = vc
    1 fallsind = i2
    1 fallsjson = vc
    1 pfallind = i2
    1 pfalljson = vc
    1 painind = i2
    1 painjson = vc
    1 ppainind = i2
    1 ppainjson = vc
    1 pskinind = i2
    1 pskinjson = vc
    1 immind = i2
    1 immjson = vc
    1 tobind = i2
    1 tobjson = vc
    1 subind = i2
    1 subjson = vc
    1 pcind = i2
    1 pcjson = vc
    1 hbipsind = i2
    1 hbipsjson = vc
    1 sepsisind = i2
    1 sepsisjson = vc
    1 hsind = i2
    1 hsjson = vc
    1 patients[*]
      2 pagenum = i4
      2 ptqualind = i4
      2 pt_id = f8
      2 encntr_id = f8
      2 encntr_typecd = f8
      2 name = vc
      2 fin = vc
      2 mrn = vc
      2 age = vc
      2 birth_dt = vc
      2 birthdtjs = vc
      2 gender = vc
      2 org_id = f8
      2 facility = vc
      2 facilitycd = f8
      2 nurse_unit = vc
      2 room = vc
      2 bed = vc
      2 los = f8
      2 attend_phy = vc
      2 nurse = vc
      2 admit_dt = vc
      2 admitdtjs = vc
      2 surg_dt = vc
      2 surgdtjs = vc
      2 allergy_cnt = i4
      2 visitreason = vc
      2 allergy[*]
        3 alg_desc = vc
        3 severity = vc
        3 type = vc
      2 diag_cnt = i4
      2 diag[*]
        3 diag_desc = vc
        3 diag_dt = vc
        3 diagdtjs = vc
        3 type = vc
      2 prob_cnt = i4
      2 problem[*]
        3 prob_desc = vc
        3 prob_dt = vc
        3 probdtjs = vc
        3 type = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(ptreply2)))
  RECORD ptreply2(
    1 pt_cnt = i4
    1 page_cnt = i4
    1 tabname = vc
    1 prsnlid = f8
    1 positioncd = f8
    1 viewprefsid = f8
    1 amiind = i2
    1 amijson = vc
    1 hfind = i2
    1 hfjson = vc
    1 pnind = i2
    1 pnjson = vc
    1 cacind = i2
    1 cacjson = vc
    1 vteind = i2
    1 vtejson = vc
    1 stkind = i2
    1 stkjson = vc
    1 scipind = i2
    1 scipjson = vc
    1 pulcerind = i2
    1 pulcerjson = vc
    1 criind = i2
    1 crijson = vc
    1 fallsind = i2
    1 fallsjson = vc
    1 pfallind = i2
    1 pfalljson = vc
    1 painind = i2
    1 painjson = vc
    1 ppainind = i2
    1 ppainjson = vc
    1 pskinind = i2
    1 pskinjson = vc
    1 immind = i2
    1 immjson = vc
    1 tobind = i2
    1 tobjson = vc
    1 subind = i2
    1 subjson = vc
    1 pcind = i2
    1 pcjson = vc
    1 hbipsind = i2
    1 hbipsjson = vc
    1 sepsisind = i2
    1 sepsisjson = vc
    1 hsind = i2
    1 hsjson = vc
    1 patients[*]
      2 pagenum = i4
      2 ptqualind = i4
      2 pt_id = f8
      2 encntr_id = f8
      2 encntr_typecd = f8
      2 name = vc
      2 fin = vc
      2 mrn = vc
      2 age = vc
      2 birth_dt = vc
      2 birthdtjs = vc
      2 gender = vc
      2 org_id = f8
      2 facility = vc
      2 facilitycd = f8
      2 nurse_unit = vc
      2 room = vc
      2 bed = vc
      2 los = f8
      2 attend_phy = vc
      2 nurse = vc
      2 admit_dt = vc
      2 admitdtjs = vc
      2 surg_dt = vc
      2 surgdtjs = vc
      2 allergy_cnt = i4
      2 visitreason = vc
      2 allergy[*]
        3 alg_desc = vc
        3 severity = vc
        3 type = vc
      2 diag_cnt = i4
      2 diag[*]
        3 diag_desc = vc
        3 diag_dt = vc
        3 diagdtjs = vc
        3 type = vc
      2 prob_cnt = i4
      2 problem[*]
        3 prob_desc = vc
        3 prob_dt = vc
        3 probdtjs = vc
        3 type = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(amireply)))
  RECORD amireply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 ptqual = i2
      2 assessdttm = dq8
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(hfreply)))
  RECORD hfreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 ptqual = i2
      2 assessdttm = dq8
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status_data
      2 status = c1
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(cacreply)))
  RECORD cacreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 ptqual = i2
      2 assessdttm = dq8
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status_data
      2 status = c1
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(pnreply)))
  RECORD pnreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 ptqual = i2
      2 pwstatus = vc
      2 assessdttm = dq8
      2 admitdt = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status_data
      2 status = c1
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(scipreply)))
  RECORD scipreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 ptqual = i2
      2 assessdttm = dq8
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status_data
      2 status = c1
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(stkreply)))
  RECORD stkreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 ptqual = i2
      2 assessdttm = dq8
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(vtereply)))
  RECORD vtereply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 ptqual = i2
      2 assessdttm = dq8
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(pulcerreply)))
  RECORD pulcerreply(
    1 ptcnt = i4
    1 patients[*]
      2 pulcer_ptqual = i2
      2 pt_id = f8
      2 encntr_id = f8
      2 encntr_typecd = f8
      2 name = vc
      2 birthdt = dq8
      2 admitdt = dq8
      2 facility = vc
      2 facilitycd = f8
      2 assessstat = i2
      2 interventstat = i2
      2 pustat = i2
      2 ulcer1 = vc
      2 ulcerid1 = f8
      2 ulcer2 = vc
      2 ulcerid2 = f8
      2 pustage1 = vc
      2 stageid1 = f8
      2 pustage2 = vc
      2 stageid2 = f8
      2 event_cnt = i4
      2 events[*]
        3 type = vc
        3 event_dt = dq8
        3 eventdtdisp = vc
        3 event_cd = f8
        3 event_disp = vc
        3 event_result = vc
        3 event_cki = vc
        3 event_goal = vc
        3 event_status = i2
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(crireply)))
  RECORD crireply(
    1 ptcnt = i4
    1 patients[*]
      2 ptqualind = i4
      2 pt_id = f8
      2 encntr_id = f8
      2 encntr_typecd = f8
      2 name = vc
      2 birthdt = dq8
      2 admitdt = dq8
      2 facility = vc
      2 facilitycd = f8
      2 cri_ptqual = i2
      2 linedaystat = i2
      2 ucind = i2
      2 cvind = i2
      2 ucdt = dq8
      2 cvdt = dq8
      2 firstdt = dq8
      2 assessstat = i2
      2 sympstat = i2
      2 cri_cnt = i4
      2 cri[*]
        3 type = vc
        3 status = i4
        3 eventcnt = i4
        3 nmbrcri = i4
        3 events[*]
          4 event_dt = dq8
          4 eventdtdisp = vc
          4 eventlblid = f8
          4 event_cd = f8
          4 event_disp = vc
          4 event_result = vc
          4 event_cki = vc
          4 event_val = vc
          4 event_status = i4
          4 eventtypeind = i2
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(fallsreply)))
  RECORD fallsreply(
    1 patients[*]
      2 ptqualind = i4
      2 pt_id = f8
      2 encntr_id = f8
      2 encntr_typecd = f8
      2 name = vc
      2 birthdt = dq8
      2 admitdt = dq8
      2 facility = vc
      2 facilitycd = f8
      2 fall_ptqual = i2
      2 falls_cnt = i4
      2 falls[*]
        3 type = vc
        3 status = i4
        3 event_cnt = i4
        3 nmbrfalls = i2
        3 attreqind = i2
        3 dtfalls = vc
        3 events[*]
          4 event_dt = dq8
          4 eventdtdisp = vc
          4 event_cd = f8
          4 parent_event_id = f8
          4 event_disp = vc
          4 event_result = vc
          4 event_cki = vc
          4 event_goal = vc
          4 event_status = i4
  )
 ENDIF
 IF ( NOT (validate(pfallreply)))
  RECORD pfallreply(
    1 patients[*]
      2 ptqualind = i4
      2 pt_id = f8
      2 encntr_id = f8
      2 encntr_typecd = f8
      2 name = vc
      2 birthdt = dq8
      2 admitdt = dq8
      2 facility = vc
      2 facilitycd = f8
      2 pfall_ptqual = i2
      2 pfall_cnt = i4
      2 pfall[*]
        3 type = vc
        3 status = i4
        3 event_cnt = i4
        3 nmbrpfall = i4
        3 events[*]
          4 event_dt = dq8
          4 eventdtdisp = vc
          4 eventlblid = f8
          4 event_cd = f8
          4 event_disp = vc
          4 event_result = vc
          4 event_cki = vc
          4 event_val = vc
          4 event_status = i4
          4 eventtypeind = i2
  )
 ENDIF
 IF ( NOT (validate(apmreply)))
  RECORD apmreply(
    1 listcnt = i4
    1 colmncnt = i4
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 birthdt = dq8
      2 eidtype = f8
      2 admitdt = dq8
      2 facilitycd = f8
      2 ptqual = i2
      2 cnt = i4
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 hidecnt = i4
      2 paincnt = i4
      2 assesscnt = i4
      2 intervcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 hidestat = i4
      2 painstat = i4
      2 assessstat = i4
      2 intervstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 tmind = i2
        3 status = i4
        3 statusdisp = vc
        3 event_dt = dq8
        3 eventdtdisp = vc
        3 event_cd = f8
        3 event_disp = vc
        3 event_result = vc
        3 event_cki = vc
        3 event_goal = vc
        3 event_status = i4
        3 eventtype = f8
        3 compenddt = dq8
        3 compstatus = f8
        3 outcomestatus = f8
        3 outcometype = f8
        3 resultcnt = i4
        3 results[*]
          4 nomid = f8
          4 nomenflag = i4
          4 numeric = i4
          4 resultunitscd = f8
          4 operand = vc
          4 operator = f8
          4 rslttype = f8
          4 rsltval = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(ppmreply)))
  RECORD ppmreply(
    1 listcnt = i4
    1 colmncnt = i4
    1 list[*]
      2 ptdataind = i2
      2 ptqual = i2
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 birthdt = dq8
      2 eidtype = f8
      2 admitdt = dq8
      2 facilitycd = f8
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 assessstat = i2
      2 painpres = vc
      2 painpresno = vc
      2 tooldisp = vc
      2 selfrpt = vc
      2 painloc = vc
      2 painlat = vc
      2 painqual = vc
      2 painpat = vc
      2 timedind = i2
      2 intervstat = i2
      2 intervdisp = vc
      2 painstat = i2
      2 acceptpain = vc
      2 acceptrslt = vc
      2 acceptdt = vc
      2 eventcnt = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 tmind = i2
        3 status = i4
        3 statusdisp = vc
        3 event_dt = dq8
        3 eventdtdisp = vc
        3 event_cd = f8
        3 event_disp = vc
        3 event_result = vc
        3 event_status = i4
        3 eventtype = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(psreply)))
  RECORD psreply(
    1 listcnt = i4
    1 colmncnt = i4
    1 list[*]
      2 ptdataind = i2
      2 ptqual = i2
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 birthdt = dq8
      2 eidtype = f8
      2 admitdt = dq8
      2 facilitycd = f8
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 riskassessstat = i2
      2 integritystat = i2
      2 impairmentstat = i2
      2 pskinimpairment1 = vc
      2 pskinimpairmentdt1 = vc
      2 pskinstage1 = vc
      2 pskinpoa1 = vc
      2 pskinimpairment2 = vc
      2 pskinimpairmentdt2 = vc
      2 pskinstage2 = vc
      2 pskinpoa2 = vc
      2 intervstat = i2
      2 intervdisp = vc
      2 eventcnt = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 tmind = i2
        3 status = i4
        3 statusdisp = vc
        3 event_dt = dq8
        3 eventdtdisp = vc
        3 event_cd = f8
        3 event_disp = vc
        3 event_result = vc
        3 event_status = i4
        3 eventtype = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(immreply)))
  RECORD immreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 name = vc
      2 ptqual = i2
      2 assessdttm = dq8
      2 admitdt = vc
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(tobreply)))
  RECORD tobreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 name = vc
      2 ptqual = i2
      2 assessdttm = dq8
      2 admitdt = vc
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(subreply)))
  RECORD subreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 name = vc
      2 ptqual = i2
      2 assessdttm = dq8
      2 admitdt = vc
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(pcreply)))
  RECORD pcreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 name = vc
      2 ptqual = i2
      2 assessdttm = dq8
      2 admitdt = vc
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(hbipsreply)))
  RECORD hbipsreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 name = vc
      2 ptqual = i2
      2 assessdttm = dq8
      2 admitdt = vc
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(sepsisreply)))
  RECORD sepsisreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 ptqual = i2
      2 assessdttm = dq8
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(hsreply)))
  RECORD hsreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 name = vc
      2 ptqual = i2
      2 assessdttm = dq8
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE painreq = vc WITH protect
 DECLARE now = i4 WITH protect
 DECLARE prsnlid2 = f8 WITH protect
 DECLARE domainid2 = f8 WITH protect
 DECLARE domaingrpid2 = f8 WITH protect
 DECLARE appcntxid2 = f8 WITH protect
 DECLARE appid2 = i4 WITH protect
 DECLARE clientnm2 = vc WITH protect
 DECLARE reltncd2 = f8 WITH protect
 DECLARE ptlistid2 = f8 WITH protect
 DECLARE ptlisttype2 = f8 WITH protect
 DECLARE ptlistloccd2 = f8 WITH protect
 DECLARE allergyind2 = i2 WITH protect
 DECLARE diagind2 = i2 WITH protect
 DECLARE probind2 = i2 WITH protect
 DECLARE allqmstr = vc WITH protect
 DECLARE positioncd = f8
 DECLARE tabnumstrg = vc
 DECLARE viewprefid = f8
 DECLARE strsize = i2
 DECLARE commapos = i2
 DECLARE tabdefnumstring = vc
 DECLARE tabdefnumint = i2
 SET ptreply->tabname = "Patient Information"
 IF (( $2 != null))
  SET now = cnvtjsontorec( $2)
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo("This is the converted json string to record")
   CALL echorecord(qmreq)
  ENDIF
 ENDIF
 SET prsnlid2 = qmreq->prsnlid
 SET domainid2 = qmreq->domainid
 SET domaingrpid2 = qmreq->domaingrpid
 SET appcntxid2 = qmreq->appcntxid
 SET appid2 = qmreq->appid
 SET clientnm2 = qmreq->clientnm
 SET reltncd2 = qmreq->reltncd
 SET ptlistid2 = qmreq->ptlistid
 SET ptlisttype2 = qmreq->ptlisttype
 SET ptlistloccd2 = qmreq->ptlistloccd
 SET allergyind2 = qmreq->allergyind
 SET diagind2 = qmreq->diagind
 SET probind2 = qmreq->probind
 FREE RECORD qmreq
 RECORD qmreq(
   1 prsnlid = f8
   1 domainid = f8
   1 domaingrpid = f8
   1 appcntxid = f8
   1 devloccd = f8
   1 appid = i4
   1 clientnm = vc
   1 reltncd = f8
   1 ptlistid = f8
   1 ptlisttype = f8
   1 ptlistloccd = f8
   1 allergyind = i2
   1 diagind = i2
   1 probind = i2
   1 list[*]
     2 pid = f8
     2 eid = f8
     2 name = vc
     2 birthdt = vc
     2 eidtype = f8
     2 admitdt = vc
     2 facilitycd = f8
     2 orgid = f8
 )
 SET qmreq->prsnlid = prsnlid2
 SET qmreq->domainid = domainid2
 SET qmreq->domaingrpid = domaingrpid2
 SET qmreq->appcntxid = appcntxid2
 SET qmreq->appid = appid2
 SET qmreq->clientnm = clientnm2
 SET qmreq->reltncd = reltncd2
 SET qmreq->ptlistid = ptlistid2
 SET qmreq->ptlisttype = ptlisttype2
 SET qmreq->ptlistloccd = ptlistloccd2
 SET qmreq->allergyind = allergyind2
 SET qmreq->diagind = diagind2
 SET qmreq->probind = probind2
 IF (checkdic("DC_MP_GET_PATIENTS2","P",0) > 0)
  EXECUTE dc_mp_get_patients2 "NOFORMS", "" WITH replace(ptreply,ptreply2)
 ENDIF
 IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
  CALL echo("Back from DC_MP_GET_PATIENTS2")
  CALL echorecord(ptreply2)
 ENDIF
 IF ((ptreply2->pt_cnt > 0))
  SELECT INTO "nl:"
   patients_pt_id = ptreply2->patients[d1.seq].pt_id, name = substring(1,40,ptreply2->patients[d1.seq
    ].name)
   FROM (dummyt d1  WITH seq = ptreply2->pt_cnt)
   PLAN (d1)
   ORDER BY name DESC
   HEAD REPORT
    cntr = 0, now = alterlist(qmreq->list,ptreply2->pt_cnt)
   DETAIL
    cntr = (cntr+ 1), qmreq->list[cntr].name = ptreply2->patients[d1.seq].name, qmreq->list[cntr].pid
     = ptreply2->patients[d1.seq].pt_id,
    qmreq->list[cntr].eid = ptreply2->patients[d1.seq].encntr_id, qmreq->list[cntr].eidtype =
    ptreply2->patients[d1.seq].encntr_typecd, qmreq->list[cntr].birthdt = ptreply2->patients[d1.seq].
    birth_dt,
    qmreq->list[cntr].admitdt = ptreply2->patients[d1.seq].admit_dt, qmreq->list[cntr].facilitycd =
    ptreply2->patients[d1.seq].facilitycd, qmreq->list[cntr].orgid = ptreply2->patients[d1.seq].
    org_id
   WITH nocounter, separator = " ", format
  ;end select
  SET allqmstr = cnvtrectojson(qmreq)
 ELSE
  GO TO exit_script
  FREE RECORD qmreq
 ENDIF
 IF (( $3 > 0))
  IF (checkdic("DC_MP_GET_AMI","P",0) > 0)
   EXECUTE dc_mp_get_ami "noforms", ""
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("AMI Check:", $3))
   CALL echo("Back from DC_MP_GET_AMI")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = amireply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(amireply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (amireply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=amireply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->amiind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->amiind=1))
   SET ptreply->amijson = cnvtrectojson(amireply)
  ELSE
   SET now = alterlist(amireply->nomenlist,0)
   SET now = alterlist(amireply->list,0)
   SET ptreply->amijson = cnvtrectojson(amireply)
  ENDIF
 ENDIF
 FREE RECORD amireply
 IF (( $4 > 0))
  IF (checkdic("DC_MP_GET_HF","P",0) > 0)
   EXECUTE dc_mp_get_hf "noforms", ""
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("HF Check:", $4))
   CALL echo("Back from DC_MP_GET_HF")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = hfreply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(hfreply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (hfreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=hfreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->hfind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->hfind=1))
   SET ptreply->hfjson = cnvtrectojson(hfreply)
  ELSE
   SET now = alterlist(hfreply->nomenlist,0)
   SET now = alterlist(hfreply->list,0)
   SET ptreply->hfjson = cnvtrectojson(hfreply)
  ENDIF
 ENDIF
 FREE RECORD hfreply
 IF (( $5 > 0))
  IF (checkdic("DC_MP_GET_PN","P",0) > 0)
   EXECUTE dc_mp_get_pn "noforms", ""
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("PN Check:", $5))
   CALL echo("Back from DC_MP_GET_PN")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = pnreply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(pnreply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (pnreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=pnreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->pnind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->pnind=1))
   SET ptreply->pnjson = cnvtrectojson(pnreply)
  ELSE
   SET now = alterlist(pnreply->nomenlist,0)
   SET now = alterlist(pnreply->list,0)
   SET ptreply->pnjson = cnvtrectojson(pnreply)
  ENDIF
 ENDIF
 FREE RECORD pnreply
 IF (( $6 > 0))
  IF (checkdic("DC_MP_GET_CAC","P",0) > 0)
   EXECUTE dc_mp_get_cac "noforms", ""
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("CAC Check:", $6))
   CALL echo("Back from DC_MP_GET_CAC")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = cacreply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(cacreply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (cacreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=cacreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->cacind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->cacind=1))
   SET ptreply->cacjson = cnvtrectojson(cacreply)
  ELSE
   SET now = alterlist(cacreply->nomenlist,0)
   SET now = alterlist(cacreply->list,0)
   SET ptreply->cacjson = cnvtrectojson(cacreply)
  ENDIF
 ENDIF
 FREE RECORD cacreply
 IF (( $7 > 0))
  IF (checkdic("DC_MP_GET_VTE","P",0) > 0)
   EXECUTE dc_mp_get_vte "noforms", ""
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("VTE Check:", $7))
   CALL echo("Back from DC_MP_GET_VTE")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = vtereply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(vtereply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (vtereply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=vtereply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->vteind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->vteind=1))
   SET ptreply->vtejson = cnvtrectojson(vtereply)
  ELSE
   SET now = alterlist(vtereply->nomenlist,0)
   SET now = alterlist(vtereply->list,0)
   SET ptreply->vtejson = cnvtrectojson(vtereply)
  ENDIF
 ENDIF
 FREE RECORD vtereply
 IF (( $8 > 0))
  IF (checkdic("DC_MP_GET_STROKE","P",0) > 0)
   EXECUTE dc_mp_get_stroke "noforms", ""
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("STK Check:", $8))
   CALL echo("Back from DC_MP_GET_STROKE")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = stkreply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(stkreply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (stkreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=stkreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->stkind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->stkind=1))
   SET ptreply->stkjson = cnvtrectojson(stkreply)
  ELSE
   SET now = alterlist(stkreply->nomenlist,0)
   SET now = alterlist(stkreply->list,0)
   SET ptreply->stkjson = cnvtrectojson(stkreply)
  ENDIF
 ENDIF
 FREE RECORD stkreply
 IF (( $9 > 0))
  IF (checkdic("DC_MP_GET_SCIP","P",0) > 0)
   EXECUTE dc_mp_get_scip "noforms", ""
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("SCIP Check:", $9))
   CALL echo("Back from DC_MP_GET_SCIP")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = scipreply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(scipreply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (scipreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=scipreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->scipind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->scipind=1))
   SET ptreply->scipjson = cnvtrectojson(scipreply)
  ELSE
   SET now = alterlist(scipreply->nomenlist,0)
   SET now = alterlist(scipreply->list,0)
   SET ptreply->scipjson = cnvtrectojson(scipreply)
  ENDIF
 ENDIF
 FREE RECORD scipreply
 IF (( $10 > 0))
  IF (checkdic("DC_MP_GET_LH_PULCER","P",0) > 0)
   EXECUTE dc_mp_get_lh_pulcer "noforms", ""
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("PULCER Check:", $10))
   CALL echo("Back from DC_MP_GET_LH_PULCER")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   patients_encntr_id = ptreply2->patients[d2.seq].encntr_id
   FROM (dummyt d1  WITH seq = value(size(pulcerreply->patients,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (pulcerreply->patients[d1.seq].pulcer_ptqual > 0))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=pulcerreply->patients[d1.seq].encntr_id))
   HEAD REPORT
    ptreply2->pulcerind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->pulcerind=1))
   SET ptreply->pulcerjson = cnvtrectojson(pulcerreply)
  ELSE
   SET ptreply->pulcerjson = "NA"
  ENDIF
 ENDIF
 FREE RECORD pulcerreply
 IF (( $11 > 0))
  IF (checkdic("DC_MP_GET_LH_CRI","P",0) > 0)
   EXECUTE dc_mp_get_lh_cri "noforms", ""
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("CRI Check:", $11))
   CALL echo("Back from DC_MP_GET_LH_CRI")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   patients_encntr_id = ptreply2->patients[d2.seq].encntr_id
   FROM (dummyt d1  WITH seq = value(size(crireply->patients,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (crireply->patients[d1.seq].cri_ptqual > 0))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=crireply->patients[d1.seq].encntr_id))
   HEAD REPORT
    ptreply2->criind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->criind=1))
   SET ptreply->crijson = cnvtrectojson(crireply)
  ELSE
   SET ptreply->crijson = "NA"
  ENDIF
 ENDIF
 FREE RECORD crireply
 IF (( $12 > 0))
  IF (checkdic("DC_MP_GET_LH_FALLS","P",0) > 0)
   EXECUTE dc_mp_get_lh_falls "noforms", allqmstr
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("FALLS Check:", $12))
   CALL echo("Back from DC_MP_GET_LH_FALLS")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   patients_encntr_id = ptreply2->patients[d2.seq].encntr_id
   FROM (dummyt d1  WITH seq = value(size(fallsreply->patients,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (fallsreply->patients[d1.seq].fall_ptqual > 0))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=fallsreply->patients[d1.seq].encntr_id))
   HEAD REPORT
    ptreply2->fallsind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->fallsind=1))
   SET ptreply->fallsjson = cnvtrectojson(fallsreply)
  ELSE
   SET ptreply->fallsjson = "NA"
  ENDIF
 ENDIF
 FREE RECORD fallsreply
 IF (( $13 > 0))
  IF (checkdic("DC_MP_LH_FALL_PED","P",0) > 0)
   EXECUTE dc_mp_lh_fall_ped "noforms", allqmstr
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("PEDS FALLS Check:", $13))
   CALL echo("Back from DC_MP_LH_FALL_PED")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   patients_encntr_id = ptreply2->patients[d2.seq].encntr_id
   FROM (dummyt d1  WITH seq = value(size(pfallreply->patients,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (pfallreply->patients[d1.seq].pfall_ptqual > 0))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=pfallreply->patients[d1.seq].encntr_id))
   HEAD REPORT
    ptreply2->pfallind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->pfallind=1))
   SET ptreply->pfalljson = cnvtrectojson(pfallreply)
  ELSE
   SET ptreply->pfalljson = "NA"
  ENDIF
 ENDIF
 FREE RECORD pfallreply
 IF (( $14 > 0))
  IF (checkdic("DC_MP_GET_LH_PAIN","P",0) > 0)
   EXECUTE dc_mp_get_lh_pain "noforms", allqmstr
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("PAIN Check:", $14))
   CALL echo("Back from DC_MP_GET_LH_PAIN")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   patients_encntr_id = ptreply2->patients[d2.seq].encntr_id
   FROM (dummyt d1  WITH seq = value(apmreply->listcnt)),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (apmreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=apmreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->painind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->painind=1))
   SET ptreply->painjson = cnvtrectojson(apmreply)
  ELSE
   SET ptreply->painjson = "NA"
  ENDIF
 ENDIF
 FREE RECORD apmreply
 IF (( $15 > 0))
  IF (checkdic("dc_mp_get_lh_ped_pain","P",0) > 0)
   EXECUTE dc_mp_get_lh_ped_pain "noforms", allqmstr
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("PED PAIN Check:", $15))
   CALL echo("Back from dc_mp_get_lh_ped_pain")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   patients_encntr_id = ptreply2->patients[d2.seq].encntr_id
   FROM (dummyt d1  WITH seq = value(ppmreply->listcnt)),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (ppmreply->list[d1.seq].ptqual=1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=ppmreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->ppainind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->ppainind=1))
   SET ptreply->ppainjson = cnvtrectojson(ppmreply)
  ELSE
   SET ptreply->ppainjson = "NA"
  ENDIF
 ENDIF
 CALL echorecord(ppmreply)
 FREE RECORD ppmreply
 IF (( $16 > 0))
  IF (checkdic("DC_MP_GET_LH_PSKIN","P",0) > 0)
   EXECUTE dc_mp_get_lh_pskin "noforms", allqmstr
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("PED SKIN Check:", $16))
   CALL echo("Back from DC_MP_GET_LH_PSKIN")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   patients_encntr_id = ptreply2->patients[d2.seq].encntr_id
   FROM (dummyt d1  WITH seq = value(psreply->listcnt)),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (psreply->list[d1.seq].ptqual=1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=psreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->pskinind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->pskinind=1))
   SET ptreply->pskinjson = cnvtrectojson(psreply)
  ELSE
   SET ptreply->pskinjson = "NA"
  ENDIF
 ENDIF
 CALL echorecord(psreply)
 FREE RECORD psreply
 IF (( $17 > 0))
  IF (checkdic("DC_MP_GET_IMM","P",0) > 0)
   EXECUTE dc_mp_get_imm "noforms", allqmstr
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("IMM Check:", $17))
   CALL echo("Back from DC_MP_GET_IMM")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = immreply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(immreply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (immreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=immreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->immind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->immind=1))
   SET ptreply->immjson = cnvtrectojson(immreply)
  ELSE
   SET now = alterlist(immreply->nomenlist,0)
   SET now = alterlist(immreply->list,0)
   SET ptreply->immjson = cnvtrectojson(immreply)
  ENDIF
 ENDIF
 FREE RECORD immreply
 IF (( $18 > 0))
  IF (checkdic("DC_MP_GET_TOB","P",0) > 0)
   EXECUTE dc_mp_get_tob "noforms", allqmstr
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("TOB Check:", $18))
   CALL echo("Back from dc_mp_get_tob")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = tobreply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(tobreply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (tobreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=tobreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->tobind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->tobind=1))
   SET ptreply->tobjson = cnvtrectojson(tobreply)
  ELSE
   SET now = alterlist(tobreply->nomenlist,0)
   SET now = alterlist(tobreply->list,0)
   SET ptreply->tobjson = cnvtrectojson(tobreply)
  ENDIF
 ENDIF
 FREE RECORD tobreply
 IF (( $19 > 0))
  IF (checkdic("DC_MP_GET_SUB","P",0) > 0)
   EXECUTE dc_mp_get_sub "noforms", allqmstr
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("SUB Check:", $19))
   CALL echo("Back from dc_mp_get_sub")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = subreply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(subreply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (subreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=subreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->subind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->subind=1))
   SET ptreply->subjson = cnvtrectojson(subreply)
  ELSE
   SET now = alterlist(subreply->nomenlist,0)
   SET now = alterlist(subreply->list,0)
   SET ptreply->subjson = cnvtrectojson(subreply)
  ENDIF
 ENDIF
 FREE RECORD subreply
 IF (( $20 > 0))
  IF (checkdic("DC_MP_GET_PC","P",0) > 0)
   EXECUTE dc_mp_get_pc "noforms", allqmstr
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("PC Check:", $20))
   CALL echo("Back from DC_MP_GET_PC")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = pcreply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(pcreply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (pcreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=pcreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->pcind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->pcind=1))
   SET ptreply->pcjson = cnvtrectojson(pcreply)
  ELSE
   SET now = alterlist(pcreply->nomenlist,0)
   SET now = alterlist(pcreply->list,0)
   SET ptreply->pcjson = cnvtrectojson(pcreply)
  ENDIF
 ENDIF
 FREE RECORD pcreply
 IF (( $21 > 0))
  IF (checkdic("DC_MP_GET_HBIPS","P",0) > 0)
   EXECUTE dc_mp_get_hbips "noforms", allqmstr
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL echo(build("HBIPS Check:", $21))
   CALL echo("Back from DC_MP_GET_HBIPS")
   CALL echorecord(ptreply2)
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = hbipsreply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(hbipsreply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (hbipsreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=hbipsreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->hbipsind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->hbipsind=1))
   SET ptreply->hbipsjson = cnvtrectojson(hbipsreply)
  ELSE
   SET now = alterlist(hbipsreply->nomenlist,0)
   SET now = alterlist(hbipsreply->list,0)
   SET ptreply->hbipsjson = cnvtrectojson(hbipsreply)
  ENDIF
 ENDIF
 FREE RECORD hbipsreply
 IF (( $22 > 0))
  IF (checkdic("DC_MP_GET_SEPSIS","P",0) > 0)
   EXECUTE dc_mp_get_sepsis "noforms", allqmstr
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL lhprint(build("SEPSIS Check:", $22))
   CALL lhprint("Back from DC_MP_GET_SEPSIS")
   IF (validate(audit_filename))
    CALL echorecord(ptreply2,audit_filename,1)
   ELSE
    CALL echorecord(ptreply2)
   ENDIF
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = sepsisreply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(sepsisreply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (sepsisreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=sepsisreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->sepsisind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->sepsisind != 1))
   SET now = alterlist(sepsisreply->nomenlist,0)
   SET now = alterlist(sepsisreply->list,0)
  ENDIF
  SET ptreply->sepsisjson = cnvtrectojson(sepsisreply)
 ENDIF
 FREE RECORD sepsisreply
 IF (( $23 > 0))
  IF (checkdic("DC_MP_GET_HS","P",0) > 0)
   EXECUTE dc_mp_get_hs "noforms", allqmstr
  ENDIF
  IF (validate(debug_dc_mp_get_allqm_ind,0)=1)
   CALL lhprint("Back from DC_MP_GET_HS")
   IF (validate(audit_filename))
    CALL echorecord(ptreply2,audit_filename,1)
   ELSE
    CALL echorecord(ptreply2)
   ENDIF
  ENDIF
  SELECT INTO "NL:"
   list_ptqual = hsreply->list[d1.seq].ptqual, patients_encntr_id = ptreply2->patients[d2.seq].
   encntr_id
   FROM (dummyt d1  WITH seq = value(size(hsreply->list,5))),
    (dummyt d2  WITH seq = value(ptreply2->pt_cnt))
   PLAN (d1
    WHERE (hsreply->list[d1.seq].ptqual > 1))
    JOIN (d2
    WHERE (ptreply2->patients[d2.seq].encntr_id=hsreply->list[d1.seq].eid))
   HEAD REPORT
    ptreply2->hsind = 1
   DETAIL
    ptreply2->patients[d2.seq].ptqualind = 1
   WITH nocounter, separator = " ", format
  ;end select
  IF ((ptreply2->hsind != 1))
   SET now = alterlist(hsreply->nomenlist,0)
   SET now = alterlist(hsreply->list,0)
  ENDIF
  SET ptreply->hsjson = cnvtrectojson(hsreply)
 ENDIF
 FREE RECORD hsreply
 SELECT INTO "NL:"
  patients_encntr_id = ptreply2->patients[d1.seq].encntr_id
  FROM (dummyt d1  WITH seq = value(ptreply2->pt_cnt))
  PLAN (d1
   WHERE (ptreply2->patients[d1.seq].ptqualind=1))
  HEAD REPORT
   cntr = 0, cntx = 0.0, pagecount1 = 0.0,
   pagecount2 = 0, ptreply->amiind = ptreply2->amiind, ptreply->hfind = ptreply2->hfind,
   ptreply->pnind = ptreply2->pnind, ptreply->cacind = ptreply2->cacind, ptreply->vteind = ptreply2->
   vteind,
   ptreply->stkind = ptreply2->stkind, ptreply->scipind = ptreply2->scipind, ptreply->pulcerind =
   ptreply2->pulcerind,
   ptreply->criind = ptreply2->criind, ptreply->fallsind = ptreply2->fallsind, ptreply->pfallind =
   ptreply2->pfallind,
   ptreply->painind = ptreply2->painind, ptreply->ppainind = ptreply2->ppainind, ptreply->pskinind =
   ptreply2->pskinind,
   ptreply->immind = ptreply2->immind, ptreply->tobind = ptreply2->tobind, ptreply->subind = ptreply2
   ->subind,
   ptreply->pcind = ptreply2->pcind, ptreply->hbipsind = ptreply2->hbipsind, ptreply->sepsisind =
   ptreply2->sepsisind,
   ptreply->hsind = ptreply2->hsind, ptreply->status_data.status = ptreply2->status_data.status,
   ptreply->status_data.subeventstatus[1].operationname = ptreply2->status_data.subeventstatus[1].
   operationname,
   ptreply->status_data.subeventstatus[1].operationstatus = ptreply2->status_data.subeventstatus[1].
   operationstatus, ptreply->status_data.subeventstatus[1].targetobjectname = ptreply2->status_data.
   subeventstatus[1].targetobjectname, ptreply->status_data.subeventstatus[1].targetobjectvalue =
   ptreply2->status_data.subeventstatus[1].targetobjectvalue
  DETAIL
   cntr = (cntr+ 1)
   IF (mod(cntr,100)=1)
    now = alterlist(ptreply->patients,(cntr+ 99))
   ENDIF
   pagecount1 = 0.0, pagecount2 = 0, pagecount1 = cnvtreal((cntr/ 25.0)),
   pagecount2 = cnvtint(pagecount1)
   IF (pagecount1 > pagecount2)
    ptreply->patients[cntr].pagenum = (pagecount2+ 1)
   ELSEIF (pagecount1=pagecount2)
    ptreply->patients[cntr].pagenum = pagecount2
   ENDIF
   ptreply->patients[cntr].ptqualind = ptreply2->patients[d1.seq].ptqualind, ptreply->patients[cntr].
   pt_id = ptreply2->patients[d1.seq].pt_id, ptreply->patients[cntr].encntr_id = ptreply2->patients[
   d1.seq].encntr_id,
   ptreply->patients[cntr].encntr_typecd = ptreply2->patients[d1.seq].encntr_typecd, ptreply->
   patients[cntr].name = ptreply2->patients[d1.seq].name, ptreply->patients[cntr].fin = ptreply2->
   patients[d1.seq].fin,
   ptreply->patients[cntr].mrn = ptreply2->patients[d1.seq].mrn, ptreply->patients[cntr].age =
   ptreply2->patients[d1.seq].age, ptreply->patients[cntr].birth_dt = ptreply2->patients[d1.seq].
   birth_dt,
   ptreply->patients[cntr].birthdtjs = ptreply2->patients[d1.seq].birthdtjs, ptreply->patients[cntr].
   gender = ptreply2->patients[d1.seq].gender, ptreply->patients[cntr].org_id = ptreply2->patients[d1
   .seq].org_id,
   ptreply->patients[cntr].facility = ptreply2->patients[d1.seq].facility, ptreply->patients[cntr].
   facilitycd = ptreply2->patients[d1.seq].facilitycd, ptreply->patients[cntr].nurse_unit = ptreply2
   ->patients[d1.seq].nurse_unit,
   ptreply->patients[cntr].room = ptreply2->patients[d1.seq].room, ptreply->patients[cntr].bed =
   ptreply2->patients[d1.seq].bed, ptreply->patients[cntr].los = ptreply2->patients[d1.seq].los,
   ptreply->patients[cntr].attend_phy = ptreply2->patients[d1.seq].attend_phy, ptreply->patients[cntr
   ].nurse = ptreply2->patients[d1.seq].nurse, ptreply->patients[cntr].admit_dt = ptreply2->patients[
   d1.seq].admit_dt,
   ptreply->patients[cntr].admitdtjs = ptreply2->patients[d1.seq].admitdtjs, ptreply->patients[cntr].
   surg_dt = ptreply2->patients[d1.seq].surg_dt, ptreply->patients[cntr].surgdtjs = ptreply2->
   patients[d1.seq].surgdtjs,
   ptreply->patients[cntr].allergy_cnt = ptreply2->patients[d1.seq].allergy_cnt, ptreply->patients[
   cntr].visitreason = ptreply2->patients[d1.seq].visitreason, ptreply->patients[cntr].diag_cnt =
   ptreply2->patients[d1.seq].diag_cnt,
   ptreply->patients[cntr].prob_cnt = ptreply2->patients[d1.seq].prob_cnt, now = moverec(ptreply2->
    patients[d1.seq].allergy,ptreply->patients[cntr].allergy), now = moverec(ptreply2->patients[d1
    .seq].diag,ptreply->patients[cntr].diag),
   now = moverec(ptreply2->patients[d1.seq].problem,ptreply->patients[cntr].problem)
  FOOT REPORT
   now = alterlist(ptreply->patients,cntr), ptreply->pt_cnt = cntr, pagecount1 = 0.0,
   pagecount2 = 0, pagecount1 = cnvtreal((cntr/ 25.0)), pagecount2 = cnvtint(pagecount1)
   IF (pagecount1 > pagecount2)
    ptreply->page_cnt = (pagecount2+ 1)
   ELSEIF (pagecount1=pagecount2)
    ptreply->page_cnt = pagecount2
   ENDIF
  WITH nocounter, separator = " ", format
 ;end select
 SELECT INTO "NL:"
  FROM prsnl p
  PLAN (p
   WHERE p.person_id=prsnlid2
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   positioncd = p.position_cd, ptreply->positioncd = p.position_cd, ptreply->prsnlid = p.person_id,
   CALL echo(build("position:",uar_get_code_display(p.position_cd)))
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM app_prefs a,
   name_value_prefs n
  PLAN (a
   WHERE a.position_cd=positioncd
    AND a.application_number=appid2)
   JOIN (n
   WHERE a.app_prefs_id=n.parent_entity_id
    AND n.pvc_name="DEFAULT_VIEWS")
  HEAD REPORT
   tabnumstrg = trim(n.pvc_value), strsize = size(tabnumstrg,1), commapos = findstring(",",tabnumstrg,
    1,0)
   IF (commapos=0)
    tabdefnumstring = "1"
   ELSE
    tabdefnumstring = substring((commapos+ 1),strsize,tabnumstrg), tabdefnumint = cnvtint(
     tabdefnumstring), tabdefnumint = (tabdefnumint+ 1),
    tabdefnumstring = cnvtstring(tabdefnumint)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM name_value_prefs n,
   view_prefs v,
   name_value_prefs n1
  PLAN (n
   WHERE n.pvc_name="DISPLAY_SEQ"
    AND n.pvc_value=tabdefnumstring)
   JOIN (v
   WHERE v.view_prefs_id=n.parent_entity_id
    AND v.position_cd=positioncd
    AND v.application_number=appid2
    AND v.frame_type="CHART")
   JOIN (n1
   WHERE n1.parent_entity_id=v.view_prefs_id
    AND n1.pvc_name="VIEW_CAPTION")
  HEAD REPORT
   viewprefid = v.view_prefs_id, ptreply->viewprefsid = v.view_prefs_id, ptreply->tabname = trim(n1
    .pvc_value)
  WITH nocounter
 ;end select
 FREE RECORD ptreply2
#exit_script
 CALL echo("SCRIPT VERSION IS 006 09/27/2011 Allison Wynn adding default tab for user")
 IF (validate(_memory_reply_string)=1)
  SET _memory_reply_string = cnvtrectojson(ptreply)
 ELSE
  CALL echojson(ptreply, $1)
 ENDIF
END GO
