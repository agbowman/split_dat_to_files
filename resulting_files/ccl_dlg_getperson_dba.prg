CREATE PROGRAM ccl_dlg_getperson:dba
 PROMPT
  "starting last name " = "",
  "maximum allowed" = 20
  WITH strlastname, nmax
 EXECUTE ccl_prompt_api_dataset "autoset", "dataset", "context"
 DECLARE lastname = vc
 DECLARE firstname = vc
 DECLARE personid = f8 WITH noconstant(0.0)
 DECLARE maxrows = i4 WITH noconstant(20)
 DECLARE contqual = i4 WITH noconstant(0)
 SET maxrows = cnvtint( $NMAX)
 IF (getcontextcount(0)=4)
  SET contqual = true
  SET lastname = getcontextrecord(1)
  SET firstname = getcontextrecord(2)
  SET personid = cnvtint(getcontextrecord(3))
  SET maxrows = cnvtint(getcontextrecord(4))
  SET stat = setcontextsize(0)
 ELSE
  SET contqual = false
  SET lastname = trim(cnvtupper( $STRLASTNAME))
 ENDIF
 SELECT
  IF (contqual)
   WHERE ((p.name_last_key > lastname) OR (p.name_last_key=lastname
    AND ((p.name_first_key=firstname
    AND p.person_id > personid) OR (p.name_first_key > firstname)) ))
  ELSE
   WHERE p.name_last_key=lastname
  ENDIF
  INTO "nl:"
  p.person_id, p.name_full_formatted, p.name_last_key,
  p.name_first_key
  FROM person p
  ORDER BY p.name_last_key, p.name_first_key, p.person_id
  HEAD REPORT
   stat = makedataset(20)
  DETAIL
   stat = writerecord(0)
  FOOT REPORT
   IF (recordcount(0)=0)
    stat = setmessageboxex(concat("No persons matching '", $STRLASTNAME,"' found"),"Get Person",
     _mb_info_)
   ELSEIF (recordcount(0) >= maxrows)
    stat = setcontextsize(4), stat = setcontextrecord(1,p.name_last_key), stat = setcontextrecord(2,p
     .name_first_key),
    stat = setcontextrecord(3,cnvtstring(p.person_id)), stat = setcontextrecord(4,cnvtstring(maxrows)
     )
   ENDIF
   stat = closedataset(0), stat = setstatus("S")
  WITH maxrow = 1, reporthelp, check,
   maxqual(p,value(maxrows))
 ;end select
END GO
