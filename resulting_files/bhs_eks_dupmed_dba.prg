CREATE PROGRAM bhs_eks_dupmed:dba
 PROMPT
  "Rule Name" = ""
  WITH rule_name
 DECLARE mf_primary_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6011,"PRIMARY")), protect
 DECLARE mf_pharmacy_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")), protect
 DECLARE mn_num = i4
 DECLARE mn_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_cnt1 = i4 WITH protect, noconstant(0)
 DECLARE mf_ord_id = f8
 SET retval = 0
 DECLARE ms_tmp1 = vc WITH protect, noconstant(" ")
 FREE RECORD med
 RECORD med(
   1 cat[*]
     2 f_catalog_cd = f8
 )
 FREE RECORD temprequest
 RECORD temprequest(
   1 orderlist[*]
     2 orderid = f8
     2 catalogcd = f8
 )
 IF (( $RULE_NAME="ASA"))
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=200
     AND cv.display_key IN ("ASPIRIN*", "WARFARIN")
     AND cv.active_ind=1)
   HEAD REPORT
    mn_cnt = 0
   DETAIL
    mn_cnt = (mn_cnt+ 1), stat = alterlist(med->cat,mn_cnt), med->cat[mn_cnt].f_catalog_cd = cv
    .code_value
   WITH nocounter
  ;end select
 ELSEIF (( $RULE_NAME="NSAIDS"))
  SELECT INTO "nl:"
   FROM order_catalog_synonym ocs,
    alt_sel_list asl,
    alt_sel_cat ascd
   PLAN (ascd
    WHERE ascd.long_description="nonsteroidal anti-inflammatory agents"
     AND ascd.ahfs_ind=1)
    JOIN (asl
    WHERE asl.alt_sel_category_id=ascd.alt_sel_category_id)
    JOIN (ocs
    WHERE ocs.synonym_id=asl.synonym_id
     AND ocs.catalog_type_cd=mf_pharmacy_var
     AND ocs.mnemonic_type_cd=mf_primary_var)
   HEAD REPORT
    mn_cnt = 0
   DETAIL
    mn_cnt = (mn_cnt+ 1), stat = alterlist(med->cat,mn_cnt), med->cat[mn_cnt].f_catalog_cd = ocs
    .catalog_cd
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(temprequest->orderlist,size(request->orderlist,5))
 FOR (x = 1 TO size(temprequest->orderlist,5))
   SET temprequest->orderlist[x].orderid = request->orderlist[x].orderid
   SET temprequest->orderlist[x].catalogcd = request->orderlist[x].catalog_code
   FOR (y = 1 TO size(med->cat,5))
     IF ((temprequest->orderlist[x].catalogcd=med->cat[y].f_catalog_cd))
      SET mn_cnt1 = (mn_cnt1+ 1)
      SET ms_tmp1 = concat(ms_tmp1," ",trim(uar_get_code_display(med->cat[y].f_catalog_cd)),", ")
     ENDIF
   ENDFOR
 ENDFOR
 CALL echo(build("mn_cnt1 = ",mn_cnt1))
 IF (( $RULE_NAME="NSAIDS"))
  IF (mn_cnt1 >= 3)
   SET retval = 100
   SET log_message = build2("find ",cnvtstring(mn_cnt1)," orders ")
   SET log_misc1 = concat(ms_tmp1," ",trim(cnvtstring(mn_cnt1)))
   GO TO exit_script
  ELSE
   SET retval = 0
   SET log_message = build2("not 3 orders ")
  ENDIF
 ELSE
  IF (mn_cnt1 >= 2)
   CALL echo(build("list0 = ",size(request->orderlist,5)))
   SET retval = 100
   SET log_message = build2("find ",cnvtstring(mn_cnt1)," orders ")
   SET log_misc1 = concat(ms_tmp1," ",trim(cnvtstring(mn_cnt1)))
   GO TO exit_script
  ELSE
   SET retval = 0
   SET log_message = build2("not 2 orders ")
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(med)
 CALL echorecord(eksdata)
 CALL echorecord(request)
END GO
