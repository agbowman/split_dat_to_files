CREATE PROGRAM dcp_get_dtawizard_findinfo:dba
 RECORD reply(
   1 found_ind = i2
   1 dta_cnt = i4
   1 dta_qual[*]
     2 activity_type_cd = f8
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 description = vc
     2 display = vc
     2 default_type_flag = i2
     2 single_select_ind = i2
     2 version_number = f8
     2 template_script_cd = f8
     2 label_template_id = f8
     2 event_cd = f8
     2 result_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_reply(
   1 dta_qual[*]
     2 activity_type_cd = f8
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 description = vc
     2 display = vc
     2 default_type_flag = i2
     2 single_select_ind = i2
     2 version_number = f8
     2 active_ind = i4
     2 template_script_cd = f8
     2 label_template_id = f8
     2 event_cd = f8
     2 result_type_cd = f8
 )
 SET modify = predeclare
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE mnemonic = vc WITH protect, noconstant(cnvtupper(trim(request->description,3)))
 DECLARE expand_cnt = i4 WITH protect, noconstant(0)
 DECLARE start_index = i4 WITH protect, noconstant(request->start_index)
 DECLARE max_cnt = i4 WITH protect, noconstant((start_index+ 26))
 DECLARE rec_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE buffer = c20 WITH protect, noconstant(fillstring(20," "))
 SET i18nhandle = uar_i18nalphabet_init()
 CALL uar_i18nalphabet_highchar(i18nhandle,buffer,size(buffer))
 DECLARE highvalues = vc WITH protect, constant(cnvtupper(trim(buffer)))
 IF (textlen(mnemonic)=0)
  SET buffer = fillstring(20," ")
  CALL uar_i18nalphabet_lowchar(i18nhandle,buffer,size(buffer))
  SET mnemonic = cnvtupper(trim(buffer))
 ENDIF
 CALL uar_i18nalphabet_end(i18nhandle)
 SELECT INTO "nl:"
  FROM discrete_task_assay dta
  WHERE dta.mnemonic_key_cap BETWEEN mnemonic AND highvalues
   AND dta.active_ind=1
  ORDER BY dta.mnemonic_key_cap
  DETAIL
   rec_cnt += 1
   IF (rec_cnt > start_index)
    count1 += 1
    IF (mod(count1,10)=1)
     stat = alterlist(temp_reply->dta_qual,(count1+ 9))
    ENDIF
    temp_reply->dta_qual[count1].description = trim(dta.description), temp_reply->dta_qual[count1].
    activity_type_cd = dta.activity_type_cd, temp_reply->dta_qual[count1].task_assay_cd = dta
    .task_assay_cd,
    temp_reply->dta_qual[count1].mnemonic = dta.mnemonic, temp_reply->dta_qual[count1].
    default_type_flag = dta.default_type_flag, temp_reply->dta_qual[count1].single_select_ind = dta
    .single_select_ind,
    temp_reply->dta_qual[count1].version_number = dta.version_number, temp_reply->dta_qual[count1].
    template_script_cd = validate(dta.template_script_cd,0.0), temp_reply->dta_qual[count1].
    label_template_id = dta.label_template_id,
    temp_reply->dta_qual[count1].event_cd = dta.event_cd, temp_reply->dta_qual[count1].result_type_cd
     = dta.default_result_type_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_reply->dta_qual,count1)
  WITH maxrec = value(max_cnt)
 ;end select
 IF (count1=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE expand(expand_cnt,1,count1,cv.code_value,temp_reply->dta_qual[expand_cnt].activity_type_cd)
   AND ((cv.code_set+ 0)=106)
  ORDER BY cv.code_value
  HEAD REPORT
   cnt = 0, pos = 0
  HEAD cv.code_value
   pos = locateval(pos,1,count1,cv.code_value,temp_reply->dta_qual[pos].activity_type_cd)
   WHILE (pos != 0)
     cnt += 1, temp_reply->dta_qual[pos].display = cv.display, temp_reply->dta_qual[pos].active_ind
      = 1,
     pos = locateval(pos,(pos+ 1),count1,cv.code_value,temp_reply->dta_qual[pos].activity_type_cd)
   ENDWHILE
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->dta_qual,count1)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = count1)
  WHERE (temp_reply->dta_qual[d.seq].active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1, reply->dta_qual[cnt].description = temp_reply->dta_qual[d.seq].description, reply->
   dta_qual[cnt].activity_type_cd = temp_reply->dta_qual[d.seq].activity_type_cd,
   reply->dta_qual[cnt].task_assay_cd = temp_reply->dta_qual[d.seq].task_assay_cd, reply->dta_qual[
   cnt].mnemonic = temp_reply->dta_qual[d.seq].mnemonic, reply->dta_qual[cnt].default_type_flag =
   temp_reply->dta_qual[d.seq].default_type_flag,
   reply->dta_qual[cnt].single_select_ind = temp_reply->dta_qual[d.seq].single_select_ind, reply->
   dta_qual[cnt].version_number = temp_reply->dta_qual[d.seq].version_number, reply->dta_qual[cnt].
   display = temp_reply->dta_qual[d.seq].display,
   reply->dta_qual[cnt].template_script_cd = temp_reply->dta_qual[d.seq].template_script_cd, reply->
   dta_qual[cnt].label_template_id = temp_reply->dta_qual[d.seq].label_template_id, reply->dta_qual[
   cnt].event_cd = temp_reply->dta_qual[d.seq].event_cd,
   reply->dta_qual[cnt].result_type_cd = temp_reply->dta_qual[d.seq].result_type_cd
  FOOT REPORT
   stat = alterlist(reply->dta_qual,cnt), reply->dta_cnt = cnt, reply->found_ind = 1
  WITH nocounter
 ;end select
#exit_script
 IF ((reply->found_ind=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD temp_reply
END GO
