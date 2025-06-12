CREATE PROGRAM dc_mp_get_pc
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
 FREE RECORD br_setting
 RECORD br_setting(
   1 filters[*]
     2 filter_mean = vc
     2 filter_display = vc
     2 items[*]
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 value_seq = i4
       3 group_seq = i4
       3 free_text_desc = vc
       3 value_type_flag = i2
       3 qualifier_flag = i2
       3 logical_domain_id = f8
 )
 FREE RECORD emeas_setting
 RECORD emeas_setting(
   1 filters[*]
     2 filter_mean = vc
     2 filter_display = vc
     2 items[*]
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 value_seq = i4
       3 group_seq = i4
       3 free_text_desc = vc
       3 value_type_flag = i2
       3 qualifier_flag = i2
       3 logical_domain_id = f8
 )
 FREE RECORD iqr_setting
 RECORD iqr_setting(
   1 filters[*]
     2 filter_mean = vc
     2 filter_display = vc
     2 items[*]
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 value_seq = i4
       3 group_seq = i4
       3 free_text_desc = vc
       3 value_type_flag = i2
       3 qualifier_flag = i2
       3 logical_domain_id = f8
 )
 FREE RECORD tmp_outcomes
 RECORD tmp_outcomes(
   1 outcomes[*]
     2 condition_id = f8
     2 outcome_desc = vc
     2 meas_mean = vc
     2 complete_ind = i2
     2 hoverdisplay = vc
     2 showiconind = i2
     2 measures[*]
       3 delayditherind = i2
       3 oralfactordither = i2
       3 vancopresind = i2
       3 ditherpresamiind = i2
       3 dithermeasureind = i2
       3 name = vc
       3 measuremetind = i2
       3 contraind = i2
       3 ordersetind = i4
       3 orderpresentind = i4
       3 ordercd = f8
       3 ordercompletedisplay = vc
       3 orderincompletedisplay = vc
       3 ordertaskind = i2
       3 adminsetind = i4
       3 adminpresentind = i4
       3 admincompletedisplay = vc
       3 adminincompletedisplay = vc
       3 admintaskind = i2
       3 adminformid = f8
       3 admintabname = vc
       3 pressetind = i4
       3 prespresentind = i4
       3 prescompletedisplay = vc
       3 presincompletedisplay = vc
       3 prestaskind = i2
       3 docsetind = i2
       3 docpresentind = i2
       3 doccompletedisplay = vc
       3 docincompletedisplay = vc
       3 doctaskind = i2
       3 docformid = f8
       3 doctabname = vc
       3 colsetind = i2
       3 colpresentind = i2
       3 colcompletedisplay = vc
       3 colincompletedisplay = vc
       3 coltaskind = i2
       3 colformid = f8
       3 coltabname = vc
       3 orderdetailidx = i4
       3 admindetailidx = i4
       3 presdetailidx = i4
       3 docdetailidx = i4
       3 coldetailidx = i4
       3 contrataskidx = i4
       3 notactionablelabel = vc
     2 iview[*]
       3 measure_name = vc
       3 doc_iview_band = vc
       3 doc_iview_section = vc
       3 doc_iview_item = vc
 )
 DECLARE organizesequence(rec=vc(ref),cond_seq=vc(ref),cond_id=f8) = null WITH protect
 DECLARE getmpagesetting(flex_id=f8,logical_domain_id=f8,category_mean=vc,rec=vc(ref)) = null WITH
 protect
 SUBROUTINE getmpagesetting(flex_id,logical_domain_id,category_mean,rec)
   CALL lhprint("*** Start getMPageSetting subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE catstr = vc WITH constant(nullterm(concat("b.category_mean IN (",category_mean," )"))),
   protect
   DECLARE i = i2 WITH noconstant(0), protect
   FOR (i = 1 TO 2)
    SELECT INTO "nl:"
     FROM br_datamart_category b,
      br_datamart_filter bf,
      br_datamart_value bv
     PLAN (b
      WHERE parser(catstr)
       AND b.br_datamart_category_id > 0)
      JOIN (bf
      WHERE bf.br_datamart_category_id=b.br_datamart_category_id)
      JOIN (bv
      WHERE bv.br_datamart_filter_id=bf.br_datamart_filter_id
       AND bv.br_datamart_flex_id=flex_id
       AND bv.logical_domain_id=logical_domain_id)
     ORDER BY b.br_datamart_category_id, bf.br_datamart_filter_id, bv.br_datamart_value_id
     HEAD b.br_datamart_category_id
      filter_cnt = size(rec->filters,5)
     HEAD bf.br_datamart_filter_id
      filter_cnt = (filter_cnt+ 1)
      IF (size(rec->filters,5) < filter_cnt)
       stat = alterlist(rec->filters,(filter_cnt+ 49))
      ENDIF
      rec->filters[filter_cnt].filter_mean = bf.filter_mean, rec->filters[filter_cnt].filter_display
       = bf.filter_display, item_cnt = 0
     DETAIL
      item_cnt = (item_cnt+ 1)
      IF (mod(item_cnt,100)=1)
       stat = alterlist(rec->filters[filter_cnt].items,(item_cnt+ 99))
      ENDIF
      rec->filters[filter_cnt].items[item_cnt].parent_entity_id = bv.parent_entity_id, rec->filters[
      filter_cnt].items[item_cnt].parent_entity_name = bv.parent_entity_name, rec->filters[filter_cnt
      ].items[item_cnt].value_seq = bv.value_seq,
      rec->filters[filter_cnt].items[item_cnt].group_seq = bv.group_seq, rec->filters[filter_cnt].
      items[item_cnt].value_type_flag = bv.value_type_flag, rec->filters[filter_cnt].items[item_cnt].
      qualifier_flag = bv.qualifier_flag,
      rec->filters[filter_cnt].items[item_cnt].logical_domain_id = bv.logical_domain_id, rec->
      filters[filter_cnt].items[item_cnt].free_text_desc = bv.freetext_desc
     FOOT  bf.br_datamart_filter_id
      stat = alterlist(rec->filters[filter_cnt].items,item_cnt)
     FOOT  b.br_datamart_category_id
      stat = alterlist(rec->filters,filter_cnt)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET i = 3
    ELSE
     SET flex_id = 0.0
    ENDIF
   ENDFOR
   CALL lhelapsedtime("getMPageSetting",begin_dt_tm)
 END ;Subroutine
 SUBROUTINE organizesequence(rec,cond_seq,cond_id)
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE seq_cnt = i4 WITH noconstant(0), protect
   DECLARE copyfrompos = i4 WITH noconstant(0), protect
   DECLARE copybackpos = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   FOR (cnt = 1 TO size(rec->patients,5))
     SET stat = initrec(tmp_outcomes)
     SET stat = alterlist(tmp_outcomes->outcomes,size(cond_seq->seq,5))
     FOR (seq_cnt = 1 TO size(cond_seq->seq,5))
      SET copyfrompos = locateval(idx,1,size(rec->patients[cnt].outcomes,5),cond_seq->seq[seq_cnt].
       meas_mean,rec->patients[cnt].outcomes[idx].meas_mean,
       cond_id,rec->patients[cnt].outcomes[idx].condition_id)
      IF (copyfrompos > 0)
       SET tmp_outcomes->outcomes[seq_cnt].condition_id = rec->patients[cnt].outcomes[copyfrompos].
       condition_id
       SET tmp_outcomes->outcomes[seq_cnt].outcome_desc = rec->patients[cnt].outcomes[copyfrompos].
       outcome_desc
       SET tmp_outcomes->outcomes[seq_cnt].meas_mean = rec->patients[cnt].outcomes[copyfrompos].
       meas_mean
       SET tmp_outcomes->outcomes[seq_cnt].complete_ind = rec->patients[cnt].outcomes[copyfrompos].
       complete_ind
       SET tmp_outcomes->outcomes[seq_cnt].hoverdisplay = rec->patients[cnt].outcomes[copyfrompos].
       hoverdisplay
       SET tmp_outcomes->outcomes[seq_cnt].showiconind = rec->patients[cnt].outcomes[copyfrompos].
       showiconind
       SET stat = moverec(rec->patients[cnt].outcomes[copyfrompos].measures,tmp_outcomes->outcomes[
        seq_cnt].measures)
       IF (validate(rec->patients[cnt].outcomes[copyfrompos].iview) > 0
        AND validate(tmp_outcomes->outcomes[seq_cnt].iview) > 0)
        SET stat = moverec(rec->patients[cnt].outcomes[copyfrompos].iview,tmp_outcomes->outcomes[
         seq_cnt].iview)
       ENDIF
      ENDIF
     ENDFOR
     SET start_idx = 1
     FOR (seq_cnt = 1 TO size(tmp_outcomes->outcomes,5))
      IF ((tmp_outcomes->outcomes[seq_cnt].condition_id != 0.0))
       SET copybackpos = locateval(idx,start_idx,size(rec->patients[cnt].outcomes,5),tmp_outcomes->
        outcomes[seq_cnt].condition_id,rec->patients[cnt].outcomes[idx].condition_id)
       IF (copybackpos > 0)
        SET rec->patients[cnt].outcomes[copybackpos].condition_id = tmp_outcomes->outcomes[seq_cnt].
        condition_id
        SET rec->patients[cnt].outcomes[copybackpos].outcome_desc = tmp_outcomes->outcomes[seq_cnt].
        outcome_desc
        SET rec->patients[cnt].outcomes[copybackpos].meas_mean = tmp_outcomes->outcomes[seq_cnt].
        meas_mean
        SET rec->patients[cnt].outcomes[copybackpos].complete_ind = tmp_outcomes->outcomes[seq_cnt].
        complete_ind
        SET rec->patients[cnt].outcomes[copybackpos].hoverdisplay = tmp_outcomes->outcomes[seq_cnt].
        hoverdisplay
        SET rec->patients[cnt].outcomes[copybackpos].showiconind = tmp_outcomes->outcomes[seq_cnt].
        showiconind
        SET stat = moverec(tmp_outcomes->outcomes[seq_cnt].measures,rec->patients[cnt].outcomes[
         copybackpos].measures)
        IF (validate(rec->patients[cnt].outcomes[copybackpos].iview) > 0
         AND validate(tmp_outcomes->outcomes[seq_cnt].iview) > 0)
         SET stat = moverec(tmp_outcomes->outcomes[seq_cnt].iview,rec->patients[cnt].outcomes[
          copybackpos].iview)
        ENDIF
       ENDIF
      ENDIF
      SET start_idx = (copybackpos+ 1)
     ENDFOR
   ENDFOR
   CALL lhprint(build(";organizeSequence Process time: ",datetimediff(cnvtdatetime(curdate,curtime3),
      begin_dt_tm,5)))
 END ;Subroutine
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
 DECLARE ver_num1 = vc WITH protect, constant(iqrversioncontrolstring("PCN",cnvtdatetime(curdate,
    curtime3)))
 DECLARE ver_num2 = vc WITH protect, constant(iqrversioncontrolstring("PCB",cnvtdatetime(curdate,
    curtime3)))
 DECLARE ver_num3 = vc WITH protect, constant(iqrversioncontrolstring("PCM",cnvtdatetime(curdate,
    curtime3)))
 DECLARE ver_num4 = vc WITH protect, constant(iqrversioncontrolstring("PCU",cnvtdatetime(curdate,
    curtime3)))
 DECLARE currentdttm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), protect
 DECLARE emeasversion = i4 WITH constant(emeasversioncontrol("MU_CQM_EH_PCM",currentdttm)), protect
 DECLARE emeasversionbaby = i4 WITH constant(emeasversioncontrol("MU_CQM_EH_PC_",currentdttm)),
 protect
 DECLARE elapsetm = vc WITH protect
 IF (( $2 != null))
  SET jrec = cnvtjsontorec( $2)
  IF (validate(debug_dc_mp_get_pc_ind,0)=1)
   CALL echo("This is the converted json string to record")
   CALL echorecord(qmreq)
  ENDIF
 ENDIF
 DECLARE _positioncd = f8 WITH constant(getpositioncd(cnvtreal(qmreq->prsnlid))), protect
 DECLARE _logicaldomainid = f8 WITH constant(getdomainid(cnvtreal(qmreq->prsnlid))), protect
 DECLARE _flexid = f8 WITH constant(getflexid(_positioncd)), protect
 DECLARE combinedviewtype = i2 WITH constant(getcombinedviewtypestring(ver_num3,emeasversion,
   "MP_QM_PC","MP_QM_EPC",_flexid,
   _logicaldomainid)), protect
 DECLARE iqrvenuedefined = i2 WITH constant(checkvenuedefined(_flexid,_logicaldomainid,"MP_QM_PC")),
 protect
 DECLARE emeasvenuedefined = i2 WITH constant(checkvenuedefined(_flexid,_logicaldomainid,"MP_QM_EPC")
  ), protect
 IF (validate(debug_dc_mp_get_pc_ind,0)=1)
  CALL echo(build("prsnl ID --->",qmreq->prsnlid))
  CALL echo(build("position CD --->",_positioncd))
  CALL echo(build("logical domain ID --->",_logicaldomainid))
  CALL echo(build("flex ID --->",_flexid))
  CALL lhprint(build("prsnl ID --->",qmreq->prsnlid))
  CALL lhprint(build("position CD --->",_positioncd))
  CALL lhprint(build("logical domain ID --->",_logicaldomainid))
  CALL lhprint(build("flex ID --->",_flexid))
 ENDIF
 DECLARE epcombined = i2 WITH noconstant(0), protect
 DECLARE min_version = vc WITH protect, noconstant("")
 SET min_version = "5.10"
 IF (emeasversion >= 2021
  AND emeasversionbaby >= 2021
  AND ((versioncheck(ver_num3,min_version)=1
  AND ver_num1=ver_num3
  AND ver_num3=ver_num4) OR (ver_num3="")) )
  SET epcombined = 1
 ELSE
  SET epcombined = 0
 ENDIF
 IF (epcombined=1)
  IF (checkdic("LH_MP_COMBINE_ORG_PC","P",0) > 0)
   EXECUTE lh_mp_combine_org_pc  WITH replace("REQUEST",qmreq), replace("REPLY",pcreply), replace(
    "FLEXID",_flexid),
   replace("DOMAINID",_logicaldomainid), replace("PC_IQR_IND",iqrvenuedefined), replace(
    "PC_EMEAS_IND",emeasvenuedefined)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (epcombined=0)
  IF (checkemeasureenabled(_flexid,_logicaldomainid,"MP_QM_EPC")=1)
   IF (emeasversion=2015
    AND checkdic("LH_MP_ORG_E_PC","P",0) > 0)
    EXECUTE lh_mp_org_e_pc  WITH replace("REQUEST",qmreq), replace("REPLY",pcreply), replace("FLEXID",
     _flexid),
    replace("DOMAINID",_logicaldomainid)
    GO TO exit_script
   ELSEIF (emeasversion=2016
    AND checkdic("LH_MP_ORG_E_PC_2016","P",0) > 0)
    EXECUTE lh_mp_org_e_pc_2016  WITH replace("REQUEST",qmreq), replace("REPLY",pcreply), replace(
     "FLEXID",_flexid),
    replace("DOMAINID",_logicaldomainid)
    GO TO exit_script
   ELSEIF (emeasversion >= 2017
    AND checkdic("LH_MP_ORG_EPC","P",0) > 0)
    EXECUTE lh_mp_org_epc  WITH replace("REQUEST",qmreq), replace("REPLY",pcreply), replace("FLEXID",
     _flexid),
    replace("DOMAINID",_logicaldomainid)
    GO TO exit_script
   ENDIF
  ELSE
   SET stat = initrec(pcreply)
   IF (((versioncheck(ver_num1,cnvtstring(5.0,3,1))=1
    AND versioncheck(ver_num2,cnvtstring(5.0,3,1))=1
    AND versioncheck(ver_num3,cnvtstring(5.0,3,1))=1) OR (versioncheck(ver_num1,cnvtstring(5.7,3,1))
    >= 1
    AND versioncheck(ver_num3,cnvtstring(5.7,3,1))=1
    AND checkdic("LH_MP_ORGANIZER_PC","P",0) > 0)) )
    EXECUTE lh_mp_organizer_pc  WITH replace("REQUEST",qmreq), replace("REPLY",pcreply), replace(
     "FLEXID",_flexid),
    replace("DOMAINID",_logicaldomainid)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (validate(debug_dc_mp_get_pc_ind,0)=1)
  CALL echorecord(pcreply)
 ENDIF
 IF (validate(_memory_reply_string)=1)
  SET _memory_reply_string = cnvtrectojson(pcreply)
 ELSE
  CALL echojson(pcreply, $1)
 ENDIF
END GO
