CREATE PROGRAM djh_121354_device_tbl
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  d.description, r.area_code, r.exchange,
  r.phone_suffix, d.device_cd, d_device_function_disp = uar_get_code_display(d.device_function_cd),
  d_device_type_disp = uar_get_code_display(d.device_type_cd), d.name, d.updt_dt_tm,
  d.updt_id, r.local_flag, r.remote_dev_type_id
  FROM device d,
   remote_device r
  PLAN (d
   WHERE d.name != "CVS,*"
    AND d.name != "Bills,*"
    AND d.name != "Brooks,*"
    AND d.name != "PriceChop,*"
    AND d.name != "BigY,*"
    AND d.name != "Stp/Shp,*"
    AND d.name != "Target,*"
    AND d.name != "Walmart,*"
    AND d.name != "Walg,*"
    AND d.name != "Lou/Clrk,*"
    AND d.name != "Walgreen,*"
    AND d.name != "test*"
    AND d.name != "BMC *"
    AND d.name != "3300*"
    AND d.name != "AA Test*"
    AND d.name != "Footit,WSp*"
    AND d.name != "FreedomFert,Bye*"
    AND d.name != "Flynns,Ptt*"
    AND d.name != "AbleCare,Enfld,Palom"
    AND d.name != "AdvnceRx,Scottsdale"
    AND d.name != "AgawamMed,Agawam"
    AND d.name != "AnthemHMO"
    AND d.name != "Apothecary,Spfld"
    AND d.name != "Apria,Sprgfld,Carand"
    AND d.name != "ApriaHlth,Spfld"
    AND d.name != "Arrow,NHamp,Main"
    AND d.name != "Arrow,Wstfld,NElm"
    AND d.name != "AtlanticHMS")
   JOIN (r
   WHERE d.device_cd=r.device_cd
    AND r.exchange > " ")
  ORDER BY d.description
  WITH maxrec = 1200, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
