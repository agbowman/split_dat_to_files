CREATE PROGRAM bhs_athn_discern_dialog_v2
 FREE RECORD result
 RECORD result(
   1 person_id = f8
   1 encntr_id = f8
   1 birth_dt_tm = vc
   1 sex_cd = f8
   1 alerts[*]
     2 title = vc
     2 text = vc
     2 module_name = vc
     2 powerform_id = f8
     2 add_diagnosis_btn_ind = i2
     2 powerformname = vc
     2 powerformbutton = vc
     2 powerformtext = vc
     2 powerforminprogressstatuscd = f8
     2 cancellabel1 = vc
     2 ignorelabel2 = vc
     2 modifylabel3 = vc
     2 defaultlabel = vc
     2 overridecnt = i2
     2 overrideother = vc
     2 overrides[*]
       3 reasoncd = f8
       3 display = vc
     2 urlbutton = vc
     2 urladdress = vc
     2 okbutton = vc
 ) WITH protect
 DECLARE calldiscerndialogueserver(null) = i2
 DECLARE getpowerformdetails(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE add_diagnosis_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,
   "PROBLEMLISTDIAGNOSISDISCERNFORM"))
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSON_ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID ENCNTR_ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $4 <= 0.0))
  CALL echo("INVALID REQUEST TYPE PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $5 <= 0.0))
  CALL echo("INVALID PRSNL_ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE mpersonid = f8 WITH protect, constant( $2)
 DECLARE mencntrid = f8 WITH protect, constant( $3)
 SET result->person_id = mpersonid
 SET result->encntr_id = mencntrid
 IF (( $7 > 0.0))
  SET result->birth_dt_tm =  $6
  SET result->sex_cd =  $7
 ELSE
  SELECT INTO "NL:"
   FROM person p
   PLAN (p
    WHERE (p.person_id= $2)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm < sysdate
     AND p.end_effective_dt_tm > sysdate)
   ORDER BY p.person_id
   HEAD p.person_id
    result->birth_dt_tm = format(p.birth_dt_tm,"dd-MMM-yyyy HH:mm:ss"), result->sex_cd = p.sex_cd
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF ((result->birth_dt_tm=" "))
  CALL echo("INVALID PATIENT DETAILS...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = calldiscerndialogueserver(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = getpowerformdetails(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
#exit_script
 IF (validate(_memory_reply_string))
  SET _memory_reply_string = cnvtrectojson(result)
 ELSE
  CALL echojson(result, $1)
 ENDIF
 FREE RECORD result
 SUBROUTINE calldiscerndialogueserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(3072000)
   DECLARE requestid = i4 WITH constant(3072006)
   FREE RECORD dialoguerequest
   RECORD dialoguerequest(
     1 req_type_cd = f8
     1 passthru_ind = i2
     1 trigger_app = i4
     1 person_id = f8
     1 encntr_id = f8
     1 position_cd = f8
     1 sex_cd = f8
     1 birth_dt_tm = dq8
     1 weight = f8
     1 weight_unit_cd = f8
     1 height = f8
     1 height_unit_cd = f8
     1 orderlist[*]
       2 synonym_code = f8
       2 catalog_code = f8
       2 catalogtypecd = f8
       2 orderid = f8
       2 actiontypecd = f8
       2 activitytypecd = f8
       2 activitysubtypecd = f8
       2 dose = f8
       2 dose_unit = f8
       2 start_dt_tm = dq8
       2 end_dt_tm = dq8
       2 route = f8
       2 frequency = f8
       2 physician = f8
       2 rate = f8
       2 infuse_over = i4
       2 infuse_over_unit_cd = f8
       2 protocol_order_ind = i2
       2 dayoftreatment_order_ind = i2
       2 detaillist[*]
         3 oefieldid = f8
         3 oefieldvalue = f8
         3 oefielddisplayvalue = vc
         3 oefielddttmvalue = dq8
         3 oefieldmeaning = vc
       2 diagnosislist[*]
         3 dx = vc
       2 ingredientlist[*]
         3 catalogcd = f8
         3 synonymid = f8
         3 item_id = f8
         3 strengthdose = f8
         3 strengthunit = f8
         3 volumedose = f8
         3 volumeunit = f8
         3 bag_frequency_cd = f8
         3 freetextdose = vc
         3 dosequantity = f8
         3 dosequantityunit = f8
         3 ivseq = i4
         3 normalized_rate = f8
         3 normalized_rate_unit = f8
     1 alert_titlebar = vc
     1 commonreply_ind = i2
     1 freetextparam = vc
     1 expert_trigger = vc
   ) WITH protect
   FREE RECORD dialoguereply
   RECORD dialoguereply(
     1 status = vc
     1 reason = vc
     1 progid = vc
     1 spindex = i2
     1 actiontemplateseq = i4
     1 modifydlgname = vc
     1 cer_hnam_location = vc
     1 parameterlist[*]
       2 parameter = vc
     1 numreply = i4
     1 qual[*]
       2 status = vc
       2 reason = vc
       2 progid = vc
       2 spindex = i2
       2 actiontemplateseq = i4
       2 modifydlgname = vc
       2 parameterlist[*]
         3 parameter = vc
     1 personid = f8
     1 name_full_formatted = vc
     1 recipientid = f8
     1 alerts[*]
       2 title = vc
       2 titlebar = vc
       2 modulename = vc
       2 spindex = i4
       2 actiontemplateseq = i4
       2 modifydlgname = vc
       2 encntrid = f8
       2 serverurl = vc
       2 text = vc
       2 gtext = gvc
       2 cancellabel1 = vc
       2 ignorelabel2 = vc
       2 modifylabel3 = vc
       2 defaultlabel = vc
       2 overridecnt = i2
       2 overrideother = vc
       2 overrides[*]
         3 reasoncd = f8
         3 display = vc
       2 addproblemcnt = i2
       2 confirmationcd = f8
       2 classificationcd = f8
       2 recorderid = f8
       2 lifecyclestatuscd = f8
       2 defaultfirstproblemind = i2
       2 addproblems[*]
         3 display = vc
         3 nomenclatureid = f8
       2 adddxcnt = i2
       2 dxconfirmationcd = f8
       2 dxclassificationcd = f8
       2 dxclinicalservicecd = f8
       2 dxtypecd = f8
       2 dxdttm = dq8
       2 dxprsnlid = f8
       2 dxprsnldisplay = vc
       2 defaultfirstdxind = i2
       2 adddx[*]
         3 display = vc
         3 nomenclatureid = f8
         3 conceptcki = vc
       2 ordercnt = i2
       2 defaultfirstorder = vc
       2 orders[*]
         3 actionflag = i2
         3 mnemonic = vc
         3 catalogcd = f8
         3 synonymid = f8
         3 oeformatid = f8
         3 ordersentenceid = f8
         3 ordersentencedisplay = vc
         3 detailcnt = i2
         3 detaillist[*]
           4 oefieldid = f8
           4 oefieldvalue = f8
           4 oefielddisplayvalue = vc
           4 oefielddttmvalue = vc
           4 oefieldmeaning = vc
           4 oefieldmeaningid = f8
         3 multum_dosing_ind = i2
         3 multum_dnum = vc
       2 urlbutton = vc
       2 urladdress = vc
       2 okbutton = vc
       2 powerformid = f8
       2 powerformname = vc
       2 powerformbutton = vc
       2 powerformtext = vc
       2 powerforminprogressstatuscd = f8
       2 historyind = i2
       2 historybutton = vc
       2 historysavetextind = i2
       2 historypatientname = vc
       2 multum_dosing_ind = i2
       2 multum_dnum = vc
       2 age_in_years = i4
       2 weight = f8
       2 weight_unit_disp = vc
       2 height = f8
       2 height_unit_disp = vc
       2 sex_cd = f8
       2 sex_disp = vc
       2 liver_disease_ind = i2
       2 liver_disease_text = vc
       2 dialysis_ind = i2
       2 creatinine_level = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET dialoguerequest->req_type_cd =  $4
   SET dialoguerequest->person_id = result->person_id
   SET dialoguerequest->encntr_id = result->encntr_id
   SET dialoguerequest->sex_cd = result->sex_cd
   SET dialoguerequest->birth_dt_tm = cnvtdatetime(result->birth_dt_tm)
   SET dialoguerequest->commonreply_ind = 1
   SET dialoguerequest->position_cd = 227469966
   FREE RECORD i_request
   RECORD i_request(
     1 prsnl_id = f8
   ) WITH protect
   FREE RECORD i_reply
   RECORD i_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET i_request->prsnl_id =  $5
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",dialoguerequest,
    "REC",dialoguereply,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(dialoguereply)
   IF ((dialoguereply->status_data.status != "F"))
    SET alertcount = size(dialoguereply->alerts,5)
    SET stat = alterlist(result->alerts,alertcount)
    IF (alertcount > 0)
     FOR (i = 1 TO alertcount)
       SET result->alerts[i].title = dialoguereply->alerts[i].title
       SET result->alerts[i].text = trim(replace(replace(replace(replace(dialoguereply->alerts[i].
            text,"’","'",0),"‘","'",0),"â€˜","'",0),"â€™","'",0),3)
       SET result->alerts[i].module_name = dialoguereply->alerts[i].modulename
       SET result->alerts[i].powerform_id = dialoguereply->alerts[i].powerformid
       SET result->alerts[i].cancellabel1 = dialoguereply->alerts[i].cancellabel1
       SET result->alerts[i].ignorelabel2 = dialoguereply->alerts[i].ignorelabel2
       SET result->alerts[i].modifylabel3 = dialoguereply->alerts[i].modifylabel3
       SET result->alerts[i].defaultlabel = dialoguereply->alerts[i].defaultlabel
       SET result->alerts[i].overrideother = dialoguereply->alerts[i].overrideother
       SET overridecnt = size(dialoguereply->alerts[i].overrides,5)
       SET stat = alterlist(result->alerts[i].overrides,overridecnt)
       FOR (jdx = 1 TO overridecnt)
        SET result->alerts[i].overrides[jdx].reasoncd = dialoguereply->alerts[i].overrides[jdx].
        reasoncd
        SET result->alerts[i].overrides[jdx].display = dialoguereply->alerts[i].overrides[jdx].
        display
       ENDFOR
       SET result->alerts[i].urlbutton = dialoguereply->alerts[i].urlbutton
       SET result->alerts[i].urladdress = dialoguereply->alerts[i].urladdress
       SET result->alerts[i].okbutton = dialoguereply->alerts[i].okbutton
       SET result->alerts[i].powerformname = dialoguereply->alerts[i].powerformname
       SET result->alerts[i].powerformbutton = dialoguereply->alerts[i].powerformbutton
       SET result->alerts[i].powerformtext = dialoguereply->alerts[i].powerformtext
       SET result->alerts[i].powerforminprogressstatuscd = dialoguereply->alerts[i].
       powerforminprogressstatuscd
     ENDFOR
    ENDIF
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE getpowerformdetails(null)
  IF (size(result->alerts,5) > 0)
   SELECT INTO "NL:"
    FROM dcp_forms_ref dfr
    PLAN (dfr
     WHERE expand(idx,1,size(result->alerts,5),dfr.dcp_forms_ref_id,result->alerts[idx].powerform_id)
     )
    HEAD dfr.dcp_forms_ref_id
     IF (dfr.dcp_forms_ref_id > 0)
      pos = locateval(locidx,1,size(result->alerts,5),dfr.dcp_forms_ref_id,result->alerts[locidx].
       powerform_id), result->alerts[pos].add_diagnosis_btn_ind = evaluate(dfr.event_cd,
       add_diagnosis_form_cd,1,0)
     ENDIF
    WITH nocounter, time = 30
   ;end select
  ENDIF
  RETURN(fail)
 END ;Subroutine
END GO
