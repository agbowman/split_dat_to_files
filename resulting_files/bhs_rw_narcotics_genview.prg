CREATE PROGRAM bhs_rw_narcotics_genview
 FREE RECORD work
 RECORD work(
   1 person_id = f8
   1 encntr_id = f8
   1 o_cnt = i4
   1 ords[*]
     2 parentid = f8
     2 doc_order_id = f8
     2 doc_order_desc = vc
     2 doc_order_dt_tm = dq8
     2 doc_order_details = vc
     2 med_order_id = f8
     2 med_order_desc = vc
     2 med_order_dt_tm = dq8
     2 med_order_details = vc
     2 f_cnt = i4
     2 forms[*]
       3 dcp_forms_ref_id = f8
       3 dcp_forms_act_id = f8
       3 form_desc = vc
       3 form_dt_tm = dq8
       3 form_text = vc
   1 m_cnt = i4
   1 mords[*]
     2 parentid = f8
     2 bagstart = dq8
     2 med_order_desc = vc
     2 med_order_dt_tm = dq8
     2 med_order_details = vc
     2 doc_order_dt_tm = dq8
     2 doc_order_desc = vc
 )
 IF (validate(request->visit[1].encntr_id,0.00) > 0.00)
  SET work->encntr_id = request->visit[1].encntr_id
 ELSEIF (cnvtreal(parameter(1,0)) > 0.00)
  SET work->encntr_id = cnvtreal(parameter(1,0))
  RECORD reply(
    1 text = vc
  )
 ELSE
  CALL echo("No valid encntr_id given. Exiting Script")
  GO TO exit_script
 ENDIF
 DECLARE cs200_narcotic_infusion_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICINFUSIONACCOUNTABILITY"))
 DECLARE cs200_narc_shift_doc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICSHIFTDOCUMENTATION"))
 DECLARE mf_narc_patch_acct_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICPATCHACCOUNTABILITY"))
 DECLARE mf_narc_patch_shift_doc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICPATCHSHIFTDOCUMENTATION"))
 DECLARE infusionstarttime = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"INFUSIONSTARTTIME"))
 DECLARE cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE cs6004_completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs18189_clincalevent_cd = f8 WITH constant(uar_get_code_by("MEANING",18189,"CLINCALEVENT"))
 CALL echo("select to find documentation orders")
 SELECT INTO "NL:"
  FROM orders o,
   clinical_event ce,
   dcp_forms_activity_comp dfac,
   dcp_forms_activity dfa,
   order_comment oc,
   long_text lt,
   dummyt d
  PLAN (o
   WHERE (o.encntr_id=work->encntr_id)
    AND ((o.catalog_cd+ 0) IN (cs200_narcotic_infusion_cd, cs200_narc_shift_doc_cd,
   mf_narc_patch_acct_cd, mf_narc_patch_shift_doc_cd))
    AND o.order_status_cd IN (cs6004_ordered_cd, cs6004_completed_cd))
   JOIN (oc
   WHERE o.order_id=oc.order_id
    AND oc.action_sequence=1)
   JOIN (lt
   WHERE oc.long_text_id=lt.long_text_id)
   JOIN (d)
   JOIN (ce
   WHERE o.encntr_id=ce.encntr_id
    AND o.order_id=ce.order_id
    AND ce.reference_nbr="*!0"
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_modified_cd, cs8_altered_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (dfac
   WHERE outerjoin(ce.event_id)=dfac.parent_entity_id
    AND dfac.component_cd=outerjoin(cs18189_clincalevent_cd))
   JOIN (dfa
   WHERE outerjoin(dfac.dcp_forms_activity_id)=dfa.dcp_forms_activity_id)
  ORDER BY ce.performed_dt_tm DESC, o.orig_order_dt_tm DESC
  HEAD REPORT
   o_cnt = 0, f_cnt = 0
  HEAD o.person_id
   work->person_id = o.person_id
  HEAD o.order_id
   o_cnt = (work->o_cnt+ 1), stat = alterlist(work->ords,o_cnt), work->o_cnt = o_cnt,
   work->ords[o_cnt].doc_order_id = o.order_id, work->ords[o_cnt].doc_order_desc = trim(o
    .hna_order_mnemonic,3), work->ords[o_cnt].doc_order_dt_tm = o.orig_order_dt_tm,
   work->ords[o_cnt].doc_order_details = trim(lt.long_text,3), work->ords[o_cnt].med_order_id =
   cnvtreal(substring((findstring("(ORDER_ID:",lt.long_text)+ 10),((findstring(")",lt.long_text,0,1)
      - findstring("(ORDER_ID:",lt.long_text)) - 10),lt.long_text))
   IF (ce.parent_event_id > 0)
    work->ords[o_cnt].parentid = ce.parent_event_id
   ENDIF
  DETAIL
   IF (dfa.dcp_forms_ref_id > 0.00)
    CALL echo("josh"),
    CALL echo(ce.parent_event_id),
    CALL echo(trim(format(cnvtdatetime(o.orig_order_dt_tm),";;q"))),
    CALL echo(trim(format(cnvtdatetime(ce.performed_dt_tm),";;q"))), f_cnt = (work->ords[o_cnt].f_cnt
    + 1), stat = alterlist(work->ords[o_cnt].forms,f_cnt),
    work->ords[o_cnt].f_cnt = f_cnt, work->ords[o_cnt].forms[f_cnt].dcp_forms_ref_id = dfa
    .dcp_forms_ref_id, work->ords[o_cnt].forms[f_cnt].dcp_forms_act_id = dfa.dcp_forms_activity_id,
    work->ords[o_cnt].forms[f_cnt].form_desc = dfa.description, work->ords[o_cnt].forms[f_cnt].
    form_dt_tm = dfa.form_dt_tm
   ENDIF
  WITH nocounter, outerjoin = d, dontcare = ce
 ;end select
 CALL echorecord(work)
 SELECT INTO "NL:"
  docdttm = work->ords[d.seq].doc_order_dt_tm, order_id = o.order_id
  FROM (dummyt d  WITH seq = value(work->o_cnt)),
   orders o
  PLAN (d
   WHERE (work->ords[d.seq].med_order_id > 0.00))
   JOIN (o
   WHERE (work->ords[d.seq].med_order_id=o.order_id)
    AND o.order_status_cd IN (cs6004_ordered_cd))
  ORDER BY o.orig_order_dt_tm DESC, o.order_id
  HEAD o.orig_order_dt_tm
   stat = 0
  HEAD o.order_id
   work->m_cnt = (work->m_cnt+ 1), stat = alterlist(work->mords,work->m_cnt), work->mords[work->m_cnt
   ].med_order_desc = trim(o.ordered_as_mnemonic,3),
   work->mords[work->m_cnt].med_order_dt_tm = o.orig_order_dt_tm, work->mords[work->m_cnt].
   med_order_details = trim(o.clinical_display_line,3), work->mords[work->m_cnt].doc_order_desc =
   work->ords[d.seq].doc_order_desc,
   work->mords[work->m_cnt].doc_order_dt_tm = work->ords[d.seq].doc_order_dt_tm, work->mords[work->
   m_cnt].parentid = work->ords[d.seq].parentid
  WITH nocounter
 ;end select
 CALL echorecord(work)
 IF ((work->m_cnt > 0))
  CALL echo("Select to find Begin bag DTA charted")
  SELECT INTO "NL:"
   FROM clinical_event ce,
    clinical_event ce1,
    clinical_event ce2,
    ce_date_result cdr,
    (dummyt d  WITH seq = value(work->m_cnt))
   PLAN (d)
    JOIN (ce
    WHERE (ce.parent_event_id=work->mords[d.seq].parentid)
     AND ce.parent_event_id > 0
     AND ce.event_cd != ce.parent_event_id
     AND ce.result_status_cd IN (cs8_auth_cd, cs8_modified_cd, cs8_altered_cd)
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (ce1
    WHERE ce1.parent_event_id=ce.event_id
     AND ce1.parent_event_id != ce1.event_id
     AND ce1.result_status_cd IN (cs8_auth_cd, cs8_modified_cd, cs8_altered_cd)
     AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.event_id != ce2.parent_event_id
     AND ce2.event_cd=infusionstarttime
     AND ce2.result_status_cd IN (cs8_auth_cd, cs8_modified_cd, cs8_altered_cd)
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (cdr
    WHERE cdr.event_id=ce2.event_id
     AND cdr.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce2.event_end_dt_tm DESC
   DETAIL
    CALL echo(format(cnvtdatetime(cdr.result_dt_tm),";;q")), work->mords[d.seq].bagstart =
    cnvtdatetime(cdr.result_dt_tm)
   WITH nocounter
  ;end select
 ELSE
  CALL echo("no Values in Work Rec")
 ENDIF
 SET beg_rtf = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}} \f0\fs20"
 SET end_rtf = "}"
 SET beg_bold = "\b"
 SET end_bold = "\b0"
 SET beg_uline = "\ul"
 SET end_uline = "\ulnone"
 SET beg_ital = "\i"
 SET end_ital = "\i0"
 SET new_line = concat(char(10),char(13))
 SET end_line = "\par"
 SET reply->text = build2(beg_rtf,new_line,beg_bold,beg_uline," Narcotic Infusion Summary",
  end_bold,end_uline,end_line,new_line)
 IF ((work->m_cnt <= 0))
  SET reply->text = build2(reply->text,end_line,new_line,beg_bold,
   " No Narcotic Infusion orders found",
   end_bold,end_line,new_line)
 ENDIF
 FREE RECORD narc_reply
 RECORD narc_reply(
   1 text = vc
 )
 FOR (c = 1 TO work->m_cnt)
   IF (c > 1)
    SET reply->text = build2(reply->text,new_line,
     "___________________________________________________________________________",
     "_______________________________________",end_line,
     new_line)
   ENDIF
   IF ((work->mords[c].bagstart != null))
    SET reply->text = build2(reply->text,end_line,new_line,beg_bold,
     "  Last recorded infuse start time : ",
     end_bold," ",format(work->mords[c].bagstart,";;q"))
   ENDIF
   IF (textlen(trim(work->mords[c].doc_order_desc,3)) <= 0.00)
    SET reply->text = build2(reply->text,end_line,new_line,beg_bold,"  Medication Order: Not Found",
     end_bold)
   ELSE
    SET reply->text = build2(reply->text,end_line,new_line,beg_bold,"  Medication Order: ",
     end_bold," ",work->mords[c].med_order_desc," ",work->mords[c].med_order_details)
   ENDIF
 ENDFOR
 SET reply->text = build2(reply->text,end_line,new_line,end_rtf)
 FREE RECORD narc_reply
 IF (reflect(parameter(1,0)) > " ")
  CALL echo(reply->text)
 ENDIF
#exit_script
END GO
