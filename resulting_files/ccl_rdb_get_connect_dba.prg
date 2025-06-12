CREATE PROGRAM ccl_rdb_get_connect:dba
 PROMPT
  "Enter Oracle userid: " = "v500",
  "Enable debugging (0)= " = 0,
  "Enter RDBMS mode (RAC)= " = ""
 DECLARE _rdb_user = vc
 DECLARE _rdb_link = vc
 DECLARE _rdb_linklen = i4 WITH noconstant(- (1))
 DECLARE _rdb_connect = c80
 DECLARE _rdb_connectlen = i4 WITH constant(80)
 DECLARE _rdb_sid = vc
 DECLARE _rdb_mode = vc WITH noconstant(" ")
 DECLARE _uar_stat = i4
 DECLARE _debug = i2
 DECLARE uar_buildrdbmsuid(p1=vc(ref),p2=i4(value),p3=vc(ref),p4=i4(value),p5=vc(ref),
  p6=i4(value)) = i4 WITH persist
 IF (validate(rdbmslocal_connect,"N")="N")
  DECLARE rdbmslocal_connect = vc WITH persist
 ENDIF
 IF (textlen( $1)=0)
  SET _rdb_user = trim(currdbuser)
 ELSE
  SET _rdb_user =  $1
 ENDIF
 SET _rdb_link = trim(currdblink)
 IF (textlen(_rdb_link) > 0)
  SET _rdb_link = concat("@",trim(currdblink))
 ELSE
  IF (cursys="AIX")
   SET _rdb_sid = trim(logical("ORACLE_SID"))
  ELSEIF (cursys="AXP")
   SET _rdb_sid = trim(logical("ORA_SID"))
  ELSEIF (cursys="WIN")
   CALL echo("Win32 platform not supported..")
  ENDIF
  IF (textlen(_rdb_sid) > 0)
   SET _rdb_link = concat("@",_rdb_sid)
  ENDIF
 ENDIF
 SET _rdb_linklen = textlen(_rdb_link)
 SET _debug =  $2
 IF (textlen(trim( $3)) > 0)
  SET _rdb_link = trim(cnvtupper( $3))
  CALL echo(build("Setting _RDB_Link= ",_rdb_link))
 ENDIF
 IF (_debug=1)
  CALL echo(concat("Call uar_buildrdbmsuid for RDB User= ",_rdb_user,", Link= ",_rdb_link))
 ENDIF
 SET _uar_stat = uar_buildrdbmsuid(_rdb_connect,value(_rdb_connectlen),nullterm(_rdb_user),textlen(
   _rdb_user),nullterm(_rdb_link),
  _rdb_linklen)
 IF (_uar_stat=1)
  SET rdbmslocal_connect = trim(_rdb_connect)
 ELSE
  CALL echo(concat("Error in uar_buildrdbmsuid, status= ",build(_uar_stat)))
 ENDIF
 IF (_debug=1)
  CALL echo(concat("RDBMSLOCAL_CONNECT= ",rdbmslocal_connect))
 ENDIF
END GO
