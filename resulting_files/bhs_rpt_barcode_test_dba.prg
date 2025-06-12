CREATE PROGRAM bhs_rpt_barcode_test:dba
 PROMPT
  "Output to File/Printer/MINE" = "bisis1pharm1",
  "Enter DHID:" = 44982178.0
  WITH outdev, dhid
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  DETAIL
   dsbar_code = fillstring(15," "), bar_code = fillstring(18," "), ord_id = cnvtstring( $DHID,9,0,r),
   bar_code = concat("*T",ord_id,"*{f/0}"), dsbar_code = concat(trim(ord_id)),
   "{f/1/1}{lpi/8}{cpi/18}",
   CALL print(calcpos(100,75)),
   CALL print(ord_id), row + 1,
   "{lpi/12}{cpi/8}{f/28/3}",
   CALL print(calcpos(100,100)), bar_code,
   row + 1
  WITH nocounter, dio = 16, maxcol = 250,
   noformfeed
 ;end select
END GO
