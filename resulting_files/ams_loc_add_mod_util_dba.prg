CREATE PROGRAM ams_loc_add_mod_util:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter file name" = "",
  "path" = ""
  WITH outdev, file, path
 EXECUTE ams_define_toolkit_common
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an AMS Associate. Operation Denied."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (size(trim(curdomain,3))=0)
  EXECUTE cclseclogin
 ENDIF
 DECLARE room_var = f8 WITH constant(uar_get_code_by("MEANING",222,"ROOM")), protect
 DECLARE nurseunit_var = f8 WITH constant(uar_get_code_by("MEANING",222,"NURSEUNIT")), protect
 DECLARE facility_var = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY")), protect
 DECLARE building_var = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING")), protect
 DECLARE bed_var = f8 WITH constant(uar_get_code_by("MEANING",222,"BED")), protect
 DECLARE ambulatory_var = f8 WITH constant(uar_get_code_by("MEANING",222,"AMBULATORY")), protect
 DECLARE ex_short_desc = vc
 DECLARE ex_room_cd = f8
 SET path = value(logical( $PATH))
 SET infile =  $FILE
 SET file_path = build( $PATH,":", $FILE)
 DEFINE rtl2 value(file_path)
 FREE RECORD temp
 RECORD temp(
   1 list[*]
     2 facility = vc
     2 res = vc
     2 buil_list[*]
       3 building = vc
       3 res = vc
       3 nurse_unit_list[*]
         4 nurs_unit = vc
         4 res = vc
         4 room_list[*]
           5 room = vc
           5 res = vc
           5 bed_list[*]
             6 bed = vc
 )
 DECLARE fac_cnt = i4
 DECLARE bul_cnt = i4
 DECLARE nurs_cnt = i4
 DECLARE room_cnt = i4
 DECLARE bed_cnt = i4
 DECLARE flag = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 1
  HEAD r.line
   line1 = r.line
   IF (flag=0)
    stat = alterlist(temp->list,1), temp->list[1].facility = piece(line1,",",1,"No Found"), fac_cnt
     = 1
    IF (piece(line1,",",2,"No Found") != "No Found")
     stat = alterlist(temp->list[1].buil_list,1), temp->list[1].buil_list[1].building = piece(line1,
      ",",2,"No Found"), bul_cnt = 1
     IF (piece(line1,",",3,"No Found") != "No Found")
      stat = alterlist(temp->list[1].buil_list[1].nurse_unit_list,1), temp->list[1].buil_list[1].
      nurse_unit_list[1].nurs_unit = piece(line1,",",3,"No Found"), nurs_cnt = 1
      IF (piece(line1,",",4,"No Found") != "No Found")
       stat = alterlist(temp->list[1].buil_list[1].nurse_unit_list[1].room_list,1), temp->list[1].
       buil_list[1].nurse_unit_list[1].room_list[1].room = piece(line1,",",4,"No Found"), room_cnt =
       1
       IF (piece(line1,",",5,"No Found") != "No Found")
        stat = alterlist(temp->list[1].buil_list[1].nurse_unit_list[1].room_list[1].bed_list,1), temp
        ->list[1].buil_list[1].nurse_unit_list[1].room_list[1].bed_list[1].bed = piece(line1,",",5,
         "No Found"), bed_cnt = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    flag = 1
   ELSE
    IF ((temp->list[fac_cnt].facility != piece(line1,",",1,"No Found")))
     stat = alterlist(temp->list,(fac_cnt+ 1)), fac_cnt = (fac_cnt+ 1), temp->list[fac_cnt].facility
      = piece(line1,",",1,"No Found"),
     bul_cnt = 0
    ENDIF
    IF (((bul_cnt=0) OR ((temp->list[fac_cnt].buil_list[bul_cnt].building != piece(line1,",",2,
     "No Found")))) )
     stat = alterlist(temp->list[fac_cnt].buil_list,(bul_cnt+ 1)), bul_cnt = (bul_cnt+ 1), temp->
     list[fac_cnt].buil_list[bul_cnt].building = piece(line1,",",2,"No Found"),
     nurs_cnt = 0
    ENDIF
    IF (((nurs_cnt=0) OR ((temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[nurs_cnt].nurs_unit
     != piece(line1,",",3,"No Found"))))
     AND piece(line1,",",3,"No Found") != "No Found"
     AND bul_cnt != 0)
     stat = alterlist(temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list,(nurs_cnt+ 1)), nurs_cnt
      = (nurs_cnt+ 1), temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[nurs_cnt].nurs_unit =
     piece(line1,",",3,"No Found"),
     room_cnt = 0
    ENDIF
    IF (((room_cnt=0) OR ((temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[nurs_cnt].
    room_list[room_cnt].room != piece(line1,",",4,"No Found"))
     AND nurs_cnt != 0))
     AND piece(line1,",",4,"No Found") != "No Found")
     stat = alterlist(temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[nurs_cnt].room_list,(
      room_cnt+ 1)), room_cnt = (room_cnt+ 1), temp->list[fac_cnt].buil_list[bul_cnt].
     nurse_unit_list[nurs_cnt].room_list[room_cnt].room = piece(line1,",",4,"No Found"),
     bed_cnt = 0
    ENDIF
    IF (((bed_cnt=0) OR ((temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[nurs_cnt].room_list[
    room_cnt].bed_list[bed_cnt].bed != piece(line1,",",5,"No Found"))
     AND room_cnt != 0))
     AND piece(line1,",",5,"No Found") != "No Found")
     stat = alterlist(temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[nurs_cnt].room_list[
      room_cnt].bed_list,(bed_cnt+ 1)), bed_cnt = (bed_cnt+ 1), temp->list[fac_cnt].buil_list[bul_cnt
     ].nurse_unit_list[nurs_cnt].room_list[room_cnt].bed_list[bed_cnt].bed = piece(line1,",",5,
      "No Found")
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(temp)
 FREE RECORD request_13055
 RECORD request_13055(
   1 code_set = i4
   1 cdf_meaning = c12
 )
 FREE RECORD reply_13055
 RECORD reply_13055(
   1 max_coll_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request_13000
 RECORD request_13000(
   1 qual[*]
     2 resource_ind = i2
     2 active_ind = i2
     2 census_ind = i2
     2 organization_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 description = c200
     2 short_desc = c40
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
     2 reserve_ind = i2
     2 transfer_dt_tm_ind = i2
 )
 FREE RECORD reply_13000
 RECORD reply_13000(
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
 FREE RECORD request_13058
 RECORD request_13058(
   1 parent_loc_cd = f8
   1 location_group_type_mean = vc
   1 root_loc_cd = f8
 )
 FREE RECORD reply_13058
 RECORD reply_13058(
   1 max_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request_13015
 RECORD request_13015(
   1 qual[*]
     2 parent_loc_cd = f8
     2 child_loc_cd = f8
     2 cdf_meaning = c12
     2 root_loc_cd = f8
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 sequence = i4
 )
 FREE RECORD reply_13015
 RECORD reply_13015(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request_6024
 RECORD request_6024(
   1 action = i4
   1 codesetlist[*]
     2 codeset = i4
     2 meaninglist[*]
       3 meaning = vc
   1 codelist[*]
     2 code = f8
 )
 FREE RECORD reply_6024
 RECORD reply_6024(
   1 status_data
     2 status = c1
     2 substatus = i2
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request_13050
 RECORD request_13050(
   1 location_cd = f8
   1 parent_type_mean = c12
   1 organization_id = f8
   1 total_new_rooms = i4
   1 rooms[*]
     2 new_room_ind = i2
     2 location_cd = f8
     2 sequence = i4
     2 class_cd = f8
     2 med_service_cd = f8
     2 number_fixed_beds = i4
     2 isolation_cd = f8
     2 resource_ind = i2
     2 active_ind = i2
     2 census_ind = i2
     2 active_status_cd = f8
     2 fixed_bed_ind = i2
     2 active_status_dt_tm = di8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 description = c200
     2 short_desc = c40
     2 cdf_meaning = c12
     2 primary_ind = i4
     2 definition = c100
     2 collation_seq = i4
     2 facility_accn_prefix = c5
     2 bed_cnt = i4
     2 beds[*]
       3 sequence = i4
       3 fixed_bed_ind = i2
       3 resource_ind = i2
       3 active_ind = i2
       3 census_ind = i2
       3 dup_bed_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = di8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 description = c200
       3 short_desc = c10
       3 cdf_meaning = c12
       3 definition = c100
       3 collation_seq = i4
       3 facility_accn_prefix = c5
       3 reserve_ind = i2
 )
 FREE RECORD reply_13050
 RECORD reply_13050(
   1 rooms[1]
     2 location_cd = f8
     2 beds[1]
       3 bed_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE fac_flag = i4 WITH protect, noconstant(0)
 DECLARE bul_flag = i4 WITH protect, noconstant(0)
 DECLARE facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE building_cd = f8 WITH protect, noconstant(0.0)
 DECLARE nurse_unit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE facility = vc WITH protect
 DECLARE building = vc WITH protect
 DECLARE nurse_unit = vc WITH protect
 FOR (fac_cnt = 1 TO size(temp->list,5))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=220
    AND cv.description=trim(temp->list[fac_cnt].facility)
    AND cv.cdf_meaning="FACILITY"
   DETAIL
    facility_cd = cv.code_value, temp->list[fac_cnt].res = "Facility Found"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   FOR (bul_cnt = 1 TO size(temp->list[fac_cnt].buil_list,5))
     SELECT INTO "nl:"
      FROM code_value cv,
       location_group lg
      PLAN (cv
       WHERE cv.display=trim(temp->list[fac_cnt].buil_list[bul_cnt].building)
        AND cv.active_ind=1
        AND cv.cdf_meaning="BUILDING"
        AND cv.code_set=220)
       JOIN (lg
       WHERE lg.child_loc_cd=cv.code_value
        AND lg.parent_loc_cd=facility_cd
        AND lg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND lg.location_group_type_cd=facility_var
        AND lg.active_ind=1)
      DETAIL
       building_cd = cv.code_value, temp->list[fac_cnt].buil_list[bul_cnt].res = "Building Found"
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET building = trim(temp->list[fac_cnt].buil_list[bul_cnt].building)
      SET request_13055->cdf_meaning = "BUILDING"
      SET request_13055->code_set = 220
      SET stat = tdbexecute(13000,13000,13055,"REC",request_13055,
       "REC",reply_13055)
      SET stat = initrec(request_13000)
      SET stat = alterlist(request_13000->qual,1)
      SET request_13000->qual[1].active_ind = 1
      SET request_13000->qual[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
      SET request_13000->qual[1].end_effective_dt_tm = cnvtdatetime("30-DEC-2100 18:30:00")
      SET request_13000->qual[1].description = building
      SET request_13000->qual[1].short_desc = building
      SET request_13000->qual[1].cdf_meaning = "BUILDING"
      SET request_13000->qual[1].collation_seq = (reply_13055->max_coll_seq+ 1)
      SET request_13000->qual[1].loc_facility_cd = facility_cd
      SET stat = tdbexecute(13000,13001,13000,"REC",request_13000,
       "REC",reply_13000)
      SET request_13058->location_group_type_mean = "FACILITY"
      SET request_13058->parent_loc_cd = facility_cd
      SET stat = tdbexecute(13000,13000,13058,"REC",request_13058,
       "REC",reply_13058)
      SET building_cd = reply_13000->qual[1].location_cd
      SET stat = alterlist(request_13015->qual,1)
      SET request_13015->qual[1].active_ind = 1
      SET request_13015->qual[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
      SET request_13015->qual[1].cdf_meaning = "FACILITY"
      SET request_13015->qual[1].end_effective_dt_tm = cnvtdatetime("30-DEC-2100 18:30:00")
      SET request_13015->qual[1].child_loc_cd = reply_13000->qual[1].location_cd
      SET request_13015->qual[1].parent_loc_cd = facility_cd
      SET request_13015->qual[1].sequence = (reply_13058->max_sequence+ 1)
      SET stat = tdbexecute(13000,13001,13015,"REC",request_13015,
       "REC",reply_13015)
      SET stat = initrec(request_6024)
      SET stat = alterlist(request_6024->codelist,1)
      SET request_6024->action = 4
      SET request_6024->codelist[1].code = reply_13000->qual[1].location_cd
      SET stat = tdbexecute(13000,13001,6024,"REC",request_6024,
       "REC",reply_6024)
      SET temp->list[fac_cnt].buil_list[bul_cnt].res = "Building Added"
     ENDIF
     FOR (nurs_cnt = 1 TO size(temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list,5))
       SELECT INTO "nl:"
        FROM code_value cv,
         location_group lg
        PLAN (cv
         WHERE cv.code_set=220
          AND cv.display=trim(temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[nurs_cnt].
          nurs_unit)
          AND cv.cdf_meaning="NURSEUNIT"
          AND cv.active_ind=1
          AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
         JOIN (lg
         WHERE lg.child_loc_cd=cv.code_value
          AND lg.parent_loc_cd=building_cd
          AND lg.location_group_type_cd=building_var
          AND lg.active_ind=1
          AND lg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
        DETAIL
         nurse_unit_cd = cv.code_value, temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[
         nurs_cnt].res = "Nurse Unit Found"
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET request_13055->cdf_meaning = "NURSEUNIT"
        SET request_13055->code_set = 220
        SET stat = tdbexecute(13000,13000,13055,"REC",request_13055,
         "REC",reply_13055)
        SET stat = initrec(request_13000)
        SET stat = alterlist(request_13000->qual,1)
        SET request_13000->qual[1].active_ind = 1
        SET request_13000->qual[1].census_ind = 1
        SET request_13000->qual[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
        SET request_13000->qual[1].end_effective_dt_tm = cnvtdatetime("30-DEC-2100 18:30:00")
        SET request_13000->qual[1].cdf_meaning = "NURSEUNIT"
        SET request_13000->qual[1].collation_seq = (reply_13055->max_coll_seq+ 1)
        SET request_13000->qual[1].description = trim(temp->list[fac_cnt].buil_list[bul_cnt].
         nurse_unit_list[nurs_cnt].nurs_unit)
        SET request_13000->qual[1].short_desc = trim(temp->list[fac_cnt].buil_list[bul_cnt].
         nurse_unit_list[nurs_cnt].nurs_unit)
        SET request_13000->qual[1].loc_building_cd = building_cd
        SET request_13000->qual[1].loc_facility_cd = facility_cd
        SET stat = tdbexecute(13000,13001,13000,"REC",request_13000,
         "REC",reply_13000)
        SET nurse_unit_cd = reply_13000->qual[0].location_cd
        SET request_13058->parent_loc_cd = building_cd
        SET request_13058->location_group_type_mean = "BUILDING"
        SET stat = tdbexecute(13000,13000,13058,"REC",request_13058,
         "REC",reply_13058)
        SET stat = alterlist(request_13015->qual,1)
        SET request_13015->qual[0].active_ind = 1
        SET request_13015->qual[0].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
        SET request_13015->qual[0].cdf_meaning = "BUILDING"
        SET request_13015->qual[0].child_loc_cd = nurse_unit_cd
        SET request_13015->qual[0].end_effective_dt_tm = cnvtdatetime("30-DEC-2100 18:30:00")
        SET request_13015->qual[0].parent_loc_cd = building_cd
        SET request_13015->qual[0].sequence = (reply_13058->max_sequence+ 1)
        SET stat = tdbexecute(13000,13001,13015,"REC",request_13015,
         "REC",reply_13015)
        SET temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[nurs_cnt].res = "Nurse Unit Added"
       ENDIF
       SET stat = initrec(request_13050)
       SET request_13050->location_cd = nurse_unit_cd
       SET request_13050->parent_type_mean = "NURSEUNIT"
       FOR (room_cnt = 1 TO size(temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[nurs_cnt].
        room_list,5))
         SET stat = alterlist(request_13050->rooms,room_cnt)
         SELECT
          FROM code_value cv,
           location_group lg
          PLAN (cv
           WHERE cv.display=trim(temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[nurs_cnt].
            room_list[room_cnt].room)
            AND cv.cdf_meaning="ROOM"
            AND cv.active_ind=1
            AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
           JOIN (lg
           WHERE lg.child_loc_cd=cv.code_value
            AND lg.parent_loc_cd=nurse_unit_cd
            AND lg.location_group_type_cd=nurseunit_var
            AND lg.active_ind=1
            AND lg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          ORDER BY lg.parent_loc_cd
          HEAD lg.parent_loc_cd
           ex_room_cd = cv.code_value, ex_short_desc = trim(cv.description), temp->list[fac_cnt].
           buil_list[bul_cnt].nurse_unit_list[nurs_cnt].room_list[room_cnt].res = "Room Found"
          WITH nocounter
         ;end select
         IF (curqual=0)
          SET request_13050->total_new_rooms = (request_13050->total_new_rooms+ 1)
          SET request_13050->rooms[room_cnt].new_room_ind = 1
          SET request_13050->rooms[room_cnt].active_ind = 1
          SET request_13050->rooms[room_cnt].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
          SET request_13050->rooms[room_cnt].census_ind = 1
          SET request_13050->rooms[room_cnt].description = temp->list[fac_cnt].buil_list[bul_cnt].
          nurse_unit_list[nurs_cnt].room_list[room_cnt].room
          SET request_13050->rooms[room_cnt].short_desc = request_13050->rooms[request_13050].
          description
          SET request_13050->rooms[room_cnt].cdf_meaning = "ROOM"
          SET request_13050->rooms[room_cnt].end_effective_dt_tm = cnvtdatetime(
           "30-DEC-2100 18:30:00")
          SET temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[nurs_cnt].room_list[room_cnt].
          res = "Room Added"
         ELSE
          SET request_13050->rooms[room_cnt].location_cd = ex_room_cd
          SET request_13050->rooms[room_cnt].short_desc = ex_short_desc
         ENDIF
         FOR (bed_cnt = 1 TO size(temp->list[fac_cnt].buil_list[bul_cnt].nurse_unit_list[nurs_cnt].
          room_list[room_cnt].bed_list,5))
           SET request_13050->rooms[room_cnt].bed_cnt = (request_13050->rooms[room_cnt].bed_cnt+ 1)
           SET stat = alterlist(request_13050->rooms[room_cnt].beds,request_13050->rooms[room_cnt].
            bed_cnt)
           SET request_13050->rooms[room_cnt].beds[bed_cnt].active_ind = 1
           SET request_13050->rooms[room_cnt].beds[bed_cnt].beg_effective_dt_tm = cnvtdatetime(
            curdate,curtime)
           SET request_13050->rooms[room_cnt].beds[bed_cnt].end_effective_dt_tm = cnvtdatetime(
            "30-DEC-2100 18:30:00")
           SET request_13050->rooms[room_cnt].beds[bed_cnt].census_ind = 1
           SET request_13050->rooms[room_cnt].beds[bed_cnt].description = temp->list[fac_cnt].
           buil_list[bul_cnt].nurse_unit_list[nurs_cnt].room_list[room_cnt].bed_list[bed_cnt].bed
           SET request_13050->rooms[room_cnt].beds[bed_cnt].short_desc = request_13050->rooms[
           room_cnt].beds[bed_cnt].description
           SET request_13050->rooms[room_cnt].beds[bed_cnt].cdf_meaning = "BED"
           IF (bed_cnt=1)
            SET request_13050->rooms[room_cnt].beds[bed_cnt].sequence = 0
           ELSE
            CALL echo("BrefSeq")
            CALL echo(request_13050->rooms[room_cnt].beds[bed_cnt].sequence)
            SET request_13050->rooms[room_cnt].beds[bed_cnt].sequence = (request_13050->rooms[
            room_cnt].beds[(bed_cnt - 1)].sequence+ 1)
            CALL echo("Seq")
            CALL echo(request_13050->rooms[room_cnt].beds[bed_cnt].sequence)
            CALL echo("Bedcnt")
            CALL echo(bed_cnt)
           ENDIF
         ENDFOR
       ENDFOR
       IF (size(request_13050->rooms,5) > 0)
        CALL echorecord(request_13050)
        SET stat = tdbexecute(13000,13001,13050,"REC",request_13050,
         "REC",reply_13050)
       ENDIF
       SET stat = initrec(request_6024)
       SET request_6024->action = 4
       SET stat = alterlist(request_6024->codelist,1)
       SET request_6024->codelist[1].code = nurse_unit_cd
       SET stat = tdbexecute(13000,13001,6024,"REC",request_6024,
        "REC",reply_6024)
     ENDFOR
   ENDFOR
  ELSE
   SET temp->list[fac_cnt].res = "Facility Not Found"
  ENDIF
 ENDFOR
 SELECT INTO  $OUTDEV
  list_facility = substring(1,30,temp->list[d1.seq].facility), list_res = substring(1,30,temp->list[
   d1.seq].res), buil_list_building = substring(1,30,temp->list[d1.seq].buil_list[d2.seq].building),
  buil_list_res = substring(1,30,temp->list[d1.seq].buil_list[d2.seq].res), nurse_unit_list_nurs_unit
   = substring(1,30,temp->list[d1.seq].buil_list[d2.seq].nurse_unit_list[d3.seq].nurs_unit),
  nurse_unit_list_res = substring(1,30,temp->list[d1.seq].buil_list[d2.seq].nurse_unit_list[d3.seq].
   res),
  room_list_room = substring(1,30,temp->list[d1.seq].buil_list[d2.seq].nurse_unit_list[d3.seq].
   room_list[d4.seq].room), room_list_res = substring(1,30,temp->list[d1.seq].buil_list[d2.seq].
   nurse_unit_list[d3.seq].room_list[d4.seq].res), bed_list_bed = substring(1,30,temp->list[d1.seq].
   buil_list[d2.seq].nurse_unit_list[d3.seq].room_list[d4.seq].bed_list[d5.seq].bed)
  FROM (dummyt d1  WITH seq = value(size(temp->list,5))),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   (dummyt d5  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(temp->list[d1.seq].buil_list,5)))
   JOIN (d2
   WHERE maxrec(d3,size(temp->list[d1.seq].buil_list[d2.seq].nurse_unit_list,5)))
   JOIN (d3
   WHERE maxrec(d4,size(temp->list[d1.seq].buil_list[d2.seq].nurse_unit_list[d3.seq].room_list,5)))
   JOIN (d4
   WHERE maxrec(d5,size(temp->list[d1.seq].buil_list[d2.seq].nurse_unit_list[d3.seq].room_list[d4.seq
     ].bed_list,5)))
   JOIN (d5)
  WITH nocounter, separator = " ", format
 ;end select
 CALL updtdminfo(trim(cnvtupper(curprog),3))
#exit_script
 SET last_mod = "000 04/21/2016 KK032244 Initial Release"
END GO
