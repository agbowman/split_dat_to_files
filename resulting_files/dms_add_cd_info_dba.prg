CREATE PROGRAM dms_add_cd_info:dba
 PROMPT
  "Enter hostname resolution flag 0=resolve the IP address, 1=use the host name: " = "0",
  "Enter user name: " = "",
  "Enter password: " = "",
  "Enter host name: " = ""
 IF (isnumeric(trim( $1))=0)
  CALL echo("Hostname resolution flag must be a 0 or 1.")
  GO TO end_program
 ENDIF
 DECLARE hostflag = i4 WITH noconstant(cnvtint(trim( $1)))
 DECLARE username = vc WITH noconstant(trim( $2))
 DECLARE psswrd = vc WITH noconstant(trim( $3))
 DECLARE hostname = vc WITH noconstant(trim(cnvtupper( $4)))
 DECLARE rimage_host_enabled = vc WITH constant("RIMAGE_HOST_ENABLED")
 DECLARE rimage_user = vc WITH constant("RIMAGE_USER")
 DECLARE rimage_password = vc WITH constant("RIMAGE_PASSWORD")
 DECLARE newpsswrd = vc WITH noconstant("")
 IF (size(hostname,3)=0)
  CALL echo("Host name required.")
  GO TO end_program
 ENDIF
 IF (((hostflag=0) OR (hostflag=1)) )
  DELETE  FROM dm_info dm
   WHERE dm.info_domain=rimage_host_enabled
    AND dm.info_name=hostname
   WITH nocounter
  ;end delete
  INSERT  FROM dm_info dm
   SET dm.info_domain = rimage_host_enabled, dm.info_name = hostname, dm.info_number = hostflag
   WITH nocounter
  ;end insert
 ELSE
  CALL echo("Hostname Resolution Flag must be a 0 or 1.")
  GO TO end_program
 ENDIF
 IF (size(username,3) > 0)
  DELETE  FROM dm_info dm
   WHERE dm.info_domain=rimage_user
    AND dm.info_name=hostname
   WITH nocounter
  ;end delete
  INSERT  FROM dm_info dm
   SET dm.info_domain = rimage_user, dm.info_name = hostname, dm.info_char = username
   WITH nocounter
  ;end insert
 ENDIF
 IF (size(psswrd,3) > 0)
  DELETE  FROM dm_info dm
   WHERE dm.info_domain=rimage_password
    AND dm.info_name=hostname
   WITH nocounter
  ;end delete
  DECLARE i = i4 WITH noconstant(0)
  FOR (i = 1 TO size(psswrd,3))
    SET curchar = substring(i,1,psswrd)
    SET num = bxor(ichar(curchar),1)
    SET newchar = char(num)
    IF (i=1)
     SET newpsswrd = notrim(newchar)
    ELSE
     SET newpsswrd = notrim(build2(newpsswrd,newchar))
    ENDIF
  ENDFOR
  INSERT  FROM dm_info dm
   SET dm.info_domain = rimage_password, dm.info_name = hostname, dm.info_char = newpsswrd
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
#end_program
END GO
