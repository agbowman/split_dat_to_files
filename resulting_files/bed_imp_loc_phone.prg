CREATE PROGRAM bed_imp_loc_phone
 EXECUTE cclseclogin
 FREE SET request_add_phone
 RECORD request_add_phone(
   1 qual[1]
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 phone_type_cd = f8
     2 phone_type_meaning = vc
     2 phone_type_seq = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 phone_format_cd = f8
     2 phone_num = vc
     2 description = vc
     2 contact = vc
     2 call_instruction = vc
     2 modem_capability_cd = f8
     2 extension = vc
     2 paging_code = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 FREE SET reply_add_phone
 RECORD reply_add_phone(
   1 phone_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET str_data
 RECORD str_data(
   1 str_qual = c1
 )
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
 DECLARE phonetype = vc
 DECLARE phone_type_code = f8
 DECLARE phoneformatcd = f8
 DECLARE phonenumber = vc
 DECLARE description = vc
 DECLARE contact = vc
 DECLARE callinst = vc
 DECLARE modem = i2
 DECLARE extension = vc
 DECLARE status = vc
 DECLARE active_req = i2
 DECLARE active_preq = i2
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
 DECLARE numhim = i4 WITH noconstant(0)
 DECLARE numproc = i4
 DECLARE numhimact[2] = i4 WITH noconstant(0,0)
 DECLARE samedis = i4 WITH noconstant(0)
 DECLARE sametyp = i4 WITH noconstant(0)
 DECLARE samefac = i4 WITH noconstant(0)
 DECLARE samebui = i4 WITH noconstant(0)
 DECLARE sameloc = i4 WITH noconstant(0)
 DECLARE sameview = i4 WITH noconstant(0)
 DECLARE diffdis = i4 WITH noconstant(0)
 DECLARE difftyp = i4 WITH noconstant(0)
 DECLARE difffac = i4 WITH noconstant(0)
 DECLARE diffbui = i4 WITH noconstant(0)
 DECLARE diffloc = i4 WITH noconstant(0)
 DECLARE diffview = i4 WITH noconstant(0)
 DECLARE cs222_facility = f8
 DECLARE cs222_himroot = f8
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 SET title = validate(log_title_set,"Location Phone Import Log")
 SET name = validate(log_name_set,"bed_loc_phone.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 SET facility_pname = no_match
 SET discipline_pname = no_match
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
 SET phoneformatcd = 0.0
 SELECT INTO "nl:"
  cc.code_value
  FROM code_value cc
  WHERE cc.code_set=281
   AND cc.active_ind=1
   AND cc.cdf_meaning="FREETEXT"
  DETAIL
   phoneformatcd = cc.code_value
  WITH nocounter
 ;end select
 IF (phoneformatcd=0.0)
  SET err_msg = "ERROR: no code for FREETEXT in codeset 281"
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
 SET location_desc = trim(requestin->list_0[loopvarin].locdescription,3)
 SET phonetype = trim(requestin->list_0[loopvarin].phonetype,3)
 SET phonenumber = trim(requestin->list_0[loopvarin].number,3)
 SET description = trim(requestin->list_0[loopvarin].description,3)
 SET contact = trim(requestin->list_0[loopvarin].contact,3)
 SET callinst = trim(requestin->list_0[loopvarin].instructions,3)
 SET modem = evaluate(trim(requestin->list_0[loopvarin].modem,3),"0",0,1)
 SET extension = trim(requestin->list_0[loopvarin].extension,3)
 SET facility_uname = cnvtupper(facility_name)
 SET building_uname = cnvtupper(building_name)
 SET location_uname = cnvtupper(location_desc)
 SET location_name = location_desc
 IF (facility_name <= " "
  AND building_name <= " ")
  SET numblank = (numblank+ 1)
  GO TO next_rec
 ENDIF
 SET building_add = " "
 SET location_add = " "
 SET err_flag = 0
 CALL validate_facility(0)
 CALL validate_building(0)
 IF (err_flag != 0)
  GO TO next_rec
 ENDIF
 CALL validate_location(0)
 IF (err_flag != 0)
  GO TO next_rec
 ENDIF
 CALL validate_phone(0)
 IF (err_flag != 0)
  GO TO next_rec
 ENDIF
 IF ((alt_mode=- (2)))
  CALL logrec(0)
  GO TO next_rec
 ENDIF
 CALL add_phone(0)
 CALL logrec(0)
 GO TO next_rec
#show_totals
 CALL logtotal(0)
 RETURN
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
   IF (nfound=0)
    SET err_msg = concat("ERROR: no building: ",building_name," exist in facility: ",facility_name,
     ".")
    CALL logrec(8)
    RETURN
   ENDIF
   IF (building_code > 0.1)
    SET building_pname = building_uname
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE validate_location(xdum)
   SET diffloc = (diffloc+ 1)
   SET location_pname = no_match
   SET room_pname = no_match
   SET location_code = 0.0
   IF (location_desc <= " ")
    SET err_msg = "ERROR: location is a required field; it must not be blank."
    CALL logrec(8)
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
      AND cv.code_set=220
      AND cv.active_ind=1)
    DETAIL
     IF (location_code != cv.code_value)
      nfound = (nfound+ 1)
     ENDIF
     location_code = cv.code_value
    WITH nocounter
   ;end select
   IF (nfound > 1)
    SET err_msg = concat("ERROR: ambiguous ",location_name,".  ",build(nfound),
     " of these already exist in building: ",
     building_name,".")
    CALL logrec(8)
    RETURN
   ENDIF
   IF (nfound=0)
    SET err_msg = concat("ERROR: no location: ",location_desc," exist in building: ",building_name,
     ".")
    CALL logrec(8)
    RETURN
   ENDIF
   IF (location_code > 0.1)
    SET location_pname = location_uname
    SET active_preq = active_req
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE validate_phone(xdum)
   SET phone_type_code = 0.0
   SELECT INTO "nl:"
    cc.code_value
    FROM code_value cc
    WHERE cc.code_set=43
     AND cc.active_ind=1
     AND cc.display_key=cnvtupper(phonetype)
    DETAIL
     phone_type_code = cc.code_value
    WITH nocounter
   ;end select
   IF (phone_type_code=0.0)
    SET err_msg = concat("ERROR: no code for ",phonetype," in codeset 43")
    CALL logrec(8)
    RETURN
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE add_phone(xdum)
   SET request_add_phone->qual[1].parent_entity_name = "LOCATION"
   SET request_add_phone->qual[1].parent_entity_id = location_code
   SET request_add_phone->qual[1].phone_type_cd = phone_type_code
   SET request_add_phone->qual[1].phone_type_meaning = phonetype
   SET request_add_phone->qual[1].phone_type_seq = 0
   SET request_add_phone->qual[1].active_ind = 1
   SET request_add_phone->qual[1].active_status_cd = reqdata->active_status_cd
   SET request_add_phone->qual[1].active_status_dt_tm = begin_dt_tm
   SET request_add_phone->qual[1].phone_format_cd = phoneformatcd
   SET request_add_phone->qual[1].phone_num = phonenumber
   SET request_add_phone->qual[1].description = description
   SET request_add_phone->qual[1].contact = contact
   SET request_add_phone->qual[1].call_instruction = callinst
   SET request_add_phone->qual[1].modem_capability_cd = modem
   SET request_add_phone->qual[1].extension = extension
   SET request_add_phone->qual[1].paging_code = " "
   SET request_add_phone->qual[1].beg_effective_dt_tm = begin_dt_tm
   SET request_add_phone->qual[1].end_effective_dt_tm = end_dt_tm
   IF (alt_mode >= 0)
    EXECUTE mm_add_phone  WITH replace("REQUEST",request_add_phone)
    COMMIT
   ENDIF
   SET location_add = "+"
   RETURN
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
    EXECUTE mig_imp_locs_full
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
       col 35, building_name"#########################", col 63,
       location_add, col 64, location_name"##################",
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
     "Total Number of Duplicate Records:", col 34, numdup"######",
     row + 1, col 0, "Total Number of Records Not Added:",
     col 34, numnot"######", row + 1,
     col 0, "    Total Number of Error Records:", col 34,
     numerr"######"
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
END GO
