CREATE PROGRAM bhs_prax_get_pat_diagnosis
 IF (( $2=0))
  SET where_params = build("D.ENCNTR_ID =", $3)
 ELSE
  SET where_params = build("D.PERSON_ID =", $2)
 ENDIF
 SELECT INTO  $1
  d.active_ind, d_active_status_disp = uar_get_code_display(d.active_status_cd), d
  .active_status_dt_tm,
  d.active_status_prsnl_id, d.attestation_dt_tm, d.beg_effective_dt_tm,
  d_certainty_disp = uar_get_code_display(d.certainty_cd), d_classification_disp =
  uar_get_code_display(d.classification_cd), d.clinical_diag_priority,
  d_clinical_service_disp = uar_get_code_display(d.clinical_service_cd), d_conditional_qual_disp =
  uar_get_code_display(d.conditional_qual_cd), d_confid_level_disp = uar_get_code_display(d
   .confid_level_cd),
  d_confirmation_status_disp = uar_get_code_display(d.confirmation_status_cd),
  d_contributor_system_disp = uar_get_code_display(d.contributor_system_cd), d_diagnosis_display =
  trim(replace(replace(replace(replace(replace(substring(1,255,d.diagnosis_display),"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  d.diagnosis_group, d.diagnosis_id, d_diagnostic_category_disp = uar_get_code_display(d
   .diagnostic_category_cd),
  d_diag_class_disp = uar_get_code_display(d.diag_class_cd), d_diag_dt_tm = format(d.diag_dt_tm,
   "MM/DD/YYYY"), d.diag_note,
  d.diag_priority, d.diag_prsnl_id, d_diag_prsnl_name = trim(replace(replace(replace(replace(replace(
        trim(d.diag_prsnl_name,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3),
  d_diag_type_disp = uar_get_code_display(d.diag_type_cd), d.encntr_id, d.end_effective_dt_tm,
  d_laterality_disp = uar_get_code_display(d.laterality_cd), d.long_blob_id, d.nomenclature_id,
  d.person_id, d_present_on_admit_disp = uar_get_code_display(d.present_on_admit_cd), d.probability,
  d_ranking_disp = uar_get_code_display(d.ranking_cd), d_severity_disp = uar_get_code_display(d
   .severity_cd), d_severity_class_disp = uar_get_code_display(d.severity_class_cd),
  d_severity_free_text = trim(replace(replace(replace(replace(replace(substring(1,255,d
         .severity_ftdesc),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3), d.updt_dt_tm, d.updt_id,
  n.source_identifier, n_source_vocabulary_disp = uar_get_code_display(n.source_vocabulary_cd),
  n_source_string = trim(replace(replace(replace(replace(replace(substring(1,255,n.source_string),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  l_diag_comment =
  IF (l.long_blob_id != 0) trim(replace(replace(replace(replace(replace(substring(1,500,l.long_blob),
         "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
  ELSE " "
  ENDIF
  , l_compression_disp = uar_get_code_display(l.compression_cd)
  FROM diagnosis d,
   nomenclature n,
   long_blob l
  PLAN (d
   WHERE parser(where_params)
    AND d.diagnosis_group != 0.0)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(d.nomenclature_id))
   JOIN (l
   WHERE l.long_blob_id=outerjoin(d.long_blob_id))
  ORDER BY d.diagnosis_group, d.end_effective_dt_tm DESC
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD d.diagnosis_group
   header_grp = build("<","Diagnosis",">"), col + 1, header_grp,
   row + 1, v1 = build("<DiagnosisId>",trim(replace(cnvtstring(d.diagnosis_id),".0*","",0),3),
    "</DiagnosisId>"), col + 1,
   v1, row + 1, v2 = build("<DiagnosisGroupId>",cnvtint(d.diagnosis_group),"</DiagnosisGroupId>"),
   col + 1, v2, row + 1,
   v3 = build("<EncounterId>",trim(replace(cnvtstring(d.encntr_id),".0*","",0),3),"</EncounterId>"),
   col + 1, v3,
   row + 1, v4 = build("<PersonId>",cnvtint(d.person_id),"</PersonId>"), col + 1,
   v4, row + 1, v5 = build("<DiagnosisClassification>",d_classification_disp,
    "</DiagnosisClassification>"),
   col + 1, v5, row + 1,
   v51 = build("<DiagnosisClassificationCd>",cnvtint(d.classification_cd),
    "</DiagnosisClassificationCd>"), col + 1, v51,
   row + 1, v6 = build("<DiagnosisClinicalService>",d_clinical_service_disp,
    "</DiagnosisClinicalService>"), col + 1,
   v6, row + 1, v61 = build("<DiagnosisClinicalServiceCd>",cnvtint(d.clinical_service_cd),
    "</DiagnosisClinicalServiceCd>"),
   col + 1, v61, row + 1,
   v7 = build("<DiagnosisConfirmationStatus>",d_confirmation_status_disp,
    "</DiagnosisConfirmationStatus>"), col + 1, v7,
   row + 1, v71 = build("<DiagnosisConfStatusCd>",cnvtint(d.confirmation_status_cd),
    "</DiagnosisConfStatusCd>"), col + 1,
   v71, row + 1, v8 = build("<DiagnosisDateTime>",d_diag_dt_tm,"</DiagnosisDateTime>"),
   col + 1, v8, row + 1,
   v9 = build("<DiagnosisDisplay>",d_diagnosis_display,"</DiagnosisDisplay>"), col + 1, v9,
   row + 1, v10 = build("<DiagnosisRanking>",d_ranking_disp,"</DiagnosisRanking>"), col + 1,
   v10, row + 1, v101 = build("<DiagnosisRankingCd>",cnvtint(d.ranking_cd),"</DiagnosisRankingCd>"),
   col + 1, v101, row + 1,
   v11 = build("<ResposibleProviderId>",cnvtint(d.diag_prsnl_id),"</ResposibleProviderId>"), col + 1,
   v11,
   row + 1, v12 = build("<ResposibleProviderName>",d_diag_prsnl_name,"</ResposibleProviderName>"),
   col + 1,
   v12, row + 1, v13 = build("<NomenclatureId>",cnvtint(d.nomenclature_id),"</NomenclatureId>"),
   col + 1, v13, row + 1,
   v14 = build("<SourceIdentifier>",n.source_identifier,"</SourceIdentifier>"), col + 1, v14,
   row + 1, v15 = build("<SourceString>",n_source_string,"</SourceString>"), col + 1,
   v15, row + 1, v16 = build("<SourceVacabulary>",n_source_vocabulary_disp,"</SourceVacabulary>"),
   col + 1, v16, row + 1,
   v17 = build("<DiagnosisComment>",l_diag_comment,"</DiagnosisComment>"), col + 1, v17,
   row + 1, v18 = build("<DiagnosisStatus>",d_active_status_disp,"</DiagnosisStatus>"), col + 1,
   v18, row + 1, v181 = build("<DiagnosisStatusCd>",cnvtint(d.active_status_cd),
    "</DiagnosisStatusCd>"),
   col + 1, v181, row + 1,
   v19 = build("<DiagnosisType>",d_diag_type_disp,"</DiagnosisType>"), col + 1, v19,
   row + 1, v191 = build("<DiagnosisTypeCd>",cnvtint(d.diag_type_cd),"</DiagnosisTypeCd>"), col + 1,
   v191, row + 1, v20 = build("<ConfidentialityLevel>",d_confid_level_disp,"</ConfidentialityLevel>"),
   col + 1, v20, row + 1,
   v201 = build("<ConfidentialityLevelCd>",cnvtint(d.confid_level_cd),"</ConfidentialityLevelCd>"),
   col + 1, v201,
   row + 1, v21 = build("<DiagnosisCategory>",d_diagnostic_category_disp,"</DiagnosisCategory>"), col
    + 1,
   v21, row + 1, v211 = build("<DiagnosisCategoryCd>",cnvtint(d.diagnostic_category_cd),
    "</DiagnosisCategoryCd>"),
   col + 1, v211, row + 1,
   v22 = build("<Probability>",d.probability,"</Probability>"), col + 1, v22,
   row + 1, v23 = build("<PresentOnAdmission>",d_present_on_admit_disp,"</PresentOnAdmission>"), col
    + 1,
   v23, row + 1, v231 = build("<PresentOnAdmissionCd>",cnvtint(d.present_on_admit_cd),
    "</PresentOnAdmissionCd>"),
   col + 1, v231, row + 1,
   v24 = build("<Severity>",d_severity_disp,"</Severity>"), col + 1, v24,
   row + 1, v241 = build("<SeverityCd>",cnvtint(d.severity_cd),"</SeverityCd>"), col + 1,
   v241, row + 1, v25 = build("<Laterality>",d_laterality_disp,"</Laterality>"),
   col + 1, v25, row + 1,
   v251 = build("<LateralityCd>",cnvtint(d.laterality_cd),"</LateralityCd>"), col + 1, v251,
   row + 1, v26 = build("<ActiveIndicator>",cnvtint(d.active_ind),"</ActiveIndicator>"), col + 1,
   v26, row + 1, v27 = build("<EndEffectiveDate>",format(d.end_effective_dt_tm,"MM/DD/YYYY"),
    "</EndEffectiveDate>"),
   col + 1, v27, row + 1,
   v28 = build("<Certainity>",d_certainty_disp,"</Certainity>"), col + 1, v28,
   row + 1, v29 = build("<CertainityCd>",cnvtint(d.certainty_cd),"</CertainityCd>"), col + 1,
   v29, row + 1, v30 = build("<SeverityClass>",d_severity_class_disp,"</SeverityClass>"),
   col + 1, v30, row + 1,
   v31 = build("<SeverityClassCd>",cnvtint(d.severity_class_cd),"</SeverityClassCd>"), col + 1, v31,
   row + 1, v32 = build("<SeverityFreeText>",d_severity_free_text,"</SeverityFreeText>"), col + 1,
   v32, row + 1, v33 = build("<ConditionalQualifier>",d_conditional_qual_disp,
    "</ConditionalQualifier>"),
   col + 1, v33, row + 1,
   v34 = build("<ConditionalQualifierCd>",cnvtint(d.conditional_qual_cd),"</ConditionalQualifierCd>"),
   col + 1, v34,
   row + 1, v35 = build("<DiagnosisClass>",d_diag_class_disp,"</DiagnosisClass>"), col + 1,
   v35, row + 1, v36 = build("<DiagnosisClassCd>",cnvtint(d.diag_class_cd),"</DiagnosisClassCd>"),
   col + 1, v36, row + 1
  FOOT  d.diagnosis_group
   foot_grp = build("</","Diagnosis",">"), col + 1, foot_grp,
   row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
