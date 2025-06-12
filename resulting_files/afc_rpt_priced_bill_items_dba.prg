CREATE PROGRAM afc_rpt_priced_bill_items:dba
 PAINT
 CALL text(2,10,"Press Shift+F5 for a list of price schedules")
 CALL text(5,10,"Price Schedule :")
 CALL text(6,10,"Price Schedule :")
 CALL text(7,10,"Price Schedule :")
 SET help =
 SELECT INTO "NL:"
  p.price_sched_id, p.price_sched_desc
  FROM price_sched p
  WHERE p.active_ind=1
  WITH nocounter
 ;end select
 CALL accept(5,30,"9(11);DS;",0)
 SET price_sched_one = curaccept
 CALL accept(6,30,"9(11);DS;",0)
 SET price_sched_two = curaccept
 CALL accept(7,30,"9(11);DS;",0)
 SET price_sched_three = curaccept
 CALL text(10,10,"Loading Data...")
 SELECT
  b.ext_description, p.price, p.price_sched_id,
  pr.price_sched_desc
  FROM bill_item b,
   price_sched_items p,
   price_sched pr
  PLAN (pr
   WHERE pr.price_sched_id IN (price_sched_one, price_sched_two, price_sched_three)
    AND pr.active_ind=1)
   JOIN (b
   WHERE b.active_ind=1)
   JOIN (p
   WHERE p.bill_item_id=b.bill_item_id
    AND p.active_ind=1
    AND p.price_sched_id=pr.price_sched_id)
  ORDER BY pr.price_sched_desc, b.ext_description
  HEAD REPORT
   mycount = 0, description = fillstring(30," "), priceschedule = fillstring(20," "),
   billitemid = fillstring(11," "), dashline = fillstring(100,"=")
  HEAD PAGE
   CALL center("* * * B I L L   I T E M   W I T H   P R I C E S   R E P O R T * * *",01,100), row + 2,
   col 1,
   "Report Name: AFC_RPT_PRICED_BILL_ITEMS", row + 1, col 1,
   curdate"MM/DD/YY;;D", col + 1, curtime"HH:MM;;M",
   row + 1, col 01, "Price Schedule",
   col 28, "Bill Item ID", col 50,
   "Bill Item Description", col 85, "Price",
   row + 1, dashline, row + 1,
   priceschedule = trim(pr.price_sched_desc), col 01, priceschedule
  HEAD p.price_sched_id
   priceschedule = trim(pr.price_sched_desc), col 01, priceschedule,
   row + 1
  DETAIL
   description = trim(b.ext_description), billitemid = cnvtstring(b.bill_item_id,17,2), mycount = (
   mycount+ 1),
   col 50, description, col 30,
   billitemid, col 85, p.price"$#######.##",
   row + 1
  FOOT PAGE
   col 110, "PAGE:", col + 1,
   curpage"###"
  FOOT REPORT
   row + 2, col 1, "Total Number of Bill Items With Prices =",
   count(mycount)
  WITH nocounter
 ;end select
END GO
