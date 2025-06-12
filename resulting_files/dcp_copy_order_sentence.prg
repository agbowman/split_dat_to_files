CREATE PROGRAM dcp_copy_order_sentence
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 new_order_sent_id = f8
     2 orig_order_sent_id = f8
     2 order_sent_display = vc
     2 ord_comment_long_text_id = f8
     2 long_text = vc
     2 rx_type_mean = c12
     2 normalized_dose_unit_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD details(
   1 sentlist[*]
     2 order_sentence_id = f8
     2 order_sentence_display_line = vc
     2 oe_format_id = f8
     2 usage_flag = i2
     2 order_encntr_group_cd = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 parent_entity2_name = vc
     2 parent_entity2_id = f8
     2 ord_comment_long_text_id = f8
     2 long_text = vc
     2 rx_type_mean = c12
     2 normalized_dose_unit_ind = i2
     2 list[*]
       3 sequence = i4
       3 oe_field_id = f8
       3 oe_field_value = f8
       3 oe_field_display_value = vc
       3 oe_field_meaning_id = f8
       3 field_type_flag = i2
       3 default_parent_entity_name = c32
       3 default_parent_entity_id = f8
 )
 FREE RECORD request_get_ord_sent_filter
 RECORD request_get_ord_sent_filter(
   1 order_sentences[*]
     2 order_sentence_id = f8
     2 orde_sentence_index = i4
     2 order_sentence_filters[*]
       3 order_sentence_filter_id = f8
       3 order_sentence_filter_display = vc
       3 age_range_filter[*]
         4 minimum = i4
         4 maximum = i4
         4 unit_cd = f8
       3 postmenstrual_age_range_filter[*]
         4 minimum = i4
         4 maximum = i4
         4 unit_cd = f8
       3 weight_range_filter[*]
         4 minimum = f8
         4 maximum = f8
         4 unit_cd = f8
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
 )
 DECLARE verifynotnull(hinstance=i4) = i2
 SUBROUTINE verifynotnull(hinstance)
   IF (hinstance=0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE srvdestroyinstancewithnullcheck(hinstance=i4) = null
 SUBROUTINE srvdestroyinstancewithnullcheck(hinstance)
   IF (hinstance != 0)
    CALL uar_srvdestroyinstance(hinstance)
   ENDIF
 END ;Subroutine
 DECLARE queryordersentencefiltersbyordersentenceids(request_get_ord_sent_filter=vc(ref)) = i2
 SUBROUTINE queryordersentencefiltersbyordersentenceids(request_get_ord_sent_filter)
   DECLARE stat = i2 WITH protect, noconstant(0)
   DECLARE hmessage = i4 WITH protect, noconstant(0)
   DECLARE hrequest = i4 WITH protect, noconstant(0)
   DECLARE hreply_get_ord_sent_filter = i4 WITH protect, noconstant(0)
   EXECUTE crmrtl
   EXECUTE srvrtl
   SET hmessage = uar_srvselect("QueryOrderSentenceFiltersByOrderSentenceIds")
   IF (verifynotnull(hmessage)=0)
    CALL srvdestroyinstancewithnullcheck(hrequest)
    CALL srvdestroyinstancewithnullcheck(hreply_get_ord_sent_filter)
    CALL srvdestroyinstancewithnullcheck(hmessage)
    RETURN(0)
   ENDIF
   SET hrequest = uar_srvcreaterequest(hmessage)
   IF (verifynotnull(hrequest)=0)
    CALL srvdestroyinstancewithnullcheck(hrequest)
    CALL srvdestroyinstancewithnullcheck(hreply_get_ord_sent_filter)
    CALL srvdestroyinstancewithnullcheck(hmessage)
    RETURN(0)
   ENDIF
   SET hreply_get_ord_sent_filter = uar_srvcreatereply(hmessage)
   IF (verifynotnull(hreply_get_ord_sent_filter)=0)
    CALL srvdestroyinstancewithnullcheck(hrequest)
    CALL srvdestroyinstancewithnullcheck(hreply_get_ord_sent_filter)
    CALL srvdestroyinstancewithnullcheck(hmessage)
    RETURN(0)
   ENDIF
   IF (size(request_get_ord_sent_filter->order_sentences,5) > 0)
    DECLARE hordsentreq = i4 WITH protect, noconstant(0)
    FOR (iindex = 1 TO size(request_get_ord_sent_filter->order_sentences,5))
      SET hordsentreq = uar_srvadditem(hrequest,"order_sentences")
      CALL verifynotnull(hordsentreq)
      SET stat = uar_srvsetdouble(hordsentreq,"order_sentence_id",request_get_ord_sent_filter->
       order_sentences[iindex].order_sentence_id)
      CALL echo(build2("order sent id ",request_get_ord_sent_filter->order_sentences[iindex].
        order_sentence_id))
    ENDFOR
   ELSE
    RETURN(0)
   ENDIF
   IF (uar_srvexecute(hmessage,hrequest,hreply_get_ord_sent_filter) != 0)
    CALL srvdestroyinstancewithnullcheck(hrequest)
    CALL srvdestroyinstancewithnullcheck(hreply_get_ord_sent_filter)
    CALL srvdestroyinstancewithnullcheck(hmessage)
    RETURN(0)
   ENDIF
   DECLARE htransactionstatus = i4 WITH protect, noconstant(0)
   SET htransactionstatus = uar_srvgetstruct(hreply_get_ord_sent_filter,"transaction_status")
   IF (uar_srvgetshort(htransactionstatus,"success_ind")=0)
    CALL echo(build2("________________FAILED____________"),htransactionstatus)
    CALL srvdestroyinstancewithnullcheck(hrequest)
    CALL srvdestroyinstancewithnullcheck(hreply_get_ord_sent_filter)
    CALL srvdestroyinstancewithnullcheck(hmessage)
    RETURN(0)
   ENDIF
   DECLARE lnumberofordersent = i4 WITH protect, noconstant(0)
   DECLARE lordsentindex = i4 WITH protect, noconstant(0)
   DECLARE lnumberofordersentfilter = i4 WITH protect, noconstant(0)
   DECLARE lnumberofagefilter = i4 WITH protect, noconstant(0)
   DECLARE lnumberofpmafilter = i4 WITH protect, noconstant(0)
   DECLARE lnumberofwtfilter = i4 WITH protect, noconstant(0)
   DECLARE hordsentfilterage = i4 WITH protect, noconstant(0)
   DECLARE hordsentfilterpma = i4 WITH protect, noconstant(0)
   DECLARE hordsentfilterwt = i4 WITH protect, noconstant(0)
   DECLARE lordersentfilter = i4 WITH protect, noconstant(0)
   DECLARE hordsent = i4 WITH protect, noconstant(0)
   DECLARE htran = i4 WITH protect, noconstant(0)
   DECLARE hordsentfilter = i4 WITH protect, noconstant(0)
   DECLARE lsearchidx = i4 WITH protect
   DECLARE lidx = i4 WITH protect
   SET htran = uar_srvgetstruct(hreply_get_ord_sent_filter,"transaction_status")
   SET request_get_ord_sent_filter->transaction_status.debug_error_message = uar_srvgetstringptr(
    htran,"debug_error_message")
   SET request_get_ord_sent_filter->transaction_status.success_ind = uar_srvgetshort(htran,
    "success_ind")
   IF ((request_get_ord_sent_filter->transaction_status.success_ind=0))
    RETURN(0)
   ENDIF
   SET lnumberofordersent = uar_srvgetitemcount(hreply_get_ord_sent_filter,"order_sentences")
   FOR (lordsentindex = 1 TO lnumberofordersent)
     SET hordsent = uar_srvgetitem(hreply_get_ord_sent_filter,"order_sentences",(lordsentindex - 1))
     CALL verifynotnull(hordsent)
     SET lsearchidx = locateval(lidx,1,lnumberofordersent,uar_srvgetdouble(hordsent,
       "order_sentence_id"),request_get_ord_sent_filter->order_sentences[lidx].order_sentence_id)
     SET lnumberofordersentfilter = uar_srvgetitemcount(hordsent,"order_sentence_filters")
     SET stat = alterlist(request_get_ord_sent_filter->order_sentences[lsearchidx].
      order_sentence_filters,lnumberofordersentfilter)
     FOR (lordersentfilter = 1 TO lnumberofordersentfilter)
       SET hordsentfilter = uar_srvgetitem(hordsent,"order_sentence_filters",(lordersentfilter - 1))
       CALL verifynotnull(hordsentfilter)
       SET request_get_ord_sent_filter->order_sentences[lsearchidx].order_sentence_filters[
       lordersentfilter].order_sentence_filter_id = uar_srvgetdouble(hordsentfilter,
        "order_sentence_filter_id")
       SET request_get_ord_sent_filter->order_sentences[lsearchidx].order_sentence_filters[
       lordersentfilter].order_sentence_filter_display = uar_srvgetstringptr(hordsentfilter,
        "order_sentence_filter_display")
       SET lnumberofagefilter = uar_srvgetitemcount(hordsentfilter,"age_range_filter")
       IF (lnumberofagefilter != 0)
        SET hordsentfilterage = uar_srvgetitem(hordsentfilter,"age_range_filter",(lnumberofagefilter
          - 1))
        SET stat = alterlist(request_get_ord_sent_filter->order_sentences[lsearchidx].
         order_sentence_filters[lordersentfilter].age_range_filter,lnumberofagefilter)
        SET request_get_ord_sent_filter->order_sentences[lsearchidx].order_sentence_filters[
        lordersentfilter].age_range_filter[lnumberofagefilter].minimum = uar_srvgetlong(
         hordsentfilterage,"minimum")
        SET request_get_ord_sent_filter->order_sentences[lsearchidx].order_sentence_filters[
        lordersentfilter].age_range_filter[lnumberofagefilter].maximum = uar_srvgetlong(
         hordsentfilterage,"maximum")
        SET request_get_ord_sent_filter->order_sentences[lsearchidx].order_sentence_filters[
        lordersentfilter].age_range_filter[lnumberofagefilter].unit_cd = uar_srvgetdouble(
         hordsentfilterage,"unit_cd")
       ENDIF
       SET lnumberofpmafilter = uar_srvgetitemcount(hordsentfilter,"postmenstrual_age_range_filter")
       IF (lnumberofpmafilter != 0)
        SET hordsentfilterpma = uar_srvgetitem(hordsentfilter,"postmenstrual_age_range_filter",(
         lnumberofpmafilter - 1))
        SET stat = alterlist(request_get_ord_sent_filter->order_sentences[lsearchidx].
         order_sentence_filters[lordersentfilter].postmenstrual_age_range_filter,lnumberofpmafilter)
        SET request_get_ord_sent_filter->order_sentences[lsearchidx].order_sentence_filters[
        lordersentfilter].postmenstrual_age_range_filter[lnumberofpmafilter].minimum = uar_srvgetlong
        (hordsentfilterpma,"minimum")
        SET request_get_ord_sent_filter->order_sentences[lsearchidx].order_sentence_filters[
        lordersentfilter].postmenstrual_age_range_filter[lnumberofpmafilter].maximum = uar_srvgetlong
        (hordsentfilterpma,"maximum")
        SET request_get_ord_sent_filter->order_sentences[lsearchidx].order_sentence_filters[
        lordersentfilter].postmenstrual_age_range_filter[lnumberofpmafilter].unit_cd =
        uar_srvgetdouble(hordsentfilterpma,"unit_cd")
       ENDIF
       SET lnumberofwtfilter = uar_srvgetitemcount(hordsentfilter,"weight_range_filter")
       IF (lnumberofwtfilter != 0)
        SET hordsentfilterwt = uar_srvgetitem(hordsentfilter,"weight_range_filter",(lnumberofwtfilter
          - 1))
        SET stat = alterlist(request_get_ord_sent_filter->order_sentences[lsearchidx].
         order_sentence_filters[lordersentfilter].weight_range_filter,lnumberofwtfilter)
        SET request_get_ord_sent_filter->order_sentences[lsearchidx].order_sentence_filters[
        lordersentfilter].weight_range_filter[lnumberofwtfilter].minimum = uar_srvgetdouble(
         hordsentfilterwt,"minimum")
        SET request_get_ord_sent_filter->order_sentences[lsearchidx].order_sentence_filters[
        lordersentfilter].weight_range_filter[lnumberofwtfilter].maximum = uar_srvgetdouble(
         hordsentfilterwt,"maximum")
        SET request_get_ord_sent_filter->order_sentences[lsearchidx].order_sentence_filters[
        lordersentfilter].weight_range_filter[lnumberofwtfilter].unit_cd = uar_srvgetdouble(
         hordsentfilterwt,"unit_cd")
       ENDIF
     ENDFOR
   ENDFOR
   CALL srvdestroyinstancewithnullcheck(hrequest)
   CALL srvdestroyinstancewithnullcheck(hreply_get_ord_sent_filter)
   CALL srvdestroyinstancewithnullcheck(hmessage)
   RETURN(1)
 END ;Subroutine
 RECORD local_request_get_ord_sent_filters(
   1 order_sentences[*]
     2 order_sentence_id = f8
     2 new_order_sentence_id = f8
     2 order_sentence_filters[*]
       3 order_sentence_filter_id = f8
       3 order_sentence_filter_display = vc
       3 age_range_filter[*]
         4 minimum = i4
         4 maximum = i4
         4 unit_cd = f8
       3 postmenstrual_age_range_filter[*]
         4 minimum = i4
         4 maximum = i4
         4 unit_cd = f8
       3 weight_range_filter[*]
         4 minimum = f8
         4 maximum = f8
         4 unit_cd = f8
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
 )
 RECORD local_add_os_filters(
   1 adding_personnel_id = f8
   1 order_sentences[*]
     2 order_sentence_id = f8
     2 order_sentence_filters[*]
       3 age_range_filter[*]
         4 minimum = i4
         4 maximum = i4
         4 unit_cd = f8
       3 postmenstrual_age_range_filter[*]
         4 minimum = i4
         4 maximum = i4
         4 unit_cd = f8
       3 weight_range_filter[*]
         4 minimum = f8
         4 maximum = f8
         4 unit_cd = f8
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
 )
 EXECUTE crmrtl
 EXECUTE srvrtl
 DECLARE addordersentencefilters(orm_add_order_sentence_filters_record=vc(ref)) = i2
 SUBROUTINE addordersentencefilters(orm_add_order_sentence_filters_record)
   DECLARE oscnt = i4 WITH protect, noconstant(0)
   DECLARE osfiltercnt = i4 WITH protect, noconstant(0)
   DECLARE dunitcddays = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"DAYS"))
   DECLARE dunitcdweeks = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"WEEKS"))
   DECLARE dunitcdmonths = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"MONTHS"))
   DECLARE dunitcdyears = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"YEARS"))
   DECLARE dunitcdlb = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"LB"))
   DECLARE dunitcdoz = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"OZ"))
   DECLARE dunitcdkg = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"KG"))
   DECLARE dunitcdgm = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"GM"))
   SET oscnt = size(orm_add_order_sentence_filters_record->order_sentences,5)
   FOR (n = 1 TO oscnt)
    SET osfiltercnt = size(orm_add_order_sentence_filters_record->order_sentences[n].
     order_sentence_filters,5)
    FOR (osfcount = 1 TO osfiltercnt)
      DECLARE ordersentencefilterid = f8 WITH protect, noconstant(0.0)
      DECLARE iagemaxvalue = i4 WITH protect, noconstant(0)
      DECLARE iageminvalue = i4 WITH protect, noconstant(0)
      DECLARE dageunitcd = f8 WITH protect, noconstant(0)
      DECLARE ipmamaxvalue = i4 WITH protect, noconstant(0)
      DECLARE ipmaminvalue = i4 WITH protect, noconstant(0)
      DECLARE dpmaunitcd = f8 WITH protect, noconstant(0)
      DECLARE dwtmaxvalue = f8 WITH protect, noconstant(0)
      DECLARE dwtminvalue = f8 WITH protect, noconstant(0)
      DECLARE dwtunitcd = f8 WITH protect, noconstant(0)
      DECLARE bagerangeflag = i2 WITH protect, noconstant(1)
      DECLARE bpmarangeflag = i2 WITH protect, noconstant(1)
      DECLARE bwtrangeflag = i2 WITH protect, noconstant(1)
      DECLARE iagerangecnt = i4 WITH protect, noconstant(0)
      DECLARE ipmarangecnt = i4 WITH protect, noconstant(0)
      DECLARE iwtrangecnt = i4 WITH protect, noconstant(0)
      SET iagerangecnt = size(orm_add_order_sentence_filters_record->order_sentences[n].
       order_sentence_filters[osfcount].age_range_filter,5)
      SET ipmarangecnt = size(orm_add_order_sentence_filters_record->order_sentences[n].
       order_sentence_filters[osfcount].postmenstrual_age_range_filter,5)
      SET iwtrangecnt = size(orm_add_order_sentence_filters_record->order_sentences[n].
       order_sentence_filters[osfcount].weight_range_filter,5)
      IF (iagerangecnt <= 0
       AND ipmarangecnt <= 0
       AND iwtrangecnt <= 0)
       SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 0
       RETURN(0)
      ENDIF
      IF (iagerangecnt > 0)
       SET iageminvalue = orm_add_order_sentence_filters_record->order_sentences[n].
       order_sentence_filters[osfcount].age_range_filter[1].minimum
       SET iagemaxvalue = orm_add_order_sentence_filters_record->order_sentences[n].
       order_sentence_filters[osfcount].age_range_filter[1].maximum
       SET dageunitcd = orm_add_order_sentence_filters_record->order_sentences[n].
       order_sentence_filters[osfcount].age_range_filter[1].unit_cd
       IF (dageunitcd IN (dunitcddays, dunitcdweeks, dunitcdmonths, dunitcdyears))
        IF (iageminvalue > 0
         AND iagemaxvalue > 0
         AND iageminvalue > iagemaxvalue)
         SET bagerangeflag = 0
         SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 0
         RETURN(0)
        ELSEIF (iageminvalue <= 0
         AND iagemaxvalue <= 0)
         SET bagerangeflag = 0
         SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 0
         RETURN(0)
        ENDIF
       ELSE
        SET bagerangeflag = 0
        SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 0
        RETURN(0)
       ENDIF
      ENDIF
      IF (ipmarangecnt > 0)
       SET ipmaminvalue = orm_add_order_sentence_filters_record->order_sentences[n].
       order_sentence_filters[osfcount].postmenstrual_age_range_filter[1].minimum
       SET ipmamaxvalue = orm_add_order_sentence_filters_record->order_sentences[n].
       order_sentence_filters[osfcount].postmenstrual_age_range_filter[1].maximum
       SET dpmaunitcd = orm_add_order_sentence_filters_record->order_sentences[n].
       order_sentence_filters[osfcount].postmenstrual_age_range_filter[1].unit_cd
       IF (dpmaunitcd IN (dunitcddays, dunitcdweeks))
        IF (ipmaminvalue > 0
         AND ipmamaxvalue > 0
         AND ipmaminvalue > ipmamaxvalue)
         SET bpmarangeflag = 0
         SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 0
         RETURN(0)
        ELSEIF (ipmaminvalue <= 0
         AND ipmamaxvalue <= 0)
         SET bpmarangeflag = 0
         SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 0
         RETURN(0)
        ENDIF
       ELSE
        SET bpmarangeflag = 0
        SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 0
        RETURN(0)
       ENDIF
      ENDIF
      IF (iwtrangecnt > 0)
       SET dwtminvalue = orm_add_order_sentence_filters_record->order_sentences[n].
       order_sentence_filters[osfcount].weight_range_filter[1].minimum
       SET dwtmaxvalue = orm_add_order_sentence_filters_record->order_sentences[n].
       order_sentence_filters[osfcount].weight_range_filter[1].maximum
       SET dwtunitcd = orm_add_order_sentence_filters_record->order_sentences[n].
       order_sentence_filters[osfcount].weight_range_filter[1].unit_cd
       IF (dwtunitcd IN (dunitcdlb, dunitcdoz, dunitcdkg, dunitcdgm))
        IF (dwtminvalue > 0
         AND dwtmaxvalue > 0
         AND dwtminvalue > dwtmaxvalue)
         SET bwtrangeflag = 0
         SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 0
         RETURN(0)
        ELSEIF (dwtminvalue <= 0
         AND dwtmaxvalue <= 0)
         SET bwtrangeflag = 0
         SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 0
         RETURN(0)
        ENDIF
       ELSE
        SET bwtrangeflag = 0
        SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 0
        RETURN(0)
       ENDIF
      ENDIF
      IF (bagerangeflag=1
       AND bpmarangeflag=1
       AND bwtrangeflag=1)
       SELECT INTO "nl:"
        gen_next_filter_id = seq(reference_seq,nextval)
        FROM dual
        DETAIL
         ordersentencefilterid = gen_next_filter_id
        WITH nocounter
       ;end select
       INSERT  FROM order_sentence_filter osf
        SET osf.order_sentence_id = orm_add_order_sentence_filters_record->order_sentences[n].
         order_sentence_id, osf.order_sentence_filter_id = ordersentencefilterid, osf.age_min_value
          = iageminvalue,
         osf.age_max_value = iagemaxvalue, osf.age_unit_cd = dageunitcd, osf.pma_min_value =
         ipmaminvalue,
         osf.pma_max_value = ipmamaxvalue, osf.pma_unit_cd = dpmaunitcd, osf.weight_min_value =
         dwtminvalue,
         osf.weight_max_value = dwtmaxvalue, osf.weight_unit_cd = dwtunitcd, osf.updt_dt_tm =
         cnvtdatetime(curdate,curtime3),
         osf.updt_id = orm_add_order_sentence_filters_record->adding_personnel_id, osf.updt_applctx
          = reqinfo->updt_applctx, osf.updt_cnt = 0,
         osf.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET failed = "T"
        CALL echo("Failed to insert into the order_sentence_filter table.")
        SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 0
        RETURN(0)
       ELSE
        SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 1
       ENDIF
      ELSE
       CALL echo("Failed to insert into the order_sentence_filter table.")
       SET orm_add_order_sentence_filters_record->transaction_status.success_ind = 0
       RETURN(0)
      ENDIF
    ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 DECLARE cfailed = c1 WITH protect, noconstant("F")
 DECLARE cloadlongtext = c1 WITH protect, noconstant("N")
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE n = i4 WITH protect, noconstant(0)
 DECLARE l = i4 WITH protect, noconstant(0)
 DECLARE detailcnt = i4 WITH protect, noconstant(0)
 DECLARE sentcnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE ordsent_cnt = i4 WITH noconstant(value(size(request->qual,5)))
 DECLARE strengthdoseunitid = f8 WITH protect, noconstant(0.0)
 DECLARE volumedoseunitid = f8 WITH protect, noconstant(0.0)
 DECLARE fieldvalueint = i4 WITH protect, noconstant(0)
 DECLARE osf_cnt = i4 WITH noconstant(0)
 DECLARE return_stat = i2 WITH noconstant(0)
 RECORD sent_request(
   1 id_count = i2
   1 comp_type_meaning = c12
 )
 RECORD sent_reply(
   1 id_list[*]
     2 id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF (validate(request->pathway_comp_id,0)=0)
  CALL report_failure("INSERT","F","DCP_COPY_ORDER_SENTENCE",
   "Missing a valid pathway_comp_id in the script request")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM oe_field_meaning ofm
  WHERE ofm.oe_field_meaning IN ("STRENGTHDOSEUNIT", "VOLUMEDOSEUNIT")
  DETAIL
   IF (ofm.oe_field_meaning="STRENGTHDOSEUNIT")
    strengthdoseunitid = ofm.oe_field_meaning_id
   ELSEIF (ofm.oe_field_meaning="VOLUMEDOSEUNIT")
    volumedoseunitid = ofm.oe_field_meaning_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_sentence os,
   order_sentence_detail osd,
   code_value_extension cve
  PLAN (os
   WHERE expand(i,1,ordsent_cnt,os.order_sentence_id,request->qual[i].order_sent_id))
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
   JOIN (cve
   WHERE cve.code_value=outerjoin(osd.default_parent_entity_id)
    AND cve.field_name=outerjoin("PHARM_UNIT")
    AND cve.code_set=outerjoin(54))
  ORDER BY os.order_sentence_id, osd.sequence
  HEAD REPORT
   sentcnt = 0
  HEAD os.order_sentence_id
   sentcnt = (sentcnt+ 1)
   IF (sentcnt > value(size(details->sentlist,5)))
    stat = alterlist(details->sentlist,(sentcnt+ 10))
   ENDIF
   detailcnt = 0, details->sentlist[sentcnt].order_sentence_id = os.order_sentence_id, details->
   sentlist[sentcnt].order_sentence_display_line = trim(os.order_sentence_display_line),
   details->sentlist[sentcnt].oe_format_id = os.oe_format_id, details->sentlist[sentcnt].usage_flag
    = os.usage_flag, details->sentlist[sentcnt].order_encntr_group_cd = os.order_encntr_group_cd,
   details->sentlist[sentcnt].parent_entity_name = "PATHWAY_COMP", details->sentlist[sentcnt].
   parent_entity_id = request->pathway_comp_id
   IF (os.parent_entity_name="PATHWAY_COMP"
    AND os.parent_entity2_name="ORDER_CATALOG_SYNONYM")
    details->sentlist[sentcnt].parent_entity2_name = trim(os.parent_entity2_name), details->sentlist[
    sentcnt].parent_entity2_id = os.parent_entity2_id
   ELSE
    details->sentlist[sentcnt].parent_entity2_name = " ", details->sentlist[sentcnt].
    parent_entity2_id = 0
   ENDIF
   details->sentlist[sentcnt].ord_comment_long_text_id = os.ord_comment_long_text_id
   IF (os.ord_comment_long_text_id > 0)
    cloadlongtext = "Y"
   ENDIF
   details->sentlist[sentcnt].rx_type_mean = os.rx_type_mean
  DETAIL
   detailcnt = (detailcnt+ 1)
   IF (detailcnt > value(size(details->sentlist[sentcnt].list,5)))
    stat = alterlist(details->sentlist[sentcnt].list,(detailcnt+ 10))
   ENDIF
   IF (osd.oe_field_meaning_id IN (strengthdoseunitid, volumedoseunitid))
    IF (osd.default_parent_entity_name="CODE_VALUE")
     fieldvalueint = cnvtint(cve.field_value)
     IF (band(fieldvalueint,32)=32)
      details->sentlist[sentcnt].normalized_dose_unit_ind = 1
     ENDIF
    ENDIF
   ENDIF
   details->sentlist[sentcnt].list[detailcnt].sequence = osd.sequence, details->sentlist[sentcnt].
   list[detailcnt].oe_field_id = osd.oe_field_id, details->sentlist[sentcnt].list[detailcnt].
   oe_field_value = osd.oe_field_value,
   details->sentlist[sentcnt].list[detailcnt].oe_field_display_value = osd.oe_field_display_value,
   details->sentlist[sentcnt].list[detailcnt].oe_field_meaning_id = osd.oe_field_meaning_id, details
   ->sentlist[sentcnt].list[detailcnt].field_type_flag = osd.field_type_flag,
   details->sentlist[sentcnt].list[detailcnt].default_parent_entity_name = osd
   .default_parent_entity_name, details->sentlist[sentcnt].list[detailcnt].default_parent_entity_id
    = osd.default_parent_entity_id
  FOOT  os.order_sentence_id
   stat = alterlist(details->sentlist[sentcnt].list,detailcnt)
  FOOT REPORT
   stat = alterlist(details->sentlist,sentcnt)
  WITH nocounter
 ;end select
 SET ordsent_cnt = value(size(details->sentlist,5))
 IF (cloadlongtext="Y")
  SELECT INTO "nl:"
   FROM long_text lt
   PLAN (lt
    WHERE expand(i,1,ordsent_cnt,lt.long_text_id,details->sentlist[i].ord_comment_long_text_id)
     AND lt.parent_entity_name="ORDER_SENTENCE"
     AND lt.active_ind=1)
   HEAD REPORT
    num = 0
   DETAIL
    idx = locateval(num,1,ordsent_cnt,lt.long_text_id,details->sentlist[num].ord_comment_long_text_id
     ), details->sentlist[idx].long_text = trim(lt.long_text)
   FOOT REPORT
    dummy = 0
   WITH nocounter
  ;end select
 ENDIF
 SET sent_request->id_count = ordsent_cnt
 SET modify = nopredeclare
 SET sent_request->comp_type_meaning = "PLAN REF"
 EXECUTE dcp_get_pw_comp_id  WITH replace("REQUEST","SENT_REQUEST"), replace("REPLY","SENT_REPLY")
 IF ((((sent_reply->status_data.status="F")) OR (value(size(sent_reply->id_list,5)) < ordsent_cnt)) )
  CALL report_failure("INSERT","F","DCP_COPY_ORDER_SENTENCE",
   "Unable to create the appropriate number of new id's")
  GO TO exit_script
 ENDIF
 SET modify = predeclare
 SET stat = alterlist(reply->qual,ordsent_cnt)
 SET stat = alterlist(local_request_get_ord_sent_filters->order_sentences,ordsent_cnt)
 FOR (n = 1 TO ordsent_cnt)
   SET long_text_id = 0.0
   IF ((details->sentlist[n].long_text > "")
    AND (details->sentlist[n].long_text != null))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      long_text_id = nextseqnum
     WITH nocounter
    ;end select
    IF (long_text_id=0.0)
     CALL report_failure("INSERT","F","DCP_COPY_ORDER_SENTENCE","Unable to create new long_text_id")
     GO TO exit_script
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = long_text_id, lt.parent_entity_name = "ORDER_SENTENCE", lt
      .parent_entity_id = sent_reply->id_list[n].id,
      lt.long_text = trim(details->sentlist[n].long_text), lt.active_ind = 1, lt.active_status_cd =
      reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_COPY_ORDER_SENTENCE","Unable to insert into LONG_TEXT")
     GO TO exit_script
    ENDIF
   ENDIF
   INSERT  FROM order_sentence os
    SET os.order_sentence_id = sent_reply->id_list[n].id, os.order_sentence_display_line = details->
     sentlist[n].order_sentence_display_line, os.oe_format_id = details->sentlist[n].oe_format_id,
     os.usage_flag = details->sentlist[n].usage_flag, os.order_encntr_group_cd = details->sentlist[n]
     .order_encntr_group_cd, os.parent_entity_name = details->sentlist[n].parent_entity_name,
     os.parent_entity_id = details->sentlist[n].parent_entity_id, os.parent_entity2_name = details->
     sentlist[n].parent_entity2_name, os.parent_entity2_id = details->sentlist[n].parent_entity2_id,
     os.ord_comment_long_text_id = long_text_id, os.rx_type_mean = details->sentlist[n].rx_type_mean,
     os.updt_dt_tm = cnvtdatetime(curdate,curtime),
     os.updt_id = reqinfo->updt_id, os.updt_task = reqinfo->updt_task, os.updt_applctx = reqinfo->
     updt_applctx,
     os.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_COPY_ORDER_SENTENCE","Unable to insert into order_sentence"
     )
    GO TO exit_script
   ENDIF
   SET detailcnt = value(size(details->sentlist[n].list,5))
   FOR (l = 1 TO detailcnt)
    INSERT  FROM order_sentence_detail osd
     SET osd.order_sentence_id = sent_reply->id_list[n].id, osd.sequence = details->sentlist[n].list[
      l].sequence, osd.oe_field_id = details->sentlist[n].list[l].oe_field_id,
      osd.oe_field_value = details->sentlist[n].list[l].oe_field_value, osd.oe_field_display_value =
      details->sentlist[n].list[l].oe_field_display_value, osd.oe_field_meaning_id = details->
      sentlist[n].list[l].oe_field_meaning_id,
      osd.field_type_flag = details->sentlist[n].list[l].field_type_flag, osd
      .default_parent_entity_name = details->sentlist[n].list[l].default_parent_entity_name, osd
      .default_parent_entity_id = details->sentlist[n].list[l].default_parent_entity_id,
      osd.updt_dt_tm = cnvtdatetime(curdate,curtime3), osd.updt_dt_tm = cnvtdatetime(curdate,curtime3
       ), osd.updt_id = reqinfo->updt_id,
      osd.updt_task = reqinfo->updt_task, osd.updt_applctx = reqinfo->updt_applctx, osd.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_COPY_ORDER_SENTENCE",
      "Unable to insert into order_sentence_detail")
     GO TO exit_script
    ENDIF
   ENDFOR
   SET reply->qual[n].new_order_sent_id = sent_reply->id_list[n].id
   SET reply->qual[n].orig_order_sent_id = details->sentlist[n].order_sentence_id
   SET reply->qual[n].order_sent_display = details->sentlist[n].order_sentence_display_line
   SET reply->qual[n].ord_comment_long_text_id = long_text_id
   SET reply->qual[n].long_text = details->sentlist[n].long_text
   SET reply->qual[n].rx_type_mean = details->sentlist[n].rx_type_mean
   SET reply->qual[n].normalized_dose_unit_ind = details->sentlist[n].normalized_dose_unit_ind
   SET local_request_get_ord_sent_filters->order_sentences[n].order_sentence_id = details->sentlist[n
   ].order_sentence_id
   SET local_request_get_ord_sent_filters->order_sentences[n].new_order_sentence_id = reply->qual[n].
   new_order_sent_id
 ENDFOR
 DECLARE child_filter_cnt = i4 WITH protect, noconstant(0)
 SET osf_cnt = 0
 IF (size(local_request_get_ord_sent_filters->order_sentences,5) > 0)
  SET return_stat = queryordersentencefiltersbyordersentenceids(local_request_get_ord_sent_filters)
  IF (return_stat != 0)
   FOR (i = 1 TO size(local_request_get_ord_sent_filters->order_sentences,5))
     IF (size(local_request_get_ord_sent_filters->order_sentences[i].order_sentence_filters,5)=1)
      SET osf_cnt = (osf_cnt+ 1)
      IF (osf_cnt > size(local_add_os_filters->order_sentences,5))
       SET stat = alterlist(local_add_os_filters->order_sentences,(osf_cnt+ 10))
      ENDIF
      SET stat = alterlist(local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters,1)
      SET local_add_os_filters->order_sentences[osf_cnt].order_sentence_id =
      local_request_get_ord_sent_filters->order_sentences[i].new_order_sentence_id
      SET child_filter_cnt = size(local_request_get_ord_sent_filters->order_sentences[i].
       order_sentence_filters[1].age_range_filter,5)
      IF (child_filter_cnt > 0)
       SET stat = alterlist(local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters[1].
        age_range_filter,child_filter_cnt)
       FOR (j = 1 TO child_filter_cnt)
         SET local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters[1].
         age_range_filter[j].minimum = local_request_get_ord_sent_filters->order_sentences[i].
         order_sentence_filters[1].age_range_filter[j].minimum
         SET local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters[1].
         age_range_filter[j].maximum = local_request_get_ord_sent_filters->order_sentences[i].
         order_sentence_filters[1].age_range_filter[j].maximum
         SET local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters[1].
         age_range_filter[j].unit_cd = local_request_get_ord_sent_filters->order_sentences[i].
         order_sentence_filters[1].age_range_filter[j].unit_cd
       ENDFOR
      ENDIF
      SET child_filter_cnt = size(local_request_get_ord_sent_filters->order_sentences[i].
       order_sentence_filters[1].postmenstrual_age_range_filter,5)
      IF (child_filter_cnt > 0)
       SET stat = alterlist(local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters[1].
        postmenstrual_age_range_filter,child_filter_cnt)
       FOR (j = 1 TO child_filter_cnt)
         SET local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters[1].
         postmenstrual_age_range_filter[j].minimum = local_request_get_ord_sent_filters->
         order_sentences[i].order_sentence_filters[1].postmenstrual_age_range_filter[j].minimum
         SET local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters[1].
         postmenstrual_age_range_filter[j].maximum = local_request_get_ord_sent_filters->
         order_sentences[i].order_sentence_filters[1].postmenstrual_age_range_filter[j].maximum
         SET local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters[1].
         postmenstrual_age_range_filter[j].unit_cd = local_request_get_ord_sent_filters->
         order_sentences[i].order_sentence_filters[1].postmenstrual_age_range_filter[j].unit_cd
       ENDFOR
      ENDIF
      SET child_filter_cnt = size(local_request_get_ord_sent_filters->order_sentences[i].
       order_sentence_filters[1].weight_range_filter,5)
      IF (child_filter_cnt > 0)
       SET stat = alterlist(local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters[1].
        weight_range_filter,child_filter_cnt)
       FOR (j = 1 TO child_filter_cnt)
         SET local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters[1].
         weight_range_filter[j].minimum = local_request_get_ord_sent_filters->order_sentences[i].
         order_sentence_filters[1].weight_range_filter[j].minimum
         SET local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters[1].
         weight_range_filter[j].maximum = local_request_get_ord_sent_filters->order_sentences[i].
         order_sentence_filters[1].weight_range_filter[j].maximum
         SET local_add_os_filters->order_sentences[osf_cnt].order_sentence_filters[1].
         weight_range_filter[j].unit_cd = local_request_get_ord_sent_filters->order_sentences[i].
         order_sentence_filters[1].weight_range_filter[j].unit_cd
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF (osf_cnt > 0)
  SET stat = alterlist(local_add_os_filters->order_sentences,osf_cnt)
 ENDIF
 IF (size(local_add_os_filters->order_sentences,5) > 0)
  SET local_add_os_filters->adding_personnel_id = reqinfo->updt_id
  SET stat = addordersentencefilters(local_add_os_filters)
  IF (stat <= 0)
   SET cfailed = "T"
   CALL echo("failed to insert into the order_sentence_filter table")
  ENDIF
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 FREE RECORD local_request_get_ord_sent_filters
 FREE RECORD local_add_os_filters
END GO
