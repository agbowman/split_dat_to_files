CREATE PROGRAM auth_maint_main:dba
 PAINT
 SET width = 132
 SET modify = system
 SET perform_housekeeping =  $1
 SUBROUTINE delete_transaction_data(delete_cv)
   SET trans_cnt = 0
   FREE DEFINE trans
   RECORD trans(
     1 list[*]
       2 transaction_activity_id = f8
   )
   SELECT INTO "nl:"
    d.seq
    FROM dm_transaction_data d
    WHERE d.field_num_value=delete_cv
    DETAIL
     trans_cnt = (trans_cnt+ 1), stat = alterlist(trans->list,trans_cnt), trans->list[trans_cnt].
     transaction_activity_id = d.transaction_activity_id
    WITH nocounter
   ;end select
   DELETE  FROM dm_transaction_data dm
    WHERE dm.field_num_value=delete_cv
    WITH nocounter
   ;end delete
   FOR (x = 1 TO trans_cnt)
    SELECT INTO "nl:"
     dm.seq
     FROM dm_transaction_data dm
     WHERE (dm.transaction_activity_id=trans->list[x].transaction_activity_id)
     WITH nocounter
    ;end select
    IF (curqual=0)
     DELETE  FROM dm_transaction_key dm
      WHERE (dm.transaction_activity_id=trans->list[x].transaction_activity_id)
      WITH nocounter
     ;end delete
     DELETE  FROM dm_transaction_activity dm
      WHERE (dm.transaction_activity_id=trans->list[x].transaction_activity_id)
      WITH nocounter
     ;end delete
    ENDIF
   ENDFOR
 END ;Subroutine
 SET first_time = 1
#0100_start
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 IF (first_time=1
  AND perform_housekeeping=1)
  EXECUTE FROM 1000_housekeeping TO 1000_housekeeping_exit
 ENDIF
 SET first_time = 0
 EXECUTE FROM 2000_border TO 2099_border_exit
 EXECUTE FROM 3000_load_code_values TO 3099_load_code_values_exit
 EXECUTE FROM 8000_display TO 8099_display_exit
 GO TO 0100_start
#1000_initialize
 SET true = 1
 SET false = 0
 SET fill40 = fillstring(40," ")
 SET fill55 = fillstring(55," ")
 SET fill130 = fillstring(130,"-")
 SET cv_cnt = 0
 SET auth_cd = 0
 SET unauth_cd = 0
 SET auth_disp = fillstring(12," ")
 SET inactive_cd = 0
 SET inactive_disp = fillstring(12," ")
 SET active_cd = 0
 SET active_disp = fillstring(12," ")
 SET first_time_yn = "Y"
 SET from_cv = 0
 SET to_cv = 0
 SET to_disp = fillstring(40," ")
 SET redisplay_yn = "N"
 SET current_user_id = 0
 SET current_user_name = fillstring(30," ")
 SET code_set = 0
 SET esi_trans_id = 0
 SET pn = 0
 SET parser_buffer[10] = fillstring(132," ")
 SET new_nbr = 0
 SELECT INTO "nl:"
  d.seq
  FROM dm_transactions d
  WHERE d.description="ESI SERVER"
  DETAIL
   esi_trans_id = d.transaction_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   y = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    new_nbr = cnvtreal(y)
   WITH format, counter
  ;end select
  INSERT  FROM dm_transactions d
   SET d.transaction_id = new_nbr, d.description = "ESI SERVER", d.updt_applctx = 12218,
    d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = 0, d.updt_id = 12218,
    d.updt_task = 12218, d.transaction_cat_cd = 0
   WITH nocounter
  ;end insert
  COMMIT
  SET esi_trans_id = new_nbr
 ENDIF
 SELECT INTO "nl:"
  p.seq
  FROM prsnl p
  WHERE p.username=curuser
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   current_user_id = p.person_id, current_user_name = substring(1,30,p.name_full_formatted)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning="AUTH"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   auth_cd = c.code_value, auth_disp = substring(1,12,c.display)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL text(1,1,"AUTH - Meaning Not Found")
  GO TO 9999_end
 ENDIF
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning="UNAUTH"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   unauth_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL text(1,1,"UNAUTH - Meaning Not Found")
  GO TO 9999_end
 ENDIF
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="INACTIVE"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   inactive_cd = c.code_value, inactive_disp = substring(1,12,c.display)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="ACTIVE"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   active_cd = c.code_value, active_disp = substring(1,12,c.display)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL text(1,1,"INACTIVE - Meaning Not Found")
  GO TO 9999_end
 ENDIF
 FREE DEFINE cv
 RECORD cv(
   1 list[*]
     2 code_set = f8
     2 code_value = f8
     2 display = c30
     2 active = c5
     2 data_status_disp = c12
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_name = c30
 )
 SET cv_cnt = 0
#1099_initialize_exit
#1000_housekeeping
 CALL text(1,1,"Cleaning up unauthenticated code values that did not come in via ESI.")
 UPDATE  FROM code_value cv
  SET cv.data_status_cd = auth_cd
  WHERE cv.data_status_cd != auth_cd
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_transaction_data dt
   WHERE cv.code_value=dt.field_num_value)))
 ;end update
 COMMIT
 FREE DEFINE cv2
 RECORD cv2(
   1 list[*]
     2 code_value = f8
 )
 SET cv2_cnt = 0
 SELECT DISTINCT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.data_status_cd != unauth_cd
   AND  EXISTS (
  (SELECT
   "x"
   FROM dm_transaction_data dtd
   WHERE dtd.field_num_value=cv.code_value))
  DETAIL
   cv2_cnt = (cv2_cnt+ 1), stat = alterlist(cv2->list,cv2_cnt), cv2->list[cv2_cnt].code_value = cv
   .code_value
  WITH nocounter
 ;end select
 CALL text(1,1,"Deleting authenticated code values that were logged in the DM_TRANS tables.")
 FOR (i = 1 TO cv2_cnt)
   CALL text(1,1,concat("Deleting authenticated code value ",cnvtstring(cv2->list[i].code_value),
     " that were logged in the DM_TRANS tables."))
   CALL delete_transaction_data(cv2->list[i].code_value)
   COMMIT
 ENDFOR
#1000_housekeeping_exit
#2000_border
 CALL clear(1,1)
 CALL video(r)
 CALL box(1,1,3,132)
 CALL clear(2,2,130)
 CALL text(02,05,"Code Value Authentication")
 CALL video(n)
 CALL text(5,2,"Code Set")
 CALL text(5,16,"Code Value")
 CALL text(5,30,"Display")
 CALL text(5,62,"Act Ind")
 CALL text(5,73,"Data St Cd")
 CALL text(5,88,"Data St Dt")
 CALL text(5,102,"Data St Prsnl Name")
 CALL text(6,2,fill130)
 CALL text(23,2,fill130)
#2099_border_exit
#3000_load_code_values
 CALL text(24,2,"Enter Code Set, <0> for all:  ")
 SET help =
 SELECT
  c.code_set, c.display
  FROM code_value_set c
  WHERE c.code_set >= curaccept
  ORDER BY c.code_set
  WITH nocounter
 ;end select
 CALL accept(24,32,"9(11);pd")
 SET code_set = curaccept
 CALL clear(24,1)
 CALL text(24,2,"Loading Code Values...")
 IF (code_set=0)
  SELECT INTO "nl:"
   c1.seq
   FROM code_value c1,
    code_value c2,
    prsnl p,
    dummyt d
   PLAN (c1
    WHERE c1.data_status_cd != auth_cd)
    JOIN (c2
    WHERE c2.code_value=c1.data_status_cd)
    JOIN (d)
    JOIN (p
    WHERE c1.data_status_prsnl_id=p.person_id)
   ORDER BY c1.code_set, c1.code_value
   DETAIL
    cv_cnt = (cv_cnt+ 1), stat = alterlist(cv->list,cv_cnt), cv->list[cv_cnt].code_set = c1.code_set,
    cv->list[cv_cnt].code_value = c1.code_value, cv->list[cv_cnt].display = substring(1,30,c1.display
     )
    IF (c1.active_ind=1)
     cv->list[cv_cnt].active = "ACT"
    ELSE
     cv->list[cv_cnt].active = "INACT"
    ENDIF
    cv->list[cv_cnt].data_status_disp = substring(1,12,c2.display), cv->list[cv_cnt].
    data_status_dt_tm = c1.data_status_dt_tm, cv->list[cv_cnt].data_status_prsnl_name = substring(1,
     30,p.name_full_formatted)
   WITH nocounter, outerjoin = d
  ;end select
 ELSE
  SELECT INTO "nl:"
   c1.seq
   FROM code_value c1,
    code_value c2,
    dummyt d,
    prsnl p
   PLAN (c1
    WHERE c1.code_set=code_set
     AND c1.data_status_cd != auth_cd)
    JOIN (c2
    WHERE c2.code_value=c1.data_status_cd)
    JOIN (d)
    JOIN (p
    WHERE c1.data_status_prsnl_id=p.person_id)
   ORDER BY c1.code_set, c1.code_value
   DETAIL
    cv_cnt = (cv_cnt+ 1), stat = alterlist(cv->list,cv_cnt), cv->list[cv_cnt].code_set = c1.code_set,
    cv->list[cv_cnt].code_value = c1.code_value, cv->list[cv_cnt].display = c1.display
    IF (c1.active_ind=1)
     cv->list[cv_cnt].active = "ACT"
    ELSE
     cv->list[cv_cnt].active = "INACT"
    ENDIF
    cv->list[cv_cnt].data_status_disp = substring(1,12,c2.display), cv->list[cv_cnt].
    data_status_dt_tm = c1.data_status_dt_tm, cv->list[cv_cnt].data_status_prsnl_name = substring(1,
     30,p.name_full_formatted)
   WITH nocounter, outerjoin = d
  ;end select
 ENDIF
#3099_load_code_values_exit
#8000_display
 IF (redisplay_yn="Y")
  SET redisplay_yn = "N"
  EXECUTE FROM 2000_border TO 2099_border_exit
 ENDIF
 IF (cv_cnt <= 16)
  SET stat = alterlist(cv->list,16)
 ENDIF
 IF (first_time_yn="Y")
  EXECUTE FROM 8000_display_first TO 8099_display_first_exit
  SET first_time_yn = "N"
 ELSE
  EXECUTE FROM 8000_scroll TO 8099_scroll_exit
 ENDIF
 CALL clear(24,1)
 CASE (code_set)
  OF 72:
   CALL text(24,2,
    "Use the Event Code Load to Report:  Event Code Options Only -- (R)eport, (N)ew, or (Q)uit")
   CALL accept(24,110,"p;cus","Q"
    WHERE curaccept IN ("R", "N", "Q"))
  OF 220:
   CALL text(24,2,"Select Option -- (A)uthenticate, (R)eport, (N)ew, or (Q)uit")
   CALL accept(24,73,"p;cus","Q"
    WHERE curaccept IN ("A", "R", "N", "Q"))
  ELSE
   CALL text(24,2,"Select Option -- (A)uthenticate, (C)ombine, (R)eport, (N)ew, or (Q)uit")
   CALL accept(24,73,"p;cus","Q"
    WHERE curaccept IN ("A", "C", "R", "N", "Q"))
 ENDCASE
 CASE (curscroll)
  OF 0:
   SET select_option = curaccept
  OF 1:
   IF (current_line=bottom_line)
    SET current_line = top_line
   ELSE
    IF (current_line >= cv_cnt)
     SET current_line = top_line
    ELSE
     SET current_line = (current_line+ 1)
    ENDIF
   ENDIF
  OF 2:
   IF (current_line=top_line)
    IF (bottom_line > cv_cnt)
     SET current_line = cv_cnt
    ELSE
     SET current_line = bottom_line
    ENDIF
   ELSE
    SET current_line = (current_line - 1)
   ENDIF
  OF 5:
   SET new_start = 0
   IF (top_line > 7)
    SET top_line = (top_line - 16)
    SET bottom_line = (top_line+ 15)
   ELSE
    SET top_line = 1
    IF (cv_cnt > 15)
     SET bottom_line = (top_line+ 15)
    ELSE
     SET bottom_line = cv_cnt
    ENDIF
   ENDIF
   SET current_line = top_line
  OF 6:
   SET new_start = 0
   SET new_start = (top_line+ 16)
   IF (cv_cnt >= new_start)
    SET top_line = new_start
    SET current_line = top_line
    SET new_start = (top_line+ 15)
    IF (top_line <= cv_cnt)
     SET bottom_line = (top_line+ 15)
    ELSE
     SET bottom_line = cv_cnt
    ENDIF
   ENDIF
 ENDCASE
 IF (curscroll=0)
  IF ((cv->list[current_line].data_status_disp="DELETED")
   AND ((select_option="A") OR (select_option="C")) )
   GO TO 8000_display
  ENDIF
  CASE (select_option)
   OF "A":
    EXECUTE FROM 8000_authenticate TO 8099_authenticate_exit
   OF "C":
    EXECUTE FROM 8000_combine TO 8099_combine_exit
   OF "R":
    SET redisplay_yn = "Y"
    EXECUTE FROM 8000_report TO 8099_report_exit
   OF "N":
    GO TO 0100_start
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
   IF ((cv->list[display_loop].code_set > 0))
    CALL text(display_line,2,format(cv->list[display_loop].code_set,"###########;l"))
   ENDIF
   CALL text(display_line,13,"   ")
   IF ((cv->list[display_loop].code_value > 0))
    CALL text(display_line,16,format(cv->list[display_loop].code_value,"###########;l"))
   ENDIF
   CALL text(display_line,27,"   ")
   IF ((cv->list[display_loop].display > " "))
    CALL text(display_line,30,cv->list[display_loop].display)
   ELSE
    CALL text(display_line,30,"                              ")
   ENDIF
   CALL text(display_line,60,"  ")
   CALL text(display_line,62,cv->list[display_loop].active)
   CALL text(display_line,67,"      ")
   IF ((cv->list[display_loop].data_status_disp > " "))
    CALL text(display_line,73,cv->list[display_loop].data_status_disp)
   ELSE
    CALL text(display_line,73,"            ")
   ENDIF
   CALL text(display_line,85,"   ")
   CALL text(display_line,88,format(cv->list[display_loop].data_status_dt_tm,"DD-MMM-YYYY;3;d"))
   CALL text(display_line,99,"   ")
   IF ((cv->list[display_loop].data_status_prsnl_name > " "))
    CALL text(display_line,102,cv->list[display_loop].data_status_prsnl_name)
   ELSE
    CALL text(display_line,102,"                              ")
   ENDIF
   SET bottom_line = (bottom_line+ 1)
   SET display_line = (display_line+ 1)
 ENDFOR
#8099_display_first_exit
#8000_scroll
 SET display_line = 7
 SET max_scroll = 16
 FOR (display_loop = top_line TO bottom_line)
   IF (display_loop <= cv_cnt)
    IF (display_loop=current_line)
     CALL video(r)
    ELSE
     CALL video(n)
    ENDIF
    CALL text(display_line,2,format(cv->list[display_loop].code_set,"###########;l"))
    CALL text(display_line,13,"   ")
    CALL text(display_line,16,format(cv->list[display_loop].code_value,"###########;l"))
    CALL text(display_line,27,"   ")
    IF ((cv->list[display_loop].display > " "))
     CALL text(display_line,30,cv->list[display_loop].display)
    ELSE
     CALL text(display_line,30,"                              ")
    ENDIF
    CALL text(display_line,60,"  ")
    CALL text(display_line,62,cv->list[display_loop].active)
    CALL text(display_line,67,"      ")
    IF ((cv->list[display_loop].data_status_disp > " "))
     CALL text(display_line,73,cv->list[display_loop].data_status_disp)
    ELSE
     CALL text(display_line,73,"            ")
    ENDIF
    CALL text(display_line,85,"   ")
    CALL text(display_line,88,format(cv->list[display_loop].data_status_dt_tm,"DD-MMM-YYYY;3;d"))
    CALL text(display_line,99,"   ")
    IF ((cv->list[display_loop].data_status_prsnl_name > " "))
     CALL text(display_line,102,cv->list[display_loop].data_status_prsnl_name)
    ELSE
     CALL text(display_line,102,"                              ")
    ENDIF
    SET display_line = (display_line+ 1)
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
   col 35, "UNAUTHENTICATED CODE VALUE REPORT", row + 1,
   hold_date = cnvtdatetime(curdate,curtime), col 1, "Date:  ",
   hold_date"dd-mmm-yyyy;3;d", row + 2, col 1,
   "Code Set", col 15, "Code Value",
   col 29, "Display", col 63,
   "Act Ind", col 72, "Data St Cd",
   col 87, "Data St Dt", col 101,
   "Data St Prsnl Name", row + 1, col 1,
   "------------", col 15, "------------",
   col 29, "-------------------------------", col 63,
   "-------", col 72, "------------",
   col 87, "------------", col 101,
   "------------------------------", row + 1
  DETAIL
   FOR (x = 1 TO cv_cnt)
     col 1, cv->list[x].code_set"###########;l", col 15,
     cv->list[x].code_value"############;l", col 29, cv->list[x].display,
     col 63, cv->list[x].active, col 72,
     cv->list[x].data_status_disp, col 87, cv->list[x].data_status_dt_tm"dd-mmm-yyyy;3;d",
     col 101, cv->list[x].data_status_prsnl_name, row + 1,
     name_hold = fillstring(28," ")
   ENDFOR
  WITH nocounter
 ;end select
#8099_report_exit
#8000_authenticate
 CALL clear(24,1)
 CALL text(24,2,"Are you sure you want to Authenticate this code value? (Y/N)")
 CALL accept(24,63,"p;cud","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  CALL clear(24,1)
  CALL text(24,2,"Working...")
  SET cv->list[current_line].data_status_disp = auth_disp
  SET cv->list[current_line].data_status_dt_tm = cnvtdatetime(curdate,curtime3)
  SET cv->list[current_line].data_status_prsnl_name = current_user_name
  SET cv->list[current_line].active = "ACT"
  UPDATE  FROM code_value c
   SET c.active_ind = true, c.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), c
    .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    c.active_type_cd = active_cd, c.inactive_dt_tm = null, c.data_status_cd = auth_cd,
    c.data_status_prsnl_id = current_user_id, c.data_status_dt_tm = cnvtdatetime(curdate,curtime3), c
    .updt_id = current_user_id,
    c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = 2218, c.updt_applctx = 2218,
    c.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (c.code_value=cv->list[current_line].code_value)
   WITH nocounter
  ;end update
  CALL delete_transaction_data(cv->list[current_line].code_value)
  COMMIT
 ENDIF
#8099_authenticate_exit
#8000_combine
 SET from_cv = cv->list[current_line].code_value
 SET cv->list[current_line].data_status_disp = "DELETED"
 SET cv->list[current_line].data_status_prsnl_name = current_user_name
 SET cv->list[current_line].data_status_dt_tm = cnvtdatetime(curdate,curtime3)
 FOR (x = 10 TO 17)
   CALL clear(x,30,70)
 ENDFOR
 CALL box(10,30,17,100)
 CALL video(r)
 CALL text(11,31,"            *** Unauthenticated Code Value Combine ***               ")
 CALL text(16,31,"                                                             <HELP>  ")
 CALL video(n)
 CALL video(l)
 CALL text(13,36,"From CV:")
 CALL text(14,36,"To CV:")
 CALL video(n)
 CALL text(13,45,format(from_cv,"###########"))
 CALL text(13,59,cv->list[current_line].display)
 SET help =
 SELECT
  c.code_value, c.display
  FROM code_value c
  WHERE (c.code_set=cv->list[current_line].code_set)
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND c.data_status_cd=auth_cd
  ORDER BY c.display
  WITH nocounter
 ;end select
 CALL accept(14,45,"9(11);d")
 SET to_cv = curaccept
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_value=to_cv
   AND (c.code_set=cv->list[current_line].code_set)
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND c.data_status_cd=auth_cd
  DETAIL
   to_disp = c.display
  WITH nocounter
 ;end select
 CALL text(14,59,to_disp)
 IF (curqual=0)
  GO TO 8000_combine
 ENDIF
 CALL video(r)
 CALL text(16,83,"                ")
 CALL text(16,83,"Correct (Y/N)")
 CALL accept(16,97,"p;cud","Y"
  WHERE curaccept IN ("Y", "N"))
 CALL video(n)
 IF (curaccept="N")
  GO TO 8000_combine
 ENDIF
 CALL clear(24,1)
 CALL text(24,2,"Working...")
 FREE DEFINE cmb
 RECORD cmb(
   1 data[*]
     2 transaction_activity_id = f8
     2 field_name = c32
     2 ky_cnt = i4
     2 ky[*]
       3 field_name = c32
       3 field_num_value = f8
       3 entity_name = c32
 )
 SET more_combine_rows = 1
 WHILE (more_combine_rows=1)
   SET data_cnt = 0
   IF (more_combine_rows=1)
    SET more_combine_rows = 0
    SELECT INTO "nl:"
     dm.seq
     FROM dm_transaction_data dm
     WHERE (dm.field_num_value=cv->list[current_line].code_value)
      AND sqlpassthru("rownum < 501")
     DETAIL
      data_cnt = (data_cnt+ 1), stat = alterlist(cmb->data,data_cnt), cmb->data[data_cnt].
      transaction_activity_id = dm.transaction_activity_id,
      cmb->data[data_cnt].field_name = dm.field_name
     WITH nocounter
    ;end select
    IF (data_cnt=500)
     SET more_combine_rows = 1
    ENDIF
   ENDIF
   FOR (x = 1 TO data_cnt)
     SET ky_cnt = 0
     SELECT INTO "nl:"
      dm1.seq
      FROM dm_transaction_key dm1,
       dm_transaction_activity dm2
      PLAN (dm1
       WHERE (dm1.transaction_activity_id=cmb->data[x].transaction_activity_id))
       JOIN (dm2
       WHERE dm2.transaction_activity_id=dm1.transaction_activity_id)
      DETAIL
       ky_cnt = (ky_cnt+ 1), stat = alterlist(cmb->data[x].ky,ky_cnt), cmb->data[x].ky[ky_cnt].
       field_name = dm1.field_name,
       cmb->data[x].ky[ky_cnt].field_num_value = dm1.field_num_value, cmb->data[x].ky[ky_cnt].
       entity_name = dm2.entity_name
      WITH nocounter
     ;end select
     SET cmb->data[x].ky_cnt = ky_cnt
   ENDFOR
   FOR (x = 1 TO data_cnt)
     SET trace symbol mark
     SET alias = substring(1,1,cmb->data[x].ky[1].entity_name)
     SET parser_buffer[1] = concat("update into ",trim(cmb->data[x].ky[1].entity_name)," ",alias)
     SET parser_buffer[2] = concat("set ",alias,".",trim(cmb->data[x].field_name)," = ",
      cnvtstring(to_cv),",")
     SET parser_buffer[3] = concat("    ",alias,".updt_dt_tm = cnvtdatetime(curdate,curtime3),")
     SET parser_buffer[4] = concat("    ",alias,".updt_id = current_user_id,")
     SET parser_buffer[5] = concat("    ",alias,".updt_task = 2218,")
     SET parser_buffer[6] = concat("    ",alias,".updt_applctx = 2218,")
     SET parser_buffer[7] = concat("    ",alias,".updt_cnt = ",alias,".updt_cnt + 1")
     SET pn = 7
     FOR (y = 1 TO cmb->data[x].ky_cnt)
      SET pn = (pn+ 1)
      IF (pn=8)
       SET parser_buffer[pn] = concat("where ",alias,".",trim(cmb->data[x].ky[y].field_name)," = ",
        cnvtstring(cmb->data[x].ky[y].field_num_value))
      ELSE
       SET parser_buffer[pn] = concat("and ",alias,".",trim(cmb->data[x].ky[y].field_name)," = ",
        cnvtstring(cmb->data[x].ky[y].field_num_value))
      ENDIF
     ENDFOR
     SET pn = (pn+ 1)
     SET parser_buffer[pn] = "go"
     FOR (z = 1 TO pn)
       CALL parser(parser_buffer[z],1)
     ENDFOR
     SET trace = symbol
   ENDFOR
   FOR (x = 1 TO data_cnt)
     DELETE  FROM dm_transaction_data dm
      WHERE (dm.transaction_activity_id=cmb->data[x].transaction_activity_id)
      WITH nocounter
     ;end delete
   ENDFOR
   FOR (x = 1 TO data_cnt)
    SELECT INTO "nl:"
     dm.seq
     FROM dm_transaction_data dm
     WHERE (dm.transaction_activity_id=cmb->data[x].transaction_activity_id)
     WITH nocounter
    ;end select
    IF (curqual=0)
     DELETE  FROM dm_transaction_key dm
      WHERE (dm.transaction_activity_id=cmb->data[x].transaction_activity_id)
      WITH nocounter
     ;end delete
     DELETE  FROM dm_transaction_activity dm
      WHERE (dm.transaction_activity_id=cmb->data[x].transaction_activity_id)
      WITH nocounter
     ;end delete
    ENDIF
   ENDFOR
   UPDATE  FROM code_value c
    SET c.active_ind = false, c.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), c
     .inactive_dt_tm = cnvtdatetime(curdate,curtime),
     c.data_status_cd = auth_cd, c.data_status_prsnl_id = current_user_id, c.data_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     c.active_type_cd = inactive_cd, c.active_dt_tm = cnvtdatetime(curdate,curtime), c
     .active_status_prsnl_id = current_user_id,
     c.updt_id = current_user_id, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (c
     .updt_cnt+ 1)
    WHERE c.code_value=from_cv
    WITH nocounter
   ;end update
   UPDATE  FROM code_value_alias c
    SET c.code_value = to_cv, c.updt_id = current_user_id, c.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     c.updt_cnt = (c.updt_cnt+ 1)
    WHERE c.code_value=from_cv
   ;end update
 ENDWHILE
 COMMIT
 GO TO 8000_display
#8099_combine_exit
#9999_end
END GO
