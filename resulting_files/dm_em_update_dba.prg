CREATE PROGRAM dm_em_update:dba
 FREE SET g_audit_only
 FREE SET i_report_ind
 FREE SET i_update_ind
 FREE SET i_debug_ind
 DECLARE g_audit_only = i4
 DECLARE i_report_ind = i4
 DECLARE i_update_ind = i4
 DECLARE i_debug_ind = i4
 SET g_audit_only = 0
 SET i_report_ind = 1
 SET i_update_ind = 1
 SET i_debug_ind = 0
 EXECUTE dm_em_upd_rpt
END GO
