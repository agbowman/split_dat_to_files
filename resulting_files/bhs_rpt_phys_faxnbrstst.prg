CREATE PROGRAM bhs_rpt_phys_faxnbrstst
 PROMPT
  "Enter Last Name" = "*",
  "Output to Screen/Printer" = "MINE"
  WITH prompt2, outdev
 DECLARE localflg = c5
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  d.description, d.name, d.device_type_cd,
  d_device_type_disp = uar_get_code_display(d.device_type_cd), rd.area_code, rd.exchange,
  rd.phone_suffix, rd.device_address_type_cd, rd.device_cd,
  rd.phone_mask_id, rd.remote_dev_type_id, dxr.parent_entity_name
  FROM remote_device rd,
   device d,
   device_xref dxr
  PLAN (d
   WHERE (cnvtupper(d.name)= $PROMPT2))
   JOIN (rd
   WHERE d.device_cd=rd.device_cd
    AND rd.exchange > " ")
   JOIN (dxr
   WHERE d.device_cd=dxr.device_cd
    AND dxr.parent_entity_name="PRSNL")
  ORDER BY d.description
  WITH format, separator = " "
 ;end select
END GO
