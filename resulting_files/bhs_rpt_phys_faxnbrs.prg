CREATE PROGRAM bhs_rpt_phys_faxnbrs
 PROMPT
  "Enter Last Name" = "*",
  "Output to Screen/Printer" = "MINE"
  WITH prompt2, outdev
 EXECUTE bhs_check_domain:dba
 DECLARE localflg = c5
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  d.description, d.name, d.device_type_cd,
  d_device_type_disp = uar_get_code_display(d.device_type_cd), rd.area_code, rd.exchange,
  rd.phone_suffix, rd.device_address_type_cd, rd.device_cd,
  rd.phone_mask_id, rd.remote_dev_type_id, dxr.parent_entity_name
  FROM remote_device rd,
   device d,
   cr_destination_xref dxr
  PLAN (d
   WHERE (cnvtupper(d.name)= $PROMPT2))
   JOIN (rd
   WHERE d.device_cd=rd.device_cd
    AND rd.exchange > " ")
   JOIN (dxr
   WHERE d.device_cd=dxr.device_cd
    AND dxr.parent_entity_name="PRSNL")
  ORDER BY d.description
  HEAD PAGE
   "{cpi/12}", xcol = 76, ycol = 30,
   CALL print(calcpos(xcol,ycol)), "ln", row + 1,
   ycol += 10,
   CALL print(calcpos(xcol,ycol)), "nbr",
   row + 1, xcol += 50,
   CALL print(calcpos(xcol,ycol)),
   "Name", xcol += 115,
   CALL print(calcpos(xcol,ycol)),
   "FAX Number", xcol += 85,
   CALL print(calcpos(xcol,ycol)),
   "Local", row + 1, xcol = 72,
   ycol += 10, line = fillstring(50,"-"),
   CALL print(calcpos(xcol,ycol)),
   line, row + 1
  DETAIL
   lncnt += 1, xcol = 72, ycol += 10,
   CALL print(calcpos(xcol,ycol)), lncnt"####", xcol = 72,
   xcol += 30,
   CALL print(calcpos(xcol,ycol)), d.name"#########################",
   xcol += 140,
   CALL print(calcpos(xcol,ycol)), rd.area_code"###",
   xcol += 25,
   CALL print(calcpos(xcol,ycol)), rd.exchange"###",
   xcol += 25,
   CALL print(calcpos(xcol,ycol)), rd.phone_suffix"####",
   localflg =
   IF (rd.local_flag=1) "Yes"
   ELSE "No"
   ENDIF
   , xcol += 40,
   CALL print(calcpos(xcol,ycol)),
   localflg, row + 1
   IF (row >= 64)
    BREAK
   ENDIF
  FOOT PAGE
   "{cpi/15}", row + 1, xcol = 72,
   ycol = 700,
   CALL print(calcpos((xcol+ 10),ycol)), curprog,
   CALL print(calcpos((xcol+ 134),ycol)), curdate,
   CALL print(calcpos((xcol+ 190),ycol)),
   curnode
   IF (gl_bhs_prod_flag=1)
    ms_temp = "PROD"
   ELSE
    CASE (curnode)
     OF "cisr":
      ms_temp = "READonly"
     OF "casdtest":
      ms_temp = "BUILD"
     OF "casbtest":
      ms_temp = "CERT"
     ELSE
      ms_temp = "domain?"
    ENDCASE
   ENDIF
   CALL print(calcpos((xcol+ 250),ycol)), ms_temp,
   CALL print(calcpos((xcol+ 320),ycol)),
   "Page:", curpage"{cpi/12}"
  WITH dio = postscript, maxrow = 66
 ;end select
END GO
