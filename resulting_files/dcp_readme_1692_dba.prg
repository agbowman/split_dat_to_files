CREATE PROGRAM dcp_readme_1692:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET appcnt = 0
 RECORD apps(
   1 qual[*]
     2 clsid = vc
     2 appnumber = vc
 )
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   application a
  PLAN (nvp
   WHERE ((nvp.pvc_name="ORG_CustomToolProgId") OR (nvp.pvc_name="CHART_CustomToolProgId")) )
   JOIN (a
   WHERE cnvtcap(trim(a.object_name))=cnvtcap(trim(nvp.pvc_value)))
  ORDER BY a.application_number
  HEAD a.application_number
   appcnt = (appcnt+ 1), stat = alterlist(apps->qual,appcnt), apps->qual[appcnt].clsid = cnvtcap(trim
    (a.object_name)),
   apps->qual[appcnt].appnumber = cnvtstring(a.application_number)
  DETAIL
   CALL echo(nvp.pvc_value)
  WITH nocounter
 ;end select
 FOR (i = 1 TO appcnt)
  UPDATE  FROM name_value_prefs nvp
   SET nvp.pvc_name = "ORG_CernerApplicationButton", nvp.pvc_value = apps->qual[i].appnumber
   WHERE nvp.pvc_name="ORG_CustomToolProgId"
    AND (cnvtcap(trim(nvp.pvc_value))=apps->qual[i].clsid)
   WITH nocounter
  ;end update
  UPDATE  FROM name_value_prefs nvp
   SET nvp.pvc_name = "CHART_CernerApplicationButton", nvp.pvc_value = apps->qual[i].appnumber
   WHERE nvp.pvc_name="CHART_CustomToolProgId"
    AND (cnvtcap(trim(nvp.pvc_value))=apps->qual[i].clsid)
   WITH nocounter
  ;end update
 ENDFOR
 DELETE  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="ORG_CustomToolDisplay"
  WITH nocounter
 ;end delete
 DELETE  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="ORG_CustomToolBitmap"
  WITH nocounter
 ;end delete
 DELETE  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="CHART_CustomToolDisplay"
  WITH nocounter
 ;end delete
 DELETE  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="CHART_CustomToolBitmap"
  WITH nocounter
 ;end delete
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
END GO
