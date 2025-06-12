CREATE PROGRAM bhs_test_barcode_scan
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD request
 RECORD request(
   1 barcode = vc
   1 facility_cd = f8
   1 ndc = vc
   1 identifier = vc
   1 identifier_type_cd = f8
 )
 SET request->barcode = "6952365"
 SET request->facility_cd = 2583987.00
 EXECUTE dcp_get_orc_from_barcode
END GO
