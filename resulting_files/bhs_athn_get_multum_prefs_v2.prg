CREATE PROGRAM bhs_athn_get_multum_prefs_v2
 FREE RECORD result
 RECORD result(
   1 master_multum_enabled = vc
   1 drug_drug_enabled = vc
   1 drug_food_enabled = vc
   1 drug_allergy_enabled = vc
   1 duplicate_therapy_enabled = vc
   1 override_reason_required = vc
   1 check_duplicate_against_orderable = vc
   1 check_duplicate_against_order_status = vc
   1 drug_drug_severity_level = vc
   1 drug_food_severity_level = vc
   1 drug_drug_interruption = vc
   1 drug_food_interruption = vc
   1 drug_allergy_interruption = vc
   1 duplicate_therapy_interruption = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req961202
 RECORD req961202(
   1 qual_knt = i4
   1 qual[*]
     2 app_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
 ) WITH protect
 FREE RECORD rep961202
 RECORD rep961202(
   1 qual_knt = i4
   1 qual[*]
     2 app_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 pref_qual = i4
     2 app_prefs_id = f8
     2 pref[*]
       3 pref_id = f8
       3 pref_name = vc
       3 pref_value = vc
       3 sequence = i4
       3 merge_id = f8
       3 merge_name = vc
       3 active_ind = i2
   1 status_data
     2 status = vc
     2 substatus = i2
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callcpsgetappprefs(position_cd=f8) = i2
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET result->status_data.status = "F"
 SET stat = callcpsgetappprefs(0.0)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF (( $2 > 0.0))
  SET stat = callcpsgetappprefs(cnvtreal( $2))
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  DECLARE v7 = vc WITH protect, noconstant("")
  DECLARE v8 = vc WITH protect, noconstant("")
  DECLARE v9 = vc WITH protect, noconstant("")
  DECLARE v10 = vc WITH protect, noconstant("")
  DECLARE v11 = vc WITH protect, noconstant("")
  DECLARE v12 = vc WITH protect, noconstant("")
  DECLARE v13 = vc WITH protect, noconstant("")
  DECLARE v14 = vc WITH protect, noconstant("")
  DECLARE v15 = vc WITH protect, noconstant("")
  DECLARE v16 = vc WITH protect, noconstant("")
  DECLARE v17 = vc WITH protect, noconstant("")
  DECLARE v18 = vc WITH protect, noconstant("")
  DECLARE v19 = vc WITH protect, noconstant("")
  DECLARE v20 = vc WITH protect, noconstant("")
  DECLARE v21 = vc WITH protect, noconstant("")
  IF ((result->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, col + 1, "<MasterMultumEnabled>",
     row + 1, col + 1, "<Label>Do you want to turn on Multum interaction checking?</Label>",
     row + 1, v1 = build("<Value>",result->master_multum_enabled,"</Value>"), col + 1,
     v1, row + 1, v2 = build("<Display>",evaluate(result->master_multum_enabled,"1","Yes","No"),
      "</Display>"),
     col + 1, v2, row + 1,
     col + 1, "</MasterMultumEnabled>", row + 1,
     col + 1, "<DrugDrugEnabled>", row + 1,
     col + 1, "<Label>Perform Multum Interaction Checking</Label>", row + 1,
     v3 = build("<Value>",result->drug_drug_enabled,"</Value>"), col + 1, v3,
     row + 1, col + 1, "</DrugDrugEnabled>",
     row + 1, col + 1, "<DrugFoodEnabled>",
     row + 1, col + 1, "<Label>Perform Drug-Food Interaction Checking</Label>",
     row + 1, v4 = build("<Value>",result->drug_food_enabled,"</Value>"), col + 1,
     v4, row + 1, col + 1,
     "</DrugFoodEnabled>", row + 1, col + 1,
     "<DrugAllergyEnabled>", row + 1, col + 1,
     "<Label>Perform Multum Reaction Checking</Label>", row + 1, v5 = build("<Value>",result->
      drug_allergy_enabled,"</Value>"),
     col + 1, v5, row + 1,
     col + 1, "</DrugAllergyEnabled>", row + 1,
     col + 1, "<DuplicateTherapyEnabled>", row + 1,
     col + 1, "<Label>Perform Therapeautic Duplicate Checking</Label>", row + 1,
     v6 = build("<Value>",result->duplicate_therapy_enabled,"</Value>"), col + 1, v6,
     row + 1, col + 1, "</DuplicateTherapyEnabled>",
     row + 1, col + 1, "<OverrideReasonRequired>",
     row + 1, col + 1, "<Label>Override Reason Required</Label>",
     row + 1, v7 = build("<Value>",result->override_reason_required,"</Value>"), col + 1,
     v7, row + 1, col + 1,
     "</OverrideReasonRequired>", row + 1, col + 1,
     "<CheckDuplicateAgainstOrderable>", row + 1, col + 1,
     "<Label>Check duplicate against</Label>", row + 1, v8 = build("<Value>",result->
      check_duplicate_against_orderable,"</Value>"),
     col + 1, v8, row + 1,
     v9 = build("<Display>",evaluate(result->check_duplicate_against_orderable,"0","Single Drug","1",
       "Category",
       "2","Single Drug and Category","Unknown"),"</Display>"), col + 1, v9,
     row + 1, col + 1, "</CheckDuplicateAgainstOrderable>",
     row + 1, col + 1, "<CheckDuplicateAgainstOrderStatus>",
     row + 1, col + 1, "<Label>Check duplicate against</Label>",
     row + 1, v8 = build("<Value>",result->check_duplicate_against_order_status,"</Value>"), col + 1,
     v8, row + 1, v9 = build("<Display>",evaluate(result->check_duplicate_against_order_status,"0",
       "New orders","1","Profile orders",
       "2","New orders and profile orders","3","New orders exclude same CKI","4",
       "New orders exclude same CKI and profile orders","Unknown"),"</Display>"),
     col + 1, v9, row + 1,
     col + 1, "</CheckDuplicateAgainstOrderStatus>", row + 1,
     col + 1, "<DrugDrugSeverityLevel>", row + 1,
     col + 1, "<Label>Drug-Drug severity level to retrieve</Label>", row + 1,
     v10 = build("<Value>",result->drug_drug_severity_level,"</Value>"), col + 1, v10,
     row + 1, v11 = build("<Display>",evaluate(result->drug_drug_severity_level,"0",
       "Non severity level","1","Minor",
       "2","Moderate","3","Major","4",
       "No literature","5","Major Contraindicated","Unknown"),"</Display>"), col + 1,
     v11, row + 1, col + 1,
     "</DrugDrugSeverityLevel>", row + 1, col + 1,
     "<DrugFoodSeverityLevel>", row + 1, col + 1,
     "<Label>Drug-Food severity level to retrieve</Label>", row + 1, v12 = build("<Value>",result->
      drug_food_severity_level,"</Value>"),
     col + 1, v12, row + 1,
     v13 = build("<Display>",evaluate(result->drug_food_severity_level,"0","Non severity level","1",
       "Minor",
       "2","Moderate","3","Major","4",
       "No literature","Unknown"),"</Display>"), col + 1, v13,
     row + 1, col + 1, "</DrugFoodSeverityLevel>",
     row + 1, col + 1, "<DrugDrugInterruption>",
     row + 1, col + 1, "<Label>Drug - Drug</Label>",
     row + 1, v14 = build("<Value>",result->drug_drug_interruption,"</Value>"), col + 1,
     v14, row + 1, v15 = build("<Display>",evaluate(result->drug_drug_interruption,"0","Minor","1",
       "Moderate",
       "2","Major","3","Never","Unknown"),"</Display>"),
     col + 1, v15, row + 1,
     col + 1, "</DrugDrugInterruption>", row + 1,
     col + 1, "<DrugFoodInterruption>", row + 1,
     col + 1, "<Label>Drug - Food</Label>", row + 1,
     v16 = build("<Value>",result->drug_food_interruption,"</Value>"), col + 1, v16,
     row + 1, v17 = build("<Display>",evaluate(result->drug_food_interruption,"0","Minor","1",
       "Moderate",
       "2","Major","3","Never","Unknown"),"</Display>"), col + 1,
     v17, row + 1, col + 1,
     "</DrugFoodInterruption>", row + 1, col + 1,
     "<DrugAllergyInterruption>", row + 1, col + 1,
     "<Label>Drug - Allergy</Label>", row + 1, v18 = build("<Value>",evaluate(result->
       drug_allergy_interruption,"0","1","0"),"</Value>"),
     col + 1, v18, row + 1,
     v19 = build("<Display>",evaluate(result->drug_allergy_interruption,"0","Yes","1","No",
       "Unknown"),"</Display>"), col + 1, v19,
     row + 1, col + 1, "</DrugAllergyInterruption>",
     row + 1, col + 1, "<DuplicateTherapyInterruption>",
     row + 1, col + 1, "<Label>Duplicate Therapy</Label>",
     row + 1, v20 = build("<Value>",evaluate(result->duplicate_therapy_interruption,"0","1","0"),
      "</Value>"), col + 1,
     v20, row + 1, v21 = build("<Display>",evaluate(result->duplicate_therapy_interruption,"0","Yes",
       "1","No",
       "Unknown"),"</Display>"),
     col + 1, v21, row + 1,
     col + 1, "</DuplicateTherapyInterruption>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD req961202
 FREE RECORD rep961202
 SUBROUTINE callcpsgetappprefs(position_cd)
   DECLARE applicationid = i4 WITH protect, constant(962000)
   DECLARE taskid = i4 WITH protect, constant(961200)
   DECLARE requestid = i4 WITH protect, constant(961202)
   SET stat = initrec(req961202)
   SET stat = initrec(rep961202)
   SET req961202->qual_knt = 1
   SET stat = alterlist(req961202->qual,1)
   SET req961202->qual[1].app_number = 600005
   SET req961202->qual[1].position_cd = position_cd
   CALL echorecord(req961202)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req961202,
    "REC",rep961202,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep961202)
   IF ((rep961202->status_data.status="S")
    AND size(rep961202->qual,5) > 0)
    FOR (idx = 1 TO size(rep961202->qual[1].pref,5))
      IF ((rep961202->qual[1].pref[idx].pref_name="MULPREF"))
       SET result->master_multum_enabled = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MULINTR"))
       SET result->drug_drug_enabled = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MULDFINTR"))
       SET result->drug_food_enabled = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MULREAT"))
       SET result->drug_allergy_enabled = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MULDUP"))
       SET result->duplicate_therapy_enabled = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MUL_OVERRIDEREQUIRED"))
       SET result->override_reason_required = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MULDUPMODE"))
       SET result->check_duplicate_against_orderable = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MULDUPCHECKPREF"))
       SET result->check_duplicate_against_order_status = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MUL_INTRSEVERITY"))
       SET result->drug_drug_severity_level = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MULFSEVERITY"))
       SET result->drug_food_severity_level = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MUL_DRUGINTERRUPTION"))
       SET result->drug_drug_interruption = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MUL_FOODINTERRUPTION"))
       SET result->drug_food_interruption = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MUL_ALLERGYINTERRUPTION"))
       SET result->drug_allergy_interruption = rep961202->qual[1].pref[idx].pref_value
      ELSEIF ((rep961202->qual[1].pref[idx].pref_name="MUL_DUPINTERRUPTION"))
       SET result->duplicate_therapy_interruption = rep961202->qual[1].pref[idx].pref_value
      ENDIF
    ENDFOR
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
