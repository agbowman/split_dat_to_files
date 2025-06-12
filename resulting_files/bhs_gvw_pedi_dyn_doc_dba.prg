CREATE PROGRAM bhs_gvw_pedi_dyn_doc:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_scnt = i4
   1 squal[*]
     2 s_section = vc
     2 l_dcnt = i4
     2 dqual[*]
       3 s_dta_description = vc
       3 s_dta_response = vc
 ) WITH protect
 FREE RECORD m_form
 RECORD m_form(
   1 l_ecnt = i4
   1 equal[*]
     2 f_event_cd = f8
     2 l_event_seq = i4
 ) WITH protect
 DECLARE mf_swycform_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"SWYCFORM"))
 DECLARE mf_autism_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"MCHATRFFORM"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE ms_rhead = vc WITH protect, constant(
  "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}}\deftab250\plain \f0 \fs18 ")
 DECLARE ms_reol = vc WITH protect, constant("\par ")
 DECLARE ms_reop = vc WITH protect, constant("\pard ")
 DECLARE ms_rh2r = vc WITH protect, constant("\pard\plain\f0\fs18 ")
 DECLARE ms_rh2b = vc WITH protect, constant("\pard\plain\f0\fs18\b ")
 DECLARE ms_rh2bu = vc WITH protect, constant("\pard\plain\f0\fs18\b\ul ")
 DECLARE ms_rh2u = vc WITH protect, constant("\pard\plain\f0\fs18\u ")
 DECLARE ms_rh2i = vc WITH protect, constant("\pard\plain\f0\fs18\i ")
 DECLARE ms_rtab = vc WITH protect, constant("\tab ")
 DECLARE ms_rbopt = vc WITH protect, constant(
  "\pard \tx1200\tx1900\tx2650\tx3325\tx3800\tx4400\tx5050\tx5750\tx6500 ")
 DECLARE ms_wr = vc WITH protect, constant("\plain\f0\fs18 ")
 DECLARE ms_wb = vc WITH protect, constant("\plain\f0\fs18\b ")
 DECLARE ms_wu = vc WITH protect, constant("\plain\f0\fs18 \ul\b ")
 DECLARE ms_wbi = vc WITH protect, constant("\plain\f0\fs18\b\i ")
 DECLARE ms_ws = vc WITH protect, constant("\plain\f0\fs18\strike ")
 DECLARE ms_hi = vc WITH protect, constant("\pard\fi-1050\li1050 ")
 DECLARE ms_rtfeof = vc WITH protect, constant("}")
 DECLARE mf_enc_id = f8 WITH protect, noconstant(0.00)
 DECLARE mf_per_id = f8 WITH protect, noconstant(0.00)
 DECLARE md_reg_dt_tm = dq8 WITH protect
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_text = vc WITH protect, noconstant(" ")
 DECLARE ml_scnt = i4 WITH protect, noconstant(0)
 DECLARE ml_dcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ecnt = i4 WITH protect, noconstant(0)
 DECLARE mf_swycform_event_id = f8 WITH protect, noconstant(0.00)
 DECLARE mf_autism_event_id = f8 WITH protect, noconstant(0.0)
 SET mf_enc_id = request->visit[1].encntr_id
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=mf_enc_id)
  HEAD REPORT
   mf_per_id = e.person_id, md_reg_dt_tm = e.reg_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp,
   discrete_task_assay dta
  PLAN (dfr
   WHERE dfr.description IN ("SWYC The Survey of Well-Being of Young Children",
   "Modified Checklist for Autism in Toddlers - R/F - BHS")
    AND dfr.active_ind=1)
   JOIN (dfd
   WHERE dfr.dcp_form_instance_id=dfd.dcp_form_instance_id
    AND dfd.active_ind=1)
   JOIN (dsr
   WHERE dfd.dcp_section_ref_id=dsr.dcp_section_ref_id
    AND dsr.active_ind=1)
   JOIN (dir
   WHERE dsr.dcp_section_instance_id=dir.dcp_section_instance_id
    AND dir.active_ind=1
    AND  NOT (cnvtupper(dir.description) IN ("LABEL", "ALLERGIES", "IMAGE*")))
   JOIN (nvp
   WHERE dir.dcp_input_ref_id=nvp.parent_entity_id
    AND nvp.active_ind=1
    AND nvp.pvc_name IN ("discrete_task_assay", "discrete_task_assay2"))
   JOIN (dta
   WHERE nvp.merge_id=dta.task_assay_cd
    AND dta.active_ind=1)
  ORDER BY dfr.description, dfd.section_seq, dir.input_ref_seq,
   dta.mnemonic_key_cap
  HEAD REPORT
   ml_ecnt = 0
  DETAIL
   ml_ecnt += 1, m_form->l_ecnt = ml_ecnt, stat = alterlist(m_form->equal,ml_ecnt),
   m_form->equal[ml_ecnt].f_event_cd = dta.event_cd, m_form->equal[ml_ecnt].l_event_seq = dir
   .input_ref_seq
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event cef
  PLAN (cef
   WHERE cef.person_id=mf_per_id
    AND cef.event_cd IN (mf_swycform_cd, mf_autism_cd)
    AND cef.event_end_dt_tm >= cnvtdatetime(md_reg_dt_tm)
    AND cef.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND cef.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd)
    AND cef.encntr_id=mf_enc_id)
  ORDER BY cef.event_cd, cef.event_end_dt_tm DESC
  HEAD cef.event_cd
   IF (cef.event_cd=mf_swycform_cd)
    mf_swycform_event_id = cef.event_id
   ELSE
    mf_autism_event_id = cef.event_id
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build2("mf_autism_event_id: ",mf_autism_event_id))
 IF (mf_swycform_event_id=0.00)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pl_form_sort =
  IF (cef.event_id=mf_swycform_event_id) 1
  ELSE 2
  ENDIF
  , input_seq = m_form->equal[d.seq].l_event_seq
  FROM clinical_event cef,
   clinical_event ces,
   clinical_event cec,
   dummyt dg,
   clinical_event ceg,
   (dummyt d  WITH seq = m_form->l_ecnt)
  PLAN (cef
   WHERE cef.event_id IN (mf_swycform_event_id, mf_autism_event_id)
    AND cef.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (ces
   WHERE ces.parent_event_id=cef.event_id
    AND ces.event_id != cef.event_id
    AND ces.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (cec
   WHERE cec.parent_event_id=ces.event_id
    AND cec.event_id != ces.event_id
    AND cec.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND cec.event_cd > 0.00)
   JOIN (dg)
   JOIN (ceg
   WHERE ceg.parent_event_id=cec.event_id
    AND ceg.event_id != cec.event_id
    AND ceg.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (d
   WHERE (((m_form->equal[d.seq].f_event_cd=cec.event_cd)) OR ((m_form->equal[d.seq].f_event_cd=ceg
   .event_cd))) )
  ORDER BY cef.encntr_id, pl_form_sort, cef.event_id,
   cef.collating_seq, ces.collating_seq, input_seq,
   ceg.collating_seq, ceg.event_cd
  HEAD REPORT
   ml_scnt = 0
  HEAD cef.encntr_id
   null
  HEAD cef.event_id
   null
  HEAD cef.collating_seq
   null
  HEAD ces.collating_seq
   ml_scnt += 1, m_rec->l_scnt = ml_scnt, stat = alterlist(m_rec->squal,ml_scnt)
   IF (cef.event_id=mf_swycform_event_id)
    m_rec->squal[ml_scnt].s_section = replace(uar_get_code_display(cec.event_cd),"- Grid","")
   ELSE
    m_rec->squal[ml_scnt].s_section = trim(ces.event_title_text,3)
   ENDIF
   ml_dcnt = 0
  HEAD input_seq
   null
  HEAD ceg.collating_seq
   null
  HEAD ceg.event_cd
   ml_dcnt += 1, m_rec->squal[ml_scnt].l_dcnt = ml_dcnt, stat = alterlist(m_rec->squal[ml_scnt].dqual,
    ml_dcnt)
   IF (ceg.task_assay_cd > 0.00)
    m_rec->squal[ml_scnt].dqual[ml_dcnt].s_dta_description = trim(uar_get_definition(ceg
      .task_assay_cd)), m_rec->squal[ml_scnt].dqual[ml_dcnt].s_dta_response = trim(ceg.result_val)
   ELSE
    m_rec->squal[ml_scnt].dqual[ml_dcnt].s_dta_description = trim(uar_get_code_display(cec.event_cd)),
    m_rec->squal[ml_scnt].dqual[ml_dcnt].s_dta_response = trim(cec.result_val)
   ENDIF
  WITH outerjoin = dg, dontcare = ceg, outerjoin = d,
   nocounter
 ;end select
 IF ( NOT ((m_rec->l_scnt > 0)))
  GO TO exit_script
 ENDIF
 SET ms_text = ms_rhead
 FOR (ml_sloop = 1 TO m_rec->l_scnt)
   SET ms_line = concat(ms_wb,"{",trim(m_rec->squal[ml_sloop].s_section),"} ",ms_reol)
   SET ms_text = concat(ms_text,ms_line)
   FOR (ml_dloop = 1 TO m_rec->squal[ml_sloop].l_dcnt)
    SET ms_line = concat(ms_wb,ms_rtab,"{",trim(m_rec->squal[ml_sloop].dqual[ml_dloop].
      s_dta_description),": } ",
     ms_wr,"{",trim(m_rec->squal[ml_sloop].dqual[ml_dloop].s_dta_response),"} ",ms_reol)
    SET ms_text = concat(ms_text,ms_line)
   ENDFOR
   SET ms_text = concat(ms_text,ms_reol)
 ENDFOR
 SET reply->text = concat(ms_text,ms_rtfeof)
#exit_script
 CALL echorecord(m_rec)
 SET reply->status_data.status = "S"
END GO
