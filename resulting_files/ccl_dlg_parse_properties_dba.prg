CREATE PROGRAM ccl_dlg_parse_properties:dba
 PROMPT
  "PROMPT_ID" = 0,
  "Component Name" = " ",
  "Property Name" = " "
  WITH prmptid, cmpt, prop
 EXECUTE ccl_prompt_api_dataset "dataset", "noautoset"
 DECLARE txtbuffer = vc WITH notrim
 DECLARE propname = vc WITH notrim
 DECLARE propvalue = vc WITH notrim
 SELECT INTO "nl:"
  FROM ccl_prompt_properties p
  WHERE (p.prompt_id= $PRMPTID)
   AND (p.component_name= $CMPT)
   AND (p.property_name= $PROP)
  HEAD REPORT
   strname = fillstring(30," "), strvalue = fillstring(1000," "), stat = makedataset(10),
   fline = addintegerfield("LINE","Line:",true), fname = addstringfield("PROPERTY_NAME","Name:",true,
    40), fvalue = addstringfield("PROPERTY_VALUE","Value:",true,2000),
   pscnt = 0
  DETAIL
   pvallen = size(p.property_value)
   IF (pvallen > 0)
    pch = 1
    IF (substring(1,12, $PROP) != "STRING-TABLE")
     pscnt = 0
     WHILE (pch < pvallen)
       recno = getnextrecord(0), propname = "", propvalue = ""
       WHILE (pch <= pvallen
        AND substring(pch,1,p.property_value) <= char(32))
         pch = (pch+ 1)
       ENDWHILE
       IF (substring(pch,1,p.property_value)="{")
        pscnt = (pscnt+ 1), pch = (pch+ 1)
       ENDIF
       pos = pch
       WHILE (pch <= pvallen
        AND substring(pch,1,p.property_value) != "=")
         pch = (pch+ 1)
       ENDWHILE
       propname = substring(pos,(pch - pos),p.property_value)
       IF (pscnt > 0)
        propname = concat(trim(cnvtstring(pscnt)),") ",propname)
       ENDIF
       WHILE (pch <= pvallen
        AND substring(pch,1,p.property_value) != "'")
         pch = (pch+ 1)
       ENDWHILE
       pch = (pch+ 1), pos = pch
       WHILE (pch <= pvallen
        AND substring(pch,1,p.property_value) != "'")
         pch = (pch+ 1)
       ENDWHILE
       propvalue = substring(pos,(pch - pos),p.property_value), pch = (pch+ 1)
       WHILE (pch <= pvallen
        AND substring(pch,1,p.property_value) <= char(32))
         pch = (pch+ 1)
       ENDWHILE
       IF (substring(pch,1,p.property_value)="}")
        pch = (pch+ 1)
       ENDIF
       propvalue = replace(propvalue,"&#034;",'"'), propvalue = replace(propvalue,"&#061;","="),
       propvalue = replace(propvalue,"&#123;","{"),
       propvalue = replace(propvalue,"&#125;","}"), stat = setintegerfield(recno,fline,recno), stat
        = setstringfield(recno,fname,propname),
       stat = setstringfield(recno,fvalue,propvalue)
     ENDWHILE
    ENDIF
   ENDIF
  FOOT REPORT
   stat = setstatus("S"), stat = closedataset(0)
  WITH nocounter
 ;end select
END GO
