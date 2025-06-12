CREATE PROGRAM bhs_gvw_nicu_feeding_ords:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = gvc
    1 status_data[1]
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 mf_person_id = f8
   1 mf_encntr_id = f8
   1 mn_ords_cnt = i2
   1 ords[*]
     2 mf_order_id = f8
     2 ms_ord_as_mnemonic = vc
     2 ms_ord_mnemonic = vc
     2 ms_clin_display = vc
     2 ms_ord_provider = vc
     2 ms_orig_ord_dttm = vc
 ) WITH protect
 DECLARE mf_breastmilk_cs200 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "BREASTMILK"))
 DECLARE mf_formulainfant_cs200 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FORMULAINFANT"))
 DECLARE mf_formulaadditiveinfant_cs200 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FORMULAADDITIVEINFANT"))
 DECLARE mf_npo_cs200 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NPO"))
 DECLARE mf_donor_breast_milk_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DONORBREASTMILK"))
 DECLARE mf_inprocess_cs6004 = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE mf_medstudent_cs6004 = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"
   ))
 DECLARE mf_ordered_cs6004 = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_pending_cs6004 = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE mf_pendingrev_cs6004 = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDINGREV"
   ))
 DECLARE mf_unscheduled_cs6004 = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
   "UNSCHEDULED"))
 DECLARE mf_order_cs6003 = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE mf_fin_cs319 = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_nutritionservices_cs6000 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "NUTRITIONSERVICES"))
 DECLARE ms_rhead = vc WITH protect, constant(
  "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}\deftab1134")
 DECLARE ms_rh2b = vc WITH protect, constant("\plain \f0 \fs18 \b \cb2 \pard\sl0 ")
 DECLARE ms_reol = vc WITH protect, constant("\par ")
 DECLARE ms_wr = vc WITH protect, constant(" \plain \f0 \fs18 \cb2 ")
 DECLARE ms_wb = vc WITH protect, constant(" \plain \f0 \fs18 \b \cb2 ")
 DECLARE ms_rtfeof = vc WITH protect, constant("}")
 DECLARE ms_rtf_pard = vc WITH protect, constant("\pard ")
 DECLARE ms_rtf_line1 = vc WITH protect, constant("\fi-288 \li288 ")
 DECLARE ms_rtf_indent1 = vc WITH protect, constant("\li288 ")
 DECLARE mn_ord_idx = i2 WITH protect, noconstant(0)
 DECLARE mn_ocnt = i2 WITH protect, noconstant(0)
 DECLARE ms_outputrtf = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
  DETAIL
   m_rec->mf_person_id = e.person_id, m_rec->mf_encntr_id = e.encntr_id
  WITH nocounter
 ;end select
 SELECT
  provider_name = pr.name_full_formatted, fin = ea.alias, pat_name = p.name_full_formatted,
  o.encntr_id, o.hna_order_mnemonic, o.order_id,
  o.clinical_display_line, o.current_start_dt_tm
  FROM orders o,
   order_action oa,
   person p,
   prsnl pr,
   encntr_alias ea
  PLAN (o
   WHERE (o.person_id=m_rec->mf_person_id)
    AND (o.encntr_id=m_rec->mf_encntr_id)
    AND o.catalog_type_cd=mf_nutritionservices_cs6000
    AND o.catalog_cd IN (mf_breastmilk_cs200, mf_formulainfant_cs200, mf_formulaadditiveinfant_cs200,
   mf_npo_cs200, mf_donor_breast_milk_cd)
    AND o.order_status_cd IN (mf_inprocess_cs6004, mf_inprocess_cs6004, mf_medstudent_cs6004,
   mf_ordered_cs6004, mf_pending_cs6004,
   mf_pendingrev_cs6004, mf_unscheduled_cs6004)
    AND o.template_order_flag IN (0, 1)
    AND o.cs_flag IN (0, 2))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_order_cs6003)
   JOIN (pr
   WHERE pr.person_id=oa.action_personnel_id)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cs319)
  ORDER BY o.current_start_dt_tm DESC, o.order_id
  HEAD REPORT
   mn_ocnt = 0
  HEAD o.order_id
   mn_ocnt = (mn_ocnt+ 1), m_rec->mn_ords_cnt = mn_ocnt, stat = alterlist(m_rec->ords,mn_ocnt),
   m_rec->ords[mn_ocnt].mf_order_id = o.order_id, m_rec->ords[mn_ocnt].ms_ord_as_mnemonic = trim(o
    .ordered_as_mnemonic), m_rec->ords[mn_ocnt].ms_ord_mnemonic = trim(o.order_mnemonic),
   m_rec->ords[mn_ocnt].ms_clin_display = trim(o.clinical_display_line,3), m_rec->ords[mn_ocnt].
   ms_orig_ord_dttm = format(o.orig_order_dt_tm,"MM/DD/YYYY hh:mm;;d"), m_rec->ords[mn_ocnt].
   ms_ord_provider = trim(pr.name_full_formatted)
  WITH nocounter
 ;end select
 IF ((m_rec->mn_ords_cnt <= 0))
  SET ms_outputrtf = build2(ms_rh2b," No Orders Found within last 48 hours.",ms_reol)
 ELSE
  FOR (mn_ord_idx = 1 TO m_rec->mn_ords_cnt)
   IF (mn_ord_idx=1)
    SET ms_outputrtf = concat(ms_rh2b,m_rec->ords[mn_ord_idx].ms_ord_as_mnemonic,ms_reol,
     "- Ordered by ",m_rec->ords[mn_ord_idx].ms_ord_provider,
     " at ",m_rec->ords[mn_ord_idx].ms_orig_ord_dttm,ms_reol)
   ELSE
    SET ms_outputrtf = concat(ms_outputrtf,ms_wb,ms_rtf_pard,ms_rtf_line1,m_rec->ords[mn_ord_idx].
     ms_ord_as_mnemonic,
     ms_reol,"- Ordered by ",m_rec->ords[mn_ord_idx].ms_ord_provider," at ",m_rec->ords[mn_ord_idx].
     ms_orig_ord_dttm,
     ms_reol)
   ENDIF
   SET ms_outputrtf = concat(ms_outputrtf,ms_reol,ms_rtf_pard,ms_rtf_indent1,m_rec->ords[mn_ord_idx].
    ms_clin_display,
    ms_reol)
  ENDFOR
 ENDIF
 SET reply->text = concat(ms_rhead,ms_outputrtf,ms_rtfeof)
 CALL echo(concat("reply->text is : ",reply->text))
#exit_script
 FREE RECORD m_rec
 FREE SET ms_outputrtf
END GO
