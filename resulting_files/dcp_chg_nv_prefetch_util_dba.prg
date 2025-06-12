CREATE PROGRAM dcp_chg_nv_prefetch_util:dba
 UPDATE  FROM name_value_prefs
  SET pvc_name = "DEMOGWND", pvc_value = "1"
  WHERE pvc_name="PREFETCH"
  WITH nocounter
 ;end update
END GO
