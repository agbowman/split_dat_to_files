CREATE PROGRAM bed_imp_locs:dba
 EXECUTE cclseclogin
 FREE SET request_loc_add
 RECORD request_loc_add(
   1 qual[1]
     2 resource_ind = i2
     2 active_ind = i2
     2 census_ind = i2
     2 organization_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 description = c200
     2 short_desc = c15
     2 cdf_meaning = c12
     2 patcare_node_ind = i2
     2 discipline_type_cd = f8
     2 definition = c100
     2 collation_seq = i4
     2 transmit_outbound_order_ind = i2
     2 tray_type_cd = f8
     2 rack_type_cd = f8
     2 med_service_cd = f8
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
     2 tag_value = i4
     2 contributor_source_cd = f8
     2 ref_lab_acct_nbr = vc
 )
 FREE SET reply_loc_add
 RECORD reply_loc_add(
   1 qual[1]
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
 FREE SET request_loc_rel
 RECORD request_loc_rel(
   1 qual[1]
     2 parent_loc_cd = f8
     2 child_loc_cd = f8
     2 cdf_meaning = c12
     2 root_loc_cd = f8
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 sequence = i4
 )
 FREE SET reply_loc_rel
 RECORD reply_loc_rel(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET request_room_bed
 RECORD request_room_bed(
   1 location_cd = f8
   1 parent_type_mean = c12
   1 organization_id = f8
   1 total_new_rooms = i4
   1 rooms[1]
     2 new_room_ind = i2
     2 location_cd = f8
     2 sequence = i4
     2 class_cd = f8
     2 med_service_cd = f8
     2 isolation_cd = f8
     2 resource_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 census_ind = i2
     2 fixed_bed_ind = i2
     2 active_status_dt_tm = di8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 description = c200
     2 short_desc = c10
     2 definition = c100
     2 collation_seq = i4
     2 facility_accn_prefix = c5
     2 bed_cnt = i4
     2 beds[1]
       3 sequence = i4
       3 resource_ind = i2
       3 active_ind = i2
       3 census_ind = i2
       3 dup_bed_ind = i2
       3 active_status_dt_tm = di8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 description = c200
       3 short_desc = c10
       3 definition = c100
       3 collation_seq = i4
       3 facility_accn_prefix = c5
 )
 FREE SET reply_room_bed
 RECORD reply_room_bed(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET request_cs_seq
 RECORD request_cs_seq(
   1 code_set = i4
   1 cdf_meaning = c12
 )
 FREE SET reply_cs_seq
 RECORD reply_cs_seq(
   1 max_coll_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET request_lg_seq
 RECORD request_lg_seq(
   1 parent_loc_cd = f8
   1 location_group_type_mean = c12
   1 root_loc_cd = f8
 )
 FREE SET reply_lg_seq
 RECORD reply_lg_seq(
   1 max_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_cs_sequence(p1,p2) = i4
 DECLARE get_lg_sequence(p1,p2) = i4
 DECLARE log_name = vc
 DECLARE organization_name = vc
 DECLARE organization_id = f8
 DECLARE facility_name = vc
 DECLARE facility_uname = vc
 DECLARE facility_pname = vc
 DECLARE facility_code = f8
 DECLARE building_name = vc
 DECLARE building_uname = vc
 DECLARE building_pname = vc
 DECLARE building_code = f8
 DECLARE building_add = c1
 DECLARE location_desc = vc
 DECLARE location_name = vc
 DECLARE location_uname = vc
 DECLARE location_pname = vc
 DECLARE location_code = f8
 DECLARE location_add = c1
 DECLARE discipline_name = vc
 DECLARE discipline_kname = vc
 DECLARE discipline_pname = vc
 DECLARE discipline_code = f8
 DECLARE discipline_pcode = f8
 DECLARE type_name = vc
 DECLARE type_uname = vc
 DECLARE type_pname = vc
 DECLARE type_meaning = vc
 DECLARE type_display = vc
 DECLARE room_name = vc
 DECLARE room_uname = vc
 DECLARE room_pname = vc
 DECLARE room_code = f8
 DECLARE room_add = c1
 DECLARE new_room = i2
 DECLARE room_seq = i4
 DECLARE bed_name = vc
 DECLARE bed_uname = vc
 DECLARE bed_code = f8
 DECLARE bed_add = c1
 DECLARE new_bed = i2
 DECLARE bed_seq = i4
 DECLARE status = vc
 DECLARE active_req = i2
 DECLARE active_preq = i2
 DECLARE census_req = i2
 DECLARE scr = vc
 DECLARE err_msg = vc
 DECLARE act_cen = c2
 DECLARE rownum = i4
 DECLARE seqnum = i4
 DECLARE err_flag = i2
 DECLARE stat = i2
 DECLARE nfound = i2
 DECLARE no_match = vc WITH constant("~~~")
 DECLARE numblank = i4 WITH noconstant(0)
 DECLARE numerr = i4 WITH noconstant(0)
 DECLARE numadd = i4 WITH noconstant(0)
 DECLARE numdup = i4 WITH noconstant(0)
 DECLARE numnot = i4 WITH noconstant(0)
 DECLARE numbui = i4 WITH noconstant(0)
 DECLARE numnur = i4 WITH noconstant(0)
 DECLARE numamb = i4 WITH noconstant(0)
 DECLARE numroom = i4 WITH noconstant(0)
 DECLARE numbeds = i4 WITH noconstant(0)
 DECLARE numproc = i4
 DECLARE numnuract[2] = i4 WITH noconstant(0,0)
 DECLARE numnurcen[2] = i4 WITH noconstant(0,0)
 DECLARE numambact[2] = i4 WITH noconstant(0,0)
 DECLARE numambcen[2] = i4 WITH noconstant(0,0)
 DECLARE samedis = i4 WITH noconstant(0)
 DECLARE sametyp = i4 WITH noconstant(0)
 DECLARE samefac = i4 WITH noconstant(0)
 DECLARE samebui = i4 WITH noconstant(0)
 DECLARE sameloc = i4 WITH noconstant(0)
 DECLARE sameroom = i4 WITH noconstant(0)
 DECLARE diffdis = i4 WITH noconstant(0)
 DECLARE difftyp = i4 WITH noconstant(0)
 DECLARE difffac = i4 WITH noconstant(0)
 DECLARE diffbui = i4 WITH noconstant(0)
 DECLARE diffloc = i4 WITH noconstant(0)
 DECLARE diffroom = i4 WITH noconstant(0)
 DECLARE cs222_facility = f8
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 SET title = validate(log_title_set,"Location Import Log")
 SET name = validate(log_name_set,"bed_imp_locs.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 SET facility_pname = no_match
 SET discipline_pname = no_match
 SET type_pname = no_match
 SET active_preq = - (1)
 SET cs222_facility = 0.0
 SELECT INTO "nl:"
  cc.code_value
  FROM code_value cc
  WHERE cc.code_set=222
   AND cc.cdf_meaning="FACILITY"
   AND cc.active_ind=1
  DETAIL
   cs222_facility = cc.code_value
  WITH nocounter
 ;end select
 IF (cs222_facility=0.0)
  SET err_msg = "ERROR: no code for FACILITY in codeset 222"
  CALL logrec(9)
  RETURN
 ENDIF
 CALL load_reqdata(0)
 SET numrows = size(requestin->list_0,5)
 SET loopvarin = 0
#next_rec
 SET loopvarin = (loopvarin+ 1)
 IF (loopvarin > numrows)
  GO TO show_totals
 ENDIF
 SET facility_name = trim(requestin->list_0[loopvarin].facility,3)
 SET building_name = trim(requestin->list_0[loopvarin].building,3)
 SET location_desc = trim(requestin->list_0[loopvarin].description,3)
 SET location_name = trim(requestin->list_0[loopvarin].display,3)
 SET type_name = trim(requestin->list_0[loopvarin].type,3)
 SET room_name = trim(requestin->list_0[loopvarin].room,3)
 SET bed_name = trim(requestin->list_0[loopvarin].bed,3)
 IF (validate(requestin->list_0[loopvarin].active))
  SET active_req = evaluate(trim(requestin->list_0[loopvarin].active,3),"0",0,1)
 ELSE
  SET active_req = 1
 ENDIF
 IF (validate(requestin->list_0[loopvarin].census))
  SET census_req = evaluate(trim(requestin->list_0[loopvarin].census,3),"0",0,1)
 ELSE
  SET census_req = 0
 ENDIF
 IF (validate(requestin->list_0[loopvarin].discipline))
  SET discipline_name = trim(requestin->list_0[loopvarin].discipline,3)
 ELSE
  SET discipline_name = fillstring(40," ")
 ENDIF
 SET facility_uname = cnvtupper(facility_name)
 SET building_uname = cnvtupper(building_name)
 SET location_uname = cnvtupper(location_desc)
 SET type_uname = cnvtupper(type_name)
 SET room_uname = cnvtupper(room_name)
 SET bed_uname = cnvtupper(bed_name)
 SET discipline_kname = cnvtupper(cnvtalphanum(discipline_name))
 IF (facility_name <= " "
  AND building_name <= " "
  AND location_name <= " "
  AND type_name <= " ")
  SET numblank = (numblank+ 1)
  GO TO next_rec
 ENDIF
 SET building_add = " "
 SET location_add = " "
 SET room_add = " "
 SET bed_add = " "
 SET err_flag = 0
 CALL validate_facility(0)
 CALL validate_type(0)
 CALL validate_discipline(0)
 IF (err_flag != 0)
  GO TO next_rec
 ENDIF
 CALL validate_building(0)
 IF (err_flag != 0)
  GO TO next_rec
 ENDIF
 CALL validate_location(0)
 IF (err_flag != 0)
  GO TO next_rec
 ENDIF
 CALL validate_room(0)
 IF (err_flag != 0)
  GO TO next_rec
 ENDIF
 CALL validate_bed(0)
 IF (err_flag != 0)
  GO TO next_rec
 ENDIF
 IF ((alt_mode=- (2)))
  CALL logrec(0)
  GO TO next_rec
 ENDIF
 IF (building_code < 0.1)
  CALL add_building(0)
  IF (err_flag != 0)
   GO TO next_rec
  ENDIF
 ENDIF
 IF (location_code < 0.1)
  CALL add_location(0)
  IF (err_flag != 0)
   GO TO next_rec
  ENDIF
 ENDIF
 IF ((room_code > - (0.1)))
  CALL add_room_bed(0)
  IF (err_flag != 0)
   GO TO next_rec
  ENDIF
 ENDIF
 CALL logrec(0)
 GO TO next_rec
#show_totals
 CALL logtotal(0)
 RETURN
 SUBROUTINE validate_type(xdum)
   IF (type_uname=type_pname)
    SET sametyp = (sametyp+ 1)
    RETURN
   ENDIF
   SET difftyp = (difftyp+ 1)
   SET type_pname = no_match
   SET location_pname = no_match
   SET type_meaning = " "
   SET type_display = " "
   IF (type_name <= " ")
    SET err_msg = "ERROR: type is a required field; it must not be blank."
    CALL logrec(8)
    RETURN
   ENDIF
   IF (((type_uname="NUR") OR (type_uname="NURSING")) )
    SET type_pname = type_uname
    SET type_meaning = "NURSEUNIT"
    SET type_display = "nursing unit"
    RETURN
   ENDIF
   IF (((type_uname="LOC") OR (type_uname="AMBULATORY")) )
    SET type_pname = type_uname
    SET type_meaning = "AMBULATORY"
    SET type_display = "ambulatory location"
    RETURN
   ENDIF
   SET err_msg = concat("ERROR: type ",type_name," is invalid: must be NUR or LOC.")
   CALL logrec(8)
   RETURN
 END ;Subroutine
 SUBROUTINE validate_discipline(xdum)
   IF (discipline_name <= " ")
    SET discipline_code = 0.0
    RETURN
   ENDIF
   IF (discipline_kname=discipline_pname)
    SET samedis = (samedis+ 1)
    SET discipline_code = discipline_pcode
    RETURN
   ENDIF
   SET diffdis = (diffdis+ 1)
   SET discipline_pname = no_match
   SET discipline_code = 0.0
   SELECT INTO "nl:"
    cc.code_value
    FROM code_value cc
    WHERE cc.code_set=6000
     AND cc.display_key=discipline_kname
     AND cc.active_ind=1
    DETAIL
     discipline_code = cc.code_value
    WITH nocounter
   ;end select
   IF (discipline_code=0.0)
    SET err_msg = concat("ERROR: discipline ",discipline_name," is not defined on Code Set 6000.")
    CALL logrec(8)
    RETURN
   ENDIF
   SET discipline_pname = discipline_kname
   SET discipline_pcode = discipline_code
   RETURN
 END ;Subroutine
 SUBROUTINE validate_facility(xdum)
   IF (facility_uname=facility_pname)
    SET samefac = (samefac+ 1)
    RETURN
   ENDIF
   SET difffac = (difffac+ 1)
   SET facility_pname = no_match
   SET building_pname = no_match
   IF (facility_name <= " ")
    SET err_msg = "ERROR: facility is a required field; it must not be blank."
    CALL logrec(8)
    RETURN
   ENDIF
   SET facility_code = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cnvtupper(cv.description)=facility_uname
     AND cv.cdf_meaning="FACILITY"
     AND cv.code_set=220
    DETAIL
     facility_code = cv.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_msg = concat("ERROR: facility ",facility_name," is not defined on Codeset 220.")
    CALL logrec(8)
    RETURN
   ENDIF
   SET organization_id = 0.0
   SET ltc = 0.0
   SELECT INTO "nl:"
    FROM location l
    WHERE l.location_cd=facility_code
    DETAIL
     ltc = l.location_type_cd, organization_id = l.organization_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_msg = concat("ERROR: facility ",facility_name," is not in Location table.")
    CALL logrec(8)
    RETURN
   ENDIF
   IF (ltc != cs222_facility)
    SELECT INTO "nl:"
     cc.code_value
     FROM code_value cc
     WHERE cc.code_set=222
      AND cc.code_value=ltc
      AND cc.active_ind=1
     DETAIL
      scr = cc.display
     WITH nocounter
    ;end select
    SET err_msg = concat("ERROR: facility ",facility_name,
     " is not setup as FACILITY in Location table: ",trim(scr))
    CALL logrec(8)
   ENDIF
   SET organization_name = " "
   SELECT INTO "nl:"
    FROM organization o
    WHERE o.organization_id=organization_id
    DETAIL
     organization_name = o.org_name
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_msg = concat("ERROR: facility ",facility_name," has no entry in Organization table.")
    CALL logrec(8)
    RETURN
   ENDIF
   IF (err_flag != 0)
    RETURN
   ENDIF
   SET facility_pname = facility_uname
   RETURN
 END ;Subroutine
 SUBROUTINE validate_building(xdum)
   IF (building_uname=building_pname)
    SET samebui = (samebui+ 1)
    RETURN
   ENDIF
   SET diffbui = (diffbui+ 1)
   SET building_pname = no_match
   SET location_pname = no_match
   SET building_code = 0.0
   IF (building_name <= " ")
    SET err_msg = "ERROR: building is a required field; it must not be blank."
    CALL logrec(8)
    RETURN
   ENDIF
   SET nfound = 0
   SELECT INTO "NL:"
    FROM location_group lg,
     code_value cv
    PLAN (lg
     WHERE lg.parent_loc_cd=facility_code)
     JOIN (cv
     WHERE cv.code_value=lg.child_loc_cd
      AND cnvtupper(cv.description)=building_uname
      AND cv.cdf_meaning="BUILDING"
      AND cv.code_set=220
      AND cv.active_ind=1)
    DETAIL
     IF (building_code != cv.code_value)
      nfound = (nfound+ 1)
     ENDIF
     building_code = cv.code_value
    WITH nocounter
   ;end select
   IF (nfound > 1)
    SET err_msg = concat("ERROR: ambiguous building: ",building_name,".  ",build(nfound),
     " of these already exist in facility: ",
     facility_name,".")
    CALL logrec(8)
    RETURN
   ENDIF
   IF (building_code > 0.1)
    SET building_pname = building_uname
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE validate_location(xdum)
   IF (location_uname=location_pname
    AND active_req=active_preq)
    SET sameloc = (sameloc+ 1)
    RETURN
   ENDIF
   SET diffloc = (diffloc+ 1)
   SET location_pname = no_match
   SET room_pname = no_match
   SET location_code = 0.0
   IF (location_desc <= " ")
    SET err_msg = "ERROR: description is a required field; it must not be blank."
    CALL logrec(8)
    RETURN
   ENDIF
   IF (building_code < 0.1)
    RETURN
   ENDIF
   SET nfound = 0
   SELECT INTO "NL:"
    FROM location_group lg,
     code_value cv
    PLAN (lg
     WHERE lg.parent_loc_cd=building_code)
     JOIN (cv
     WHERE cv.code_value=lg.child_loc_cd
      AND cnvtupper(cv.description)=location_uname
      AND cv.cdf_meaning=type_meaning
      AND cv.code_set=220
      AND cv.active_ind=active_req)
    DETAIL
     IF (location_code != cv.code_value)
      nfound = (nfound+ 1)
     ENDIF
     location_code = cv.code_value
    WITH nocounter
   ;end select
   IF (nfound > 1)
    SET err_msg = concat("ERROR: ambiguous ",evaluate(active_req,1,"active ","inactive "),
     type_display,": ",location_name,
     ".  ",build(nfound)," of these already exist in building: ",building_name,".")
    CALL logrec(8)
    RETURN
   ENDIF
   IF (location_code > 0.1)
    SET location_pname = location_uname
    SET active_preq = active_req
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE validate_room(xdum)
   IF (room_uname=room_pname)
    SET sameroom = (sameroom+ 1)
    RETURN
   ENDIF
   SET diffroom = (diffroom+ 1)
   SET room_pname = no_match
   SET room_code = 0.0
   SET bed_code = 0.0
   IF (room_name <= " ")
    IF (bed_name > " ")
     SET err_msg = concat("ERROR: room is required when bed (",bed_name,") is supplied.")
     CALL logrec(8)
     RETURN
    ENDIF
    IF (location_code > 0.1)
     CALL logrec(1)
     RETURN
    ENDIF
    SET room_code = - (1.0)
    RETURN
   ENDIF
   IF (location_code < 0.1)
    RETURN
   ENDIF
   SET nfound = 0
   SELECT INTO "NL:"
    FROM location_group lg,
     code_value cv
    PLAN (lg
     WHERE lg.parent_loc_cd=location_code)
     JOIN (cv
     WHERE cv.code_value=lg.child_loc_cd
      AND cnvtupper(cv.description)=room_uname
      AND cv.cdf_meaning="ROOM"
      AND cv.code_set=220)
    DETAIL
     IF (room_code != cv.code_value)
      nfound = (nfound+ 1)
     ENDIF
     room_code = cv.code_value
    WITH nocounter
   ;end select
   IF (nfound > 1)
    SET err_msg = concat("ERROR: ambiguous room: ",room_name,".  ",build(nfound),
     " of these already exist in ",
     type_display,": ",location_name,".")
    CALL logrec(8)
    RETURN
   ENDIF
   IF (room_code > 0.1)
    SET room_pname = room_uname
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE validate_bed(xdum)
   SET bed_code = 0.0
   IF (bed_name <= " ")
    IF (room_code > 0.1)
     CALL logrec(1)
     RETURN
    ENDIF
    SET bed_code = - (1.0)
    RETURN
   ENDIF
   IF (room_code < 0.1)
    RETURN
   ENDIF
   SELECT INTO "NL:"
    FROM location_group lg,
     code_value cv
    PLAN (lg
     WHERE lg.parent_loc_cd=room_code)
     JOIN (cv
     WHERE cv.code_value=lg.child_loc_cd
      AND cnvtupper(cv.description)=bed_uname
      AND cv.cdf_meaning="BED"
      AND cv.code_set=220)
    DETAIL
     bed_code = cv.code_value
    WITH nocounter
   ;end select
   IF (bed_code > 0.1)
    CALL logrec(1)
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE add_building(xdum)
   SET seqnum = get_cs_sequence(220,"BUILDING")
   SET request_loc_add->qual[1].resource_ind = 0
   SET request_loc_add->qual[1].active_ind = 1
   SET request_loc_add->qual[1].census_ind = 0
   SET request_loc_add->qual[1].organization_id = organization_id
   SET request_loc_add->qual[1].beg_effective_dt_tm = begin_dt_tm
   SET request_loc_add->qual[1].end_effective_dt_tm = end_dt_tm
   SET request_loc_add->qual[1].description = building_name
   SET request_loc_add->qual[1].short_desc = building_name
   SET request_loc_add->qual[1].cdf_meaning = "BUILDING"
   SET request_loc_add->qual[1].patcare_node_ind = 0
   SET request_loc_add->qual[1].discipline_type_cd = 0.0
   SET request_loc_add->qual[1].definition = " "
   SET request_loc_add->qual[1].collation_seq = seqnum
   SET request_loc_add->qual[1].transmit_outbound_order_ind = 0
   SET request_loc_add->qual[1].tray_type_cd = 0
   SET request_loc_add->qual[1].rack_type_cd = 0
   SET request_loc_add->qual[1].med_service_cd = 0
   SET request_loc_add->qual[1].atd_req_loc = 0
   SET request_loc_add->qual[1].cart_qty_ind = 0
   SET request_loc_add->qual[1].dispense_window = 0
   SET request_loc_add->qual[1].class_cd = 0
   SET request_loc_add->qual[1].fixed_bed_ind = 0
   SET request_loc_add->qual[1].number_fixed_beds = 0
   SET request_loc_add->qual[1].isolation_cd = 0
   SET request_loc_add->qual[1].loc_building_cd = 0.0
   SET request_loc_add->qual[1].loc_facility_cd = facility_code
   SET request_loc_add->qual[1].loc_nurse_unit_cd = 0.0
   SET request_loc_add->qual[1].tag_value = 0
   SET request_loc_add->qual[1].contributor_source_cd = 0.0
   SET request_loc_add->qual[1].ref_lab_acct_nbr = " "
   IF (alt_mode >= 0)
    EXECUTE loc_add_location  WITH replace("REQUEST",request_loc_add), replace("REPLY",reply_loc_add)
    IF ((reply_loc_add->status_data.status="S"))
     SET do_nothing = 1
    ELSE
     SET building_add = "*"
     CALL logrec(2)
     RETURN
    ENDIF
   ENDIF
   SET building_code = reply_loc_add->qual[1].location_cd
   SET seqnum = get_lg_sequence(facility_code,"FACILITY")
   SET request_loc_rel->qual[1].parent_loc_cd = facility_code
   SET request_loc_rel->qual[1].child_loc_cd = building_code
   SET request_loc_rel->qual[1].cdf_meaning = "FACILITY"
   SET request_loc_rel->qual[1].root_loc_cd = 0.0
   SET request_loc_rel->qual[1].active_ind = 1
   SET request_loc_rel->qual[1].beg_effective_dt_tm = begin_dt_tm
   SET request_loc_rel->qual[1].end_effective_dt_tm = end_dt_tm
   SET request_loc_rel->qual[1].sequence = seqnum
   IF (alt_mode >= 0)
    EXECUTE loc_add_loc_parent_child_r  WITH replace("REQUEST",request_loc_rel), replace("REPLY",
     reply_loc_rel)
    IF ((reply_loc_rel->status_data.status="S"))
     COMMIT
    ELSE
     ROLLBACK
     SET building_add = "#"
     CALL logrec(2)
     RETURN
    ENDIF
   ENDIF
   SET building_add = "+"
   SET numbui = (numbui+ 1)
   RETURN
 END ;Subroutine
 SUBROUTINE add_location(xdum)
   SET seqnum = get_cs_sequence(220,type_meaning)
   SET request_loc_add->qual[1].resource_ind = 0
   SET request_loc_add->qual[1].active_ind = active_req
   SET request_loc_add->qual[1].census_ind = census_req
   SET request_loc_add->qual[1].organization_id = organization_id
   SET request_loc_add->qual[1].beg_effective_dt_tm = begin_dt_tm
   SET request_loc_add->qual[1].end_effective_dt_tm = end_dt_tm
   SET request_loc_add->qual[1].description = location_desc
   SET request_loc_add->qual[1].short_desc = location_name
   SET request_loc_add->qual[1].cdf_meaning = type_meaning
   SET request_loc_add->qual[1].patcare_node_ind = 0
   SET request_loc_add->qual[1].discipline_type_cd = discipline_code
   SET request_loc_add->qual[1].definition = " "
   SET request_loc_add->qual[1].collation_seq = seqnum
   SET request_loc_add->qual[1].transmit_outbound_order_ind = 0
   SET request_loc_add->qual[1].tray_type_cd = 0
   SET request_loc_add->qual[1].rack_type_cd = 0
   SET request_loc_add->qual[1].med_service_cd = 0
   SET request_loc_add->qual[1].atd_req_loc = 0
   SET request_loc_add->qual[1].cart_qty_ind = 0
   SET request_loc_add->qual[1].dispense_window = 0
   SET request_loc_add->qual[1].class_cd = 0
   SET request_loc_add->qual[1].fixed_bed_ind = 0
   SET request_loc_add->qual[1].number_fixed_beds = 0
   SET request_loc_add->qual[1].isolation_cd = 0
   SET request_loc_add->qual[1].loc_building_cd = building_code
   SET request_loc_add->qual[1].loc_facility_cd = facility_code
   SET request_loc_add->qual[1].loc_nurse_unit_cd = 0.0
   SET request_loc_add->qual[1].tag_value = 0
   SET request_loc_add->qual[1].contributor_source_cd = 0.0
   SET request_loc_add->qual[1].ref_lab_acct_nbr = " "
   IF (alt_mode >= 0)
    EXECUTE loc_add_location  WITH replace("REQUEST",request_loc_add), replace("REPLY",reply_loc_add)
    IF ((reply_loc_add->status_data.status="S"))
     SET do_nothing = 1
    ELSE
     SET location_add = "*"
     CALL logrec(2)
     RETURN
    ENDIF
   ENDIF
   SET location_code = reply_loc_add->qual[1].location_cd
   SET seqnum = get_lg_sequence(building_code,"BUILDING")
   SET request_loc_rel->qual[1].parent_loc_cd = building_code
   SET request_loc_rel->qual[1].child_loc_cd = location_code
   SET request_loc_rel->qual[1].cdf_meaning = "BUILDING"
   SET request_loc_rel->qual[1].root_loc_cd = 0.0
   SET request_loc_rel->qual[1].active_ind = 1
   SET request_loc_rel->qual[1].beg_effective_dt_tm = begin_dt_tm
   SET request_loc_rel->qual[1].end_effective_dt_tm = end_dt_tm
   SET request_loc_rel->qual[1].sequence = seqnum
   IF (alt_mode >= 0)
    EXECUTE loc_add_loc_parent_child_r  WITH replace("REQUEST",request_loc_rel), replace("REPLY",
     reply_loc_rel)
    IF ((reply_loc_rel->status_data.status="S"))
     COMMIT
    ELSE
     ROLLBACK
     SET location_add = "#"
     CALL logrec(2)
     RETURN
    ENDIF
   ENDIF
   SET location_add = "+"
   IF (((type_uname="NUR") OR (type_uname="NURSING")) )
    SET numnur = (numnur+ 1)
    SET numnuract[(active_req+ 1)] = (numnuract[(active_req+ 1)]+ 1)
    SET numnurcen[(census_req+ 1)] = (numnurcen[(census_req+ 1)]+ 1)
   ELSE
    SET numamb = (numamb+ 1)
    SET numambact[(active_req+ 1)] = (numambact[(active_req+ 1)]+ 1)
    SET numambcen[(census_req+ 1)] = (numambcen[(census_req+ 1)]+ 1)
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE add_room_bed(xdum)
   SET new_room = 0
   SET new_bed = 0
   SET room_seq = 0
   SET bed_seq = 0
   IF (room_code < 0.1)
    SET new_room = 1
    SET room_seq = get_lg_sequence(location_code,type_meaning)
   ENDIF
   IF ((bed_code > - (0.1)))
    SET new_bed = 1
    IF (new_room=0)
     SET bed_seq = get_lg_sequence(room_code,"ROOM")
    ENDIF
   ENDIF
   SET request_room_bed->location_cd = location_code
   SET request_room_bed->parent_type_mean = type_meaning
   SET request_room_bed->organization_id = organization_id
   SET request_room_bed->total_new_rooms = new_room
   SET request_room_bed->rooms[1].new_room_ind = new_room
   SET request_room_bed->rooms[1].location_cd = room_code
   SET request_room_bed->rooms[1].sequence = room_seq
   SET request_room_bed->rooms[1].class_cd = 0
   SET request_room_bed->rooms[1].med_service_cd = 0
   SET request_room_bed->rooms[1].isolation_cd = 0
   SET request_room_bed->rooms[1].resource_ind = 0
   SET request_room_bed->rooms[1].active_status_cd = reqdata->active_status_cd
   SET request_room_bed->rooms[1].active_ind = 1
   SET request_room_bed->rooms[1].census_ind = 1
   SET request_room_bed->rooms[1].fixed_bed_ind = 0
   SET request_room_bed->rooms[1].beg_effective_dt_tm = begin_dt_tm
   SET request_room_bed->rooms[1].end_effective_dt_tm = end_dt_tm
   SET request_room_bed->rooms[1].description = room_name
   SET request_room_bed->rooms[1].short_desc = room_name
   SET request_room_bed->rooms[1].definition = " "
   SET request_room_bed->rooms[1].collation_seq = 0
   SET request_room_bed->rooms[1].bed_cnt = new_bed
   SET request_room_bed->rooms[1].beds[1].sequence = bed_seq
   SET request_room_bed->rooms[1].beds[1].resource_ind = 0
   SET request_room_bed->rooms[1].beds[1].active_ind = 1
   SET request_room_bed->rooms[1].beds[1].census_ind = 1
   SET request_room_bed->rooms[1].beds[1].dup_bed_ind = 0
   SET request_room_bed->rooms[1].beds[1].beg_effective_dt_tm = begin_dt_tm
   SET request_room_bed->rooms[1].beds[1].end_effective_dt_tm = end_dt_tm
   SET request_room_bed->rooms[1].beds[1].description = bed_name
   SET request_room_bed->rooms[1].beds[1].short_desc = bed_name
   SET request_room_bed->rooms[1].beds[1].definition = " "
   SET request_room_bed->rooms[1].beds[1].collation_seq = 0
   IF (alt_mode >= 0)
    EXECUTE loc_add_room_bed  WITH replace("REQUEST",request_room_bed), replace("REPLY",
     reply_room_bed)
    IF ((reply_room_bed->status_data.status="S"))
     COMMIT
    ELSE
     ROLLBACK
     IF (new_room > 0)
      SET room_add = "*"
     ENDIF
     IF (new_bed > 0)
      SET bed_add = "*"
     ENDIF
     CALL logrec(2)
     RETURN
    ENDIF
   ENDIF
   IF (new_room)
    SET room_add = "+"
    SET numroom = (numroom+ 1)
   ENDIF
   IF (new_bed)
    SET bed_add = "+"
    SET numbeds = (numbeds+ 1)
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE get_cs_sequence(xcodeset,xmean)
   SET request_cs_seq->code_set = xcodeset
   SET request_cs_seq->cdf_meaning = xmean
   SET reply_cs_seq->max_coll_seq = 0
   EXECUTE loc_get_cs_max_coll_seq  WITH replace("REQUEST",request_cs_seq), replace("REPLY",
    reply_cs_seq)
   RETURN((reply_cs_seq->max_coll_seq+ 1))
 END ;Subroutine
 SUBROUTINE get_lg_sequence(xcode,xmean)
   SET request_lg_seq->parent_loc_cd = xcode
   SET request_lg_seq->location_group_type_mean = xmean
   SET request_lg_seq->root_loc_cd = 0.0
   SET reply_lg_seq->max_sequence = 0
   EXECUTE loc_get_loc_group_max_seq  WITH replace("REQUEST",request_lg_seq), replace("REPLY",
    reply_lg_seq)
   RETURN((reply_lg_seq->max_sequence+ 1))
 END ;Subroutine
 SUBROUTINE load_reqdata(xdum)
   SET codeval = 0.0
   SELECT INTO "nl:"
    cc.code_value
    FROM code_value cc
    WHERE cc.code_set=48
     AND cc.cdf_meaning="ACTIVE"
     AND cc.active_ind=1
    DETAIL
     codeval = cc.code_value
    WITH nocounter
   ;end select
   SET reqdata->active_status_cd = codeval
   SET codeval = 0.0
   SELECT INTO "nl:"
    cc.code_value
    FROM code_value cc
    WHERE cc.code_set=48
     AND cc.cdf_meaning="INACTIVE"
     AND cc.active_ind=1
    DETAIL
     codeval = cc.code_value
    WITH nocounter
   ;end select
   SET reqdata->inactive_status_cd = codeval
   SET codeval = 0.0
   SELECT INTO "nl:"
    cc.code_value
    FROM code_value cc
    WHERE cc.code_set=8
     AND cc.cdf_meaning="AUTH"
     AND cc.active_ind=1
    DETAIL
     codeval = cc.code_value
    WITH nocounter
   ;end select
   SET reqdata->data_status_cd = codeval
   SET codeval = 0.0
   SELECT INTO "nl:"
    cc.code_value
    FROM code_value cc
    WHERE cc.code_set=89
     AND cc.cdf_meaning="POWERCHART"
     AND cc.active_ind=1
    DETAIL
     codeval = cc.code_value
    WITH nocounter
   ;end select
   SET reqdata->contributor_system_cd = codeval
   RETURN
 END ;Subroutine
 SUBROUTINE logstart(xtitle,xname)
   DECLARE dir_name = vc
   SET dir_name = logical("miglog")
   IF (dir_name=" ")
    SET dir_name = "ccluserdir:"
   ELSE
    SET dir_name = "miglog:"
   ENDIF
   SET log_name = concat(trim(dir_name),xname)
   SET logvar = 0
   SELECT INTO value(log_name)
    logvar
    HEAD REPORT
     begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
     col + 1, xtitle, row + 1
    DETAIL
     row + 2, col 4, "ROW",
     col 8, "FACILITY", col 35,
     "BUILDING", col 60, "TYP",
     col 64, "NURSE UNIT/AMB LOC", col 84,
     "ROOM", col 93, "BED",
     col 101, "DISCIPLINE", col 117,
     status
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
 SUBROUTINE logrec(xflag)
   IF (err_flag=0)
    SET err_flag = xflag
   ELSE
    SET err_flag = 9
   ENDIF
   SET rownum = (loopvarin+ 1)
   CASE (err_flag)
    OF 0:
     SET status = "ADDED"
     SET numadd = (numadd+ 1)
    OF 1:
     SET status = "DUPLICATE"
     SET numdup = (numdup+ 1)
    OF 2:
     SET status = "NOT ADDED"
     SET numnot = (numnot+ 1)
    OF 8:
     SET status = "ERROR"
     SET numerr = (numerr+ 1)
    ELSE
     SET status = "ERROR"
   ENDCASE
   IF (alt_detail)
    EXECUTE bed_imp_locs_full
   ELSE
    IF (err_flag=0)
     SET building_add = " "
     SET location_add = " "
     SET room_add = " "
     SET bed_add = " "
    ENDIF
    SELECT INTO value(log_name)
     DETAIL
      IF (err_flag < 9)
       col 0, rownum"######", col 8,
       facility_name"#########################", col 34, building_add,
       col 35, building_name"#########################", col 61,
       type_uname"#", col 63, location_add,
       col 64, location_name"##################", col 83,
       room_add, col 84, room_name"#######",
       col 92, bed_add, col 93,
       bed_name"#######", col 101, discipline_name"###############",
       col 117, status
      ENDIF
      IF (err_flag > 7)
       IF (err_flag=8)
        row + 1
       ENDIF
       col 8, err_msg
      ENDIF
     WITH nocounter, append, format = variable,
      noformfeed, maxcol = 132, maxrow = 1
    ;end select
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE logtotal(xdum)
   SET numproc = ((((numadd+ numnot)+ numdup)+ numerr)+ numblank)
   SELECT INTO value(log_name)
    DETAIL
     row + 2, col 0, "        Total Number of Rows Sent:",
     col 34, numrows"######", row + 1,
     col 0, "   Total Number of Rows Processed:", col 34,
     numproc"######", row + 1, col 0,
     "            Total Buildings Added:", col 34, numbui"######",
     row + 1, col 0, "        Total Nursing Units Added:",
     col 34, numnur"######", row + 1,
     col 0, " Total Ambulatory Locations Added:", col 34,
     numamb"######", row + 1, col 0,
     "                Total Rooms Added:", col 34, numroom"######",
     row + 1, col 0, "                 Total Beds Added:",
     col 34, numbeds"######", row + 1,
     col 0, "Total Number of Duplicate Records:", col 34,
     numdup"######", row + 1, col 0,
     "Total Number of Records Not Added:", col 34, numnot"######",
     row + 1, col 0, "    Total Number of Error Records:",
     col 34, numerr"######"
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
END GO
