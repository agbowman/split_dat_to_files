CREATE PROGRAM bed_get_fn_filter_by_tab:dba
 FREE SET reply
 RECORD reply(
   1 tabs[*]
     2 name_value_prefs_id = f8
     2 patient_filter_option = i2
     2 filter_time = i4
     2 filter_time_unit = i2
     2 filter_from_date = vc
     2 filter_to_date = vc
     2 filter_all_prv = i2
     2 filter_unavail_prv = i2
     2 custom_filter_id = f8
     2 custom_filter_name = vc
     2 patient_type_filters[*]
       3 code_value = f8
       3 mean = vc
       3 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET beg_pos = 0
 SET end_pos = 0
 SET temp_beg_pos = 0
 SET temp_end_pos = 0
 SET tab_count = 0
 SET tab_count = size(request->tabs,5)
 IF (tab_count=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->tabs,tab_count)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tab_count),
   name_value_prefs nvp
  PLAN (d)
   JOIN (nvp
   WHERE (nvp.name_value_prefs_id=request->tabs[d.seq].name_value_prefs_id))
  HEAD d.seq
   reply->tabs[d.seq].name_value_prefs_id = request->tabs[d.seq].name_value_prefs_id
  DETAIL
   tot_length = 0, temp_beg_pos = 0, temp_end_pos = 0,
   temp_tot_length = 0, filter_time_unit = 0, filter_time = 0,
   patient_filter_option = 0, refresh_time = 0, refresh_unit = 0,
   scroll_time = 0, scroll_unit = 0, filter_all_prv = 0,
   filter_unavail_prv = 0, bed_view_cd = 0.0, list_type_cd = 0.0,
   column_view_id = 0.0, track_group_cd = 0.0, filter_id = 0.0,
   location_view_cd = 0.0, loc_security_cd = 0.0, edit_security_cd = 0.0,
   filters = fillstring(100," "), filter_from_date = fillstring(20," "), filter_to_date = fillstring(
    20," "),
   refresh_rate = fillstring(10," "), scroll_rate = fillstring(10," ")
   IF (nvp.pvc_value="TRKBEDLIST*")
    tot_length = size(nvp.pvc_value,1), beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0
     ),
    tab_type = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos
     = findstring(";",nvp.pvc_value,beg_pos,0),
    filters = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (filters != "0,0,0,0,0")
     temp_beg_pos = 1, temp_end_pos = findstring(",",trim(filters),1,0), patient_filter_option =
     cnvtint(substring(1,(temp_end_pos - temp_beg_pos),filters)),
     temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0)
     IF (((patient_filter_option=4) OR (patient_filter_option=5)) )
      filter_from_date = substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters), temp_beg_pos
       = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0),
      filter_to_date = substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters)
     ELSEIF (((patient_filter_option=2) OR (patient_filter_option=1)) )
      filter_time_unit = cnvtint(substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters)),
      temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0),
      filter_time = cnvtint(substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters))
     ENDIF
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos), bed_view_cd = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), empty_values = substring(beg_pos,8,nvp.pvc_value), beg_pos = (beg_pos+ 8),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), list_type_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_view_id = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), track_group_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), refresh_rate = substring(beg_pos,(end_pos -
     beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), filter_id = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), location_view_cd = cnvtreal(substring(beg_pos,
      (end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), scroll_rate = substring(beg_pos,(end_pos -
     beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), loc_security_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), edit_security_cd = cnvtreal(substring(beg_pos,
      (end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    dnbr = cnvtint(substring(beg_pos,tot_length,nvp.pvc_value))
   ELSEIF (nvp.pvc_value="LOCATION*")
    tot_length = size(nvp.pvc_value,1), beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0
     ),
    tab_type = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos
     = findstring(";",nvp.pvc_value,beg_pos,0),
    filters = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (filters != "0,0,0,0,0*")
     temp_beg_pos = 1, temp_end_pos = findstring(",",trim(filters),1,0), patient_filter_option =
     cnvtint(substring(1,(temp_end_pos - temp_beg_pos),filters)),
     temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0)
     IF (((patient_filter_option=4) OR (patient_filter_option=5)) )
      filter_from_date = substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters), temp_beg_pos
       = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0),
      filter_to_date = substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters), temp_beg_pos =
      (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0)
     ELSEIF (((patient_filter_option=1) OR (patient_filter_option=2)) )
      filter_time_unit = cnvtint(substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters)),
      temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0),
      filter_time = cnvtint(substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters)),
      temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0)
     ENDIF
     pat_filter_count = cnvtint(substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters)), stat
      = alterlist(reply->tabs[d.seq].patient_type_filters,pat_filter_count)
     FOR (i = 1 TO pat_filter_count)
       temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0),
       patient_type_cd = cnvtint(substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters)),
       reply->tabs[d.seq].patient_type_filters[i].code_value = patient_type_cd
     ENDFOR
    ENDIF
    facility_cd = 0.0, building_cd = 0.0, unit_cd = 0.0,
    room_cd = 0.0, bed_cd = 0.0, beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos), facility_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos), building_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos), unit_cd = cnvtreal(substring(beg_pos,(end_pos -
      beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos), room_cd = cnvtreal(substring(beg_pos,(end_pos -
      beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos), bed_cd = cnvtreal(substring(beg_pos,(end_pos -
      beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), list_type_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_view_id = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), track_group_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), refresh_rate = substring(beg_pos,(end_pos -
     beg_pos),nvp.pvc_value)
    IF (refresh_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(refresh_rate),1,0),
     refresh_unit = cnvtint(substring(1,1,refresh_rate)),
     temp_beg_pos = (temp_end_pos+ 1), refresh_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       refresh_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), filter_id = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), location_view_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), scroll_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (scroll_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(scroll_rate),1,0),
     scroll_unit = cnvtint(substring(1,(temp_end_pos - 1),scroll_rate)),
     temp_beg_pos = (temp_end_pos+ 1), scroll_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       scroll_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), loc_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), edit_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), dnbr = cnvtint(substring(beg_pos,tot_length,nvp.pvc_value))
   ELSEIF (nvp.pvc_value="TRKPRVLIST*")
    tot_length = size(nvp.pvc_value,1), beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0
     ),
    tab_type = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos
     = findstring(";",nvp.pvc_value,beg_pos,0),
    filters = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (filters != ",0,0,0,0,0,0")
     temp_beg_pos = 1, temp_end_pos = findstring(",",trim(filters),1,0), patient_filter_option =
     cnvtint(substring(1,(temp_end_pos - temp_beg_pos),filters)),
     temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0),
     filter_time_unit = cnvtint(substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters)),
     temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0),
     filter_time = cnvtint(substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters)),
     temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0),
     pat_filter_count = cnvtint(substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters)),
     temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0),
     patient_type_cd = cnvtint(substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters)),
     temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0),
     filter_all_prv = cnvtint(substring(temp_beg_pos,1,filters)),
     temp_beg_pos = (temp_end_pos+ 1), filter_unavail_prv = cnvtint(substring(temp_beg_pos,1,filters)
      )
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), temp = substring(
     beg_pos,(end_pos - beg_pos),nvp.pvc_value),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), list_type_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_view_id =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), track_group_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), refresh_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (refresh_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(refresh_rate),1,0),
     refresh_unit = cnvtint(substring(1,1,refresh_rate)),
     temp_beg_pos = (temp_end_pos+ 1), refresh_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       refresh_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), filter_id = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), location_view_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), scroll_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (scroll_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(scroll_rate),1,0),
     scroll_unit = cnvtint(substring(1,(temp_end_pos - 1),scroll_rate)),
     temp_beg_pos = (temp_end_pos+ 1), scroll_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       scroll_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), loc_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), edit_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), dnbr = cnvtint(substring(beg_pos,tot_length,nvp.pvc_value))
   ELSEIF (nvp.pvc_value="TRKGROUP*")
    tot_length = size(nvp.pvc_value,1), beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0
     ),
    tab_type = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos
     = findstring(";",nvp.pvc_value,beg_pos,0),
    filters = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (filters != "0,0,0,0,0")
     temp_beg_pos = 1, temp_end_pos = findstring(",",trim(filters),1,0), patient_filter_option =
     cnvtint(substring(1,(temp_end_pos - temp_beg_pos),filters)),
     temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0)
     IF (((patient_filter_option=4) OR (patient_filter_option=5)) )
      filter_from_date = substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters), temp_beg_pos
       = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0),
      filter_to_date = substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters)
     ELSEIF (((patient_filter_option=2) OR (patient_filter_option=1)) )
      filter_time_unit = cnvtint(substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters)),
      temp_beg_pos = (temp_end_pos+ 1), temp_end_pos = findstring(",",trim(filters),temp_beg_pos,0),
      filter_time = cnvtint(substring(temp_beg_pos,(temp_end_pos - temp_beg_pos),filters))
     ENDIF
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), temp = substring(
     beg_pos,(end_pos - beg_pos),nvp.pvc_value),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), list_type_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_view_id =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), track_group_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), refresh_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (refresh_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(refresh_rate),1,0),
     refresh_unit = cnvtint(substring(1,1,refresh_rate)),
     temp_beg_pos = (temp_end_pos+ 1), refresh_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       refresh_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), filter_id = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), location_view_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), scroll_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (scroll_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(scroll_rate),1,0),
     scroll_unit = cnvtint(substring(1,(temp_end_pos - 1),scroll_rate)),
     temp_beg_pos = (temp_end_pos+ 1), scroll_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       scroll_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), loc_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), edit_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), dnbr = cnvtint(substring(beg_pos,tot_length,nvp.pvc_value))
   ENDIF
   reply->tabs[d.seq].patient_filter_option = patient_filter_option, reply->tabs[d.seq].filter_time
    = filter_time, reply->tabs[d.seq].filter_time_unit = filter_time_unit,
   reply->tabs[d.seq].filter_from_date = filter_from_date, reply->tabs[d.seq].filter_to_date =
   filter_to_date, reply->tabs[d.seq].filter_all_prv = filter_all_prv,
   reply->tabs[d.seq].filter_unavail_prv = filter_unavail_prv, reply->tabs[d.seq].custom_filter_id =
   filter_id
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tab_count),
   predefined_prefs pp
  PLAN (d
   WHERE (reply->tabs[d.seq].custom_filter_id > 0))
   JOIN (pp
   WHERE pp.active_ind=1
    AND (pp.predefined_prefs_id=reply->tabs[d.seq].custom_filter_id))
  DETAIL
   reply->tabs[d.seq].custom_filter_name = pp.name
  WITH nocounter
 ;end select
 FOR (x = 1 TO tab_count)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(size(reply->tabs[x].patient_type_filters,5))),
     code_value cv
    PLAN (d
     WHERE (reply->tabs[x].patient_type_filters[d.seq].code_value > 0))
     JOIN (cv
     WHERE cv.active_ind=1
      AND (cv.code_value=reply->tabs[x].patient_type_filters[d.seq].code_value))
    DETAIL
     reply->tabs[x].patient_type_filters[d.seq].mean = cv.cdf_meaning, reply->tabs[x].
     patient_type_filters[d.seq].display = cv.display
    WITH nocounter
   ;end select
 ENDFOR
#exit_script
 IF (tab_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
