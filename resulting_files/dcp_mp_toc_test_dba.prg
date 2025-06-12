CREATE PROGRAM dcp_mp_toc_test:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person Id:" = "",
  "Personnel Id:" = "",
  "Encounter Id:" = "",
  "Application:" = "",
  "Position Cd:" = "",
  "PPR Cd:" = ""
  WITH outdev, inputpersonid, inputpersonnelid,
  inputencounterid, inputappname, inputpos,
  inputppr
 DECLARE startpage(dummy) = null WITH protect, copy
 DECLARE callpatcon(dummy) = null WITH protect, copy
 DECLARE calldirtydata(dummy) = null WITH protect, copy
 DECLARE endpage(dummy) = null WITH protect, copy
 DECLARE _htmlfilehandle = i4 WITH persistscript, noconstant(0)
 DECLARE _htmlfilestat = i4 WITH persistscript, noconstant(0)
 DECLARE _vcwriteln = vc WITH persistscript, noconstant("")
 DECLARE _sendto = vc WITH persistscript, noconstant( $OUTDEV)
 DECLARE dirtydata = i2 WITH persistscript, noconstant(0)
 DECLARE _personid = f8 WITH persistscript, constant(cnvtreal( $INPUTPERSONID))
 DECLARE _userid = f8 WITH persistscript, constant(cnvtreal( $INPUTPERSONNELID))
 DECLARE _encntrid = f8 WITH persistscript, constant(cnvtreal( $INPUTENCOUNTERID))
 DECLARE _ppr = f8 WITH persistscript, constant(cnvtreal( $INPUTPPR))
 DECLARE _pos = f8 WITH persistscript, constant(cnvtreal( $INPUTPOS))
 DECLARE _appname = vc WITH persistscript, constant( $INPUTAPPNAME)
 DECLARE _time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), protect
 DECLARE _crlf = vc WITH persistscript, constant(build2(char(13),char(10)))
 CALL startpage(0)
 CALL callpatcon(0)
 CALL calldirtydata(0)
 CALL endpage(0)
 SUBROUTINE startpage(dummy)
   SET _htmlfilehandle = uar_fopen(nullterm(_sendto),"w+b")
   SET _vcwriteln = build2('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" ',
    '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',_crlf,
    '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"',
    ' xmlns:v="urn:schemas-microsoft-com:vml">',
    "<head>",_crlf,"<title>","Sample MPage","</title>",
    '<META content="APPLINK,CCLLINK,MPAGES_EVENT,XMLCCLREQUEST" name="discern">',
    '</head><body onLoad="loadPatConDiv()">',_crlf,'</head><body onLoad="loadDirtyDataDiv()">',_crlf)
   SET _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
 END ;Subroutine
 SUBROUTINE callpatcon(dummy)
  SET _vcwriteln = build2("<script type='text/javascript'>",_crlf,"function loadPatConDiv(){",_crlf,
   "	/*Create the PVContxtMPage object*/",
   _crlf,'	var patConObj = window.external.DiscernObjectFactory("PVCONTXTMPAGE");',_crlf,
   "	/*Make the call to the PVContxtMPage*/",_crlf,
   "	var personId = ", $INPUTPERSONID,";",_crlf,
   "	var encString = patConObj.GetValidEncounters(personId);",
   _crlf,'	var encArray = encString.split(",");',_crlf,
   '	var divBody = "<H3>PatCon Results: </H3><br/><table border = 1>";',_crlf,
   '   divBody = divBody + "<tr><Td>Valid Encounters<td><tr>";',_crlf,
   "	for(var i = 0; i < encArray.length; i++){",_crlf,
   '		divBody = divBody + "<tr><td>"+encArray[i]+"<td><tr>";',
   _crlf,"	}",_crlf,'	var divBody = divBody +"</table><br>";',_crlf,
   '	var patConDiv = document.getElementById("patcondiv");',_crlf,"	patConDiv.innerHTML = divBody;",
   _crlf,"}",
   _crlf,"</script>",_crlf)
  SET _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
 END ;Subroutine
 SUBROUTINE calldirtydata(dummy)
  SET _vcwriteln = build2("<script type='text/javascript'>",_crlf,"function loadDirtyDataDiv(){",
   _crlf,'	var divBody = "<H3>Dirty Data: </H3><br>";',
   _crlf,'	var dirtyDataDiv = document.getElementById("dirtydatadiv");',_crlf,
   "	dirtyDataDiv.innerHTML = divBody;",_crlf,
   "}",_crlf,"</script>",_crlf)
  SET _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
 END ;Subroutine
 SUBROUTINE endpage(dummy)
   SET _vcwriteln = build2("<TABLE border=1><CAPTION><H3>Context Variables:</H3></CAPTION><TBODY>",
    "<TR><TH>Variable Name</TH><TR>","<TD>PersonId</TD><TD>",_personid,"</TD></TR><TR>",
    "<TD>EncntrId</TD><TD>",_encntrid,"</TD></TR><TR>","<TD>UserId</TD><TD>",_userid,
    "</TD></TR>","<TD>PositionCd</TD><TD>",_pos,"</TD></TR>","<TD>PPRCd</TD><TD>",
    _ppr,"</TD></TR>","<TR><TD>AppName</TD><TD>",_appname,"</TD></TR>",
    "<TR><TD>Time</TD><TD>",format(_time,"MM/DD/YYYY HH:MM;;D"),"</TD></TR>",
    "<TR><TD>Link to Flowsheet Tab</TD><TD>",
    ^<A href="javascript:APPLINK(0,'powerchart.exe','/PERSONID=^,
    _personid,"/ENCNTRID=",_encntrid,^/FIRSTTAB= Flowsheet')">^,"Link</a></TD></TR></TABLE>",
    "<DIV id='patcondiv'></DIV>","<DIV id='dirtydatadiv'></DIV>","<H3>Dirty Data1: </H3>",
    "<P><INPUT type=checkbox onClick=setDirtyData() name=tab>Dirty Data</P>",
    "<script type='text/javascript'>",
    _crlf,'	var fwObj = window.external.DiscernObjectFactory("PVFRAMEWORKLINK");',_crlf,
    "function setDirtyData(){",_crlf,
    "if(tab.checked == true)",_crlf,"{",_crlf,"	fwObj.SetPendingData(1);",
    _crlf,"}",_crlf,"if(tab.checked == false)",_crlf,
    "{",_crlf,"	fwObj.SetPendingData(0);",_crlf,"}",
    _crlf,"}",_crlf,"</script>",_crlf,
    "</body></html>")
   SET _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
   SET _htmlfilestat = uar_fclose(_htmlfilehandle)
 END ;Subroutine
#exit_script
END GO
