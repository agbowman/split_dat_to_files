CREATE PROGRAM dm_ocd_get_admin:dba
 SET reply->status_data.status = "F"
 SET errcode = 0
 SET errmsg = fillstring(132," ")
 FREE RECORD admin
 RECORD admin(
   1 db_link = vc
   1 connect_str = vc
 )
 SET dm_sys = fillstring(5," ")
 SELECT INTO "nl:"
  x = cursys
  FROM dual
  DETAIL
   dm_sys = trim(cnvtupper(x))
  WITH nocounter
 ;end select
 IF (dm_sys="AXP")
  SET fname = "dm_ocd_get_admin.com"
 ELSEIF (dm_sys="AIX")
  SET fname = "dm_ocd_get_admin.ksh"
 ENDIF
 SET dm_env_id = 0.0
 SELECT INTO "nl:"
  i.info_number
  FROM dm_info i
  WHERE i.info_domain="DATA MANAGEMENT"
   AND i.info_name="DM_ENV_ID"
  DETAIL
   dm_env_id = i.info_number
  WITH nocounter
 ;end select
 IF (dm_env_id=0.0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = "INVALID OR NONEXISTENT ENVIRONMENT_ID IN DM_INFO"
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM all_synonyms a
  WHERE table_name="DM_ENVIRONMENT"
  DETAIL
   admin->db_link = cnvtlower(substring(1,(findstring(".",a.db_link) - 1),a.db_link))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (dm_sys="AIX")
   SELECT INTO value(fname)
    i.info_name
    FROM dm_info i,
     dm_environment e
    WHERE i.info_name="DM_ENV_ID"
     AND i.info_domain="DATA MANAGEMENT"
     AND i.info_number=e.environment_id
    DETAIL
     col 0, "#!/usr/bin/ksh", row + 1,
     col 0, ". $cer_mgr/.user_setup ", e.envset_string,
     row + 1, col 0, "ccl <<!",
     row + 1, col 0, "execute dm_ocd_check_admin_int 'cdba', '",
     admin->db_link, "','cdba' go"
    WITH nocounter, formfeed = none, maxrow = 1,
     maxcol = 512, format = variable
   ;end select
  ELSE
   SELECT INTO value(fname)
    d.seq
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 0, "$!", row + 1,
     col 0, "$set verify", row + 1,
     col 0, '$CCL :== "$CER_EXE:CCLORA.EXE"', row + 1,
     col 0, "$CCL", row + 1,
     col 0, "execute dm_ocd_check_admin_int 'cdba', 'cdba', '", admin->db_link,
     "' go"
    WITH nocounter, formfeed = none, format = variable,
     maxrow = 1, maxcol = 200
   ;end select
  ENDIF
  SET dclcom = fillstring(100," ")
  IF (dm_sys="AIX")
   SET dclcom = "rm -f $CCLUSERDIR/dm_ocd_chk_adm.dat"
   SET len = size(trim(dclcom))
   SET status = 0
   CALL dcl(dclcom,len,status)
   IF (status=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Couldn't remove old version of dm_ocd_chk_adm.dat"
   ENDIF
   SET dclcom = "chmod 755 $CCLUSERDIR/dm_ocd_get_admin.ksh"
   SET len = size(trim(dclcom))
   SET status = 0
   CALL dcl(dclcom,len,status)
   IF (status=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Couldn't chmod dm_ocd_get_admin.ksh"
   ENDIF
   SET dclcom = "./dm_ocd_get_admin.ksh"
   SET len = size(trim(dclcom))
   SET status = 0
   CALL dcl(dclcom,len,status)
  ELSE
   SET dclcom = "delete CCLUSERDIR:dm_ocd_chk_adm.dat;*"
   SET len = size(trim(dclcom))
   SET status = 0
   CALL dcl(dclcom,len,status)
   IF (status=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Couldn't remove old version of dm_ocd_chk_adm.dat"
   ENDIF
   SET dclcom = "@dm_ocd_get_admin.com"
   SET len = size(trim(dclcom))
   SET status = 0
   CALL dcl(dclcom,len,status)
   IF (status=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Couldn't execute dm_ocd_get_admin.com"
   ENDIF
  ENDIF
  FREE DEFINE rtl
  DEFINE rtl "dm_ocd_chk_adm.dat"
  SET errcode = error(errmsg,0)
  IF (errcode != 0)
   SET reply->status_data.status = "Z"
   SET reply->ops_event = "Could not open dm_ocd_chk_adm.dat"
   GO TO end_program
  ENDIF
  SELECT INTO "nl:"
   r.line
   FROM rtlt r
   WHERE r.line="success"
   WITH nocounter
  ;end select
  IF (curqual=1)
   SET reply->status_data.status = "S"
   SET reply->ops_event = " "
  ELSE
   SET reply->status_data.status = "Z"
   SET errstr = build("Unable to connect to admin using: ", $1,"/",request->output_dist,"@",
     $2)
   SET reply->ops_event = errstr
  ENDIF
 ELSE
  SET reply->status_data.status = "D"
 ENDIF
#end_program
END GO
