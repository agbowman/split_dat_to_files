CREATE PROGRAM dcp_get_pat_demog:dba
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
      2 birth_tz = i4
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
      2 assign_notes_ind = i2
      2 rounds_notes_ind = i2
      2 plan_name = vc
      2 patient_status = f8
      2 discharge_date = dq8
      2 end_effective_dt_tm = dq8
      2 street_addr = vc
      2 street_addr2 = vc
      2 city = vc
      2 state = vc
      2 zipcode = vc
      2 phone_num = vc
      2 encntr_contact_info[*]
        3 person_reltn_type_cd = f8
        3 person_reltn_cd = f8
        3 name_full_formatted = vc
        3 street_addr = vc
        3 street_addr2 = vc
        3 city = vc
        3 state = vc
        3 zipcode = vc
        3 phone_num = vc
        3 priority_seq = i4
      2 lifetime_contact_info[*]
        3 person_reltn_type_cd = f8
        3 person_reltn_cd = f8
        3 name_full_formatted = vc
        3 street_addr = vc
        3 street_addr2 = vc
        3 city = vc
        3 state = vc
        3 zipcode = vc
        3 phone_num = vc
        3 priority_seq = i4
      2 visitor_status_cd = f8
      2 visitor_status_disp = c40
      2 time_zone_indx = i4
      2 ssn = vc
      2 encntr_type_class_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD encntrloctzreq(
   1 encntrs[*]
     2 encntr_id = f8
   1 facilities[*]
     2 loc_facility_cd = f8
 )
 FREE RECORD reqtemp
 RECORD reqtemp(
   1 person_cnt = i4
   1 person_list[*]
     2 person_id = f8
   1 encntr_cnt = i4
   1 encntr_list[*]
     2 encntr_id = f8
     2 person_id = f8
 )
 FREE RECORD temp
 RECORD temp(
   1 encntr_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
     2 bed_location_cd = f8
     2 bed_sequence = i4
     2 room_location_cd = f8
     2 room_sequence = i4
     2 unit_location_cd = f8
     2 unit_sequence = i4
     2 building_location_cd = f8
     2 building_sequence = i4
     2 facility_location_cd = f8
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
 SET reply->status_data.status = "F"
 SET sz = size(request->persons,5)
 SET cnt = 0
 SET stat = 0
 DECLARE no_of_days = vc WITH public, noconstant
 SET no_of_days = uar_i18ngetmessage(i18nhandle,"No_of_days","Days")
 DECLARE time_zone_cnt = i4 WITH noconstant(0)
 DECLARE rep_size = i4 WITH noconstant(0)
 DECLARE facility_cnt = i4 WITH noconstant(0)
 DECLARE cs = f8 WITH noconstant(0.0)
 DECLARE valid_ind = i2 WITH noconstant(0)
 DECLARE temp_phone = vc WITH public, noconstant(fillstring(40," "))
 DECLARE fmt_phone = vc WITH public, noconstant(fillstring(40," "))
 DECLARE code_value = f8 WITH noconstant(0.0)
 DECLARE code_set = i4 WITH noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE guardian_cd = f8 WITH constant(uar_get_code_by("MEANING",351,"GUARDIAN"))
 DECLARE emc_cd = f8 WITH constant(uar_get_code_by("MEANING",351,"EMC"))
 DECLARE family_cd = f8 WITH constant(uar_get_code_by("MEANING",351,"FAMILY"))
 DECLARE nok_cd = f8 WITH constant(uar_get_code_by("MEANING",351,"NOK"))
 DECLARE default_format_cd = f8 WITH constant(uar_get_code_by("MEANING",281,"DEFAULT"))
 DECLARE homeaddresscode = f8 WITH constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE homephonecode = f8 WITH constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE shiftnote_cd = f8 WITH constant(uar_get_code_by("MEANING",14122,"ASGMTNOTE"))
 DECLARE powerchart_cd = f8 WITH constant(uar_get_code_by("MEANING",14122,"POWERCHART"))
 DECLARE roundnote_cd = f8 WITH constant(uar_get_code_by("MEANING",14122,"ROUNDNOTE"))
 DECLARE life_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE encntr_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ssn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE preprocessrequest(null) = null
 DECLARE findencntrindex(encntr=f8) = i4
 DECLARE tempencntrindex = i4 WITH noconstant(0), private
 CALL preprocessrequest(null)
 DECLARE encntr_size = i4 WITH protect, constant(size(temp->encntrs,5))
 IF ((reqtemp->encntr_cnt > 0))
  CALL loadencntrinfo(null)
  CALL initializesequences(null)
  CALL loadbedsequence(null)
  CALL loadroomsequence(null)
  CALL loadunitsequence(null)
  CALL loadbuildingsequence(null)
 ENDIF
 SUBROUTINE initializesequences(null)
   FOR (i = 1 TO temp->encntr_cnt)
     SET temp->encntrs[i].bed_sequence = - (1)
     SET temp->encntrs[i].room_sequence = - (1)
     SET temp->encntrs[i].unit_sequence = - (1)
     SET temp->encntrs[i].building_sequence = - (1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE preprocessrequest(null)
   DECLARE i1 = i4 WITH noconstant(0)
   DECLARE j1 = i4 WITH noconstant(0)
   SET stat = alterlist(reqtemp->encntr_list,sz)
   SET stat = alterlist(reqtemp->person_list,sz)
   SET stat = alterlist(temp->encntrs,sz)
   SET reqtemp->person_cnt = 0
   SET reqtemp->encntr_cnt = 0
   FOR (i1 = 1 TO sz)
     SET reqtemp->person_cnt = (reqtemp->person_cnt+ 1)
     SET reqtemp->person_list[reqtemp->person_cnt].person_id = request->persons[i1].person_id
     IF ((request->persons[i1].encntr_id > 0.0))
      SET reqtemp->encntr_cnt = (reqtemp->encntr_cnt+ 1)
      SET reqtemp->encntr_list[reqtemp->encntr_cnt].encntr_id = request->persons[i1].encntr_id
      SET reqtemp->encntr_list[reqtemp->encntr_cnt].person_id = request->persons[i1].person_id
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE loadencntrinfo(null)
   DECLARE new_list_size = i4
   DECLARE cur_list_size = i4
   DECLARE batch_size = i4 WITH constant(40)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH noconstant(0)
   DECLARE loop_cnt = i4 WITH noconstant(0)
   SET cur_list_size = reqtemp->encntr_cnt
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(reqtemp->encntr_list,new_list_size)
   SET nstart = 1
   FOR (idx = (cur_list_size+ 1) TO new_list_size)
     SET reqtemp->encntr_list[idx].encntr_id = reqtemp->encntr_list[cur_list_size].encntr_id
   ENDFOR
   SELECT INTO "nl:"
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
    HEAD e.encntr_id
     temp->encntr_cnt = (temp->encntr_cnt+ 1), temp->encntrs[temp->encntr_cnt].encntr_id = e
     .encntr_id, temp->encntrs[temp->encntr_cnt].bed_location_cd = e.loc_bed_cd,
     temp->encntrs[temp->encntr_cnt].room_location_cd = e.loc_room_cd, temp->encntrs[temp->encntr_cnt
     ].unit_location_cd = e.loc_nurse_unit_cd, temp->encntrs[temp->encntr_cnt].building_location_cd
      = e.loc_building_cd,
     temp->encntrs[temp->encntr_cnt].facility_location_cd = e.loc_facility_cd
   ;end select
 END ;Subroutine
 SUBROUTINE loadbedsequence(null)
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
 SUBROUTINE findencntrindex(encntr)
   DECLARE val = i4 WITH noconstant(0)
   FOR (val = 1 TO temp->encntr_cnt)
     IF ((temp->encntrs[val].encntr_id=encntr))
      RETURN(val)
     ENDIF
   ENDFOR
   RETURN(- (1))
 END ;Subroutine
 SET cs = 71
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
 SET stat = alterlist(reply->qual,sz)
 SELECT INTO "nl:"
  nulld = nullind(p.deceased_dt_tm)
  FROM (dummyt d  WITH seq = value(sz)),
   person p,
   address a,
   phone ph,
   person_alias pa
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=request->persons[d.seq].person_id)
    AND p.active_ind=1)
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND a.parent_entity_name=outerjoin("PERSON")
    AND a.active_ind=outerjoin(1)
    AND a.address_type_cd=outerjoin(homeaddresscode)
    AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND a.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(p.person_id)
    AND ph.parent_entity_name=outerjoin("PERSON")
    AND ph.phone_type_cd=outerjoin(homephonecode)
    AND ph.active_ind=outerjoin(1)
    AND ph.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ph.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.person_alias_type_cd=outerjoin(ssn_cd)
    AND pa.active_ind=outerjoin(1)
    AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY d.seq, a.address_type_seq, ph.phone_type_seq
  HEAD d.seq
   cnt = (cnt+ 1), reply->qual[cnt].person_id = p.person_id, reply->qual[cnt].encntr_id = request->
   persons[d.seq].encntr_id,
   reply->qual[cnt].name_full_formatted = p.name_full_formatted, reply->qual[cnt].gender_cd = p
   .sex_cd, reply->qual[cnt].birthdate = p.birth_dt_tm,
   reply->qual[cnt].birth_tz = validate(p.birth_tz,0), reply->qual[cnt].ssn = cnvtalias(pa.alias,pa
    .alias_pool_cd)
   IF (nulld=0)
    reply->qual[cnt].age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),
     cnvtint(format(p.birth_dt_tm,"hhmm;;m")),cnvtdate2(format(p.deceased_dt_tm,"mm/dd/yyyy;;d"),
      "mm/dd/yyyy"),cnvtint(format(p.deceased_dt_tm,"hhmm;;m")))
   ELSE
    reply->qual[cnt].age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),
     cnvtint(format(p.birth_dt_tm,"hhmm;;m")))
   ENDIF
   reply->qual[cnt].vip_cd = p.vip_cd, reply->qual[cnt].confid_cd = p.confid_level_cd, reply->qual[
   cnt].street_addr = a.street_addr,
   reply->qual[cnt].street_addr2 = a.street_addr2, reply->qual[cnt].city = a.city
   IF (a.state > " ")
    reply->qual[cnt].state = a.state
   ELSE
    reply->qual[cnt].state = uar_get_code_display(a.state_cd)
   ENDIF
   reply->qual[cnt].zipcode = a.zipcode, fmt_phone = " "
   IF (ph.phone_num > " "
    AND ph.parent_entity_id > 0)
    temp_phone = cnvtalphanum(ph.phone_num)
    IF (temp_phone != ph.phone_num)
     fmt_phone = ph.phone_num
    ELSEIF (ph.phone_format_cd > 0)
     fmt_phone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
    ELSEIF (default_format_cd > 0)
     fmt_phone = cnvtphone(trim(ph.phone_num),default_format_cd)
    ELSEIF (size(trim(temp_phone)) < 8)
     fmt_phone = format(trim(ph.phone_num),"###-####")
    ELSE
     fmt_phone = format(trim(ph.phone_num),"(###) ###-####")
    ENDIF
    IF (fmt_phone <= " ")
     fmt_phone = ph.phone_num
    ENDIF
    reply->qual[cnt].phone_num = fmt_phone
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,cnt)
 IF (cnt=0)
  GO TO finish
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   person_person_reltn ppsr,
   person p,
   address a,
   phone ph
  PLAN (d)
   JOIN (ppsr
   WHERE (ppsr.person_id=request->persons[d.seq].person_id)
    AND ppsr.active_ind=1
    AND ppsr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ppsr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=ppsr.related_person_id
    AND p.active_ind=1)
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND a.parent_entity_name=outerjoin("PERSON")
    AND a.address_type_cd=outerjoin(homeaddresscode)
    AND a.active_ind=outerjoin(1)
    AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND a.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(p.person_id)
    AND ph.parent_entity_name=outerjoin("PERSON")
    AND ph.phone_type_cd=outerjoin(homephonecode)
    AND ph.active_ind=outerjoin(1)
    AND ph.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ph.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY d.seq, ppsr.person_person_reltn_id
  HEAD d.seq
   ppsrcnt = 0
  HEAD ppsr.person_person_reltn_id
   check_add_seq = - (1), check_ph_seq = - (1)
   IF (ppsr.person_reltn_type_cd IN (guardian_cd, emc_cd, family_cd, nok_cd))
    valid_ind = 0, ppsrcnt = (ppsrcnt+ 1), stat = alterlist(reply->qual[d.seq].lifetime_contact_info,
     ppsrcnt),
    reply->qual[d.seq].lifetime_contact_info[ppsrcnt].person_reltn_type_cd = ppsr
    .person_reltn_type_cd, reply->qual[d.seq].lifetime_contact_info[ppsrcnt].person_reltn_cd = ppsr
    .person_reltn_cd, reply->qual[d.seq].lifetime_contact_info[ppsrcnt].priority_seq = ppsr
    .priority_seq,
    reply->qual[d.seq].lifetime_contact_info[ppsrcnt].name_full_formatted = p.name_full_formatted
   ELSE
    valid_ind = 1
   ENDIF
  DETAIL
   IF (a.address_id != 0
    AND valid_ind=0
    AND ((a.address_type_seq < check_add_seq) OR ((check_add_seq=- (1)))) )
    check_add_seq = a.address_type_seq, reply->qual[d.seq].lifetime_contact_info[ppsrcnt].street_addr
     = a.street_addr, reply->qual[d.seq].lifetime_contact_info[ppsrcnt].street_addr2 = a.street_addr2,
    reply->qual[d.seq].lifetime_contact_info[ppsrcnt].city = a.city
    IF (a.state > " ")
     reply->qual[d.seq].lifetime_contact_info[ppsrcnt].state = a.state
    ELSE
     reply->qual[d.seq].lifetime_contact_info[ppsrcnt].state = uar_get_code_display(a.state_cd)
    ENDIF
    reply->qual[d.seq].lifetime_contact_info[ppsrcnt].zipcode = a.zipcode
   ENDIF
   IF (ph.phone_id != 0)
    IF (valid_ind=0)
     IF (((ph.phone_type_seq < check_ph_seq) OR ((check_ph_seq=- (1)))) )
      check_ph_seq = ph.phone_type_seq, fmt_phone = " "
      IF (ph.phone_num > " "
       AND ph.parent_entity_id > 0)
       temp_phone = cnvtalphanum(ph.phone_num)
       IF (temp_phone != ph.phone_num)
        fmt_phone = ph.phone_num
       ELSEIF (ph.phone_format_cd > 0)
        fmt_phone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
       ELSEIF (default_format_cd > 0)
        fmt_phone = cnvtphone(trim(ph.phone_num),default_format_cd)
       ELSEIF (size(trim(temp_phone)) < 8)
        fmt_phone = format(trim(ph.phone_num),"###-####")
       ELSE
        fmt_phone = format(trim(ph.phone_num),"(###) ###-####")
       ENDIF
       IF (fmt_phone <= " ")
        fmt_phone = ph.phone_num
       ENDIF
       reply->qual[d.seq].lifetime_contact_info[ppsrcnt].phone_num = fmt_phone
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   encounter e,
   encntr_leave el,
   encntr_alias ea,
   encntr_plan_reltn eplr,
   health_plan hp
  PLAN (d
   WHERE (reply->qual[d.seq].encntr_id != 0))
   JOIN (e
   WHERE (e.encntr_id=reply->qual[d.seq].encntr_id))
   JOIN (el
   WHERE el.encntr_id=outerjoin(e.encntr_id)
    AND el.active_ind=outerjoin(1))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (eplr
   WHERE eplr.encntr_id=outerjoin(e.encntr_id)
    AND eplr.health_plan_id > outerjoin(0)
    AND eplr.active_ind=outerjoin(1)
    AND eplr.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND eplr.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (hp
   WHERE hp.health_plan_id=outerjoin(eplr.health_plan_id)
    AND hp.active_ind=outerjoin(1)
    AND hp.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND hp.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY d.seq, eplr.priority_seq, hp.health_plan_id
  HEAD d.seq
   reply->qual[d.seq].patient_status = e.encntr_status_cd, reply->qual[d.seq].discharge_date = e
   .disch_dt_tm, reply->qual[d.seq].end_effective_dt_tm = e.end_effective_dt_tm,
   reply->qual[d.seq].encntr_id = e.encntr_id, reply->qual[d.seq].encntr_type_class_cd = e
   .encntr_type_class_cd, reply->qual[d.seq].confid_cd = e.confid_level_cd,
   reply->qual[d.seq].reg_dt_tm = e.reg_dt_tm, reply->qual[d.seq].bed_location_cd = e.loc_bed_cd,
   reply->qual[d.seq].room_location_cd = e.loc_room_cd,
   reply->qual[d.seq].unit_location_cd = e.loc_nurse_unit_cd, reply->qual[d.seq].building_location_cd
    = e.loc_building_cd, reply->qual[d.seq].facility_location_cd = e.loc_facility_cd,
   reply->qual[d.seq].facility_collation_seq = uar_get_collation_seq(e.loc_facility_cd), reply->qual[
   d.seq].temp_location_cd = e.loc_temp_cd, reply->qual[d.seq].service_cd = e.med_service_cd,
   reply->qual[d.seq].visit_reason = e.reason_for_visit, reply->qual[d.seq].leave_ind = el.leave_ind
   IF ((reply->qual[d.seq].encntr_id > 0))
    tempencntrindex = findencntrindex(e.encntr_id)
    IF (tempencntrindex > 0)
     reply->qual[d.seq].bed_collation_seq = temp->encntrs[tempencntrindex].bed_sequence, reply->qual[
     d.seq].room_collation_seq = temp->encntrs[tempencntrindex].room_sequence, reply->qual[d.seq].
     unit_collation_seq = temp->encntrs[tempencntrindex].unit_sequence,
     reply->qual[d.seq].building_collation_seq = temp->encntrs[tempencntrindex].building_sequence
    ENDIF
   ENDIF
   time_zone_cnt = (time_zone_cnt+ 1)
   IF (mod(time_zone_cnt,10)=1)
    stat = alterlist(encntrloctzreq->facilities,(time_zone_cnt+ 9))
   ENDIF
   IF ((reply->qual[d.seq].facility_location_cd > 0))
    facility_cnt = (facility_cnt+ 1), encntrloctzreq->facilities[time_zone_cnt].loc_facility_cd = e
    .loc_facility_cd
   ENDIF
   IF (cs=71)
    reply->qual[d.seq].encntr_type = e.encntr_type_cd, reply->qual[d.seq].encntr_type_disp =
    uar_get_code_display(e.encntr_type_cd)
   ELSE
    reply->qual[d.seq].encntr_type = e.encntr_type_class_cd, reply->qual[d.seq].encntr_type_disp =
    uar_get_code_display(e.encntr_type_class_cd)
   ENDIF
   IF (e.reg_dt_tm > 0)
    IF (e.disch_dt_tm > 0)
     tempday = datetimediff(e.disch_dt_tm,e.reg_dt_tm), reply->qual[d.seq].los = concat(format(
       tempday,"####.#;I")," ",no_of_days)
    ELSE
     tempday = datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm), reply->qual[d.seq].los =
     concat(format(tempday,"####.#;I")," ",no_of_days)
    ENDIF
   ELSE
    reply->qual[d.seq].los = " "
   ENDIF
   reply->qual[d.seq].visitor_status_cd = e.visitor_status_cd
  HEAD hp.health_plan_id
   IF (hp.health_plan_id > 0)
    IF ((reply->qual[d.seq].plan_name != ""))
     reply->qual[d.seq].plan_name = concat(trim(reply->qual[d.seq].plan_name),"; ",hp.plan_name)
    ELSE
     reply->qual[d.seq].plan_name = hp.plan_name
    ENDIF
   ENDIF
  DETAIL
   IF (ea.encntr_alias_type_cd=encntr_mrn_cd)
    reply->qual[d.seq].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
   ELSEIF (ea.encntr_alias_type_cd=fin_cd)
    reply->qual[d.seq].fin_nbr = cnvtalias(ea.alias,ea.alias_pool_cd)
   ENDIF
  WITH nocounter
 ;end select
 IF (facility_cnt > 0
  AND curutc)
  EXECUTE pm_get_encntr_loc_tz  WITH replace("REQUEST",encntrloctzreq), replace("REPLY",
   encntrloctzrep)
  IF ((encntrloctzrep->status_data.status="F"))
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = encntrloctzrep->status_data.
   subeventstatus[1].targetobjectvalue
   GO TO exit_script
  ENDIF
 ENDIF
 SET rep_size = size(encntrloctzrep->facilities,5)
 IF (rep_size > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(time_zone_cnt)),
    (dummyt d2  WITH seq = value(rep_size))
   PLAN (d1
    WHERE (reply->qual[d1.seq].facility_location_cd > 0))
    JOIN (d2
    WHERE (encntrloctzrep->facilities[d2.seq].loc_facility_cd=reply->qual[d1.seq].
    facility_location_cd))
   DETAIL
    reply->qual[d1.seq].time_zone_indx = encntrloctzrep->facilities[d2.seq].time_zone_indx
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   encntr_person_reltn epsr,
   person p,
   address a,
   phone ph
  PLAN (d)
   JOIN (epsr
   WHERE (epsr.encntr_id=reply->qual[d.seq].encntr_id)
    AND epsr.active_ind=1
    AND epsr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epsr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=epsr.related_person_id
    AND p.active_ind=1)
   JOIN (a
   WHERE a.parent_entity_name=outerjoin("PERSON")
    AND a.parent_entity_id=outerjoin(p.person_id)
    AND a.active_ind=outerjoin(1)
    AND a.address_type_cd=outerjoin(homeaddresscode)
    AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND a.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ph
   WHERE ph.parent_entity_name=outerjoin("PERSON")
    AND ph.parent_entity_id=outerjoin(p.person_id)
    AND ph.phone_type_cd=outerjoin(homephonecode)
    AND ph.active_ind=outerjoin(1)
    AND ph.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ph.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY d.seq, epsr.encntr_person_reltn_id
  HEAD d.seq
   epsrcnt = 0
  HEAD epsr.encntr_person_reltn_id
   check_add_seq = - (1), check_ph_seq = - (1)
   IF (epsr.person_reltn_type_cd IN (guardian_cd, emc_cd, family_cd, nok_cd))
    valid_ind = 0, epsrcnt = (epsrcnt+ 1), stat = alterlist(reply->qual[d.seq].encntr_contact_info,
     epsrcnt),
    reply->qual[d.seq].encntr_contact_info[epsrcnt].person_reltn_type_cd = epsr.person_reltn_type_cd,
    reply->qual[d.seq].encntr_contact_info[epsrcnt].person_reltn_cd = epsr.person_reltn_cd, reply->
    qual[d.seq].encntr_contact_info[epsrcnt].priority_seq = epsr.priority_seq,
    reply->qual[d.seq].encntr_contact_info[epsrcnt].name_full_formatted = p.name_full_formatted
   ELSE
    valid_ind = 1
   ENDIF
  DETAIL
   IF (a.address_id != 0)
    IF (valid_ind=0)
     IF (((a.address_type_seq < check_add_seq) OR ((check_add_seq=- (1)))) )
      check_add_seq = a.address_type_seq, reply->qual[d.seq].encntr_contact_info[epsrcnt].street_addr
       = a.street_addr, reply->qual[d.seq].encntr_contact_info[epsrcnt].street_addr2 = a.street_addr2,
      reply->qual[d.seq].encntr_contact_info[epsrcnt].city = a.city
      IF (a.state > " ")
       reply->qual[d.seq].encntr_contact_info[epsrcnt].state = a.state
      ELSE
       reply->qual[d.seq].encntr_contact_info[epsrcnt].state = uar_get_code_display(a.state_cd)
      ENDIF
      reply->qual[d.seq].encntr_contact_info[epsrcnt].zipcode = a.zipcode
     ENDIF
    ENDIF
   ENDIF
   IF (ph.phone_id != 0)
    IF (valid_ind=0)
     IF (((ph.phone_type_seq < check_ph_seq) OR ((check_ph_seq=- (1)))) )
      check_ph_seq = ph.phone_type_seq, fmt_phone = " "
      IF (ph.phone_num > " "
       AND ph.parent_entity_id > 0)
       temp_phone = cnvtalphanum(ph.phone_num)
       IF (temp_phone != ph.phone_num)
        fmt_phone = ph.phone_num
       ELSEIF (ph.phone_format_cd > 0)
        fmt_phone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
       ELSEIF (default_format_cd > 0)
        fmt_phone = cnvtphone(trim(ph.phone_num),default_format_cd)
       ELSEIF (size(trim(temp_phone)) < 8)
        fmt_phone = format(trim(ph.phone_num),"###-####")
       ELSE
        fmt_phone = format(trim(ph.phone_num),"(###) ###-####")
       ENDIF
       IF (fmt_phone <= " ")
        fmt_phone = ph.phone_num
       ENDIF
       reply->qual[d.seq].encntr_contact_info[epsrcnt].phone_num = fmt_phone
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   person_plan_reltn pplr,
   health_plan hp
  PLAN (d
   WHERE (reply->qual[d.seq].plan_name=""))
   JOIN (pplr
   WHERE (pplr.person_id=reply->qual[d.seq].person_id)
    AND pplr.active_ind=1
    AND pplr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pplr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (hp
   WHERE hp.health_plan_id=pplr.health_plan_id
    AND hp.active_ind=1
    AND hp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND hp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, pplr.priority_seq, hp.plan_name
  DETAIL
   IF (hp.health_plan_id > 0)
    IF ((reply->qual[d.seq].plan_name != ""))
     reply->qual[d.seq].plan_name = concat(trim(reply->qual[d.seq].plan_name),"; ",hp.plan_name)
    ELSE
     reply->qual[d.seq].plan_name = hp.plan_name
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   person_alias pa
  PLAN (d
   WHERE (reply->qual[d.seq].mrn=""))
   JOIN (pa
   WHERE (pa.person_id=reply->qual[d.seq].person_id)
    AND pa.person_alias_type_cd=life_mrn_cd
    AND pa.active_ind=1)
  DETAIL
   reply->qual[d.seq].mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   sticky_note sn
  PLAN (d)
   JOIN (sn
   WHERE (sn.parent_entity_id=reply->qual[d.seq].person_id)
    AND sn.sticky_note_type_cd IN (powerchart_cd, shiftnote_cd, roundnote_cd)
    AND sn.parent_entity_name="PERSON")
  ORDER BY d.seq, sn.sticky_note_type_cd
  HEAD d.seq
   reply->qual[d.seq].sticky_notes_ind = 0, reply->qual[d.seq].assign_notes_ind = 0, reply->qual[d
   .seq].rounds_notes_ind = 0
  HEAD sn.sticky_note_type_cd
   IF (sn.sticky_note_type_cd=powerchart_cd)
    reply->qual[d.seq].sticky_notes_ind = 1
   ELSEIF (sn.sticky_note_type_cd=shiftnote_cd)
    reply->qual[d.seq].assign_notes_ind = 1
   ELSEIF (sn.sticky_note_type_cd=roundnote_cd
    AND (((sn.parent_entity_id=reqinfo->updt_id)) OR (sn.public_ind=1)) )
    reply->qual[d.seq].rounds_notes_ind = 1
   ENDIF
  WITH nocounter
 ;end select
#finish
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
