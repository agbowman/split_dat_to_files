CREATE PROGRAM bhs_eks_lab_test_iso_ords:dba
 RECORD m_rec(
   1 l_lcnt = i4
   1 llst[*]
     2 f_order_id = f8
     2 f_catalog_cd = f8
     2 s_mnemonic = vc
   1 l_icnt = i4
   1 ilst[*]
     2 f_order_id = f8
     2 f_catalog_cd = f8
     2 s_mnemonic = vc
     2 i_dcnt = i4
     2 dlst[*]
       3 s_isolationcode = vc
 )
 DECLARE mf_afbculturewafbsmearrespiratory = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   200,"AFBCULTUREWAFBSMEARRESPIRATORY"))
 DECLARE mf_afbculturewafbsmearrespiratory = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   200,"AFBCULTUREWAFBSMEARRESPIRATORY"))
 DECLARE mf_cdifficilerapidtoxinassay = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CDIFFICILERAPIDTOXINASSAY"))
 DECLARE mf_measlesrubeolaigm = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "MEASLESRUBEOLAIGM"))
 DECLARE mf_meningencephcsfpcrpanel = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "MENINGENCEPHCSFPCRPANEL"))
 DECLARE mf_mumpsigm = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MUMPSIGM"))
 DECLARE mf_respiratorypathogenpanelbypcr = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   200,"RESPIRATORYPATHOGENPANELBYPCR"))
 DECLARE mf_rubellagermanmeaslesigm = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RUBELLAGERMANMEASLESIGM"))
 DECLARE mf_varicellapcrnonblood = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "VARICELLAPCRNONBLOOD"))
 DECLARE mf_varicellazosterigmab = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "VARICELLAZOSTERIGMAB"))
 DECLARE mf_isolation = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ISOLATION"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_oidx = i4 WITH protect, noconstant(0)
 DECLARE ml_ndx = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_iso_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_iso_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_inc_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_droplet_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_contact_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_airborne_ind = i4 WITH protect, noconstant(0)
 DECLARE mf_inc_order_id = f8 WITH protect, noconstant(0.00)
 DECLARE mf_inc_cat_cd = f8 WITH protect, noconstant(0.00)
 DECLARE request_text = vc WITH protect, noconstant(" ")
 DECLARE eksdata_text = vc WITH protect, noconstant(" ")
 SET retval = 0
 SET log_message = concat("Script started.")
 SET request_text = cnvtrectojson(request)
 SET eksdata_text = cnvtrectojson(eksdata)
 FOR (ml_loop = 1 TO size(request->orderlist))
   IF ((request->orderlist[ml_loop].catalog_code IN (mf_respiratorypathogenpanelbypcr,
   mf_meningencephcsfpcrpanel, mf_cdifficilerapidtoxinassay, mf_mumpsigm, mf_rubellagermanmeaslesigm,
   mf_measlesrubeolaigm, mf_varicellapcrnonblood, mf_varicellazosterigmab,
   mf_afbculturewafbsmearrespiratory)))
    SET mf_inc_cat_cd = request->orderlist[ml_loop].catalog_code
   ENDIF
 ENDFOR
 SET log_message = concat("An incomming Lab Order found: ",build(uar_get_code_display(mf_inc_cat_cd))
  )
 SET ml_ndx = 0
 SET ml_iso_loc = locateval(ml_ndx,1,size(request->orderlist,5),mf_isolation,request->orderlist[
  ml_ndx].catalog_code)
 IF (ml_iso_loc > 0)
  SET ml_iso_ind = 1
  SET log_message = trim(concat(log_message,"  An incomming Isolation Order found."),3)
 ELSE
  SET retval = 0
  SET log_message = trim(concat(log_message,"  No incomming Isolation Order found."),3)
  GO TO exit_script
 ENDIF
 FOR (ml_loop = 1 TO size(request->orderlist[ml_iso_loc].detaillist,5))
   IF ((request->orderlist[ml_iso_loc].detaillist[ml_loop].oefieldmeaning="ISOLATIONCODE"))
    CASE (request->orderlist[ml_iso_loc].detaillist[ml_loop].oefielddisplayvalue)
     OF "Contact":
      SET ml_contact_ind = 1
     OF "Droplet":
      SET ml_droplet_ind = 1
     OF "Airborne":
      SET ml_airborne_ind = 1
    ENDCASE
   ENDIF
 ENDFOR
 SET log_message = concat(log_message," - ml_droplet_ind: ",build(ml_droplet_ind))
 IF (mf_inc_cat_cd IN (mf_respiratorypathogenpanelbypcr))
  IF (ml_contact_ind=1
   AND ml_droplet_ind=1)
   SET retval = 100
   SET log_message = concat("Incoming lab order ",trim(uar_get_code_display(mf_inc_cat_cd),3),
    " requires contact and droplet isolation codes.",
    "  An incoming Isolation order with the appropriate isolation codes has been found.")
  ELSE
   SET retval = 0
   SET log_message = concat("Incoming lab order ",trim(uar_get_code_display(mf_inc_cat_cd),3),
    " requires contact and droplet isolation codes.",
    "  An incoming Isolation order with the appropriate isolation code was not found.")
  ENDIF
 ENDIF
 IF (mf_inc_cat_cd IN (mf_meningencephcsfpcrpanel, mf_mumpsigm, mf_rubellagermanmeaslesigm))
  IF (ml_droplet_ind=1)
   SET retval = 100
   SET log_message = concat("Incoming lab order ",trim(uar_get_code_display(mf_inc_cat_cd),3),
    " requires droplet isolation code.",
    "  An incoming Isolation order with the appropriate isolation code has been found.")
  ELSE
   SET retval = 0
   SET log_message = concat("Incoming lab order ",trim(uar_get_code_display(mf_inc_cat_cd),3),
    " requires droplet isolation code.",
    "  An incoming Isolation order with the appropriate isolation code was not found.")
  ENDIF
 ENDIF
 IF (mf_inc_cat_cd IN (mf_measlesrubeolaigm, mf_varicellapcrnonblood, mf_varicellazosterigmab))
  IF (ml_contact_ind=1
   AND ml_airborne_ind=1)
   SET retval = 100
   SET log_message = concat("Incoming lab order ",trim(uar_get_code_display(mf_inc_cat_cd),3),
    " requires contact and airborne isolation codes.",
    "An incoming Isolation order with the appropriate isolation codes has been found.")
  ELSE
   SET retval = 0
   SET log_message = concat("Incoming lab order ",trim(uar_get_code_display(mf_inc_cat_cd),3),
    " requires contact and airborne isolation codes.",
    "An incoming Isolation order with the appropriate isolation code was not found.")
  ENDIF
 ENDIF
 IF (mf_inc_cat_cd IN (mf_afbculturewafbsmearrespiratory))
  IF (ml_airborne_ind=1)
   SET retval = 100
   SET log_message = concat("Incoming lab order ",trim(uar_get_code_display(mf_inc_cat_cd),3),
    " requires airborne isolation code.",
    "An incoming Isolation order with the appropriate isolation code has been found.")
  ELSE
   SET retval = 0
   SET log_message = concat("Incoming lab order ",trim(uar_get_code_display(mf_inc_cat_cd),3),
    " requires airborne isolation code.",
    "An incoming Isolation order with the appropriate isolation code was not found.")
  ENDIF
 ENDIF
 IF (mf_inc_cat_cd IN (mf_cdifficilerapidtoxinassay))
  IF (ml_contact_ind=1)
   SET retval = 100
   SET log_message = concat("Incoming lab order ",trim(uar_get_code_display(mf_inc_cat_cd),3),
    " requires contact isolation code.",
    "An incoming Isolation order with the appropriate isolation code has been found.")
  ELSE
   SET retval = 0
   SET log_message = concat("Incoming lab order ",trim(uar_get_code_display(mf_inc_cat_cd),3),
    " requires contact isolation code.",
    "An incoming Isolation order with the appropriate isolation code was not found.")
  ENDIF
 ENDIF
#exit_script
 CALL echo(log_message)
END GO
