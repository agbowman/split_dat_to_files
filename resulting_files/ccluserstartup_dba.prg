CREATE PROGRAM ccluserstartup:dba
 SET fulluname = "v500"
 SET fullpword = "v500"
 SET readuname = "v500_read"
 SET readpword = "v500_read"
 IF (curbatch=0)
  EXECUTE cclseclogin
 ELSE
  GO TO exit_script
 ENDIF
 SET xloginck = validate(xxcclseclogin->loggedin,99)
 IF (xloginck != 1)
  CALL video(rbi)
  CALL clear(1,1)
  CALL text(3,1,"user not logged in aborting automated database connection...")
  CALL text(4,1,"")
  SET message = nowindow
  GO TO exit_script
 ELSE
  SET message = nowindow
 ENDIF
 IF (currdbuser != null)
  CALL echo("dropping existing connection to database")
  FREE DEFINE oraclesystem
 ENDIF
 SET dbnode = cnvtupper(trim( $1,3))
 SET passedstring = trim( $2,3)
 IF (substring(1,1,passedstring) != "@")
  SET connectstring = concat("@",passedstring)
 ELSE
  SET connectstring = passedstring
 ENDIF
 SET inst = substring(2,(textlen(connectstring) - 1),connectstring)
 IF (validate(accessmode,"NULL")="Full")
  CALL echo("                         access: read/write")
  SET uname = fulluname
  SET pword = fullpword
 ELSE
  CALL echo("                         access: read only")
  SET uname = readuname
  SET pword = readpword
 ENDIF
 DECLARE uar_get_nodename(p1,p2) = c16
 SET node = fillstring(16," ")
 SET x = 0
 CALL uar_get_nodename(node,x)
 CALL echo(concat("                Current Node is: ",node))
 CALL echo(concat("            Current Platform is: ",cursys))
 CALL echo(concat("            Current Database is: ",inst))
 IF (cnvtupper(node)=dbnode)
  CALL echo("   Current connection method is: LOCAL")
  SET lgnstr = concat(uname,"/",pword)
 ELSE
  CALL echo(concat("   Current connection method is: REMOTE  (via  ",connectstring,")"))
  SET lgnstr = concat(uname,"/",pword,connectstring)
 ENDIF
 DEFINE oraclesystem value(lgnstr)
 IF (currdbuser=null)
  CALL echo("Automated connection to database was unsucessful")
  EXECUTE ccloralogin
 ENDIF
#exit_script
END GO
