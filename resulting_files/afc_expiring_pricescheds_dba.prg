CREATE PROGRAM afc_expiring_pricescheds:dba
 PAINT
 SET width = 140
 SET modify = system
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = i2
   1 updt_applctx = i4
   1 updt_task = i4
   1 updt_dt_tm = dq8
 )
 SET reqinfo->updt_id = 1100
 SET reqinfo->updt_applctx = 951100
 SET reqinfo->updt_task = 951100
 SET reqinfo->updt_dt_tm = cnvtdatetime(curdate,curtime)
 FREE SET request
 RECORD request(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 action_type = c3
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 ext_description = c40
     2 display = c40
     2 price_sched_desc = c40
     2 price_sched_items_id = f8
     2 price = f8
     2 price_ind = i2
     2 percent_revenue = i4
     2 charge_level_cd = f8
     2 interval_template_cd = f8
     2 detail_charge_ind_ind = i2
     2 detail_charge_ind = i2
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 end_effective_dt_tm_ind = i2
     2 updt_cnt = i4
     2 updt_id = f8
     2 updt_dt_tm = dq8
     2 updt_applctx = f8
     2 updt_task = f8
     2 units_ind = i2
     2 units_ind_ind = i2
 )
 SET new_price_sched_id = 0.0
 SET cur_date_time = datetimeadd(cnvtdatetime(curdate,curtime),1)
 SET end_of_day = cnvtdatetime(concat(format(cur_date_time,"dd-mmm-yyyy;;d")," 23:59:59.59"))
#menu
 CALL text(1,45,"***  Expiring Price Schedule Report  ***")
 CALL text(3,10,"Press <Shift+F5> for a list of Choices:")
 CALL text(5,10,"1) Select an END date ")
 CALL text(6,10,"2) Choose a Price Schedule")
 CALL text(8,10,"3) Create Report")
 CALL text(10,10,"4) Exit")
 CALL text(12,10,"Choose 1 of the following :")
 CALL accept(12,38,"9;",4
  WHERE curaccept IN (1, 2, 3, 4))
 CASE (curaccept)
  OF 1:
   GO TO select_date
  OF 2:
   GO TO select_pricesched
  OF 3:
   GO TO create_report
  OF 4:
   GO TO the_end
 ENDCASE
 GO TO menu
#select_date
 EXECUTE FROM display_dates TO display_dates_end
 EXECUTE FROM display_dates_fields TO display_dates_fields_end
 EXECUTE FROM accept_dates_fields TO accept_dates_fields_end
 GO TO menu
#display_dates
 CALL text(5,60,"01 End Effective Date :")
#display_dates_end
#display_dates_fields
 CALL text(05,92,format(end_of_day,"DD-MMM-YYYY HH:MM;3;d"))
#display_dates_fields_end
#accept_dates_fields
 CALL text(14,60,"Correct (Y/N/Q)?")
 CALL accept(14,78,"p;cu","Y"
  WHERE curaccept IN ("Y", "N", "Q"))
 CALL clear(14,60)
 CASE (curaccept)
  OF "Y":
   CALL clear(5,60)
   CALL text(5,45,format(end_of_day,"DD-MMM-YYYY HH:MM;3;d"))
   GO TO accept_dates_fields_end
  OF "N":
   GO TO accept_dates_line_nbr
  OF "Q":
   GO TO menu
  ELSE
   GO TO accept_dates_fields
 ENDCASE
#accept_dates_01
 CALL accept(5,92,"nndpppdnnnndnndnn;cs",format(end_of_day,"dd-mmm-yyyy hh:mm;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm;;d")=curaccept)
 CASE (curscroll)
  OF 0:
   SET end_of_day = cnvtdatetime(curaccept)
  OF 2:
   CALL text(5,92,format(end_of_day,"DD-MMM-YYYY HH:MM;3;d"))
   GO TO accept_dates_01
  OF 3:
   CALL text(5,92,format(end_of_day,"DD-MMM-YYYY HH:MM;3;d"))
   GO TO accept_dates_end
  ELSE
   GO TO accept_dates_01
 ENDCASE
#accept_dates_end
 GO TO accept_dates_fields
#accept_dates_line_nbr
 CALL video(n)
 CALL text(14,60,"Line Number :")
 CALL video(lu)
 SET accept = nochange
 CALL accept(14,74,"9;",0
  WHERE curaccept >= 0
   AND curaccept <= 8)
 CALL clear(14,60)
 SET accept = change
 CASE (curaccept)
  OF 0:
   GO TO accept_dates_fields
  OF 1:
   GO TO accept_dates_01
  ELSE
   GO TO accept_dates_line_nbr
 ENDCASE
#accept_dates_fields_end
 GO TO menu
#select_pricesched
 SET help =
 SELECT INTO "nl:"
  p.price_sched_id, p.price_sched_desc
  FROM price_sched p
  WHERE p.active_ind=1
   AND p.pharm_ind=0
  WITH nocounter
 ;end select
 CALL accept(6,50,"A(12);CU;",0)
 SET new_price_sched_id = cnvtint(curaccept)
 GO TO menu
#create_report
 SET count1 = 0
 SELECT INTO "nl:"
  p.*, b.ext_description, b.ext_owner_cd,
  c.display, p2.price_sched_desc
  FROM price_sched_items p,
   bill_item b,
   code_value c,
   price_sched p2
  PLAN (p
   WHERE p.price_sched_id=new_price_sched_id
    AND p.active_ind=1)
   JOIN (p2
   WHERE p.price_sched_id=p2.price_sched_id)
   JOIN (b
   WHERE p.bill_item_id=b.bill_item_id
    AND b.active_ind=1)
   JOIN (c
   WHERE b.ext_owner_cd=c.code_value
    AND c.active_ind=1)
  ORDER BY c.display, b.ext_description, b.bill_item_id,
   p.end_effective_dt_tm DESC
  DETAIL
   count1 = (count1+ 1), stat = alterlist(request->price_sched_items,count1), request->
   price_sched_items[count1].price_sched_desc = p2.price_sched_desc,
   request->price_sched_items[count1].ext_description = b.ext_description, request->
   price_sched_items[count1].display = c.display, request->price_sched_items[count1].bill_item_id = p
   .bill_item_id,
   request->price_sched_items[count1].price = p.price, request->price_sched_items[count1].
   beg_effective_dt_tm = p.beg_effective_dt_tm, request->price_sched_items[count1].
   end_effective_dt_tm = p.end_effective_dt_tm,
   request->price_sched_items[count1].price_sched_items_id = p.price_sched_items_id
  WITH nocounter
 ;end select
 SET request->price_sched_items_qual = count1
 CALL text(14,10,"Processing..")
 SET file = "MINE"
 SET count2 = 0
 SET old_bill_item_id = 0.0
 SET exp_date = concat(format(end_of_day,"mmm-dd-yyyy;;d")," 23:59:59.59")
 SELECT INTO value(file)
  FROM (dummyt d1  WITH seq = value(request->price_sched_items_qual))
  HEAD REPORT
   line = fillstring(130,"="), col 0, "Expiring Price Schedules Report",
   col 100, curdate"MMM-DD-YYYY;;D", col 112,
   curtime"HH:MM:SS;;M", row + 1, col 0,
   line, row + 1, col 0,
   "Price Schedule: ", request->price_sched_items[d1.seq].price_sched_desc"##################", col
   74,
   "Expiring On or Before: ", exp_date, row + 2,
   col 0, "External Owner", col 25,
   "Bill Item", col 52, "Bill Item Id",
   col 69, "Price", col 82,
   "Beg Effective Date", col 102, "End Effective Date",
   row + 1, col 0, line,
   row + 1
  DETAIL
   IF ((old_bill_item_id=request->price_sched_items[d1.seq].bill_item_id))
    IF ((request->price_sched_items[d1.seq].end_effective_dt_tm > cnvtdatetime(end_of_day)))
     count1 = count1
    ELSE
     count1 = count1
    ENDIF
   ELSEIF ((old_bill_item_id != request->price_sched_items[d1.seq].bill_item_id))
    IF ((request->price_sched_items[d1.seq].end_effective_dt_tm > cnvtdatetime(end_of_day)))
     count1 = count1
    ELSE
     IF (((row+ 4) > maxrow))
      BREAK
     ENDIF
     col 0, request->price_sched_items[d1.seq].display"#######################", col 25,
     request->price_sched_items[d1.seq].ext_description"##########################", col 50, request
     ->price_sched_items[d1.seq].bill_item_id"############",
     col 69, request->price_sched_items[d1.seq].price"$####.##", col 82,
     request->price_sched_items[d1.seq].beg_effective_dt_tm"MM/DD/YY HH:MM:SS;;D", col 102, request->
     price_sched_items[d1.seq].end_effective_dt_tm"MM/DD/YY HH:MM:SS;;D",
     row + 1, count1 = (count1+ 1)
    ENDIF
   ENDIF
   old_bill_item_id = request->price_sched_items[d1.seq].bill_item_id
  FOOT PAGE
   col 0, line, row + 1,
   col 01, "Printed: ", col 10,
   curdate"DDMMMYY;;D", col 18, curtime"HH:MM;;M",
   col 25, "By: ", col 29,
   curuser"######", col 110, "Page: ",
   col 116, curpage"###"
  WITH nocounter
 ;end select
 CALL echo(build("Outfile is: ",file))
 GO TO menu
#the_end
END GO
