CREATE PROGRAM bhs_prax_discern_dialog
 FREE RECORD result
 RECORD result(
   1 person_id = f8
   1 encntr_id = f8
   1 birth_dt_tm = dq8
   1 sex_cd = f8
   1 alerts[*]
     2 title = vc
     2 text = vc
     2 module_name = vc
 ) WITH protect
 DECLARE calldiscerndialogueserver(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
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
 SELECT INTO "NL:"
  FROM person p
  PLAN (p
   WHERE (p.person_id=result->person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY p.person_id
  HEAD p.person_id
   result->birth_dt_tm = p.birth_dt_tm, result->sex_cd = p.sex_cd
  WITH nocounter, time = 30
 ;end select
 IF ((result->birth_dt_tm <= 0.0))
  CALL echo("INVALID PATIENT DETAILS...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = calldiscerndialogueserver(null)
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
  IF (size(result->alerts,5) > 0)
   SELECT INTO value(moutputdevice)
    FROM (dummyt d  WITH seq = value(size(result->alerts,5)))
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, v1 = build("<PersonId>",cnvtint(result->person_id),"</PersonId>"), col + 1,
     v1, row + 1, v2 = build("<EncounterId>",cnvtint(result->encntr_id),"</EncounterId>"),
     col + 1, v2, row + 1,
     v3 = build("<BirthDtTm>",format(result->birth_dt_tm,"MM/DD/YYYY;;D"),"</BirthDtTm>"), col + 1,
     v3,
     row + 1, v4 = build("<SexCd>",cnvtint(result->sex_cd),"</SexCd>"), col + 1,
     v4, row + 1, col + 1,
     "<Alerts>", row + 1
    DETAIL
     col + 1, "<Alert>", row + 1,
     v5 = build("<Title>",trim(replace(replace(replace(replace(replace(result->alerts[d.seq].title,
            "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Title>"),
     col + 1, v5,
     row + 1, v6 = build("<Text>",trim(replace(replace(replace(replace(replace(result->alerts[d.seq].
            text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
      "</Text>"), col + 1,
     v6, row + 1, v7 = build("<ModuleName>",trim(replace(replace(replace(replace(replace(result->
            alerts[d.seq].module_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
        "&quot;",0),3),"</ModuleName>"),
     col + 1, v7, row + 1,
     col + 1, "</Alert>", row + 1
    FOOT REPORT
     col + 1, "</Alerts>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ELSE
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, v1 = build("<PersonId>",cnvtint(result->person_id),"</PersonId>"), col + 1,
     v1, row + 1, v2 = build("<EncounterId>",cnvtint(result->encntr_id),"</EncounterId>"),
     col + 1, v2, row + 1,
     v3 = build("<BirthDtTm>",format(result->birth_dt_tm,"MM/DD/YYYY HH:MM;;D"),"</BirthDtTm>"), col
      + 1, v3,
     row + 1, v4 = build("<SexCd>",cnvtint(result->sex_cd),"</SexCd>"), col + 1,
     v4, row + 1, col + 1,
     "<Alerts>", row + 1
    FOOT REPORT
     col + 1, "</Alerts>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
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
   SET dialoguerequest->birth_dt_tm = result->birth_dt_tm
   SET dialoguerequest->commonreply_ind = 1
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
   EXECUTE bhs_prax_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
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
       SET result->alerts[i].text = dialoguereply->alerts[i].text
       SET result->alerts[i].module_name = dialoguereply->alerts[i].modulename
     ENDFOR
    ENDIF
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
