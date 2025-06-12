CREATE PROGRAM afc_add_cv_site_prefs:dba
 DECLARE versionnbr = vc
 SET versionnbr = "009"
 CALL echo(build("AFC_ADD_CV_SITE_PREFS Version: ",versionnbr))
 CALL clear(1,1)
 RECORD dm_info_req(
   1 site_pref_qual = i2
   1 site_pref[*]
     2 info_name = vc
     2 info_date = dq8
     2 info_char = vc
     2 info_number = f8
     2 info_long_id = f8
     2 updt_applctx = f8
     2 updt_task = f8
 )
 DECLARE prefcnt = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE addpreference(prefname=vc,prefvalue=vc) = null
 DECLARE addnumberpreference(prefname=vc,prefnumber=i4) = null
 DECLARE addlongidpreference(prefname=vc,preflongid=f8.0) = null
 SET message = noinformation
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 CALL text(4,4,uar_i18ngetmessage(i18nhandle,"k1",
   "Do you want a 'Reason' prompt when you choose to credit or modify a charge in CSChargeViewer?"))
 CALL accept(4,116,"A;cu","Y"
  WHERE curaccept IN ("N", "Y"))
 CALL addpreference("ADJUST/MODIFY REASON PROMPT",curaccept)
 IF (curaccept="Y")
  CALL text(5,4,uar_i18ngetmessage(i18nhandle,"k1",
    "Do you want the 'Reason Code' to be required when you credit or modify a charge in CSChargeViewer?"
    ))
  CALL accept(5,116,"A;cu","Y"
   WHERE curaccept IN ("N", "Y"))
  CALL addpreference("CREDIT/ADJUST/MODIFY REASON CODE REQUIRED",curaccept)
  CALL text(6,4,uar_i18ngetmessage(i18nhandle,"k1",
    "Do you want the 'Reason Note' to be required when you credit or modify a charge in CSChargeViewer?"
    ))
  CALL accept(6,116,"A;cu","Y"
   WHERE curaccept IN ("N", "Y"))
  CALL addpreference("CREDIT/ADJUST/MODIFY NOTE REQUIRED",curaccept)
 ENDIF
 CALL text(7,4,uar_i18ngetmessage(i18nhandle,"k1",
   "Check ABN when modifying or manually adding charges?"))
 CALL accept(7,116,"A;cu","Y"
  WHERE curaccept IN ("N", "Y"))
 CALL addpreference("USE ABN",curaccept)
 CALL text(8,4,uar_i18ngetmessage(i18nhandle,"k1",
   "Do you want to force the price to be greater than 0.00 when a manual charge is released?"))
 CALL accept(8,116,"A;cu","Y"
  WHERE curaccept IN ("N", "Y"))
 CALL addpreference("USE MANUAL RELEASE PREFERENCE - PRICE",curaccept)
 CALL text(9,4,uar_i18ngetmessage(i18nhandle,"k1",
   "Do you want to ensure the charge has a CDM when a manual charge is released?"))
 CALL accept(9,116,"A;cu","Y"
  WHERE curaccept IN ("N", "Y"))
 CALL addpreference("USE MANUAL RELEASE PREFERENCE - CDM",curaccept)
 CALL text(10,4,uar_i18ngetmessage(i18nhandle,"k1",
   "Do you want to ensure a credit is not created when you toggle the process flag from Interface to pending? Y/N/P"
   ))
 CALL accept(10,116,"A;cu","Y"
  WHERE curaccept IN ("N", "Y", "P"))
 CALL addpreference("CHARGE VIEWER TOGGLE PREFERENCE",curaccept)
 CALL text(11,4,uar_i18ngetmessage(i18nhandle,"k1",
   "Do you want to allow service date to be greater than the current date?"))
 CALL accept(11,116,"A;cu","Y"
  WHERE curaccept IN ("N", "Y"))
 CALL addpreference("CHARGE VIEWER FUTURE SERVICE DATE ALLOWED",curaccept)
 CALL text(12,4,uar_i18ngetmessage(i18nhandle,"k1",
   "What is the maximum number of charges allowed to display in charge viewer?"))
 CALL accept(12,116,"9(11);pd",0
  WHERE curaccept >= 0)
 CALL addnumberpreference("CAP FOR CHARGE VIEWER",curaccept)
 CALL text(13,4,uar_i18ngetmessage(i18nhandle,"k1",
   "Select ICD Principal Procedure(<shift f5> for help):"))
 SET help =
 SELECT
  code_value = cv.code_value"##########;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=400
   AND cv.active_ind=1
   AND cv.cdf_meaning="*ICD*"
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(13,116,"9(10);C",0.0)
 CALL addlongidpreference("ICD PRINCIPAL PROCEDURE TYPE",cnvtreal(curaccept))
 CALL text(14,4,uar_i18ngetmessage(i18nhandle,"k1",
   "Select ICD Principal Diagnosis(<shift f5> for help):"))
 SET help =
 SELECT
  code_value = cv.code_value"##########;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=400
   AND cv.active_ind=1
   AND cv.cdf_meaning="*ICD*"
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(14,116,"9(10);C",0.0)
 CALL addlongidpreference("ICD PRINCIPAL DIAGNOSIS TYPE",cnvtreal(curaccept))
 CALL text(15,4,uar_i18ngetmessage(i18nhandle,"k1",
   "Select Secondary ICD Procedure(<shift f5> for help):"))
 SET help =
 SELECT
  code_value = cv.code_value"##########;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=400
   AND cv.active_ind=1
   AND cv.cdf_meaning="*ICD*"
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(15,116,"9(10);C",0.0)
 CALL addlongidpreference("SECONDARY ICD PRINCIPAL PROCEDURE TYPE",cnvtreal(curaccept))
 CALL text(16,4,uar_i18ngetmessage(i18nhandle,"k1",
   "Select Secondary ICD Diagnosis(<shift f5> for help):"))
 SET help =
 SELECT
  code_value = cv.code_value"##########;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=400
   AND cv.active_ind=1
   AND cv.cdf_meaning="*ICD*"
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(16,116,"9(10);C",0.0)
 CALL addlongidpreference("SECONDARY ICD PRINCIPAL DIAGNOSIS TYPE",cnvtreal(curaccept))
 IF ((dm_info_req->site_pref_qual > 0))
  EXECUTE afc_add_upt_site_prefs  WITH replace("REQUEST",dm_info_req)
  COMMIT
  CALL clear(1,1)
  CALL video(w)
  CALL text(4,4,"****************************",wide)
  CALL text(5,4,uar_i18ngetmessage(i18nhandle,"k1","CHANGES HAVE BEEN COMMITTED!"),wide)
  CALL text(6,4,"****************************",wide)
  CALL text(7,4,"")
  CALL video(n)
 ENDIF
 SUBROUTINE addpreference(prefname,prefvalue)
   SET prefcnt = (prefcnt+ 1)
   SET dm_info_req->site_pref_qual = prefcnt
   SET stat = alterlist(dm_info_req->site_pref,prefcnt)
   SET dm_info_req->site_pref[prefcnt].info_name = prefname
   SET dm_info_req->site_pref[prefcnt].info_char = prefvalue
 END ;Subroutine
 SUBROUTINE addnumberpreference(prefname,prefnumber)
   SET prefcnt = (prefcnt+ 1)
   SET dm_info_req->site_pref_qual = prefcnt
   SET stat = alterlist(dm_info_req->site_pref,prefcnt)
   SET dm_info_req->site_pref[prefcnt].info_name = prefname
   SET dm_info_req->site_pref[prefcnt].info_number = prefnumber
 END ;Subroutine
 SUBROUTINE addlongidpreference(prefname,preflongid)
   SET prefcnt = (prefcnt+ 1)
   SET dm_info_req->site_pref_qual = prefcnt
   SET stat = alterlist(dm_info_req->site_pref,prefcnt)
   SET dm_info_req->site_pref[prefcnt].info_name = prefname
   SET dm_info_req->site_pref[prefcnt].info_long_id = preflongid
 END ;Subroutine
END GO
