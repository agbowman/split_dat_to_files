CREATE PROGRAM census:dba
 PAINT
 SET width = 132
 SET modify = system
#1000_start
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 2000_menu TO 2099_menu_exit
 EXECUTE FROM 6000_border TO 6099_border_exit
 CASE (option)
  OF 1:
   EXECUTE FROM 6000_accept_fac TO 6099_accept_fac_exit
  OF 2:
   EXECUTE FROM 6000_accept_fac TO 6099_accept_fac_exit
   EXECUTE FROM 6000_accept_build TO 6099_accept_build_exit
  OF 3:
   EXECUTE FROM 6000_accept_fac TO 6099_accept_fac_exit
   EXECUTE FROM 6000_accept_build TO 6099_accept_build_exit
   EXECUTE FROM 6000_accept_nur TO 6099_accept_nur_exit
  OF 4:
   EXECUTE FROM 6000_accept_fac TO 6099_accept_fac_exit
   EXECUTE FROM 6000_accept_build TO 6099_accept_build_exit
   EXECUTE FROM 6000_accept_nur TO 6099_accept_nur_exit
   EXECUTE FROM 6000_accept_room TO 6099_accept_room_exit
  OF 5:
   EXECUTE FROM 6000_accept_fac TO 6099_accept_fac_exit
   EXECUTE FROM 6000_accept_build TO 6099_accept_build_exit
   EXECUTE FROM 6000_accept_nur TO 6099_accept_nur_exit
   EXECUTE FROM 6000_accept_room TO 6099_accept_room_exit
   EXECUTE FROM 6000_accept_bed TO 6099_accept_bed_exit
   EXECUTE FROM 9000_clear TO 9099_clear_exit
   EXECUTE FROM 7000_load_locations TO 7099_load_locations_exit
  ELSE
   GO TO 9999_end
 ENDCASE
 EXECUTE FROM 9000_clear TO 9099_clear_exit
 EXECUTE FROM 7000_load_locations TO 7099_load_locations_exit
 EXECUTE FROM 7000_load_display TO 7099_load_display_exit
 EXECUTE FROM 8000_display TO 8099_display_exit
 GO TO 1000_start
#1000_initialize
 SET option = 0
 SET facility_cd = 0.0
 SET build_cd = 0.0
 SET nurse_unit_cd = 0.0
 SET room_cd = 0.0
 SET bed_cd = 0.0
 SET facility_type_cd = 0.0
 SET build_type_cd = 0.0
 SET nurse_unit_type_cd = 0.0
 SET ambulatory_type_cd = 0.0
 SET room_type_cd = 0.0
 SET bed_type_cd = 0.0
 SET facility_disp = fillstring(40," ")
 SET build_disp = fillstring(40," ")
 SET nurse_unit_disp = fillstring(40," ")
 SET room_disp = fillstring(40," ")
 SET bed_disp = fillstring(40," ")
 SET fill40 = fillstring(40," ")
 SET fill55 = fillstring(55," ")
 SET fill130 = fillstring(130,"-")
 SET fac_cnt = 0
 SET build_cnt = 0
 SET nu_cnt = 0
 SET room_cnt = 0
 SET bed_cnt = 0
 SET drows = 0
 SET first_time_yn = "Y"
 SET nbr_encntr_types = 0
 SET finnbr_type_cd = 0.0
 SET parser_buffer[500] = fillstring(132," ")
 SET parser_number = 0
 SET file_name = "tempaudcensus"
 SET male_cd = 0.0
 SET female_cd = 0.0
 SET unknown_cd = 0.0
 SET encntr_domain_type_cd = 0.0
 SET nbr_tables = 6
 SET table_name[20] = fillstring(32," ")
 SET table_name[1] = "PERSON"
 SET table_name[2] = "PERSON_ALIAS"
 SET table_name[3] = "PERSON_NAME"
 SET table_name[4] = "ENCOUNTER"
 SET table_name[5] = "ENCNTR_ALIAS"
 SET table_name[6] = "ENCNTR_DOMAIN"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=222
   AND c.cdf_meaning="FACILITY"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   facility_type_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=222
   AND c.cdf_meaning="BUILDING"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   build_type_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=222
   AND c.cdf_meaning="NURSEUNIT"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   nurse_unit_type_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=222
   AND c.cdf_meaning="AMBULATORY"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   ambulatory_type_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=222
   AND c.cdf_meaning="ROOM"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   room_type_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=222
   AND c.cdf_meaning="BED"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   bed_type_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=319
   AND c.cdf_meaning="FIN NBR"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   finnbr_type_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=57
   AND c.cdf_meaning="MALE"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   male_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=57
   AND c.cdf_meaning="FEMALE"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   female_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=57
   AND c.cdf_meaning="UNKNOWN"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   unknown_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=339
   AND c.cdf_meaning="CENSUS"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   encntr_domain_type_cd = c.code_value
  WITH nocounter
 ;end select
 FREE SET loc
 RECORD loc(
   1 build_cnt = i4
   1 build[*]
     2 build_cd = f8
     2 build_disp = c40
     2 nu_cnt = i4
     2 nu[*]
       3 nu_cd = f8
       3 nu_disp = c40
       3 room_cnt = i4
       3 room[*]
         4 room_cd = f8
         4 room_disp = c40
         4 bed_cnt = i4
         4 bed[*]
           5 bed_cd = f8
           5 bed_disp = c40
 )
 FREE SET disp
 RECORD disp(
   1 list[*]
     2 fac_disp = c5
     2 build_disp = c5
     2 nu_disp = c5
     2 room_disp = c5
     2 bed_disp = c5
     2 person_id = f8
     2 encntr_id = f8
     2 name_full_formatted = c30
     2 encntr_type_disp = c12
     2 reg_dt_tm = dq8
     2 sex_disp = c1
     2 birth_dt_tm = dq8
     2 finnbr_number = c15
 )
 FREE SET audit
 RECORD audit(
   1 list[100]
     2 attr_name = c34
     2 attr_type = c10
 )
#1099_initialize_exit
#2000_menu
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,23,132)
 CALL text(2,1,"CENSUS REPORT",w)
 CALL text(7,5," 1  Facility")
 CALL text(9,5," 2  Facility, Building")
 CALL text(11,5," 3  Facility, Building, Nurse Unit")
 CALL text(13,5," 4  Facility, Building, Nurse Unit, Room")
 CALL text(15,5," 5  Facility, Building, Nurse Unit, Room, Bed")
 CALL text(17,5," 6  Exit")
 CALL text(24,1,"Select Option ? ")
 CALL accept(24,17,"9;",5
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6))
 CALL clear(24,1)
 SET option = curaccept
 IF (option=6)
  GO TO 9999_end
 ENDIF
#2099_menu_exit
#6000_border
 CALL clear(1,1)
 CALL video(r)
 CALL box(1,1,12,132)
 CALL box(1,1,3,132)
 CALL clear(2,2,130)
 CALL text(02,05,"CENSUS REPORT")
 CALL video(n)
#6099_border_exit
#6000_accept_fac
 CALL text(06,05,"Facility")
 CALL text(11,115,"<HELP>")
 SET help =
 SELECT INTO "NL:"
  c.code_value, c.display
  FROM code_value c
  WHERE c.code_set=220
   AND c.cdf_meaning="FACILITY"
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  ORDER BY c.collation_seq, c.display_key
  WITH nocounter
 ;end select
 CALL accept(06,22,"9(11);DF")
 SET facility_cd = curaccept
 SELECT INTO "nl:"
  c.display
  FROM code_value c
  WHERE c.code_value=facility_cd
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   facility_disp = c.display
  WITH nocounter
 ;end select
 CALL text(06,35,facility_disp)
 SET help = off
#6099_accept_fac_exit
#6000_accept_build
 CALL text(07,05,"Building")
 SET help =
 SELECT INTO "NL:"
  l.child_loc_cd, c.display
  FROM location_group l,
   code_value c
  WHERE l.parent_loc_cd=facility_cd
   AND l.location_group_type_cd=facility_type_cd
   AND l.active_ind=true
   AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
   AND c.code_value=l.child_loc_cd
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  ORDER BY c.display
  WITH nocounter
 ;end select
 CALL accept(07,22,"9(11);DSF")
 IF (curscroll=2)
  CALL text(06,35,fill40)
  CALL text(07,22,fill55)
  GO TO 6000_accept_fac
 ENDIF
 SET build_cd = curaccept
 SELECT INTO "nl:"
  c.display
  FROM code_value c
  WHERE c.code_value=build_cd
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   build_disp = c.display
  WITH nocounter
 ;end select
 CALL text(07,35,build_disp)
 SET help = off
#6099_accept_build_exit
#6000_accept_nur
 CALL text(08,05,"Nurse Unit")
 SET help =
 SELECT INTO "NL:"
  l.child_loc_cd, c.display
  FROM location_group l,
   code_value c
  WHERE l.parent_loc_cd=build_cd
   AND l.location_group_type_cd=build_type_cd
   AND l.active_ind=true
   AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
   AND c.code_value=l.child_loc_cd
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  ORDER BY c.display
  WITH nocounter
 ;end select
 CALL accept(08,22,"9(11);DSF")
 IF (curscroll=2)
  CALL text(07,35,fill40)
  CALL text(08,22,fill55)
  GO TO 6000_accept_build
 ENDIF
 SET nurse_unit_cd = curaccept
 SELECT INTO "nl:"
  c.display
  FROM code_value c
  WHERE c.code_value=nurse_unit_cd
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   nurse_unit_disp = c.display
  WITH nocounter
 ;end select
 CALL text(08,35,nurse_unit_disp)
 SET help = off
#6099_accept_nur_exit
#6000_accept_room
 CALL text(09,05,"Room")
 SET help =
 SELECT INTO "NL:"
  l.child_loc_cd, c.display
  FROM location_group l,
   code_value c
  WHERE l.parent_loc_cd=nurse_unit_cd
   AND ((l.location_group_type_cd=nurse_unit_type_cd) OR (l.location_group_type_cd=ambulatory_type_cd
  ))
   AND l.active_ind=true
   AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
   AND c.code_value=l.child_loc_cd
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  ORDER BY c.display
  WITH nocounter
 ;end select
 CALL accept(09,22,"9(11);DSF")
 IF (curscroll=2)
  CALL text(08,35,fill40)
  CALL text(09,22,fill55)
  GO TO 6000_accept_nur
 ENDIF
 SET room_cd = curaccept
 SELECT INTO "nl:"
  c.display
  FROM code_value c
  WHERE c.code_value=room_cd
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   room_disp = c.display
  WITH nocounter
 ;end select
 CALL text(09,35,room_disp)
 SET help = off
#6099_accept_room_exit
#6000_accept_bed
 CALL text(10,05,"Bed")
 SET help =
 SELECT INTO "NL:"
  l.child_loc_cd, c.display
  FROM location_group l,
   code_value c
  WHERE l.parent_loc_cd=room_cd
   AND l.location_group_type_cd=room_type_cd
   AND l.active_ind=true
   AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
   AND c.code_value=l.child_loc_cd
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  ORDER BY c.display
  WITH nocounter
 ;end select
 CALL accept(10,22,"9(11);DSF")
 IF (curscroll=2)
  CALL text(09,35,fill40)
  CALL text(10,22,fill55)
  GO TO 6000_accept_room
 ENDIF
 SET bed_cd = curaccept
 SELECT INTO "nl:"
  c.display
  FROM code_value c
  WHERE c.code_value=bed_cd
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   bed_disp = c.display
  WITH nocounter
 ;end select
 CALL text(10,35,bed_disp)
 SET help = off
#6099_accept_bed_exit
#7000_load_locations
 CALL text(24,3,"Loading locations...")
 CASE (option)
  OF 1:
   SELECT INTO "NL:"
    l.child_loc_cd, c.display
    FROM location_group l,
     code_value c
    WHERE l.parent_loc_cd=facility_cd
     AND l.location_group_type_cd=facility_type_cd
     AND l.active_ind=true
     AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND c.code_value=l.child_loc_cd
     AND c.active_ind=true
     AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
     AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
    ORDER BY c.display
    DETAIL
     build_cnt += 1, stat = alterlist(loc->build,build_cnt), loc->build[build_cnt].build_cd = l
     .child_loc_cd,
     loc->build[build_cnt].build_disp = c.display
    WITH nocounter
   ;end select
   SET loc->build_cnt = build_cnt
   SET build_cnt = 0
   FOR (x = 1 TO loc->build_cnt)
     SELECT INTO "NL:"
      l.child_loc_cd, c.display
      FROM location_group l,
       code_value c
      WHERE (l.parent_loc_cd=loc->build[x].build_cd)
       AND l.location_group_type_cd=build_type_cd
       AND l.active_ind=true
       AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND c.code_value=l.child_loc_cd
       AND c.active_ind=true
       AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
      ORDER BY c.display
      DETAIL
       nu_cnt += 1, stat = alterlist(loc->build[x].nu,nu_cnt), loc->build[x].nu[nu_cnt].nu_cd = l
       .child_loc_cd,
       loc->build[x].nu[nu_cnt].nu_disp = c.display
      WITH nocounter
     ;end select
     SET loc->build[x].nu_cnt = nu_cnt
     SET nu_cnt = 0
   ENDFOR
   FOR (x = 1 TO loc->build_cnt)
     FOR (y = 1 TO loc->build[x].nu_cnt)
       SELECT INTO "NL:"
        l.child_loc_cd, c.display
        FROM location_group l,
         code_value c
        WHERE (l.parent_loc_cd=loc->build[x].nu[y].nu_cd)
         AND ((l.location_group_type_cd=nurse_unit_type_cd) OR (l.location_group_type_cd=
        ambulatory_type_cd))
         AND l.active_ind=true
         AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
         AND c.code_value=l.child_loc_cd
         AND c.active_ind=true
         AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
         AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
        ORDER BY c.display
        DETAIL
         room_cnt += 1, stat = alterlist(loc->build[x].nu[y].room,room_cnt), loc->build[x].nu[y].
         room[room_cnt].room_cd = l.child_loc_cd,
         loc->build[x].nu[y].room[room_cnt].room_disp = c.display
        WITH nocounter
       ;end select
       SET loc->build[x].nu[y].room_cnt = room_cnt
       SET room_cnt = 0
     ENDFOR
   ENDFOR
   FOR (x = 1 TO loc->build_cnt)
     FOR (y = 1 TO loc->build[x].nu_cnt)
       FOR (z = 1 TO loc->build[x].nu[y].room_cnt)
         SELECT INTO "NL:"
          l.child_loc_cd, c.display
          FROM location_group l,
           code_value c
          WHERE (l.parent_loc_cd=loc->build[x].nu[y].room[z].room_cd)
           AND l.location_group_type_cd=room_type_cd
           AND l.active_ind=true
           AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
           AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
           AND c.code_value=l.child_loc_cd
           AND c.active_ind=true
           AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
           AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
          ORDER BY c.display
          DETAIL
           bed_cnt += 1, stat = alterlist(loc->build[x].nu[y].room[z].bed,bed_cnt), loc->build[x].nu[
           y].room[z].bed[bed_cnt].bed_cd = l.child_loc_cd,
           loc->build[x].nu[y].room[z].bed[bed_cnt].bed_disp = c.display
          WITH nocounter
         ;end select
         SET loc->build[x].nu[y].room[z].bed_cnt = bed_cnt
         SET bed_cnt = 0
       ENDFOR
     ENDFOR
   ENDFOR
  OF 2:
   SET loc->build_cnt = 1
   SET stat = alterlist(loc->build,1)
   SET loc->build[1].build_cd = build_cd
   SET loc->build[1].build_disp = build_disp
   SELECT INTO "NL:"
    l.child_loc_cd, c.display
    FROM location_group l,
     code_value c
    WHERE l.parent_loc_cd=build_cd
     AND l.location_group_type_cd=build_type_cd
     AND l.active_ind=true
     AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND c.code_value=l.child_loc_cd
     AND c.active_ind=true
     AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
     AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
    ORDER BY c.display
    DETAIL
     nu_cnt += 1, stat = alterlist(loc->build[1].nu,nu_cnt), loc->build[1].nu[nu_cnt].nu_cd = l
     .child_loc_cd,
     loc->build[1].nu[nu_cnt].nu_disp = c.display
    WITH nocounter
   ;end select
   SET loc->build[1].nu_cnt = nu_cnt
   SET nu_cnt = 0
   FOR (x = 1 TO loc->build[1].nu_cnt)
     SELECT INTO "NL:"
      l.child_loc_cd, c.display
      FROM location_group l,
       code_value c
      WHERE (l.parent_loc_cd=loc->build[1].nu[x].nu_cd)
       AND ((l.location_group_type_cd=nurse_unit_type_cd) OR (l.location_group_type_cd=
      ambulatory_type_cd))
       AND l.active_ind=true
       AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND c.code_value=l.child_loc_cd
       AND c.active_ind=true
       AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
      ORDER BY c.display
      DETAIL
       room_cnt += 1, stat = alterlist(loc->build[1].nu[x].room,room_cnt), loc->build[1].nu[x].room[
       room_cnt].room_cd = l.child_loc_cd,
       loc->build[1].nu[x].room[room_cnt].room_disp = c.display
      WITH nocounter
     ;end select
     SET loc->build[1].nu[x].room_cnt = room_cnt
     SET room_cnt = 0
   ENDFOR
   FOR (x = 1 TO loc->build[1].nu_cnt)
     FOR (y = 1 TO loc->build[1].nu[x].room_cnt)
       SELECT INTO "NL:"
        l.child_loc_cd, c.display
        FROM location_group l,
         code_value c
        WHERE (l.parent_loc_cd=loc->build[1].nu[x].room[y].room_cd)
         AND l.location_group_type_cd=room_type_cd
         AND l.active_ind=true
         AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
         AND c.code_value=l.child_loc_cd
         AND c.active_ind=true
         AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
         AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
        ORDER BY c.display
        DETAIL
         bed_cnt += 1, stat = alterlist(loc->build[1].nu[x].room[y].bed,bed_cnt), loc->build[1].nu[x]
         .room[y].bed[bed_cnt].bed_cd = l.child_loc_cd,
         loc->build[1].nu[x].room[y].bed[bed_cnt].bed_disp = c.display
        WITH nocounter
       ;end select
       SET loc->build[1].nu[x].room[y].bed_cnt = bed_cnt
       SET bed_cnt = 0
     ENDFOR
   ENDFOR
  OF 3:
   SET loc->build_cnt = 1
   SET stat = alterlist(loc->build,1)
   SET loc->build[1].build_cd = build_cd
   SET loc->build[1].build_disp = build_disp
   SET loc->build[1].nu_cnt = 1
   SET stat = alterlist(loc->build[1].nu,1)
   SET loc->build[1].nu[1].nu_cd = nurse_unit_cd
   SET loc->build[1].nu[1].nu_disp = nurse_unit_disp
   SELECT INTO "NL:"
    l.child_loc_cd, c.display
    FROM location_group l,
     code_value c
    WHERE l.parent_loc_cd=nurse_unit_cd
     AND ((l.location_group_type_cd=nurse_unit_type_cd) OR (l.location_group_type_cd=
    ambulatory_type_cd))
     AND l.active_ind=true
     AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND c.code_value=l.child_loc_cd
     AND c.active_ind=true
     AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
     AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
    ORDER BY c.display
    DETAIL
     room_cnt += 1, stat = alterlist(loc->build[1].nu[1].room,room_cnt), loc->build[1].nu[1].room[
     room_cnt].room_cd = l.child_loc_cd,
     loc->build[1].nu[1].room[room_cnt].room_disp = c.display
    WITH nocounter
   ;end select
   SET loc->build[1].nu[1].room_cnt = room_cnt
   SET room_cnt = 0
   FOR (x = 1 TO loc->build[1].nu[1].room_cnt)
     SELECT INTO "NL:"
      l.child_loc_cd, c.display
      FROM location_group l,
       code_value c
      WHERE (l.parent_loc_cd=loc->build[1].nu[1].room[x].room_cd)
       AND l.location_group_type_cd=room_type_cd
       AND l.active_ind=true
       AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND c.code_value=l.child_loc_cd
       AND c.active_ind=true
       AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
      ORDER BY c.display
      DETAIL
       bed_cnt += 1, stat = alterlist(loc->build[1].nu[1].room[x].bed,bed_cnt), loc->build[1].nu[1].
       room[x].bed[bed_cnt].bed_cd = l.child_loc_cd,
       loc->build[1].nu[1].room[x].bed[bed_cnt].bed_disp = c.display
      WITH nocounter
     ;end select
     SET loc->build[1].nu[1].room[x].bed_cnt = bed_cnt
     SET bed_cnt = 0
   ENDFOR
  OF 4:
   SET loc->build_cnt = 1
   SET stat = alterlist(loc->build,1)
   SET loc->build[1].build_cd = build_cd
   SET loc->build[1].build_disp = build_disp
   SET loc->build[1].nu_cnt = 1
   SET stat = alterlist(loc->build[1].nu,1)
   SET loc->build[1].nu[1].nu_cd = nurse_unit_cd
   SET loc->build[1].nu[1].nu_disp = nurse_unit_disp
   SET loc->build[1].nu[1].room_cnt = 1
   SET stat = alterlist(loc->build[1].nu[1].room,1)
   SET loc->build[1].nu[1].room[1].room_cd = room_cd
   SET loc->build[1].nu[1].room[1].room_disp = room_disp
   SELECT INTO "NL:"
    l.child_loc_cd, c.display
    FROM location_group l,
     code_value c
    WHERE l.parent_loc_cd=room_cd
     AND l.location_group_type_cd=room_type_cd
     AND l.active_ind=true
     AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND c.code_value=l.child_loc_cd
     AND c.active_ind=true
     AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
     AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
    ORDER BY c.display
    DETAIL
     bed_cnt += 1, stat = alterlist(loc->build[1].nu[1].room[1].bed,bed_cnt), loc->build[1].nu[1].
     room[1].bed[bed_cnt].bed_cd = l.child_loc_cd,
     loc->build[1].nu[1].room[1].bed[bed_cnt].bed_disp = c.display
    WITH nocounter
   ;end select
   SET loc->build[1].nu[1].room[1].bed_cnt = bed_cnt
   SET bed_cnt = 0
  OF 5:
   SET loc->build_cnt = 1
   SET stat = alterlist(loc->build,1)
   SET loc->build[1].build_cd = build_cd
   SET loc->build[1].build_disp = build_disp
   SET loc->build[1].nu_cnt = 1
   SET stat = alterlist(loc->build[1].nu,1)
   SET loc->build[1].nu[1].nu_cd = nurse_unit_cd
   SET loc->build[1].nu[1].nu_disp = nurse_unit_disp
   SET loc->build[1].nu[1].room_cnt = 1
   SET stat = alterlist(loc->build[1].nu[1].room,1)
   SET loc->build[1].nu[1].room[1].room_cd = room_cd
   SET loc->build[1].nu[1].room[1].room_disp = room_disp
   SET loc->build[1].nu[1].room[1].bed_cnt = 1
   SET stat = alterlist(loc->build[1].nu[1].room[1].bed,1)
   SET loc->build[1].nu[1].room[1].bed[1].bed_cd = bed_cd
   SET loc->build[1].nu[1].room[1].bed[1].bed_disp = bed_disp
 ENDCASE
#7099_load_locations_exit
#7000_load_display
 CALL text(24,3,"Loading patients...")
 SET drows = 1
 FOR (x = 1 TO loc->build_cnt)
   FOR (y = 1 TO loc->build[x].nu_cnt)
     FOR (z = 1 TO loc->build[x].nu[y].room_cnt)
       FOR (zz = 1 TO loc->build[x].nu[y].room[z].bed_cnt)
         SET build_disp = substring(1,5,loc->build[x].build_disp)
         SET nurse_unit_disp = substring(1,5,loc->build[x].nu[y].nu_disp)
         SET room_disp = substring(1,5,loc->build[x].nu[y].room[z].room_disp)
         SET bed_disp = substring(1,5,loc->build[x].nu[y].room[z].bed[zz].bed_disp)
         SELECT INTO "nl:"
          ed.seq
          FROM encntr_domain ed,
           encounter e,
           person p,
           encntr_alias ea,
           code_value c
          PLAN (ed
           WHERE ed.loc_facility_cd=facility_cd
            AND (ed.loc_building_cd=loc->build[x].build_cd)
            AND (ed.loc_nurse_unit_cd=loc->build[x].nu[y].nu_cd)
            AND (ed.loc_room_cd=loc->build[x].nu[y].room[z].room_cd)
            AND (ed.loc_bed_cd=loc->build[x].nu[y].room[z].bed[zz].bed_cd)
            AND ed.encntr_domain_type_cd=encntr_domain_type_cd
            AND ed.active_ind=true
            AND ed.beg_effective_dt_tm <= cnvtdatetime(sysdate)
            AND ed.end_effective_dt_tm >= cnvtdatetime(sysdate))
           JOIN (e
           WHERE e.encntr_id=ed.encntr_id
            AND e.active_ind=true
            AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
            AND e.end_effective_dt_tm >= cnvtdatetime(sysdate))
           JOIN (p
           WHERE p.person_id=e.person_id
            AND p.active_ind=true
            AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
            AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
           JOIN (ea
           WHERE ea.encntr_id=e.encntr_id
            AND ea.encntr_alias_type_cd=finnbr_type_cd
            AND ea.active_ind=true
            AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
            AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
           JOIN (c
           WHERE c.code_value=e.encntr_type_cd
            AND c.active_ind=true
            AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
            AND c.end_effective_dt_tm >= cnvtdatetime(sysdate))
          DETAIL
           stat = alterlist(disp->list,drows), disp->list[drows].build_disp = build_disp, disp->list[
           drows].nu_disp = nurse_unit_disp,
           disp->list[drows].room_disp = room_disp, disp->list[drows].bed_disp = bed_disp, disp->
           list[drows].name_full_formatted = substring(1,30,p.name_full_formatted),
           disp->list[drows].reg_dt_tm = e.reg_dt_tm, disp->list[drows].birth_dt_tm = p.birth_dt_tm,
           disp->list[drows].person_id = e.person_id,
           disp->list[drows].encntr_id = e.encntr_id, disp->list[drows].finnbr_number = substring(1,
            15,ea.alias), disp->list[drows].encntr_type_disp = substring(1,12,c.display)
           IF (p.sex_cd=male_cd)
            disp->list[drows].sex_disp = "M"
           ELSE
            IF (p.sex_cd=female_cd)
             disp->list[drows].sex_disp = "F"
            ELSE
             IF (p.sex_cd=unknown_cd)
              disp->list[drows].sex_disp = "U"
             ELSE
              disp->list[drows].sex_disp = "-"
             ENDIF
            ENDIF
           ENDIF
           drows += 1
          WITH nocounter
         ;end select
         IF (curqual=0)
          SET stat = alterlist(disp->list,drows)
          SET disp->list[drows].build_disp = build_disp
          SET disp->list[drows].nu_disp = nurse_unit_disp
          SET disp->list[drows].room_disp = room_disp
          SET disp->list[drows].bed_disp = bed_disp
          SET drows += 1
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 SET drows -= 1
#7099_load_display_exit
#8000_display
 IF (drows <= 16)
  SET stat = alterlist(disp->list,16)
 ENDIF
 CALL video(r)
 CALL box(1,1,3,132)
 CALL clear(2,2,130)
 CALL text(02,05,"CENSUS REPORT:")
 CALL text(2,20,facility_disp)
 CALL video(n)
 CALL text(6,1,fill130)
 CALL text(5,1,
  " BLD     NU      ROOM    BED     NAME                             ENCNTR TYPE   REG DT TM    SEX")
 CALL text(5,99,"BIRTH DT TM   FIN NBR")
 CALL text(23,1,fill130)
 IF (first_time_yn="Y")
  EXECUTE FROM 8000_display_first TO 8099_display_first_exit
  SET first_time_yn = "N"
 ELSE
  EXECUTE FROM 8000_scroll TO 8099_scroll_exit
 ENDIF
 CALL text(24,1,"Select Option -- (N)ew, (R)eport, (A)udit, or (Q)uit")
 CALL accept(24,54,"p;cus","Q"
  WHERE curaccept IN ("N", "R", "A", "Q"))
 CASE (curscroll)
  OF 0:
   SET select_option = curaccept
  OF 1:
   IF (current_line=bottom_line)
    SET current_line = top_line
   ELSE
    IF (current_line >= drows)
     SET current_line = top_line
    ELSE
     SET current_line += 1
    ENDIF
   ENDIF
  OF 2:
   IF (current_line=top_line)
    IF (bottom_line > drows)
     SET current_line = drows
    ELSE
     SET current_line = bottom_line
    ENDIF
   ELSE
    SET current_line -= 1
   ENDIF
  OF 5:
   SET new_start = 0
   IF (top_line > 7)
    SET top_line -= 16
    SET bottom_line = (top_line+ 15)
   ELSE
    SET top_line = 1
    IF (drows > 15)
     SET bottom_line = (top_line+ 15)
    ELSE
     SET bottom_line = drows
    ENDIF
   ENDIF
   SET current_line = top_line
  OF 6:
   SET new_start = 0
   SET new_start = (top_line+ 16)
   IF (drows >= new_start)
    SET top_line = new_start
    SET current_line = top_line
    SET new_start = (top_line+ 15)
    IF (top_line <= drows)
     SET bottom_line = (top_line+ 15)
    ELSE
     SET bottom_line = drows
    ENDIF
   ENDIF
 ENDCASE
 IF (curscroll=0)
  CASE (select_option)
   OF "A":
    IF ((disp->list[current_line].person_id > 0))
     EXECUTE FROM 8000_audit TO 8099_audit_exit
    ENDIF
   OF "R":
    EXECUTE FROM 8000_report TO 8099_report_exit
   OF "N":
    GO TO 1000_start
   ELSE
    GO TO 9999_end
  ENDCASE
 ENDIF
 GO TO 8000_display
#8099_display_exit
#8000_display_first
 SET display_line = 7
 SET top_line = 1
 SET cur_line = 0
 SET bottom_line = 0
 SET max_scroll = 16
 FOR (display_loop = 1 TO max_scroll)
   IF (display_loop=1)
    CALL video(r)
    SET current_line = 1
   ELSE
    CALL video(n)
   ENDIF
   CALL text(display_line,2,disp->list[display_loop].build_disp)
   CALL text(display_line,7,"   ")
   CALL text(display_line,10,disp->list[display_loop].nu_disp)
   CALL text(display_line,15,"   ")
   CALL text(display_line,18,disp->list[display_loop].room_disp)
   CALL text(display_line,23,"   ")
   CALL text(display_line,26,disp->list[display_loop].bed_disp)
   CALL text(display_line,31,"   ")
   IF ((disp->list[display_loop].name_full_formatted > " "))
    CALL text(display_line,34,disp->list[display_loop].name_full_formatted)
   ELSE
    CALL text(display_line,34,"                              ")
   ENDIF
   CALL text(display_line,64,"   ")
   IF ((disp->list[display_loop].encntr_type_disp > " "))
    CALL text(display_line,67,disp->list[display_loop].encntr_type_disp)
   ELSE
    CALL text(display_line,67,"            ")
   ENDIF
   CALL text(display_line,78,"   ")
   CALL text(display_line,81,format(disp->list[display_loop].reg_dt_tm,"DD-MMM-YYYY;3;d"))
   CALL text(display_line,92,"   ")
   IF ((disp->list[display_loop].sex_disp > " "))
    CALL text(display_line,95,disp->list[display_loop].sex_disp)
   ELSE
    CALL text(display_line,95," ")
   ENDIF
   CALL text(display_line,96,"   ")
   CALL text(display_line,99,format(disp->list[display_loop].birth_dt_tm,"DD-MMM-YYYY;3;d"))
   CALL text(display_line,110,"   ")
   IF ((disp->list[display_loop].finnbr_number > " "))
    CALL text(display_line,113,disp->list[display_loop].finnbr_number)
   ELSE
    CALL text(display_line,113,"               ")
   ENDIF
   SET bottom_line += 1
   SET display_line += 1
 ENDFOR
#8099_display_first_exit
#8000_scroll
 SET display_line = 7
 SET max_scroll = 16
 FOR (display_loop = top_line TO bottom_line)
   IF (display_loop <= drows)
    IF (display_loop=current_line)
     CALL video(r)
    ELSE
     CALL video(n)
    ENDIF
    CALL text(display_line,2,disp->list[display_loop].build_disp)
    CALL text(display_line,7,"   ")
    CALL text(display_line,10,disp->list[display_loop].nu_disp)
    CALL text(display_line,15,"   ")
    CALL text(display_line,18,disp->list[display_loop].room_disp)
    CALL text(display_line,23,"   ")
    CALL text(display_line,26,disp->list[display_loop].bed_disp)
    CALL text(display_line,31,"   ")
    IF ((disp->list[display_loop].name_full_formatted > " "))
     CALL text(display_line,34,disp->list[display_loop].name_full_formatted)
    ELSE
     CALL text(display_line,34,"                              ")
    ENDIF
    CALL text(display_line,64,"   ")
    IF ((disp->list[display_loop].encntr_type_disp > " "))
     CALL text(display_line,67,disp->list[display_loop].encntr_type_disp)
    ELSE
     CALL text(display_line,67,"            ")
    ENDIF
    CALL text(display_line,78,"   ")
    CALL text(display_line,81,format(disp->list[display_loop].reg_dt_tm,"DD-MMM-YYYY;3;d"))
    CALL text(display_line,92,"   ")
    IF ((disp->list[display_loop].sex_disp > " "))
     CALL text(display_line,95,disp->list[display_loop].sex_disp)
    ELSE
     CALL text(display_line,95," ")
    ENDIF
    CALL text(display_line,96,"   ")
    CALL text(display_line,99,format(disp->list[display_loop].birth_dt_tm,"DD-MMM-YYYY;3;d"))
    CALL text(display_line,110,"   ")
    IF ((disp->list[display_loop].finnbr_number > " "))
     CALL text(display_line,113,disp->list[display_loop].finnbr_number)
    ELSE
     CALL text(display_line,113,"               ")
    ENDIF
    SET display_line += 1
   ENDIF
 ENDFOR
 IF (display_line < 23)
  CALL video(n)
  FOR (display_blank = display_line TO 22)
    CALL text(display_blank,2,fillstring(130," "))
  ENDFOR
 ENDIF
 CALL video(n)
#8099_scroll_exit
#8000_report
 SELECT INTO mine
  d.seq
  FROM dummyt d
  HEAD PAGE
   col 50, "CENSUS REPORT", row + 1,
   hold_date = cnvtdatetime(curdate,curtime), col 1, "Date:  ",
   hold_date"dd-mmm-yyyy;3;d", row + 1, col 1,
   "Facility: ", facility_disp, row + 2,
   col 2, "BLD", col 10,
   "NU", col 18, "ROOM",
   col 26, "BED", col 34,
   "NAME", col 67, "ENCNTR TYPE",
   col 81, "REG DT TM", col 94,
   "SEX", col 99, "BIRTH DT TM",
   col 113, "FIN NBR", row + 1,
   col 2, "---", col 10,
   "--", col 18, "----",
   col 26, "---", col 34,
   "-----------------------------------", col 67, "-----------",
   col 81, "---------", col 94,
   "---", col 99, "-----------",
   col 113, "-----------", row + 1
  DETAIL
   FOR (x = 1 TO drows)
     col 2, disp->list[x].build_disp, col 10,
     disp->list[x].nu_disp, col 18, disp->list[x].room_disp,
     col 26, disp->list[x].bed_disp, col 34,
     disp->list[x].name_full_formatted, col 67, disp->list[x].encntr_type_disp,
     col 81, disp->list[x].reg_dt_tm"dd-mmm-yyyy;3;d", col 95,
     disp->list[x].sex_disp, col 99, disp->list[x].birth_dt_tm"dd-mmm-yyyy;3;d",
     col 113, disp->list[x].finnbr_number, row + 1
   ENDFOR
  WITH nocounter
 ;end select
#8099_report_exit
#8000_audit
 CALL clear(24,1,130)
 CALL text(24,1,"Working...")
 FOR (inx = 1 TO nbr_tables)
   SET nbr_attributes = 0
   SET alias = substring(1,1,table_name[inx])
   SELECT INTO "nl:"
    l.attr_name, l.type, type =
    IF (btest(l.stat,6)=1) concat("D",l.type,trim(cnvtstring(l.len)))
    ELSEIF (btest(l.stat,5)=1) concat("T",l.type,trim(cnvtstring(l.len)))
    ELSE concat(" ",l.type,trim(cnvtstring(l.len)))
    ENDIF
    FROM dtable t,
     dtableattr a,
     dtableattrl l
    PLAN (t
     WHERE (t.table_name=table_name[inx]))
     JOIN (a
     WHERE t.table_name=a.table_name)
     JOIN (l)
    DETAIL
     IF (l.attr_name != "DATAREC"
      AND l.attr_name != "ROWID")
      nbr_attributes += 1, audit->list[nbr_attributes].attr_name = l.attr_name, audit->list[
      nbr_attributes].attr_type = type
     ENDIF
    WITH nocounter
   ;end select
   FOR (cnt = 1 TO nbr_attributes)
     IF (substring((size(trim(audit->list[cnt].attr_name,1),1) - 2),3,audit->list[cnt].attr_name)=
     "_CD")
      SET variable_disp = concat(substring(1,(size(trim(audit->list[cnt].attr_name)) - 3),audit->
        list[cnt].attr_name),"_DP")
      SET parser_buffer[1] = concat("set ",trim(variable_disp),'= fillstring(40," ") go')
      CALL parser(parser_buffer[1],1)
      SET parser_buffer[1] = concat('select into "nl:"')
      SET parser_buffer[2] = concat("from ",trim(table_name[inx])," ",alias,", code_value c1")
      IF ((((table_name[inx]="PERSON")) OR ((((table_name[inx]="PERSON_ALIAS")) OR ((table_name[inx]=
      "PERSON_NAME"))) )) )
       SET parser_buffer[3] = concat("plan ",alias," where ",alias,".person_id",
        " = ",cnvtstring(value(disp->list[current_line].person_id)))
      ELSE
       SET parser_buffer[3] = concat("plan ",alias," where ",alias,".encntr_id",
        " = ",cnvtstring(value(disp->list[current_line].encntr_id)))
      ENDIF
      SET parser_buffer[4] = concat("join c1 where c1.code_value = ",alias,".",trim(audit->list[cnt].
        attr_name))
      SET parser_buffer[5] = "detail"
      SET parser_buffer[6] = concat(variable_disp," = c1.display_key")
      SET parser_buffer[7] = "with nocounter go"
      FOR (y = 1 TO 7)
        CALL parser(parser_buffer[y],1)
      ENDFOR
     ENDIF
   ENDFOR
   SET parser_buffer[1] = concat("select into ",trim(file_name))
   SET parser_buffer[2] = concat("  ",alias,".*")
   SET parser_buffer[3] = concat("from ",trim(table_name[inx])," ",alias)
   IF ((((table_name[inx]="PERSON")) OR ((((table_name[inx]="PERSON_ALIAS")) OR ((table_name[inx]=
   "PERSON_NAME"))) )) )
    SET parser_buffer[4] = concat("where ",alias,".person_id"," = ",cnvtstring(value(disp->list[
       current_line].person_id)))
   ELSE
    SET parser_buffer[4] = concat("where ",alias,".encntr_id"," = ",cnvtstring(value(disp->list[
       current_line].encntr_id)))
   ENDIF
   SET parser_buffer[5] = "detail"
   SET parser_buffer[6] = concat("  col 0, row + 2,",'"',"Table:",table_name[inx],'"')
   SET parser_buffer[7] = "  row + 2"
   SET parser_buffer[8] = concat("  fill = fillstring(132,",'" ','")')
   SET parser_number = 8
   FOR (x = 1 TO nbr_attributes)
    SET parser_number += 1
    IF (substring(2,1,audit->list[x].attr_type)="C")
     SET parser_buffer[parser_number] = concat("  fill = substring(1,90,",alias,".",trim(audit->list[
       x].attr_name),")")
     SET parser_number += 1
     SET parser_buffer[parser_number] = concat("  col 0, row+1, ",'"',trim(audit->list[x].attr_name),
      " =  ",'",',
      " fill")
    ELSE
     IF (substring((size(trim(audit->list[x].attr_name,1),1) - 2),3,audit->list[x].attr_name)="_CD")
      SET parser_buffer[parser_number] = concat("  col 0, row+1,",'"',trim(audit->list[x].attr_name),
       " = ",'"',
       ", col+2,",alias,".",trim(audit->list[x].attr_name),'"##########", col+2,',
       substring(1,(size(trim(audit->list[x].attr_name)) - 3),audit->list[x].attr_name),"_DP")
     ELSE
      IF (substring((size(trim(audit->list[x].attr_name,1),1) - 5),6,audit->list[x].attr_name)=
      "_DT_TM")
       SET parser_buffer[parser_number] = concat("  col 0, row+1, ",'"',trim(audit->list[x].attr_name
         )," = ",'"',
        ",col+2 ",alias,".",trim(audit->list[x].attr_name),' "mm/dd/yyyy"',
        "col+2, ",alias,".",trim(audit->list[x].attr_name),' "hh:mm:ss"')
      ELSE
       SET parser_buffer[parser_number] = concat("  col 0, row+1, ",'"',trim(audit->list[x].attr_name
         )," = ",'"',
        ",col+2 ",alias,".",trim(audit->list[x].attr_name))
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   SET parser_number += 1
   SET parser_buffer[parser_number] = "  row + 1"
   SET parser_number += 1
   IF (inx=1)
    SET parser_buffer[parser_number] =
    "with nocounter, maxcol = 200, format = variable, noformfeed, maxrow = 1, noheading go"
   ELSE
    SET parser_buffer[parser_number] =
    "with nocounter, maxcol = 200, format = variable, noformfeed, maxrow = 1, noheading, append go"
   ENDIF
   FOR (z = 1 TO parser_number)
     CALL parser(parser_buffer[z],1)
   ENDFOR
 ENDFOR
 FREE DEFINE rtl
 EXECUTE rtlview value("MINE"), value("CCLUSERDIR:TEMPAUDCENSUS.DAT")
 SET dclcom = "delete ccluserdir:tempaudcensus.dat;*/nolog"
 SET len = size(trim(dclcom))
 SET status = 0
 CALL dcl(dclcom,len,status)
#8099_audit_exit
#9000_clear
 FOR (x = 4 TO 23)
   CALL clear(x,1,132)
 ENDFOR
#9099_clear_exit
#9999_end
END GO
