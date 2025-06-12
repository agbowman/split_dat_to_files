CREATE PROGRAM afc_batchbuild_pricemaint:dba
 PAINT
 SET width = 140
 SET modify = system
 EXECUTE cclseclogin
 SET fuser = 0.0
 SET cuser = curuser
 SELECT INTO "NL:"
  p.person_id
  FROM prsnl p
  WHERE p.username=cuser
  DETAIL
   fuser = p.person_id
  WITH nocounter
 ;end select
 RECORD request(
   1 ext_owner_code = f8
   1 from_price_sched_id = f8
   1 from_price_sched_desc = c200
   1 to_price_sched_id = f8
   1 to_price_sched_desc = c200
   1 level_ind = i2
   1 flatchange = f8
   1 percentchange = f8
   1 flat_ind = i2
   1 percent_ind = i2
   1 setzero_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 roundingdirection_ind = i2
   1 roundingamount_ind = i2
   1 price_effective_dt_tm = dq8
   1 user = f8
   1 interval_ind = i2
 )
 SET cur_date_time = datetimeadd(cnvtdatetime(curdate,curtime),1)
 SET beg_of_day = cnvtdatetime(concat(format(cur_date_time,"dd-mmm-yyyy;;d")," 00:00:00.00"))
 SET end_of_day = cnvtdatetime("31-DEC-2100 23:59:59.99")
 SET come_back = 0
 SET quit_ind = 0
 SET update_ind = 0
 SET request->user = fuser
 SET request->beg_effective_dt_tm = cnvtdatetime(beg_of_day)
 SET request->end_effective_dt_tm = cnvtdatetime(end_of_day)
 SET request->price_effective_dt_tm = cnvtdatetime(curdate,curtime)
 SET request->flat_ind = 0
 SET request->percent_ind = 0
 SET request->setzero_ind = 0
 SET request->flatchange = 0.0
 SET request->percentchange = 0.0
#menu
 IF (quit_ind=1)
  CALL clear(1,1)
  SET request->beg_effective_dt_tm = cnvtdatetime(beg_of_day)
  SET request->end_effective_dt_tm = cnvtdatetime(end_of_day)
  SET request->price_effective_dt_tm = cnvtdatetime(curdate,curtime)
  SET request->flat_ind = 0
  SET request->percent_ind = 0
  SET request->setzero_ind = 0
  SET request->flatchange = 0.0
  SET request->percentchange = 0.0
  SET request->interval_ind = 0
  SET quit_ind = 0
  SET update_ind = 0
 ENDIF
 CALL text(2,45,"***  CCL Batch Build - Price Maintenance  ***")
 CALL text(3,5,"Press <Shift+F5> for a list of Choices:")
 CALL text(5,5,"1) Type of Adjustment :")
 CALL text(7,5,"2) Exit")
 CALL text(8,5,"Choose 1 of the following :")
 IF (come_back=0)
  GO TO adjustment
 ENDIF
 CALL accept(8,35,"99;",2
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   SET come_back = 0
   GO TO adjustment
  OF 2:
   SET come_back = 0
   GO TO the_end
 ENDCASE
 SET quit_ind = 1
 GO TO menu
#adjustment
 SET help = fix('1 "Flat Change",2 "Percent Change",3 "Set Zero Prices"')
 CALL accept(5,51,"9;f",1
  WHERE curaccept IN (1, 2, 3))
 CASE (curaccept)
  OF 1:
   SET request->flat_ind = 1
   EXECUTE FROM display_change TO display_change_end
  OF 2:
   SET request->percent_ind = 1
   EXECUTE FROM display_change TO display_change_end
  OF 3:
   SET request->setzero_ind = 1
 ENDCASE
 CALL video(n)
 IF (come_back=0)
  IF ((request->setzero_ind=1))
   GO TO set_zero_menu
  ELSE
   GO TO flat_or_percent_menu
  ENDIF
 ENDIF
 SET quit_ind = 1
 GO TO menu
#set_zero_menu
 IF (come_back=0)
  CALL clear(1,1)
 ENDIF
 CALL text(2,45,"***  CCL Batch Build - Price Maintenance  ***")
 CALL text(3,5,"Press <Shift+F5> for a list of Choices:")
 CALL text(5,5,"1) External Owner Code :")
 CALL text(6,5,"2) Affected Price Schedule :")
 CALL text(7,5,"3) Level to Populate :")
 CALL text(8,5,"4) Effective Dates of New Prices :")
 CALL text(9,5,"5) Update Prices")
 CALL text(10,5,"6) Commit Changes and Exit")
 CALL text(13,5,"7) Exit")
 CALL text(14,5,"Choose 1 of the following :")
 IF (come_back=0)
  GO TO ext_owner_cd
 ENDIF
 CALL accept(14,35,"99;",7
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7))
 CASE (curaccept)
  OF 1:
   SET come_back = 0
   GO TO ext_owner_cd
  OF 2:
   SET come_back = 0
   GO TO affected_price_sched
  OF 3:
   SET come_back = 0
   GO TO populate_level
  OF 4:
   SET come_back = 0
   GO TO effective_dates
  OF 5:
   IF (update_ind=0)
    CALL clear(22,1)
    CALL text(22,1,"Calling afc_maintain_prices.")
    EXECUTE afc_maintain_prices
    CALL text(22,30,"Done.")
    SET update_ind = 1
   ELSE
    CALL clear(22,1)
    CALL text(22,1,"Already updated prices.")
   ENDIF
   GO TO set_zero_menu
  OF 6:
   COMMIT
   GO TO the_end
  OF 7:
   GO TO the_end
 ENDCASE
 SET quit_ind = 1
 GO TO menu
#flat_or_percent_menu
 IF (come_back=0)
  CALL clear(1,1)
 ENDIF
 CALL text(2,45,"***  CCL Batch Build - Price Maintenance  ***")
 CALL text(3,5,"Press <Shift+F5> for a list of Choices:")
 CALL text(5,5,"1) External Owner Code :")
 CALL text(6,5,"2) Baseline Price Schedule :")
 CALL text(7,5,"3) Affected Price Schedule :")
 CALL text(8,5,"4) Use Price As Effective On :")
 CALL text(9,5,"5) Level to Populate :")
 CALL text(10,5,"6) Effective Dates of New Prices :")
 CALL text(11,5,"7) Round? :")
 CALL text(12,5,"8) Precision :")
 CALL text(14,5,"9) Update Non Interval Prices")
 CALL text(15,5,"10) Update Interval Prices")
 CALL text(16,5,"11) Update All Prices")
 CALL text(17,5,"12) Commit Changes and Exit")
 CALL text(18,5,"13) Exit")
 CALL text(19,5,"Choose 1 of the following :")
 IF (come_back=0)
  GO TO ext_owner_cd
 ENDIF
 CALL accept(19,35,"99;",13
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7, 8, 9, 10,
  11, 12, 13))
 CASE (curaccept)
  OF 1:
   SET come_back = 0
   GO TO ext_owner_cd
  OF 2:
   SET come_back = 0
   GO TO base_price_sched
  OF 3:
   SET come_back = 0
   GO TO affected_price_sched
  OF 4:
   SET come_back = 0
   GO TO price_date
  OF 5:
   SET come_back = 0
   GO TO populate_level
  OF 6:
   SET come_back = 0
   GO TO effective_dates
  OF 7:
   SET come_back = 0
   GO TO rounding_up_down
  OF 8:
   SET come_back = 0
   GO TO rounding_precision
  OF 9:
   IF (update_ind=0)
    CALL clear(22,1)
    CALL text(22,1,"Calling afc_maintain_prices.")
    SET request->interval_ind = 0
    EXECUTE afc_maintain_prices
    CALL text(22,30,"Done.")
    SET update_ind = 1
   ELSE
    CALL clear(22,1)
    CALL text(22,1,"Already updated prices.")
   ENDIF
   GO TO flat_or_percent_menu
  OF 10:
   IF (update_ind=0)
    CALL clear(22,1)
    CALL text(22,1,"Calling afc_maintain_prices.")
    SET request->interval_ind = 1
    EXECUTE afc_maintain_prices
    CALL text(22,30,"Done.")
    SET update_ind = 1
   ELSE
    CALL clear(22,1)
    CALL text(22,1,"Already updated prices.")
   ENDIF
   GO TO flat_or_percent_menu
  OF 11:
   IF (update_ind=0)
    CALL clear(22,1)
    CALL text(22,1,"Calling afc_maintain_prices.")
    SET request->interval_ind = 2
    EXECUTE afc_maintain_prices
    CALL text(22,30,"Done.")
    SET update_ind = 1
   ELSE
    CALL clear(22,1)
    CALL text(22,1,"Already updated prices.")
   ENDIF
   GO TO flat_or_percent_menu
  OF 12:
   COMMIT
   GO TO the_end
  OF 13:
   GO TO the_end
 ENDCASE
 SET quit_ind = 1
 GO TO menu
#ext_owner_cd
 SET help =
 SELECT INTO "nl:"
  c.code_value"#################;l", c.display
  FROM code_value c
  WHERE c.code_set=106
   AND c.active_ind=1
  ORDER BY cnvtupper(c.display)
  WITH nocounter
 ;end select
 CALL accept(5,40,"A(17);fCU;",0)
 SET request->ext_owner_code = cnvtreal(curaccept)
 CALL video(n)
 SET update_ind = 0
 IF (come_back=0)
  IF ((request->setzero_ind=1))
   GO TO affected_price_sched
  ELSE
   GO TO base_price_sched
  ENDIF
 ENDIF
 SET quit_ind = 1
 GO TO menu
#base_price_sched
 SET help =
 SELECT INTO "nl:"
  p.price_sched_id, p.price_sched_desc
  FROM price_sched p
  WHERE p.active_ind=1
   AND p.pharm_ind=0
  ORDER BY cnvtupper(p.price_sched_desc)
  WITH nocounter
 ;end select
 CALL accept(6,40,"A(12);CUf;",0)
 SET request->from_price_sched_id = cnvtreal(curaccept)
 SELECT INTO "nl:"
  p.price_sched_desc
  FROM price_sched p
  WHERE (p.price_sched_id=request->from_price_sched_id)
  DETAIL
   request->from_price_sched_desc = trim(p.price_sched_desc)
  WITH nocounter
 ;end select
 CALL video(n)
 SET update_ind = 0
 IF (come_back=0)
  GO TO affected_price_sched
 ENDIF
 SET quit_ind = 1
 GO TO menu
#affected_price_sched
 SET help =
 SELECT INTO "nl:"
  p.price_sched_id, p.price_sched_desc
  FROM price_sched p
  WHERE p.active_ind=1
   AND p.pharm_ind=0
  ORDER BY cnvtupper(p.price_sched_desc)
  WITH nocounter
 ;end select
 SET update_ind = 0
 IF ((request->setzero_ind=1))
  CALL accept(6,40,"A(12);CUf;",0)
  SET request->to_price_sched_id = cnvtreal(curaccept)
  SELECT INTO "nl:"
   p.price_sched_desc
   FROM price_sched p
   WHERE (p.price_sched_id=request->to_price_sched_id)
   DETAIL
    request->to_price_sched_desc = trim(p.price_sched_desc)
   WITH nocounter
  ;end select
  CALL video(n)
  GO TO populate_level
 ELSE
  CALL accept(7,40,"A(12);CUf;",0)
  SET request->to_price_sched_id = cnvtreal(curaccept)
  SELECT INTO "nl:"
   p.price_sched_desc
   FROM price_sched p
   WHERE (p.price_sched_id=request->to_price_sched_id)
   DETAIL
    request->to_price_sched_desc = trim(p.price_sched_desc)
   WITH nocounter
  ;end select
  CALL video(n)
  GO TO price_date
 ENDIF
 SET quit_ind = 1
 GO TO menu
#price_date
 CALL accept(8,40,"99dAAAd9999d99d99d99;cu",format(request->price_effective_dt_tm,
   "dd-mmm-yyyy hh:mm:ss;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm:ss;;d")=curaccept)
 SET request->price_effective_dt_tm = cnvtdatetime(curaccept)
 SET update_ind = 0
 CALL video(n)
 IF (come_back=0)
  GO TO populate_level
 ENDIF
 SET quit_ind = 1
 GO TO menu
#populate_level
 SET help = fix('1 "Parent/Child",2 "Parent",3 "Child",4 "Default"')
 IF ((request->setzero_ind=1))
  CALL accept(7,40,"9;f",1
   WHERE curaccept IN (1, 2, 3, 4))
  CASE (curaccept)
   OF 1:
    SET request->level_ind = curaccept
   OF 2:
    SET request->level_ind = curaccept
   OF 3:
    SET request->level_ind = curaccept
   OF 4:
    SET request->level_ind = curaccept
  ENDCASE
 ELSE
  CALL accept(9,40,"9;f",1
   WHERE curaccept IN (1, 2, 3, 4))
  CASE (curaccept)
   OF 1:
    SET request->level_ind = curaccept
   OF 2:
    SET request->level_ind = curaccept
   OF 3:
    SET request->level_ind = curaccept
   OF 4:
    SET request->level_ind = curaccept
  ENDCASE
 ENDIF
 SET update_ind = 0
 CALL video(n)
 IF (come_back=0)
  GO TO effective_dates
 ENDIF
 SET quit_ind = 1
 GO TO menu
#effective_dates
 EXECUTE FROM display_dates TO display_dates_end
 EXECUTE FROM display_dates_fields TO display_dates_fields_end
 EXECUTE FROM accept_dates_fields TO accept_dates_fields_end
 SET update_ind = 0
 IF (come_back=0)
  IF ((request->setzero_ind=1))
   SET come_back = 1
   GO TO set_zero_menu
  ELSE
   GO TO rounding_up_down
  ENDIF
 ENDIF
 SET quit_ind = 1
 GO TO menu
#rounding_up_down
 CALL clear(12,40,80)
 SET help = fix('1 "No Rounding",2 "Up",3 "Down",4 "Standard Rounding"')
 CALL accept(11,40,"9;f",1
  WHERE curaccept IN (1, 2, 3, 4))
 SET request->roundingdirection_ind = curaccept
 CALL video(n)
 SET update_ind = 0
 IF (curaccept IN (2, 3, 4))
  GO TO rounding_precision
 ELSE
  SET come_back = 1
  GO TO flat_or_percent_menu
 ENDIF
#rounding_precision
 SET help = fix('1 "Nearest Dollar",2 "Nearest Ten Cents",3 "Nearest Cent"')
 CALL accept(12,40,"9;f",1
  WHERE curaccept IN (1, 2, 3))
 SET request->roundingamount_ind = curaccept
 CALL video(n)
 SET come_back = 1
 SET update_ind = 0
 GO TO flat_or_percent_menu
#display_dates
 CALL text(11,60,"1 Beginning Effective Dates :")
 CALL text(12,60,"2 End Effective Dates       :")
#display_dates_end
#display_dates_fields
 CALL text(11,92,format(request->beg_effective_dt_tm,"DD-MMM-YYYY HH:MM:SS;3;d"))
 CALL text(12,92,format(request->end_effective_dt_tm,"DD-MMM-YYYY HH:MM:SS;3;d"))
#display_dates_fields_end
#accept_dates_fields
 CALL text(14,60,"Correct (Y/N/Q)?")
 CALL accept(14,78,"p;cu","Y"
  WHERE curaccept IN ("Y", "N", "Q"))
 CALL clear(14,52,80)
 CALL video(n)
 SET update_ind = 0
 CASE (curaccept)
  OF "Y":
   IF ((request->setzero_ind=1))
    CALL clear(11,60,80)
    CALL clear(12,60,80)
    CALL text(8,40,format(request->beg_effective_dt_tm,"DD-MMM-YYYY HH:MM:SS;3;d"))
    CALL text(8,65,format(request->end_effective_dt_tm,"DD-MMM-YYYY HH:MM:SS;3;d"))
   ELSE
    CALL clear(11,60,80)
    CALL clear(12,60,80)
    CALL text(10,40,format(request->beg_effective_dt_tm,"DD-MMM-YYYY HH:MM:SS;3;d"))
    CALL text(10,65,format(request->end_effective_dt_tm,"DD-MMM-YYYY HH:MM:SS;3;d"))
   ENDIF
   GO TO accept_dates_fields_end
  OF "N":
   GO TO accept_dates_line_nbr
  OF "Q":
   SET quit_ind = 1
   GO TO menu
  ELSE
   GO TO accept_dates_fields
 ENDCASE
#accept_dates_01
 CALL video(n)
 CALL accept(11,92,"99dAAAd9999d99d99d99;cu",format(beg_of_day,"dd-mmm-yyyy hh:mm:ss;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm:ss;;d")=curaccept)
 SET request->beg_effective_dt_tm = cnvtdatetime(curaccept)
 GO TO accept_dates_02
#accept_dates_02
 CALL video(n)
 CALL accept(12,92,"99dAAAd9999d99d99d99;cu",format(end_of_day,"dd-mmm-yyyy hh:mm:ss;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm:ss;;d")=curaccept)
 SET request->end_effective_dt_tm = cnvtdatetime(curaccept)
 GO TO accept_dates_fields
#accept_dates_line_nbr
 CALL video(n)
 CALL text(14,60,"Line Number :")
 CALL accept(14,74,"9;",0
  WHERE curaccept IN (0, 1, 2))
 CALL clear(14,52,80)
 CASE (curaccept)
  OF 0:
   GO TO accept_dates_fields
  OF 1:
   GO TO accept_dates_01
  OF 2:
   GO TO accept_dates_02
 ENDCASE
#accept_dates_fields_end
 CALL video(n)
 GO TO menu
#display_change
 CALL video(n)
 IF ((request->flat_ind=1))
  CALL text(4,54,"Amount: (Enter 5.5 for $5.50)")
  CALL accept(5,54,"NNNNN;",0)
  SET request->flat_ind = 1
  SET request->flatchange = curaccept
 ELSEIF ((request->percent_ind=1))
  CALL text(4,54,"Amount: (Enter 10 for 10%)")
  CALL accept(5,54,"NNNNN;",0)
  SET request->percent_ind = 1
  SET request->percentchange = curaccept
 ELSE
  SET request->setzero_ind = 1
 ENDIF
#display_change_end
#the_end
 ROLLBACK
 FREE SET request
 CALL clear(1,1)
END GO
