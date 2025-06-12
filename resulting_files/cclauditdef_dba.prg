CREATE PROGRAM cclauditdef:dba
 IF (validate(cclaudit_def,999)=999)
  CALL echo("Declaring cclaudit_def")
  DECLARE cclaudit_def = i2 WITH persist, constant(1)
  DECLARE uar_srv_isauditable(p1=vc(ref),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvaudit",
  image_aix = "libsrvaudit.a(libsrvaudit.o)", uar = "SRV_IsAuditable",
  persist
  DECLARE uar_srv_createauditset(p1=i4(value)) = i4 WITH image_axp = "srvaudit", image_aix =
  "libsrvaudit.a(libsrvaudit.o)", uar = "SRV_CreateAuditSet",
  persist
  DECLARE uar_srv_audit(p1=i4(value)) = i4 WITH image_axp = "srvaudit", image_aix =
  "libsrvaudit.a(libsrvaudit.o)", uar = "SRV_Audit",
  persist
  RECORD cclaud(
    1 requests[11]
      2 cache = vc
    1 enable = i1
    1 stat = i4
    1 happ = i4
    1 hevent = i4
    1 hpar = i4
    1 isaudit = i4
    1 hipaamode = i4
    1 datetime
      2 event_dt_tm = dq8
    1 misc = vc
    1 debugmode = i1
  ) WITH persist
 ENDIF
 SET cclaud->enable = 0
 IF (checkprg("CCLAUDITCACHE")
  AND logical("CCL_HIPAA") != "OFF")
  SET cclaud->enable = 1
  EXECUTE cclauditcache
 ENDIF
END GO
