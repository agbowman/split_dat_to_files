CREATE PROGRAM bhs_app_pref_audit
 PROMPT
  "Output to File/Printer/MINE/Email" = "farid.faruqui@bhs.org"
 EXECUTE bhs_sys_stand_subroutine:dba
 IF (findstring("@", $1) > 0)
  SET email_ind = 1
  SET output_dest = build(cnvtlower(curprog),format(cnvtdatetime(curdate,curtime3),
    "YYYYMMDDHHMMSS;;d"))
 ELSE
  SET email_ind = 2
  SET output_dest =  $1
 ENDIF
 DECLARE output_string = vc
 SELECT INTO value(output_dest)
  nvp.pvc_name, nvp.pvc_value, app = substring(1,20,a.description),
  nvp.updt_dt_tm, update_person = substring(1,30,p.name_full_formatted), position =
  uar_get_code_display(ap.position_cd),
  ac.application_dir
  FROM name_value_prefs nvp,
   app_prefs ap,
   prsnl p,
   application a,
   application_context ac
  PLAN (nvp
   WHERE nvp.updt_dt_tm BETWEEN cnvtdatetime((curdate - 60),0) AND cnvtdatetime((curdate - 1),235959)
    AND nvp.parent_entity_name="APP_PREFS")
   JOIN (ap
   WHERE ap.app_prefs_id=outerjoin(nvp.parent_entity_id)
    AND ap.prsnl_id=0)
   JOIN (a
   WHERE a.application_number=ap.application_number)
   JOIN (p
   WHERE p.person_id=nvp.updt_id)
   JOIN (ac
   WHERE ac.applctx=outerjoin(nvp.updt_applctx))
  ORDER BY nvp.updt_dt_tm
  HEAD REPORT
   output_string = build(
    ',"PVC NAME","PVC Value","Application","Update Date","Update Person","Position"',
    ',"Pref Application",'), col 1, output_string,
   row + 1
  DETAIL
   output_string = build(',"',trim(nvp.pvc_name),'","',trim(nvp.pvc_value),'","',
    trim(app),'",',format(nvp.updt_dt_tm,"MM/DD/YYYY HH:MM;;D"),',"',trim(update_person),
    '","',trim(position),'","',trim(ac.application_dir),'",'), col 1, output_string,
   row + 1
  WITH formfeed = none, maxrow = 1, format = variable,
   maxcol = 10000
 ;end select
 IF (email_ind=1)
  SET filename_in = concat(trim(output_dest),".dat")
  SET filename_out = concat(format(cnvtdatetime(curdate,curtime3),"MMDDYYYY;;D"),".csv")
  FREE SET dclcom
  DECLARE dclcom = vc
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  CALL echo(dclcom)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out, $1,trim(curprog),1)
 ENDIF
END GO
