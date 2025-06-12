CREATE PROGRAM dcp_get_pl_pat_demog:dba
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 person_id = f8
      2 encntr_id = f8
      2 name_full_formatted = vc
      2 gender_cd = f8
      2 gender_disp = c40
      2 birthdate = dq8
      2 age = c12
      2 vip_cd = f8
      2 confid_cd = f8
      2 confid_disp = c40
      2 mrn = vc
      2 reg_dt_tm = dq8
      2 bed_location_cd = f8
      2 bed_location_disp = c40
      2 bed_collation_seq = i4
      2 room_location_cd = f8
      2 room_location_disp = c40
      2 room_collation_seq = i4
      2 unit_location_cd = f8
      2 unit_location_disp = c40
      2 unit_collation_seq = i4
      2 building_location_cd = f8
      2 building_location_disp = c40
      2 building_collation_seq = i4
      2 facility_location_cd = f8
      2 facility_location_disp = c40
      2 facility_collation_seq = i4
      2 temp_location_cd = f8
      2 temp_location_disp = c40
      2 service_cd = f8
      2 service_disp = c40
      2 leave_ind = i2
      2 visit_reason = vc
      2 fin_nbr = vc
      2 los = vc
      2 encntr_type = f8
      2 encntr_type_disp = vc
      2 sticky_notes_ind = i2
      2 discharge_date = dq8
      2 end_effective_dt_tm = dq8
      2 visitor_status_cd = f8
      2 visitor_status_disp = c40
      2 time_zone_indx = i4
      2 birth_tz = i4
      2 est_discharge_date = dq8
      2 encntr_type_new_cd = f8
      2 encntr_type_new_disp = vc
      2 deceased_date = dq8
      2 deceased_tz = i4
      2 inpatient_admit_dt_tm = dq8
      2 est_arrive_dt_tm = dq8
      2 arrive_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD reqtemp(
   1 person_cnt = i4
   1 person_list[*]
     2 person_id = f8
   1 encntr_cnt = i4
   1 encntr_list[*]
     2 encntr_id = f8
     2 person_id = f8
 )
 RECORD temp(
   1 patient_cnt = i4
   1 patients[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 gender_cd = f8
     2 gender_disp = c40
     2 birthdate = dq8
     2 birth_tz = i4
     2 age = c12
     2 vip_cd = f8
     2 confid_cd = f8
     2 sticky_notes_ind = i2
     2 mrn = vc
     2 deceased_date = dq8
     2 deceased_tz = i4
   1 encntr_cnt = i4
   1 time_header = vc
   1 encntrs[*]
     2 encntr_id = f8
     2 person_idx = i4
     2 confid_cd = f8
     2 mrn = vc
     2 reg_dt_tm = dq8
     2 bed_location_cd = f8
     2 bed_sequence = i4
     2 room_location_cd = f8
     2 room_sequence = i4
     2 unit_location_cd = f8
     2 unit_sequence = i4
     2 building_location_cd = f8
     2 building_sequence = i4
     2 facility_location_cd = f8
     2 temp_location_cd = f8
     2 service_cd = f8
     2 leave_ind = i2
     2 visit_reason = vc
     2 fin_nbr = vc
     2 los = vc
     2 encntr_type = f8
     2 sticky_notes_ind = i2
     2 discharge_date = dq8
     2 end_effective_dt_tm = dq8
     2 visitor_status_cd = f8
     2 visitor_status_disp = c40
     2 time_zone_indx = i4
     2 est_discharge_date = dq8
     2 encntr_type_new_cd = f8
     2 encntr_type_new_disp = vc
     2 inpatient_admit_dt_tm = dq8
     2 est_arrive_dt_tm = dq8
     2 arrive_dt_tm = dq8
 )
 RECORD encntrloctzreq(
   1 encntrs[*]
     2 encntr_id = f8
   1 facilities[*]
     2 loc_facility_cd = f8
 )
 RECORD encntrloctzrep(
   1 encntrs_qual_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
     2 time_zone_indx = i4
     2 time_zone = vc
     2 status = i2
   1 facilities_qual_cnt = i4
   1 facilities[*]
     2 loc_facility_cd = f8
     2 time_zone_indx = i4
     2 time_zone = vc
     2 status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE sz = i4 WITH noconstant(size(request->persons,5))
 DECLARE patient_cnt = i4 WITH noconstant(0)
 DECLARE cs = i4 WITH noconstant(71)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE preprocessrequest(null) = null
 DECLARE eliminateduplicatepatients(null) = null
 DECLARE loadpatientinfo(null) = null
 DECLARE loadpersonalias(null) = null
 DECLARE loadstickynotes(null) = null
 DECLARE loadencntrinfo(null) = null
 DECLARE loadencntraliases(null) = null
 DECLARE loadencntrleave(null) = null
 DECLARE loadencntrtz(null) = null
 DECLARE populatereply(null) = i4
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "Z"
 IF (sz > 0)
  SELECT INTO "nl:"
   FROM app_prefs a,
    name_value_prefs n
   PLAN (a
    WHERE (a.application_number=reqinfo->updt_app)
     AND a.position_cd=0
     AND a.prsnl_id=0)
    JOIN (n
    WHERE n.parent_entity_id=a.app_prefs_id
     AND n.parent_entity_name="APP_PREFS"
     AND n.pvc_name="ENCNTR_CODESET")
   DETAIL
    IF (n.pvc_value="*69*")
     cs = 69
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL preprocessrequest(null)
 IF ((reqtemp->encntr_cnt > 0))
  CALL loadencntrinfo(null)
  CALL eliminateduplicatepatients(null)
  CALL initializesequences(null)
  CALL loadbedsequence(null)
  CALL loadroomsequence(null)
  CALL loadunitsequence(null)
  CALL loadbuildingsequence(null)
 ENDIF
 IF ((reqtemp->person_cnt > 0))
  CALL loadpatientinfo(null)
 ENDIF
 CALL loadpersonalias(null)
 CALL loadstickynotes(null)
 IF ((reply->status_data.status != "F"))
  CALL populatereply(null)
 ENDIF
 FREE RECORD temp
 FREE RECORD reqtemp
 FREE RECORD encntrloctzrep
 FREE RECORD encntrloctzreq
 SET modify = nopredeclare
 SUBROUTINE loadpatientinfo(null)
   DECLARE new_list_size = i4
   DECLARE cur_list_size = i4
   DECLARE batch_size = i4 WITH constant(40)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE nstart = i4
   DECLARE loop_cnt = i4
   SET cur_list_size = reqtemp->person_cnt
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(reqtemp->person_list,new_list_size)
   SET nstart = 1
   FOR (idx = (cur_list_size+ 1) TO new_list_size)
     SET reqtemp->person_list[idx].person_id = reqtemp->person_list[cur_list_size].person_id
   ENDFOR
   SELECT INTO "nl:"
    nulld = nullind(p.deceased_dt_tm)
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     person p
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (p
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),p.person_id,reqtemp->person_list[idx].
      person_id)
      AND p.active_ind=1)
    ORDER BY p.person_id
    HEAD p.person_id
     temp->patient_cnt += 1, temp->patients[temp->patient_cnt].person_id = p.person_id, temp->
     patients[temp->patient_cnt].name_full_formatted = p.name_full_formatted,
     temp->patients[temp->patient_cnt].gender_cd = p.sex_cd, temp->patients[temp->patient_cnt].
     birthdate = p.birth_dt_tm, temp->patients[temp->patient_cnt].birth_tz = validate(p.birth_tz,0),
     temp->patients[temp->patient_cnt].mrn = " ", temp->patients[temp->patient_cnt].deceased_date = p
     .deceased_dt_tm, temp->patients[temp->patient_cnt].deceased_tz = validate(p.deceased_tz,0)
     IF (nulld=0)
      temp->patients[temp->patient_cnt].age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),
        "mm/dd/yyyy"),cnvtint(format(p.birth_dt_tm,"hhmm;;m")),cnvtdate2(format(p.deceased_dt_tm,
         "mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(p.deceased_dt_tm,"hhmm;;m")))
     ELSE
      temp->patients[temp->patient_cnt].age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),
        "mm/dd/yyyy"),cnvtint(format(p.birth_dt_tm,"hhmm;;m")))
     ENDIF
     temp->patients[temp->patient_cnt].vip_cd = p.vip_cd, temp->patients[temp->patient_cnt].confid_cd
      = p.confid_level_cd
    FOOT REPORT
     stat = alterlist(temp->patients,temp->patient_cnt), stat = alterlist(reqtemp->person_list,
      reqtemp->person_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE eliminateduplicatepatients(null)
   DECLARE i = i4 WITH noconstant(0), private
   DECLARE idx = i4 WITH noconstant(0), private
   DECLARE p_cnt = i4 WITH noconstant(0), private
   FOR (i = 1 TO reqtemp->person_cnt)
    SET idx = findpersonindex(reqtemp->person_list[i].person_id)
    IF (idx <= 0)
     SET p_cnt += 1
     SET reqtemp->person_list[p_cnt].person_id = reqtemp->person_list[i].person_id
    ENDIF
   ENDFOR
   SET reqtemp->person_cnt = p_cnt
 END ;Subroutine
 SUBROUTINE loadencntrinfo(null)
   DECLARE new_list_size = i4
   DECLARE cur_list_size = i4
   DECLARE batch_size = i4 WITH constant(40)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE nstart = i4
   DECLARE loop_cnt = i4
   SET cur_list_size = reqtemp->encntr_cnt
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(reqtemp->encntr_list,new_list_size)
   SET nstart = 1
   FOR (idx = (cur_list_size+ 1) TO new_list_size)
     SET reqtemp->encntr_list[idx].encntr_id = reqtemp->encntr_list[cur_list_size].encntr_id
   ENDFOR
   SELECT INTO "nl:"
    nulld = nullind(p.deceased_dt_tm)
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     encounter e,
     person p
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (e
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),e.encntr_id,reqtemp->encntr_list[idx].
      encntr_id))
     JOIN (p
     WHERE p.person_id=e.person_id)
    ORDER BY p.person_id, e.encntr_id
    HEAD p.person_id
     temp->patient_cnt += 1, temp->patients[temp->patient_cnt].person_id = p.person_id, temp->
     patients[temp->patient_cnt].name_full_formatted = p.name_full_formatted,
     temp->patients[temp->patient_cnt].gender_cd = p.sex_cd, temp->patients[temp->patient_cnt].
     birthdate = p.birth_dt_tm, temp->patients[temp->patient_cnt].birth_tz = validate(p.birth_tz,0),
     temp->patients[temp->patient_cnt].vip_cd = p.vip_cd, temp->patients[temp->patient_cnt].confid_cd
      = p.confid_level_cd, temp->patients[temp->patient_cnt].mrn = " ",
     temp->patients[temp->patient_cnt].deceased_date = p.deceased_dt_tm, temp->patients[temp->
     patient_cnt].deceased_tz = validate(p.deceased_tz,0)
     IF (nulld=0)
      temp->patients[temp->patient_cnt].age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),
        "mm/dd/yyyy"),cnvtint(format(p.birth_dt_tm,"hhmm;;m")),cnvtdate2(format(p.deceased_dt_tm,
         "mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(p.deceased_dt_tm,"hhmm;;m")))
     ELSE
      temp->patients[temp->patient_cnt].age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),
        "mm/dd/yyyy"),cnvtint(format(p.birth_dt_tm,"hhmm;;m")))
     ENDIF
    HEAD e.encntr_id
     temp->encntr_cnt += 1, temp->encntrs[temp->encntr_cnt].person_idx = temp->patient_cnt, temp->
     encntrs[temp->encntr_cnt].discharge_date = e.disch_dt_tm,
     temp->encntrs[temp->encntr_cnt].est_discharge_date = e.est_depart_dt_tm, temp->encntrs[temp->
     encntr_cnt].end_effective_dt_tm = e.end_effective_dt_tm, temp->encntrs[temp->encntr_cnt].
     encntr_id = e.encntr_id,
     temp->encntrs[temp->encntr_cnt].confid_cd = e.confid_level_cd, temp->encntrs[temp->encntr_cnt].
     reg_dt_tm = e.reg_dt_tm, temp->encntrs[temp->encntr_cnt].inpatient_admit_dt_tm = e
     .inpatient_admit_dt_tm,
     temp->encntrs[temp->encntr_cnt].bed_location_cd = e.loc_bed_cd, temp->encntrs[temp->encntr_cnt].
     room_location_cd = e.loc_room_cd, temp->encntrs[temp->encntr_cnt].unit_location_cd = e
     .loc_nurse_unit_cd,
     temp->encntrs[temp->encntr_cnt].building_location_cd = e.loc_building_cd, temp->encntrs[temp->
     encntr_cnt].facility_location_cd = e.loc_facility_cd, temp->encntrs[temp->encntr_cnt].
     temp_location_cd = e.loc_temp_cd,
     temp->encntrs[temp->encntr_cnt].service_cd = e.med_service_cd, temp->encntrs[temp->encntr_cnt].
     visit_reason = e.reason_for_visit, temp->encntrs[temp->encntr_cnt].leave_ind = 0,
     temp->encntrs[temp->encntr_cnt].visitor_status_cd = e.visitor_status_cd, temp->encntrs[temp->
     encntr_cnt].mrn = " "
     IF (validate(temp->encntrs[temp->encntr_cnt].est_arrive_dt_tm) > 0)
      temp->encntrs[temp->encntr_cnt].est_arrive_dt_tm = e.est_arrive_dt_tm
     ENDIF
     IF (validate(temp->encntrs[temp->encntr_cnt].arrive_dt_tm) > 0)
      temp->encntrs[temp->encntr_cnt].arrive_dt_tm = e.arrive_dt_tm
     ENDIF
     temp->time_header = uar_i18ngetmessage(i18nhandle,"time_header_key","Days")
     IF (cs=71)
      temp->encntrs[temp->encntr_cnt].encntr_type = e.encntr_type_cd, temp->encntrs[temp->encntr_cnt]
      .encntr_type_new_cd = e.encntr_type_cd
     ELSE
      temp->encntrs[temp->encntr_cnt].encntr_type = e.encntr_type_class_cd, temp->encntrs[temp->
      encntr_cnt].encntr_type_new_cd = e.encntr_type_class_cd
     ENDIF
     IF (e.inpatient_admit_dt_tm > 0)
      los_beg_dt_tm = e.inpatient_admit_dt_tm
     ELSE
      los_beg_dt_tm = e.reg_dt_tm
     ENDIF
     IF (los_beg_dt_tm > 0)
      IF (e.disch_dt_tm > 0)
       tempday = datetimediff(e.disch_dt_tm,los_beg_dt_tm)
      ELSE
       tempday = datetimediff(cnvtdatetime(sysdate),los_beg_dt_tm)
      ENDIF
      IF (tempday < 0)
       temp->encntrs[temp->encntr_cnt].los = " "
      ELSE
       temp->encntrs[temp->encntr_cnt].los = concat(format(tempday,"#####.#;I")," ",temp->time_header
        )
      ENDIF
     ELSE
      temp->encntrs[temp->encntr_cnt].los = " "
     ENDIF
    FOOT REPORT
     stat = alterlist(temp->encntrs,temp->encntr_cnt), stat = alterlist(reqtemp->encntr_list,reqtemp
      ->encntr_cnt)
    WITH nocounter
   ;end select
   IF (cur_list_size > 0)
    CALL loadencntraliases(null)
    CALL loadencntrleave(null)
    IF (curutc)
     CALL loadencntrtz(null)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE initializesequences(null)
   FOR (i = 1 TO temp->encntr_cnt)
     SET temp->encntrs[i].bed_sequence = - (1)
     SET temp->encntrs[i].room_sequence = - (1)
     SET temp->encntrs[i].unit_sequence = - (1)
     SET temp->encntrs[i].building_sequence = - (1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE loadbedsequence(null)
   DECLARE encntr_size = i4 WITH protect, noconstant(0)
   SET encntr_size = size(temp->encntrs,5)
   IF (encntr_size > 0)
    DECLARE expand_size = i4 WITH constant(40)
    DECLARE loop_cnt = i4 WITH constant(ceil((cnvtreal(encntr_size)/ expand_size)))
    DECLARE expand_total = i4 WITH constant((loop_cnt * expand_size))
    DECLARE expand_start = i4 WITH noconstant(1)
    DECLARE idx = i4 WITH noconstant(0)
    DECLARE num = i4 WITH noconstant(0), public
    DECLARE start = i4 WITH noconstant(1), public
    SET stat = alterlist(temp->encntrs,expand_total)
    FOR (idx = (encntr_size+ 1) TO expand_total)
     SET temp->encntrs[idx].bed_location_cd = 0
     SET temp->encntrs[idx].room_location_cd = 0
    ENDFOR
    SELECT INTO "nl:"
     FROM location_group lg,
      (dummyt d  WITH seq = value(loop_cnt))
     PLAN (d
      WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
      JOIN (lg
      WHERE expand(idx,expand_start,(expand_start+ (expand_size - 1)),lg.child_loc_cd,temp->encntrs[
       idx].bed_location_cd,
       lg.parent_loc_cd,temp->encntrs[idx].room_location_cd)
       AND lg.root_loc_cd=0
       AND lg.active_ind=1)
     HEAD REPORT
      num = 0
     DETAIL
      pos = locateval(num,start,size(temp->encntrs,5),lg.child_loc_cd,temp->encntrs[num].
       bed_location_cd,
       lg.parent_loc_cd,temp->encntrs[num].room_location_cd)
      WHILE (pos != 0)
       temp->encntrs[pos].bed_sequence = lg.sequence,pos = locateval(num,(pos+ 1),size(temp->encntrs,
         5),lg.child_loc_cd,temp->encntrs[num].bed_location_cd,
        lg.parent_loc_cd,temp->encntrs[num].room_location_cd)
      ENDWHILE
     FOOT REPORT
      stat = alterlist(temp->encntrs,encntr_size)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE loadroomsequence(null)
   DECLARE encntr_size = i4 WITH protect, noconstant(0)
   SET encntr_size = size(temp->encntrs,5)
   IF (encntr_size > 0)
    DECLARE expand_size = i4 WITH constant(40)
    DECLARE loop_cnt = i4 WITH constant(ceil((cnvtreal(encntr_size)/ expand_size)))
    DECLARE expand_total = i4 WITH constant((loop_cnt * expand_size))
    DECLARE expand_start = i4 WITH noconstant(1)
    DECLARE idx = i4 WITH noconstant(0)
    DECLARE num = i4 WITH noconstant(0), public
    DECLARE start = i4 WITH noconstant(1), public
    SET stat = alterlist(temp->encntrs,expand_total)
    FOR (idx = (encntr_size+ 1) TO expand_total)
     SET temp->encntrs[idx].room_location_cd = 0
     SET temp->encntrs[idx].unit_location_cd = 0
    ENDFOR
    SELECT INTO "nl:"
     FROM location_group lg,
      (dummyt d  WITH seq = value(loop_cnt))
     PLAN (d
      WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
      JOIN (lg
      WHERE expand(idx,expand_start,(expand_start+ (expand_size - 1)),lg.child_loc_cd,temp->encntrs[
       idx].room_location_cd,
       lg.parent_loc_cd,temp->encntrs[idx].unit_location_cd)
       AND lg.root_loc_cd=0
       AND lg.active_ind=1)
     HEAD REPORT
      num = 0
     DETAIL
      pos = locateval(num,start,size(temp->encntrs,5),lg.child_loc_cd,temp->encntrs[num].
       room_location_cd,
       lg.parent_loc_cd,temp->encntrs[num].unit_location_cd)
      WHILE (pos != 0)
       temp->encntrs[pos].room_sequence = lg.sequence,pos = locateval(num,(pos+ 1),size(temp->encntrs,
         5),lg.child_loc_cd,temp->encntrs[num].room_location_cd,
        lg.parent_loc_cd,temp->encntrs[num].unit_location_cd)
      ENDWHILE
     FOOT REPORT
      stat = alterlist(temp->encntrs,encntr_size)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE loadunitsequence(null)
   DECLARE encntr_size = i4 WITH protect, noconstant(0)
   SET encntr_size = size(temp->encntrs,5)
   IF (encntr_size > 0)
    DECLARE expand_size = i4 WITH constant(40)
    DECLARE loop_cnt = i4 WITH constant(ceil((cnvtreal(encntr_size)/ expand_size)))
    DECLARE expand_total = i4 WITH constant((loop_cnt * expand_size))
    DECLARE expand_start = i4 WITH noconstant(1)
    DECLARE idx = i4 WITH noconstant(0)
    DECLARE num = i4 WITH noconstant(0), public
    DECLARE start = i4 WITH noconstant(1), public
    SET stat = alterlist(temp->encntrs,expand_total)
    FOR (idx = (encntr_size+ 1) TO expand_total)
     SET temp->encntrs[idx].unit_location_cd = 0
     SET temp->encntrs[idx].building_location_cd = 0
    ENDFOR
    SELECT INTO "nl:"
     FROM location_group lg,
      (dummyt d  WITH seq = value(loop_cnt))
     PLAN (d
      WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
      JOIN (lg
      WHERE expand(idx,expand_start,(expand_start+ (expand_size - 1)),lg.child_loc_cd,temp->encntrs[
       idx].unit_location_cd,
       lg.parent_loc_cd,temp->encntrs[idx].building_location_cd)
       AND lg.root_loc_cd=0
       AND lg.active_ind=1)
     HEAD REPORT
      num = 0
     DETAIL
      pos = locateval(num,start,size(temp->encntrs,5),lg.child_loc_cd,temp->encntrs[num].
       unit_location_cd,
       lg.parent_loc_cd,temp->encntrs[num].building_location_cd)
      WHILE (pos != 0)
       temp->encntrs[pos].unit_sequence = lg.sequence,pos = locateval(num,(pos+ 1),size(temp->encntrs,
         5),lg.child_loc_cd,temp->encntrs[num].unit_location_cd,
        lg.parent_loc_cd,temp->encntrs[num].building_location_cd)
      ENDWHILE
     FOOT REPORT
      stat = alterlist(temp->encntrs,encntr_size)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE loadbuildingsequence(null)
   DECLARE encntr_size = i4 WITH protect, noconstant(0)
   SET encntr_size = size(temp->encntrs,5)
   IF (encntr_size > 0)
    DECLARE expand_size = i4 WITH constant(40)
    DECLARE loop_cnt = i4 WITH constant(ceil((cnvtreal(encntr_size)/ expand_size)))
    DECLARE expand_total = i4 WITH constant((loop_cnt * expand_size))
    DECLARE expand_start = i4 WITH noconstant(1)
    DECLARE idx = i4 WITH noconstant(0)
    DECLARE num = i4 WITH noconstant(0), public
    DECLARE start = i4 WITH noconstant(1), public
    SET stat = alterlist(temp->encntrs,expand_total)
    FOR (idx = (encntr_size+ 1) TO expand_total)
     SET temp->encntrs[idx].building_location_cd = 0
     SET temp->encntrs[idx].facility_location_cd = 0
    ENDFOR
    SELECT INTO "nl:"
     FROM location_group lg,
      (dummyt d  WITH seq = value(loop_cnt))
     PLAN (d
      WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
      JOIN (lg
      WHERE expand(idx,expand_start,(expand_start+ (expand_size - 1)),lg.child_loc_cd,temp->encntrs[
       idx].building_location_cd,
       lg.parent_loc_cd,temp->encntrs[idx].facility_location_cd)
       AND lg.root_loc_cd=0
       AND lg.active_ind=1)
     HEAD REPORT
      num = 0, b = 0
     DETAIL
      pos = locateval(num,start,size(temp->encntrs,5),lg.child_loc_cd,temp->encntrs[num].
       building_location_cd,
       lg.parent_loc_cd,temp->encntrs[num].facility_location_cd)
      WHILE (pos != 0)
       temp->encntrs[pos].building_sequence = lg.sequence,pos = locateval(num,(pos+ 1),size(temp->
         encntrs,5),lg.child_loc_cd,temp->encntrs[num].building_location_cd,
        lg.parent_loc_cd,temp->encntrs[num].facility_location_cd)
      ENDWHILE
     FOOT REPORT
      stat = alterlist(temp->encntrs,encntr_size)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE loadencntrtz(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   DECLARE found = i4 WITH noconstant(0)
   DECLARE facility_cnt = i4 WITH noconstant(0)
   DECLARE rep_size = i4 WITH noconstant(0)
   SET stat = alterlist(encntrloctzreq->facilities,temp->encntr_cnt)
   FOR (i = 1 TO temp->encntr_cnt)
     SET found = 0
     FOR (j = 1 TO facility_cnt)
       IF ((temp->encntrs[i].facility_location_cd=encntrloctzreq->facilities[j].loc_facility_cd))
        SET found = 1
        SET j = (facility_cnt+ 1)
       ENDIF
     ENDFOR
     IF (found=0)
      SET facility_cnt += 1
      SET encntrloctzreq->facilities[facility_cnt].loc_facility_cd = temp->encntrs[i].
      facility_location_cd
     ENDIF
   ENDFOR
   IF (facility_cnt > 0)
    EXECUTE pm_get_encntr_loc_tz  WITH replace("REQUEST",encntrloctzreq), replace("REPLY",
     encntrloctzrep)
    IF ((encntrloctzrep->status_data.status="F"))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = encntrloctzrep->status_data.
     subeventstatus[1].targetobjectvalue
    ELSE
     SET rep_size = size(encntrloctzrep->facilities,5)
     FOR (i = 1 TO rep_size)
       FOR (j = 1 TO temp->encntr_cnt)
         IF ((encntrloctzrep->facilities[i].loc_facility_cd=temp->encntrs[j].facility_location_cd))
          SET temp->encntrs[j].time_zone_indx = encntrloctzrep->facilities[i].time_zone_indx
         ENDIF
       ENDFOR
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE loadencntraliases(null)
   DECLARE z = i4 WITH noconstant(0)
   DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN"))
   DECLARE fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
   DECLARE encntr_size = i4 WITH protect, noconstant(0)
   SET encntr_size = reqtemp->encntr_cnt
   DECLARE expand_size = i4 WITH constant(40)
   DECLARE loop_count = i4 WITH constant(ceil((cnvtreal(encntr_size)/ expand_size)))
   DECLARE expand_start = i4 WITH noconstant(1)
   DECLARE encntr_list_size = i4 WITH constant((loop_count * expand_size))
   SET stat = alterlist(reqtemp->encntr_list,encntr_list_size)
   DECLARE val = i4 WITH noconstant(0)
   FOR (val = (encntr_size+ 1) TO encntr_list_size)
     SET reqtemp->encntr_list[val].encntr_id = reqtemp->encntr_list[encntr_size].encntr_id
   ENDFOR
   SELECT INTO "nl:"
    FROM encntr_alias ea,
     (dummyt d  WITH seq = value(loop_count))
    PLAN (d
     WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
     JOIN (ea
     WHERE expand(z,expand_start,(expand_start+ (expand_size - 1)),ea.encntr_id,reqtemp->encntr_list[
      z].encntr_id)
      AND ea.encntr_alias_type_cd IN (mrn_cd, fin_cd)
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
    ORDER BY ea.encntr_id
    HEAD ea.encntr_id
     idx = findencntrindex(ea.encntr_id)
    DETAIL
     IF (idx > 0)
      IF (ea.encntr_alias_type_cd=mrn_cd)
       temp->encntrs[idx].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
      ELSEIF (ea.encntr_alias_type_cd=fin_cd)
       temp->encntrs[idx].fin_nbr = cnvtalias(ea.alias,ea.alias_pool_cd)
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(reqtemp->encntr_list,reqtemp->encntr_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadencntrleave(null)
   DECLARE z = i4 WITH noconstant(0)
   DECLARE encntr_size = i4 WITH protect, noconstant(0)
   SET encntr_size = reqtemp->encntr_cnt
   DECLARE expand_size = i4 WITH constant(40)
   DECLARE loop_count = i4 WITH constant(ceil((cnvtreal(encntr_size)/ expand_size)))
   DECLARE expand_start = i4 WITH noconstant(1)
   DECLARE encntr_list_size = i4 WITH constant((loop_count * expand_size))
   SET stat = alterlist(reqtemp->encntr_list,encntr_list_size)
   DECLARE val = i4 WITH noconstant(0)
   FOR (val = (encntr_size+ 1) TO encntr_list_size)
     SET reqtemp->encntr_list[val].encntr_id = reqtemp->encntr_list[encntr_size].encntr_id
   ENDFOR
   SELECT INTO "nl:"
    FROM encntr_leave el,
     (dummyt d  WITH seq = value(loop_count))
    PLAN (d
     WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
     JOIN (el
     WHERE expand(z,expand_start,(expand_start+ (expand_size - 1)),el.encntr_id,reqtemp->encntr_list[
      z].encntr_id)
      AND el.active_ind=1)
    DETAIL
     idx = findencntrindex(el.encntr_id)
     IF (idx > 0)
      temp->encntrs[idx].leave_ind = el.leave_ind
     ENDIF
    FOOT REPORT
     stat = alterlist(reqtemp->encntr_list,reqtemp->encntr_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadstickynotes(null)
   DECLARE y = i4 WITH noconstant(0)
   DECLARE powerchart_cd = f8 WITH constant(uar_get_code_by("MEANING",14122,"POWERCHART"))
   DECLARE person_size = i4 WITH protect, noconstant(0)
   SET person_size = temp->patient_cnt
   DECLARE expand_size = i4 WITH constant(40)
   DECLARE loop_cnt = i4 WITH constant(ceil((cnvtreal(person_size)/ expand_size)))
   DECLARE expand_start = i4 WITH noconstant(1)
   DECLARE new_list_size = i4 WITH constant((loop_cnt * expand_size))
   SET stat = alterlist(temp->patients,new_list_size)
   SELECT INTO "nl:"
    FROM sticky_note sn,
     (dummyt d  WITH seq = value(loop_cnt))
    PLAN (d
     WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
     JOIN (sn
     WHERE expand(y,expand_start,(expand_start+ (expand_size - 1)),sn.parent_entity_id,temp->
      patients[y].person_id)
      AND sn.parent_entity_name="PERSON"
      AND sn.sticky_note_type_cd=powerchart_cd)
    ORDER BY sn.parent_entity_id
    HEAD sn.parent_entity_id
     idx = findpersonindex(sn.parent_entity_id)
     IF (idx > 0)
      temp->patients[idx].sticky_notes_ind = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(temp->patients,temp->patient_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE preprocessrequest(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   SET stat = alterlist(reqtemp->encntr_list,sz)
   SET stat = alterlist(reqtemp->person_list,sz)
   SET stat = alterlist(temp->patients,sz)
   SET stat = alterlist(temp->encntrs,sz)
   SET reqtemp->person_cnt = 0
   SET reqtemp->encntr_cnt = 0
   FOR (i = 1 TO sz)
     SET reqtemp->person_cnt += 1
     SET reqtemp->person_list[reqtemp->person_cnt].person_id = request->persons[i].person_id
     IF ((request->persons[i].encntr_id > 0.0))
      SET reqtemp->encntr_cnt += 1
      SET reqtemp->encntr_list[reqtemp->encntr_cnt].encntr_id = request->persons[i].encntr_id
      SET reqtemp->encntr_list[reqtemp->encntr_cnt].person_id = request->persons[i].person_id
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE loadpersonalias(null)
   DECLARE alias_cnt = i4 WITH noconstant(0)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN"))
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE expand_size = i4 WITH constant(40)
   DECLARE expand_start = i4 WITH noconstant(1)
   DECLARE new_list_size = i4
   RECORD aliastemp(
     1 persons[*]
       2 person_id = f8
   )
   SET stat = alterlist(aliastemp->persons,temp->patient_cnt)
   FOR (x = 1 TO sz)
     SET idx = - (1)
     IF ((request->persons[x].encntr_id > 0))
      SET idx = findencntrindex(request->persons[x].encntr_id)
     ENDIF
     IF (((idx <= 0) OR (trim(temp->encntrs[idx].mrn)=null)) )
      SET idx = findpersonindex(request->persons[x].person_id)
      IF (idx > 0)
       SET alias_cnt += 1
       SET aliastemp->persons[alias_cnt].person_id = request->persons[x].person_id
      ENDIF
     ENDIF
   ENDFOR
   DECLARE loop_cnt = i4 WITH constant(ceil((cnvtreal(alias_cnt)/ expand_size)))
   SET new_list_size = (loop_cnt * expand_size)
   SET stat = alterlist(aliastemp->persons,new_list_size)
   DECLARE val = i4 WITH noconstant(0)
   FOR (val = (alias_cnt+ 1) TO new_list_size)
     SET aliastemp->persons[val].person_id = aliastemp->persons[alias_cnt].person_id
   ENDFOR
   IF (alias_cnt > 0)
    SELECT INTO "nl:"
     FROM person_alias pa,
      (dummyt d  WITH seq = value(loop_cnt))
     PLAN (d
      WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
      JOIN (pa
      WHERE expand(x,expand_start,(expand_start+ (expand_size - 1)),pa.person_id,aliastemp->persons[x
       ].person_id)
       AND pa.person_alias_type_cd=mrn_cd
       AND pa.active_ind=1)
     DETAIL
      idx = findpersonindex(pa.person_id)
      IF (idx > 0)
       temp->patients[idx].mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   FREE RECORD aliastemp
 END ;Subroutine
 SUBROUTINE (findencntrindex(encntr=f8) =i4)
   DECLARE num = i4 WITH noconstant(0), public
   DECLARE start = i4 WITH noconstant(1), public
   DECLARE pos = i4 WITH noconstant(0)
   SET pos = locateval(num,start,temp->encntr_cnt,encntr,temp->encntrs[num].encntr_id)
   IF (pos <= 0)
    RETURN(- (1))
   ELSE
    RETURN(pos)
   ENDIF
 END ;Subroutine
 SUBROUTINE (findpersonindex(person=f8) =i4)
   DECLARE num = i4 WITH noconstant(0), public
   DECLARE start = i4 WITH noconstant(1), public
   DECLARE pos = i4 WITH noconstant(0)
   SET pos = locateval(num,start,temp->patient_cnt,person,temp->patients[num].person_id)
   IF (pos <= 0)
    RETURN(- (1))
   ELSE
    RETURN(pos)
   ENDIF
 END ;Subroutine
 SUBROUTINE populatereply(null)
   DECLARE i = i4 WITH noconstant(0), private
   DECLARE j = i4 WITH noconstant(0), private
   DECLARE reply_cnt = i4 WITH noconstant(0), private
   SET stat = alterlist(reply->qual,sz)
   FOR (i = 1 TO sz)
    SET j = findpersonindex(request->persons[i].person_id)
    IF (j > 0)
     SET reply_cnt += 1
     SET reply->qual[reply_cnt].person_id = temp->patients[j].person_id
     SET reply->qual[reply_cnt].encntr_id = request->persons[i].encntr_id
     SET reply->qual[reply_cnt].name_full_formatted = temp->patients[j].name_full_formatted
     SET reply->qual[reply_cnt].gender_cd = temp->patients[j].gender_cd
     SET reply->qual[reply_cnt].birthdate = temp->patients[j].birthdate
     SET reply->qual[reply_cnt].birth_tz = temp->patients[j].birth_tz
     SET reply->qual[reply_cnt].vip_cd = temp->patients[j].vip_cd
     SET reply->qual[reply_cnt].confid_cd = temp->patients[j].confid_cd
     SET reply->qual[reply_cnt].age = temp->patients[j].age
     SET reply->qual[reply_cnt].sticky_notes_ind = temp->patients[j].sticky_notes_ind
     SET reply->qual[reply_cnt].mrn = temp->patients[j].mrn
     SET reply->qual[reply_cnt].deceased_date = temp->patients[j].deceased_date
     SET reply->qual[reply_cnt].deceased_tz = temp->patients[j].deceased_tz
     IF ((request->persons[i].encntr_id > 0))
      SET j = findencntrindex(request->persons[i].encntr_id)
      IF (j > 0)
       SET reply->qual[reply_cnt].confid_cd = temp->encntrs[j].confid_cd
       IF (trim(temp->encntrs[j].mrn) != null)
        SET reply->qual[reply_cnt].mrn = temp->encntrs[j].mrn
       ENDIF
       SET reply->qual[reply_cnt].reg_dt_tm = temp->encntrs[j].reg_dt_tm
       SET reply->qual[reply_cnt].inpatient_admit_dt_tm = temp->encntrs[j].inpatient_admit_dt_tm
       SET reply->qual[reply_cnt].bed_location_cd = temp->encntrs[j].bed_location_cd
       SET reply->qual[reply_cnt].bed_collation_seq = temp->encntrs[j].bed_sequence
       SET reply->qual[reply_cnt].room_location_cd = temp->encntrs[j].room_location_cd
       SET reply->qual[reply_cnt].room_collation_seq = temp->encntrs[j].room_sequence
       SET reply->qual[reply_cnt].unit_location_cd = temp->encntrs[j].unit_location_cd
       SET reply->qual[reply_cnt].unit_collation_seq = temp->encntrs[j].unit_sequence
       SET reply->qual[reply_cnt].building_location_cd = temp->encntrs[j].building_location_cd
       SET reply->qual[reply_cnt].building_collation_seq = temp->encntrs[j].building_sequence
       SET reply->qual[reply_cnt].facility_location_cd = temp->encntrs[j].facility_location_cd
       SET reply->qual[reply_cnt].facility_collation_seq = uar_get_collation_seq(reply->qual[
        reply_cnt].facility_location_cd)
       SET reply->qual[reply_cnt].temp_location_cd = temp->encntrs[j].temp_location_cd
       SET reply->qual[reply_cnt].service_cd = temp->encntrs[j].service_cd
       SET reply->qual[reply_cnt].leave_ind = temp->encntrs[j].leave_ind
       SET reply->qual[reply_cnt].visit_reason = temp->encntrs[j].visit_reason
       SET reply->qual[reply_cnt].fin_nbr = temp->encntrs[j].fin_nbr
       SET reply->qual[reply_cnt].los = temp->encntrs[j].los
       SET reply->qual[reply_cnt].encntr_type = temp->encntrs[j].encntr_type
       SET reply->qual[reply_cnt].encntr_type_new_cd = temp->encntrs[j].encntr_type_new_cd
       SET reply->qual[reply_cnt].discharge_date = temp->encntrs[j].discharge_date
       SET reply->qual[reply_cnt].est_discharge_date = temp->encntrs[j].est_discharge_date
       SET reply->qual[reply_cnt].end_effective_dt_tm = temp->encntrs[j].end_effective_dt_tm
       SET reply->qual[reply_cnt].visitor_status_cd = temp->encntrs[j].visitor_status_cd
       SET reply->qual[reply_cnt].time_zone_indx = temp->encntrs[j].time_zone_indx
       IF (validate(reply->qual[reply_cnt].est_arrive_dt_tm) > 0)
        SET reply->qual[reply_cnt].est_arrive_dt_tm = temp->encntrs[j].est_arrive_dt_tm
       ENDIF
       IF (validate(reply->qual[reply_cnt].arrive_dt_tm) > 0)
        SET reply->qual[reply_cnt].arrive_dt_tm = temp->encntrs[j].arrive_dt_tm
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   IF (reply_cnt=0)
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
 END ;Subroutine
END GO
