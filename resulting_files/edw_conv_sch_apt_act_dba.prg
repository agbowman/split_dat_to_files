CREATE PROGRAM edw_conv_sch_apt_act:dba
 UPDATE  FROM dm_info di
  SET info_char = concat(substring(1,(findstring("|",di.info_char,1) - 1),di.info_char),
    "|Should the Non-Patient Appointment Information excluded from extraction for SCH_APPT and S_APT_DT (Y/N)?"
    )
  WHERE info_domain="PI EDW DATA CONFIGURATION|SA_SCH_APPT_IND"
   AND info_name="SA_SCH_APPT_IND|BOOLEAN"
  WITH nocounter
 ;end update
 SET script_version = "000 05/16/13 CK026450"
 COMMIT
END GO
