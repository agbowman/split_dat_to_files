CREATE PROGRAM bhs_mp_preop_chk_widget:dba
 PROMPT
  "Enter Person ID:" = "",
  "Enter Encounter ID:" = ""
  WITH f_person_id, f_encntr_id
 FREE RECORD m_data
 RECORD m_data(
   1 l_cntr = i4
   1 list[*]
     2 ml_sort_ord = i4
     2 mf_event_cd = f8
     2 ms_name = vc
     2 ms_value = vc
 ) WITH protect
 DECLARE mf_inerror1_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE mf_inerror2_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE mf_inerror3_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE mf_inerror4_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_unauth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE mf_notdone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE mf_cancelled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"CANCELLED"))
 DECLARE mf_inlab_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN LAB"))
 DECLARE mf_rejected_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"REJECTED"))
 DECLARE mf_unknown_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"UNKNOWN"))
 DECLARE mf_placeholder_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE mf_nposince_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"NPOSINCE"))
 DECLARE mf_lastvoid_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LASTVOID"))
 DECLARE mf_hairremoval_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HAIRREMOVAL")
  )
 DECLARE mf_lmp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LMP"))
 DECLARE mf_isolationprec_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INPTISOLATIONPRECAUTIONS"))
 DECLARE mf_urinepreg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INPTURINEPREGNANCYTESTOBTAINED"))
 DECLARE mf_bowelpre_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INPTBOWELPREPCOMPLETED"))
 DECLARE mf_foley_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INPTFOLEYORVOIDEDAT"))
 DECLARE mf_generalcons_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INPTGENERALCONSENT"))
 DECLARE mf_surgicalcons_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INPTSURGICALCONSENT"))
 DECLARE mf_anestcons_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INPTANESTHESIACONSENT"))
 DECLARE mf_dnrclarif_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INPTDNRCLARIFICATIONFORM"))
 DECLARE mf_hxanticoag_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INPTHXANTICOAGULATIONTHERAPY"))
 DECLARE mf_pacemaker_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"INPTPACEMAKER")
  )
 DECLARE mf_latx_algry_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ALLERGYLATEX")
  )
 DECLARE mf_preadmgen_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREADMITGENERALCONSENT"))
 DECLARE mf_preadmsurgalcons_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREADMITSURGICALCONSENT"))
 DECLARE mf_preadmitanest_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREADMITANESTHESIACONSENT"))
 DECLARE mf_steriliz_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREADMITSTERILIZATIONCONSENT"))
 DECLARE mf_ofanticoag_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREADMITHXOFANTICOAGULATIONTHERAPY"))
 DECLARE mf_person_id = f8 WITH protect, constant(cnvtreal( $F_PERSON_ID))
 DECLARE mf_encntr_id = f8 WITH protect, constant(cnvtreal( $F_ENCNTR_ID))
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_exp1 = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  prim_ord =
  IF (cv.code_value=mf_nposince_cd) 1
  ELSEIF (cv.code_value=mf_nposince_cd) 1
  ELSEIF (cv.code_value=mf_lastvoid_cd) 2
  ELSEIF (cv.code_value=mf_hairremoval_cd) 3
  ELSEIF (cv.code_value=mf_lmp_cd) 4
  ELSEIF (cv.code_value=mf_isolationprec_cd) 5
  ELSEIF (cv.code_value=mf_urinepreg_cd) 6
  ELSEIF (cv.code_value=mf_bowelpre_cd) 7
  ELSEIF (cv.code_value=mf_foley_cd) 8
  ELSEIF (cv.code_value=mf_generalcons_cd) 9
  ELSEIF (cv.code_value=mf_surgicalcons_cd) 10
  ELSEIF (cv.code_value=mf_anestcons_cd) 11
  ELSEIF (cv.code_value=mf_dnrclarif_cd) 12
  ELSEIF (cv.code_value=mf_hxanticoag_cd) 13
  ELSEIF (cv.code_value=mf_pacemaker_cd) 14
  ELSEIF (cv.code_value=mf_latx_algry_cd) 15
  ELSEIF (cv.code_value=mf_preadmgen_cd) 16
  ELSEIF (cv.code_value=mf_preadmsurgalcons_cd) 17
  ELSEIF (cv.code_value=mf_preadmitanest_cd) 18
  ELSEIF (cv.code_value=mf_steriliz_cd) 19
  ELSEIF (cv.code_value=mf_ofanticoag_cd) 20
  ENDIF
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=72
    AND cv.code_value IN (mf_nposince_cd, mf_lastvoid_cd, mf_hairremoval_cd, mf_lmp_cd,
   mf_isolationprec_cd,
   mf_urinepreg_cd, mf_bowelpre_cd, mf_foley_cd, mf_generalcons_cd, mf_surgicalcons_cd,
   mf_anestcons_cd, mf_dnrclarif_cd, mf_hxanticoag_cd, mf_pacemaker_cd, mf_latx_algry_cd,
   mf_preadmgen_cd, mf_preadmsurgalcons_cd, mf_preadmitanest_cd, mf_steriliz_cd, mf_ofanticoag_cd))
  ORDER BY prim_ord
  HEAD REPORT
   m_data->l_cntr = 0
  DETAIL
   m_data->l_cntr = (m_data->l_cntr+ 1)
   IF ((m_data->l_cntr > size(m_data->list,5)))
    stat = alterlist(m_data->list,(m_data->l_cntr+ 20))
   ENDIF
   m_data->list[m_data->l_cntr].ml_sort_ord = prim_ord, m_data->list[m_data->l_cntr].mf_event_cd = cv
   .code_value, m_data->list[m_data->l_cntr].ms_name = trim(cv.display,3)
  FOOT REPORT
   stat = alterlist(m_data->list,m_data->l_cntr)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_date_result ced
  PLAN (ce
   WHERE ce.encntr_id=mf_encntr_id
    AND ce.person_id=mf_person_id
    AND expand(ml_exp1,1,m_data->l_cntr,ce.event_cd,m_data->list[ml_exp1].mf_event_cd)
    AND  NOT (ce.result_status_cd IN (mf_inerror1_cd, mf_inerror2_cd, mf_inerror3_cd, mf_inerror4_cd,
   mf_inprogress_cd,
   mf_unauth_cd, mf_notdone_cd, mf_cancelled_cd, mf_inlab_cd, mf_rejected_cd,
   mf_unknown_cd))
    AND ce.event_class_cd != mf_placeholder_cd
    AND ce.view_level=1
    AND ce.valid_from_dt_tm <= sysdate
    AND ce.valid_until_dt_tm >= sysdate)
   JOIN (ced
   WHERE ced.event_id=outerjoin(ce.event_id))
  ORDER BY ce.event_cd, ce.valid_from_dt_tm DESC
  HEAD ce.event_cd
   ml_pos = locateval(ml_num,1,m_data->l_cntr,ce.event_cd,m_data->list[ml_num].mf_event_cd)
   IF (ce.event_cd IN (mf_nposince_cd, mf_lastvoid_cd, mf_lmp_cd))
    m_data->list[ml_pos].ms_value = format(ced.result_dt_tm,"@SHORTDATE")
   ELSE
    m_data->list[ml_pos].ms_value = trim(ce.event_tag,3)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(m_data)
 SET _memory_reply_string = cnvtrectojson(m_data)
#exit_program
 CALL echo(_memory_reply_string)
END GO
