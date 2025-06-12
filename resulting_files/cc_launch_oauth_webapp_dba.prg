CREATE PROGRAM cc_launch_oauth_webapp:dba
 PROMPT
  "Output to File/Printer/MINE (Default: MINE): " = "MINE",
  "Cerner Care URL: ",
  "Person Id (Default: 0): " = 0.0,
  "Person Alias Type (Default: blank): " = ""
  WITH outdev, url, pid,
  personaliastype
 DECLARE ccurl = vc
 DECLARE ccpid = f8 WITH noconstant(0.0)
 DECLARE ccpersonaliastype = vc
 SET ccurl =  $URL
 SET ccurl = trim(ccurl)
 SET ccpid =  $PID
 SET ccpersonaliastype =  $PERSONALIASTYPE
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE h = i4 WITH noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE sinvalidprefconfig = vc
 DECLARE snoaliasfound = vc
 DECLARE soauthfailure = vc
 DECLARE sgeneralfailure = vc
 DECLARE si18nloading = vc
 SET sinvalidprefconfig = uar_i18ngetmessage(i18nhandle,"i18n_cc_InvalidPrefConfig",
  "Cerner Care failed to load due to invalid preference configuration.  Please contact your system administrator."
  )
 SET snoaliasfound = uar_i18ngetmessage(i18nhandle,"i18n_cc_NoAlias",
  "Cerner Care failed to load because the alias type was not found.  Please contact your system administrator."
  )
 SET soauthfailure = uar_i18ngetmessage(i18nhandle,"i18n_cc_OAuthFailure",
  "Cerner Care failed to load due to failure retrieving OAuth credentials.  Please contact your system administrator."
  )
 SET sgeneralfailure = uar_i18ngetmessage(i18nhandle,"i18n_cc_GeneralFailure",
  "Unable to establish connection with Cerner Care.  Please contact your system administrator.")
 SET si18nloading = uar_i18ngetmessage(i18nhandle,"i18n_cc_LoadPage","Loading Cerner Care...")
 DECLARE retrievepatientcredentials(null) = vc
 DECLARE displayerrorpage(errortext=vc) = null
 DECLARE shtmlerrorpage = vc
 DECLARE shtmloautherrorpage = vc
 DECLARE sloading = vc
 SET shtmlerrorpage = build("document.write('<html><head></head><body><div>",sgeneralfailure,
  "</div></body></html>')")
 SET shtmloautherrorpage = build("document.write('<html><head></head><body><div>",soauthfailure,
  "</div></body></html>')")
 SET sloading = build("<div>",si18nloading,"</div>")
 IF (ccurl="")
  CALL displayerrorpage(sinvalidprefconfig)
 ENDIF
 IF (ccpid > 0.0)
  DECLARE urlappendedtext = vc
  SET urlappendedtext = retrievepatientcredentials(null)
  SET ccurl = concat(ccurl,urlappendedtext)
 ENDIF
 SET jsopen = build("xmlhttp.open('GET','",ccurl,"');")
 SELECT INTO  $1
  FROM dummyt d
  DETAIL
   row + 1, "<html>", row + 1,
   "<head>", row + 1, "<META content='XMLCCLREQUEST' name = 'discern'>",
   row + 1, "<script type='text/javascript'>", row + 1,
   "window.onerror = function() { ", row + 1,
   CALL print(shtmlerrorpage),
   row + 1, "} ", row + 1,
   "", row + 1, "function getAuthorization() { ",
   row + 1, "	var cclhttp = new XMLCclRequest();", row + 1,
   "	var header; ", row + 1, "	cclhttp.onreadystatechange = function() ",
   row + 1, "	{ ", row + 1,
   "		if (cclhttp.readyState==4) {", row + 1, "			if (cclhttp.responseText) { ",
   row + 1, " 				var json = eval('(' + cclhttp.responseText + ')'); ", row + 1,
   "				var success = 'S'; ", row + 1, "				if (json.OAUTHREPLY.STATUS_DATA.STATUS == success) { ",
   row + 1, "					header = json.OAUTHREPLY.HEADER; ", row + 1,
   "				} ", row + 1, "			} ",
   row + 1, "		}", row + 1,
   "	} ", row + 1, "	cclhttp.open('GET','cc_get_oauth_token',false); ",
   row + 1, "	cclhttp.send('MINE'); ", row + 1,
   "	return header; ", row + 1, "} ",
   row + 1, "", row + 1,
   "function sendHTTPRequest() { ", row + 1, "	var xmlhttp;",
   row + 1, "	if (window.XMLHttpRequest)", row + 1,
   "	{// code for IE7+, Firefox, Chrome, Opera, Safari", row + 1, "	  xmlhttp=new XMLHttpRequest();",
   row + 1, "	  }", row + 1,
   "	else", row + 1, "	  {// code for IE6, IE5",
   row + 1, "		  xmlhttp=new ActiveXObject('Microsoft.XMLHTTP');", row + 1,
   "	  }", row + 1, "	xmlhttp.onreadystatechange = function() ",
   row + 1, "	{ ", row + 1,
   "		if (xmlhttp.readyState==4) {", row + 1, "			if (xmlhttp.status == 200) { ",
   row + 1, " 				var json = eval('(' + xmlhttp.responseText + ')'); ", row + 1,
   "				if (json.url) { ", row + 1, "					window.location = json.url; ",
   row + 1, "				} ", row + 1,
   "				else { ", row + 1,
   CALL print(shtmlerrorpage),
   row + 1, "				} ", row + 1,
   "			} ", row + 1, "			else { ",
   row + 1, "				if (xmlhttp.responseText) { ", row + 1,
   "					document.write(xmlhttp.responseText); ", row + 1, "				} ",
   row + 1, "				else { ", row + 1,
   CALL print(shtmlerrorpage), row + 1, "				} ",
   row + 1, "			} ", row + 1,
   "		}", row + 1, "	} ",
   row + 1,
   CALL print(jsopen), row + 1,
   "	var header = getAuthorization(); ", row + 1, "	if (header) { ",
   row + 1, "		xmlhttp.setRequestHeader('Authorization',header); ", row + 1,
   "		xmlhttp.send(); ", row + 1, "	} ",
   row + 1, "	else { ", row + 1,
   CALL print(shtmloautherrorpage), row + 1, " 	} ",
   row + 1, "} ", row + 1,
   "</script>", row + 1, "</head>",
   row + 1, "<body onload='sendHTTPRequest();'>", row + 1,
   CALL print(sloading), row + 1, "</body>",
   row + 1, "</html>"
  WITH maxcol = 8000, format = variable
 ;end select
 GO TO endofprogram
 SUBROUTINE retrievepatientcredentials(null)
   DECLARE urlappendedtext = vc
   DECLARE alias_code_value = f8 WITH noconstant(0.0)
   DECLARE alias = vc
   IF (ccpersonaliastype != "")
    SET alias_code_value = uar_get_code_by("MEANING",4,trim(ccpersonaliastype))
    IF (alias_code_value <= 0.0)
     CALL displayerrorpage(sinvalidprefconfig)
    ENDIF
    SELECT INTO "nl:"
     FROM person_alias pa
     PLAN (pa
      WHERE pa.person_id=ccpid
       AND pa.person_alias_type_cd=alias_code_value
       AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND pa.active_ind=1)
     ORDER BY pa.person_id
     HEAD pa.person_id
      alias = pa.alias
     WITH nocounter
    ;end select
   ELSE
    CALL displayerrorpage(sinvalidprefconfig)
   ENDIF
   IF (alias="")
    CALL displayerrorpage(snoaliasfound)
   ENDIF
   DECLARE nsize = i4 WITH noconstant(0)
   SET nsize = size(ccurl)
   SET lastchar = substring(nsize,1,ccurl)
   IF (lastchar="/")
    SET urlappendedtext = build("patient/",alias,"/chart")
   ELSE
    SET urlappendedtext = build("/patient/",alias,"/chart")
   ENDIF
   RETURN(urlappendedtext)
 END ;Subroutine
 SUBROUTINE displayerrorpage(errortext)
   DECLARE errorhtmldisplay = vc
   SET errorhtmldisplay = build("<html><head></head><body><div>",errortext,"</div></body></html>")
   SELECT INTO  $1
    FROM dummyt d
    DETAIL
     row + 1,
     CALL print(errorhtmldisplay)
    WITH maxcol = 8000, format = variable
   ;end select
   GO TO endofprogram
 END ;Subroutine
#endofprogram
END GO
