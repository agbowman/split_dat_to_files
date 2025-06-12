CREATE PROGRAM di_dialogprefetch:dba
 CALL echo(concat(" *********** request->commonreply_ind in di_dialogprefetch : ",build(request->
    commonreply_ind)))
 IF (validate(request->commonreply_ind,0)=1)
  CALL echo("calling eks_dialogcommon.inc")
  RECORD reply(
    1 status = vc
    1 reason = vc
    1 progid = vc
    1 spindex = i2
    1 sp
      2 spindex = i4
      2 addlcnt = i4
      2 addl[*]
        3 index = i4
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
      2 sp
        3 spindex = i4
        3 addlcnt = i4
        3 addl[*]
          4 index = i4
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
      2 sp
        3 spindex = i4
        3 addlcnt = i4
        3 addl[*]
          4 index = i4
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
        3 originating_nomenclature_id = f8
        3 originating_conceptcki = vc
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
        3 originating_nomenclature_id = f8
        3 originating_conceptcki = vc
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
      2 event_attr[*]
        3 attr_name = vc
        3 attr_id = f8
        3 attr_value = vc
      2 browser_indx = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persist
  SET reply->numreply = 0
  SET reply->status_data.status = "Z"
  SET reply->status = ""
  SET reply->progid = ""
  SET reply->spindex = 0
  SET reply->cer_hnam_location = cer_hnam_location
 ELSE
  RECORD reply(
    1 status = vc
    1 reason = vc
    1 progid = vc
    1 spindex = i2
    1 cer_hnam_location = vc
    1 parameterlist[*]
      2 parameter = vc
    1 numreply = i4
    1 qual[*]
      2 status = vc
      2 reason = vc
      2 progid = vc
      2 spindex = i2
      2 parameterlist[*]
        3 parameter = vc
  )
  SET reply->numreply = 0
  SET reply->status = "E"
  SET reply->progid = "NADA"
  SET reply->spindex = 0
  SET reply->cer_hnam_location = cer_hnam_location
 ENDIF
 RECORD event(
   1 qual[*]
     2 accession_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 logging = c100
     2 cnt = i4
     2 data[*]
       3 misc = vc
 )
 SET eks_common->event_repeat_count = 1
 SET cnt = eks_common->event_repeat_count
 SET stat = alterlist(event->qual,cnt)
 IF ((eks_common->request_number=3072003))
  FOR (inx = 1 TO cnt)
    SET event->qual[inx].order_id = 0.0
    SET event->qual[inx].person_id = request->person_id
    SET event->qual[inx].encntr_id = 0.0
    SET event->qual[inx].accession_id = 0.0
  ENDFOR
  CALL echo(concat("Person id: ",build(request->person_id)))
 ELSE
  FOR (inx = 1 TO cnt)
    SET event->qual[inx].order_id = 0.0
    SET event->qual[inx].person_id = request->person_id
    SET event->qual[inx].encntr_id = request->encntr_id
    SET event->qual[inx].accession_id = 0.0
  ENDFOR
  CALL echo(concat("Person id: ",build(request->person_id)))
  CALL echo(concat("Encntr id: ",build(request->encntr_id)))
 ENDIF
 CALL echo(concat("Person id(EVENTREC): ",build(event->qual[1].person_id)))
 CALL echo(concat("Encntr id(EVENTREC): ",build(event->qual[1].encntr_id)))
END GO
