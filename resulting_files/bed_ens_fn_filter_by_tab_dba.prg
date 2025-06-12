CREATE PROGRAM bed_ens_fn_filter_by_tab:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET new_pvc_value = fillstring(256," ")
 SELECT INTO "NL:"
  FROM name_value_prefs nvp
  WHERE (nvp.name_value_prefs_id=request->name_value_prefs_id)
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
    beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0), new_pvc_value = substring(1,(
     end_pos - beg_pos),nvp.pvc_value),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), new_pvc_value = concat
    (trim(new_pvc_value),";",trim(cnvtstring(request->patient_filter_option)),",")
    IF ((((request->patient_filter_option=5)) OR ((request->patient_filter_option=4))) )
     new_pvc_value = concat(trim(new_pvc_value),trim(request->filter_from_date),",",trim(request->
       filter_to_date),",")
    ELSEIF ((((request->patient_filter_option=2)) OR ((request->patient_filter_option=1))) )
     new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->filter_time_unit)),",",trim(
       cnvtstring(request->filter_time)),",")
    ELSEIF ((request->patient_filter_option=3))
     new_pvc_value = concat(trim(new_pvc_value),"0,0,")
    ENDIF
    new_pvc_value = concat(trim(new_pvc_value),"0,0,0,0"), beg_pos = (end_pos+ 1), end_pos =
    findstring(";",nvp.pvc_value,beg_pos),
    bed_view_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos
    + 1), end_pos = findstring(";",nvp.pvc_value,beg_pos),
    new_pvc_value = concat(trim(new_pvc_value),";",trim(cnvtstring(bed_view_cd)),";0;0;0;0;"),
    beg_pos = (beg_pos+ 8), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    list_type_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos
    + 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    column_view_id = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
    end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    track_group_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
    end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    refresh_rate = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    filter_id = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1
    ), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    location_view_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
    end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    scroll_rate = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    loc_security_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
    end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    edit_security_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
    end_pos+ 1), end_pos = findstring(" ",nvp.pvc_value,beg_pos,0),
    dnbr = cnvtint(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), new_pvc_value = concat(trim
     (new_pvc_value),trim(cnvtstring(list_type_cd)),";",trim(cnvtstring(column_view_id)),";",
     trim(cnvtstring(track_group_cd)),";",trim(refresh_rate),";",trim(cnvtstring(request->
       custom_filter_id)),
     ";",trim(cnvtstring(location_view_cd)),";",trim(scroll_rate),";",
     trim(cnvtstring(loc_security_cd)),";",trim(cnvtstring(edit_security_cd)),";",trim(cnvtstring(
       dnbr)))
   ELSEIF (nvp.pvc_value="LOCATION*")
    beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0), new_pvc_value = substring(1,(
     end_pos - beg_pos),nvp.pvc_value),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), new_pvc_value = concat
    (trim(new_pvc_value),";",trim(cnvtstring(request->patient_filter_option)),",")
    IF ((((request->patient_filter_option=5)) OR ((request->patient_filter_option=4))) )
     new_pvc_value = concat(trim(new_pvc_value),trim(request->filter_from_date),",",trim(request->
       filter_to_date),",")
    ELSEIF ((((request->patient_filter_option=2)) OR ((request->patient_filter_option=1))) )
     new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->filter_time_unit)),",",trim(
       cnvtstring(request->filter_time)),",")
    ELSEIF ((request->patient_filter_option=3))
     new_pvc_value = concat(trim(new_pvc_value),"0,0,")
    ENDIF
    pat_type_cnt = size(request->patient_type_filters,5), new_pvc_value = concat(trim(new_pvc_value),
     trim(cnvtstring(pat_type_cnt)),",")
    FOR (i = 1 TO pat_type_cnt)
      new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->patient_type_filters[i].
         code_value)),",")
    ENDFOR
    new_pvc_value = concat(trim(new_pvc_value),"0,0,0"), facility_cd = 0.0, building_cd = 0.0,
    unit_cd = 0.0, room_cd = 0.0, bed_cd = 0.0,
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos), facility_cd = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos), building_cd = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos), unit_cd = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos), room_cd = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos), bed_cd = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), list_type_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_view_id =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), track_group_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), refresh_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), filter_id = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), location_view_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), scroll_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), loc_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), edit_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(" ",nvp.pvc_value,beg_pos,0), dnbr = cnvtint(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    new_pvc_value = concat(trim(new_pvc_value),";",trim(cnvtstring(facility_cd)),";",trim(cnvtstring(
       building_cd)),
     ";",trim(cnvtstring(unit_cd)),";",trim(cnvtstring(room_cd)),";",
     trim(cnvtstring(bed_cd)),";"), new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(
       list_type_cd)),";",trim(cnvtstring(column_view_id)),";",
     trim(cnvtstring(track_group_cd)),";",trim(refresh_rate),";",trim(cnvtstring(request->
       custom_filter_id)),
     ";",trim(cnvtstring(location_view_cd)),";",trim(scroll_rate),";",
     trim(cnvtstring(loc_security_cd)),";",trim(cnvtstring(edit_security_cd)),";",trim(cnvtstring(
       dnbr)))
   ELSEIF (nvp.pvc_value="TRKPRVLIST*")
    beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0), new_pvc_value = substring(1,(
     end_pos - beg_pos),nvp.pvc_value),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0)
    IF ((((request->filter_all_prv=1)) OR ((request->filter_unavail_prv=1))) )
     new_pvc_value = concat(trim(new_pvc_value),";,0,0,0,0,")
    ELSE
     new_pvc_value = concat(trim(new_pvc_value),";0,0,0,")
    ENDIF
    IF ((request->filter_all_prv=1))
     new_pvc_value = concat(trim(new_pvc_value),"1,")
    ELSE
     new_pvc_value = concat(trim(new_pvc_value),"0,")
    ENDIF
    IF ((request->filter_unavail_prv=1))
     new_pvc_value = concat(trim(new_pvc_value),"1;")
    ELSE
     new_pvc_value = concat(trim(new_pvc_value),"0;")
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), beg_pos = (end_pos+ 1),
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
    end_pos = findstring(" ",nvp.pvc_value,beg_pos,0), dnbr = cnvtint(substring(beg_pos,(end_pos -
      beg_pos),nvp.pvc_value))
    IF ((((request->filter_all_prv=1)) OR ((request->filter_unavail_prv=1))) )
     new_pvc_value = concat(trim(new_pvc_value),";",trim(cnvtstring(list_type_cd)),";",trim(
       cnvtstring(column_view_id)),
      ";",trim(cnvtstring(track_group_cd)),";",trim(refresh_rate),";",
      trim(cnvtstring(request->custom_filter_id)),";",trim(cnvtstring(location_view_cd)),";",trim(
       scroll_rate),
      ";",trim(cnvtstring(loc_security_cd)),";",trim(cnvtstring(edit_security_cd)),";",
      trim(cnvtstring(dnbr)))
    ELSE
     new_pvc_value = concat(trim(new_pvc_value),"0;",trim(cnvtstring(list_type_cd)),";",trim(
       cnvtstring(column_view_id)),
      ";",trim(cnvtstring(track_group_cd)),";",trim(refresh_rate),";",
      trim(cnvtstring(request->custom_filter_id)),";",trim(cnvtstring(location_view_cd)),";",trim(
       scroll_rate),
      ";",trim(cnvtstring(loc_security_cd)),";",trim(cnvtstring(edit_security_cd)),";",
      trim(cnvtstring(dnbr)))
    ENDIF
   ELSEIF (nvp.pvc_value="TRKGROUP*")
    beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0), new_pvc_value = substring(1,(
     end_pos - beg_pos),nvp.pvc_value),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), new_pvc_value = concat
    (trim(new_pvc_value),";",trim(cnvtstring(request->patient_filter_option)),",")
    IF ((((request->patient_filter_option=5)) OR ((request->patient_filter_option=4))) )
     new_pvc_value = concat(trim(new_pvc_value),trim(request->filter_from_date),",",trim(request->
       filter_to_date),",")
    ELSEIF ((((request->patient_filter_option=2)) OR ((request->patient_filter_option=1))) )
     new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->filter_time_unit)),",",trim(
       cnvtstring(request->filter_time)),",")
    ELSEIF ((request->patient_filter_option=3))
     new_pvc_value = concat(trim(new_pvc_value),"0,0,")
    ENDIF
    new_pvc_value = concat(trim(new_pvc_value),"0,0,0,0;"), beg_pos = (end_pos+ 1), end_pos =
    findstring(";",nvp.pvc_value,beg_pos,0),
    temp = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos =
    findstring(";",nvp.pvc_value,beg_pos,0),
    list_type_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos
    + 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    column_view_id = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
    end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    track_group_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
    end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    refresh_rate = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    filter_id = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1
    ), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    location_view_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
    end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    scroll_rate = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    loc_security_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
    end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
    edit_security_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
    end_pos+ 1), end_pos = findstring(" ",nvp.pvc_value,beg_pos,0),
    dnbr = cnvtint(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), new_pvc_value = concat(trim
     (new_pvc_value),trim(cnvtstring(temp)),";",trim(cnvtstring(list_type_cd)),";",
     trim(cnvtstring(column_view_id)),";",trim(cnvtstring(track_group_cd)),";",trim(refresh_rate),
     ";",trim(cnvtstring(request->custom_filter_id)),";",trim(cnvtstring(location_view_cd)),";",
     trim(scroll_rate),";",trim(cnvtstring(loc_security_cd)),";",trim(cnvtstring(edit_security_cd)),
     ";",trim(cnvtstring(dnbr)))
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM name_value_prefs nvp
  SET nvp.pvc_value = new_pvc_value, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id =
   reqinfo->updt_id,
   nvp.updt_task = reqinfo->updt_task, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_applctx = reqinfo->
   updt_applctx
  WHERE (nvp.name_value_prefs_id=request->name_value_prefs_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to update name_value_prefs for ",cnvtstring(request->
    name_value_prefs_id))
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = error_msg
  CALL echo(error_msg)
 ENDIF
 CALL echorecord(reply)
END GO
