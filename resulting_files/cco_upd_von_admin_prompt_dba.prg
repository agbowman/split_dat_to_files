CREATE PROGRAM cco_upd_von_admin_prompt:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Select Organization to setup:" = 0,
  "Enter extract path:" = "",
  "Enter VON Hospital Number:" = "",
  "Enter Last File number:" = 0
  WITH outdev, org_id, extract_path,
  hosp_num, last_file_num
 DECLARE get_next_seq_id(p1) = f8 WITH protect
 DECLARE insert_rar_data(p_seq_id) = i2 WITH protect
 DECLARE update_rar_data(p_rar_id) = i2 WITH protect
 DECLARE get_rar_id(p_org_id) = f8 WITH protect
 DECLARE print_report(p_rar_id) = null WITH protect
 DECLARE print_error_report(p_err_msg) = null WITH protect
 DECLARE print_cki_error_rpt(p1) = null WITH protect
 DECLARE v_ref_id = f8 WITH noconstant(0.0), protect
 DECLARE success_flag = c1 WITH noconstant("N"), protect
 DECLARE fail_string = vc WITH noconstant(fillstring(30," ")), protect
 DECLARE seq_id = f8 WITH noconstant(- (1.0)), protect
 SET v_ref_id = get_rar_id( $ORG_ID)
 IF (v_ref_id > 0)
  IF (update_rar_data(v_ref_id)=0)
   CALL print_error_report("ERROR UPDATING RAR RECORD")
  ELSE
   COMMIT
   CALL print_cki_error_rpt("")
  ENDIF
 ELSE
  SET seq_id = get_next_seq_id("")
  IF (seq_id > 0)
   IF (insert_rar_data(seq_id)=0)
    CALL print_error_report("ERROR INSERTING RAR RECORD")
   ELSE
    COMMIT
    CALL print_cki_error_rpt("")
   ENDIF
  ELSE
   CALL print_error_report("ERROR GETTING NEXT SEQUENCE NUMBER")
  ENDIF
 ENDIF
 SUBROUTINE get_rar_id(p_org_id)
   DECLARE ref_id = f8 WITH noconstant(- (1.0)), protect
   SELECT INTO "nl:"
    FROM risk_adjustment_ref rar
    WHERE rar.organization_id=p_org_id
     AND rar.active_ind=1
    DETAIL
     ref_id = rar.risk_adjustment_ref_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(- (1.0))
   ELSE
    RETURN(ref_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_next_seq_id(p1)
   DECLARE new_seq_id = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     new_seq_id = cnvtreal(j)
    WITH format, nocounter
   ;end select
   IF (new_seq_id <= 0.0)
    SET success_flag = "N"
    SET fail_string = "ERROR GETTING NEXTVAL FROM CARENET_SEQ"
   ENDIF
   RETURN(new_seq_id)
 END ;Subroutine
 SUBROUTINE insert_rar_data(p_seq_id)
  INSERT  FROM risk_adjustment_ref rar
   SET rar.risk_adjustment_ref_id = p_seq_id, rar.active_ind = 1, rar.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    rar.extract_path =  $EXTRACT_PATH, rar.hospital_code =  $HOSP_NUM, rar.last_file_number =
     $LAST_FILE_NUM,
    rar.organization_id =  $ORG_ID, rar.updt_applctx = reqinfo->updt_applctx, rar.updt_cnt = 0,
    rar.updt_dt_tm = cnvtdatetime(curdate,curtime3), rar.updt_id = reqinfo->updt_id, rar.updt_task =
    reqinfo->updt_task
   WITH nocounter
  ;end insert
  RETURN(curqual)
 END ;Subroutine
 SUBROUTINE update_rar_data(p_rar_id)
  UPDATE  FROM risk_adjustment_ref rar
   SET rar.hospital_code =  $HOSP_NUM, rar.extract_path =  $EXTRACT_PATH, rar.last_file_number =
     $LAST_FILE_NUM,
    rar.updt_applctx = reqinfo->updt_applctx, rar.updt_cnt = (rar.updt_cnt+ 1), rar.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    rar.updt_id = reqinfo->updt_id, rar.updt_task = reqinfo->updt_task
   WHERE rar.risk_adjustment_ref_id=p_rar_id
    AND rar.active_ind=1
   WITH nocounter
  ;end update
  RETURN(curqual)
 END ;Subroutine
 SUBROUTINE print_report(p_rar_id)
   SELECT INTO  $OUTDEV
    o.org_name, rar.hospital_code, rar.extract_path,
    rar.last_extract_dt_tm"@LONGDATETIME", rar.last_file_number, rar.updt_cnt,
    rar.updt_dt_tm"@LONGDATETIME"
    FROM risk_adjustment_ref rar,
     organization o
    PLAN (rar
     WHERE rar.risk_adjustment_ref_id=p_rar_id
      AND rar.active_ind=1)
     JOIN (o
     WHERE o.organization_id=rar.organization_id
      AND o.active_ind=1)
    WITH nocounter, format, separator = " "
   ;end select
 END ;Subroutine
 SUBROUTINE print_error_report(p_err_msg)
   SELECT INTO  $OUTDEV
    error_msg = p_err_msg
    FROM (dummyt d  WITH seq = 1)
    WITH nocounter, format, separator = " "
   ;end select
 END ;Subroutine
 SUBROUTINE print_cki_error_rpt(p1)
   RECORD von(
     1 cnt = i2
     1 event_list[*]
       2 cki = vc
       2 desc = vc
   )
   DECLARE cki_cnt = i2 WITH protect
   DECLARE lp_cnt = i2 WITH protect
   DECLARE bad_cnt = i2 WITH protect
   SET stat = alterlist(von->event_list,100)
   SET cki_cnt = 0
   IF (uar_get_code_by_cki(nullterm("CKI.EC!3333")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!3333"
    SET von->event_list[cki_cnt].desc = "FIO2"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!4051")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!4051"
    SET von->event_list[cki_cnt].desc = "Weight"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!6267")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!6267"
    SET von->event_list[cki_cnt].desc = "Oxygen Flow Rate"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!7215")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!7215"
    SET von->event_list[cki_cnt].desc = "Delivery Type Birth"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!7365")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!7365"
    SET von->event_list[cki_cnt].desc = "Birthweight"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!7672")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!7672"
    SET von->event_list[cki_cnt].desc = "Ventilator Mode"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!7676")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!7676"
    SET von->event_list[cki_cnt].desc = "Ventilator Mode"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!7991")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!7991"
    SET von->event_list[cki_cnt].desc = "Oxygen Therapy"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8089")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8089"
    SET von->event_list[cki_cnt].desc = "Gestational Age - Weeks"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8090")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8090"
    SET von->event_list[cki_cnt].desc = "Gestational Age - Days"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8092")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8092"
    SET von->event_list[cki_cnt].desc = "Location of Birth"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8095")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8095"
    SET von->event_list[cki_cnt].desc = "Mothers Race/Ethnicity"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8096")) < 1.0)
    SET cki_cny = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8096"
    SET von->event_list[cki_cnt].desc = "Risk Factors - Prenatal Care"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8097")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8097"
    SET von->event_list[cki_cnt].desc = "Pregnancy Medications - Antenatal Steroids"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8098")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8098"
    SET von->event_list[cki_cnt].desc = "Multiple Births"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8099")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8099"
    SET von->event_list[cki_cnt].desc = "Number of Infants Delivered"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8100")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8100"
    SET von->event_list[cki_cnt].desc = "APGAR 1 Minute"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8101")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8101"
    SET von->event_list[cki_cnt].desc = "APGAR 5 Minute"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8102")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8102"
    SET von->event_list[cki_cnt].desc = "Delivery Room Resusitation"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8103")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8103"
    SET von->event_list[cki_cnt].desc = "O2 for Heliox"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8105")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8105"
    SET von->event_list[cki_cnt].desc = "Mask/Delivery Type"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8106")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8106"
    SET von->event_list[cki_cnt].desc = "Surfactant in Delivery"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8107")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8107"
    SET von->event_list[cki_cnt].desc = "Inhaled Nitric Oxide"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8108")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8108"
    SET von->event_list[cki_cnt].desc = "Seizures"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8127")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8127"
    SET von->event_list[cki_cnt].desc = "RT Treatment at Discharge"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8128")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8128"
    SET von->event_list[cki_cnt].desc = "Nutrition at discharge"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8129")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8129"
    SET von->event_list[cki_cnt].desc = "Reason for Transfer"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8130")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8130"
    SET von->event_list[cki_cnt].desc = "Discharge Disposition"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8311")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8311"
    SET von->event_list[cki_cnt].desc = "Sepsis Bacterial"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8312")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8312"
    SET von->event_list[cki_cnt].desc = "Meningitis Bacterial"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8315")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8315"
    SET von->event_list[cki_cnt].desc = "Cranial Ultrasound"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8379")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8379"
    SET von->event_list[cki_cnt].desc = "Worst PIH Grade"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8380")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8380"
    SET von->event_list[cki_cnt].desc = "Steroids for CLD"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8381")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8381"
    SET von->event_list[cki_cnt].desc = "PDA Ligation Group"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8385")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8385"
    SET von->event_list[cki_cnt].desc = "Respiratory Distress Syndrome"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8386")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8386"
    SET von->event_list[cki_cnt].desc = "Pneumothorax"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8387")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8387"
    SET von->event_list[cki_cnt].desc = "Patent Ductus Arteriosus"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8388")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8388"
    SET von->event_list[cki_cnt].desc = "Necrotizing Enterocolitis"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8389")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8389"
    SET von->event_list[cki_cnt].desc = "Focal Gastrointestinal Perforation"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8392")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8392"
    SET von->event_list[cki_cnt].desc = "Sepsis Coagulase Negative Staphlococcus"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8394")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8394"
    SET von->event_list[cki_cnt].desc = "Sepsis Fungal"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8395")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8395"
    SET von->event_list[cki_cnt].desc = "Meningitis Fungal"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8396")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8396"
    SET von->event_list[cki_cnt].desc = "Cystic Periventricular Leukomalacia"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8397")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8397"
    SET von->event_list[cki_cnt].desc = "Retinal Exam for ROP"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8398")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8398"
    SET von->event_list[cki_cnt].desc = "Retinal exam for ROP worst stage"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8399")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8399"
    SET von->event_list[cki_cnt].desc = "Major Birth Defects"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8400")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8400"
    SET von->event_list[cki_cnt].desc = "Post Transfer Disposition"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8402")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8402"
    SET von->event_list[cki_cnt].desc = "Meconium Aspiration"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8403")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8403"
    SET von->event_list[cki_cnt].desc = "Tracheal Suction for Meconium"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8404")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8404"
    SET von->event_list[cki_cnt].desc = "Extracorporeal Membrane Oxygenation"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8405")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8405"
    SET von->event_list[cki_cnt].desc = "ECMO, where done"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8406")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8406"
    SET von->event_list[cki_cnt].desc = "Surgery for congenital heart disease"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8407")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8407"
    SET von->event_list[cki_cnt].desc = "Surgery, where done"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8408")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8408"
    SET von->event_list[cki_cnt].desc = "Hypoxic-Ischemic Encephalopathy"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8409")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8409"
    SET von->event_list[cki_cnt].desc = "Hypoxic-Ischemic Encephalopathy Severity"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("CKI.EC!8412")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "CKI.EC!8412"
    SET von->event_list[cki_cnt].desc = "Inhaled Nitric Oxide, where done"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("MUL.ORD!d00039")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "MUL.ORD!d00039"
    SET von->event_list[cki_cnt].desc = "Indomethacin"
   ENDIF
   IF (uar_get_code_by_cki(nullterm("MUL.ORD!d00777")) < 1.0)
    SET cki_cnt = (cki_cnt+ 1)
    SET von->event_list[cki_cnt].cki = "MUL.ORD!d00777"
    SET von->event_list[cki_cnt].desc = "Beractant - Surfactant at any time"
   ENDIF
   SET stat = alterlist(von->event_list,cki_cnt)
   SET von->cnt = cki_cnt
   IF ((von->cnt > 0))
    SELECT INTO  $OUTDEV
     FROM (dummyt d  WITH seq = von->cnt)
     HEAD REPORT
      row + 1, col 20, "VON CKI ERROR RPEORT",
      row + 2, col 1, "ALL CKIs BELOW NEED TO BE MAPPED FOR VON TO FUNCTION",
      row + 1, row + 1, rpt_line = fillstring(60,"-"),
      col 1, rpt_line, row + 1
     DETAIL
      row + 1, col 1, von->event_list[d.seq].cki,
      col 30, von->event_list[d.seq].desc
     WITH nocounter
    ;end select
   ELSE
    CALL print_report(v_ref_id)
   ENDIF
 END ;Subroutine
END GO
