CREATE PROGRAM bhs_prax_sign_order_alerts
 FREE RECORD result
 RECORD result(
   1 person_id = f8
   1 encntr_id = f8
   1 birth_dt_tm = dq8
   1 sex_cd = f8
   1 prsnl_id = f8
   1 position_cd = f8
   1 catalog_type_cd = f8
   1 activity_type_cd = f8
   1 activity_subtype_cd = f8
   1 alerts[*]
     2 title = vc
     2 text = vc
     2 module_name = vc
     2 defaultfirstorder = vc
     2 orders[*]
       3 actionflag = i2
       3 mnemonic = vc
       3 catalogcd = f8
       3 synonymid = f8
       3 oeformatid = f8
       3 ordersentenceid = f8
       3 ordersentencedisplay = vc
       3 multum_dosing_ind = i2
       3 multum_dnum = vc
       3 detaillist[*]
         4 oefieldid = f8
         4 oefieldvalue = f8
         4 oefielddisplayvalue = vc
         4 oefielddttmvalue = vc
         4 oefieldmeaning = vc
         4 oefieldmeaningid = f8
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
     2 powerformid = f8
     2 powerformname = vc
     2 powerformbutton = vc
     2 powerformtext = vc
     2 powerforminprogressstatuscd = f8
 ) WITH protect
 DECLARE calldiscerndialogueserver(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE kdx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET result->encntr_id =  $2
 SELECT INTO "NL:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE (e.encntr_id=result->encntr_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < sysdate
    AND e.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY p.person_id
  HEAD p.person_id
   CALL echo(build("PATIENT NAME: ",p.name_full_formatted)), result->person_id = p.person_id, result
   ->birth_dt_tm = p.birth_dt_tm,
   result->sex_cd = p.sex_cd
  WITH nocounter, time = 30
 ;end select
 IF ((((result->birth_dt_tm <= 0.0)) OR ((result->person_id <= 0.0))) )
  CALL echo("INVALID PATIENT DETAILS...EXITING")
  GO TO exit_script
 ENDIF
 SET result->prsnl_id =  $3
 SELECT INTO "NL:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=result->prsnl_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY p.person_id
  HEAD p.person_id
   result->position_cd = p.position_cd
  WITH nocounter, time = 30
 ;end select
 IF ((result->position_cd <= 0.0))
  CALL echo("INVALID PERSONNEL DETAILS...EXITING")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM order_catalog oc
  PLAN (oc
   WHERE (oc.catalog_cd= $9)
    AND oc.active_ind=1)
  HEAD oc.catalog_cd
   result->catalog_type_cd = oc.catalog_type_cd, result->activity_type_cd = oc.activity_type_cd,
   result->activity_subtype_cd = oc.activity_subtype_cd
  WITH nocounter, time = 30
 ;end select
 CALL echo("PARSING ORDER ENTRY DETAILS PARAMETER")
 FREE RECORD req_oeparse
 RECORD req_oeparse(
   1 oe_params = vc
 ) WITH protect
 FREE RECORD rep_oeparse
 RECORD rep_oeparse(
   1 detaillist[*]
     2 oefieldid = f8
     2 oefieldvalue = f8
     2 oefielddisplayvalue = vc
     2 oefielddttmvalue = dq8
     2 oefieldmeaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SET req_oeparse->oe_params = trim( $21,3)
 EXECUTE bhs_prax_parse_oe_details  WITH replace("REQUEST","REQ_OEPARSE"), replace("REPLY",
  "REP_OEPARSE")
 IF ((rep_oeparse->status_data.status != "S"))
  CALL echo("PARSE_OE_DETAILS FAILED...EXITING!")
  GO TO exit_script
 ENDIF
 DECLARE c_bsa_mostellar = f8 WITH protect, constant(1.0)
 DECLARE c_bsa_haycock = f8 WITH protect, constant(2.0)
 DECLARE c_bsa_dubois = f8 WITH protect, constant(3.0)
 DECLARE c_bsa_gehan_george = f8 WITH protect, constant(4.0)
 DECLARE detaillistcnt = i4 WITH protect, noconstant(0)
 DECLARE bsa_pref = f8 WITH protect, noconstant(0.0)
 DECLARE bsa_pref_display = vc WITH protect, noconstant("")
 SELECT INTO "NL:"
  FROM dm_prefs dp
  PLAN (dp
   WHERE dp.pref_domain="PHARMNET"
    AND dp.pref_name="BSA EQUATION")
  ORDER BY dp.pref_id DESC
  HEAD dp.pref_name
   bsa_pref = evaluate(cnvtupper(trim(dp.pref_str,3)),"MOSTELLER",c_bsa_mostellar,"HAYCOCK",
    c_bsa_haycock,
    "DUBOIS",c_bsa_dubois,"GEHAN_GEORGE",c_bsa_gehan_george,0.0)
   IF (bsa_pref > 0.0)
    bsa_pref_display = concat(trim(cnvtstring(cnvtint(bsa_pref)),3)," - ",trim(dp.pref_str,3)),
    CALL echo(build("ADDING OEFIELD TO DETAILLIST: ",bsa_pref_display)), detaillistcnt = (size(
     rep_oeparse->detaillist,5)+ 1),
    CALL echo(build("DETAILLISTCNT:",detaillistcnt)), stat = alterlist(rep_oeparse->detaillist,
     detaillistcnt), rep_oeparse->detaillist[detaillistcnt].oefieldid = 0.0,
    rep_oeparse->detaillist[detaillistcnt].oefieldvalue = bsa_pref, rep_oeparse->detaillist[
    detaillistcnt].oefielddisplayvalue = bsa_pref_display, rep_oeparse->detaillist[detaillistcnt].
    oefielddttmvalue = 0.0,
    rep_oeparse->detaillist[detaillistcnt].oefieldmeaning = "BSAPREF"
   ENDIF
  WITH nocounter, time = 30
 ;end select
 IF (bsa_pref <= 0.0)
  CALL echo("INVALID BSA_PREF...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = calldiscerndialogueserver(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
#exit_script
 EXECUTE bhs_prax_alerts_write_output
 FREE RECORD result
 FREE RECORD req_oeparse
 FREE RECORD rep_oeparse
 SUBROUTINE calldiscerndialogueserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(3072000)
   DECLARE requestid = i4 WITH constant(3072006)
   DECLARE alertcnt = i4 WITH protect, noconstant(0)
   DECLARE ordercnt = i4 WITH protect, noconstant(0)
   DECLARE detailcnt = i4 WITH protect, noconstant(0)
   DECLARE overridecnt = i4 WITH protect, noconstant(0)
   DECLARE c_cps_sign_ord_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12600,
     "CPS_SIGN_ORD"))
   DECLARE c_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
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
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_prax_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
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
   SET dialoguerequest->req_type_cd = c_cps_sign_ord_cd
   SET dialoguerequest->person_id = result->person_id
   SET dialoguerequest->encntr_id = result->encntr_id
   SET dialoguerequest->sex_cd = result->sex_cd
   SET dialoguerequest->birth_dt_tm = result->birth_dt_tm
   SET dialoguerequest->height =  $4
   SET dialoguerequest->height_unit_cd =  $5
   SET dialoguerequest->weight =  $6
   SET dialoguerequest->weight_unit_cd =  $7
   SET dialoguerequest->commonreply_ind = 1
   SET dialoguerequest->passthru_ind = 0
   SET dialoguerequest->trigger_app = 0
   SET dialoguerequest->position_cd = result->position_cd
   SET stat = alterlist(dialoguerequest->orderlist,1)
   SET dialoguerequest->orderlist[1].synonym_code =  $8
   SET dialoguerequest->orderlist[1].catalog_code =  $9
   SET dialoguerequest->orderlist[1].catalogtypecd = result->catalog_type_cd
   SET dialoguerequest->orderlist[1].orderid =  $10
   SET dialoguerequest->orderlist[1].actiontypecd = c_order_cd
   SET dialoguerequest->orderlist[1].activitytypecd = result->activity_type_cd
   SET dialoguerequest->orderlist[1].activitysubtypecd = result->activity_subtype_cd
   SET dialoguerequest->orderlist[1].dose =  $11
   SET dialoguerequest->orderlist[1].dose_unit =  $12
   SET dialoguerequest->orderlist[1].start_dt_tm = cnvtdatetime( $13)
   SET dialoguerequest->orderlist[1].end_dt_tm = cnvtdatetime( $14)
   SET dialoguerequest->orderlist[1].route =  $15
   SET dialoguerequest->orderlist[1].frequency =  $16
   SET dialoguerequest->orderlist[1].physician =  $17
   SET dialoguerequest->orderlist[1].rate =  $18
   SET dialoguerequest->orderlist[1].infuse_over =  $19
   SET dialoguerequest->orderlist[1].infuse_over_unit_cd =  $20
   SET stat = alterlist(dialoguerequest->orderlist[1].detaillist,size(rep_oeparse->detaillist,5))
   FOR (idx = 1 TO size(rep_oeparse->detaillist,5))
     SET dialoguerequest->orderlist[1].detaillist[idx].oefieldid = rep_oeparse->detaillist[idx].
     oefieldid
     SET dialoguerequest->orderlist[1].detaillist[idx].oefieldvalue = rep_oeparse->detaillist[idx].
     oefieldvalue
     SET dialoguerequest->orderlist[1].detaillist[idx].oefielddisplayvalue = rep_oeparse->detaillist[
     idx].oefielddisplayvalue
     SET dialoguerequest->orderlist[1].detaillist[idx].oefielddttmvalue = rep_oeparse->detaillist[idx
     ].oefielddttmvalue
     SET dialoguerequest->orderlist[1].detaillist[idx].oefieldmeaning = rep_oeparse->detaillist[idx].
     oefieldmeaning
   ENDFOR
   CALL echorecord(dialoguerequest)
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
    SET alertcnt = size(dialoguereply->alerts,5)
    SET stat = alterlist(result->alerts,alertcnt)
    FOR (idx = 1 TO alertcnt)
      SET result->alerts[idx].title = dialoguereply->alerts[idx].title
      SET result->alerts[idx].text = dialoguereply->alerts[idx].text
      SET result->alerts[idx].module_name = dialoguereply->alerts[idx].modulename
      SET result->alerts[idx].defaultfirstorder = dialoguereply->alerts[idx].defaultfirstorder
      SET ordercnt = size(dialoguereply->alerts[idx].orders,5)
      SET stat = alterlist(result->alerts[idx].orders,ordercnt)
      FOR (jdx = 1 TO ordercnt)
        SET result->alerts[idx].orders[jdx].actionflag = dialoguereply->alerts[idx].orders[jdx].
        actionflag
        SET result->alerts[idx].orders[jdx].mnemonic = dialoguereply->alerts[idx].orders[jdx].
        mnemonic
        SET result->alerts[idx].orders[jdx].catalogcd = dialoguereply->alerts[idx].orders[jdx].
        catalogcd
        SET result->alerts[idx].orders[jdx].synonymid = dialoguereply->alerts[idx].orders[jdx].
        synonymid
        SET result->alerts[idx].orders[jdx].oeformatid = dialoguereply->alerts[idx].orders[jdx].
        oeformatid
        SET result->alerts[idx].orders[jdx].ordersentenceid = dialoguereply->alerts[idx].orders[jdx].
        ordersentenceid
        SET result->alerts[idx].orders[jdx].ordersentencedisplay = dialoguereply->alerts[idx].orders[
        jdx].ordersentencedisplay
        SET result->alerts[idx].orders[jdx].multum_dosing_ind = dialoguereply->alerts[idx].orders[jdx
        ].multum_dosing_ind
        SET result->alerts[idx].orders[jdx].multum_dnum = dialoguereply->alerts[idx].orders[jdx].
        multum_dnum
        SET detailcnt = size(dialoguereply->alerts[idx].orders[jdx].detaillist,5)
        SET stat = alterlist(result->alerts[idx].orders[jdx].detaillist,detailcnt)
        FOR (kdx = 1 TO detailcnt)
          SET result->alerts[idx].orders[jdx].detaillist[kdx].oefieldid = dialoguereply->alerts[idx].
          orders[jdx].detaillist[kdx].oefieldid
          SET result->alerts[idx].orders[jdx].detaillist[kdx].oefieldvalue = dialoguereply->alerts[
          idx].orders[jdx].detaillist[kdx].oefieldvalue
          SET result->alerts[idx].orders[jdx].detaillist[kdx].oefielddisplayvalue = dialoguereply->
          alerts[idx].orders[jdx].detaillist[kdx].oefielddisplayvalue
          SET result->alerts[idx].orders[jdx].detaillist[kdx].oefielddttmvalue = dialoguereply->
          alerts[idx].orders[jdx].detaillist[kdx].oefielddttmvalue
          SET result->alerts[idx].orders[jdx].detaillist[kdx].oefieldmeaning = dialoguereply->alerts[
          idx].orders[jdx].detaillist[kdx].oefieldmeaning
          SET result->alerts[idx].orders[jdx].detaillist[kdx].oefieldmeaningid = dialoguereply->
          alerts[idx].orders[jdx].detaillist[kdx].oefieldmeaningid
        ENDFOR
      ENDFOR
      SET result->alerts[idx].cancellabel1 = dialoguereply->alerts[idx].cancellabel1
      SET result->alerts[idx].ignorelabel2 = dialoguereply->alerts[idx].ignorelabel2
      SET result->alerts[idx].modifylabel3 = dialoguereply->alerts[idx].modifylabel3
      SET result->alerts[idx].defaultlabel = dialoguereply->alerts[idx].defaultlabel
      SET result->alerts[idx].overrideother = dialoguereply->alerts[idx].overrideother
      SET overridecnt = size(dialoguereply->alerts[idx].overrides,5)
      SET stat = alterlist(result->alerts[idx].overrides,overridecnt)
      FOR (jdx = 1 TO overridecnt)
       SET result->alerts[idx].overrides[jdx].reasoncd = dialoguereply->alerts[idx].overrides[jdx].
       reasoncd
       SET result->alerts[idx].overrides[jdx].display = dialoguereply->alerts[idx].overrides[jdx].
       display
      ENDFOR
      SET result->alerts[idx].urlbutton = dialoguereply->alerts[idx].urlbutton
      SET result->alerts[idx].urladdress = dialoguereply->alerts[idx].urladdress
      SET result->alerts[idx].okbutton = dialoguereply->alerts[idx].okbutton
      SET result->alerts[idx].powerformid = dialoguereply->alerts[idx].powerformid
      SET result->alerts[idx].powerformname = dialoguereply->alerts[idx].powerformname
      SET result->alerts[idx].powerformbutton = dialoguereply->alerts[idx].powerformbutton
      SET result->alerts[idx].powerformtext = dialoguereply->alerts[idx].powerformtext
      SET result->alerts[idx].powerforminprogressstatuscd = dialoguereply->alerts[idx].
      powerforminprogressstatuscd
    ENDFOR
    CALL echorecord(result)
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
