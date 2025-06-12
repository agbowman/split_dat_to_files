CREATE PROGRAM dms_content_type_readme_test
 DECLARE totalcount = i4 WITH public, noconstant(0)
 DECLARE totalcontenttypes = i4 WITH protect, constant(108)
 SELECT INTO "nl:"
  FROM dms_content_type d
  WHERE d.content_type_key IN ("AUDIO", "UNIVERSAL_DOMAIN_OBJECT", "APIMAGE", "CV_HEMO", "CV_INTERP",
  "CARDIOLOGY_DEVICE_INTEGRATION", "CAREAWARE_CONNECT", "HEALTHEDEMOGRAPHICS", "HEALTHEEFORMS",
  "ORDERS_EXTRACT",
  "CHARGES_EXTRACT", "CLINICAL_EVENT_EXTRACT", "SCHEDULING_EXTRACT", "DISCERN_ALERTS_EXTRACT",
  "EBS_REPORT",
  "CLINICAL_PHOTO", "CLINICAL_ATTACHMENT", "DICTATION", "CHART", "CHART_DEBUG",
  "CPDICLINICALDOCUMENTATION", "CPDIPATHNET", "CPDIEMPI", "CPDIENTERPRISEREGISTRATION",
  "CPDIFIRSTNET",
  "CPDIPATIENTPRIVACY", "CPDIPHARMNET", "CPDIPOWERCHART", "CPDIPROFIT", "CPDIRADIOLOGY",
  "CPDIUNKNOWNNONCLIN", "CPDIHELIX", "CPDICASEREPORT", "CPDITEMPFORMS", "CPDICLIPBOARD",
  "DIGITAL_SIGNATURE", "CPDIEFORMS", "BODY_MAP", "EMERGENT_NOTE", "EPCS_RPT",
  "CCD", "MONITOR.DISCRETE.EPISODE.FETAL", "ESI IMAGE", "ESI TEXT", "ESI APPLICATION",
  "PROVIDED_DOC", "XDS_DOCUMENT_REPO", "HL7V2_MESSAGE", "NHIN_DIRECT", "LAB_PLOT",
  "UNCLASSIFIED_MEDIA", "PERSON_PHOTO", "COMMENT", "DIAGRAM", "MOBILE_CAPTURE",
  "EVENT_BLOB", "XMLSTYLESHEET", "PATIENT_PROVIDED", "EXT_PAT_DATA_XML", "PAT_CLIP_RAW",
  "CARETRACKER", "MDSI", "RADBDANNOTATION", "RADBDBURNEDIMAGE", "RADBDTEMPLATE",
  "RAD_DOSE_SR", "RAD_DOSE_SR_RAW", "CCHITXMLSTYLESHEET", "XDOC_CDA", "XDOC_NONCDA",
  "EXPORT_SUM", "TOC_REF", "AMB_SUM", "INPAT_SUM", "CLIN_SUM",
  "WARNING_MSG", "XDM_ZIP", "RRD_SECURE_EMAIL", "CREF_NOTE", "CDSCH_SUM",
  "SIGNED_DOCUMENT_SUMMARY", "SIGNED_ORDER_SUMMARY", "CPW_BOOKMARK", "IAW_WAVEFORM_DETAILS",
  "IAW_WAVEFORM_REPORT",
  "IAW_WAVEFORM", "IAW_WAVEFORM_SHARD", "DICOMSTUDIES", "CCDMU3", "DISCHSUMMU3",
  "EPA_IN_ATTACH", "REFNOTEMU3", "NHCSV11", "NHCSV12", "NHCSV1ED",
  "NHCSV1INP", "NHCSV1OUTP", "NONREPUDIATIVEDOC", "MIGR_CCDA", "CAREPLAN",
  "DEXAAS_EXTRACT", "ADVANCED_INTEROP_CLINICAL_NOTES", "FETALINK_PDF", "ECASE", "ASTHMA_ACTION_PLAN",
  "KIA_ESH_VERSION", "CHART_CONCEPT_SERVICE", "CARDIO_EXT_DOC")
  DETAIL
   totalcount += 1
  WITH nocounter
 ;end select
 IF (totalcount=totalcontenttypes)
  CALL echo("*")
  CALL echo("<====================   Test Successful   ====================>")
  SET msg = build("<====================     Expected: ",totalcontenttypes,
   "     ====================>")
  SET msg2 = build("<====================      Actual: ",totalcount,"      ====================>")
  CALL echo(msg)
  CALL echo(msg2)
  CALL echo("*")
 ELSE
  CALL echo("*")
  CALL video(b)
  CALL echo("<====================   Test Failed   ====================>")
  CALL video(n)
  SET msg = build("<====================   Expected: ",totalcontenttypes,"   ====================>")
  SET msg2 = build("<====================    Actual: ",totalcount,"    ====================>")
  CALL echo(msg)
  CALL echo(msg2)
  CALL echo("*")
 ENDIF
END GO
