CREATE PROGRAM bhs_rpt_uptodate_search:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Search String:" = ""
  WITH outdev, search
 DECLARE link = vc WITH noconstant(" ")
 DECLARE list = vc WITH noconstant(" ")
 DECLARE searchstring = vc WITH noconstant(" ")
 SET searchstring = trim(replace(cnvtlower( $SEARCH),"abcdefghijklmnopqrstuvwxyz ",
   "abcdefghijklmnopqrstuvwxyz ",3),3)
 SET searchstring = replace(searchstring,"  "," ")
 SET searchstring = trim(replace(searchstring," ","+"),3)
 IF (validate(reqinfo->updt_id) > 0
  AND (reqinfo->updt_id > 0))
  SET realuserid = reqinfo->updt_id
 ELSE
  SET realuserid = curuser
 ENDIF
 DECLARE strusername = vc WITH noconstant(" ")
 DECLARE strusername = vc
 SELECT INTO "NL:"
  FROM prsnl p
  WHERE p.person_id=realuserid
  DETAIL
   strusername = trim(p.username,3),
   CALL echo(strusername)
  WITH time = 5
 ;end select
 SELECT INTO  $OUTDEV
  FROM dummyt d
  DETAIL
   link = '"http://bhsprodapps/UpToDate/goto_UpToDate.aspx?unid=', link = concat(link,trim(
     strusername)), link = concat(link,"&srcsys=CERNBHS_MA&eiv=2.1.0&search=",searchstring,'"'),
   list = concat("<a href='javascript: CCLNEWSESSIONWINDOW(",link,',"_parent",'), list = concat(list,
    ^"height=200,width=200",1,0)' >Loading UpToDate</a>^), row + 1,
   CALL print("<html><head>"), row + 1,
   CALL print("<META content='CCLNEWSESSIONWINDOW' name='discern'></head>"),
   row + 1,
   CALL print(list), row + 1,
   CALL print('<script type="text/javascript">'), row + 1,
   CALL print(concat("window.location = ",link)),
   row + 1,
   CALL print("</script>"), row + 1,
   CALL print("<BODY>"), row + 1,
   CALL print("</BODY></html>")
  WITH nocounter, separator = " ", format,
   maxcol = 1000
 ;end select
END GO
