CREATE PROGRAM acm_rdm_legacy_comm_pref_drr:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE drr_table_and_ccldef_exists(null) = i2
 IF (validate(drr_validate_table->table_name,"X")="X"
  AND validate(drr_validate_table->table_name,"Z")="Z")
  FREE RECORD drr_validate_table
  RECORD drr_validate_table(
    1 msg_returned = vc
    1 list[*]
      2 table_name = vc
      2 status = i2
  )
 ENDIF
 SUBROUTINE drr_table_and_ccldef_exists(null)
   DECLARE dtc_table_num = i4 WITH protect, noconstant(0)
   DECLARE dtc_table_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_ccldef_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_no_ccldef = vc WITH protect, noconstant("")
   DECLARE dtc_no_table = vc WITH protect, noconstant("")
   DECLARE dtc_errmsg = vc WITH protect, noconstant("")
   SET dtc_table_num = size(drr_validate_table->list,5)
   IF (dtc_table_num=0)
    SET drr_validate_table->msg_returned = concat(
     "No table specified in DRR_VALIDATE_TABLE record structure.")
    RETURN(- (1))
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables ut,
     (dummyt d  WITH seq = value(dtc_table_num))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (ut
     WHERE ut.table_name=trim(cnvtupper(drr_validate_table->list[d.seq].table_name)))
    DETAIL
     dtc_table_cnt += 1, drr_validate_table->list[d.seq].status = 1
    WITH nocounter
   ;end select
   IF (error(dtc_errmsg,0) != 0)
    SET drr_validate_table->msg_returned = concat("Select for table existence failed: ",dtc_errmsg)
    RETURN(- (1))
   ELSEIF (dtc_table_cnt=0)
    SET drr_validate_table->msg_returned = concat("No DRR tables found")
    RETURN(0)
   ENDIF
   IF (dtc_table_cnt < dtc_table_num)
    FOR (i = 1 TO dtc_table_num)
      IF ((drr_validate_table->list[i].status=0))
       SET dtc_no_table = concat(dtc_no_table," ",drr_validate_table->list[i].table_name)
      ENDIF
    ENDFOR
    SET drr_validate_table->msg_returned = concat("Missing table",dtc_no_table)
    RETURN(dtc_table_cnt)
   ENDIF
   FOR (i = 1 TO dtc_table_num)
     IF (checkdic(cnvtupper(drr_validate_table->list[i].table_name),"T",0) != 2)
      SET dtc_no_ccldef = concat(dtc_no_ccldef," ",drr_validate_table->list[i].table_name)
      SET drr_validate_table->list[i].status = 0
     ELSE
      SET dtc_ccldef_cnt += 1
     ENDIF
   ENDFOR
   IF (dtc_ccldef_cnt < dtc_table_num)
    SET drr_validate_table->msg_returned = concat("CCL definition missing for ",dtc_no_ccldef)
    RETURN(dtc_ccldef_cnt)
   ENDIF
   RETURN(dtc_table_cnt)
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = concat("FAILED STARTING README ",cnvtstring(readme_data->readme_id))
 FREE RECORD t_legacy_comm_record
 RECORD t_legacy_comm_record(
   1 person_patient[*]
     2 person_id = f8
     2 contact_method_cd = f8
     2 phone_contact_type_cd = f8
     2 pm_hist_tracking_id = f8
     2 person_pref_clinical_comm_id = f8
     2 person_pref_appointment_comm_id = f8
 )
 DECLARE lpptotal = i4 WITH protect, noconstant(0)
 DECLARE ms_errmsg = vc WITH protect, noconstant("")
 DECLARE dactivecd = f8 WITH protect, noconstant(0.0)
 DECLARE dtelephonecd = f8 WITH protect, noconstant(0.0)
 DECLARE dclinicalcommtypecd = f8 WITH protect, noconstant(0.0)
 DECLARE dapptremindertypecd = f8 WITH protect, noconstant(0.0)
 DECLARE lcontactmethodcdtotal = i4 WITH protect, noconstant(0)
 DECLARE lphonecontacttypetotal = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect
 DECLARE ind = i4 WITH protect
 DECLARE load_legacy_person_patient_records(null) = null
 DECLARE get_pm_hist_tracking_ids(null) = null
 CALL echo("Processing... ACM_RDM_COMM_PREF_DRR")
 CALL echo("")
 SET stat = alterlist(drr_validate_table->list,4)
 SET drr_validate_table->list[1].table_name = "PERSON_PATIENT0384DRR"
 SET drr_validate_table->list[2].table_name = "PERSON_PATIENT_HIS7626DRR"
 SET drr_validate_table->list[3].table_name = "PERSON_PREF_COMM6228DRR"
 SET drr_validate_table->list[4].table_name = "PERSON_PREF_COMM_H6229DRR"
 IF (drr_table_and_ccldef_exists(null) != 0
  AND drr_table_and_ccldef_exists(null) != 4)
  SET readme_data->status = "F"
  SET readme_data->message = drr_validate_table->msg_returned
  GO TO exit_program
 ELSEIF (drr_table_and_ccldef_exists(null)=0)
  SET readme_data->status = "S"
  SET readme_data->message = drr_validate_table->msg_returned
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="CLINICALCOMM"
   AND cv.code_set=4640016
   AND cv.active_ind=1
  DETAIL
   dclinicalcommtypecd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error selecting the CDF_MEANING from CODE_VALUE table for CODE_SET 4640016: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="APPTREMINDER"
   AND cv.code_set=4640016
   AND cv.active_ind=1
  DETAIL
   dapptremindertypecd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error selecting the CDF_MEANING from CODE_VALUE table for CODE_SET 4640016: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 FREE RECORD contact_method_cd_list
 RECORD contact_method_cd_list(
   1 list[*]
     2 contact_method_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value_group cvg
  PLAN (cv
   WHERE cv.code_set=23042
    AND cv.active_ind=1)
   JOIN (cvg
   WHERE cv.code_value=cvg.child_code_value
    AND ((cvg.parent_code_value=dclinicalcommtypecd) OR (cvg.parent_code_value=dapptremindertypecd))
    AND cvg.child_code_value > 0)
  DETAIL
   lcontactmethodcdtotal += 1, stat = alterlist(contact_method_cd_list->list,lcontactmethodcdtotal),
   contact_method_cd_list->list[lcontactmethodcdtotal].contact_method_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error selecting CONTACT_METHOD_CDs from CODE_VALUE table for CODE_SET 23042: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 FREE RECORD phone_contact_type_list
 RECORD phone_contact_type_list(
   1 list[*]
     2 phone_contact_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=43
   AND cv.active_ind=1
  DETAIL
   lphonecontacttypetotal += 1, stat = alterlist(phone_contact_type_list->list,lphonecontacttypetotal
    ), phone_contact_type_list->list[lphonecontacttypetotal].phone_contact_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error selecting PHONE_CONTACT_TYPE_CDs from CODE_VALUE table for CODE_SET 43: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="ACTIVE"
   AND cv.code_set=48
   AND cv.active_ind=1
  DETAIL
   dactivecd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error selecting the CDF_MEANING from CODE_VALUE table for CODE_SET 48: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="TELEPHONE"
   AND cv.code_set=23042
   AND cv.active_ind=1
  DETAIL
   dtelephonecd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error selecting the CDF_MEANING from CODE_VALUE table for CODE_SET 23042: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 CALL echo("calling load_legacy_person_patient_records")
 CALL load_legacy_person_patient_records(null)
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error loading the data to t_legacy_comm_record: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 CALL echo("get_pm_hist_tracking_ids")
 CALL get_pm_hist_tracking_ids(null)
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error loading pm_hist_tracking_id within t_legacy_comm_record: ",
   ms_errmsg)
  GO TO exit_program
 ENDIF
 CALL echo("insert_person_pref_comm for CLINICALCOMM")
 CALL insert_person_pref_comm(dclinicalcommtypecd)
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error inserting the data for CLINICALCOMM communication type: ",
   ms_errmsg)
  GO TO exit_program
 ENDIF
 CALL echo("insert_person_pref_comm for APPTREMINDER")
 CALL insert_person_pref_comm(dapptremindertypecd)
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error inserting the data for APPTREMINDER communication type: ",
   ms_errmsg)
  GO TO exit_program
 ENDIF
 CALL echo("insert_person_pref_comm_hist for CLINICALCOMM")
 CALL insert_person_pref_comm_hist(dclinicalcommtypecd)
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error inserting the history data for CLINICALCOMM: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 CALL echo("insert_person_pref_comm_hist for APPTREMINDER")
 CALL insert_person_pref_comm_hist(dapptremindertypecd)
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error inserting the history data for APPTREMINDER: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 SUBROUTINE load_legacy_person_patient_records(null)
   SELECT INTO "nl:"
    person_pref_clinical_comm_id = seq(person_seq,nextval)
    FROM person_patient0384drr pp
    WHERE pp.active_ind=1
     AND pp.person_id > 0
     AND pp.active_status_cd=dactivecd
     AND ((expand(num,1,lcontactmethodcdtotal,pp.contact_method_cd,contact_method_cd_list->list[num].
     contact_method_cd)) OR (expand(ind,1,lphonecontacttypetotal,pp.phone_contact_type_cd,
     phone_contact_type_list->list[ind].phone_contact_type_cd)))
     AND  NOT ( EXISTS (
    (SELECT
     person_pref_comm_id
     FROM person_pref_comm6228drr ppc
     WHERE pp.person_id=ppc.person_id
      AND ppc.active_ind=1
      AND ((ppc.communication_type_cd=dclinicalcommtypecd) OR (ppc.communication_type_cd=
     dapptremindertypecd)) )))
    HEAD REPORT
     lpptotal = 0
    HEAD pp.person_id
     lpptotal += 1
     IF (mod(lpptotal,100)=1)
      stat = alterlist(t_legacy_comm_record->person_patient,(lpptotal+ 99))
     ENDIF
     t_legacy_comm_record->person_patient[lpptotal].person_pref_clinical_comm_id =
     person_pref_clinical_comm_id, t_legacy_comm_record->person_patient[lpptotal].person_id = pp
     .person_id, t_legacy_comm_record->person_patient[lpptotal].contact_method_cd = pp
     .contact_method_cd,
     t_legacy_comm_record->person_patient[lpptotal].phone_contact_type_cd = evaluate(pp
      .contact_method_cd,dtelephonecd,pp.phone_contact_type_cd,0)
    FOOT  pp.person_id
     null
    FOOT REPORT
     stat = alterlist(t_legacy_comm_record->person_patient,lpptotal)
    WITH nocounter
   ;end select
   IF (error(ms_errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error loading data within main query",ms_errmsg)
    GO TO exit_program
   ENDIF
   FOR (idx = 1 TO lpptotal)
     SELECT INTO "nl:"
      seq_value = seq(person_seq,nextval)
      FROM dual
      DETAIL
       t_legacy_comm_record->person_patient[idx].person_pref_appointment_comm_id = seq_value
      WITH nocounter
     ;end select
   ENDFOR
   RETURN(null)
 END ;Subroutine
 SUBROUTINE get_pm_hist_tracking_ids(null)
   IF (lpptotal > 0)
    SELECT INTO "nl:"
     FROM person_patient_his7626drr pph,
      (dummyt d  WITH seq = value(lpptotal))
     PLAN (d)
      JOIN (ppr
      WHERE (pph.person_id=t_legacy_comm_record->person_patient[d.seq].person_id)
       AND (pph.contact_method_cd=t_legacy_comm_record->person_patient[d.seq].contact_method_cd)
       AND (pph.phone_contact_type_cd=t_legacy_comm_record->person_patient[d.seq].
      phone_contact_type_cd))
     ORDER BY d.seq, pph.person_id, pph.updt_dt_tm DESC
     HEAD d.seq
      t_legacy_comm_record->person_patient[d.seq].pm_hist_tracking_id = ppr.pm_hist_tracking_id
     FOOT  d.seq
      null
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (insert_person_pref_comm(communicationtypecd=f8) =null)
  IF (lpptotal > 0)
   INSERT  FROM person_pref_comm6228drr ppc,
     (dummyt d1  WITH seq = value(lpptotal))
    SET ppc.person_pref_comm_id =
     IF (communicationtypecd=dclinicalcommtypecd) t_legacy_comm_record->person_patient[d1.seq].
      person_pref_clinical_comm_id
     ELSE t_legacy_comm_record->person_patient[d1.seq].person_pref_appointment_comm_id
     ENDIF
     , ppc.person_id = t_legacy_comm_record->person_patient[d1.seq].person_id, ppc
     .communication_type_cd = communicationtypecd,
     ppc.contact_method_cd = t_legacy_comm_record->person_patient[d1.seq].contact_method_cd, ppc
     .phone_type_cd = t_legacy_comm_record->person_patient[d1.seq].phone_contact_type_cd, ppc
     .active_ind = 1,
     ppc.active_status_dt_tm = cnvtdatetime(sysdate), ppc.active_status_prsnl_id = reqinfo->updt_id,
     ppc.active_status_cd = dactivecd,
     ppc.updt_id = reqinfo->updt_id, ppc.updt_dt_tm = cnvtdatetime(sysdate), ppc.updt_task = reqinfo
     ->updt_task,
     ppc.updt_applctx = reqinfo->updt_applctx, ppc.updt_cnt = 0
    PLAN (d1)
     JOIN (ppc
     WHERE (t_legacy_comm_record->person_patient[d1.seq].person_id > 0))
    WITH nocounter
   ;end insert
  ENDIF
  RETURN(null)
 END ;Subroutine
 SUBROUTINE (insert_person_pref_comm_hist(communicationtypecd=f8) =null)
  IF (lpptotal > 0)
   INSERT  FROM person_pref_comm_h6229drr ppch,
     (dummyt d1  WITH seq = value(lpptotal))
    SET ppch.person_pref_comm_hist_id = seq(person_seq,nextval), ppch.person_pref_comm_id =
     IF (communicationtypecd=dclinicalcommtypecd) t_legacy_comm_record->person_patient[d1.seq].
      person_pref_clinical_comm_id
     ELSE t_legacy_comm_record->person_patient[d1.seq].person_pref_appointment_comm_id
     ENDIF
     , ppch.communication_type_cd = t_legacy_comm_record->person_patient[d1.seq].
     communication_type_cd,
     ppch.contact_method_cd = t_legacy_comm_record->person_patient[d1.seq].contact_method_cd, ppch
     .phone_type_cd = t_legacy_comm_record->person_patient[d1.seq].phone_type_cd, ppch
     .pm_hist_tracking_id = t_legacy_comm_record->person_patient[d1.seq].pm_hist_tracking_id,
     ppch.active_ind = 1, ppch.active_status_dt_tm = cnvtdatetime(sysdate), ppch
     .active_status_prsnl_id = reqinfo->updt_id,
     ppch.active_status_cd = dactivecd, ppch.updt_dt_tm = cnvtdatetime(sysdate), ppch.updt_task =
     reqinfo->updt_task,
     ppch.updt_applctx = reqinfo->updt_applctx, ppch.updt_cnt = 0
    PLAN (d1)
     JOIN (ppc
     WHERE (t_legacy_comm_record->person_patient[d1.seq].person_id > 0))
    WITH nocounter
   ;end insert
  ENDIF
  RETURN(null)
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Readme completed successfully"
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
