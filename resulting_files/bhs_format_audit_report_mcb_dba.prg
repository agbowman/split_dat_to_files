CREATE PROGRAM bhs_format_audit_report_mcb:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE cclseclogin
 RECORD oef(
   1 cnt = i4
   1 qual[*]
     2 oe_format_name = vc
     2 oe_format_id = f8
     2 action_type_cd = f8
     2 action_type = vc
     2 catalog_type = vc
     2 fcnt = i4
     2 qual[*]
       3 description = vc
       3 oe_field_id = f8
       3 accept_flag = vc
       3 default_value = vc
     2 flexcnt = i4
     2 fqual[*]
       3 flex_type = vc
       3 flex_cd = f8
       3 flex_value = vc
       3 fcnt = i4
       3 qual[*]
         4 description = vc
         4 accept_flag = vc
         4 default_value = vc
 )
 SET oef->cnt = 0
 SET stat = alterlist(oef->qual,25)
 SET disp_val5 = fillstring(10," ")
 SELECT INTO "nl:"
  oef.oe_format_id, off.oe_format_id, oef.oe_format_name,
  field.oe_field_id
  FROM order_entry_format oef,
   (dummyt d1  WITH seq = 1),
   oe_format_fields off,
   order_entry_fields field
  PLAN (oef
   WHERE oef.action_type_cd=2534)
   JOIN (d1)
   JOIN (off
   WHERE off.oe_format_id=oef.oe_format_id
    AND off.action_type_cd=oef.action_type_cd)
   JOIN (field
   WHERE field.oe_field_id=off.oe_field_id)
  ORDER BY oef.oe_format_name, oef.action_type_cd, off.group_seq,
   off.field_seq
  HEAD oef.oe_format_name
   oef->cnt = (oef->cnt+ 1)
   IF ((oef->cnt > size(oef->qual,5)))
    stat = alterlist(oef->qual,(oef->cnt+ 10))
   ENDIF
   oef->qual[oef->cnt].oe_format_name = substring(1,30,oef.oe_format_name), oef->qual[oef->cnt].
   oe_format_id = oef.oe_format_id, oef->qual[oef->cnt].action_type = substring(1,15,
    uar_get_code_display(oef.action_type_cd)),
   oef->qual[oef->cnt].action_type_cd = oef.action_type_cd, oef->qual[oef->cnt].catalog_type =
   substring(1,20,uar_get_code_display(oef.catalog_type_cd)), oef->qual[oef->cnt].fcnt = 0
  DETAIL
   oef->qual[oef->cnt].fcnt = (oef->qual[oef->cnt].fcnt+ 1), ftmp = oef->qual[oef->cnt].fcnt
   IF (ftmp > size(oef->qual[oef->cnt].qual,5))
    stat = alterlist(oef->qual[oef->cnt].qual,(ftmp+ 10))
   ENDIF
   oef->qual[oef->cnt].qual[ftmp].description = substring(1,30,field.description)
   IF (off.accept_flag=0)
    disp_val5 = "Required"
   ELSEIF (off.accept_flag=1)
    disp_val5 = "Optional"
   ELSEIF (off.accept_flag=2)
    disp_val5 = "No Display"
   ELSEIF (off.accept_flag=3)
    disp_val5 = "Display Only"
   ELSE
    disp_val5 = "Unknown"
   ENDIF
   oef->qual[oef->cnt].qual[ftmp].accept_flag = disp_val5, oef->qual[oef->cnt].qual[ftmp].oe_field_id
    = field.oe_field_id, oef->qual[oef->cnt].qual[ftmp].default_value = substring(1,30,off
    .default_value)
  WITH nocounter, outerjoin = d1
 ;end select
 FOR (ff = 1 TO oef->cnt)
  SET oef->qual[ff].flexcnt = 0
  SELECT INTO "nl:"
   aff.oe_format_id, aff.flex_type_flag, aff.flex_cd,
   field.oe_field_id, flex_val = uar_get_code_display(aff.flex_cd)
   FROM accept_format_flexing aff,
    order_entry_fields field
   PLAN (aff
    WHERE (aff.oe_format_id=oef->qual[ff].oe_format_id)
     AND (aff.action_type_cd=oef->qual[ff].action_type_cd)
     AND aff.flex_type_flag IN (1, 4))
    JOIN (field
    WHERE field.oe_field_id=aff.oe_field_id)
   ORDER BY aff.flex_type_flag, flex_val, aff.flex_cd
   HEAD aff.flex_cd
    oef->qual[ff].flexcnt = (oef->qual[ff].flexcnt+ 1), flextmp = oef->qual[ff].flexcnt
    IF (flextmp > size(oef->qual[ff].fqual,5))
     stat = alterlist(oef->qual[ff].fqual,(flextmp+ 10))
    ENDIF
    disp_val9 = fillstring(20," ")
    IF (aff.flex_type_flag=0)
     disp_val9 = "Ordering Location"
    ELSEIF (aff.flex_type_flag=1)
     disp_val9 = "Patient Location"
    ELSEIF (aff.flex_type_flag=2)
     disp_val9 = "Application"
    ELSEIF (aff.flex_type_flag=3)
     disp_val9 = "Position"
    ELSEIF (aff.flex_type_flag=4)
     disp_val9 = "Encounter Type"
    ENDIF
    oef->qual[ff].fqual[flextmp].flex_type = disp_val9, oef->qual[ff].fqual[flextmp].flex_cd = aff
    .flex_cd, oef->qual[ff].fqual[flextmp].flex_value = trim(uar_get_code_display(aff.flex_cd)),
    oef->qual[ff].fqual[flextmp].fcnt = 0
   DETAIL
    oef->qual[ff].fqual[flextmp].fcnt = (oef->qual[ff].fqual[flextmp].fcnt+ 1), fftmp = oef->qual[ff]
    .fqual[flextmp].fcnt
    IF (fftmp > size(oef->qual[ff].fqual[flextmp].qual,5))
     stat = alterlist(oef->qual[ff].fqual[flextmp].qual,(fftmp+ 10))
    ENDIF
    IF (aff.accept_flag=0)
     disp_val5 = "Required"
    ELSEIF (aff.accept_flag=1)
     disp_val5 = "Optional"
    ELSEIF (aff.accept_flag=2)
     disp_val5 = "No Display"
    ELSEIF (aff.accept_flag=3)
     disp_val5 = "Display Only"
    ELSE
     disp_val5 = "Unknown"
    ENDIF
    oef->qual[ff].fqual[flextmp].qual[fftmp].description = substring(1,30,field.description), oef->
    qual[ff].fqual[flextmp].qual[fftmp].accept_flag = disp_val5, oef->qual[ff].fqual[flextmp].qual[
    fftmp].default_value = substring(1,30,aff.default_value)
   WITH nocounter
  ;end select
 ENDFOR
 SELECT INTO  $1
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD PAGE
   row + 1, col 45, "Order Entry Format Report"
  DETAIL
   FOR (aa = 1 TO oef->cnt)
     row + 3, col 2, "Format Name: ",
     oef->qual[aa].oe_format_name, col 40, "Action: ",
     oef->qual[aa].action_type, col 65, "Catalog Type: ",
     oef->qual[aa].catalog_type, col 110, "Fmt ID:",
     oef->qual[aa].oe_format_id
     IF ((oef->qual[aa].fcnt > 0))
      FOR (bb = 1 TO oef->qual[aa].fcnt)
        row + 1, col 10, "Field Name: ",
        oef->qual[aa].qual[bb].description, col 55, "Accept Flag: ",
        oef->qual[aa].qual[bb].accept_flag, col 80, "Default Value: ",
        oef->qual[aa].qual[bb].default_value, col 110, "Fld ID:",
        oef->qual[aa].qual[bb].oe_field_id
      ENDFOR
     ENDIF
     IF ((oef->qual[aa].flexcnt > 0))
      FOR (cc = 1 TO oef->qual[aa].flexcnt)
        row + 2, col 6, "Flex Type: ",
        oef->qual[aa].fqual[cc].flex_type, col 40, "Flex Value: ",
        oef->qual[aa].fqual[cc].flex_value
        FOR (dd = 1 TO oef->qual[aa].fqual[cc].fcnt)
          row + 1, col 10, "Field Name: ",
          oef->qual[aa].fqual[cc].qual[dd].description, col 55, "Accept Flag: ",
          oef->qual[aa].fqual[cc].qual[dd].accept_flag, col 80, "Default Value: ",
          oef->qual[aa].fqual[cc].qual[dd].default_value
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
   IF (row > 55)
    BREAK
   ENDIF
  WITH maxcol = 150, nocounter, outerjoin = d1
 ;end select
END GO
