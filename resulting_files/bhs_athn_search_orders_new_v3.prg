CREATE PROGRAM bhs_athn_search_orders_new_v3
 FREE RECORD result
 RECORD result(
   1 search_phrase = vc
   1 birth_dt_tm = dq8
   1 encntr_type_cd = f8
   1 facility_cd = f8
   1 patient_relationship_cd = f8
   1 clinical_category_codes[*]
     2 clinical_category_code = f8
     2 clinical_category_disp = vc
   1 orderables[*]
     2 synonym_id = f8
     2 display = vc
     2 source_string = vc
     2 catalog_cd = f8
     2 catalog_disp = vc
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 ref_text_mask = i4
     2 auto_invoke_prep_ind = i2
     2 has_multiple_order_sentences = i2
     2 text_type_cnt = i2
     2 oe_format_id = f8
     2 dcp_clin_cat_cd = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 orderable_type_flag = i4
     2 rx_mask = i4
     2 order_sentences[*]
       3 order_sentence_id = f8
       3 display_line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req680220
 RECORD req680220(
   1 search_phrase = vc
   1 suggestion_limit = i2
   1 personnel
     2 personnel_id = f8
     2 patient_provider_reltnship_cd = f8
   1 encounter[*]
     2 encounter_type_cd = f8
   1 facility[*]
     2 facility_id = f8
     2 filter_type
       3 virtual_view_ind = i2
       3 plan_virtual_view_ind = i2
       3 regimen_virtual_view_ind = i2
     2 formulary_filter[*]
       3 formulary_status_codes[*]
         4 formulary_status_cd = f8
   1 filter_by_venue
     2 inpatient_venue[*]
       3 content
         4 orderable_ind = i2
         4 plan_ind = i2
         4 regimen_ind = i2
     2 ambulatory_venue[*]
       3 content
         4 orderable_ind = i2
         4 plan_ind = i2
         4 regimen_ind = i2
       3 orderable_filters
         4 pharmacy_filters
           5 order_usage
             6 administration_ind = i2
             6 prescription_ind = i2
           5 filter_set[*]
             6 product_mnemonics_ind = i2
         4 advanced_virtual_view_filtering[*]
           5 apply_for_non_prescription_ind = i2
           5 apply_for_prescription_ind = i2
     2 prescription_venue[*]
       3 content
         4 orderable_ind = i2
       3 orderable_filters
         4 historical_ind = i2
         4 pharmacy_filters
           5 filter_set[*]
             6 product_mnemonics_ind = i2
   1 demographic_filter_criteria[*]
     2 agefilter[*]
       3 birthdate = dq8
       3 timezone = i4
       3 birth_age_hide_all_ind = i2
     2 weightfilter[*]
       3 weightvalue = f8
       3 weightcode = f8
       3 weight_hide_all_ind = i2
     2 pmafilter[*]
       3 pmavalue = i4
       3 pma_hide_all_ind = i2
   1 orderable_type_inclusions[*]
     2 normal_0_ind = i2
     2 normal_1_ind = i2
     2 supergroup_ind = i2
     2 orderset_ind = i2
     2 multi_ingredient_ind = i2
     2 freetext_ind = i2
     2 tpn_ind = i2
     2 compound_ind = i2
   1 pharmacy_type_inclusions[*]
     2 diluent_ind = i2
     2 additive_ind = i2
     2 medication_ind = i2
     2 tpn_ind = i2
     2 sliding_scale_ind = i2
     2 tapered_dose_ind = i2
     2 pca_pump_ind = i2
     2 no_rx_mask_ind = i2
     2 non_pharmacy_ind = i2
   1 clinical_category_codes[*]
     2 clinical_category_code = f8
   1 intermittent_ind_flag = i2
 ) WITH protect
 FREE RECORD rep680220
 RECORD rep680220(
   1 status_data
     2 success_ind = i2
     2 debug_error_message = vc
   1 suggestions[*]
     2 suggestion_display = vc
     2 orderable_suggestion[*]
       3 synonym_id = f8
       3 reference_name = vc
       3 sentence[*]
         4 order_sentence_id = f8
         4 sentence_display = vc
         4 ageinformation[*]
           5 age_minimum = i4
           5 age_maximum = i4
           5 age_code = f8
         4 weightinformation[*]
           5 weight_minimum = f8
           5 weight_maximum = f8
           5 weight_code = f8
         4 pmainformation[*]
           5 age_minimum = i4
           5 age_maximum = i4
           5 age_code = f8
       3 formulary_status_cd = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
     2 plan_suggestion[*]
       3 pathway_catalog_id = f8
       3 pathway_catalog_synonym_id = f8
     2 regimen_suggestion[*]
       3 regimen_catalog_id = f8
       3 regimen_catalog_synonym_id = f8
   1 results_filtered_ind = i2
 ) WITH protect
 FREE RECORD req500689
 RECORD req500689(
   1 qual[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
   1 facility_cd = f8
   1 text_types[*]
     2 text_type_cd = f8
 ) WITH protect
 FREE RECORD rep500689
 RECORD rep500689(
   1 qual[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 auto_invoke_prep_ind = i2
     2 text_types[*]
       3 text_type_cd = f8
   1 status_data
     2 status = vc
     2 subeventstatus[*]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetsearch(null) = i2
 DECLARE getordercatalogdetails(null) = i2
 DECLARE callgettextinfo(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE startpos = i4 WITH protect, noconstant(0)
 DECLARE endpos = i4 WITH protect, noconstant(0)
 DECLARE param = vc WITH protect, noconstant("")
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 DECLARE iv_set_flag = i4 WITH protect, constant(8)
 DECLARE pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6000,"PHARMACY"))
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (textlen(trim( $4,3)) <= 0)
  CALL echo("INVALID SEARCH TEXT PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 SET req_format_str->param =  $4
 EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
  "REP_FORMAT_STR")
 SET result->search_phrase = rep_format_str->param
 SELECT INTO "NL:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE (e.encntr_id= $2)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < sysdate
    AND e.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY p.person_id
  HEAD p.person_id
   result->encntr_type_cd = e.encntr_type_cd, result->facility_cd = e.loc_facility_cd, result->
   birth_dt_tm = p.birth_dt_tm
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "NL:"
  FROM encntr_prsnl_reltn epr
  PLAN (epr
   WHERE (epr.encntr_id= $2)
    AND (epr.prsnl_person_id= $3)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm < sysdate
    AND epr.end_effective_dt_tm > sysdate)
  ORDER BY epr.priority_seq
  HEAD epr.encntr_id
   result->patient_relationship_cd = epr.encntr_prsnl_r_cd
  WITH nocounter, time = 30
 ;end select
 DECLARE clincatcdparam = vc WITH protect, noconstant("")
 DECLARE clincatcdcnt = i4 WITH protect, noconstant(0)
 SET startpos = 1
 SET clincatcdparam = trim( $7,3)
 CALL echo(build2("CLINCATCDPARAM IS: ",clincatcdparam))
 WHILE (size(clincatcdparam) > 0)
   SET endpos = (findstring(";",clincatcdparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(clincatcdparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,clincatcdparam)
    CALL echo(build("PARAM:",param))
    SET clincatcdcnt += 1
    SET stat = alterlist(result->clinical_category_codes,clincatcdcnt)
    SET result->clinical_category_codes[clincatcdcnt].clinical_category_code = cnvtreal(param)
    SET result->clinical_category_codes[clincatcdcnt].clinical_category_disp = uar_get_code_display(
     result->clinical_category_codes[clincatcdcnt].clinical_category_code)
   ENDIF
   SET clincatcdparam = substring((endpos+ 2),(size(clincatcdparam) - endpos),clincatcdparam)
   CALL echo(build("CLINCATCDPARAM:",clincatcdparam))
   CALL echo(build("SIZE(CLINCATCDPARAM):",size(clincatcdparam)))
 ENDWHILE
 SET stat = callgetsearch(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = getordercatalogdetails(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = callgettextinfo(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  DECLARE v7 = vc WITH protect, noconstant("")
  DECLARE v8 = vc WITH protect, noconstant("")
  DECLARE v9 = vc WITH protect, noconstant("")
  DECLARE v10 = vc WITH protect, noconstant("")
  DECLARE v11 = vc WITH protect, noconstant("")
  DECLARE v12 = vc WITH protect, noconstant("")
  DECLARE v13 = vc WITH protect, noconstant("")
  DECLARE v14 = vc WITH protect, noconstant("")
  DECLARE v15 = vc WITH protect, noconstant("")
  DECLARE v16 = vc WITH protect, noconstant("")
  DECLARE v17 = vc WITH protect, noconstant("")
  DECLARE v18 = vc WITH protect, noconstant("")
  DECLARE v19 = vc WITH protect, noconstant("")
  DECLARE v20 = vc WITH protect, noconstant("")
  DECLARE v21 = vc WITH protect, noconstant("")
  DECLARE v22 = vc WITH protect, noconstant("")
  DECLARE v23 = vc WITH protect, noconstant("")
  DECLARE v24 = vc WITH protect, noconstant("")
  DECLARE v25 = vc WITH protect, noconstant("")
  DECLARE v26 = vc WITH protect, noconstant("")
  DECLARE v27 = vc WITH protect, noconstant("")
  DECLARE v28 = vc WITH protect, noconstant("")
  DECLARE v29 = vc WITH protect, noconstant("")
  DECLARE v30 = vc WITH protect, noconstant("")
  IF ((rep680220->status_data.success_ind=1))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, col + 1, "<OrderSynonyms>",
     row + 1
     FOR (idx = 1 TO size(result->orderables,5))
       IF ((((result->orderables[idx].oe_format_id > 0)) OR ((result->orderables[idx].
       orderable_type_flag=iv_set_flag))) )
        col + 1, "<OrderSynonym>", row + 1,
        v1 = build("<SynonymID>",cnvtint(result->orderables[idx].synonym_id),"</SynonymID>"), col + 1,
        v1,
        row + 1, v2 = build("<Mnemonic>",trim(replace(replace(replace(replace(replace(result->
               orderables[idx].display,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
           "&quot;",0),3),"</Mnemonic>"), col + 1,
        v2, row + 1, v27 = build("<SourceString>",trim(replace(replace(replace(replace(replace(result
               ->orderables[idx].source_string,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
            "&apos;",0),'"',"&quot;",0),3),"</SourceString>"),
        col + 1, v27, row + 1,
        v3 = build("<CatalogCD>",cnvtint(result->orderables[idx].catalog_cd),"</CatalogCD>"), col + 1,
        v3,
        row + 1, v4 = build("<CatalogTypeCD>",cnvtint(result->orderables[idx].catalog_type_cd),
         "</CatalogTypeCD>"), col + 1,
        v4, row + 1, v7 = build("<RefTextMask>",
         IF ((result->orderables[idx].text_type_cnt > 0)) "RefTextAvailable"
         ELSE "RefTextNotAvailable"
         ENDIF
         ,"</RefTextMask>"),
        col + 1, v7, row + 1,
        v8 = build("<OrderFormatId>",cnvtstring(result->orderables[idx].oe_format_id),
         "</OrderFormatId>"), col + 1, v8,
        row + 1, col + 1, "<Catalog>",
        row + 1, v9 = build("<Value>",cnvtstring(result->orderables[idx].catalog_cd),"</Value>"), col
         + 1,
        v9, row + 1, v10 = build("<Meaning>",trim(replace(replace(replace(replace(replace(
               uar_get_code_meaning(result->orderables[idx].catalog_cd),"&","&amp;",0),"<","&lt;",0),
             ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Meaning>"),
        col + 1, v10, row + 1,
        v11 = build("<Display>",trim(replace(replace(replace(replace(replace(replace(
                uar_get_code_display(result->orderables[idx].catalog_cd),"Â ","",0),"&","&amp;",0),
              "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Display>"), col + 1,
        v11,
        row + 1, col + 1, "</Catalog>",
        row + 1, col + 1, "<CatalogType>",
        row + 1, v12 = build("<Value>",cnvtstring(result->orderables[idx].catalog_type_cd),"</Value>"
         ), col + 1,
        v12, row + 1, v13 = build("<Meaning>",trim(replace(replace(replace(replace(replace(
               uar_get_code_meaning(result->orderables[idx].catalog_type_cd),"&","&amp;",0),"<",
              "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Meaning>"),
        col + 1, v13, row + 1,
        v14 = build("<Display>",trim(replace(replace(replace(replace(replace(replace(
                uar_get_code_display(result->orderables[idx].catalog_type_cd),"Â ","",0),"&",
               "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Display>"
         ), col + 1, v14,
        row + 1, col + 1, "</CatalogType>",
        row + 1, col + 1, "<ClinicalCategory>",
        row + 1, v15 = build("<Value>",cnvtstring(result->orderables[idx].dcp_clin_cat_cd),"</Value>"
         ), col + 1,
        v15, row + 1, v16 = build("<Meaning>",trim(replace(replace(replace(replace(replace(
               uar_get_code_meaning(result->orderables[idx].dcp_clin_cat_cd),"&","&amp;",0),"<",
              "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Meaning>"),
        col + 1, v16, row + 1,
        v17 = build("<Display>",trim(replace(replace(replace(replace(replace(replace(
                uar_get_code_display(result->orderables[idx].dcp_clin_cat_cd),"Â ","",0),"&",
               "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Display>"
         ), col + 1, v17,
        row + 1, col + 1, "</ClinicalCategory>",
        row + 1, col + 1, "<ActivityType>",
        row + 1, v18 = build("<Value>",cnvtstring(result->orderables[idx].activity_type_cd),
         "</Value>"), col + 1,
        v18, row + 1, v19 = build("<Meaning>",trim(replace(replace(replace(replace(replace(
               uar_get_code_meaning(result->orderables[idx].activity_type_cd),"&","&amp;",0),"<",
              "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Meaning>"),
        col + 1, v19, row + 1,
        v20 = build("<Display>",trim(replace(replace(replace(replace(replace(replace(
                uar_get_code_display(result->orderables[idx].activity_type_cd),"Â ","",0),"&",
               "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Display>"
         ), col + 1, v20,
        row + 1, col + 1, "</ActivityType>",
        row + 1, col + 1, "<ActivitySubTypeCD>",
        row + 1, v21 = build("<Value>",cnvtstring(result->orderables[idx].activity_subtype_cd),
         "</Value>"), col + 1,
        v21, row + 1, v22 = build("<Meaning>",trim(replace(replace(replace(replace(replace(
               uar_get_code_meaning(result->orderables[idx].activity_subtype_cd),"&","&amp;",0),"<",
              "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Meaning>"),
        col + 1, v22, row + 1,
        v23 = build("<Display>",trim(replace(replace(replace(replace(replace(replace(
                uar_get_code_display(result->orderables[idx].activity_subtype_cd),"Â ","",0),"&",
               "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Display>"
         ), col + 1, v23,
        row + 1, col + 1, "</ActivitySubTypeCD>",
        row + 1, col + 1, "<PharmacyType>",
        row + 1, v28 = build("<DiluentInd>",evaluate(band(result->orderables[idx].rx_mask,1),0,0,1),
         "</DiluentInd>"), col + 1,
        v28, row + 1, v29 = build("<AdditiveInd>",evaluate(band(result->orderables[idx].rx_mask,2),0,
          0,1),"</AdditiveInd>"),
        col + 1, v29, row + 1,
        v30 = build("<MedInd>",evaluate(band(result->orderables[idx].rx_mask,4),0,0,1),"</MedInd>"),
        col + 1, v30,
        row + 1, v31 = build("<SlidingScaleInd>",evaluate(band(result->orderables[idx].rx_mask,16),0,
          0,1),"</SlidingScaleInd>"), col + 1,
        v31, row + 1, col + 1,
        "</PharmacyType>", row + 1, col + 1,
        "<OrderSentencesList>", row + 1
        FOR (jdx = 1 TO size(result->orderables[idx].order_sentences,5))
          col + 1, "<OrderSentenceList>", row + 1,
          v5 = build("<OrderSentenceId>",cnvtint(result->orderables[idx].order_sentences[jdx].
            order_sentence_id),"</OrderSentenceId>"), col + 1, v5,
          row + 1, v6 = build("<OrderSentenceDisplayLine>",trim(replace(replace(replace(replace(
                replace(result->orderables[idx].order_sentences[jdx].display_line,"&","&amp;",0),"<",
                "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
           "</OrderSentenceDisplayLine>"), col + 1,
          v6, row + 1, col + 1,
          "</OrderSentenceList>", row + 1
        ENDFOR
        col + 1, "</OrderSentencesList>", row + 1,
        v24 = build("<AutoInvokePrepInd>",cnvtint(result->orderables[idx].auto_invoke_prep_ind),
         "</AutoInvokePrepInd>"), col + 1, v24,
        row + 1, v25 = build("<OrderableTypeFlag>",cnvtint(result->orderables[idx].
          orderable_type_flag),"</OrderableTypeFlag>"), col + 1,
        v25, row + 1, v26 = build("<MultipleOrderSentInd>",result->orderables[idx].
         has_multiple_order_sentences,"</MultipleOrderSentInd>"),
        col + 1, v26, row + 1,
        col + 1, "</OrderSynonym>", row + 1
       ENDIF
     ENDFOR
     col + 1, "</OrderSynonyms>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ELSE
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, col + 1, "<OrderSynonyms>",
     row + 1, col + 1, "</OrderSynonyms>",
     row + 1, col + 1, "</ReplyMessage>",
     row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 10
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD req680220
 FREE RECORD rep680220
 FREE RECORD req500689
 FREE RECORD rep500689
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 SUBROUTINE callgetsearch(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(500195)
   DECLARE requestid = i4 WITH protect, constant(680220)
   DECLARE clncatsize = i4 WITH protect, constant(size(result->clinical_category_codes,5))
   DECLARE ocnt = i4 WITH protect, noconstant(0)
   DECLARE scnt = i4 WITH protect, noconstant(0)
   SET req680220->search_phrase = result->search_phrase
   SET req680220->suggestion_limit = 100
   SET req680220->personnel.personnel_id =  $3
   SET req680220->personnel.patient_provider_reltnship_cd = result->patient_relationship_cd
   SET stat = alterlist(req680220->encounter,1)
   SET req680220->encounter[1].encounter_type_cd = result->encntr_type_cd
   IF ((result->facility_cd > 0.00))
    SET stat = alterlist(req680220->facility,1)
    SET req680220->facility[1].facility_id = result->facility_cd
    SET req680220->facility[1].filter_type.virtual_view_ind = 1
    SET req680220->facility[1].filter_type.plan_virtual_view_ind = 0
   ENDIF
   SET stat = alterlist(req680220->filter_by_venue.inpatient_venue,1)
   SET req680220->filter_by_venue.inpatient_venue.content.orderable_ind = 1
   SET req680220->filter_by_venue.inpatient_venue.content.plan_ind = 0
   SET stat = alterlist(req680220->demographic_filter_criteria,1)
   IF ((result->birth_dt_tm != null))
    SET stat = alterlist(req680220->demographic_filter_criteria[1].agefilter,1)
    SET req680220->demographic_filter_criteria[1].agefilter[1].birthdate = result->birth_dt_tm
    SET req680220->demographic_filter_criteria[1].agefilter[1].timezone = app_tz
   ENDIF
   IF (cnvtreal( $5) > 0.0)
    SET stat = alterlist(req680220->demographic_filter_criteria[1].weightfilter,1)
    SET req680220->demographic_filter_criteria[1].weightfilter[1].weightvalue =  $5
    SET req680220->demographic_filter_criteria[1].weightfilter[1].weightcode =  $6
   ENDIF
   SET stat = alterlist(req680220->demographic_filter_criteria[1].pmafilter,1)
   SET req680220->demographic_filter_criteria[1].pmafilter[1].pma_hide_all_ind = 1
   SET stat = alterlist(req680220->orderable_type_inclusions,1)
   SET req680220->orderable_type_inclusions[1].normal_0_ind = 1
   SET req680220->orderable_type_inclusions[1].normal_1_ind = 1
   SET req680220->orderable_type_inclusions[1].freetext_ind = 1
   SET stat = alterlist(req680220->pharmacy_type_inclusions,1)
   IF (( $9=0)
    AND ( $10=0)
    AND ( $11=0))
    SET req680220->pharmacy_type_inclusions[1].medication_ind = 1
    SET req680220->pharmacy_type_inclusions[1].non_pharmacy_ind = 1
   ELSEIF (( $11 > 0))
    SET req680220->orderable_type_inclusions[1].supergroup_ind = 1
    SET req680220->orderable_type_inclusions[1].orderset_ind = 1
    SET req680220->orderable_type_inclusions[1].multi_ingredient_ind = 1
    SET req680220->orderable_type_inclusions[1].tpn_ind = 1
    SET req680220->orderable_type_inclusions[1].compound_ind = 1
    SET req680220->pharmacy_type_inclusions[1].diluent_ind = 1
    SET req680220->pharmacy_type_inclusions[1].additive_ind = 1
    SET req680220->pharmacy_type_inclusions[1].medication_ind = 1
    SET req680220->pharmacy_type_inclusions[1].tpn_ind = 1
    SET req680220->pharmacy_type_inclusions[1].sliding_scale_ind = 0
    SET req680220->pharmacy_type_inclusions[1].tapered_dose_ind = 0
    SET req680220->pharmacy_type_inclusions[1].pca_pump_ind = 1
    SET req680220->pharmacy_type_inclusions[1].non_pharmacy_ind = 1
   ELSEIF (( $9 > 0))
    SET req680220->pharmacy_type_inclusions[1].diluent_ind = 1
   ELSEIF (( $10 > 0))
    SET req680220->pharmacy_type_inclusions[1].additive_ind = 1
   ENDIF
   IF (clncatsize > 0)
    SET stat = alterlist(req680220->clinical_category_codes,clncatsize)
    FOR (idx = 1 TO clncatsize)
      SET req680220->clinical_category_codes[idx].clinical_category_code = result->
      clinical_category_codes[idx].clinical_category_code
    ENDFOR
   ENDIF
   CALL echorecord(req680220)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req680220,
    "REC",rep680220,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep680220)
   IF ((rep680220->status_data.success_ind=1))
    SET stat = alterlist(result->orderables,size(rep680220->suggestions,5))
    FOR (idx = 1 TO size(rep680220->suggestions,5))
      IF (size(rep680220->suggestions[idx].orderable_suggestion,5) > 0)
       SET ocnt += 1
       SET result->orderables[ocnt].display = rep680220->suggestions[idx].suggestion_display
       SET result->orderables[ocnt].source_string = rep680220->suggestions[idx].orderable_suggestion[
       1].reference_name
       SET result->orderables[ocnt].synonym_id = rep680220->suggestions[idx].orderable_suggestion[1].
       synonym_id
       SET result->orderables[ocnt].catalog_cd = rep680220->suggestions[idx].orderable_suggestion[1].
       catalog_cd
       SET result->orderables[ocnt].catalog_disp = uar_get_code_display(result->orderables[ocnt].
        catalog_cd)
       SET result->orderables[ocnt].catalog_type_cd = rep680220->suggestions[idx].
       orderable_suggestion[1].catalog_type_cd
       SET result->orderables[ocnt].catalog_type_disp = uar_get_code_display(result->orderables[ocnt]
        .catalog_type_cd)
       IF ((result->orderables[ocnt].catalog_type_cd=pharmacy_cd))
        SELECT INTO "NL:"
         FROM order_catalog_synonym ocs
         WHERE (ocs.synonym_id=result->orderables[ocnt].synonym_id)
         HEAD ocs.synonym_id
          result->orderables[ocnt].rx_mask = ocs.rx_mask
         WITH time = 10, maxrec = 1
        ;end select
       ENDIF
       SET scnt = size(rep680220->suggestions[idx].orderable_suggestion[1].sentence,5)
       SET stat = alterlist(result->orderables[ocnt].order_sentences,scnt)
       FOR (jdx = 1 TO scnt)
         SET result->orderables[ocnt].order_sentences[jdx].order_sentence_id = rep680220->
         suggestions[idx].orderable_suggestion[1].sentence[jdx].order_sentence_id
         SET result->orderables[ocnt].order_sentences[jdx].display_line = rep680220->suggestions[idx]
         .orderable_suggestion[1].sentence[jdx].sentence_display
         IF ((result->orderables[(ocnt - 1)].synonym_id=result->orderables[ocnt].synonym_id)
          AND size(result->orderables[(ocnt - 1)].order_sentences,5) <= 0)
          SET result->orderables[(ocnt - 1)].has_multiple_order_sentences = 1
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
    SET stat = alterlist(result->orderables,ocnt)
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE getordercatalogdetails(null)
  DECLARE osize = i4 WITH protect, constant(size(result->orderables,5))
  IF (osize > 0)
   SELECT INTO "NL:"
    FROM order_catalog oc
    PLAN (oc
     WHERE expand(idx,1,osize,oc.catalog_cd,result->orderables[idx].catalog_cd))
    HEAD oc.catalog_cd
     pos = locateval(locidx,1,osize,oc.catalog_cd,result->orderables[locidx].catalog_cd)
     WHILE (pos > 0)
       result->orderables[pos].ref_text_mask = oc.ref_text_mask, result->orderables[pos].oe_format_id
        = oc.oe_format_id, result->orderables[pos].dcp_clin_cat_cd = oc.dcp_clin_cat_cd,
       result->orderables[pos].activity_type_cd = oc.activity_type_cd, result->orderables[pos].
       activity_subtype_cd = oc.activity_subtype_cd, result->orderables[pos].orderable_type_flag = oc
       .orderable_type_flag,
       pos = locateval(locidx,(pos+ 1),osize,oc.catalog_cd,result->orderables[locidx].catalog_cd)
     ENDWHILE
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE callgettextinfo(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(500195)
   DECLARE requestid = i4 WITH protect, constant(500689)
   SET stat = alterlist(req500689->qual,size(result->orderables,5))
   FOR (idx = 1 TO size(result->orderables,5))
    SET req500689->qual[idx].parent_entity_id = result->orderables[idx].catalog_cd
    SET req500689->qual[idx].parent_entity_name = "ORDER_CATALOG"
   ENDFOR
   SET req500689->facility_cd = result->facility_cd
   CALL echorecord(req500689)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req500689,
    "REC",rep500689,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep500689)
   IF ((rep500689->status_data.status="S"))
    FOR (idx = 1 TO size(rep500689->qual,5))
     SET pos = locateval(locidx,1,size(result->orderables,5),rep500689->qual[idx].parent_entity_id,
      result->orderables[locidx].catalog_cd)
     WHILE (pos > 0)
       SET result->orderables[pos].auto_invoke_prep_ind = rep500689->qual[idx].auto_invoke_prep_ind
       SET result->orderables[pos].text_type_cnt = size(rep500689->qual[idx].text_types,5)
       SET pos = locateval(locidx,(pos+ 1),size(result->orderables,5),rep500689->qual[idx].
        parent_entity_id,result->orderables[locidx].catalog_cd)
     ENDWHILE
    ENDFOR
    RETURN(success)
   ELSEIF ((rep500689->status_data.status="Z"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
