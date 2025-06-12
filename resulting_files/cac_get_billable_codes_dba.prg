CREATE PROGRAM cac_get_billable_codes:dba
 RECORD ncodereply(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
     2 error_details[*]
       3 error_detail = vc
   1 transaction_uid = vc
   1 diagnoses[*]
     2 terminology
       3 icd9_ind = i2
       3 icd10_ind = i2
     2 concept_identifier = vc
     2 concept_name = vc
     2 instances[*]
       3 location
         4 begin_index = f8
         4 end_index = f8
         4 sections[*]
           5 name = vc
       3 certainty
         4 positive_ind = i2
         4 negative_ind = i2
         4 uncertain_ind = i2
   1 procedures[*]
     2 terminology
       3 cpt_ind = i2
       3 icd9_ind = i2
       3 icd10_ind = i2
     2 concept_identifier = vc
     2 concept_name = vc
     2 partial_code[*]
       3 position = i2
       3 position_meaning = vc
       3 values[*]
         4 code = vc
         4 code_meaning = vc
     2 instances[*]
       3 location
         4 begin_index = f8
         4 end_index = f8
         4 sections[*]
           5 name = vc
       3 certainty
         4 positive_ind = i2
         4 negative_ind = i2
         4 uncertain_ind = i2
       3 instance_date[*]
         4 date = vc
         4 specificity
           5 day_ind = i2
           5 week_ind = i2
           5 month_ind = i2
           5 year_ind = i2
       3 surgeons[*]
         4 name = vc
         4 prefix = vc
         4 suffix = vc
 )
 DECLARE step_id = i4 WITH protect, constant(3070039)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hrequest = i4 WITH protect, noconstant(0)
 DECLARE hcriteriaterminology = i4 WITH protect, noconstant(0)
 DECLARE hretrievalcriteria = i4 WITH protect, noconstant(0)
 DECLARE hdiagnosiscriteria = i4 WITH protect, noconstant(0)
 DECLARE hprocedurecriteria = i4 WITH protect, noconstant(0)
 DECLARE hpatientinformation = i4 WITH protect, noconstant(0)
 DECLARE hgender = i4 WITH protect, noconstant(0)
 DECLARE hreply = i4 WITH protect, noconstant(0)
 DECLARE hstatus = i4 WITH protect, noconstant(0)
 DECLARE herrordetail = i4 WITH protect, noconstant(0)
 DECLARE hterminology = i4 WITH protect, noconstant(0)
 DECLARE hinstance = i4 WITH protect, noconstant(0)
 DECLARE hlocation = i4 WITH protect, noconstant(0)
 DECLARE hsection = i4 WITH protect, noconstant(0)
 DECLARE hcertainty = i4 WITH protect, noconstant(0)
 DECLARE hdate = i4 WITH protect, noconstant(0)
 DECLARE hdatespecificity = i4 WITH protect, noconstant(0)
 DECLARE hdiagnosis = i4 WITH protect, noconstant(0)
 DECLARE hprocedure = i4 WITH protect, noconstant(0)
 DECLARE hsurgeon = i4 WITH protect, noconstant(0)
 DECLARE hpartialcode = i4 WITH protect, noconstant(0)
 DECLARE hpartialcodevalue = i4 WITH protect, noconstant(0)
 DECLARE diagnosiscriteriacnt = i2 WITH protect, noconstant(0)
 DECLARE procedurecriteriacnt = i2 WITH protect, noconstant(0)
 DECLARE patientinformationcnt = i2 WITH protect, noconstant(0)
 DECLARE gendercnt = i2 WITH protect, noconstant(0)
 DECLARE instancessize = i2 WITH protect, noconstant(0)
 DECLARE instancecnt = i2 WITH protect, noconstant(0)
 DECLARE sectionssize = i2 WITH protect, noconstant(0)
 DECLARE sectioncnt = i2 WITH protect, noconstant(0)
 DECLARE instancedatessize = i2 WITH protect, noconstant(0)
 DECLARE instancedatecnt = i2 WITH protect, noconstant(0)
 DECLARE diagnosessize = i2 WITH protect, noconstant(0)
 DECLARE diagnosiscnt = i2 WITH protect, noconstant(0)
 DECLARE proceduressize = i2 WITH protect, noconstant(0)
 DECLARE procedurecnt = i2 WITH protect, noconstant(0)
 DECLARE surgeonssize = i2 WITH protect, noconstant(0)
 DECLARE surgeoncnt = i2 WITH protect, noconstant(0)
 DECLARE partialcodessize = i2 WITH protect, noconstant(0)
 DECLARE partialcodecnt = i2 WITH protect, noconstant(0)
 DECLARE partialcodevaluessize = i2 WITH protect, noconstant(0)
 DECLARE partialcodevaluecnt = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET hstep = uar_srvselectmessage(step_id)
 SET hrequest = uar_srvcreaterequest(hstep)
 IF ( NOT (hrequest))
  SET ncodereply->transaction_status.success_ind = 0
  SET ncodereply->transaction_status.debug_error_message = concat("SrvCreateRequest for ",build(" ",
    step_id)," failed.")
  GO TO cleanup
 ENDIF
 SET stat = uar_srvsetasis(hrequest,"document",nullterm(ncoderequest->document),size(ncoderequest->
   document))
 SET stat = uar_srvsetstring(hrequest,"visit_date",nullterm(ncoderequest->visit_date))
 SET stat = uar_srvsetstring(hrequest,"specialty",nullterm(ncoderequest->specialty))
 SET hretrievalcriteria = uar_srvgetstruct(hrequest,"retrieval_criteria")
 FOR (diagnosiscriteriacnt = 1 TO value(size(ncoderequest->retrieval_criteria.diagnosis_criteria,5)))
   SET hdiagnosiscriteria = uar_srvadditem(hretrievalcriteria,"diagnosis_criteria")
   SET hcriteriaterminology = uar_srvgetstruct(hdiagnosiscriteria,"terminology")
   SET stat = uar_srvsetshort(hcriteriaterminology,"icd9_ind",ncoderequest->retrieval_criteria.
    diagnosis_criteria[diagnosiscriteriacnt].terminology.icd9_ind)
   SET stat = uar_srvsetshort(hcriteriaterminology,"icd10_ind",ncoderequest->retrieval_criteria.
    diagnosis_criteria[diagnosiscriteriacnt].terminology.icd10_ind)
 ENDFOR
 FOR (procedurecriteriacnt = 1 TO value(size(ncoderequest->retrieval_criteria.procedure_criteria,5)))
   SET hprocedurecriteria = uar_srvadditem(hretrievalcriteria,"procedure_criteria")
   SET hcriteriaterminology = uar_srvgetstruct(hprocedurecriteria,"terminology")
   SET stat = uar_srvsetshort(hcriteriaterminology,"cpt_ind",ncoderequest->retrieval_criteria.
    procedure_criteria[procedurecriteriacnt].terminology.cpt_ind)
   SET stat = uar_srvsetshort(hcriteriaterminology,"icd9_ind",ncoderequest->retrieval_criteria.
    procedure_criteria[procedurecriteriacnt].terminology.icd9_ind)
   SET stat = uar_srvsetshort(hcriteriaterminology,"icd10_ind",ncoderequest->retrieval_criteria.
    procedure_criteria[procedurecriteriacnt].terminology.icd10_ind)
 ENDFOR
 FOR (patientinformationcnt = 1 TO value(size(ncoderequest->patient_information,5)))
   SET hpatientinformation = uar_srvadditem(hrequest,"patient_information")
   SET stat = uar_srvsetstring(hpatientinformation,"birth_date",ncoderequest->patient_information[
    patientinformationcnt].birth_date)
   FOR (patientgendercnt = 1 TO value(size(ncoderequest->patient_information[patientinformationcnt].
     gender,5)))
     SET hgender = uar_srvadditem(hpatientinformation,"gender")
     SET stat = uar_srvsetshort(hgender,"male_ind",ncoderequest->patient_information[
      patientinformationcnt].gender[patientgendercnt].male_ind)
     SET stat = uar_srvsetshort(hgender,"female_ind",ncoderequest->patient_information[
      patientinformationcnt].gender[patientgendercnt].female_ind)
   ENDFOR
 ENDFOR
 SET hreply = uar_srvcreatereply(hstep)
 SET stat = uar_srvexecute(hstep,hrequest,hreply)
 IF (stat != 0)
  SET ncodereply->transaction_status.success_ind = 0
  SET ncodereply->transaction_status.debug_error_message = concat("SrvExecute for ",build(" ",step_id
    )," failed.")
  GO TO cleanup
 ENDIF
 SET hstatus = uar_srvgetstruct(hreply,"transaction_status")
 SET ncodereply->transaction_status.success_ind = uar_srvgetshort(hstatus,"success_ind")
 SET ncodereply->transaction_status.debug_error_message = uar_srvgetstringptr(hstatus,
  "debug_error_message")
 SET errordetailssize = uar_srvgetitemcount(hstatus,"error_details")
 IF (errordetailssize > 0)
  SET stat = alterlist(ncodereply->transaction_status.error_details,errordetailssize)
  FOR (errordetailscnt = 1 TO errordetailssize)
   SET herrordetail = uar_srvgetitem(hstatus,"error_details",(errordetailscnt - 1))
   SET ncodereply->transaction_status.error_details[errordetailscnt].error_detail =
   uar_srvgetstringptr(herrordetail,"error_detail")
  ENDFOR
 ENDIF
 SET ncodereply->transaction_uid = uar_srvgetstringptr(hreply,"transaction_uid")
 SET diagnosessize = uar_srvgetitemcount(hreply,"diagnoses")
 IF (diagnosessize > 0)
  SET stat = alterlist(ncodereply->diagnoses,diagnosessize)
  FOR (diagnosiscnt = 1 TO diagnosessize)
    SET hdiagnosis = uar_srvgetitem(hreply,"diagnoses",(diagnosiscnt - 1))
    SET hterminology = uar_srvgetstruct(hdiagnosis,"terminology")
    SET ncodereply->diagnoses[diagnosiscnt].terminology.icd9_ind = uar_srvgetshort(hterminology,
     "icd9_ind")
    SET ncodereply->diagnoses[diagnosiscnt].terminology.icd10_ind = uar_srvgetshort(hterminology,
     "icd10_ind")
    SET ncodereply->diagnoses[diagnosiscnt].concept_identifier = uar_srvgetstringptr(hdiagnosis,
     "concept_identifier")
    SET ncodereply->diagnoses[diagnosiscnt].concept_name = uar_srvgetstringptr(hdiagnosis,
     "concept_name")
    SET instancessize = uar_srvgetitemcount(hdiagnosis,"instances")
    IF (instancessize > 0)
     SET stat = alterlist(ncodereply->diagnoses[diagnosiscnt].instances,instancessize)
     FOR (instancecnt = 1 TO instancessize)
       SET hinstance = uar_srvgetitem(hdiagnosis,"instances",(instancecnt - 1))
       SET hlocation = uar_srvgetstruct(hinstance,"location")
       SET ncodereply->diagnoses[diagnosiscnt].instances[instancecnt].location.begin_index =
       uar_srvgetlong(hlocation,"begin_index")
       SET ncodereply->diagnoses[diagnosiscnt].instances[instancecnt].location.end_index =
       uar_srvgetlong(hlocation,"end_index")
       SET sectionssize = uar_srvgetitemcount(hlocation,"sections")
       IF (sectionssize > 0)
        SET stat = alterlist(ncodereply->diagnoses[diagnosiscnt].instances[instancecnt].location.
         sections,sectionssize)
        FOR (sectioncnt = 1 TO sectionssize)
         SET hsection = uar_srvgetitem(hlocation,"sections",(sectioncnt - 1))
         SET ncodereply->diagnoses[diagnosiscnt].instances[instancecnt].location.sections[sectioncnt]
         .name = uar_srvgetstringptr(hsection,"name")
        ENDFOR
       ENDIF
       SET hcertainty = uar_srvgetstruct(hinstance,"certainty")
       SET ncodereply->diagnoses[diagnosiscnt].instances[instancecnt].certainty.positive_ind =
       uar_srvgetshort(hcertainty,"positive_ind")
       SET ncodereply->diagnoses[diagnosiscnt].instances[instancecnt].certainty.negative_ind =
       uar_srvgetshort(hcertainty,"negative_ind")
       SET ncodereply->diagnoses[diagnosiscnt].instances[instancecnt].certainty.uncertain_ind =
       uar_srvgetshort(hcertainty,"uncertain_ind")
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 SET proceduressize = uar_srvgetitemcount(hreply,"procedures")
 IF (proceduressize > 0)
  SET stat = alterlist(ncodereply->procedures,proceduressize)
  FOR (procedurecnt = 1 TO proceduressize)
    SET hprocedure = uar_srvgetitem(hreply,"procedures",(procedurecnt - 1))
    SET hterminology = uar_srvgetstruct(hprocedure,"terminology")
    SET ncodereply->procedures[procedurecnt].terminology.cpt_ind = uar_srvgetshort(hterminology,
     "cpt_ind")
    SET ncodereply->procedures[procedurecnt].terminology.icd9_ind = uar_srvgetshort(hterminology,
     "icd9_ind")
    SET ncodereply->procedures[procedurecnt].terminology.icd10_ind = uar_srvgetshort(hterminology,
     "icd10_ind")
    SET ncodereply->procedures[procedurecnt].concept_identifier = uar_srvgetstringptr(hprocedure,
     "concept_identifier")
    SET ncodereply->procedures[procedurecnt].concept_name = uar_srvgetstringptr(hprocedure,
     "concept_name")
    SET instancessize = uar_srvgetitemcount(hprocedure,"instances")
    IF (instancessize > 0)
     SET stat = alterlist(ncodereply->procedures[procedurecnt].instances,instancessize)
     FOR (instancecnt = 1 TO instancessize)
       SET hinstance = uar_srvgetitem(hprocedure,"instances",(instancecnt - 1))
       SET hlocation = uar_srvgetstruct(hinstance,"location")
       SET ncodereply->procedures[procedurecnt].instances[instancecnt].location.begin_index =
       uar_srvgetlong(hlocation,"begin_index")
       SET ncodereply->procedures[procedurecnt].instances[instancecnt].location.end_index =
       uar_srvgetlong(hlocation,"end_index")
       SET sectionssize = uar_srvgetitemcount(hlocation,"sections")
       IF (sectionssize > 0)
        SET stat = alterlist(ncodereply->procedures[procedurecnt].instances[instancecnt].location.
         sections,sectionssize)
        FOR (sectioncnt = 1 TO sectionssize)
         SET hsection = uar_srvgetitem(hlocation,"sections",(sectioncnt - 1))
         SET ncodereply->procedures[procedurecnt].instances[instancecnt].location.sections[sectioncnt
         ].name = uar_srvgetstringptr(hsection,"name")
        ENDFOR
       ENDIF
       SET hcertainty = uar_srvgetstruct(hinstance,"certainty")
       SET ncodereply->procedures[procedurecnt].instances[instancecnt].certainty.positive_ind =
       uar_srvgetshort(hcertainty,"positive_ind")
       SET ncodereply->procedures[procedurecnt].instances[instancecnt].certainty.negative_ind =
       uar_srvgetshort(hcertainty,"negative_ind")
       SET ncodereply->procedures[procedurecnt].instances[instancecnt].certainty.uncertain_ind =
       uar_srvgetshort(hcertainty,"uncertain_ind")
       SET instancedatessize = uar_srvgetitemcount(hinstance,"instance_date")
       IF (instancedatessize > 0)
        SET stat = alterlist(ncodereply->procedures[procedurecnt].instances[instancecnt].
         instance_date,instancedatessize)
        FOR (instancedatecnt = 1 TO instancedatessize)
          SET hdate = uar_srvgetitem(hinstance,"instance_date",(instancedatecnt - 1))
          SET ncodereply->procedures[procedurecnt].instances[instancecnt].instance_date[
          instancedatecnt].date = uar_srvgetstringptr(hdate,"date")
          SET hdatespecificity = uar_srvgetstruct(hdate,"specificity")
          SET ncodereply->procedures[procedurecnt].instances[instancecnt].instance_date[
          instancedatecnt].specificity.day_ind = uar_srvgetshort(hdatespecificity,"day_ind")
          SET ncodereply->procedures[procedurecnt].instances[instancecnt].instance_date[
          instancedatecnt].specificity.week_ind = uar_srvgetshort(hdatespecificity,"week_ind")
          SET ncodereply->procedures[procedurecnt].instances[instancecnt].instance_date[
          instancedatecnt].specificity.month_ind = uar_srvgetshort(hdatespecificity,"month_ind")
          SET ncodereply->procedures[procedurecnt].instances[instancecnt].instance_date[
          instancedatecnt].specificity.year_ind = uar_srvgetshort(hdatespecificity,"year_ind")
        ENDFOR
       ENDIF
       SET surgeonssize = uar_srvgetitemcount(hinstance,"surgeons")
       IF (surgeonssize > 0)
        SET stat = alterlist(ncodereply->procedures[procedurecnt].instances[instancecnt].surgeons,
         surgeonssize)
        FOR (surgeoncnt = 1 TO surgeonssize)
          SET hsurgeon = uar_srvgetitem(hinstance,"surgeons",(surgeoncnt - 1))
          SET ncodereply->procedures[procedurecnt].instances[instancecnt].surgeons[surgeoncnt].name
           = uar_srvgetstringptr(hsurgeon,"name")
          SET ncodereply->procedures[procedurecnt].instances[instancecnt].surgeons[surgeoncnt].prefix
           = uar_srvgetstringptr(hsurgeon,"prefix")
          SET ncodereply->procedures[procedurecnt].instances[instancecnt].surgeons[surgeoncnt].suffix
           = uar_srvgetstringptr(hsurgeon,"suffix")
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
    SET partialcodessize = uar_srvgetitemcount(hprocedure,"partial_code")
    IF (partialcodessize > 0)
     SET stat = alterlist(ncodereply->procedures[procedurecnt].partial_code,partialcodessize)
     FOR (partialcodecnt = 1 TO partialcodessize)
       SET hpartialcode = uar_srvgetitem(hprocedure,"partial_code",(partialcodecnt - 1))
       SET ncodereply->procedures[procedurecnt].partial_code[partialcodecnt].position =
       uar_srvgetshort(hpartialcode,"position")
       SET ncodereply->procedures[procedurecnt].partial_code[partialcodecnt].position_meaning =
       uar_srvgetstringptr(hpartialcode,"position_meaning")
       SET partialcodevaluessize = uar_srvgetitemcount(hpartialcode,"values")
       IF (partialcodevaluessize > 0)
        SET stat = alterlist(ncodereply->procedures[procedurecnt].partial_code[partialcodecnt].values,
         partialcodevaluessize)
        FOR (partialcodevaluecnt = 1 TO partialcodevaluessize)
          SET hpartialcodevalue = uar_srvgetitem(hpartialcode,"values",(partialcodevaluecnt - 1))
          SET ncodereply->procedures[procedurecnt].partial_code[partialcodecnt].values[
          partialcodevaluecnt].code = uar_srvgetstringptr(hpartialcodevalue,"code")
          SET ncodereply->procedures[procedurecnt].partial_code[partialcodecnt].values[
          partialcodevaluecnt].code_meaning = uar_srvgetstringptr(hpartialcodevalue,"code_meaning")
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
#cleanup
 CALL uar_srvdestroyinstance(hrequest)
 CALL uar_srvdestroyinstance(hreply)
 CALL uar_srvdestroymessage(hstep)
END GO
