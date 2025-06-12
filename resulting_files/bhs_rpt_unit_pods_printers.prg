CREATE PROGRAM bhs_rpt_unit_pods_printers
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Please enter a facility:" = 0,
  "Nursing Unit" = 0,
  "Check for RX" = 0
  WITH outdev, facility, nurse_unit,
  chk_rx
 DECLARE mc_msg2 = vc WITH constant("*******************************************"), protect
 DECLARE mf_pod_code_set = f8 WITH protect
 DECLARE mc_podded_unit = vc WITH protect
 DECLARE mc_msg1 = vc WITH protect
 IF (( $CHK_RX=0))
  SET mf_pod_code_set = 103027.0
  SET mc_msg1 = concat("No Pod logic for ",uar_get_code_display( $NURSE_UNIT))
 ELSEIF (( $CHK_RX=1))
  SET mf_pod_code_set = 104103.0
  SET mc_msg1 = concat("No RX Pod logic for ",uar_get_code_display( $NURSE_UNIT))
 ENDIF
 SELECT INTO "nl:"
  pod_codes = build(uar_get_code_display(l2.parent_loc_cd),uar_get_code_display(l2.child_loc_cd),
   uar_get_code_display(l.parent_loc_cd))
  FROM location_group l,
   location_group l1,
   location_group l2
  PLAN (l
   WHERE (l.parent_loc_cd= $NURSE_UNIT)
    AND l.root_loc_cd=0
    AND l.active_ind=1)
   JOIN (l1
   WHERE l1.child_loc_cd=l.parent_loc_cd
    AND l1.parent_loc_cd=680158.00
    AND l1.root_loc_cd=0
    AND l1.active_ind=1)
   JOIN (l2
   WHERE l2.child_loc_cd=l1.parent_loc_cd
    AND l2.parent_loc_cd=673936.00
    AND l2.root_loc_cd=0
    AND l2.active_ind=1)
  ORDER BY pod_codes
  HEAD pod_codes
   mc_podded_unit = pod_codes
  WITH nocounter, separator = " ", format
 ;end select
 IF (curqual > 0)
  SET mc_podded_unit = concat(cnvtupper(trim(mc_podded_unit,3)),patstring("*"))
  CALL echo(build("mc_podded_unit = ",mc_podded_unit))
  SELECT INTO  $OUTDEV
   room = cv1.display, pod = cv1.definition, printer = cv2.definition
   FROM code_value cv1,
    code_value cv2
   PLAN (cv1
    WHERE cv1.code_set=103026
     AND cv1.display=patstring(mc_podded_unit))
    JOIN (cv2
    WHERE cv2.code_set=mf_pod_code_set
     AND cv1.definition=cv2.display)
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
 IF (curqual=0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", y_pos = 18,
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))),
    mc_msg1, row + 2, mc_msg2
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
END GO
