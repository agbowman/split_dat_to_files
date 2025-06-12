CREATE PROGRAM ctp_core_locations_cls:dba
 CREATE CLASS get_unit_types FROM edcw_get_data_code_set_cls
 init
 DECLARE PRIVATE::codeset = i4 WITH constant(222)
 DECLARE PRIVATE::cdf_list = vc WITH constant(
  "NURSEUNIT|AMBULATORY|ANCILSURG|LAB|PHARM|APPTLOC|RAD|RETURNBIN")
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_room_types FROM edcw_get_data_code_set_cls
 init
 DECLARE PRIVATE::codeset = i4 WITH constant(222)
 DECLARE PRIVATE::cdf_list = vc WITH constant("TRANSPORT|WAITROOM|ROOM|CHECKOUT|PREARRIVAL|RETURNBIN"
  )
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_discipline FROM edcw_get_data_code_set_cls
 init
 DECLARE PRIVATE::codeset = i4 WITH constant(6000)
 END; class scope:init
 WITH copy = 1
 CREATE CLASS bed_get_facility_orgs FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 search_txt = vc
   1 search_type_flag = vc
   1 max_reply_limit = i2
   1 show_inactive_ind = i2
   1 load_bldg_cnt_ind = i2
   1 load_only_facs_with_units_ind = i2
   1 org_alias_pool_types[*]
     2 code_value = f8
   1 load_only_effective_facs_ind = i2
   1 honor_org_security_ind = i2
 )
 RECORD _::reply(
   1 facility[*]
     2 location_code_value = f8
     2 fac_short_description = vc
     2 fac_full_description = vc
     2 organization_id = f8
     2 bldg_cnt = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("bed_get_facility_list"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_facorg_data FROM edcw_get_data_cls
 init
 RECORD _::data(
   1 list[*]
     2 fac_cd = f8
     2 fac_display = vc
     2 fac_full_desc = vc
     2 org_id = f8
     2 org_name = vc
     2 pat_care_ind = i2
 )
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE GET::facorgslist = null WITH protect, class(bed_get_facility_orgs)
   IF ( NOT (GET::facorgslist.perform(0)))
    SET PRIVATE::err_msg = GET::facorgslist.geterror(0)
    RETURN(0)
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SET stat = alterlist(_::data->list,size(get::facorgslist.reply->facility,5))
   FOR (idx = 1 TO size(_::data->list,5))
     SET _::data->list[idx].fac_cd = get::facorgslist.reply->facility[idx].location_code_value
     SET _::data->list[idx].fac_display = get::facorgslist.reply->facility[idx].fac_short_description
     SET _::data->list[idx].fac_full_desc = get::facorgslist.reply->facility[idx].
     fac_full_description
     SET _::data->list[idx].org_id = get::facorgslist.reply->facility[idx].organization_id
   ENDFOR
   IF (size(_::data->list,5)=0)
    RETURN(1)
   ENDIF
   SET stat = copyrec(_::data,TMP::data)
   SELECT INTO "nl:"
    key_id = _::data->list[d.seq].fac_cd
    FROM (dummyt d  WITH seq = size(_::data->list,5))
    ORDER BY key_id
    HEAD REPORT
     cnt = 0, stat = alterlist(tmp::data->list,size(_::data->list,5))
    DETAIL
     cnt += 1, stat = movereclist(_::data->list,tmp::data->list,d.seq,cnt,1,
      0)
    FOOT REPORT
     stat = moverec(TMP::data,_::data)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM location l,
     organization o
    PLAN (l
     WHERE expand(idx,1,size(_::data->list,5),l.location_cd,_::data->list[idx].fac_cd))
     JOIN (o
     WHERE o.organization_id=l.organization_id)
    DETAIL
     pos = locatevalsort(idx,1,size(_::data->list,5),l.location_cd,_::data->list[idx].fac_cd)
     IF (pos > 0)
      _::data->list[pos].org_name = o.org_name, _::data->list[pos].pat_care_ind = l.patcare_node_ind
     ENDIF
    WITH nocounter, expand = 2
   ;end select
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_child_locs_data FROM edcw_get_data_cls
 init
 RECORD _::fltr(
   1 list[*]
     2 location = vc
 )
 RECORD _::data(
   1 list[*]
     2 loc_cd = f8
     2 loc_meaning = c12
     2 loc_meaning_cd = f8
     2 org_id = f8
     2 org_name = vc
     2 fac_cd = f8
     2 bld_cd = f8
     2 bld_seq = i4
     2 unit_cd = f8
     2 unit_type_cd = f8
     2 unit_seq = i4
     2 room_cd = f8
     2 room_seq = i4
     2 bed_cd = f8
     2 bed_seq = i4
     2 locations[*]
       3 child_loc_cd = f8
       3 child_ind = i2
       3 loc_status_ind = i2
       3 loc_active_ind = i2
       3 lg_status_ind = i2
       3 lg_active_ind = i2
       3 sequence = i4
       3 location_type_mean = c12
       3 location_type_cd = f8
 )
 DECLARE _::get(fltr_loc=i2,active_loc=i2) = i2
 SUBROUTINE _::get(fltr_loc,active_loc)
   DECLARE cs222_facility = vc WITH protect, constant("FACILITY")
   DECLARE cs222_building = vc WITH protect, constant("BUILDING")
   DECLARE cs222_nurseunit = vc WITH protect, constant("NURSEUNIT")
   DECLARE cs222_ambulatory = vc WITH protect, constant("AMBULATORY")
   DECLARE cs222_surgery = vc WITH protect, constant("ANCILSURG")
   DECLARE cs222_lab = vc WITH protect, constant("LAB")
   DECLARE cs222_pharm = vc WITH protect, constant("PHARM")
   DECLARE cs222_apptloc = vc WITH protect, constant("APPTLOC")
   DECLARE cs222_rad = vc WITH protect, constant("RAD")
   DECLARE cs222_rxreturn = vc WITH protect, constant("RETURNBIN")
   DECLARE cs222_room = vc WITH protect, constant("ROOM")
   DECLARE cs222_checkout = vc WITH protect, constant("CHECKOUT")
   DECLARE cs222_waitroom = vc WITH protect, constant("WAITROOM")
   DECLARE cs222_transport = vc WITH protect, constant("TRANSPORT")
   DECLARE cs222_prearrival = vc WITH protect, constant("PREARRIVAL")
   DECLARE cs222_bed = vc WITH protect, constant("BED")
   DECLARE cs48_deleted = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2673"))
   DECLARE loc_idx = i4 WITH protect, noconstant(0)
   DECLARE loc_sz = i4 WITH protect, noconstant(0)
   DECLARE loc_pos = i4 WITH protect, noconstant(0)
   DECLARE cur_logical_dm_cd = f8 WITH protect, noconstant(0.0)
   DECLARE chld_loc_cnt = i4 WITH protect, noconstant(0)
   DECLARE lookup_ndx = i4 WITH protect, noconstant(0)
   DECLARE lookup2_ndx = i4 WITH protect, noconstant(0)
   DECLARE loc_parser = vc WITH protect, noconstant("1=1")
   IF (active_loc=1)
    SET loc_parser = concat(loc_parser," and c.active_ind = 1")
   ENDIF
   SELECT INTO "nl:"
    p.logical_domain_id
    FROM prsnl p
    PLAN (p
     WHERE (p.person_id=reqinfo->updt_id)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     cur_logical_dm_cd = p.logical_domain_id
    WITH nocounter
   ;end select
   SET loc_sz = size(_::data->list,5)
   SELECT
    IF (fltr_loc=1)
     PLAN (lg1
      WHERE expand(loc_idx,1,loc_sz,lg1.parent_loc_cd,_::data->list[loc_idx].loc_cd,
       lg1.location_group_type_cd,_::data->list[loc_idx].loc_meaning_cd)
       AND lg1.root_loc_cd=0
       AND lg1.active_status_cd != cs48_deleted)
      JOIN (c
      WHERE c.code_value=lg1.child_loc_cd
       AND c.active_type_cd != cs48_deleted
       AND c.cdf_meaning IN (cs222_facility, cs222_building, cs222_nurseunit, cs222_ambulatory,
      cs222_surgery,
      cs222_lab, cs222_pharm, cs222_apptloc, cs222_rad, cs222_rxreturn,
      cs222_room, cs222_checkout, cs222_waitroom, cs222_transport, cs222_prearrival,
      cs222_bed)
       AND ((expand(lookup_ndx,1,size(_::fltr->list,5),cnvtupper(c.display),_::fltr->list[lookup_ndx]
       .location)) OR (expand(lookup2_ndx,1,size(_::fltr->list,5),cnvtupper(c.description),_::fltr->
       list[lookup2_ndx].location)))
       AND parser(loc_parser))
      JOIN (l
      WHERE l.location_cd=lg1.child_loc_cd)
      JOIN (o
      WHERE o.organization_id=l.organization_id
       AND ((o.logical_domain_id=cur_logical_dm_cd) OR (o.organization_id=0)) )
      JOIN (lg2
      WHERE (lg2.parent_loc_cd= Outerjoin(lg1.child_loc_cd))
       AND (lg2.root_loc_cd= Outerjoin(0))
       AND (lg2.active_status_cd!= Outerjoin(cs48_deleted)) )
    ELSE
    ENDIF
    INTO "nl:"
    parent_loc_cd = lg1.parent_loc_cd, chld_loc_cd = lg1.child_loc_cd, chld2_loc_cd = lg2
    .child_loc_cd
    FROM location_group lg1,
     location_group lg2,
     code_value c,
     location l,
     organization o
    PLAN (lg1
     WHERE expand(loc_idx,1,loc_sz,lg1.parent_loc_cd,_::data->list[loc_idx].loc_cd,
      lg1.location_group_type_cd,_::data->list[loc_idx].loc_meaning_cd)
      AND lg1.root_loc_cd=0
      AND lg1.active_status_cd != cs48_deleted)
     JOIN (c
     WHERE c.code_value=lg1.child_loc_cd
      AND c.active_type_cd != cs48_deleted
      AND c.cdf_meaning IN (cs222_facility, cs222_building, cs222_nurseunit, cs222_ambulatory,
     cs222_surgery,
     cs222_lab, cs222_pharm, cs222_apptloc, cs222_rad, cs222_rxreturn,
     cs222_room, cs222_checkout, cs222_waitroom, cs222_transport, cs222_prearrival,
     cs222_bed)
      AND parser(loc_parser))
     JOIN (l
     WHERE l.location_cd=lg1.child_loc_cd)
     JOIN (o
     WHERE o.organization_id=l.organization_id
      AND ((o.logical_domain_id=cur_logical_dm_cd) OR (o.organization_id=0)) )
     JOIN (lg2
     WHERE (lg2.parent_loc_cd= Outerjoin(lg1.child_loc_cd))
      AND (lg2.root_loc_cd= Outerjoin(0))
      AND (lg2.active_status_cd!= Outerjoin(cs48_deleted)) )
    ORDER BY parent_loc_cd, chld_loc_cd, chld2_loc_cd
    HEAD REPORT
     loc_pos = 0
    HEAD parent_loc_cd
     loc_pos = locateval(loc_idx,1,loc_sz,lg1.parent_loc_cd,_::data->list[loc_idx].loc_cd),
     chld_loc_cnt = 0
    HEAD lg1.child_loc_cd
     chld_loc_cnt += 1
     IF (chld_loc_cnt > size(_::data->list[loc_pos].locations,5))
      stat = alterlist(_::data->list[loc_pos].locations,(chld_loc_cnt+ 199))
     ENDIF
     _::data->list[loc_pos].locations[chld_loc_cnt].child_loc_cd = lg1.child_loc_cd, _::data->list[
     loc_pos].locations[chld_loc_cnt].sequence = lg1.sequence, _::data->list[loc_pos].locations[
     chld_loc_cnt].location_type_mean = c.cdf_meaning,
     _::data->list[loc_pos].locations[chld_loc_cnt].location_type_cd = uar_get_code_by("MEANING",222,
      trim(_::data->list[loc_pos].locations[chld_loc_cnt].location_type_mean,3)), _::data->list[
     loc_pos].locations[chld_loc_cnt].loc_active_ind = c.active_ind
     IF (c.active_ind=1
      AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND c.end_effective_dt_tm >= cnvtdatetime(sysdate))
      _::data->list[loc_pos].locations[chld_loc_cnt].loc_status_ind = 1
     ENDIF
     _::data->list[loc_pos].locations[chld_loc_cnt].lg_active_ind = lg1.active_ind
     IF (lg1.active_ind=1
      AND lg1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND lg1.end_effective_dt_tm >= cnvtdatetime(sysdate))
      _::data->list[loc_pos].locations[chld_loc_cnt].lg_status_ind = 1
     ENDIF
    DETAIL
     IF (lg2.parent_loc_cd > 0)
      _::data->list[loc_pos].locations[chld_loc_cnt].child_ind = 1
     ENDIF
    FOOT  lg1.child_loc_cd
     null
    FOOT  parent_loc_cd
     stat = alterlist(_::data->list[loc_pos].locations,chld_loc_cnt)
    WITH nocounter, expand = 2
   ;end select
   RETURN(1)
 END ;Subroutine
 DECLARE _::clear_rec(null) = i2
 SUBROUTINE _::clear_rec(null)
   SET stat = initrec(_::data)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_loc_addl_data FROM edcw_get_data_cls
 init
 RECORD _::data(
   1 list[*]
     2 loc_cd = f8
     2 in_census = i2
     2 discipline = f8
     2 is_ed = i2
     2 is_apache_icu = i2
     2 duplicate_bed = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM location l,
     bed b
    PLAN (l
     WHERE expand(idx,1,size(_::data->list,5),l.location_cd,_::data->list[idx].loc_cd))
     JOIN (b
     WHERE (b.location_cd= Outerjoin(l.location_cd)) )
    DETAIL
     pos = locatevalsort(idx,1,size(_::data->list,5),l.location_cd,_::data->list[idx].loc_cd)
     IF (pos > 0)
      _::data->list[pos].in_census = l.census_ind, _::data->list[pos].discipline = l
      .discipline_type_cd, _::data->list[pos].is_apache_icu = l.icu_ind,
      _::data->list[pos].beg_effective_dt_tm = l.beg_effective_dt_tm, _::data->list[pos].
      end_effective_dt_tm = l.end_effective_dt_tm, _::data->list[pos].duplicate_bed = b.dup_bed_ind
     ENDIF
    WITH nocounter, expand = 2
   ;end select
   SELECT INTO "nl:"
    FROM br_name_value br
    PLAN (br
     WHERE br.br_nv_key1="EDUNIT"
      AND br.br_name="CVFROMCS220"
      AND expand(idx,1,size(_::data->list,5),cnvtreal(br.br_value),_::data->list[idx].loc_cd))
    DETAIL
     pos = locatevalsort(idx,1,size(_::data->list,5),cnvtreal(br.br_value),_::data->list[idx].loc_cd)
     IF (pos > 0)
      _::data->list[pos].is_ed = 1
     ENDIF
    WITH nocounter, expand = 2
   ;end select
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_loc_tree FROM edcw_get_data_cls
 init
 RECORD _::loc_ref_tree(
   1 fac[*]
     2 org_id = f8
     2 org_name = vc
     2 fac_cd = f8
     2 fac_disp = vc
     2 bld[*]
       3 bld_cd = f8
       3 bld_disp = vc
       3 bld_begin_dt_tm = dq8
       3 bld_end_dt_tm = dq8
       3 bld_active_ind = i2
       3 bld_seq = i4
       3 units[*]
         4 unit_cd = f8
         4 unit_disp = vc
         4 unit_type_cd = f8
         4 unit_type_disp = vc
         4 unit_seq = i4
         4 unit_in_census = i2
         4 discipline = f8
         4 is_ed = i2
         4 is_apache_icu = i2
         4 unit_begin_dt_tm = dq8
         4 unit_end_dt_tm = dq8
         4 unit_active_ind = i2
         4 room_seq_start = i4
         4 rooms[*]
           5 room_cd = f8
           5 room_disp = vc
           5 room_type_cd = f8
           5 room_type_disp = vc
           5 room_seq = i4
           5 room_in_census = i2
           5 room_begin_dt_tm = dq8
           5 room_end_dt_tm = dq8
           5 room_active_ind = i2
           5 bed_seq_start = i4
           5 beds[*]
             6 bed_cd = f8
             6 bed_desc = vc
             6 bed_disp = vc
             6 bed_seq = i4
             6 bed_in_census = i2
             6 duplicate_bed = i2
             6 bed_begin_dt_tm = dq8
             6 bed_end_dt_tm = dq8
             6 bed_active_ind = i2
 )
 RECORD _::dup_loc_list(
   1 loc[*]
     2 org_name = vc
     2 fac_disp = vc
     2 bld_disp = vc
     2 unit_disp = vc
     2 unit_type_disp = vc
     2 room_disp = vc
     2 room_type_disp = vc
     2 bed_desc = vc
     2 dup_lvl = i4
 )
 RECORD _::ref_locations(
   1 reqin_sz = i4
   1 list[*]
     2 org_id = f8
     2 org_name = vc
     2 fac_cd = f8
     2 bld_cd = f8
     2 bld_begin_dt_tm = dq8
     2 bld_end_dt_tm = dq8
     2 bld_active_ind = i2
     2 bld_seq = i2
     2 unit_cd = f8
     2 unit_type_cd = f8
     2 unit_seq = i4
     2 unit_in_census = i2
     2 unit_discipline = f8
     2 unit_is_ed = i2
     2 unit_is_apache_icu = i2
     2 unit_begin_dt_tm = dq8
     2 unit_end_dt_tm = dq8
     2 unit_active_ind = i2
     2 room_cd = f8
     2 room_type_cd = f8
     2 room_seq = i4
     2 room_in_census = i2
     2 room_begin_dt_tm = dq8
     2 room_end_dt_tm = dq8
     2 room_active_ind = i2
     2 bed_cd = f8
     2 bed_seq = i4
     2 bed_in_census = i2
     2 duplicate_bed = i2
     2 bed_begin_dt_tm = dq8
     2 bed_end_dt_tm = dq8
     2 bed_active_ind = i2
     2 lowest_lvl_loc_cd = f8
     2 lowest_lvl_loc_type_cd = f8
     2 lowest_lvl_level = i4
     2 lowest_lvl_seq = i4
     2 loc_children_ind = i2
     2 loc_children_loaded_ind = i2
 )
 SUBROUTINE (_::load_facilityorglist(all_fac=i4) =i2)
   SET curalias facorg get::facorgs.data->list[d.seq]
   DECLARE lookup_ndx = i4 WITH protect, noconstant(0)
   DECLARE fac_parser = vc WITH protect, noconstant("1=1")
   DECLARE reqin_sz = i4 WITH protect, noconstant(_::ref_locations->reqin_sz)
   IF (all_fac=1)
    SET fac_parser = build(
     "expand(lookup_ndx, 1, reqin_sz, cnvtupper(uar_get_code_display(FACORG->fac_cd)),",
     "cnvtupper(trim(requestin->list_0[lookup_ndx].fac_display,3)))")
   ENDIF
   DECLARE GET::facorgs = null WITH protect, class(get_facorg_data)
   IF ( NOT (GET::facorgs.get(0)))
    SET PRIVATE::err_msg = GET::facorgs.geterror(0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(get::facorgs.data->list,5))
    PLAN (d
     WHERE parser(fac_parser))
    ORDER BY d.seq
    HEAD REPORT
     cnt = 0, stat = alterlist(_::ref_locations->list,size(get::facorgs.data->list,5))
    DETAIL
     cnt += 1, _::ref_locations->list[cnt].org_id = get::facorgs.data->list[d.seq].org_id, _::
     ref_locations->list[cnt].org_name = get::facorgs.data->list[d.seq].org_name,
     _::ref_locations->list[cnt].fac_cd = get::facorgs.data->list[d.seq].fac_cd, _::ref_locations->
     list[cnt].lowest_lvl_loc_cd = get::facorgs.data->list[d.seq].fac_cd, _::ref_locations->list[cnt]
     .lowest_lvl_loc_type_cd = cs222_facility,
     _::ref_locations->list[cnt].lowest_lvl_level = 1, _::ref_locations->list[cnt].loc_children_ind
      = 1
    FOOT REPORT
     stat = alterlist(_::ref_locations->list,cnt)
    WITH nocounter
   ;end select
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (_::load_locationtree(fltr_loc=i2,active_loc=i2) =i2 WITH protect)
   CALL echo("start load_LocationTree")
   SET curalias globalloc _::ref_locations->list[llt_loc_idx]
   SET curalias parentloc get::locations.data->list[llt_loc_idx]
   SET curalias childloc get::locations.data->list[llt_loc_idx].locations[llt_chldloc_idx]
   SET curalias savegloballoc _::ref_locations->list[ndx_start]
   DECLARE llt_loc_idx = i4 WITH protect, noconstant(0)
   DECLARE llt_loc_cnt = i4 WITH protect, noconstant(0)
   DECLARE llt_ref_loc_cnt = i4 WITH protect, noconstant(0)
   DECLARE local_load_chld_locs = i2 WITH protect, noconstant(1)
   DECLARE llt_fltr_idx = i4 WITH protect, noconstant(0)
   DECLARE llt_fltr_cnt = i4 WITH protect, noconstant(0)
   DECLARE llt_chldloc_idx = i4 WITH protect, noconstant(0)
   DECLARE llt_loc_loc_rec_sz = i4 WITH protect, noconstant(0)
   DECLARE loc_cnt = i4 WITH protect, noconstant(0)
   DECLARE chldloc_cnt = i4 WITH protect, noconstant(0)
   DECLARE ndx_start = i4 WITH protect, noconstant(0)
   DECLARE reqin_sz = i4 WITH protect, noconstant(_::ref_locations->reqin_sz)
   DECLARE GET::locations = null WITH protect, class(get_child_locs_data)
   FOR (llt_fltr_idx = 1 TO reqin_sz)
     IF (textlen(trim(requestin->list_0[llt_fltr_idx].bld_display,3)) > 0)
      SET llt_fltr_cnt += 1
      IF (llt_fltr_cnt > size(get::locations.fltr->list,5))
       SET stat = alterlist(get::locations.fltr->list,(llt_fltr_cnt+ 499))
      ENDIF
      SET get::locations.fltr->list[llt_fltr_cnt].location = cnvtupper(requestin->list_0[llt_fltr_idx
       ].bld_display)
     ENDIF
     IF (textlen(trim(requestin->list_0[llt_fltr_idx].unit_display,3)) > 0)
      SET llt_fltr_cnt += 1
      IF (llt_fltr_cnt > size(get::locations.fltr->list,5))
       SET stat = alterlist(get::locations.fltr->list,(llt_fltr_cnt+ 499))
      ENDIF
      SET get::locations.fltr->list[llt_fltr_cnt].location = cnvtupper(requestin->list_0[llt_fltr_idx
       ].unit_display)
     ENDIF
     IF (textlen(trim(requestin->list_0[llt_fltr_idx].rm_display,3)) > 0)
      SET llt_fltr_cnt += 1
      IF (llt_fltr_cnt > size(get::locations.fltr->list,5))
       SET stat = alterlist(get::locations.fltr->list,(llt_fltr_cnt+ 499))
      ENDIF
      SET get::locations.fltr->list[llt_fltr_cnt].location = cnvtupper(requestin->list_0[llt_fltr_idx
       ].rm_display)
     ENDIF
     IF (textlen(trim(requestin->list_0[llt_fltr_idx].bed_desc,3)) > 0)
      SET llt_fltr_cnt += 1
      IF (llt_fltr_cnt > size(get::locations.fltr->list,5))
       SET stat = alterlist(get::locations.fltr->list,(llt_fltr_cnt+ 499))
      ENDIF
      SET get::locations.fltr->list[llt_fltr_cnt].location = cnvtupper(requestin->list_0[llt_fltr_idx
       ].bed_desc)
     ENDIF
   ENDFOR
   SET stat = alterlist(get::locations.fltr->list,llt_fltr_cnt)
   WHILE (local_load_chld_locs != 0)
     SET local_load_chld_locs = 0
     SET llt_loc_cnt = 0
     CALL GET::locations.clear_rec(0)
     SET llt_ref_loc_cnt = size(_::ref_locations->list,5)
     FOR (llt_loc_idx = 1 TO llt_ref_loc_cnt)
       IF ((globalloc->loc_children_loaded_ind=0)
        AND (globalloc->loc_children_ind=1))
        SET llt_loc_cnt += 1
        IF (llt_loc_cnt > size(get::locations.data->list,5))
         SET stat = alterlist(get::locations.data->list,(llt_loc_cnt+ 99))
        ENDIF
        SET get::locations.data->list[llt_loc_cnt].loc_cd = globalloc->lowest_lvl_loc_cd
        SET get::locations.data->list[llt_loc_cnt].loc_meaning = uar_get_code_meaning(globalloc->
         lowest_lvl_loc_type_cd)
        SET get::locations.data->list[llt_loc_cnt].loc_meaning_cd = uar_get_code_by("MEANING",222,
         trim(get::locations.data->list[llt_loc_cnt].loc_meaning,3))
        SET get::locations.data->list[llt_loc_cnt].org_id = globalloc->org_id
        SET get::locations.data->list[llt_loc_cnt].org_name = globalloc->org_name
        SET get::locations.data->list[llt_loc_cnt].fac_cd = globalloc->fac_cd
        SET get::locations.data->list[llt_loc_cnt].bld_cd = globalloc->bld_cd
        SET get::locations.data->list[llt_loc_cnt].bld_seq = globalloc->bld_seq
        SET get::locations.data->list[llt_loc_cnt].unit_cd = globalloc->unit_cd
        SET get::locations.data->list[llt_loc_cnt].unit_type_cd = globalloc->unit_type_cd
        SET get::locations.data->list[llt_loc_cnt].unit_seq = globalloc->unit_seq
        SET get::locations.data->list[llt_loc_cnt].room_cd = globalloc->room_cd
        SET get::locations.data->list[llt_loc_cnt].room_seq = globalloc->room_seq
        SET get::locations.data->list[llt_loc_cnt].bed_cd = globalloc->bed_cd
        SET get::locations.data->list[llt_loc_cnt].bed_seq = globalloc->bed_seq
        SET globalloc->loc_children_loaded_ind = 1
       ENDIF
     ENDFOR
     SET stat = alterlist(get::locations.data->list,llt_loc_cnt)
     IF ( NOT (GET::locations.get(fltr_loc,active_loc)))
      SET PRIVATE::err_msg = GET::locations.geterror(0)
      RETURN(0)
     ENDIF
     SET llt_chldloc_idx = 0
     SET llt_loc_loc_rec_sz = 0
     SET loc_cnt = 0
     SET chldloc_cnt = 0
     SET ndx_start = size(_::ref_locations->list,5)
     SET loc_cnt = size(get::locations.data->list,5)
     FOR (llt_loc_idx = 1 TO loc_cnt)
       SET chldloc_cnt = size(get::locations.data->list[llt_loc_idx].locations,5)
       SET llt_loc_loc_rec_sz = (size(_::ref_locations->list,5)+ size(get::locations.data->list[
        llt_loc_idx].locations,5))
       SET stat = alterlist(_::ref_locations->list,llt_loc_loc_rec_sz)
       FOR (llt_chldloc_idx = 1 TO chldloc_cnt)
         SET ndx_start += 1
         SET savegloballoc->org_id = parentloc->org_id
         SET savegloballoc->org_name = parentloc->org_name
         SET savegloballoc->fac_cd = parentloc->fac_cd
         SET savegloballoc->bld_cd = parentloc->bld_cd
         SET savegloballoc->bld_seq = parentloc->bld_seq
         SET savegloballoc->unit_type_cd = parentloc->unit_type_cd
         SET savegloballoc->unit_cd = parentloc->unit_cd
         SET savegloballoc->unit_seq = parentloc->unit_seq
         SET savegloballoc->room_cd = parentloc->room_cd
         SET savegloballoc->room_seq = parentloc->room_seq
         SET savegloballoc->bed_cd = parentloc->bed_cd
         SET savegloballoc->bed_seq = parentloc->bed_seq
         SET savegloballoc->lowest_lvl_loc_cd = childloc->child_loc_cd
         SET savegloballoc->lowest_lvl_loc_type_cd = childloc->location_type_cd
         SET savegloballoc->lowest_lvl_seq = childloc->sequence
         SET savegloballoc->loc_children_ind = childloc->child_ind
         IF ((childloc->child_ind=1))
          SET local_load_chld_locs = 1
         ENDIF
         CASE (savegloballoc->lowest_lvl_loc_type_cd)
          OF cs222_building:
           SET savegloballoc->bld_cd = savegloballoc->lowest_lvl_loc_cd
           SET savegloballoc->bld_seq = savegloballoc->lowest_lvl_seq
           SET savegloballoc->bld_active_ind = childloc->loc_active_ind
           SET savegloballoc->lowest_lvl_level = 2
          OF cs222_nurseunit:
          OF cs222_ambulatory:
          OF cs222_surgery:
          OF cs222_lab:
          OF cs222_pharm:
          OF cs222_apptloc:
          OF cs222_rad:
           SET savegloballoc->unit_cd = savegloballoc->lowest_lvl_loc_cd
           SET savegloballoc->unit_type_cd = savegloballoc->lowest_lvl_loc_type_cd
           SET savegloballoc->unit_seq = savegloballoc->lowest_lvl_seq
           SET savegloballoc->unit_active_ind = childloc->loc_active_ind
           SET savegloballoc->lowest_lvl_level = 3
          OF cs222_transport:
          OF cs222_waitroom:
          OF cs222_checkout:
          OF cs222_prearrival:
          OF cs222_room:
           SET savegloballoc->room_cd = savegloballoc->lowest_lvl_loc_cd
           SET savegloballoc->room_type_cd = savegloballoc->lowest_lvl_loc_type_cd
           SET savegloballoc->room_seq = savegloballoc->lowest_lvl_seq
           SET savegloballoc->room_active_ind = childloc->loc_active_ind
           SET savegloballoc->lowest_lvl_level = 4
          OF cs222_bed:
           SET savegloballoc->bed_cd = savegloballoc->lowest_lvl_loc_cd
           SET savegloballoc->bed_seq = savegloballoc->lowest_lvl_seq
           SET savegloballoc->bed_active_ind = childloc->loc_active_ind
           SET savegloballoc->lowest_lvl_level = 5
          OF cs222_rxreturn:
           IF ((parentloc->unit_cd > 0))
            SET savegloballoc->room_cd = savegloballoc->lowest_lvl_loc_cd
            SET savegloballoc->room_type_cd = savegloballoc->lowest_lvl_loc_type_cd
            SET savegloballoc->room_seq = savegloballoc->lowest_lvl_seq
            SET savegloballoc->room_active_ind = childloc->loc_active_ind
            SET savegloballoc->lowest_lvl_level = 4
           ELSE
            SET savegloballoc->unit_cd = savegloballoc->lowest_lvl_loc_cd
            SET savegloballoc->unit_type_cd = savegloballoc->lowest_lvl_loc_type_cd
            SET savegloballoc->unit_seq = savegloballoc->lowest_lvl_seq
            SET savegloballoc->unit_active_ind = childloc->loc_active_ind
            SET savegloballoc->lowest_lvl_level = 3
           ENDIF
         ENDCASE
       ENDFOR
     ENDFOR
   ENDWHILE
   SET stat = copyrec(_::ref_locations,TMP::locdata)
   SELECT INTO "nl:"
    loc_cd = _::ref_locations->list[d.seq].lowest_lvl_loc_cd
    FROM (dummyt d  WITH seq = size(_::ref_locations->list,5))
    ORDER BY loc_cd
    HEAD REPORT
     cnt = 0, stat = alterlist(tmp::locdata->list,size(_::ref_locations->list,5))
    DETAIL
     cnt += 1, stat = movereclist(_::ref_locations->list,tmp::locdata->list,d.seq,cnt,1,
      0)
    FOOT REPORT
     stat = moverec(TMP::locdata,_::ref_locations)
    WITH nocounter
   ;end select
   SET curalias globalloc _::ref_locations->list[llt_loc_idx]
   SET curalias addlinfo get::addlloc.data->list[llt_loc_idx]
   DECLARE GET::addlloc = null WITH protect, class(get_loc_addl_data)
   SET stat = alterlist(get::addlloc.data->list,size(_::ref_locations->list,5))
   FOR (llt_loc_idx = 1 TO size(_::ref_locations->list,5))
     SET addlinfo->loc_cd = globalloc->lowest_lvl_loc_cd
   ENDFOR
   IF ( NOT (GET::addlloc.get(0)))
    SET PRIVATE::err_msg = GET::addlloc.geterror(0)
    RETURN(0)
   ENDIF
   SET loc_cnt = size(get::addlloc.data->list,5)
   FOR (llt_loc_idx = 1 TO loc_cnt)
     CASE (globalloc->lowest_lvl_loc_type_cd)
      OF cs222_building:
       SET globalloc->bld_begin_dt_tm = addlinfo->beg_effective_dt_tm
       SET globalloc->bld_end_dt_tm = addlinfo->end_effective_dt_tm
      OF cs222_nurseunit:
      OF cs222_ambulatory:
      OF cs222_surgery:
      OF cs222_lab:
      OF cs222_pharm:
      OF cs222_apptloc:
      OF cs222_rad:
       SET globalloc->unit_begin_dt_tm = addlinfo->beg_effective_dt_tm
       SET globalloc->unit_end_dt_tm = addlinfo->end_effective_dt_tm
       SET globalloc->unit_discipline = addlinfo->discipline
       SET globalloc->unit_is_ed = addlinfo->is_ed
       SET globalloc->unit_is_apache_icu = addlinfo->is_apache_icu
       SET globalloc->unit_in_census = addlinfo->in_census
      OF cs222_transport:
      OF cs222_waitroom:
      OF cs222_checkout:
      OF cs222_prearrival:
      OF cs222_room:
       SET globalloc->room_begin_dt_tm = addlinfo->beg_effective_dt_tm
       SET globalloc->room_end_dt_tm = addlinfo->end_effective_dt_tm
       SET globalloc->room_in_census = addlinfo->in_census
      OF cs222_bed:
       SET globalloc->bed_begin_dt_tm = addlinfo->beg_effective_dt_tm
       SET globalloc->bed_end_dt_tm = addlinfo->end_effective_dt_tm
       SET globalloc->bed_in_census = addlinfo->in_census
       SET globalloc->duplicate_bed = addlinfo->duplicate_bed
      OF cs222_rxreturn:
       IF ((globalloc->lowest_lvl_level=3))
        SET globalloc->unit_begin_dt_tm = addlinfo->beg_effective_dt_tm
        SET globalloc->unit_end_dt_tm = addlinfo->end_effective_dt_tm
       ELSE
        SET globalloc->room_begin_dt_tm = addlinfo->beg_effective_dt_tm
        SET globalloc->room_end_dt_tm = addlinfo->end_effective_dt_tm
       ENDIF
     ENDCASE
   ENDFOR
   CALL echo("exit load_LocationTree")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (_::load_fullloctree(sort_type=i2) =i2 WITH protect)
   CALL echo("start load_FullLocTree")
   SET curalias globalloc2 _::ref_locations->list[d.seq]
   SET curalias locfac _::loc_ref_tree->fac[fac_cnt]
   SET curalias locbld _::loc_ref_tree->fac[fac_cnt].bld[bld_cnt]
   SET curalias locnu _::loc_ref_tree->fac[fac_cnt].bld[bld_cnt].units[nu_cnt]
   SET curalias locrm _::loc_ref_tree->fac[fac_cnt].bld[bld_cnt].units[nu_cnt].rooms[rm_cnt]
   SET curalias locbed _::loc_ref_tree->fac[fac_cnt].bld[bld_cnt].units[nu_cnt].rooms[rm_cnt].beds[
   bed_cnt]
   SET curalias duploc _::dup_loc_list->loc[dup_cnt]
   DECLARE disp_sort = i4 WITH protect, constant(1)
   DECLARE disp_cd_sort = i4 WITH protect, constant(0)
   DECLARE lookup_ndx = i4 WITH protect, noconstant(0)
   DECLARE fac_pos = i4 WITH protect, noconstant(0)
   DECLARE bld_pos = i4 WITH protect, noconstant(0)
   DECLARE unit_pos = i4 WITH protect, noconstant(0)
   DECLARE rm_pos = i4 WITH protect, noconstant(0)
   CALL echo("sort load_FullLocTree")
   SELECT
    IF (sort_type=disp_sort)
     fac_sort = build(cnvtupper(uar_get_code_display(globalloc2->fac_cd)),char(0),globalloc2->fac_cd),
     bld_sort1 = cnvtupper(uar_get_code_display(globalloc2->bld_cd)), bld_sort2 = globalloc2->bld_cd,
     nu_sort1 = cnvtupper(build(uar_get_code_display(globalloc2->unit_type_cd),uar_get_code_display(
        globalloc2->unit_cd))), nu_sort2 = globalloc2->unit_cd, rm_sort1 = cnvtupper(build(
       uar_get_code_display(globalloc2->room_type_cd),uar_get_code_display(globalloc2->room_cd))),
     rm_sort2 = globalloc2->room_cd, bed_sort1 = cnvtupper(uar_get_code_display(globalloc2->bed_cd)),
     bed_sort2 = globalloc2->bed_cd,
     loc_level = globalloc2->lowest_lvl_level
    ELSEIF (sort_type=disp_cd_sort)
     fac_sort = globalloc2->fac_cd, bld_sort1 = globalloc2->bld_seq, bld_sort2 = globalloc2->bld_cd,
     nu_sort1 = globalloc2->unit_seq, nu_sort2 = globalloc2->unit_cd, rm_sort1 = globalloc2->room_seq,
     rm_sort2 = globalloc2->room_cd, bed_sort1 = globalloc2->bed_seq, bed_sort2 = globalloc2->bed_cd,
     loc_level = globalloc2->lowest_lvl_level
    ELSE
    ENDIF
    INTO "nl:"
    FROM (dummyt d  WITH seq = size(_::ref_locations->list,5))
    ORDER BY loc_level, fac_sort, bld_sort1,
     bld_sort2, nu_sort1, nu_sort2,
     rm_sort1, rm_sort2, bed_sort1,
     bed_sort2
    HEAD REPORT
     fac_cnt = 0
    HEAD loc_level
     null
    HEAD fac_sort
     IF (loc_level=1)
      bld_cnt = 0, fac_cnt += 1
      IF (fac_cnt > size(_::loc_ref_tree->fac,5))
       stat = alterlist(_::loc_ref_tree->fac,(fac_cnt+ 29))
      ENDIF
      locfac->org_id = globalloc2->org_id, locfac->org_name = globalloc2->org_name, locfac->fac_cd =
      globalloc2->fac_cd,
      locfac->fac_disp = uar_get_code_display(globalloc2->fac_cd)
     ELSE
      fac_pos = locateval(lookup_ndx,1,size(_::loc_ref_tree->fac,5),globalloc2->fac_cd,_::
       loc_ref_tree->fac[lookup_ndx].fac_cd)
      IF (fac_pos > 0)
       fac_cnt = fac_pos, bld_cnt = size(locfac->bld,5)
      ENDIF
     ENDIF
    HEAD bld_sort2
     IF (loc_level=2)
      nu_cnt = 0
      IF (bld_sort2 > 0
       AND fac_cnt > 0)
       bld_cnt += 1
       IF (bld_cnt > size(locfac->bld,5))
        stat = alterlist(locfac->bld,(bld_cnt+ 9))
       ENDIF
       locbld->bld_cd = globalloc2->bld_cd, locbld->bld_disp = uar_get_code_display(globalloc2->
        bld_cd), locbld->bld_begin_dt_tm = globalloc2->bld_begin_dt_tm,
       locbld->bld_end_dt_tm = globalloc2->bld_end_dt_tm, locbld->bld_active_ind = globalloc2->
       bld_active_ind, locbld->bld_seq = globalloc2->bld_seq
      ENDIF
     ELSE
      bld_pos = locateval(lookup_ndx,1,size(locfac->bld,5),globalloc2->bld_cd,locfac->bld[lookup_ndx]
       .bld_cd)
      IF (bld_pos > 0)
       bld_cnt = bld_pos, nu_cnt = size(locbld->units,5)
      ENDIF
     ENDIF
    HEAD nu_sort2
     IF (loc_level=3)
      rm_cnt = 0
      IF (nu_sort2 > 0
       AND bld_sort2 > 0
       AND fac_cnt > 0)
       nu_cnt += 1
       IF (nu_cnt > size(locbld->units,5))
        stat = alterlist(locbld->units,(nu_cnt+ 99))
       ENDIF
       locnu->unit_cd = globalloc2->unit_cd, locnu->unit_disp = uar_get_code_display(globalloc2->
        unit_cd), locnu->unit_type_cd = globalloc2->unit_type_cd,
       locnu->unit_type_disp = uar_get_code_display(globalloc2->unit_type_cd), locnu->unit_seq =
       globalloc2->unit_seq, locnu->unit_in_census = globalloc2->unit_in_census,
       locnu->discipline = globalloc2->unit_discipline, locnu->is_ed = globalloc2->unit_is_ed, locnu
       ->is_apache_icu = globalloc2->unit_is_apache_icu,
       locnu->unit_begin_dt_tm = globalloc2->unit_begin_dt_tm, locnu->unit_end_dt_tm = globalloc2->
       unit_end_dt_tm, locnu->unit_active_ind = globalloc2->unit_active_ind
      ENDIF
     ELSE
      unit_pos = locateval(lookup_ndx,1,size(locbld->units,5),globalloc2->unit_cd,locbld->units[
       lookup_ndx].unit_cd)
      IF (unit_pos > 0)
       nu_cnt = unit_pos, rm_cnt = size(locnu->rooms,5)
      ENDIF
     ENDIF
    HEAD rm_sort2
     IF (loc_level=4)
      bed_cnt = 0
      IF (rm_sort2 > 0
       AND nu_sort2 > 0
       AND bld_sort2 > 0
       AND fac_cnt > 0)
       rm_cnt += 1
       IF (rm_cnt > size(locnu->rooms,5))
        stat = alterlist(locnu->rooms,(rm_cnt+ 24))
       ENDIF
       locrm->room_cd = globalloc2->room_cd, locrm->room_disp = uar_get_code_display(globalloc2->
        room_cd), locrm->room_type_cd = globalloc2->room_type_cd,
       locrm->room_type_disp = uar_get_code_display(globalloc2->room_type_cd), locrm->room_seq =
       globalloc2->room_seq, locrm->room_in_census = globalloc2->room_in_census,
       locrm->room_begin_dt_tm = globalloc2->room_begin_dt_tm, locrm->room_end_dt_tm = globalloc2->
       room_end_dt_tm, locrm->room_active_ind = globalloc2->room_active_ind
       IF ((globalloc2->room_seq > locnu->room_seq_start))
        locnu->room_seq_start = globalloc2->room_seq
       ENDIF
      ENDIF
     ELSE
      rm_pos = locateval(lookup_ndx,1,size(locnu->rooms,5),globalloc2->room_cd,locnu->rooms[
       lookup_ndx].room_cd)
      IF (rm_pos > 0)
       rm_cnt = rm_pos, bed_cnt = size(locrm->beds,5)
      ENDIF
     ENDIF
    HEAD bed_sort2
     IF (loc_level=5
      AND bed_sort2 > 0
      AND rm_sort2 > 0
      AND nu_sort2 > 0
      AND bld_sort2 > 0
      AND fac_cnt > 0)
      bed_cnt += 1
      IF (bed_cnt > size(locrm->beds,5))
       stat = alterlist(locrm->beds,(bed_cnt+ 24))
      ENDIF
      locbed->bed_cd = globalloc2->bed_cd, locbed->bed_disp = uar_get_code_display(globalloc2->bed_cd
       ), locbed->bed_desc = uar_get_code_description(globalloc2->bed_cd),
      locbed->bed_seq = globalloc2->bed_seq, locbed->bed_in_census = globalloc2->bed_in_census,
      locbed->duplicate_bed = globalloc2->duplicate_bed,
      locbed->bed_begin_dt_tm = globalloc2->bed_begin_dt_tm, locbed->bed_end_dt_tm = globalloc2->
      bed_end_dt_tm, locbed->bed_active_ind = globalloc2->bed_active_ind
      IF ((globalloc2->bed_seq > locrm->bed_seq_start))
       locrm->bed_seq_start = globalloc2->bed_seq
      ENDIF
     ENDIF
    DETAIL
     null
    FOOT  bed_sort2
     null
    FOOT  rm_sort2
     IF (bed_cnt > 0
      AND loc_level=5)
      stat = alterlist(locrm->beds,bed_cnt)
     ENDIF
    FOOT  nu_sort2
     IF (rm_cnt > 0
      AND loc_level=4)
      stat = alterlist(locnu->rooms,rm_cnt)
     ENDIF
    FOOT  bld_sort2
     IF (nu_cnt > 0
      AND loc_level=3)
      stat = alterlist(locbld->units,nu_cnt)
     ENDIF
    FOOT  fac_sort
     IF (bld_cnt > 0
      AND loc_level=2)
      stat = alterlist(locfac->bld,bld_cnt)
     ENDIF
    FOOT  loc_level
     IF (fac_cnt > 0
      AND loc_level=1)
      stat = alterlist(_::loc_ref_tree->fac,fac_cnt)
     ENDIF
    FOOT REPORT
     null
    WITH nocounter
   ;end select
   CALL echo("duplicate load_FullLocTree")
   SELECT INTO "nl:"
    dup_sort = cnvtupper(build(uar_get_code_display(globalloc2->fac_cd),"|",uar_get_code_display(
       globalloc2->bld_cd),"|",uar_get_code_display(globalloc2->unit_type_cd),
      "|",uar_get_code_display(globalloc2->unit_cd),"|",uar_get_code_display(globalloc2->room_type_cd
       ),"|",
      uar_get_code_display(globalloc2->room_cd),"|",uar_get_code_display(globalloc2->bed_cd))),
    bld_cd = globalloc2->bld_cd, nu_cd = globalloc2->unit_cd,
    rm_cd = globalloc2->room_cd, bed_cd = globalloc2->bed_cd, loc_level = globalloc2->
    lowest_lvl_level
    FROM (dummyt d  WITH seq = size(_::ref_locations->list,5))
    ORDER BY dup_sort
    HEAD REPORT
     dup_cnt = 0
    HEAD dup_sort
     dup_sort_cnt = 0
    DETAIL
     dup_sort_cnt += 1
    FOOT  dup_sort
     IF (dup_sort_cnt > 1)
      dup_cnt += 1
      IF (dup_cnt > size(_::dup_loc_list->loc,5))
       stat = alterlist(_::dup_loc_list->loc,(dup_cnt+ 24))
      ENDIF
      duploc->org_name = globalloc2->org_name, duploc->fac_disp = cnvtupper(uar_get_code_display(
        globalloc2->fac_cd)), duploc->bld_disp = cnvtupper(uar_get_code_display(globalloc2->bld_cd)),
      duploc->unit_disp = cnvtupper(uar_get_code_display(globalloc2->unit_cd)), duploc->
      unit_type_disp = cnvtupper(uar_get_code_display(globalloc2->unit_type_cd)), duploc->room_disp
       = cnvtupper(uar_get_code_display(globalloc2->room_cd)),
      duploc->room_type_disp = cnvtupper(uar_get_code_display(globalloc2->room_type_cd)), duploc->
      bed_desc = cnvtupper(uar_get_code_description(globalloc2->bed_cd)), duploc->dup_lvl =
      globalloc2->lowest_lvl_level
     ENDIF
    FOOT REPORT
     stat = alterlist(_::dup_loc_list->loc,dup_cnt)
    WITH nocounter
   ;end select
   CALL echo("end load_FullLocTree")
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS loc_get_cs_max_seq FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 code_set = i4
   1 cdf_meaning = vc
 )
 RECORD _::reply(
   1 max_coll_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("loc_get_cs_max_coll_seq"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS add_location FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 qual[*]
     2 resource_ind = i2
     2 active_ind = i2
     2 census_ind = i2
     2 organization_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 description = vc
     2 short_desc = vc
     2 cdf_meaning = vc
     2 discipline_type_cd = f8
     2 definition = vc
     2 patcare_node_ind = i2
     2 collation_seq = i4
     2 transmit_outbound_order_ind = i2
     2 med_service_cd = f8
     2 tray_type_cd = f8
     2 rack_type_cd = f8
     2 atd_req_loc = i4
     2 cart_qty_ind = i2
     2 dispense_window = i4
     2 class_cd = f8
     2 fixed_bed_ind = i2
     2 number_fixed_beds = i4
     2 isolation_cd = f8
     2 loc_building_cd = f8
     2 loc_facility_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 tag_value = i4
     2 contributor_source_cd = f8
     2 ref_lab_acct_nbr = vc
     2 reserve_ind = i2
     2 comp_type_cd = f8
     2 transfer_dt_tm_ind = i2
     2 packing_list = vc
 )
 RECORD _::reply(
   1 qual[*]
     2 location_cd = f8
     2 description = vc
     2 tag_value = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("loc_add_location"))
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(1)
 END; class scope:init
 WITH copy = 1
 CREATE CLASS loc_get_loc_group_max_seq FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 parent_loc_cd = f8
   1 location_group_type_mean = vc
   1 root_loc_cd = f8
 )
 RECORD _::reply(
   1 max_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("loc_get_loc_group_max_seq"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS loc_add_loc_parent_child_r FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 qual[*]
     2 parent_loc_cd = f8
     2 child_loc_cd = f8
     2 cdf_meaning = vc
     2 root_loc_cd = f8
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 sequence = i4
 )
 RECORD _::reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("loc_add_loc_parent_child_r"))
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(1)
 END; class scope:init
 WITH copy = 1
 CREATE CLASS loc_add_serv_res FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 qual[*]
     2 location_cd = f8
     2 specimen_login_cd = f8
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 description = vc
     2 short_desc = vc
     2 cdf_meaning = vc
     2 root_service_resource_cd = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 discipline_type_cd = f8
     2 definition = vc
     2 organization_id = f8
     2 collation_seq = i4
     2 charge_cost_ratio = i4
     2 reimbursement_cost_ratio = i4
     2 transcript_que_cd = f8
     2 temp_multi_flag = i2
     2 nbr_exam_on_req = i4
     2 prelim_ind = i2
     2 expedite_nursing_ind = i2
     2 unread_films_ind = i2
     2 chk_diff_borr_ind = i2
     2 daily_folder_ind = i2
     2 folder_nbr_format_cd = f8
     2 return_loc_flag = i2
     2 lib_ind = i2
     2 purge_lib_ind = i2
     2 filing_method_cd = f8
     2 pull_list_by_sect_ind = i2
     2 inventory_resource_cd = f8
     2 pat_care_loc_ind = i2
     2 pharmacy_type_cd = f8
     2 rx_loc_type = i4
     2 rx_license = vc
     2 rx_code = vc
     2 nabp_nbr = vc
     2 mobile_cart = vc
     2 mobile_reorder_loc_cd = f8
     2 dispense_ind = i2
     2 supply_ind = i2
     2 atd_req_ind = i2
     2 rx_charge_ind = i2
     2 bb_device_type = i4
     2 bb_prod_ind = i2
     2 bb_monitored_temp_hi = f8
     2 bb_monitored_temp_lo = f8
     2 bb_barcode_id = f8
     2 location_type = i4
     2 primary_vendor = i4
     2 primary_fill_location = i4
     2 worklist_build_flag = i2
     2 worklist_hours = i4
     2 worklist_max = i4
     2 container_ind = i2
     2 gate_ind = i2
     2 autologin_ind = i2
     2 dispatch_download_ind = i2
     2 multiplexor_ind = i2
     2 strt_model_id = f8
     2 instr_identifier = i4
     2 point_of_care_flag = i2
     2 identifier_flag = i2
     2 auto_verify_flag = i2
     2 instr_alias = vc
     2 tax_payer_nbr = vc
     2 min_order_cost = f8
     2 master_account_nbr = vc
     2 comments = vc
     2 approved_vendor_status_cd = f8
     2 vendor_number = i4
     2 vendor_type_cd = f8
     2 auto_commit_po_ind = i2
     2 auto_commit_receipt_ind = i2
     2 acknowledgement_ind = i2
     2 output_dest_id = f8
     2 tax_exempt_ind = i2
     2 consolidate_rqstn_ind = i2
     2 blind_receipt_ind = i2
     2 manual_receipt_ind = i2
     2 allow_overshipments_ind = i2
     2 ack_variance_percent = f8
     2 ack_variance_amount = f8
     2 po_max_lines = i4
     2 allow_backorders_ind = i2
     2 accn_site_prefix = vc
     2 inv_location_cd = f8
     2 floorstock_ind = i2
     2 eso_tpn_cmpd_ind = i2
     2 eso_dose_msg_ind = i2
     2 eso_ingred_ind = i2
     2 autm_dspns_machn_cd = f8
     2 mpps_start_ind = i2
     2 mpps_reset_ind = i2
     2 clia_number = vc
     2 medical_director_name = vc
     2 examonly_hold_time_hrs = i2
 )
 RECORD _::reply(
   1 qual[*]
     2 service_resource_cd = f8
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("loc_add_serv_res"))
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(1)
 END; class scope:init
 WITH copy = 1
 CREATE CLASS add_child_loc FROM edcw_get_data_cls
 init
 RECORD _::data(
   1 list[1]
     2 org_id = f8
     2 loc_fac_cd = f8
     2 parent_loc_meaning_cd = f8
     2 parent_loc_cd = f8
     2 chld_loc_display = vc
     2 chld_loc_desc = vc
     2 chld_loc_meaning_cd = f8
     2 chld_loc_start_dt = dq8
     2 chld_loc_end_dt = dq8
     2 chld_loc_census_ind = i2
     2 chld_loc_discipline_type_cd = i2
     2 chld_loc_cd = f8
     2 chld_loc_seq = i4
     2 chld_loc_reltn_seq = i4
 )
 DECLARE _::add_loc(null) = i2
 SUBROUTINE _::add_loc(null)
   SET curalias chldloc _::data->list[1]
   DECLARE LOC::chld_loc_get_cs_seq = null WITH protect, class(loc_get_cs_max_seq)
   DECLARE LOC::chld_loc_add = null WITH protect, class(add_location)
   DECLARE LOC::chld_loc_get_reln_seq = null WITH protect, class(loc_get_loc_group_max_seq)
   DECLARE LOC::chld_loc_add_loc_reltn = null WITH protect, class(loc_add_loc_parent_child_r)
   DECLARE cs222_building = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2843"))
   DECLARE cs222_nurseunit = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2845"))
   DECLARE cs222_ambulatory = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!9458"))
   DECLARE cs222_apptloc = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!11420"))
   CALL LOC::chld_loc_get_cs_seq.initialize(0)
   SET loc::chld_loc_get_cs_seq.request->code_set = 220
   SET loc::chld_loc_get_cs_seq.request->cdf_meaning = uar_get_code_meaning(chldloc->
    chld_loc_meaning_cd)
   IF ( NOT (LOC::chld_loc_get_cs_seq.perform(0)))
    SET PRIVATE::err_msg = LOC::chld_loc_get_cs_seq.geterror(0)
    RETURN(0)
   ENDIF
   SET chldloc->chld_loc_seq = (loc::chld_loc_get_cs_seq.reply->max_coll_seq+ 1)
   CALL LOC::chld_loc_add.initialize(0)
   SET stat = alterlist(loc::chld_loc_add.request->qual,1)
   SET loc::chld_loc_add.request->qual[1].active_ind = 1
   SET loc::chld_loc_add.request->qual[1].organization_id = chldloc->org_id
   SET loc::chld_loc_add.request->qual[1].beg_effective_dt_tm = chldloc->chld_loc_start_dt
   SET loc::chld_loc_add.request->qual[1].end_effective_dt_tm = chldloc->chld_loc_end_dt
   SET loc::chld_loc_add.request->qual[1].description = chldloc->chld_loc_desc
   SET loc::chld_loc_add.request->qual[1].short_desc = chldloc->chld_loc_display
   SET loc::chld_loc_add.request->qual[1].cdf_meaning = uar_get_code_meaning(chldloc->
    chld_loc_meaning_cd)
   SET loc::chld_loc_add.request->qual[1].collation_seq = chldloc->chld_loc_seq
   SET loc::chld_loc_add.request->qual[1].census_ind = chldloc->chld_loc_census_ind
   SET loc::chld_loc_add.request->qual[1].discipline_type_cd = chldloc->chld_loc_discipline_type_cd
   CASE (chldloc->chld_loc_meaning_cd)
    OF cs222_building:
     SET loc::chld_loc_add.request->qual[1].loc_facility_cd = chldloc->parent_loc_cd
    OF cs222_nurseunit:
    OF cs222_ambulatory:
    OF cs222_apptloc:
     SET loc::chld_loc_add.request->qual[1].loc_building_cd = chldloc->parent_loc_cd
     SET loc::chld_loc_add.request->qual[1].loc_facility_cd = chldloc->loc_fac_cd
   ENDCASE
   IF ( NOT (LOC::chld_loc_add.perform(0)))
    SET PRIVATE::err_msg = LOC::chld_loc_add.geterror(0)
    RETURN(0)
   ENDIF
   SET chldloc->chld_loc_cd = loc::chld_loc_add.reply->qual[1].location_cd
   CALL LOC::chld_loc_get_reln_seq.initialize(0)
   SET loc::chld_loc_get_reln_seq.request->parent_loc_cd = chldloc->parent_loc_cd
   SET loc::chld_loc_get_reln_seq.request->location_group_type_mean = uar_get_code_meaning(chldloc->
    parent_loc_meaning_cd)
   IF ( NOT (LOC::chld_loc_get_reln_seq.perform(0)))
    SET PRIVATE::err_msg = LOC::chld_loc_get_reln_seq.geterror(0)
    RETURN(0)
   ENDIF
   SET chldloc->chld_loc_reltn_seq = (loc::chld_loc_get_reln_seq.reply->max_sequence+ 1)
   CALL LOC::chld_loc_add_loc_reltn.initialize(0)
   SET stat = alterlist(loc::chld_loc_add_loc_reltn.request->qual,1)
   SET loc::chld_loc_add_loc_reltn.request->qual[1].parent_loc_cd = chldloc->parent_loc_cd
   SET loc::chld_loc_add_loc_reltn.request->qual[1].child_loc_cd = chldloc->chld_loc_cd
   SET loc::chld_loc_add_loc_reltn.request->qual[1].cdf_meaning = uar_get_code_meaning(chldloc->
    parent_loc_meaning_cd)
   SET loc::chld_loc_add_loc_reltn.request->qual[1].active_ind = 1
   SET loc::chld_loc_add_loc_reltn.request->qual[1].beg_effective_dt_tm = chldloc->chld_loc_start_dt
   SET loc::chld_loc_add_loc_reltn.request->qual[1].end_effective_dt_tm = chldloc->chld_loc_end_dt
   SET loc::chld_loc_add_loc_reltn.request->qual[1].sequence = chldloc->chld_loc_reltn_seq
   IF ( NOT (LOC::chld_loc_add_loc_reltn.perform(0)))
    SET PRIVATE::err_msg = LOC::chld_loc_add_loc_reltn.geterror(0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS loc_add_room_bed FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 location_cd = f8
   1 parent_type_mean = vc
   1 organization_id = f8
   1 total_new_rooms = i4
   1 rooms[*]
     2 new_room_ind = i2
     2 location_cd = f8
     2 sequence = i4
     2 class_cd = f8
     2 med_service_cd = f8
     2 fixed_bed_ind = i2
     2 number_fixed_beds = i4
     2 isolation_cd = f8
     2 resource_ind = i2
     2 active_ind = i2
     2 census_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 description = vc
     2 short_desc = vc
     2 cdf_meaning = vc
     2 primary_ind = i2
     2 definition = vc
     2 collation_seq = i4
     2 facility_accn_prefix = vc
     2 bed_cnt = i4
     2 beds[*]
       3 sequence = i4
       3 fixed_bed_ind = i2
       3 resource_ind = i2
       3 active_ind = i2
       3 census_ind = i2
       3 dup_bed_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 description = vc
       3 short_desc = vc
       3 cdf_meaning = vc
       3 definition = vc
       3 collation_seq = i4
       3 facility_accn_prefix = vc
       3 reserve_ind = i2
 )
 RECORD _::reply(
   1 rooms[1]
     2 location_cd = f8
     2 beds[*]
       3 bed_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("loc_add_room_bed"))
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(1)
 END; class scope:init
 WITH copy = 1
 CREATE CLASS loc_chk_locations FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 location[*]
     2 location_cd = f8
     2 location_occupied_details_ind = i2
 )
 RECORD _::reply(
   1 qual_cnt = i4
   1 location[*]
     2 location_cd = f8
     2 location_occupied_ind = i2
     2 location_pending_occupied_ind = i2
     2 location_occupied_details[*]
       3 person_id = f8
       3 name_full_formatted = vc
       3 encntr_id = f8
       3 encntr_pending_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pm_chk_locations"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS loc_chg_loc_status FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 qual[*]
     2 location_cd = f8
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_status_cd = f8
 )
 RECORD _::reply(
   1 exception_data[1]
     2 location_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("loc_chg_loc_status"))
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(1)
 END; class scope:init
 WITH copy = 1
END GO
