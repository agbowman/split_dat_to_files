CREATE PROGRAM bed_aud_form_status:dba
 IF ( NOT (validate(request,0)))
  FREE SET request
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 synonyms[*]
      2 synonym_id = f8
    1 facilities[*]
      2 facility_code_value = f8
  )
 ENDIF
 FREE SET reply
 RECORD reply(
   1 collist[*]
     2 header_text = vc
     2 data_type = i2
     2 hide_ind = i2
   1 rowlist[*]
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
   1 high_volume_flag = i2
   1 output_filename = vc
   1 run_status_flag = i2
   1 statlist[*]
     2 statistic_meaning = vc
     2 status_flag = i2
     2 qualifying_items = i4
     2 total_items = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE rx_syn_vsby_ind_col_exist = i2 WITH protect, noconstant(0)
 DECLARE listsize = i4 WITH protect, noconstant(6)
 IF (checkdic("OCS_FACILITY_FORMULARY_R.RX_SYNONYM_VISIBILITY_IND","A",0) > 0)
  SET rx_syn_vsby_ind_col_exist = 1
 ENDIF
 IF (rx_syn_vsby_ind_col_exist=1)
  SET listsize = 7
 ENDIF
 SET stat = alterlist(reply->collist,listsize)
 SET reply->collist[1].header_text = "Orderable"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Synonym"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Synonym Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Facility"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Inpatient Setting"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Outpatient Setting"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 IF (rx_syn_vsby_ind_col_exist=1)
  SET reply->collist[7].header_text = "Rx Visibility Setting"
  SET reply->collist[7].data_type = 1
  SET reply->collist[7].hide_ind = 0
 ENDIF
 DECLARE orderabledisplay = vc WITH protect, noconstant("")
 DECLARE synonymdisplay = vc WITH protect, noconstant("")
 DECLARE facilitydisplay = vc WITH protect, noconstant("")
 DECLARE inpatientdisplay = vc WITH protect, noconstant("")
 DECLARE outpatientdisplay = vc WITH protect, noconstant("")
 DECLARE ancillarycodevalue = f8 WITH protect, noconstant(0)
 DECLARE genericnamecodevalue = f8 WITH protect, noconstant(0)
 DECLARE outreachcodevalue = f8 WITH protect, noconstant(0)
 DECLARE pathlinkcodevalue = f8 WITH protect, noconstant(0)
 DECLARE faccount = i4 WITH protect, noconstant(0)
 DECLARE syncount = i4 WITH protect, noconstant(0)
 DECLARE rowcount = i4 WITH protect, noconstant(0)
 SET faccount = size(request->facilities,5)
 SET syncount = size(request->synonyms,5)
 SET rowcount = 0
 SET ancillarycodevalue = uar_get_code_by("MEANING",6011,"ANCILLARY")
 SET genericnamecodevalue = uar_get_code_by("MEANING",6011,"GENERICNAME")
 SET outreachcodevalue = uar_get_code_by("MEANING",6011,"OUTREACH")
 SET pathlinkcodevalue = uar_get_code_by("MEANING",6011,"PATHLINK")
 IF (faccount > 0
  AND syncount > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = faccount),
    (dummyt d2  WITH seq = syncount),
    ocs_facility_formulary_r ocsffr,
    order_catalog_synonym ocs,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4,
    code_value cv5
   PLAN (d1)
    JOIN (d2)
    JOIN (ocsffr
    WHERE ocsffr.ocs_facility_formulary_r_id > 0
     AND (ocsffr.facility_cd=request->facilities[d1.seq].facility_code_value)
     AND (ocsffr.synonym_id=request->synonyms[d2.seq].synonym_id))
    JOIN (ocs
    WHERE ocs.synonym_id=ocsffr.synonym_id
     AND  NOT (ocs.mnemonic_type_cd IN (ancillarycodevalue, genericnamecodevalue, outreachcodevalue,
    pathlinkcodevalue)))
    JOIN (cv1
    WHERE ocsffr.facility_cd=cv1.code_value)
    JOIN (cv2
    WHERE ocs.catalog_cd=cv2.code_value)
    JOIN (cv3
    WHERE ocsffr.inpatient_formulary_status_cd=cv3.code_value)
    JOIN (cv4
    WHERE ocsffr.outpatient_formulary_status_cd=cv4.code_value)
    JOIN (cv5
    WHERE ocs.mnemonic_type_cd=cv5.code_value)
   ORDER BY cnvtupper(cv2.description), cnvtupper(ocs.mnemonic), cnvtupper(cv1.display)
   DETAIL
    orderabledisplay = "", synonymdisplay = "", facilitydisplay = "",
    inpatientdisplay = "", outpatientdisplay = ""
    IF (cv2.code_value > 0)
     IF (cv2.active_ind=1)
      orderabledisplay = cv2.description
     ENDIF
    ELSE
     orderabledisplay = "<All Orderables>"
    ENDIF
    IF (ocs.synonym_id > 0)
     IF (ocs.active_ind=1)
      synonymdisplay = ocs.mnemonic
     ENDIF
    ELSE
     synonymdisplay = "<All Synonyms>"
    ENDIF
    IF (cv1.code_value > 0)
     IF (cv1.active_ind=1)
      facilitydisplay = cv1.display
     ENDIF
    ELSE
     facilitydisplay = "<All Facilities>"
    ENDIF
    IF (cv3.code_value > 0)
     inpatientdisplay = cv3.display
    ELSE
     inpatientdisplay = "Not Set"
    ENDIF
    IF (cv4.code_value > 0)
     outpatientdisplay = cv4.display
    ELSE
     outpatientdisplay = "Not Set"
    ENDIF
    IF (textlen(trim(orderabledisplay)) > 0
     AND textlen(trim(synonymdisplay)) > 0
     AND textlen(trim(facilitydisplay)) > 0)
     rowcount = (rowcount+ 1), stat = alterlist(reply->rowlist,rowcount), stat = alterlist(reply->
      rowlist[rowcount].celllist,listsize),
     reply->rowlist[rowcount].celllist[1].string_value = orderabledisplay, reply->rowlist[rowcount].
     celllist[2].string_value = synonymdisplay, reply->rowlist[rowcount].celllist[3].string_value =
     cv5.display,
     reply->rowlist[rowcount].celllist[4].string_value = facilitydisplay, reply->rowlist[rowcount].
     celllist[5].string_value = inpatientdisplay, reply->rowlist[rowcount].celllist[6].string_value
      = outpatientdisplay
     IF (rx_syn_vsby_ind_col_exist=1)
      IF (ocsffr.rx_synonym_visibility_ind=1)
       reply->rowlist[rowcount].celllist[7].string_value = "On"
      ELSE
       reply->rowlist[rowcount].celllist[7].string_value = "Off"
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (faccount > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = faccount),
    ocs_facility_formulary_r ocsffr,
    order_catalog_synonym ocs,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4,
    code_value cv5
   PLAN (d)
    JOIN (ocsffr
    WHERE ocsffr.ocs_facility_formulary_r_id > 0
     AND (ocsffr.facility_cd=request->facilities[d.seq].facility_code_value))
    JOIN (ocs
    WHERE ocs.synonym_id=ocsffr.synonym_id
     AND  NOT (ocs.mnemonic_type_cd IN (ancillarycodevalue, genericnamecodevalue, outreachcodevalue,
    pathlinkcodevalue)))
    JOIN (cv1
    WHERE ocsffr.facility_cd=cv1.code_value)
    JOIN (cv2
    WHERE ocs.catalog_cd=cv2.code_value)
    JOIN (cv3
    WHERE ocsffr.inpatient_formulary_status_cd=cv3.code_value)
    JOIN (cv4
    WHERE ocsffr.outpatient_formulary_status_cd=cv4.code_value)
    JOIN (cv5
    WHERE ocs.mnemonic_type_cd=cv5.code_value)
   ORDER BY cnvtupper(cv2.description), cnvtupper(ocs.mnemonic), cnvtupper(cv1.display)
   DETAIL
    orderabledisplay = "", synonymdisplay = "", facilitydisplay = "",
    inpatientdisplay = "", outpatientdisplay = ""
    IF (cv2.code_value > 0)
     IF (cv2.active_ind=1)
      orderabledisplay = cv2.description
     ENDIF
    ELSE
     orderabledisplay = "<All Orderables>"
    ENDIF
    IF (ocs.synonym_id > 0)
     IF (ocs.active_ind=1)
      synonymdisplay = ocs.mnemonic
     ENDIF
    ELSE
     synonymdisplay = "<All Synonyms>"
    ENDIF
    IF (cv1.code_value > 0)
     IF (cv1.active_ind=1)
      facilitydisplay = cv1.display
     ENDIF
    ELSE
     facilitydisplay = "<All Facilities>"
    ENDIF
    IF (cv3.code_value > 0)
     inpatientdisplay = cv3.display
    ELSE
     inpatientdisplay = "Not Set"
    ENDIF
    IF (cv4.code_value > 0)
     outpatientdisplay = cv4.display
    ELSE
     outpatientdisplay = "Not Set"
    ENDIF
    IF (textlen(trim(orderabledisplay)) > 0
     AND textlen(trim(synonymdisplay)) > 0
     AND textlen(trim(facilitydisplay)) > 0)
     rowcount = (rowcount+ 1), stat = alterlist(reply->rowlist,rowcount), stat = alterlist(reply->
      rowlist[rowcount].celllist,listsize),
     reply->rowlist[rowcount].celllist[1].string_value = orderabledisplay, reply->rowlist[rowcount].
     celllist[2].string_value = synonymdisplay, reply->rowlist[rowcount].celllist[3].string_value =
     cv5.display,
     reply->rowlist[rowcount].celllist[4].string_value = facilitydisplay, reply->rowlist[rowcount].
     celllist[5].string_value = inpatientdisplay, reply->rowlist[rowcount].celllist[6].string_value
      = outpatientdisplay
     IF (rx_syn_vsby_ind_col_exist=1)
      IF (ocsffr.rx_synonym_visibility_ind=1)
       reply->rowlist[rowcount].celllist[7].string_value = "On"
      ELSE
       reply->rowlist[rowcount].celllist[7].string_value = "Off"
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (syncount > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = syncount),
    ocs_facility_formulary_r ocsffr,
    order_catalog_synonym ocs,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4,
    code_value cv5
   PLAN (d)
    JOIN (ocsffr
    WHERE ocsffr.ocs_facility_formulary_r_id > 0
     AND (ocsffr.synonym_id=request->synonyms[d.seq].synonym_id))
    JOIN (ocs
    WHERE ocs.synonym_id=ocsffr.synonym_id
     AND  NOT (ocs.mnemonic_type_cd IN (ancillarycodevalue, genericnamecodevalue, outreachcodevalue,
    pathlinkcodevalue)))
    JOIN (cv1
    WHERE ocsffr.facility_cd=cv1.code_value)
    JOIN (cv2
    WHERE ocs.catalog_cd=cv2.code_value)
    JOIN (cv3
    WHERE ocsffr.inpatient_formulary_status_cd=cv3.code_value)
    JOIN (cv4
    WHERE ocsffr.outpatient_formulary_status_cd=cv4.code_value)
    JOIN (cv5
    WHERE ocs.mnemonic_type_cd=cv5.code_value)
   ORDER BY cnvtupper(cv2.description), cnvtupper(ocs.mnemonic), cnvtupper(cv1.display)
   DETAIL
    orderabledisplay = "", synonymdisplay = "", facilitydisplay = "",
    inpatientdisplay = "", outpatientdisplay = ""
    IF (cv2.code_value > 0)
     IF (cv2.active_ind=1)
      orderabledisplay = cv2.description
     ENDIF
    ELSE
     orderabledisplay = "<All Orderables>"
    ENDIF
    IF (ocs.synonym_id > 0)
     IF (ocs.active_ind=1)
      synonymdisplay = ocs.mnemonic
     ENDIF
    ELSE
     synonymdisplay = "<All Synonyms>"
    ENDIF
    IF (cv1.code_value > 0)
     IF (cv1.active_ind=1)
      facilitydisplay = cv1.display
     ENDIF
    ELSE
     facilitydisplay = "<All Facilities>"
    ENDIF
    IF (cv3.code_value > 0)
     inpatientdisplay = cv3.display
    ELSE
     inpatientdisplay = "Not Set"
    ENDIF
    IF (cv4.code_value > 0)
     outpatientdisplay = cv4.display
    ELSE
     outpatientdisplay = "Not Set"
    ENDIF
    IF (textlen(trim(orderabledisplay)) > 0
     AND textlen(trim(synonymdisplay)) > 0
     AND textlen(trim(facilitydisplay)) > 0)
     rowcount = (rowcount+ 1), stat = alterlist(reply->rowlist,rowcount), stat = alterlist(reply->
      rowlist[rowcount].celllist,listsize),
     reply->rowlist[rowcount].celllist[1].string_value = orderabledisplay, reply->rowlist[rowcount].
     celllist[2].string_value = synonymdisplay, reply->rowlist[rowcount].celllist[3].string_value =
     cv5.display,
     reply->rowlist[rowcount].celllist[4].string_value = facilitydisplay, reply->rowlist[rowcount].
     celllist[5].string_value = inpatientdisplay, reply->rowlist[rowcount].celllist[6].string_value
      = outpatientdisplay
     IF (rx_syn_vsby_ind_col_exist=1)
      IF (ocsffr.rx_synonym_visibility_ind=1)
       reply->rowlist[rowcount].celllist[7].string_value = "On"
      ELSE
       reply->rowlist[rowcount].celllist[7].string_value = "Off"
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM ocs_facility_formulary_r ocsffr,
    order_catalog_synonym ocs,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4,
    code_value cv5
   PLAN (ocsffr
    WHERE ocsffr.ocs_facility_formulary_r_id > 0)
    JOIN (ocs
    WHERE ocs.synonym_id=ocsffr.synonym_id
     AND  NOT (ocs.mnemonic_type_cd IN (ancillarycodevalue, genericnamecodevalue, outreachcodevalue,
    pathlinkcodevalue)))
    JOIN (cv1
    WHERE ocsffr.facility_cd=cv1.code_value)
    JOIN (cv2
    WHERE ocs.catalog_cd=cv2.code_value)
    JOIN (cv3
    WHERE ocsffr.inpatient_formulary_status_cd=cv3.code_value)
    JOIN (cv4
    WHERE ocsffr.outpatient_formulary_status_cd=cv4.code_value)
    JOIN (cv5
    WHERE ocs.mnemonic_type_cd=cv5.code_value)
   ORDER BY cnvtupper(cv2.description), cnvtupper(ocs.mnemonic), cnvtupper(cv1.display)
   DETAIL
    orderabledisplay = "", synonymdisplay = "", facilitydisplay = "",
    inpatientdisplay = "", outpatientdisplay = ""
    IF (cv2.code_value > 0)
     IF (cv2.active_ind=1)
      orderabledisplay = cv2.description
     ENDIF
    ELSE
     orderabledisplay = "<All Orderables>"
    ENDIF
    IF (ocs.synonym_id > 0)
     IF (ocs.active_ind=1)
      synonymdisplay = ocs.mnemonic
     ENDIF
    ELSE
     synonymdisplay = "<All Synonyms>"
    ENDIF
    IF (cv1.code_value > 0)
     IF (cv1.active_ind=1)
      facilitydisplay = cv1.display
     ENDIF
    ELSE
     facilitydisplay = "<All Facilities>"
    ENDIF
    IF (cv3.code_value > 0)
     inpatientdisplay = cv3.display
    ELSE
     inpatientdisplay = "Not Set"
    ENDIF
    IF (cv4.code_value > 0)
     outpatientdisplay = cv4.display
    ELSE
     outpatientdisplay = "Not Set"
    ENDIF
    IF (textlen(trim(orderabledisplay)) > 0
     AND textlen(trim(synonymdisplay)) > 0
     AND textlen(trim(facilitydisplay)) > 0)
     rowcount = (rowcount+ 1), stat = alterlist(reply->rowlist,rowcount), stat = alterlist(reply->
      rowlist[rowcount].celllist,listsize),
     reply->rowlist[rowcount].celllist[1].string_value = orderabledisplay, reply->rowlist[rowcount].
     celllist[2].string_value = synonymdisplay, reply->rowlist[rowcount].celllist[3].string_value =
     cv5.display,
     reply->rowlist[rowcount].celllist[4].string_value = facilitydisplay, reply->rowlist[rowcount].
     celllist[5].string_value = inpatientdisplay, reply->rowlist[rowcount].celllist[6].string_value
      = outpatientdisplay
     IF (rx_syn_vsby_ind_col_exist=1)
      IF (ocsffr.rx_synonym_visibility_ind=1)
       reply->rowlist[rowcount].celllist[7].string_value = "On"
      ELSE
       reply->rowlist[rowcount].celllist[7].string_value = "Off"
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  IF (rowcount > 30000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (rowcount > 20000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("form_status_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
