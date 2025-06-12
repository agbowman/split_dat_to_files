CREATE PROGRAM cv_identify_ecgprocedures
 RECORD proc_study_list(
   1 proc[*]
     2 proc_id = f8
     2 step_id = f8
     2 order_id = f8
     2 complete_dt_tm = dq8
     2 patient_name = vc
     2 medicalrec_number = vc
     2 performing_physcian_name = vc
 ) WITH persistscript
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 archive_un = vc
   1 archive_pw = vc
   1 dicom_prefix = vc
   1 study[*]
     2 host_address = vc
     2 siuid = c64
     2 proc_id = f8
     2 order_id = vc
     2 step_id = vc
     2 complete_dt_tm = dq8
     2 signature_line_flag = i2
     2 interp_text = vc
     2 patient_name = vc
     2 medicalrec_number = vc
     2 performing_physcian_name = vc
     2 interp_line[*]
       3 text = vc
 ) WITH persistscript
 DECLARE getsignedprocedures(null) = null WITH copy
 DECLARE getarchivedinterps(null) = null WITH copy
 DECLARE getsiuids(null) = null WITH copy
 DECLARE parseinterps(null) = null WITH copy
 DECLARE getarchiveinformation(null) = null WITH copy
 DECLARE callingechojson(null) = null WITH copy
 CALL getsignedprocedures(null)
 CALL getarchivedinterps(null)
 CALL getsiuids(null)
 CALL parseinterps(null)
 CALL getarchiveinformation(null)
 CALL callingechojson(null)
 CALL echorecord(reply)
 SUBROUTINE getsignedprocedures(null)
   DECLARE proc_type = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,"ECG"))
   DECLARE ecg_step_status_cd_completed = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
     "COMPLETED"))
   DECLARE ecg_proc_status_cd_signed = f8 WITH protect, constant(uar_get_code_by("MEANING",4000341,
     "SIGNED"))
   DECLARE encntr_alias_type_cd_mrn = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
   SELECT INTO "nl:"
    FROM cv_step cs,
     cv_proc c,
     person p,
     prsnl pr,
     encntr_alias e,
     encounter en
    PLAN (cs
     WHERE (cs.task_assay_cd=request->dta)
      AND cs.step_status_cd=ecg_step_status_cd_completed
      AND cs.perf_stop_dt_tm >= cnvtdatetime(request->start_dt_tm)
      AND cs.perf_stop_dt_tm <= cnvtdatetime(request->stop_dt_tm))
     JOIN (c
     WHERE c.cv_proc_id=cs.cv_proc_id
      AND c.activity_subtype_cd=proc_type)
     JOIN (p
     WHERE p.person_id=c.person_id)
     JOIN (pr
     WHERE pr.person_id=cs.updt_id)
     JOIN (en
     WHERE en.encntr_id=c.encntr_id)
     JOIN (e
     WHERE e.encntr_id=en.encntr_id
      AND e.encntr_alias_type_cd=encntr_alias_type_cd_mrn)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (cnt > size(proc_study_list->proc,5))
      stat = alterlist(proc_study_list->proc,(cnt+ 19))
     ENDIF
     proc_study_list->proc[cnt].proc_id = cs.cv_proc_id, proc_study_list->proc[cnt].step_id = cs
     .cv_step_id, proc_study_list->proc[cnt].complete_dt_tm = cs.perf_stop_dt_tm,
     proc_study_list->proc[cnt].patient_name = p.name_full_formatted, proc_study_list->proc[cnt].
     performing_physcian_name = pr.name_full_formatted, proc_study_list->proc[cnt].medicalrec_number
      = e.alias,
     proc_study_list->proc[cnt].order_id = c.order_id
    FOOT REPORT
     stat = alterlist(proc_study_list->proc,cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getarchivedinterps(null)
   DECLARE study_cnt = i4 WITH protect, noconstant(size(proc_study_list->proc,5))
   IF (study_cnt=0)
    RETURN(null)
   ENDIF
   DECLARE c_block_size = i4 WITH protect, constant(20)
   DECLARE study_idx = i4 WITH protect
   DECLARE study_pad = i4 WITH protect
   SET study_pad = (((study_cnt/ c_block_size)+ 1) * c_block_size)
   SET stat = alterlist(proc_study_list->proc,study_pad)
   FOR (study_idx = (study_cnt+ 1) TO study_pad)
    SET proc_study_list->proc[study_idx].proc_id = proc_study_list->proc[study_cnt].proc_id
    SET proc_study_list->proc[study_idx].step_id = proc_study_list->proc[study_cnt].step_id
   ENDFOR
   DECLARE radixlength = i4 WITH noconstant(0)
   DECLARE stepid = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((study_pad/ c_block_size))),
     long_text lt
    PLAN (d
     WHERE d.seq > 0)
     JOIN (lt
     WHERE expand(study_idx,(1+ ((d.seq - 1) * c_block_size)),(d.seq * c_block_size),lt
      .parent_entity_id,proc_study_list->proc[study_idx].step_id,
      c_block_size)
      AND lt.parent_entity_name="CV_STEP")
    HEAD REPORT
     stat = alterlist(reply->study,study_cnt)
    DETAIL
     study_idx = locateval(study_idx,(1+ ((d.seq - 1) * c_block_size)),(d.seq * c_block_size),lt
      .parent_entity_id,proc_study_list->proc[study_idx].step_id), reply->study[study_idx].
     interp_text = trim(lt.long_text), reply->study[study_idx].complete_dt_tm = proc_study_list->
     proc[study_idx].complete_dt_tm,
     stepid = proc_study_list->proc[study_idx].step_id, radixlength = (1+ cnvtint((log(stepid)/ log(
       10)))), reply->study[study_idx].step_id = cnvtstring(stepid,value(radixlength),0),
     reply->study[study_idx].proc_id = proc_study_list->proc[study_idx].proc_id, reply->study[
     study_idx].patient_name = proc_study_list->proc[study_idx].patient_name, reply->study[study_idx]
     .medicalrec_number = proc_study_list->proc[study_idx].medicalrec_number,
     reply->study[study_idx].performing_physcian_name = proc_study_list->proc[study_idx].
     performing_physcian_name, orderid = proc_study_list->proc[study_idx].order_id, radixlength = (1
     + cnvtint((log(orderid)/ log(10)))),
     reply->study[study_idx].order_id = cnvtstring(orderid,value(radixlength),0)
    WITH nocounter
   ;end select
   SET stat = alterlist(proc_study_list->proc,study_cnt)
 END ;Subroutine
 SUBROUTINE getsiuids(null)
   DECLARE study_cnt = i4 WITH protect, noconstant(size(proc_study_list->proc,5))
   IF (study_cnt=0)
    RETURN(null)
   ENDIF
   DECLARE c_block_size = i4 WITH protect, constant(20)
   DECLARE study_idx = i4 WITH protect
   DECLARE study_pad = i4 WITH protect
   SET study_pad = (((study_cnt/ c_block_size)+ 1) * c_block_size)
   SET stat = alterlist(proc_study_list->proc,study_pad)
   FOR (study_idx = (study_cnt+ 1) TO study_pad)
    SET proc_study_list->proc[study_idx].proc_id = proc_study_list->proc[study_cnt].proc_id
    SET proc_study_list->proc[study_idx].step_id = proc_study_list->proc[study_cnt].step_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((study_pad/ c_block_size))),
     im_study_parent_r imspr,
     im_study ims,
     im_study_location imsl,
     im_device id
    PLAN (d
     WHERE d.seq > 0)
     JOIN (imspr
     WHERE expand(study_idx,(1+ ((d.seq - 1) * c_block_size)),(d.seq * c_block_size),imspr
      .parent_entity_id,proc_study_list->proc[study_idx].proc_id,
      c_block_size)
      AND imspr.parent_entity_name="CV_PROC")
     JOIN (ims
     WHERE ims.im_study_id=imspr.im_study_id)
     JOIN (imsl
     WHERE imsl.im_study_id=ims.im_study_id)
     JOIN (id
     WHERE id.im_device_id=imsl.im_device_id)
    ORDER BY ims.im_study_id
    HEAD REPORT
     stat = alterlist(reply->study,study_cnt)
    DETAIL
     study_idx = locateval(study_idx,(1+ ((d.seq - 1) * c_block_size)),(d.seq * c_block_size),imspr
      .parent_entity_id,proc_study_list->proc[study_idx].proc_id), reply->study[study_idx].siuid =
     trim(ims.study_uid,3), reply->study[study_idx].host_address = id.device_name
     IF ((reply->study[study_idx].host_address <= " "))
      reply->study[study_idx].host_address = id.ip_address
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(proc_study_list->proc,study_cnt)
 END ;Subroutine
 SUBROUTINE parseinterps(null)
   DECLARE study_number = i4 WITH noconstant(0)
   DECLARE not_found = vc WITH constant("<not_found>")
   DECLARE longtext = vc WITH noconstant("")
   DECLARE interp_line = vc WITH noconstant("")
   DECLARE interp_line_index = i4 WITH noconstant(0)
   DECLARE interp_line_length = i4 WITH noconstant(0)
   DECLARE last_sign_line_index = i4 WITH noconstant(0)
   DECLARE sign_line_pattern = vc WITH constant(concat("*",request->signline_start,"*"))
   DECLARE interp_line_first_char = c1 WITH noconstant("")
   FOR (study_number = 1 TO size(reply->study,5))
     SET interp_line_index = 1
     SET last_sign_line_index = 0
     SET reply->study[study_number].signature_line_flag = 0
     SET longtext = reply->study[study_number].interp_text
     IF (size(longtext,1) > 1)
      SET interp_line = piece(longtext,char(13),interp_line_index,not_found)
      WHILE (interp_line != not_found)
        SET interp_line_length = size(interp_line,1)
        SET interp_line_first_char = substring(1,1,interp_line)
        IF (interp_line_first_char=char(10))
         SET interp_line_length -= 1
         SET interp_line = substring(2,interp_line_length,interp_line)
        ENDIF
        IF (interp_line_index >= size(reply->study[study_number].interp_line,5))
         SET stat = alterlist(reply->study[study_number].interp_line,(interp_line_index+ 5))
        ENDIF
        SET reply->study[study_number].interp_line[interp_line_index].text = interp_line
        IF (interp_line=patstring(sign_line_pattern,0))
         SET last_sign_line_index = interp_line_index
        ENDIF
        SET interp_line_index += 1
        SET interp_line = piece(longtext,char(13),interp_line_index,not_found)
      ENDWHILE
     ENDIF
     SET interp_line_index -= 1
     IF (last_sign_line_index > 0)
      SET reply->study[study_number].signature_line_flag = 1
      SET stat = alterlist(reply->study[study_number].interp_line,last_sign_line_index)
     ELSE
      SET stat = alterlist(reply->study[study_number].interp_line,interp_line_index)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE getarchiveinformation(null)
   DECLARE archiveaddress = vc WITH noconstant("")
   DECLARE implementationuid = vc WITH noconstant("")
   DECLARE databaseprefix = vc WITH noconstant("")
   DECLARE username = vc WITH noconstant("")
   DECLARE password = vc WITH noconstant("")
   SELECT INTO "nl:"
    FROM im_configuration ic
    WHERE ic.parameter_name IN ("DICOM_IMPLEMENTATION_UID", "DATABASE_DICOM_PREFIX", "USERNAME",
    "PASSWORD")
    DETAIL
     CASE (ic.parameter_name)
      OF "DICOM_IMPLEMENTATION_UID":
       implementationuid = ic.value_char
      OF "DATABASE_DICOM_PREFIX":
       databaseprefix = ic.value_char
      OF "USERNAME":
       username = ic.value_char
      OF "PASSWORD":
       password = ic.value_char
     ENDCASE
    FOOT REPORT
     reply->dicom_prefix = concat(trim(implementationuid,3),".",trim(databaseprefix,3)), reply->
     archive_un = username, reply->archive_pw = password
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE callingechojson(null)
  SET reply->status_data.status = "S"
  CALL echojson(reply,request->file_name,0)
 END ;Subroutine
END GO
