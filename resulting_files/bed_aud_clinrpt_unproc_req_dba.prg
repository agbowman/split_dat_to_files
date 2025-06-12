CREATE PROGRAM bed_aud_clinrpt_unproc_req:dba
 SET hi18n = 0
 SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"INPROCESS")), protect
 DECLARE unprocessed_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"UNPROCESSED")), protect
 DECLARE timedoutpend_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"TIMEDOUTPEND")), protect
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"PENDING")), protect
 IF ( NOT (validate(reqst_type)))
  DECLARE reqst_type = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.REQST_TYPE","Request Type"))
 ENDIF
 IF ( NOT (validate(reqst_by)))
  DECLARE reqst_by = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.REQST_BY","Requested By"))
 ENDIF
 IF ( NOT (validate(reqst_dt)))
  DECLARE reqst_dt = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.REQST_DT","Request Date/Time"))
 ENDIF
 IF ( NOT (validate(scpe)))
  DECLARE scpe = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"BED_AUD_CLINRPT_UNPROC_REQ.SCPE",
    "Scope"))
 ENDIF
 IF ( NOT (validate(patient_nme)))
  DECLARE patient_nme = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.PATIENT_NME","Patient Name"))
 ENDIF
 IF ( NOT (validate(mrn)))
  DECLARE mrn = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"BED_AUD_CLINRPT_UNPROC_REQ.MRN",
    "Patient MRN"))
 ENDIF
 IF ( NOT (validate(encnter_id)))
  DECLARE encnter_id = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.ENCNTER_ID","Encounter ID"))
 ENDIF
 IF ( NOT (validate(fin)))
  DECLARE fin = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"BED_AUD_CLINRPT_UNPROC_REQ.FIN",
    "Financial Number"))
 ENDIF
 IF ( NOT (validate(accessn)))
  DECLARE accessn = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.ACCESSN","Accession"))
 ENDIF
 IF ( NOT (validate(ordr)))
  DECLARE ordr = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"BED_AUD_CLINRPT_UNPROC_REQ.ORDR",
    "Order ID"))
 ENDIF
 IF ( NOT (validate(ordr_s)))
  DECLARE ordr_s = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.ORDR_S","Order"))
 ENDIF
 IF ( NOT (validate(evnt_id)))
  DECLARE evnt_id = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.EVNT_ID","Event ID"))
 ENDIF
 IF ( NOT (validate(outpt_dest)))
  DECLARE outpt_dest = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.OUTPT_DEST","Output Destination"))
 ENDIF
 IF ( NOT (validate(provdr)))
  DECLARE provdr = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.PROVDR","Provider"))
 ENDIF
 IF ( NOT (validate(provdr_rlshnp)))
  DECLARE provdr_rlshnp = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.PROVDR_RLSHNP","Provider Relationship"))
 ENDIF
 IF ( NOT (validate(chart_frmt)))
  DECLARE chart_frmt = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.CHART_FRMT","Chart Format"))
 ENDIF
 IF ( NOT (validate(dst_name)))
  DECLARE dst_name = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.DST_NAME","Distribution Name"))
 ENDIF
 IF ( NOT (validate(trig_name)))
  DECLARE trig_name = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.TRIG_NAME","Trigger Name"))
 ENDIF
 IF ( NOT (validate(outbnd_type)))
  DECLARE outbnd_type = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.OUTBND_TYPE","Outbound Type"))
 ENDIF
 IF ( NOT (validate(adhc)))
  DECLARE adhc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"BED_AUD_CLINRPT_UNPROC_REQ.ADHC",
    "Adhoc"))
 ENDIF
 IF ( NOT (validate(expdt)))
  DECLARE expdt = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.EXPDT","Expedite"))
 ENDIF
 IF ( NOT (validate(t_eso)))
  DECLARE t_eso = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.T_ESO","ESO"))
 ENDIF
 IF ( NOT (validate(dist)))
  DECLARE dist = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"BED_AUD_CLINRPT_UNPROC_REQ.DIST",
    "Distribution"))
 ENDIF
 IF ( NOT (validate(t_mrp)))
  DECLARE t_mrp = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.T_MRP","MRP"))
 ENDIF
 IF ( NOT (validate(prson)))
  DECLARE prson = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.PRSON","Person"))
 ENDIF
 IF ( NOT (validate(encnter)))
  DECLARE encnter = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.ENCNTER","Encounter"))
 ENDIF
 IF ( NOT (validate(cross_encntr)))
  DECLARE cross_encntr = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.CROSS_ENCNTR","Cross Encounter"))
 ENDIF
 IF ( NOT (validate(documnt)))
  DECLARE documnt = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_UNPROC_REQ.DOCUMNT","Document"))
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
  )
 ENDIF
 FREE RECORD chart_requests
 RECORD chart_requests(
   1 chart_request[*]
     2 request_type = i2
     2 request_prsnl_id = f8
     2 request_by = vc
     2 request_dt_tm = dq8
     2 request_scope = i2
     2 patient_name = vc
     2 patient_id = f8
     2 patient_mrns[*]
       3 patient_mrn = vc
     2 encntr_id = f8
     2 encntr_ids[*]
       3 encntr_id = f8
     2 fin_nbrs[*]
       3 fin_nbr = vc
     2 accession = vc
     2 order_id = f8
     2 order_ids[*]
       3 order_id = f8
     2 event_id = f8
     2 event_ids[*]
       3 event_id = f8
     2 event_ind = i2
     2 output_destination = vc
     2 output_dest_cd = f8
     2 output_device_cd = f8
     2 provider_id = f8
     2 provider_name = vc
     2 provider_relationship = vc
     2 chart_request_id = f8
     2 chart_format_name = vc
     2 chart_format_id = f8
     2 distribution_id = f8
     2 distribution_name = vc
     2 chart_trigger_id = f8
     2 trigger_id = f8
     2 expedite_trigger_name = vc
     2 outbound_type = vc
 )
 DECLARE chart_requests_cnt = i4 WITH noconstant(0)
 SELECT DISTINCT INTO "NL:"
  FROM chart_request cr,
   chart_format cf,
   prsnl p1,
   prsnl p2,
   person p3,
   chart_distribution cd,
   chart_trigger ct,
   output_dest od
  PLAN (cr
   WHERE cr.chart_status_cd IN (inprocess_cd, unprocessed_cd, timedoutpend_cd, pending_cd))
   JOIN (cf
   WHERE cf.chart_format_id=cr.chart_format_id)
   JOIN (p1
   WHERE p1.person_id=cr.request_prsnl_id)
   JOIN (p2
   WHERE p2.person_id=cr.prsnl_person_id)
   JOIN (p3
   WHERE p3.person_id=cr.person_id)
   JOIN (cd
   WHERE cd.distribution_id=cr.distribution_id)
   JOIN (ct
   WHERE ct.chart_trigger_id=cr.chart_trigger_id)
   JOIN (od
   WHERE od.output_dest_cd=cr.output_dest_cd)
  ORDER BY cr.request_type, cr.request_dt_tm
  DETAIL
   chart_requests_cnt = (chart_requests_cnt+ 1), stat = alterlist(chart_requests->chart_request,
    chart_requests_cnt), chart_requests->chart_request[chart_requests_cnt].chart_request_id = cr
   .chart_request_id,
   chart_requests->chart_request[chart_requests_cnt].encntr_id = cr.encntr_id, chart_requests->
   chart_request[chart_requests_cnt].request_type = cr.request_type, chart_requests->chart_request[
   chart_requests_cnt].request_prsnl_id = cr.request_prsnl_id,
   chart_requests->chart_request[chart_requests_cnt].request_dt_tm = cr.request_dt_tm, chart_requests
   ->chart_request[chart_requests_cnt].request_scope = cr.scope_flag, chart_requests->chart_request[
   chart_requests_cnt].patient_id = cr.person_id,
   chart_requests->chart_request[chart_requests_cnt].accession = cr.accession_nbr, chart_requests->
   chart_request[chart_requests_cnt].order_id = cr.order_id, chart_requests->chart_request[
   chart_requests_cnt].event_ind = cr.event_ind,
   chart_requests->chart_request[chart_requests_cnt].output_dest_cd = cr.output_dest_cd,
   chart_requests->chart_request[chart_requests_cnt].output_device_cd = cr.output_device_cd,
   chart_requests->chart_request[chart_requests_cnt].provider_id = cr.prsnl_person_id,
   chart_requests->chart_request[chart_requests_cnt].chart_format_id = cf.chart_format_id,
   chart_requests->chart_request[chart_requests_cnt].distribution_id = cr.distribution_id,
   chart_requests->chart_request[chart_requests_cnt].chart_trigger_id = cr.chart_trigger_id,
   chart_requests->chart_request[chart_requests_cnt].outbound_type = cr.trigger_type, chart_requests
   ->chart_request[chart_requests_cnt].request_by = p1.name_full_formatted, chart_requests->
   chart_request[chart_requests_cnt].provider_name = p2.name_full_formatted,
   chart_requests->chart_request[chart_requests_cnt].patient_name = p3.name_full_formatted,
   chart_requests->chart_request[chart_requests_cnt].chart_format_name = cf.chart_format_desc,
   chart_requests->chart_request[chart_requests_cnt].provider_relationship = uar_get_code_display(cr
    .prsnl_person_r_cd),
   chart_requests->chart_request[chart_requests_cnt].distribution_name = cd.dist_descr,
   chart_requests->chart_request[chart_requests_cnt].expedite_trigger_name =
   IF (cr.chart_trigger_id > 0) ct.trigger_name
   ELSE cr.trigger_name
   ENDIF
   , chart_requests->chart_request[chart_requests_cnt].trigger_id = cr.trigger_id,
   chart_requests->chart_request[chart_requests_cnt].output_destination = od.name
  WITH nocounter
 ;end select
 IF (chart_requests_cnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = chart_requests_cnt),
    chart_request_order cro
   PLAN (d
    WHERE (chart_requests->chart_request[d.seq].request_scope IN (3, 4)))
    JOIN (cro
    WHERE (cro.chart_request_id=chart_requests->chart_request[d.seq].chart_request_id))
   HEAD d.seq
    cro_cnt = 0
   DETAIL
    cro_cnt = (cro_cnt+ 1), stat = alterlist(chart_requests->chart_request[d.seq].order_ids,cro_cnt),
    chart_requests->chart_request[d.seq].order_ids[cro_cnt].order_id = cro.order_id
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = chart_requests_cnt),
    chart_request_encntr cre
   PLAN (d
    WHERE (chart_requests->chart_request[d.seq].request_scope=5))
    JOIN (cre
    WHERE (cre.chart_request_id=chart_requests->chart_request[d.seq].chart_request_id))
   HEAD d.seq
    cre_cnt = 0
   DETAIL
    cre_cnt = (cre_cnt+ 1), stat = alterlist(chart_requests->chart_request[d.seq].encntr_ids,cre_cnt),
    chart_requests->chart_request[d.seq].encntr_ids[cre_cnt].encntr_id = cre.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = chart_requests_cnt),
    chart_request_event cvt
   PLAN (d
    WHERE (chart_requests->chart_request[d.seq].event_ind=1))
    JOIN (cvt
    WHERE (cvt.chart_request_id=chart_requests->chart_request[d.seq].chart_request_id))
   HEAD d.seq
    cvt_cnt = 0
   DETAIL
    cvt_cnt = (cvt_cnt+ 1), stat = alterlist(chart_requests->chart_request[d.seq].event_ids,cvt_cnt),
    chart_requests->chart_request[d.seq].event_ids[cvt_cnt].event_id = cvt.cr_event_id
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = chart_requests_cnt),
    encntr_alias ea
   PLAN (d
    WHERE (chart_requests->chart_request[d.seq].encntr_id > 0))
    JOIN (ea
    WHERE (ea.encntr_id=chart_requests->chart_request[d.seq].encntr_id))
   HEAD d.seq
    ea_cnt = 0
   DETAIL
    ea_cnt = (ea_cnt+ 1), stat = alterlist(chart_requests->chart_request[d.seq].fin_nbrs,ea_cnt),
    chart_requests->chart_request[d.seq].fin_nbrs[ea_cnt].fin_nbr = cnvtalias(ea.alias,ea
     .alias_pool_cd)
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = chart_requests_cnt),
    person_alias pa
   PLAN (d
    WHERE (chart_requests->chart_request[d.seq].patient_id > 0))
    JOIN (pa
    WHERE (pa.person_id=chart_requests->chart_request[d.seq].patient_id))
   HEAD d.seq
    pa_cnt = 0
   DETAIL
    pa_cnt = (pa_cnt+ 1), stat = alterlist(chart_requests->chart_request[d.seq].patient_mrns,pa_cnt),
    chart_requests->chart_request[d.seq].patient_mrns[pa_cnt].patient_mrn = cnvtalias(pa.alias,pa
     .alias_pool_cd)
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,18)
 SET reply->collist[1].header_text = reqst_type
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = reqst_by
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = reqst_dt
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = scpe
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = patient_nme
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = mrn
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = encnter_id
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = fin
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = accessn
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = ordr
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = evnt_id
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = outpt_dest
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = provdr
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = provdr_rlshnp
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = chart_frmt
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = dst_name
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = trig_name
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = outbnd_type
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 IF (chart_requests_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->rowlist,chart_requests_cnt)
 FOR (c = 1 TO chart_requests_cnt)
   SET stat = alterlist(reply->rowlist[c].celllist,18)
   IF ((chart_requests->chart_request[c].request_type=1))
    SET reply->rowlist[c].celllist[1].string_value = adhc
   ELSEIF ((chart_requests->chart_request[c].request_type=2))
    IF ((chart_requests->chart_request[c].trigger_id > 0))
     SET reply->rowlist[c].celllist[1].string_value = t_eso
    ELSE
     SET reply->rowlist[c].celllist[1].string_value = expdt
    ENDIF
   ELSEIF ((chart_requests->chart_request[c].request_type=4))
    SET reply->rowlist[c].celllist[1].string_value = dist
   ELSEIF ((chart_requests->chart_request[c].request_type=8))
    SET reply->rowlist[c].celllist[1].string_value = t_mrp
   ENDIF
   SET reply->rowlist[c].celllist[2].string_value = build2(trim(chart_requests->chart_request[c].
     request_by),"(",trim(cnvtstringchk(chart_requests->chart_request[c].request_prsnl_id)),")")
   SET reply->rowlist[c].celllist[3].string_value = datetimezoneformat(chart_requests->chart_request[
    c].request_dt_tm,curtimezoneapp,"MM/dd/yyyy  hh:mm:ss",curtimezonedef)
   IF ((chart_requests->chart_request[c].request_scope=1))
    SET reply->rowlist[c].celllist[4].string_value = prson
   ELSEIF ((chart_requests->chart_request[c].request_scope=2))
    SET reply->rowlist[c].celllist[4].string_value = encnter
   ELSEIF ((chart_requests->chart_request[c].request_scope=3))
    SET reply->rowlist[c].celllist[4].string_value = ordr_s
   ELSEIF ((chart_requests->chart_request[c].request_scope=4))
    SET reply->rowlist[c].celllist[4].string_value = accessn
   ELSEIF ((chart_requests->chart_request[c].request_scope=5))
    SET reply->rowlist[c].celllist[4].string_value = cross_encntr
   ELSEIF ((chart_requests->chart_request[c].request_scope=6))
    SET reply->rowlist[c].celllist[4].string_value = documnt
   ENDIF
   IF ((chart_requests->chart_request[c].patient_id > 0))
    SET reply->rowlist[c].celllist[5].string_value = build2(trim(chart_requests->chart_request[c].
      patient_name),"(",trim(cnvtstringchk(chart_requests->chart_request[c].patient_id)),")")
   ENDIF
   FOR (x = 1 TO size(chart_requests->chart_request[c].patient_mrns,5))
     IF (x=1)
      SET reply->rowlist[c].celllist[6].string_value = chart_requests->chart_request[c].patient_mrns[
      x].patient_mrn
     ELSE
      SET reply->rowlist[c].celllist[6].string_value = build2(reply->rowlist[c].celllist[6].
       string_value,";",chart_requests->chart_request[c].patient_mrns[x].patient_mrn)
     ENDIF
   ENDFOR
   IF (size(chart_requests->chart_request[c].encntr_ids,5)=0
    AND (chart_requests->chart_request[c].encntr_id > 0))
    SET reply->rowlist[c].celllist[7].string_value = cnvtstringchk(chart_requests->chart_request[c].
     encntr_id)
   ELSE
    FOR (x = 1 TO size(chart_requests->chart_request[c].encntr_ids,5))
      IF (x=1)
       SET reply->rowlist[c].celllist[7].string_value = cnvtstringchk(chart_requests->chart_request[c
        ].encntr_ids[x].encntr_id)
      ELSE
       SET reply->rowlist[c].celllist[7].string_value = build2(reply->rowlist[c].celllist[7].
        string_value,";",cnvtstringchk(chart_requests->chart_request[c].encntr_ids[x].encntr_id))
      ENDIF
    ENDFOR
   ENDIF
   FOR (x = 1 TO size(chart_requests->chart_request[c].fin_nbrs,5))
     IF (x=1)
      SET reply->rowlist[c].celllist[8].string_value = chart_requests->chart_request[c].fin_nbrs[x].
      fin_nbr
     ELSE
      SET reply->rowlist[c].celllist[8].string_value = build2(reply->rowlist[c].celllist[8].
       string_value,";",chart_requests->chart_request[c].fin_nbrs[x].fin_nbr)
     ENDIF
   ENDFOR
   SET reply->rowlist[c].celllist[9].string_value = cnvtacc(chart_requests->chart_request[c].
    accession)
   IF (size(chart_requests->chart_request[c].order_ids,5)=0
    AND (chart_requests->chart_request[c].order_id > 0))
    SET reply->rowlist[c].celllist[10].string_value = cnvtstringchk(chart_requests->chart_request[c].
     order_id)
   ELSE
    FOR (x = 1 TO size(chart_requests->chart_request[c].order_ids,5))
      IF (x=1)
       SET reply->rowlist[c].celllist[10].string_value = cnvtstringchk(chart_requests->chart_request[
        c].order_ids[x].order_id)
      ELSE
       SET reply->rowlist[c].celllist[10].string_value = build2(reply->rowlist[c].celllist[10].
        string_value,";",cnvtstringchk(chart_requests->chart_request[c].order_ids[x].order_id))
      ENDIF
    ENDFOR
   ENDIF
   IF (size(chart_requests->chart_request[c].event_ids,5)=0
    AND (chart_requests->chart_request[c].event_id > 0))
    SET reply->rowlist[c].celllist[11].string_value = cnvtstringchk(chart_requests->chart_request[c].
     event_id)
   ELSE
    FOR (x = 1 TO size(chart_requests->chart_request[c].event_ids,5))
      IF (x=1)
       SET reply->rowlist[c].celllist[11].string_value = cnvtstringchk(chart_requests->chart_request[
        c].event_ids[x].event_id)
      ELSE
       SET reply->rowlist[c].celllist[11].string_value = build2(reply->rowlist[c].celllist[11].
        string_value,";",cnvtstringchk(chart_requests->chart_request[c].event_ids[x].event_id))
      ENDIF
    ENDFOR
   ENDIF
   SET reply->rowlist[c].celllist[12].string_value = chart_requests->chart_request[c].
   output_destination
   IF ((chart_requests->chart_request[c].provider_id > 0))
    SET reply->rowlist[c].celllist[13].string_value = build2(trim(chart_requests->chart_request[c].
      provider_name),"(",trim(cnvtstringchk(chart_requests->chart_request[c].provider_id)),")")
   ENDIF
   SET reply->rowlist[c].celllist[14].string_value = chart_requests->chart_request[c].
   provider_relationship
   IF ((chart_requests->chart_request[c].chart_format_id > 0))
    SET reply->rowlist[c].celllist[15].string_value = build2(trim(chart_requests->chart_request[c].
      chart_format_name),"(",trim(cnvtstringchk(chart_requests->chart_request[c].chart_format_id)),
     ")")
   ENDIF
   IF ((chart_requests->chart_request[c].request_type=4))
    SET reply->rowlist[c].celllist[16].string_value = build2(trim(chart_requests->chart_request[c].
      distribution_name),"(",trim(cnvtstringchk(chart_requests->chart_request[c].distribution_id)),
     ")")
   ENDIF
   IF ((chart_requests->chart_request[c].request_type=2))
    SET reply->rowlist[c].celllist[17].string_value = chart_requests->chart_request[c].
    expedite_trigger_name
   ENDIF
   IF ((chart_requests->chart_request[c].request_type=2))
    SET reply->rowlist[c].celllist[18].string_value = chart_requests->chart_request[c].outbound_type
   ENDIF
 ENDFOR
#exit_script
END GO
