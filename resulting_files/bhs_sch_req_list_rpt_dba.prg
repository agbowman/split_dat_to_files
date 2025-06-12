CREATE PROGRAM bhs_sch_req_list_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Request List Queues" = "",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Email Spreadsheet" = ""
  WITH outdev, mrequestlistqueues, mstartdate,
  menddate, memailspreadsheet
 FREE RECORD request
 RECORD request(
   1 call_echo_ind = i2
   1 qual[*]
     2 oe_field_meaning = vc
     2 oe_field_value = f8
     2 oe_field_dt_tm_value = dq8
 )
 FREE RECORD m_reply
 RECORD m_reply(
   1 query_qual[*]
     2 home_phone = vc
     2 cell_phone = vc
     2 person_first_name = vc
     2 person_last_name = vc
     2 appt_type_display = vc
     2 order_date = vc
     2 order_loc = vc
     2 ordering_provider = vc
     2 mrn = vc
     2 cmrn = vc
     2 personid = f8
     2 language_spoken = vc
     2 prim_insurance = vc
     2 sec_insurance = vc
     2 earliest_date = vc
     2 orderid = f8
     2 dob = vc
     2 contact_count = i4
 )
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom = vc WITH protect, noconstant(" ")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE mreplycnt = i4 WITH protect, noconstant(0)
 DECLARE ms_queue = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_person_pos = i4 WITH protect, noconstant(0)
 DECLARE ndx = i4 WITH protect, noconstant(0)
 DECLARE lndx = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_pa_pos = i4 WITH protect, noconstant(0)
 DECLARE temp_date = dq8
 DECLARE temp_date2 = dq8
 DECLARE ms_file_name = vc WITH protect, constant("bhs_sch_req_list_rpt.csv")
 DECLARE mf_phone_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"CELL"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 IF (( $MSTARTDATE >  $MENDDATE))
  SET ms_log = " Invalid input dates - start date must be before end date."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM sch_object so
  WHERE so.sch_object_id=cnvtreal( $MREQUESTLISTQUEUES)
  DETAIL
   ms_queue = so.mnemonic
  WITH nocounter
 ;end select
 SET request->call_echo_ind = 0
 SET stat = alterlist(request->qual,3)
 SET request->qual[1].oe_field_meaning = "QUEUE"
 SET request->qual[1].oe_field_value = cnvtreal( $MREQUESTLISTQUEUES)
 SET request->qual[2].oe_field_meaning = "BEGDTTM"
 SET request->qual[2].oe_field_dt_tm_value = cnvtdatetime( $MSTARTDATE)
 SET request->qual[3].oe_field_meaning = "ENDDTTM"
 SET request->qual[3].oe_field_dt_tm_value = cnvtdatetime( $MENDDATE)
 EXECUTE bhs_sch_inqa_req_wqm_queueonly
 SET mreplycnt = size(reply->query_qual,5)
 SET stat = alterlist(m_reply->query_qual,mreplycnt)
 IF (mreplycnt > 0)
  FOR (ml_loop = 1 TO mreplycnt)
    SET m_reply->query_qual[ml_loop].home_phone = reply->query_qual[ml_loop].home_phone
    SET m_reply->query_qual[ml_loop].appt_type_display = reply->query_qual[ml_loop].appt_type_display
    SET m_reply->query_qual[ml_loop].order_date = format(reply->query_qual[ml_loop].order_date,";;q")
    SET m_reply->query_qual[ml_loop].order_loc = reply->query_qual[ml_loop].order_loc
    SET m_reply->query_qual[ml_loop].ordering_provider = reply->query_qual[ml_loop].ordering_provider
    SET m_reply->query_qual[ml_loop].mrn = reply->query_qual[ml_loop].mrn
    SET m_reply->query_qual[ml_loop].personid = reply->query_qual[ml_loop].hide#personid
    SET m_reply->query_qual[ml_loop].earliest_date = format(reply->query_qual[ml_loop].earliest_dt_tm,
     ";;q")
    SET m_reply->query_qual[ml_loop].orderid = reply->query_qual[ml_loop].hide#orderid
    SET m_reply->query_qual[ml_loop].dob = format(reply->query_qual[ml_loop].dob,"DD-MMM-YYYY;;d")
    SET m_reply->query_qual[ml_loop].contact_count = reply->query_qual[ml_loop].contact_count
  ENDFOR
  SELECT INTO "nl:"
   FROM person_alias pa
   WHERE expand(ndx,1,mreplycnt,pa.person_id,m_reply->query_qual[ndx].personid)
    AND pa.person_alias_type_cd=mf_cmrn_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
   DETAIL
    ml_pa_pos = locateval(lndx,1,mreplycnt,pa.person_id,m_reply->query_qual[lndx].personid), m_reply
    ->query_qual[ml_pa_pos].cmrn = pa.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM phone ph
   WHERE expand(ndx,1,mreplycnt,ph.parent_entity_id,m_reply->query_qual[ndx].personid)
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd=mf_phone_type_cd
    AND ph.phone_type_seq=1
    AND ph.active_ind=1
    AND ph.phone_num > " "
   ORDER BY ph.parent_entity_id
   HEAD ph.parent_entity_id
    ml_person_pos = locateval(lndx,1,mreplycnt,ph.parent_entity_id,m_reply->query_qual[lndx].personid
     )
    WHILE (ml_person_pos > 0)
     m_reply->query_qual[ml_person_pos].cell_phone = cnvtphone(cnvtalphanum(ph.phone_num),ph
      .phone_format_cd),ml_person_pos = locateval(lndx,(ml_person_pos+ 1),mreplycnt,ph
      .parent_entity_id,m_reply->query_qual[lndx].personid)
    ENDWHILE
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM person p,
    person_plan_reltn ppr,
    health_plan h,
    organization org
   PLAN (p
    WHERE expand(ndx,1,mreplycnt,p.person_id,m_reply->query_qual[ndx].personid))
    JOIN (ppr
    WHERE (ppr.person_id= Outerjoin(p.person_id))
     AND (ppr.active_ind= Outerjoin(1))
     AND (ppr.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
     AND (((ppr.priority_seq= Outerjoin(1)) ) OR ((ppr.priority_seq= Outerjoin(2)) )) )
    JOIN (h
    WHERE (h.health_plan_id= Outerjoin(ppr.health_plan_id))
     AND (h.active_ind= Outerjoin(1)) )
    JOIN (org
    WHERE (org.organization_id= Outerjoin(ppr.organization_id)) )
   ORDER BY p.person_id
   HEAD p.person_id
    ml_pos = locateval(lndx,1,mreplycnt,p.person_id,m_reply->query_qual[lndx].personid)
    WHILE (ml_pos > 0)
      IF (ppr.priority_seq=1)
       m_reply->query_qual[ml_pos].prim_insurance = org.org_name
      ELSE
       m_reply->query_qual[ml_pos].sec_insurance = org.org_name
      ENDIF
      m_reply->query_qual[ml_pos].language_spoken = uar_get_code_display(p.language_cd), m_reply->
      query_qual[ml_pos].person_first_name = p.name_first, m_reply->query_qual[ml_pos].
      person_last_name = p.name_last,
      ml_pos = locateval(lndx,(ml_pos+ 1),mreplycnt,p.person_id,m_reply->query_qual[lndx].personid)
    ENDWHILE
   WITH nocounter
  ;end select
  SELECT INTO  $OUTDEV
   language_spoken = m_reply->query_qual[d.seq].language_spoken, patient_cell_phone = m_reply->
   query_qual[d.seq].cell_phone, patient_home_phone = m_reply->query_qual[d.seq].home_phone,
   person_first_name = substring(1,100,m_reply->query_qual[d.seq].person_first_name),
   person_last_name = substring(1,100,m_reply->query_qual[d.seq].person_last_name), dob = m_reply->
   query_qual[d.seq].dob,
   exam_type = substring(1,100,m_reply->query_qual[d.seq].appt_type_display), contact_count = m_reply
   ->query_qual[d.seq].contact_count, primary_insurance = substring(1,100,m_reply->query_qual[d.seq].
    prim_insurance),
   secondary_insurance = substring(1,100,m_reply->query_qual[d.seq].sec_insurance), order_date =
   m_reply->query_qual[d.seq].order_date, earliest_date = m_reply->query_qual[d.seq].earliest_date,
   order_location = substring(1,100,replace(replace(m_reply->query_qual[d.seq].order_loc,char(13)," "
      ),char(10)," ")), ordering_provider = substring(1,100,m_reply->query_qual[d.seq].
    ordering_provider), order_id = m_reply->query_qual[d.seq].orderid,
   mrn = m_reply->query_qual[d.seq].mrn, cmrn = m_reply->query_qual[d.seq].cmrn
   FROM (dummyt d  WITH seq = value(mreplycnt))
   PLAN (d)
   WITH nocounter, format, separator = " "
  ;end select
  IF (textlen( $MEMAILSPREADSHEET) > 1)
   IF (findstring("@bhs.org",cnvtlower( $MEMAILSPREADSHEET))=0
    AND findstring("@baystatehealth.org",cnvtlower( $MEMAILSPREADSHEET))=0)
    SET ms_log = " Email is invalid - must be a valid '@bhs.org' or '@baystatehealth.org' address."
    GO TO exit_script
   ENDIF
   SELECT INTO value(ms_file_name)
    FROM (dummyt d  WITH seq = value(mreplycnt))
    PLAN (d)
    HEAD REPORT
     ms_temp = "Scheduling Request List Report", col 0, ms_temp,
     row + 1, ms_temp = ms_queue, col 0,
     ms_temp, row + 2, ms_temp = concat("language_spoken,","patient_cell_phone,","patient_home_cell,",
      "person_first_name,","person_last_name,",
      "dob,","exam_type,","contact_count,","insurance,","order_date,",
      "earliest_date,","order_location,","ordering_provider"),
     col 0, ms_temp
    DETAIL
     row + 1, ms_temp = build2('"',m_reply->query_qual[d.seq].language_spoken,'",','"',m_reply->
      query_qual[d.seq].cell_phone,
      '",','"',m_reply->query_qual[d.seq].home_phone,'",','"',
      m_reply->query_qual[d.seq].person_first_name,'",','"',m_reply->query_qual[d.seq].
      person_last_name,'",',
      '"',m_reply->query_qual[d.seq].dob,'",','"',m_reply->query_qual[d.seq].appt_type_display,
      '",','"',m_reply->query_qual[d.seq].contact_count,'",','"',
      m_reply->query_qual[d.seq].insurance,'",','"',m_reply->query_qual[d.seq].order_date,'",',
      '"',m_reply->query_qual[d.seq].earliest_date,'",','"',m_reply->query_qual[d.seq].order_loc,
      '",','"',m_reply->query_qual[d.seq].ordering_provider,'"'), col 0,
     ms_temp
    WITH nocounter, format = variable, maxrow = 1,
     maxcol = 5000, separator = " "
   ;end select
   EXECUTE bhs_ma_email_file
   CALL emailfile(ms_file_name,ms_file_name, $MEMAILSPREADSHEET,"BHS Scheduling Request List Report",
    1)
  ENDIF
 ELSE
  SET ms_log = " No data found."
  GO TO exit_script
 ENDIF
#exit_script
 IF (textlen(ms_log) > 1)
  SELECT INTO  $OUTDEV
   FROM dummyt d
   HEAD REPORT
    col 0, ms_log, row + 1
   WITH nocounter
  ;end select
 ENDIF
END GO
