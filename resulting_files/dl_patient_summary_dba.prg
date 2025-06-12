CREATE PROGRAM dl_patient_summary:dba
 PROMPT
  "Printer      " = "npi7a166A"
 IF (validate(reply->status_data,"ZZZ")="ZZZ")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request->script_name,"ZZZ")="ZZZ")
  FREE RECORD request
  RECORD request(
    1 encntr_id = f8
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[1]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[2]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
  SET request->output_device =  $1
  SET request->visit_cnt = 1
  SET request->visit[1].encntr_id = 1120473
 ENDIF
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 encntr_id = f8
     2 person_id = f8
     2 account_nbr = c20
     2 name_full_formatted = vc
     2 nurse_unit = c25
     2 pt_loc = c20
     2 org_name = vc
     2 isolation_disp = vc
     2 code_status = vc
     2 los = i4
     2 reason_for_visit = vc
     2 age = c12
     2 birth_dt_tm = dq8
     2 admit_dt = c20
     2 dschg_dt = dq8
     2 number_of_orders = i4
     2 orders[*]
       3 activity_type_disp = vc
       3 catalog_type_sort = i4
       3 catalog_type_disp = vc
       3 order_mnemonic = vc
       3 start_dt_tm = c20
       3 orig_order_dt_tm = c20
       3 order_status_cd = f8
       3 template_order_flag = f8
       3 order_status_disp = c20
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
       3 long_text = vc
       3 frequency_display = vc
       3 order_comment_ind = f8
       3 order_person = vc
       3 order_doctor = vc
     2 number_of_labs = i4
     2 labs[*]
       3 event_id = f8
       3 parent_event_id = f8
       3 event_cd_disp = vc
       3 result_val = vc
       3 result_units_disp = c25
       3 normal_low = c25
       3 normal_high = c25
       3 normalcy_disp = c25
       3 reference_range = c30
       3 event_end_dt_tm = dq8
       3 date = c25
       3 order_person = vc
       3 order_doctor = vc
     2 number_of_rorders = i4
     2 rorders[*]
       3 order_id = f8
       3 person_id = f8
       3 comments = vc
       3 results = vc
       3 procedure = vc
       3 mnemonic = vc
       3 activity_type_disp = vc
       3 catalog_type_sort = i4
       3 catalog_type_disp = vc
       3 order_mnemonic = vc
       3 start_dt_tm = c20
       3 orig_order_dt_tm = c20
       3 performed_dt_tm = c20
       3 order_status_cd = f8
       3 template_order_flag = f8
       3 order_status_disp = c20
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
       3 long_text = vc
       3 frequency_display = vc
       3 order_comment_ind = f8
       3 order_person = vc
       3 order_doctor = vc
       3 event_end_dt_tm = c20
       3 event_cd = f8
       3 author = c50
       3 doc_name = c50
       3 num_lines = i4
       3 text[*]
         4 text_line = vc
     2 number_of_meds = i4
     2 meds[*]
       3 order_id = f8
       3 person_id = f8
       3 comments = vc
       3 mnemonic = vc
       3 activity_type_disp = vc
       3 catalog_type_sort = i4
       3 catalog_type_disp = vc
       3 date = c20
       3 orig_order_dt_tm = c20
       3 order_status_cd = f8
       3 template_order_flag = f8
       3 order_status_disp = c20
       3 order_detail_display_line = vc
       3 display_line = vc
       3 long_text = vc
       3 freq = c30
       3 dose = c30
       3 doseunit = c30
       3 order_comment_ind = f8
       3 order_person = vc
       3 order_doctor = vc
       3 event_id = f8
       3 event_cd_disp = vc
       3 result_val = vc
       3 normal_low = c25
       3 normal_high = c25
       3 normalcy_disp = vc
       3 event_end_dt_tm = dq8
     2 admitdoc_name = vc
     2 admitdoc_alias = vc
     2 attenddoc_name = vc
     2 attenddoc_alias = vc
     2 total_al = i4
     2 allergy[*]
       3 source_identifier = vc
       3 source_string = vc
       3 type_source_string = vc
       3 allergy_dt_tm = vc
       3 diag_dt_tm = vc
       3 substance_type_disp = vc
       3 note = vc
       3 nomenclature_id = f8
       3 source_vocabulary_cd = f8
       3 source_vocabulary_disp = c40
       3 source_vocabulary_desc = c60
       3 source_vocabulary_mean = c12
     2 total_events = i4
     2 events[*]
       3 event_cd_disp = vc
       3 event_cd = f8
       3 event_type = vc
       3 event_dt_tm = vc
     2 total_isol = i4
     2 isolation[*]
       3 isolation_disp = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 DECLARE page_cnt = i4 WITH public, noconstant(0)
 DECLARE last_title = vc WITH public, noconstant(" ")
 DECLARE title_string = vc WITH public, noconstant(" ")
 DECLARE tempstring = vc WITH public, noconstant(" ")
 DECLARE temp = vc WITH public, noconstant(" ")
 DECLARE print_string = vc WITH public, noconstant(" ")
 DECLARE printstring = vc WITH public, noconstant(" ")
 DECLARE newstring = vc WITH public, noconstant(" ")
 DECLARE print_flag = i4 WITH public, noconstant(0)
 DECLARE line1 = vc WITH public, constant(fillstring(65,"_"))
 DECLARE equal_line = c90 WITH public, constant(fillstring(80,"="))
 DECLARE starline = vc WITH public, constant(fillstring(71,"*"))
 DECLARE filler = vc WITH public, constant(fillstring(100," "))
 DECLARE line2 = vc WITH public, constant(fillstring(100," "))
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE cntd = i4 WITH public, noconstant(0)
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE lastflag = i4 WITH public, noconstant(0)
 DECLARE tblobout = vc WITH public, noconstant(" ")
 DECLARE compressed_cd = f8
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,compressed_cd)
 DECLARE o_incomplete_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE o_inprocess_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE o_ordered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE o_pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE o_pending_rev_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE o_completed_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE allergy_cancelled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE e_encntr_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"ACTIVE"))
 DECLARE mrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE ssn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE account_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"ACCOUNT"))
 DECLARE fin_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE admitdoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE attenddoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE isolation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"ISOLATION"))
 DECLARE code_status_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"TSL"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE laboratory_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE generallab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE micro_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE ocfcomp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE codestatusnsg_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CODESTATUSNSG"
   ))
 DECLARE airborneprecautionotherthantb_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "AIRBORNEPRECAUTIONOTHERTHANTB"))
 DECLARE airborneprecautionsfortb_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "AIRBORNEPRECAUTIONSFORTB"))
 DECLARE contactprecautions_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONTACTPRECAUTIONS"))
 DECLARE dropletprecautions_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "DROPLETPRECAUTIONS"))
 DECLARE neutropenicprecautions_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "NEUTROPENICPRECAUTIONS"))
 DECLARE vremultidrugresistantorganismprecau_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",200,"VREMULTIDRUGRESISTANTORGANISMPRECAU"))
 DECLARE user_name = vc WITH public, noconstant(" ")
 DECLARE laboratory_cattyp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,
   "LABORATORY"))
 DECLARE anatomicpathology_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ANATOMICPATHOLOGY"))
 DECLARE bloodbank_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANK"))
 DECLARE generallab_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"
   ))
 DECLARE micro_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE radiology_cattyp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"RADIOLOGY"
   ))
 DECLARE ct_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CT"))
 DECLARE mri_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MRI"))
 DECLARE mammography_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "MAMMOGRAPHY"))
 DECLARE nuclearmedicine_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "NUCLEARMEDICINE"))
 DECLARE radiology_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGY"))
 DECLARE specialprocedures_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "SPECIALPROCEDURES"))
 DECLARE ultrasound_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ULTRASOUND"
   ))
 DECLARE pharmacy_cattyp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE pharmacy_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE ((p.username=curuser) OR (p.person_id=1))
  ORDER BY p.person_id
  DETAIL
   user_name = substring(1,35,p.name_full_formatted)
  WITH nocounter
 ;end select
 SELECT INTO "LOGFILE"
  FROM dummyt
  DETAIL
   col 0, user_name, " ",
   curdate, " ", curtime,
   " Patient Summary ", "  encntr_id = ", request->visit[1].encntr_id,
   row + 1
  WITH append, maxcol = 80
 ;end select
 IF ((request->visit_cnt > 0))
  SELECT INTO "nl:"
   nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd), pt_loc = concat(trim(uar_get_code_display(
      e.loc_room_cd)),"-",trim(uar_get_code_display(e.loc_bed_cd))), isolation_disp =
   uar_get_code_display(e.isolation_cd)
   FROM (dummyt dd  WITH seq = value(request->visit_cnt)),
    encounter e,
    encntr_alias ea,
    person p,
    organization o
   PLAN (dd)
    JOIN (e
    WHERE (e.encntr_id=request->visit[dd.seq].encntr_id))
    JOIN (ea
    WHERE outerjoin(e.encntr_id)=ea.encntr_id
     AND outerjoin(fin_cd)=ea.encntr_alias_type_cd
     AND ea.active_ind=outerjoin(1)
     AND ea.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND ea.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (p
    WHERE e.person_id=p.person_id
     AND p.active_ind=1)
    JOIN (o
    WHERE e.organization_id=o.organization_id)
   ORDER BY pt_loc, e.encntr_id
   HEAD REPORT
    cnt = 0
   HEAD pt_loc
    col + 0
   HEAD e.encntr_id
    IF (e.encntr_id > 0)
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(dlrec->seq,(cnt+ 10))
     ENDIF
     dlrec->seq[cnt].encntr_id = e.encntr_id, dlrec->seq[cnt].admit_dt = substring(1,14,format(e
       .reg_dt_tm,"@SHORTDATETIME;;Q")), dlrec->seq[cnt].reason_for_visit = e.reason_for_visit,
     dlrec->seq[cnt].name_full_formatted = trim(p.name_full_formatted), dlrec->seq[cnt].birth_dt_tm
      = p.birth_dt_tm, dlrec->seq[cnt].account_nbr = ea.alias,
     dlrec->seq[cnt].person_id = p.person_id, dlrec->seq[cnt].nurse_unit = nurse_unit, dlrec->seq[cnt
     ].pt_loc = pt_loc,
     dlrec->seq[cnt].isolation_disp = isolation_disp, dlrec->seq[cnt].org_name = o.org_name
    ENDIF
   FOOT  e.encntr_id
    col + 0
   FOOT  pt_loc
    col + 0
   FOOT REPORT
    stat = alterlist(dlrec->seq,cnt), dlrec->encntr_total = cnt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    orders o,
    order_action oa,
    prsnl p,
    prsnl p2,
    clinical_event c
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND o.catalog_type_cd=laboratory_cd
     AND o.activity_type_cd=generallab_cd
     AND o.template_order_flag IN (0, 1))
    JOIN (oa
    WHERE outerjoin(o.order_id)=oa.order_id
     AND outerjoin(order_cd)=oa.action_type_cd)
    JOIN (p
    WHERE outerjoin(oa.action_personnel_id)=p.person_id)
    JOIN (p2
    WHERE outerjoin(oa.order_provider_id)=p2.person_id)
    JOIN (c
    WHERE c.order_id=o.order_id
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND c.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime)
     AND c.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
     AND c.result_status_cd != inerror_cd)
   ORDER BY c.encntr_id, cnvtdatetime(c.event_end_dt_tm), c.parent_event_id
   HEAD REPORT
    cnt = 0
   HEAD c.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].labs,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].labs,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].labs[cnt].parent_event_id = c.parent_event_id, dlrec->seq[dd.seq].labs[cnt].
    event_cd_disp = uar_get_code_display(c.event_cd), dlrec->seq[dd.seq].labs[cnt].result_val = build
    (c.result_val,uar_get_code_display(c.normalcy_cd)),
    dlrec->seq[dd.seq].labs[cnt].date = format(c.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), dlrec->seq[dd
    .seq].labs[cnt].result_units_disp = uar_get_code_display(c.result_units_cd), dlrec->seq[dd.seq].
    labs[cnt].normalcy_disp = uar_get_code_display(c.normalcy_cd)
    IF (c.normal_low > " "
     AND c.normal_high > " ")
     dlrec->seq[dd.seq].labs[cnt].reference_range = build("(",c.normal_low,"-",c.normal_high,
      uar_get_code_display(c.result_units_cd),
      ")")
    ELSE
     dlrec->seq[dd.seq].labs[cnt].reference_range = "(Nrml rng unspecfd)"
    ENDIF
    dlrec->seq[dd.seq].labs[cnt].order_person = p.name_first, dlrec->seq[dd.seq].labs[cnt].
    order_doctor = p2.name_last
   FOOT  c.encntr_id
    stat = alterlist(dlrec->seq[dd.seq].labs,cnt), dlrec->seq[dd.seq].number_of_labs = cnt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   catalog_type_cdf = uar_get_code_meaning(o.catalog_type_cd), catalog_type_disp =
   uar_get_code_display(o.catalog_type_cd), activity_type_disp = uar_get_code_display(o
    .activity_type_cd),
   order_status_disp = uar_get_code_display(o.order_status_cd), result_val = substring(1,30,c
    .result_val), pco = substring(1,3,uar_get_code_display(c.event_reltn_cd))
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    orders o,
    order_action oa,
    prsnl p,
    prsnl p2,
    clinical_event c
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND o.orig_order_dt_tm BETWEEN cnvtdatetime((curdate - 1),curtime3) AND cnvtdatetime(curdate,
     curtime3)
     AND o.order_status_cd IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
    o_pending_rev_cd,
    o_completed_cd)
     AND o.template_order_flag IN (0, 1))
    JOIN (oa
    WHERE outerjoin(o.order_id)=oa.order_id
     AND outerjoin(order_cd)=oa.action_type_cd)
    JOIN (p
    WHERE outerjoin(oa.action_personnel_id)=p.person_id)
    JOIN (p2
    WHERE outerjoin(oa.order_provider_id)=p2.person_id)
    JOIN (c
    WHERE outerjoin(o.order_id)=c.order_id)
   ORDER BY o.encntr_id, catalog_type_disp, activity_type_disp,
    cnvtdatetime(o.orig_order_dt_tm), o.order_id
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].orders,10)
   HEAD catalog_type_disp
    col + 0
   HEAD activity_type_disp
    col + 0
   DETAIL
    col + 0, cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].orders,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].orders[cnt].order_mnemonic = o.order_mnemonic, dlrec->seq[dd.seq].orders[cnt].
    order_status_cd = o.order_status_cd, dlrec->seq[dd.seq].orders[cnt].order_status_disp =
    order_status_disp,
    dlrec->seq[dd.seq].orders[cnt].clinical_display_line = o.clinical_display_line, dlrec->seq[dd.seq
    ].orders[cnt].orig_order_dt_tm = substring(1,14,format(o.orig_order_dt_tm,"@SHORTDATETIME;;Q"))
   FOOT  activity_type_disp
    col + 0
   FOOT  catalog_type_disp
    col + 0
   FOOT  o.encntr_id
    stat = alterlist(dlrec->seq[dd.seq].orders,cnt), dlrec->seq[dd.seq].number_of_orders = cnt
   WITH nocounter, maxcol = 800
  ;end select
  SELECT INTO "nl:"
   blob_contents = substring(1,30000,ce.blob_contents)
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    orders o,
    order_action oa,
    prsnl p,
    prsnl p2,
    clinical_event c,
    ce_blob ce,
    clinical_event c2
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND o.catalog_type_cd=radiology_cattyp_cd
     AND o.activity_type_cd IN (ct_actvy_cd, mri_actvy_cd, mammography_actvy_cd,
    nuclearmedicine_actvy_cd, radiology_actvy_cd,
    specialprocedures_actvy_cd, ultrasound_actvy_cd))
    JOIN (oa
    WHERE outerjoin(o.order_id)=oa.order_id
     AND outerjoin(order_cd)=oa.action_type_cd)
    JOIN (p
    WHERE outerjoin(oa.action_personnel_id)=p.person_id)
    JOIN (p2
    WHERE outerjoin(oa.order_provider_id)=p2.person_id)
    JOIN (c
    WHERE c.person_id=o.person_id
     AND c.encntr_id=o.encntr_id
     AND c.order_id=o.order_id
     AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    JOIN (c2
    WHERE c2.parent_event_id=c.event_id
     AND c2.performed_dt_tm > cnvtdatetime((curdate - 1),curtime))
    JOIN (ce
    WHERE ce.event_id=outerjoin(c2.event_id)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   ORDER BY o.encntr_id, o.order_id, ce.event_id
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].rorders,cnt), testflag = 0
   HEAD o.order_id
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].rorders,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].rorders[cnt].order_mnemonic, dlrec->seq[dd.seq].rorders[cnt].order_id = c
    .order_id
   HEAD ce.event_id
    blob_out = fillstring(30000," "), blob_out2 = blob_out, blob_ret_len = 0
    IF (ce.compression_cd=compressed_cd)
     CALL uar_ocf_uncompress(blob_contents,30000,blob_out,30000,blob_ret_len)
    ELSE
     blob_out = blob_contents
    ENDIF
    CALL uar_rtf2(blob_out,blob_ret_len,blob_out2,30000,blob_ret_len,1), dlrec->seq[dd.seq].rorders[
    cnt].comments = blob_out2
    IF (blob_ret_len > 1000)
     FOR (pp = 1 TO blob_ret_len)
       IF (ichar(substring(pp,1,blob_out2)) != 32)
        IF (ichar(substring((pp - 1),1,blob_out2))=32)
         newstring = concat(newstring," ",substring(pp,1,blob_out2))
        ELSE
         newstring = concat(newstring,substring(pp,1,blob_out2))
        ENDIF
       ENDIF
     ENDFOR
     dlrec->seq[dd.seq].rorders[cnt].comments = newstring
    ENDIF
    dlrec->seq[dd.seq].rorders[cnt].order_mnemonic = o.order_mnemonic, dlrec->seq[dd.seq].rorders[cnt
    ].order_status_cd = o.order_status_cd, dlrec->seq[dd.seq].rorders[cnt].order_status_disp =
    uar_get_code_display(o.order_status_cd),
    dlrec->seq[dd.seq].rorders[cnt].clinical_display_line = o.clinical_display_line, dlrec->seq[dd
    .seq].rorders[cnt].performed_dt_tm = substring(1,14,format(c2.performed_dt_tm,"@SHORTDATETIME;;Q"
      ))
   FOOT  ce.event_id
    col + 0
   FOOT  o.order_id
    col + 0
   FOOT  o.encntr_id
    stat = alterlist(dlrec->seq[dd.seq].rorders,cnt), dlrec->seq[dd.seq].number_of_rorders = cnt
   WITH nocounter
  ;end select
  FOR (x = 1 TO dlrec->encntr_total)
    FOR (y = 1 TO dlrec->seq[x].number_of_rorders)
      SET pt->line_cnt = 0
      SET max_length = 100
      EXECUTE dcp_parse_text value(dlrec->seq[x].rorders[y].comments), value(max_length)
      SET stat = alterlist(dlrec->seq[x].rorders[y].text,pt->line_cnt)
      SET dlrec->seq[x].rorders[y].num_lines = pt->line_cnt
      FOR (w = 1 TO pt->line_cnt)
        SET dlrec->seq[x].rorders[y].text[w].text_line = pt->lns[w].line
      ENDFOR
    ENDFOR
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    orders o,
    order_action oa,
    prsnl p,
    prsnl p2,
    order_detail od
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND o.catalog_type_cd=pharmacy_cattyp_cd
     AND o.order_status_cd IN (o_ordered_cd, o_pending_cd, o_inprocess_cd)
     AND o.template_order_flag IN (0, 1)
     AND o.orig_order_dt_tm > cnvtdatetime((curdate - 1),curtime))
    JOIN (oa
    WHERE outerjoin(o.order_id)=oa.order_id
     AND outerjoin(order_cd)=oa.action_type_cd)
    JOIN (p
    WHERE outerjoin(oa.action_personnel_id)=p.person_id)
    JOIN (p2
    WHERE outerjoin(oa.order_provider_id)=p2.person_id)
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT"))
   ORDER BY o.encntr_id, cnvtdatetime(o.orig_order_dt_tm), od.action_sequence
   HEAD REPORT
    cnt = 0
   HEAD o.encntr_id
    cnt = 0
   HEAD o.order_id
    cnt = (cnt+ 1), stat = alterlist(dlrec->seq[dd.seq].meds,cnt), dlrec->seq[dd.seq].meds[cnt].
    mnemonic = o.order_mnemonic,
    dlrec->seq[dd.seq].meds[cnt].display_line = o.clinical_display_line, dlrec->seq[dd.seq].meds[cnt]
    .date = format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;d")
   DETAIL
    IF (od.oe_field_meaning="FREQ")
     dlrec->seq[dd.seq].meds[cnt].freq = od.oe_field_display_value
    ELSEIF (((od.oe_field_meaning="FREETXTDOSE") OR (od.oe_field_meaning="DOSE")) )
     dlrec->seq[dd.seq].meds[cnt].dose = od.oe_field_display_value
    ELSEIF (od.oe_field_meaning="DOSEUNIT")
     dlrec->seq[dd.seq].meds[cnt].doseunit = od.oe_field_display_value
    ENDIF
    IF (p.name_first > " ")
     dlrec->seq[dd.seq].meds[cnt].order_person = p.name_first
    ENDIF
    IF (p2.name_last > " ")
     dlrec->seq[dd.seq].meds[cnt].order_doctor = p2.name_full_formatted
    ENDIF
   FOOT  o.order_id
    IF ((dlrec->seq[dd.seq].meds[cnt].dose > " ")
     AND (dlrec->seq[dd.seq].meds[cnt].doseunit > " "))
     dlrec->seq[dd.seq].meds[cnt].dose = concat(trim(dlrec->seq[dd.seq].meds[cnt].dose)," ",trim(
       dlrec->seq[dd.seq].meds[cnt].doseunit))
    ENDIF
   FOOT  o.encntr_id
    dlrec->seq[dd.seq].number_of_meds = cnt
   FOOT REPORT
    col + 0
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    encntr_prsnl_reltn epr,
    prsnl pl,
    prsnl_alias pla
   PLAN (dd)
    JOIN (epr
    WHERE (epr.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND epr.active_ind=1
     AND epr.encntr_prsnl_r_cd IN (attenddoc_cd, admitdoc_cd))
    JOIN (pl
    WHERE pl.person_id=outerjoin(epr.prsnl_person_id))
    JOIN (pla
    WHERE pla.person_id=outerjoin(pl.person_id))
   DETAIL
    IF (epr.encntr_prsnl_r_cd=attenddoc_cd)
     dlrec->seq[dd.seq].attenddoc_name = pl.name_full_formatted, dlrec->seq[dd.seq].attenddoc_alias
      = pla.alias
    ELSE
     dlrec->seq[dd.seq].admitdoc_name = pl.name_full_formatted, dlrec->seq[dd.seq].admitdoc_alias =
     pla.alias
    ENDIF
   WITH check
  ;end select
  SELECT DISTINCT INTO "nl:"
   short_source_string = concat(trim(substring(1,40,n.source_string)),trim(substring(1,40,a
      .substance_ftdesc))), substance_type_disp =
   IF (uar_get_code_display(a.substance_type_cd) > " ") uar_get_code_display(a.substance_type_cd)
   ELSE "Other "
   ENDIF
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    allergy a,
    nomenclature n
   PLAN (dd)
    JOIN (a
    WHERE (a.person_id=dlrec->seq[dd.seq].person_id)
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
     AND a.reaction_status_cd != allergy_cancelled_cd)
    JOIN (n
    WHERE outerjoin(a.substance_nom_id)=n.nomenclature_id)
   ORDER BY a.person_id, substance_type_disp, short_source_string
   HEAD a.person_id
    al = 1, stat = alterlist(dlrec->seq[dd.seq].allergy,10)
   DETAIL
    dlrec->seq[dd.seq].allergy[al].source_string = short_source_string, dlrec->seq[dd.seq].allergy[al
    ].substance_type_disp = substance_type_disp
    IF ((dlrec->seq[dd.seq].allergy[al].source_string > " ")
     AND (dlrec->seq[dd.seq].allergy[al].substance_type_disp > " "))
     IF (((al=1) OR (al > 1
      AND (dlrec->seq[dd.seq].allergy[al].source_string != dlrec->seq[dd.seq].allergy[(al - 1)].
     source_string))) )
      IF (mod(al,10)=1)
       stat = alterlist(dlrec->seq[dd.seq].allergy,(al+ 10))
      ENDIF
      dlrec->seq[dd.seq].allergy[al].type_source_string = concat(build(substance_type_disp,": ")," ",
       short_source_string), dlrec->seq[dd.seq].allergy[al].source_string = short_source_string,
      dlrec->seq[dd.seq].allergy[al].substance_type_disp = substance_type_disp,
      dlrec->seq[dd.seq].allergy[al].allergy_dt_tm = substring(1,14,format(a.updt_dt_tm,
        "@SHORTDATETIME;;Q")), al = (al+ 1)
     ENDIF
    ENDIF
   FOOT  a.person_id
    stat = alterlist(dlrec->seq[dd.seq].allergy,al), dlrec->seq[dd.seq].total_al = al
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    clinical_event c
   PLAN (dd)
    JOIN (c
    WHERE (dlrec->seq[dd.seq].encntr_id=c.encntr_id)
     AND c.event_cd=isolation_cd
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
     AND c.result_status_cd != inerror_cd
     AND c.event_tag > " ")
   ORDER BY c.encntr_id, c.event_cd, c.event_id
   HEAD c.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].events,10)
   HEAD c.event_id
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].events,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].events[cnt].event_type = c.event_tag, dlrec->seq[dd.seq].events[cnt].event_cd
     = c.event_cd, dlrec->seq[dd.seq].events[cnt].event_cd_disp = uar_get_code_display(c.event_cd),
    dlrec->seq[dd.seq].events[cnt].event_dt_tm = substring(1,14,format(c.updt_dt_tm,
      "@SHORTDATETIME;;Q"))
   FOOT  c.encntr_id
    stat = alterlist(dlrec->seq[dd.seq].events,cnt), dlrec->seq[dd.seq].total_events = cnt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    orders o,
    order_detail od
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND ((o.catalog_cd+ 0) IN (codestatusnsg_cd, airborneprecautionotherthantb_cd,
    airborneprecautionsfortb_cd, contactprecautions_cd, dropletprecautions_cd,
    neutropenicprecautions_cd, vremultidrugresistantorganismprecau_cd))
     AND o.active_ind=1)
    JOIN (od
    WHERE o.order_id=od.order_id
     AND od.oe_field_meaning IN ("ISOLATIONCODE", "OTHER"))
   ORDER BY o.encntr_id, cnvtdatetime(o.orig_order_dt_tm), o.order_id,
    od.action_sequence
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].isolation,10)
   DETAIL
    IF (o.catalog_cd=codestatusnsg_cd)
     dlrec->seq[dd.seq].code_status = od.oe_field_display_value
    ELSE
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(dlrec->seq[dd.seq].isolation,(cnt+ 10))
     ENDIF
     dlrec->seq[dd.seq].isolation[cnt].isolation_disp = build(uar_get_code_description(o.catalog_cd),
      " - ",od.oe_field_display_value)
    ENDIF
   FOOT  o.encntr_id
    stat = alterlist(dlrec->seq[dd.seq].isolation,cnt), dlrec->seq[dd.seq].total_isol = cnt
   WITH nocounter
  ;end select
  SELECT INTO request->output_device
   FROM (dummyt d  WITH seq = 1)
   HEAD REPORT
    xcol1 = 26, xcol2 = 80, xcol3 = 90,
    xcol4 = 140, xcol5 = 200, xcol8 = 340,
    xcol9 = 375, xcol10 = 360, xcol11 = 410,
    xcol12 = 440, xcolvar = xcol1, yrow1 = 5,
    last_encntr_id = 0.0, lcol1[2] = 0, lcol2[2] = 0,
    lcol3[2] = 0, gap = 80, lcol1[1] = xcol1,
    lcol2[1] = (lcol1[1]+ gap), lcol3[1] = (lcol2[1]+ gap), lcol1[2] = (lcol3[1]+ gap),
    lcol2[2] = (lcol1[2]+ gap), lcol3[2] = (lcol2[2]+ gap), printer_disp = request->output_device
    IF (printer_disp="cer_temp:*")
     printer_disp = "Screen"
    ENDIF
    MACRO (title_print)
     row + 1, yrow1 = (yrow1+ 5),
     CALL print(calcpos(xcol1,yrow1)),
     "{bold}", title_string, line1,
     CALL print(calcpos(xcol5,yrow1)), line1, "{endbold}",
     row + 1, yrow1 = (yrow1+ 5), last_title = title_string,
     rowplusone2
    ENDMACRO
    ,
    MACRO (calcpos_print)
     maxpos = (colpos+ size(trim(tempstring)))
     IF (maxpos > 80)
      row + 1, colpos = 20, col colpos,
      "{color/0}", tempstring
     ELSE
      col colpos, tempstring, "\"
     ENDIF
     colpos = ((colpos+ size(trim(tempstring)))+ 1)
    ENDMACRO
    ,
    MACRO (rowplusone)
     yrow1 = (yrow1+ 10), row + 1
     IF (yrow1 > 650)
      BREAK
     ENDIF
    ENDMACRO
    ,
    MACRO (rowplusone2)
     yrow1 = (yrow1+ 10), row + 1
    ENDMACRO
    ,
    MACRO (line_wrap2)
     limit = 0, maxlen = 80, cr = char(13)
     WHILE (tempstring > " "
      AND limit < 1000)
       ii = 0, limit = (limit+ 1), pos = 0
       WHILE (pos=0)
        ii = (ii+ 1),
        IF (substring((maxlen - ii),1,tempstring) IN (" ", cr))
         pos = (maxlen - ii)
        ELSEIF (ii=maxlen)
         pos = maxlen
        ENDIF
       ENDWHILE
       printstring = substring(1,pos,tempstring),
       CALL print(calcpos(xcolvar,yrow1)), printstring,
       rowplusone, tempstring = substring((pos+ 1),9999,tempstring)
     ENDWHILE
    ENDMACRO
    ,
    MACRO (line_wrap)
     limit = 0, maxlen = 80, cr = char(10)
     WHILE (tempstring > " "
      AND limit < 1000)
       ii = 0, limit = (limit+ 1), pos = 0
       WHILE (pos=0)
        ii = (ii+ 1),
        IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", ".", cr))
         pos = (maxlen - ii)
        ELSEIF (ii=maxlen)
         pos = maxlen
        ENDIF
       ENDWHILE
       printstring = substring(1,pos,tempstring),
       CALL print(calcpos(xcolvar,yrow1)), "{color/0}",
       printstring, rowplusone, tempstring = substring((pos+ 1),9999,tempstring)
     ENDWHILE
    ENDMACRO
   HEAD PAGE
    yrow1 = 35
    IF ((dlrec->seq[i].encntr_id != last_encntr_id))
     page_cnt = 0, last_encntr_id = dlrec->seq[i].encntr_id
    ENDIF
    page_cnt = (page_cnt+ 1)
    IF (i=0)
     i = 1
    ENDIF
    CALL center("CLINICAL SUMMARY",1,80), row + 1, col 1,
    "{b}", dlrec->seq[i].name_full_formatted, "{endb}",
    col 60, dlrec->seq[i].nurse_unit, dlrec->seq[i].pt_loc,
    row + 1, col 1, equal_line,
    row + 1, col 5, "MRN:",
    col
   DETAIL
    FOR (i = 1 TO dlrec->encntr_total)
      IF (i > 1)
       BREAK
      ENDIF
      colpos2 = 0, title_string = "Allergies:", title_print
      FOR (a = 1 TO dlrec->seq[i].total_al)
        CALL print(calcpos(xcol1,yrow1)), "{b}", dlrec->seq[i].allergy[a].allergy_dt_tm,
        CALL print(calcpos(xcol3,yrow1)), dlrec->seq[i].allergy[a].type_source_string, rowplusone
      ENDFOR
      lastflag = 0, title_string = "Labs:", title_print,
      colgroup = 0, lastparent_event_id = 0.0, lastdate = fillstring(20," ")
      FOR (a = 1 TO dlrec->seq[i].number_of_labs)
        colgroup = (colgroup+ 1)
        IF (colgroup > 2)
         colgroup = 1, rowplusone
        ENDIF
        IF ((a=dlrec->seq[i].number_of_labs))
         lastflag = 1
        ENDIF
        IF ((((dlrec->seq[i].labs[a].parent_event_id != lastparent_event_id)) OR ((dlrec->seq[i].
        labs[a].date != lastdate))) )
         lastparent_event_id = dlrec->seq[i].labs[a].parent_event_id, lastdate = dlrec->seq[i].labs[a
         ].date, colgroup = 1
         IF (a > 1)
          rowplusone
         ENDIF
         CALL print(calcpos(lcol1[colgroup],yrow1)), "{b}", dlrec->seq[i].labs[a].date,
         "{endb}", rowplusone
        ENDIF
        CALL print(calcpos(lcol1[colgroup],yrow1)), dlrec->seq[i].labs[a].event_cd_disp, row + 1,
        CALL print(calcpos(lcol2[colgroup],yrow1)), "{b}", dlrec->seq[i].labs[a].result_val,
        "{endb}", row + 1,
        CALL print(calcpos(lcol3[colgroup],yrow1)),
        dlrec->seq[i].labs[a].reference_range, row + 1
      ENDFOR
      rowplusone, lastflag = 0, title_string = "Radiology Reports:",
      title_print
      FOR (a = 1 TO dlrec->seq[i].number_of_rorders)
        IF ((a=dlrec->seq[i].number_of_rorders))
         lastflag = 1
        ENDIF
        CALL print(calcpos(xcol1,yrow1)), "{b}", dlrec->seq[i].rorders[a].performed_dt_tm,
        "{endb}", rowplusone,
        CALL print(calcpos(xcol3,yrow1)),
        "{b}", dlrec->seq[i].rorders[a].order_mnemonic, "{endb}",
        rowplusone, xcolvar = xcol1, tempstring = dlrec->seq[i].rorders[a].comments,
        line_wrap2
      ENDFOR
      rowplusone, lastflag = 0, title_string = "Medications:",
      title_print, lastdatedoc = fillstring(90," ")
      FOR (a = 1 TO dlrec->seq[i].number_of_meds)
        IF ((a=dlrec->seq[i].number_of_meds))
         lastflag = 1
        ENDIF
        IF (build(dlrec->seq[i].meds[a].date,dlrec->seq[i].meds[a].order_doctor) != lastdatedoc)
         rowplusone,
         CALL print(calcpos(xcol1,yrow1)), "{b}",
         dlrec->seq[i].meds[a].date, " per ", dlrec->seq[i].meds[a].order_doctor,
         "{endb}", lastdatedoc = build(dlrec->seq[i].meds[a].date,dlrec->seq[i].meds[a].order_doctor),
         rowplusone
        ENDIF
        xcolvar = xcol5,
        CALL print(calcpos((xcol1+ 7),yrow1)), "{b}",
        dlrec->seq[i].meds[a].mnemonic, "{endb}"
        IF (size(trim(dlrec->seq[i].meds[a].mnemonic)) > 44)
         rowplusone
        ENDIF
        tempstring = concat(dlrec->seq[i].meds[a].display_line," per ",dlrec->seq[i].meds[a].
         order_person), line_wrap
      ENDFOR
      rowplusone
    ENDFOR
    rowplusone,
    CALL print(calcpos(xcol5,yrow1)), "** End of Patient Summary **",
    row + 1
   WITH maxcol = 366, maxrow = 166
  ;end select
  SET reply->status_data.status = "S"
 ELSE
  SELECT INTO request->output_device
   DETAIL
    col 1, starline, row + 3,
    col 1, "                                INVALID DATA ENTERED", row + 3,
    col 1, "Printer: ", request->output_device,
    row + 1, col 1, starline,
    row + 1
   WITH nocounter
  ;end select
 ENDIF
#endprog
 FREE RECORD encntr_list
 FREE RECORD dlrec
 FREE RECORD pt
END GO
