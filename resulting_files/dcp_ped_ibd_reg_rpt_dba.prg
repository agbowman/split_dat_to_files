CREATE PROGRAM dcp_ped_ibd_reg_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select one organization" = 0,
  "Enter begin date" = "CURDATE",
  "Enter end date" = "CURDATE"
  WITH outdev, fac, sdate,
  edate
 DECLARE pediatricibdregistry_var = vc WITH constant("CERNER!6A4208BB-25EA-4E9E-BC1E-7BFC9E6B8FFE"),
 protect
 DECLARE heightlengthdosing_var = vc WITH constant("CERNER!141844AD-D931-4C4F-94DA-59A2A0CB5255"),
 protect
 DECLARE heightlengthdosing_dta = f8 WITH noconstant(0), protect
 DECLARE weightdosing_var = vc WITH constant("CERNER!ABfQJgD4st77Y5Aqn4waeg")
 DECLARE weightdosing_dta = f8 WITH noconstant(0), protect
 DECLARE primaryattendinggastroenterologist_var = vc WITH constant(
  "CERNER!81A4BA76-CCCF-4731-B0A4-BB22DE061ED4"), protect
 DECLARE primaryattendinggastroenterologist_dta = f8 WITH noconstant(0), protect
 DECLARE enteralnutritionprimarytherapyibd_var = vc WITH constant(
  "CERNER!006F86C1-E9FD-4BC5-9675-A9EB24F1EC03"), protect
 DECLARE enteralnutritionprimarytherapyibd_dta = f8 WITH noconstant(0), protect
 DECLARE currententeralintakesupplementibd_var = vc WITH constant(
  "CERNER!8C8145D6-2489-4F7E-921A-0D62F584F1ED"), protect
 DECLARE currententeralintakesupplementibd_dta = f8 WITH noconstant(0), protect
 DECLARE otherreasoninitiationbiologictherapy_var = vc WITH constant(
  "CERNER!AE4CC9E9-A356-49A7-9FD5-D564243D7795"), protect
 DECLARE otherreasoninitiationbiologictherapy_dta = f8 WITH noconstant(0)
 DECLARE reasonforinitiationbiologictherapy_var = vc WITH constant(
  "CERNER!46AF4003-3D2B-4A24-9383-68B64E867514")
 DECLARE reasonforinitiationbiologictherapy_dta = f8 WITH noconstant(0), protect
 DECLARE dateoffirstinductiondoseibd_var = vc WITH constant(
  "CERNER!166A0A79-E252-4910-8B9C-AFCA35D8BDC5"), protect
 DECLARE dateoffirstinductiondoseibd_dta = f8 WITH noconstant(0), protect
 DECLARE biologicinductiondosesincelastvisit_var = vc WITH constant(
  "CERNER!8434BA06-B200-4563-9085-CABB68B9F6C3"), protect
 DECLARE biologicinductiondosesincelastvisit_dta = f8 WITH noconstant(0), protect
 DECLARE cxrevidenceoftuberculosisibd_var = vc WITH constant(
  "CERNER!32D9A3E7-BE81-45EC-8FA6-D165DEBC7F38"), protect
 DECLARE cxrevidenceoftuberculosisibd_dta = f8 WITH noconstant(0), protect
 DECLARE cxrsincelastvisitibd_var = vc WITH constant("CERNER!D877360C-E6E4-4549-8503-A8EF89491D39"),
 protect
 DECLARE cxrsincelastvisitibd_dta = f8 WITH noconstant(0), protect
 DECLARE ulcerativecolitisbehavioribd_var = vc WITH constant(
  "CERNER!B4A537F1-9342-465F-B25C-02DFBCA3D348"), protect
 DECLARE ulcerativecolitisbehavioribd_dta = f8 WITH noconstant(0), protect
 DECLARE extentofulcerativecolitisdiseaseibd_var = vc WITH constant(
  "CERNER!9503696A-1A23-43B1-8946-35F28EE91979"), protect
 DECLARE extentofulcerativecolitisdiseaseibd_dta = f8 WITH noconstant(0), protect
 DECLARE perianalphenotypeibd_var = vc WITH constant("CERNER!407F7740-4282-4ECB-8BCD-F9995156A528"),
 protect
 DECLARE perianalphenotypeibd_dta = f8 WITH noconstant(0), protect
 DECLARE currentcrohnsdiseasephenotypeibd_var = vc WITH constant(
  "CERNER!53A1BA44-0DB5-43D8-9FF2-3AEAEE1BBCC3"), protect
 DECLARE currentcrohnsdiseasephenotypeibd_dta = f8 WITH noconstant(0), protect
 DECLARE macroscopicuppergidiseaseibd_var = vc WITH constant(
  "CERNER!A6DAC764-7569-4B07-BA58-ECC157A122E4"), protect
 DECLARE macroscopicuppergidiseaseibd_dta = f8 WITH noconstant(0), protect
 DECLARE crohnsremissionsincelastvisit_var = vc WITH constant(
  "CERNER!6D6FF63E-8C24-486B-98DE-A05A509CAF4C"), protect
 DECLARE crohnsremissionsincelastvisit_dta = f8 WITH noconstant(0), protect
 DECLARE macroscopiclowergidisease_var = vc WITH constant(
  "CERNER!48643278-9714-45DF-B3A9-D257F535A527"), protect
 DECLARE macroscopiclowergidisease_dta = f8 WITH noconstant(0), protect
 DECLARE knowntypeofinfectionibd_var = vc WITH constant("CERNER!50F9800C-9B61-425C-BCC6-76C21C239F97"
  ), protect
 DECLARE knowntypeofinfectionibd_dta = f8 WITH noconstant(0), protect
 DECLARE typeofinfectionibd_var = vc WITH constant("CERNER!73A933D9-29E8-4030-A513-E5BA5F619FB8"),
 protect
 DECLARE typeofinfectionibd_dta = f8 WITH noconstant(0), protect
 DECLARE infectrequirehospivsincelastvisit_var = vc WITH constant(
  "CERNER!46372ED8-33E4-476C-BDA7-AA7180415DBD"), protect
 DECLARE infectrequirehospivsincelastvisit_dta = f8 WITH noconstant(0), protect
 DECLARE remissionsincelastvisitibd_var = vc WITH constant(
  "CERNER!03148FB7-10AF-4E54-B48F-4494F7F29C1E")
 DECLARE remissionsincelastvisitibd_dta = f8 WITH noconstant(0), protect
 DECLARE growthstatusibd_var = vc WITH constant("CERNER!B163FA59-26A2-43AF-B1B2-25FBBCEB5472"),
 protect
 DECLARE growthstatusibd_dta = f8 WITH noconstant(0), protect
 DECLARE nutritionstatusibd_var = vc WITH constant("CERNER!F1FD63B5-E5AC-4987-8994-3A978CFAE678"),
 protect
 DECLARE nutritionstatusibd_dta = f8 WITH noconstant(0), protect
 DECLARE physicianglobalassessdiseasestatus_var = vc WITH constant(
  "CERNER!24BDE245-F623-44DD-B8DE-2195111ED05D"), protect
 DECLARE physicianglobalassessdiseasestatus_dta = f8 WITH noconstant(0), protect
 DECLARE perirectaldiseasecurrentexamibd_var = vc WITH constant(
  "CERNER!6516EB31-EC0B-4743-A661-EED53647D4ED"), protect
 DECLARE perirectaldiseasecurrentexamibd_dta = f8 WITH noconstant(0), protect
 DECLARE abdominalexamibd_var = vc WITH constant("CERNER!858193EC-B25D-46F0-879F-9EA2E70F8031"),
 protect
 DECLARE abdominalexamibd_dta = f8 WITH noconstant(0), protect
 DECLARE pyodermagangrenosumibd_var = vc WITH constant("CERNER!4FDC228E-054A-4143-B561-C904FF80A8F0"),
 protect
 DECLARE pyodermagangrenosumibd_dta = f8 WITH noconstant(0), protect
 DECLARE erythemanodosumibd_var = vc WITH constant("CERNER!039A5318-8587-45E1-8C19-E097510BD1E9"),
 protect
 DECLARE erythemanodosumibd_dta = f8 WITH noconstant(0), protect
 DECLARE uveitisibd_var = vc WITH constant("CERNER!19156BEE-1318-48DC-A78A-E67EBF8EB7AC"), protect
 DECLARE uveitisibd_dta = f8 WITH noconstant(0), protect
 DECLARE definitearthritisibd_var = vc WITH constant("CERNER!DDA971A3-C591-4489-A065-C9E995D70C25"),
 protect
 DECLARE definitearthritisibd_dta = f8 WITH noconstant(0), protect
 DECLARE fevergreaterthan385clast7daysibd_var = vc WITH constant(
  "CERNER!69F0CFEA-7AEF-4645-90D9-B05630250D40"), protect
 DECLARE fevergreaterthan385clast7daysibd_dta = f8 WITH noconstant(0), protect
 DECLARE nocturnaldiarrheaibd_var = vc WITH constant("CERNER!B04F2AAE-67B7-49CA-BB1F-E09773A9B4DF"),
 protect
 DECLARE nocturnaldiarrheaibd_dta = f8 WITH noconstant(0), protect
 DECLARE typicalamountofbloodinstoolsibd_var = vc WITH constant(
  "CERNER!E448B805-8936-4137-84B4-F7080BEF0DB8"), protect
 DECLARE typicalamountofbloodinstoolsibd_dta = f8 WITH noconstant(0), protect
 DECLARE patientreportedbloodystoolsibd_var = vc WITH constant(
  "CERNER!D0C50459-C0F7-45EF-94D0-EF61577C02D1"), protect
 DECLARE patientreportedbloodystoolsibd_dta = f8 WITH noconstant(0), protect
 DECLARE numberofliqorwaterystoolsibd_var = vc WITH constant(
  "CERNER!EFCC6965-4298-4B27-9E28-8BD8B38F02DD"), protect
 DECLARE numberofliqorwaterystoolsibd_dta = f8 WITH noconstant(0), protect
 DECLARE numberofliqorwaterystoolsknownibd_var = vc WITH constant(
  "CERNER!B5C4F970-00F2-4C79-931A-3C889701C474"), protect
 DECLARE numberofliqorwaterystoolsknownibd_dta = f8 WITH noconstant(0), protect
 DECLARE consistencyofmoststoolsibd_var = vc WITH constant(
  "CERNER!C12DF780-AB7C-45A5-B384-1774232B85F0"), protect
 DECLARE consistencyofmoststoolsibd_dta = f8 WITH noconstant(0), protect
 DECLARE totalnumberofstoolsibd_var = vc WITH constant("CERNER!EC5F3D87-5E5F-4B3A-AE3B-7DDCE813FB98"),
 protect
 DECLARE totalnumberofstoolsibd_dta = f8 WITH noconstant(0), protect
 DECLARE totalnumberofstoolsknownibd_var = vc WITH constant(
  "CERNER!2E2316F2-6D27-4490-9C6C-6123C492165A"), protect
 DECLARE totalnumberofstoolsknownibd_dta = f8 WITH noconstant(0), protect
 DECLARE abdominalpainibd_var = vc WITH constant("CERNER!D9453BBA-1F83-44E0-9EBF-78BBF67CFB3E"),
 protect
 DECLARE abdominalpainibd_dta = f8 WITH noconstant(0), protect
 DECLARE generalwellbeingibd_var = vc WITH constant("CERNER!8A13A58E-C407-4E6F-AEFE-171C2B70B85B"),
 protect
 DECLARE generalwellbeingibd_dta = f8 WITH noconstant(0), protect
 DECLARE currentileostomyorcolostomy_var = vc WITH constant(
  "CERNER!CD0C2260-0C77-4819-A64C-587F7C3734C1"), protect
 DECLARE currentileostomyorcolostomy_dta = f8 WITH noconstant(0), protect
 DECLARE colectomydateibd_var = vc WITH constant("CERNER!DB0AC86D-C5ED-4B65-82FD-6A890E26C733"),
 protect
 DECLARE colectomydateibd_dta = f8 WITH noconstant(0), protect
 DECLARE historyofcompletecolectomyibd_var = vc WITH constant(
  "CERNER!321D3411-C867-42CE-8807-90E3C4019213"), protect
 DECLARE historyofcompletecolectomyibd_dta = f8 WITH noconstant(0), protect
 DECLARE currentdiagnosisibd_var = vc WITH constant("CERNER!78FF8EFB-6F1B-4349-8E31-0E9181211D70"),
 protect
 DECLARE currentdiagnosisibd_dta = f8 WITH noconstant(0), protect
 DECLARE limitationsindailyactivitiesibd_var = vc WITH constant(
  "CERNER!4A92B8C0-9666-4BEC-8542-C97D887316E2"), protect
 DECLARE limitationsindailyactivitiesibd_dta = f8 WITH noconstant(0), protect
 DECLARE mrn_var = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN")), protect
 DECLARE auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE inerror_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR"))
 IF (findstring("CURDATE", $SDATE) > 0)
  DECLARE _dq8 = dq8 WITH noconstant, private
  DECLARE _count = f8 WITH noconstant, private
  SET _count = cnvtint(cnvtalphanum( $SDATE,5))
  SET _dq8 = cnvtdatetime((curdate+ _count),0)
  DECLARE start_dt_tm = vc WITH protect, constant(format(_dq8,"DD-MMM-YYYY;;D"))
 ELSE
  DECLARE start_dt_tm = vc WITH protect, constant(concat( $SDATE,",00:00:00"))
 ENDIF
 IF (findstring("CURDATE", $EDATE) > 0)
  DECLARE _dq8 = dq8 WITH noconstant, private
  DECLARE _count = f8 WITH noconstant, private
  SET _count = cnvtint(cnvtalphanum( $EDATE,5))
  SET _dq8 = cnvtdatetime((curdate+ _count),235959)
  DECLARE end_dt_tm = vc WITH protect, constant(format(_dq8,"DD-MMM-YYYY HH:MM;;Q"))
 ELSE
  DECLARE end_dt_tm = vc WITH protect, constant(concat( $EDATE,",23:59:59"))
 ENDIF
 DECLARE org_type_cd = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE org_cd = f8 WITH noconstant(0.0), protect
 DECLARE pf_event_cd = f8 WITH noconstant(0.0), protect
 DECLARE form_ref_id = f8 WITH noconstant(0.0), protect
 DECLARE dta_cnt1 = i4 WITH noconstant(0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE idx = i2 WITH noconstant(1), protect
 DECLARE detail_string = vc WITH noconstant(""), protect
 DECLARE file_name = vc WITH noconstant(""), protect
 SET file_name = concat("Ped_Ibd_Reg_",format(cnvtdatetime(sysdate),"yyyymmddhhmmss;;q"),".dat")
 FREE RECORD dtas
 RECORD dtas(
   1 dta_list[*]
     2 task_assay_cd = f8
     2 concept_cki = vc
     2 dta_description = vc
 )
 RECORD ped_ibd(
   1 rec_cnt = i4
   1 qual[*]
     2 person_name = vc
     2 encntr_id = vc
     2 mrn_nbr = vc
     2 birth_date = vc
     2 visit_date = vc
     2 height = vc
     2 weight = vc
     2 person_id = f8
     2 dta_cnt = i4
     2 dta_qual[*]
       3 dta_name = vc
       3 dta_cd = vc
       3 result_val = vc
     2 current_diagnosis = vc
     2 complete_colectomy = vc
     2 colectomy_date = vc
     2 ileostomy_or_colostomy = vc
     2 general_well_being = vc
     2 limitations = vc
     2 abdominal_pain = vc
     2 number_of_stools = vc
     2 number_of_known_stools = vc
     2 stool_description = vc
     2 known_watery_stools_day = vc
     2 watery_stools_day = vc
     2 bloody_stools = vc
     2 blood_amount = vc
     2 nocturnal_diarrhea = vc
     2 fever = vc
     2 arthritis = vc
     2 uvelitis = vc
     2 erythema_nodosum = vc
     2 pyoderma_gangrenosum = vc
     2 exam = vc
     2 perirectal_disease = vc
     2 disease_status = vc
     2 nutritional_staus = vc
     2 growth_status = vc
     2 remission_last_visit = vc
     2 serious_infection = vc
     2 known_infection_type = vc
     2 infection_type = vc
     2 macroscopic_lower_disease = vc
     2 crohns_remission_last_visit = vc
     2 macroscopic_upper_disease = vc
     2 current_crohns = vc
     2 perianal_phenotype = vc
     2 extent_of_disease = vc
     2 behavior = vc
     2 chest_x_ray = vc
     2 tb = vc
     2 induction_dose = vc
     2 first_induction_dose = vc
     2 reason_for_biologic = vc
     2 other_reason_for_biologic = vc
     2 enteral_supplement = vc
     2 primary_therapy = vc
     2 primary_gastroenterologist = vc
 )
 FREE RECORD ped_audit_request
 RECORD ped_audit_request(
   1 audit_events[*]
     2 audit_solution_cd = f8
     2 audit_event_cd = f8
     2 audit_event_dt_tm = dq8
     2 audit_facility_cd = f8
     2 audit_patient_id = f8
     2 audit_info_text = vc
   1 debug_ind = i2
 )
 DECLARE writeauditinfo(null) = null
 DECLARE getpowerformeventcode(null) = null
 DECLARE getpowerformrefid(null) = null
 DECLARE getorgcode(null) = null
 DECLARE getdtasfromform(null) = null
 DECLARE findheightandweightcd(null) = null
 DECLARE findresults(null) = null
 DECLARE findpersondetails(null) = null
 DECLARE printoutput(null) = null
 CALL writeauditinfo(null)
 CALL getpowerformeventcode(null)
 CALL getpowerformrefid(null)
 CALL getorgcode(null)
 CALL getdtasfromform(null)
 CALL findheightandweightcd(null)
 CALL findresults(null)
 CALL findpersondetails(null)
 CALL printoutput(null)
 GO TO exit_script
 SUBROUTINE writeauditinfo(null)
   SET stat = alterlist(ped_audit_request->audit_events,1)
   SET ped_audit_request->audit_events[1].audit_solution_cd = uar_get_code_by("MEANING",4002138,
    "PFPEDIATRIC")
   SET ped_audit_request->audit_events[1].audit_event_cd = uar_get_code_by("MEANING",4002139,
    "PFPEDRPT")
   SET ped_audit_request->audit_events[1].audit_facility_cd =  $FAC
   SELECT INTO "nl:"
    FROM acute_care_audit_info ac
    WHERE (ac.audit_solution_cd=ped_audit_request->audit_events[1].audit_solution_cd)
    WITH nocounter
   ;end select
   IF (curqual=0)
    EXECUTE bsc_rec_audit_info  WITH replace("REQUEST","PED_AUDIT_REQUEST"), replace("REPLY",
     "PED_AUDIT_REPLY")
    FREE RECORD ped_audit_request
    CALL echo(build("PED_AUDIT_REPLY->status_data.status",ped_audit_reply->status_data.status))
    FREE RECORD ped_audit_reply
   ENDIF
 END ;Subroutine
 SUBROUTINE getpowerformeventcode(null)
   SELECT INTO "NL:"
    FROM code_value cv,
     v500_event_code vec
    PLAN (cv
     WHERE cv.concept_cki=pediatricibdregistry_var
      AND cv.active_ind=1)
     JOIN (vec
     WHERE vec.event_cd=cv.code_value)
    DETAIL
     pf_event_cd = vec.event_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpowerformrefid(null)
   SELECT INTO "NL:"
    FROM dcp_forms_ref dfr
    WHERE dfr.event_cd=pf_event_cd
     AND dfr.active_ind=1
    DETAIL
     form_ref_id = dfr.dcp_forms_ref_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getorgcode(null)
   SELECT INTO "NL:"
    FROM organization o,
     location l
    PLAN (o
     WHERE o.organization_id=cnvtreal( $2))
     JOIN (l
     WHERE l.organization_id=o.organization_id
      AND l.active_ind=1
      AND l.location_type_cd=org_type_cd)
    HEAD o.organization_id
     org_cd = l.location_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getdtasfromform(null)
   SELECT INTO "NL:"
    FROM dcp_forms_ref dfr,
     dcp_forms_def dfd,
     dcp_section_ref dsr,
     dcp_input_ref dir,
     name_value_prefs nvp,
     discrete_task_assay dta
    PLAN (dfr
     WHERE dfr.dcp_forms_ref_id=form_ref_id
      AND dfr.active_ind=1)
     JOIN (dfd
     WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id
      AND dfr.active_ind=1)
     JOIN (dsr
     WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
      AND dsr.active_ind=1)
     JOIN (dir
     WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
      AND dir.active_ind=1)
     JOIN (nvp
     WHERE nvp.parent_entity_id=dir.dcp_input_ref_id
      AND nvp.parent_entity_name="DCP_INPUT_REF"
      AND nvp.pvc_name="discrete_task_assay")
     JOIN (dta
     WHERE dta.task_assay_cd=nvp.merge_id)
    DETAIL
     CASE (dta.concept_cki)
      OF currentdiagnosisibd_var:
       currentdiagnosisibd_dta = dta.task_assay_cd
      OF colectomydateibd_var:
       colectomydateibd_dta = dta.task_assay_cd
      OF historyofcompletecolectomyibd_var:
       historyofcompletecolectomyibd_dta = dta.task_assay_cd
      OF currentileostomyorcolostomy_var:
       currentileostomyorcolostomy_dta = dta.task_assay_cd
      OF generalwellbeingibd_var:
       generalwellbeingibd_dta = dta.task_assay_cd
      OF limitationsindailyactivitiesibd_var:
       limitationsindailyactivitiesibd_dta = dta.task_assay_cd
      OF abdominalpainibd_var:
       abdominalpainibd_dta = dta.task_assay_cd
      OF totalnumberofstoolsknownibd_var:
       totalnumberofstoolsknownibd_dta = dta.task_assay_cd
      OF totalnumberofstoolsibd_var:
       totalnumberofstoolsibd_dta = dta.task_assay_cd
      OF consistencyofmoststoolsibd_var:
       consistencyofmoststoolsibd_dta = dta.task_assay_cd
      OF numberofliqorwaterystoolsknownibd_var:
       numberofliqorwaterystoolsknownibd_dta = dta.task_assay_cd
      OF numberofliqorwaterystoolsibd_var:
       numberofliqorwaterystoolsibd_dta = dta.task_assay_cd
      OF patientreportedbloodystoolsibd_var:
       patientreportedbloodystoolsibd_dta = dta.task_assay_cd
      OF typicalamountofbloodinstoolsibd_var:
       typicalamountofbloodinstoolsibd_dta = dta.task_assay_cd
      OF nocturnaldiarrheaibd_var:
       nocturnaldiarrheaibd_dta = dta.task_assay_cd
      OF fevergreaterthan385clast7daysibd_var:
       fevergreaterthan385clast7daysibd_dta = dta.task_assay_cd
      OF definitearthritisibd_var:
       definitearthritisibd_dta = dta.task_assay_cd
      OF uveitisibd_var:
       uveitisibd_dta = dta.task_assay_cd
      OF erythemanodosumibd_var:
       erythemanodosumibd_dta = dta.task_assay_cd
      OF pyodermagangrenosumibd_var:
       pyodermagangrenosumibd_dta = dta.task_assay_cd
      OF abdominalexamibd_var:
       abdominalexamibd_dta = dta.task_assay_cd
      OF perirectaldiseasecurrentexamibd_var:
       perirectaldiseasecurrentexamibd_dta = dta.task_assay_cd
      OF physicianglobalassessdiseasestatus_var:
       physicianglobalassessdiseasestatus_dta = dta.task_assay_cd
      OF nutritionstatusibd_var:
       nutritionstatusibd_dta = dta.task_assay_cd
      OF growthstatusibd_var:
       growthstatusibd_dta = dta.task_assay_cd
      OF remissionsincelastvisitibd_var:
       remissionsincelastvisitibd_dta = dta.task_assay_cd
      OF infectrequirehospivsincelastvisit_var:
       infectrequirehospivsincelastvisit_dta = dta.task_assay_cd
      OF knowntypeofinfectionibd_var:
       knowntypeofinfectionibd_dta = dta.task_assay_cd
      OF typeofinfectionibd_var:
       typeofinfectionibd_dta = dta.task_assay_cd
      OF macroscopiclowergidisease_var:
       macroscopiclowergidisease_dta = dta.task_assay_cd
      OF macroscopicuppergidiseaseibd_var:
       macroscopicuppergidiseaseibd_dta = dta.task_assay_cd
      OF crohnsremissionsincelastvisit_var:
       crohnsremissionsincelastvisit_dta = dta.task_assay_cd
      OF currentcrohnsdiseasephenotypeibd_var:
       currentcrohnsdiseasephenotypeibd_dta = dta.task_assay_cd
      OF perianalphenotypeibd_var:
       perianalphenotypeibd_dta = dta.task_assay_cd
      OF extentofulcerativecolitisdiseaseibd_var:
       extentofulcerativecolitisdiseaseibd_dta = dta.task_assay_cd
      OF ulcerativecolitisbehavioribd_var:
       ulcerativecolitisbehavioribd_dta = dta.task_assay_cd
      OF cxrsincelastvisitibd_var:
       cxrsincelastvisitibd_dta = dta.task_assay_cd
      OF cxrevidenceoftuberculosisibd_var:
       cxrevidenceoftuberculosisibd_dta = dta.task_assay_cd
      OF biologicinductiondosesincelastvisit_var:
       biologicinductiondosesincelastvisit_dta = dta.task_assay_cd
      OF dateoffirstinductiondoseibd_var:
       dateoffirstinductiondoseibd_dta = dta.task_assay_cd
      OF reasonforinitiationbiologictherapy_var:
       reasonforinitiationbiologictherapy_dta = dta.task_assay_cd
      OF otherreasoninitiationbiologictherapy_var:
       otherreasoninitiationbiologictherapy_dta = dta.task_assay_cd
      OF currententeralintakesupplementibd_var:
       currententeralintakesupplementibd_dta = dta.task_assay_cd
      OF enteralnutritionprimarytherapyibd_var:
       enteralnutritionprimarytherapyibd_dta = dta.task_assay_cd
      OF primaryattendinggastroenterologist_var:
       primaryattendinggastroenterologist_dta = dta.task_assay_cd
     ENDCASE
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE findheightandweightcd(null)
   SELECT INTO "NL:"
    FROM code_value cv,
     v500_event_code vec,
     discrete_task_assay dta
    PLAN (cv
     WHERE cv.concept_cki IN (heightlengthdosing_var, weightdosing_var)
      AND cv.active_ind=1)
     JOIN (vec
     WHERE vec.event_cd=cv.code_value)
     JOIN (dta
     WHERE dta.event_cd=vec.event_cd
      AND dta.task_assay_cd > 0)
    DETAIL
     CASE (cv.concept_cki)
      OF heightlengthdosing_var:
       heightlengthdosing_dta = dta.task_assay_cd,
       CALL echo(build("HEIGHTDOSING_CD:",heightlengthdosing_dta))
      OF weightdosing_var:
       weightdosing_dta = dta.task_assay_cd,
       CALL echo(build("WEIGHTDOSING_dta:",weightdosing_dta))
     ENDCASE
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE findresults(null)
   SELECT INTO "NL:"
    FROM encounter e,
     dcp_forms_activity dfa,
     dcp_forms_activity_comp dfac,
     clinical_event ce,
     clinical_event ce1,
     clinical_event ce2,
     clinical_event ce3
    PLAN (e
     WHERE e.loc_facility_cd=org_cd)
     JOIN (dfa
     WHERE dfa.encntr_id=e.encntr_id
      AND dfa.person_id=e.person_id
      AND dfa.beg_activity_dt_tm <= cnvtdatetime(end_dt_tm)
      AND dfa.last_activity_dt_tm >= cnvtdatetime(start_dt_tm)
      AND dfa.form_status_cd != inerror_cd)
     JOIN (dfac
     WHERE dfa.dcp_forms_activity_id=dfac.dcp_forms_activity_id)
     JOIN (ce
     WHERE ce.event_id=dfac.parent_entity_id
      AND ce.event_cd=pf_event_cd)
     JOIN (ce1
     WHERE ce1.parent_event_id=ce.event_id)
     JOIN (ce2
     WHERE ce1.event_id=ce2.parent_event_id)
     JOIN (ce3
     WHERE ce2.event_id=ce3.parent_event_id
      AND ce3.result_status_cd IN (auth_cd, modified_cd, altered_cd, inerror_cd)
      AND ce3.valid_from_dt_tm <= cnvtdatetime(end_dt_tm)
      AND ce3.valid_until_dt_tm >= cnvtdatetime(start_dt_tm))
    ORDER BY ce.event_id, ce3.event_id, ce3.clinical_event_id
    HEAD REPORT
     cnt = 0
    HEAD ce.event_id
     IF (mod(cnt,10)=0)
      stat = alterlist(ped_ibd->qual,(cnt+ 10))
     ENDIF
     cnt += 1, ped_ibd->qual[cnt].person_id = e.person_id, ped_ibd->qual[cnt].encntr_id = cnvtstring(
      e.encntr_id),
     ped_ibd->qual[cnt].visit_date = format(e.reg_dt_tm,"mm/dd/yyyy;;q"), knt = 0
    HEAD ce3.event_id
     IF (ce3.task_assay_cd > 0)
      IF (mod(knt,10)=0)
       stat = alterlist(ped_ibd->qual[cnt].dta_qual,(knt+ 10))
      ENDIF
      knt += 1, ped_ibd->qual[cnt].dta_qual[knt].dta_cd = cnvtstring(ce3.task_assay_cd), ped_ibd->
      qual[cnt].dta_qual[knt].dta_name = uar_get_code_display(ce3.task_assay_cd),
      ped_ibd->qual[cnt].dta_qual[knt].result_val = ce3.result_val
     ENDIF
    FOOT  ce3.event_id
     CASE (ce3.task_assay_cd)
      OF currentdiagnosisibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].current_diagnosis = " "
       ELSE
        ped_ibd->qual[cnt].current_diagnosis = ce3.result_val
       ENDIF
      OF historyofcompletecolectomyibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].complete_colectomy = " "
       ELSE
        ped_ibd->qual[cnt].complete_colectomy = ce3.result_val
       ENDIF
      OF colectomydateibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].colectomy_date = " "
       ELSE
        ped_ibd->qual[cnt].colectomy_date = concat(substring(7,2,ce3.result_val),"/",substring(9,2,
          ce3.result_val),"/",substring(3,4,ce3.result_val))
       ENDIF
      OF currentileostomyorcolostomy_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].ileostomy_or_colostomy = " "
       ELSE
        ped_ibd->qual[cnt].ileostomy_or_colostomy = ce3.result_val
       ENDIF
      OF generalwellbeingibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].general_well_being = " "
       ELSE
        ped_ibd->qual[cnt].general_well_being = ce3.result_val
       ENDIF
      OF limitationsindailyactivitiesibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].limitations = " "
       ELSE
        ped_ibd->qual[cnt].limitations = ce3.result_val
       ENDIF
      OF abdominalpainibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].abdominal_pain = " "
       ELSE
        ped_ibd->qual[cnt].abdominal_pain = ce3.result_val
       ENDIF
      OF totalnumberofstoolsknownibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].number_of_known_stools = " "
       ELSE
        ped_ibd->qual[cnt].number_of_known_stools = ce3.result_val
       ENDIF
      OF totalnumberofstoolsibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].number_of_stools = " "
       ELSE
        ped_ibd->qual[cnt].number_of_stools = ce3.result_val
       ENDIF
      OF consistencyofmoststoolsibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].stool_description = " "
       ELSE
        ped_ibd->qual[cnt].stool_description = ce3.result_val
       ENDIF
      OF numberofliqorwaterystoolsknownibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].known_watery_stools_day = " "
       ELSE
        ped_ibd->qual[cnt].known_watery_stools_day = ce3.result_val
       ENDIF
      OF numberofliqorwaterystoolsibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].watery_stools_day = " "
       ELSE
        ped_ibd->qual[cnt].watery_stools_day = ce3.result_val
       ENDIF
      OF patientreportedbloodystoolsibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].bloody_stools = " "
       ELSE
        ped_ibd->qual[cnt].bloody_stools = ce3.result_val
       ENDIF
      OF typicalamountofbloodinstoolsibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].blood_amount = " "
       ELSE
        ped_ibd->qual[cnt].blood_amount = ce3.result_val
       ENDIF
      OF nocturnaldiarrheaibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].nocturnal_diarrhea = " "
       ELSE
        ped_ibd->qual[cnt].nocturnal_diarrhea = ce3.result_val
       ENDIF
      OF fevergreaterthan385clast7daysibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].fever = " "
       ELSE
        ped_ibd->qual[cnt].fever = ce3.result_val
       ENDIF
      OF definitearthritisibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].arthritis = " "
       ELSE
        ped_ibd->qual[cnt].arthritis = ce3.result_val
       ENDIF
      OF uveitisibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].uvelitis = " "
       ELSE
        ped_ibd->qual[cnt].uvelitis = ce3.result_val
       ENDIF
      OF erythemanodosumibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].erythema_nodosum = " "
       ELSE
        ped_ibd->qual[cnt].erythema_nodosum = ce3.result_val
       ENDIF
      OF pyodermagangrenosumibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].pyoderma_gangrenosum = " "
       ELSE
        ped_ibd->qual[cnt].pyoderma_gangrenosum = ce3.result_val
       ENDIF
      OF abdominalexamibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].exam = " "
       ELSE
        ped_ibd->qual[cnt].exam = concat('"',trim(ce3.result_val),'"')
       ENDIF
      OF perirectaldiseasecurrentexamibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].perirectal_disease = " "
       ELSE
        ped_ibd->qual[cnt].perirectal_disease = concat('"',trim(ce3.result_val),'"')
       ENDIF
      OF physicianglobalassessdiseasestatus_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].disease_status = " "
       ELSE
        ped_ibd->qual[cnt].disease_status = ce3.result_val
       ENDIF
      OF nutritionstatusibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].nutritional_staus = " "
       ELSE
        ped_ibd->qual[cnt].nutritional_staus = ce3.result_val
       ENDIF
      OF growthstatusibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].growth_status = " "
       ELSE
        ped_ibd->qual[cnt].growth_status = ce3.result_val
       ENDIF
      OF remissionsincelastvisitibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].remission_last_visit = " "
       ELSE
        ped_ibd->qual[cnt].remission_last_visit = ce3.result_val
       ENDIF
      OF infectrequirehospivsincelastvisit_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].serious_infection = " "
       ELSE
        ped_ibd->qual[cnt].serious_infection = ce3.result_val
       ENDIF
      OF typeofinfectionibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].infection_type = " "
       ELSE
        ped_ibd->qual[cnt].infection_type = ce3.result_val
       ENDIF
      OF knowntypeofinfectionibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].known_infection_type = " "
       ELSE
        ped_ibd->qual[cnt].known_infection_type = concat('"',trim(ce3.result_val),'"')
       ENDIF
      OF macroscopiclowergidisease_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].macroscopic_lower_disease = " "
       ELSE
        ped_ibd->qual[cnt].macroscopic_lower_disease = ce3.result_val
       ENDIF
      OF crohnsremissionsincelastvisit_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].crohns_remission_last_visit = " "
       ELSE
        ped_ibd->qual[cnt].crohns_remission_last_visit = ce3.result_val
       ENDIF
      OF macroscopicuppergidiseaseibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].macroscopic_upper_disease = " "
       ELSE
        ped_ibd->qual[cnt].macroscopic_upper_disease = ce3.result_val
       ENDIF
      OF currentcrohnsdiseasephenotypeibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].current_crohns = " "
       ELSE
        ped_ibd->qual[cnt].current_crohns = concat('"',trim(ce3.result_val),'"')
       ENDIF
      OF perianalphenotypeibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].perianal_phenotype = " "
       ELSE
        ped_ibd->qual[cnt].perianal_phenotype = ce3.result_val
       ENDIF
      OF extentofulcerativecolitisdiseaseibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].extent_of_disease = " "
       ELSE
        ped_ibd->qual[cnt].extent_of_disease = ce3.result_val
       ENDIF
      OF ulcerativecolitisbehavioribd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].behavior = " "
       ELSE
        ped_ibd->qual[cnt].behavior = ce3.result_val
       ENDIF
      OF cxrsincelastvisitibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].chest_x_ray = " "
       ELSE
        ped_ibd->qual[cnt].chest_x_ray = ce3.result_val
       ENDIF
      OF cxrevidenceoftuberculosisibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].tb = " "
       ELSE
        ped_ibd->qual[cnt].tb = ce3.result_val
       ENDIF
      OF biologicinductiondosesincelastvisit_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].induction_dose = " "
       ELSE
        ped_ibd->qual[cnt].induction_dose = ce3.result_val
       ENDIF
      OF dateoffirstinductiondoseibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].first_induction_dose = " "
       ELSE
        ped_ibd->qual[cnt].first_induction_dose = concat(substring(7,2,ce3.result_val),"/",substring(
          9,2,ce3.result_val),"/",substring(3,4,ce3.result_val))
       ENDIF
      OF reasonforinitiationbiologictherapy_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].reason_for_biologic = " "
       ELSE
        ped_ibd->qual[cnt].reason_for_biologic = concat('"',trim(ce3.result_val),'"')
       ENDIF
      OF otherreasoninitiationbiologictherapy_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].other_reason_for_biologic = " "
       ELSE
        ped_ibd->qual[cnt].other_reason_for_biologic = concat('"',trim(ce3.result_val),'"')
       ENDIF
      OF currententeralintakesupplementibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].enteral_supplement = " "
       ELSE
        ped_ibd->qual[cnt].enteral_supplement = ce3.result_val
       ENDIF
      OF enteralnutritionprimarytherapyibd_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].primary_therapy = " "
       ELSE
        ped_ibd->qual[cnt].primary_therapy = ce3.result_val
       ENDIF
      OF primaryattendinggastroenterologist_dta:
       IF (ce3.result_status_cd=inerror_cd)
        ped_ibd->qual[cnt].primary_gastroenterologist = " "
       ELSE
        ped_ibd->qual[cnt].primary_gastroenterologist = concat('"',trim(ce3.result_val),'"')
       ENDIF
     ENDCASE
    FOOT  ce.event_id
     ped_ibd->qual[cnt].dta_cnt = knt, stat = alterlist(ped_ibd->qual[cnt].dta_qual,knt)
    FOOT REPORT
     ped_ibd->rec_cnt = cnt, stat = alterlist(ped_ibd->qual,cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE findpersondetails(null)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(ped_ibd->qual,5)),
     person p,
     person_alias pa
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=ped_ibd->qual[d.seq].person_id))
     JOIN (pa
     WHERE pa.person_id=p.person_id
      AND pa.person_alias_type_cd=mrn_var)
    DETAIL
     FOR (i = 1 TO size(ped_ibd->qual,5))
       IF ((pa.person_id=ped_ibd->qual[i].person_id))
        ped_ibd->qual[i].person_name = concat('"',trim(p.name_full_formatted),'"'), ped_ibd->qual[i].
        birth_date = format(cnvtdatetime(p.birth_dt_tm),"mm/dd/yyyy;;q"), ped_ibd->qual[i].mrn_nbr =
        cnvtalias(pa.alias,pa.person_alias_type_cd)
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   SELECT INTO "nl;"
    FROM (dummyt d  WITH seq = size(ped_ibd->qual,5)),
     clinical_event ce
    PLAN (d)
     JOIN (ce
     WHERE (ce.person_id=ped_ibd->qual[d.seq].person_id)
      AND ce.task_assay_cd IN (heightlengthdosing_dta, weightdosing_dta)
      AND ce.result_status_cd IN (auth_cd, modified_cd, altered_cd, inerror_cd)
      AND ce.valid_from_dt_tm <= cnvtdatetime(end_dt_tm)
      AND ce.valid_until_dt_tm >= cnvtdatetime(start_dt_tm))
    ORDER BY ce.event_id
    DETAIL
     FOR (i = 1 TO size(ped_ibd->qual,5))
       IF ((ce.person_id=ped_ibd->qual[i].person_id)
        AND ce.encntr_id=cnvtreal(ped_ibd->qual[i].encntr_id))
        IF (ce.task_assay_cd=heightlengthdosing_dta)
         IF (ce.result_status_cd=inerror_cd)
          ped_ibd->qual[i].height = " "
         ELSE
          ped_ibd->qual[i].height = concat(trim(ce.result_val)," ",uar_get_code_display(ce
            .result_units_cd))
         ENDIF
        ELSEIF (ce.task_assay_cd=weightdosing_dta)
         IF (ce.result_status_cd=inerror_cd)
          ped_ibd->qual[i].weight = " "
         ELSE
          ped_ibd->qual[i].weight = concat(trim(ce.result_val)," ",uar_get_code_display(ce
            .result_units_cd))
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   CALL echorecord(ped_ibd)
 END ;Subroutine
 SUBROUTINE printoutput(null)
   SELECT INTO value(file_name)
    FROM (dummyt d  WITH seq = size(ped_ibd->qual,5))
    HEAD REPORT
     head_string = concat("Patient Name,","Patient Identifier,","Date of Birth,","MRN Number,",
      "Visit Date,",
      "Height,","Weight,","Current Diagnosis,","Complete Colectomy,","Colectomy Date,",
      "Ileostomy or Colostomy,","General Well-Being,","Limitations,","Abdominal Pain,",
      "Number of Stools Known,",
      "Number of Stools,","Stool description,","Known Watery Stools/day,","Watery Stools/day,",
      "Bloody Stools,",
      "Blood Amount,","Nocturnal Diarrhea,","Fever,","Arthritis,","Uveitis,",
      "Erythema Nodosum,","Pyoderma Gangrenosum,"," Abdominal Exam,","Perirectal Disease,",
      "Disease Status,",
      "Nutritional Status,","Growth Status,","Remission Last Visit,","Serious Infection,",
      "Known Infection Type,",
      "Infection Type,","Macroscopic Lower Disease,","Crohn's Remission/last visit,",
      "Macroscopic Upper Disease,","Current Crohn's,",
      "Perianal Phenotype,","Extent of Disease,","Behavior,","Chest X-Ray,","TB,",
      "Induction Dose,","First Induction Dose,","Reason for Biologic,","Other Reason for Biologic,",
      "Enteral Supplement,",
      "Primary Therapy,","Primary Gastroenterologist"), col 0, head_string,
     row + 1
    DETAIL
     detail_string = concat(ped_ibd->qual[d.seq].person_name,",",ped_ibd->qual[d.seq].encntr_id,",",
      ped_ibd->qual[d.seq].birth_date,
      ",",ped_ibd->qual[d.seq].mrn_nbr,",",ped_ibd->qual[d.seq].visit_date,",",
      ped_ibd->qual[d.seq].height,",",ped_ibd->qual[d.seq].weight,",",ped_ibd->qual[d.seq].
      current_diagnosis,
      ",",ped_ibd->qual[d.seq].complete_colectomy,",",ped_ibd->qual[d.seq].colectomy_date,",",
      ped_ibd->qual[d.seq].ileostomy_or_colostomy,",",ped_ibd->qual[d.seq].general_well_being,",",
      ped_ibd->qual[d.seq].limitations,
      ",",ped_ibd->qual[d.seq].abdominal_pain,",",ped_ibd->qual[d.seq].number_of_known_stools,",",
      ped_ibd->qual[d.seq].number_of_stools,",",ped_ibd->qual[d.seq].stool_description,",",ped_ibd->
      qual[d.seq].known_watery_stools_day,
      ",",ped_ibd->qual[d.seq].watery_stools_day,",",ped_ibd->qual[d.seq].bloody_stools,",",
      ped_ibd->qual[d.seq].blood_amount,",",ped_ibd->qual[d.seq].nocturnal_diarrhea,",",ped_ibd->
      qual[d.seq].fever,
      ",",ped_ibd->qual[d.seq].arthritis,",",ped_ibd->qual[d.seq].uvelitis,",",
      ped_ibd->qual[d.seq].erythema_nodosum,",",ped_ibd->qual[d.seq].pyoderma_gangrenosum,",",ped_ibd
      ->qual[d.seq].exam,
      ",",ped_ibd->qual[d.seq].perirectal_disease,",",ped_ibd->qual[d.seq].disease_status,",",
      ped_ibd->qual[d.seq].nutritional_staus,",",ped_ibd->qual[d.seq].growth_status,",",ped_ibd->
      qual[d.seq].remission_last_visit,
      ",",ped_ibd->qual[d.seq].serious_infection,",",ped_ibd->qual[d.seq].known_infection_type,",",
      ped_ibd->qual[d.seq].infection_type,",",ped_ibd->qual[d.seq].macroscopic_lower_disease,",",
      ped_ibd->qual[d.seq].crohns_remission_last_visit,
      ",",ped_ibd->qual[d.seq].macroscopic_upper_disease,",",ped_ibd->qual[d.seq].current_crohns,",",
      ped_ibd->qual[d.seq].perianal_phenotype,",",ped_ibd->qual[d.seq].extent_of_disease,",",ped_ibd
      ->qual[d.seq].behavior,
      ",",ped_ibd->qual[d.seq].chest_x_ray,",",ped_ibd->qual[d.seq].tb,",",
      ped_ibd->qual[d.seq].induction_dose,",",ped_ibd->qual[d.seq].first_induction_dose,",",ped_ibd->
      qual[d.seq].reason_for_biologic,
      ",",ped_ibd->qual[d.seq].other_reason_for_biologic,",",ped_ibd->qual[d.seq].enteral_supplement,
      ",",
      ped_ibd->qual[d.seq].primary_therapy,",",ped_ibd->qual[d.seq].primary_gastroenterologist), col
     0, detail_string,
     row + 1
    WITH nocounter, format = stream, formfeed = none,
     maxrow = 0, maxcol = 1000
   ;end select
   SELECT INTO  $OUTDEV
    FROM dual
    HEAD REPORT
     col 0, "File generated is located at CCLUSERDIR: ", file_name
    WITH nocounter
   ;end select
   CALL echorecord(ped_ibd)
 END ;Subroutine
#exit_script
END GO
