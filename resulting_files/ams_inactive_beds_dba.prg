CREATE PROGRAM ams_inactive_beds:dba
 PROMPT
  "Select the directory and type the file name below:" = "MINE",
  "Directory" = "",
  "Input File" = ""
  WITH outdev, directory, inputfile
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 FREE RECORD orig_content
 RECORD orig_content(
   1 rec[*]
     2 org_name = vc
     2 nurseunit_name = vc
     2 room_name = vc
     2 bed_name = vc
     2 sequence = i2
 )
 FREE RECORD room_beds
 RECORD room_beds(
   1 orgs[*]
     2 org_desc = vc
     2 nurseunits[*]
       3 nurseunit_desc = vc
       3 rooms[*]
         4 room_desc = vc
         4 beds[*]
           5 bed_desc = vc
           5 seq = i2
 )
 SELECT INTO  $1
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, check = 0, count = 0
  HEAD r.line
   line1 = r.line, check = (check+ 1)
   IF (check > 1)
    IF (textlen(trim(replace(line1,",",""),3)) > 0)
     count = (count+ 1)
     IF (count >= 1)
      row_count = (row_count+ 1), stat = alterlist(orig_content->rec,row_count), orig_content->rec[
      row_count].org_name = piece(line1,",",1,"Not Found"),
      orig_content->rec[row_count].nurseunit_name = piece(line1,",",2,"Not Found"), orig_content->
      rec[row_count].room_name = piece(line1,",",3,"Not Found"), orig_content->rec[row_count].
      bed_name = piece(line1,",",4,"Not Found"),
      orig_content->rec[row_count].sequence = cnvtint(piece(line1,",",5,"Not Found"))
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(orig_content->rec,row_count)
  WITH nocounter, format, separator = ""
 ;end select
 SET org_count = 0
 SET nu_count = 0
 SET room_count = 0
 SET bed_count = 0
 FOR (i = 1 TO value(size(orig_content->rec,5)))
   IF ((orig_content->rec[i].org_name != ""))
    SET org_count = (org_count+ 1)
    SET nu_count = 0
    SET room_count = 0
    SET bed_cnt = 0
    SET stat = alterlist(room_beds->orgs,org_count)
    SET room_beds->orgs[org_count].org_desc = cnvtupper(trim(replace(replace(replace(replace(replace(
           replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                      replace(replace(replace(replace(replace(replace(replace(replace(replace(replace
                               (replace(replace(replace(replace(replace(orig_content->rec[i].org_name,
                                     " ","",0),",","",0),"~","",0),"`","",0),"!","",0),"@","",0),"#",
                               "",0),"$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(","",0),")",
                        "",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),
                "\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/",
        "",0),"?","",0),8))
   ENDIF
   IF ((orig_content->rec[i].nurseunit_name != ""))
    SET nu_count = (nu_count+ 1)
    SET stat = alterlist(room_beds->orgs[org_count].nurseunits,nu_count)
    SET room_beds->orgs[org_count].nurseunits[nu_count].nurseunit_desc = orig_content->rec[i].
    nurseunit_name
    SET room_count = 0
   ENDIF
   IF ((orig_content->rec[i].room_name != ""))
    SET room_count = (room_count+ 1)
    SET stat = alterlist(room_beds->orgs[org_count].nurseunits[nu_count].rooms,room_count)
    SET room_beds->orgs[org_count].nurseunits[nu_count].rooms[room_count].room_desc = cnvtupper(trim(
      replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace
                 (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                            replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                     orig_content->rec[i].room_name," ","",0),",","",0),"~","",0),"`",
                                  "",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",0),"^","",0),
                           "&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_","",0),"+","",0),"=",
                    "",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'",
            "",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),8))
    SET bed_count = 0
   ENDIF
   IF ((orig_content->rec[i].bed_name != ""))
    SET bed_count = (bed_count+ 1)
    SET stat = alterlist(room_beds->orgs[org_count].nurseunits[nu_count].rooms[room_count].beds,
     bed_count)
    SET room_beds->orgs[org_count].nurseunits[nu_count].rooms[room_count].beds[bed_count].bed_desc =
    cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                          replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                   replace(replace(orig_content->rec[i].bed_name," ","",0),",","",0),
                                   "~","",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                             "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_","",
                      0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0),";","",
              0),'"',"",0),"'","",0),"<","",0),"","",0),".","",0),"/","",0),"?","",0),8))
    SET room_beds->orgs[org_count].nurseunits[nu_count].rooms[room_count].beds[bed_count].seq =
    orig_content->rec[i].sequence
   ENDIF
 ENDFOR
 CALL echorecord(room_beds)
 DECLARE room_cd = f8 WITH public
 DECLARE org_code = f8 WITH public
 DECLARE inact = i4 WITH public
 FREE RECORD request_new
 RECORD request_new(
   1 location_cd = f8
   1 organization_id = f8
   1 rooms[*]
     2 room_cd = f8
     2 updt_cnt = i4
     2 sequence = i4
     2 class_cd = f8
     2 med_service_cd = f8
     2 isolation_cd = f8
     2 resource_ind = i2
     2 active_ind = i2
     2 census_ind = i2
     2 fixed_bed_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 description = c200
     2 short_desc = c15
     2 definition = c100
     2 collation_seq = i4
     2 facility_accn_prefix = c5
     2 bed_cnt = i4
     2 beds[*]
       3 bed_cd = f8
       3 updt_cnt = i4
       3 sequence = i4
       3 resource_ind = i2
       3 active_ind = i2
       3 census_ind = i2
       3 dup_bed_ind = i2
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 description = c200
       3 short_desc = c15
       3 definition = c100
       3 collation_seq = i4
       3 facility_accn_prefix = c5
       3 reserve_ind = i2
 )
 FREE RECORD bed_inact
 RECORD bed_inact(
   1 qual[*]
     2 parent_loc_cd = f8
     2 child_loc_cd = f8
 )
 FREE RECORD request_inact
 RECORD request_inact(
   1 qual[*]
     2 parent_loc_cd = f8
     2 child_loc_cd = f8
     2 cdf_meaning = c12
     2 root_loc_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
 )
 DEFINE rtl2 "ams_inactive_beds_csv.csv"
 FREE RECORD orig_content
 RECORD orig_content(
   1 rec[*]
     2 org_name = vc
     2 nurseunit_name = vc
     2 room_name = vc
     2 bed_name = vc
     2 sequence = i2
 )
 FREE RECORD room_beds
 RECORD room_beds(
   1 orgs[*]
     2 org_desc = vc
     2 nurseunits[*]
       3 nurseunit_desc = vc
       3 rooms[*]
         4 room_desc = vc
         4 beds[*]
           5 bed_desc = vc
           5 seq = i2
 )
 SELECT INTO  $1
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, check = 0, count = 0
  HEAD r.line
   line1 = r.line, check = (check+ 1)
   IF (check > 1)
    IF (textlen(trim(replace(line1,",",""),3)) > 0)
     count = (count+ 1)
     IF (count >= 1)
      row_count = (row_count+ 1), stat = alterlist(orig_content->rec,row_count), orig_content->rec[
      row_count].org_name = piece(line1,",",1,"Not Found"),
      orig_content->rec[row_count].nurseunit_name = piece(line1,",",2,"Not Found"), orig_content->
      rec[row_count].room_name = piece(line1,",",3,"Not Found"), orig_content->rec[row_count].
      bed_name = piece(line1,",",4,"Not Found"),
      orig_content->rec[row_count].sequence = cnvtint(piece(line1,",",5,"Not Found"))
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(orig_content->rec,row_count)
  WITH nocounter, format, separator = ""
 ;end select
 SET org_count = 0
 SET nu_count = 0
 SET room_count = 0
 SET bed_count = 0
 FOR (i = 1 TO value(size(orig_content->rec,5)))
   IF ((orig_content->rec[i].org_name != ""))
    SET org_count = (org_count+ 1)
    SET nu_count = 0
    SET room_count = 0
    SET bed_cnt = 0
    SET stat = alterlist(room_beds->orgs,org_count)
    SET room_beds->orgs[org_count].org_desc = cnvtupper(trim(replace(replace(replace(replace(replace(
           replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                      replace(replace(replace(replace(replace(replace(replace(replace(replace(replace
                               (replace(replace(replace(replace(replace(orig_content->rec[i].org_name,
                                     " ","",0),",","",0),"~","",0),"`","",0),"!","",0),"@","",0),"#",
                               "",0),"$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(","",0),")",
                        "",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),
                "\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/",
        "",0),"?","",0),8))
   ENDIF
   IF ((orig_content->rec[i].nurseunit_name != ""))
    SET nu_count = (nu_count+ 1)
    SET stat = alterlist(room_beds->orgs[org_count].nurseunits,nu_count)
    SET room_beds->orgs[org_count].nurseunits[nu_count].nurseunit_desc = orig_content->rec[i].
    nurseunit_name
    SET room_count = 0
   ENDIF
   IF ((orig_content->rec[i].room_name != ""))
    SET room_count = (room_count+ 1)
    SET stat = alterlist(room_beds->orgs[org_count].nurseunits[nu_count].rooms,room_count)
    SET room_beds->orgs[org_count].nurseunits[nu_count].rooms[room_count].room_desc = cnvtupper(trim(
      replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace
                 (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                            replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                     orig_content->rec[i].room_name," ","",0),",","",0),"~","",0),"`",
                                  "",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",0),"^","",0),
                           "&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_","",0),"+","",0),"=",
                    "",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'",
            "",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),8))
    SET bed_count = 0
   ENDIF
   IF ((orig_content->rec[i].bed_name != ""))
    SET bed_count = (bed_count+ 1)
    SET stat = alterlist(room_beds->orgs[org_count].nurseunits[nu_count].rooms[room_count].beds,
     bed_count)
    SET room_beds->orgs[org_count].nurseunits[nu_count].rooms[room_count].beds[bed_count].bed_desc =
    cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                          replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                   replace(replace(orig_content->rec[i].bed_name," ","",0),",","",0),
                                   "~","",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                             "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_","",
                      0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0),";","",
              0),'"',"",0),"'","",0),"<","",0),"","",0),".","",0),"/","",0),"?","",0),8))
    SET room_beds->orgs[org_count].nurseunits[nu_count].rooms[room_count].beds[bed_count].seq =
    orig_content->rec[i].sequence
   ENDIF
 ENDFOR
 CALL echorecord(room_beds)
 SET cnt = 0
 FOR (cnt = 1 TO size(room_beds->orgs,5))
  SELECT INTO "nl:"
   o.org_name, o.organization_id, l.location_cd
   FROM organization o,
    location l
   PLAN (o
    WHERE (o.org_name_key=room_beds->orgs[cnt].org_desc)
     AND o.active_ind=1
     AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.organization_id=o.organization_id
     AND l.location_type_cd=783.00)
   ORDER BY o.organization_id
   HEAD o.organization_id
    request_new->organization_id = o.organization_id, org_code = l.location_cd
   WITH nocounter
  ;end select
  FOR (cnt1 = 1 TO size(room_beds->orgs[cnt].nurseunits,5))
    SELECT INTO "nl:"
     c1.code_value
     FROM location_group lg1,
      location_group lg2,
      code_value c1
     PLAN (lg1
      WHERE lg1.parent_loc_cd=org_code
       AND lg1.root_loc_cd=0.0
       AND lg1.active_ind=1
       AND lg1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND lg1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND lg1.active_status_cd != 0.0)
      JOIN (lg2
      WHERE lg2.parent_loc_cd=lg1.child_loc_cd
       AND lg2.root_loc_cd=0.0
       AND lg2.active_ind=1
       AND lg2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND lg2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND lg2.active_status_cd != 0.0)
      JOIN (c1
      WHERE c1.code_value=lg2.child_loc_cd
       AND (c1.description=room_beds->orgs[cnt].nurseunits[cnt1].nurseunit_desc)
       AND c1.cdf_meaning="NURSEUNIT"
       AND c1.code_set=220
       AND c1.active_ind=1
       AND c1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND c1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     ORDER BY c1.code_value
     HEAD c1.code_value
      request_new->location_cd = c1.code_value
     WITH nocounter
    ;end select
    FOR (cnt2 = 1 TO size(room_beds->orgs[cnt].nurseunits[cnt1].rooms,5))
     SELECT INTO "nl:"
      cv.*
      FROM location_group lg1,
       code_value cv
      PLAN (lg1
       WHERE (lg1.parent_loc_cd=request_new->location_cd)
        AND lg1.root_loc_cd=0.0
        AND lg1.active_ind=1
        AND lg1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND lg1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
        AND lg1.active_status_cd != 0.0)
       JOIN (cv
       WHERE cv.code_value=lg1.child_loc_cd
        AND (cv.display_key=room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].room_desc)
        AND cv.cdf_meaning="ROOM"
        AND cv.active_ind=1
        AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      ORDER BY cv.code_value
      HEAD cv.code_value
       stat = alterlist(request_new->rooms,cnt2), request_new->rooms[cnt2].room_cd = cv.code_value,
       request_new->rooms[cnt2].updt_cnt = cv.updt_cnt,
       request_new->rooms[cnt2].beg_effective_dt_tm = cv.begin_effective_dt_tm, request_new->rooms[
       cnt2].end_effective_dt_tm = cv.end_effective_dt_tm, request_new->rooms[cnt2].short_desc = cv
       .display,
       request_new->rooms[cnt2].description = cv.description, request_new->rooms[cnt2].sequence = 0,
       request_new->rooms[cnt2].class_cd = 0.0,
       request_new->rooms[cnt2].med_service_cd = 0.0, request_new->rooms[cnt2].isolation_cd = 0.0,
       request_new->rooms[cnt2].resource_ind = 0,
       request_new->rooms[cnt2].census_ind = 1, request_new->rooms[cnt2].fixed_bed_ind = 0,
       request_new->rooms[cnt2].active_ind = cv.active_ind,
       request_new->rooms[cnt2].collation_seq = 0, request_new->rooms[cnt2].bed_cnt = value(size(
         room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds,5))
      WITH nocounter
     ;end select
     FOR (cnt3 = 1 TO size(room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds,5))
       SELECT INTO "nl:"
        lg1.parent_loc_cd, cv.code_value, cv.updt_cnt
        FROM location_group lg1,
         code_value cv
        PLAN (lg1
         WHERE (lg1.parent_loc_cd=request_new->rooms[cnt2].room_cd)
          AND (lg1.sequence=room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds[cnt3].seq)
          AND lg1.root_loc_cd=0.0
          AND lg1.active_ind=1
          AND lg1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
          AND lg1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
          AND lg1.active_status_cd != 0.0)
         JOIN (cv
         WHERE cv.code_value=lg1.child_loc_cd
          AND (cv.display_key=room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds[cnt3].bed_desc)
          AND cv.cdf_meaning="BED"
          AND cv.active_ind=1
          AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
        ORDER BY cv.code_value
        HEAD cv.code_value
         stat = alterlist(request_new->rooms[cnt2].beds,cnt3), request_new->rooms[cnt2].beds[cnt3].
         bed_cd = cv.code_value, request_new->rooms[cnt2].beds[cnt3].updt_cnt = cv.updt_cnt,
         request_new->rooms[cnt2].beds[cnt3].active_ind = cv.active_ind, request_new->rooms[cnt2].
         beds[cnt3].census_ind = 1, request_new->rooms[cnt2].beds[cnt3].beg_effective_dt_tm = cv
         .begin_effective_dt_tm,
         request_new->rooms[cnt2].beds[cnt3].end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
         request_new->rooms[cnt2].beds[cnt3].description = cv.description, request_new->rooms[cnt2].
         beds[cnt3].short_desc = cv.display,
         request_new->rooms[cnt2].beds[cnt3].reserve_ind = 0, inact = (inact+ 1), stat = alterlist(
          bed_inact->qual,inact),
         bed_inact->qual[inact].parent_loc_cd = lg1.parent_loc_cd, bed_inact->qual[inact].
         child_loc_cd = cv.code_value
        WITH nocounter
       ;end select
     ENDFOR
    ENDFOR
    CALL echorecord(request_new)
    EXECUTE loc_chg_room_bed:dba  WITH replace("REQUEST",request_new)
  ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  lg.*
  FROM (dummyt d  WITH seq = value(size(bed_inact->qual,5))),
   location_group lg
  PLAN (d)
   JOIN (lg
   WHERE (lg.parent_loc_cd=bed_inact->qual[d.seq].parent_loc_cd)
    AND (lg.child_loc_cd=bed_inact->qual[d.seq].child_loc_cd)
    AND lg.root_loc_cd=0.0)
  ORDER BY lg.child_loc_cd
  HEAD REPORT
   cnt4 = 0
  HEAD lg.child_loc_cd
   cnt4 = (cnt4+ 1),
   CALL echo(cnt4), stat = alterlist(request_inact->qual,cnt4),
   request_inact->qual[cnt4].parent_loc_cd = lg.parent_loc_cd, request_inact->qual[cnt4].child_loc_cd
    = lg.child_loc_cd, request_inact->qual[cnt4].cdf_meaning = "ROOM",
   request_inact->qual[cnt4].active_ind = 0, request_inact->qual[cnt4].active_status_cd = 192.00,
   request_inact->qual[cnt4].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   request_inact->qual[cnt4].end_effective_dt_tm = cnvtdatetime(curdate,curtime3), request_inact->
   qual[cnt4].root_loc_cd = 0.0, request_inact->qual[cnt4].updt_cnt = lg.updt_cnt
  WITH nocounter
 ;end select
 CALL echorecord(request_inact)
 EXECUTE loc_chg_loc_group_active:dba  WITH replace("REQUEST",request_inact)
 SELECT INTO  $OUTDEV
  status = "Succesfully Inactivated all the given beds in the respected oorganizations"
  FROM dummyt d1
  WITH nocounter, format
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
