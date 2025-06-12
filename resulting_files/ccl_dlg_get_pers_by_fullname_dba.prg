CREATE PROGRAM ccl_dlg_get_pers_by_fullname:dba
 PROMPT
  "full name " = ""
  WITH fullname
 EXECUTE ccl_prompt_api_dataset "autoset"
 DECLARE ncomma = i2 WITH noconstant(0), protect
 DECLARE nremain = i2 WITH noconstant(0), protect
 DECLARE strfirstname = vc WITH noconstant("*"), protect
 DECLARE strlastname = vc WITH noconstant(""), protect
 SET ncomma = findstring(",", $FULLNAME)
 IF (ncomma > 0)
  SET nremain = ((size( $FULLNAME) - ncomma)+ 1)
  SET strlastname = trim(cnvtupper(substring(1,(ncomma - 1), $FULLNAME)),3)
  SET strfirstname = cnvtupper(trim(substring((ncomma+ 1),nremain, $FULLNAME),3))
  IF (strlastname <= " ")
   SET strlastname = "*"
  ENDIF
 ELSE
  SET strlastname = trim(cnvtupper( $FULLNAME),3)
  SET strfirstname = "*"
 ENDIF
 IF (isvalidationquery(0))
  CALL setvalidation(false)
  SELECT DISTINCT
   p.person_id, p.name_full_formatted, p.name_last,
   p.name_first, p.name_middle, p.birth_dt_tm"@SHORTDATETIME",
   p_sex_disp = uar_get_code_display(p.sex_cd), p_vip_disp = uar_get_code_display(p.vip_cd)
   FROM person p
   WHERE p.name_last_key=patstring(strlastname)
    AND p.name_first_key=patstring(strfirstname)
    AND p.active_ind=1
   ORDER BY p.name_full_formatted, 0
   HEAD REPORT
    stat = makedataset(20)
   DETAIL
    stat = setvalidation(true), stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check, maxrecord = 1,
    maxrow = 1
  ;end select
  IF (recordcount(0)=0)
   CALL setmessageboxex(concat("could not find '", $FULLNAME,"'"),"Find Full Name:",_mb_error_)
  ENDIF
 ELSE
  SELECT DISTINCT
   p.person_id, p.name_full_formatted, p.name_last,
   p.name_first, p.name_middle, p.birth_dt_tm"@SHORTDATETIME",
   p_sex_disp = uar_get_code_display(p.sex_cd), p_vip_disp = uar_get_code_display(p.vip_cd)
   FROM person p
   WHERE p.name_last_key=patstring(strlastname)
    AND p.name_first_key=patstring(strfirstname)
    AND p.active_ind=1
   ORDER BY p.name_full_formatted, 0
   HEAD REPORT
    stat = makedataset(20)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check
  ;end select
 ENDIF
END GO
