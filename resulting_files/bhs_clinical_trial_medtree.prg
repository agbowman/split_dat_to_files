CREATE PROGRAM bhs_clinical_trial_medtree
 PROMPT
  "Display value or initial state command ('INIT' or '%LIST%')" = "INIT",
  "Search item locataion code" = 1.0,
  "Item terminal selection state (1 or 0)" = 1,
  "Item expanded icon number" = 0,
  "Item collapsed icon number" = 0,
  "Item expandable (1=expandable)" = 1,
  "Location meaning value" = "",
  "Location path string" = ""
  WITH item_display, item_keyvalue, item_terminal_flag,
  item_icon_opened, item_icon_closed, item_expand_flag,
  item_meaning, item_path
 EXECUTE ccl_prompt_api_dataset "dataset", "parameter"
 IF (( $ITEM_DISPLAY="INIT")
  AND cnvtint( $ITEM_KEYVALUE)=1)
  SELECT INTO "NL:"
   FROM order_catalog_synonym ocs,
    order_catalog oc
   PLAN (ocs
    WHERE cnvtupper(ocs.mnemonic_key_cap) IN (value(build(cnvtupper( $ITEM_MEANING),"*")))
     AND ocs.active_ind=1
     AND ocs.catalog_type_cd=2516)
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd
     AND oc.active_ind=1
     AND oc.catalog_type_cd=2516
     AND  NOT (oc.catalog_cd IN (
    (SELECT
     b.catalog_cd
     FROM bhs_clinical_trial_meds b
     WHERE (b.irb_number= $ITEM_PATH)
      AND b.catalog_cd=oc.catalog_cd
      AND b.active_ind=1))))
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SELECT INTO "NL:"
    item_display = "No Meds found", item_keyvalue = 999999, item_terminal = 1,
    item_icon_opened = 0, item_icon_closed = 0, item_expand_flag = 0,
    item_meaning = "No Meds found", item_path = "No Meds found"
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    ORDER BY item_keyvalue
    HEAD REPORT
     stat = makedataset(1)
    HEAD item_keyvalue
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check
   ;end select
  ELSE
   SELECT INTO "NL:"
    item_display = oc.primary_mnemonic, item_keyvalue = oc.catalog_cd, item_terminal = 1,
    item_icon_opened = 1, item_icon_closed = 1, item_expand_flag = 1,
    item_meaning = oc.primary_mnemonic, item_path = oc.primary_mnemonic
    FROM order_catalog_synonym ocs,
     order_catalog oc
    PLAN (ocs
     WHERE cnvtupper(ocs.mnemonic_key_cap) IN (value(build(cnvtupper( $ITEM_MEANING),"*")))
      AND ocs.active_ind=1
      AND ocs.catalog_type_cd=2516)
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd
      AND oc.active_ind=1
      AND oc.catalog_type_cd=2516
      AND  NOT (oc.catalog_cd IN (
     (SELECT
      b.catalog_cd
      FROM bhs_clinical_trial_meds b
      WHERE (b.irb_number= $ITEM_PATH)
       AND b.catalog_cd=oc.catalog_cd
       AND b.active_ind=1))))
    ORDER BY item_keyvalue
    HEAD REPORT
     stat = makedataset(1000)
    HEAD item_keyvalue
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check
   ;end select
  ENDIF
 ELSEIF (( $ITEM_DISPLAY="INIT"))
  SELECT INTO "NL:"
   FROM order_catalog oc
   WHERE oc.catalog_cd=cnvtreal( $ITEM_KEYVALUE)
    AND oc.active_ind=1
    AND oc.catalog_type_cd=2516
    AND  NOT (oc.catalog_cd IN (
   (SELECT
    b.catalog_cd
    FROM bhs_clinical_trial_meds b
    WHERE (b.irb_number= $ITEM_PATH)
     AND b.catalog_cd=oc.catalog_cd
     AND b.active_ind=1)))
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SELECT INTO "NL:"
    item_display = "No Meds found", item_keyvalue = 999999, item_terminal = 1,
    item_icon_opened = 0, item_icon_closed = 0, item_expand_flag = 0,
    item_meaning = "No Meds found", item_path = "No Meds found"
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    ORDER BY item_keyvalue
    HEAD REPORT
     stat = makedataset(1)
    HEAD item_keyvalue
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check
   ;end select
  ELSE
   SELECT INTO "NL:"
    item_display = oc.primary_mnemonic, item_keyvalue = oc.catalog_cd, item_terminal = 1,
    item_icon_opened = 1, item_icon_closed = 1, item_expand_flag = 1,
    item_meaning = oc.primary_mnemonic, item_path = oc.primary_mnemonic
    FROM order_catalog oc
    WHERE oc.catalog_cd=cnvtreal( $ITEM_KEYVALUE)
     AND oc.active_ind=1
     AND oc.catalog_type_cd=2516
     AND  NOT (oc.catalog_cd IN (
    (SELECT
     b.catalog_cd
     FROM bhs_clinical_trial_meds b
     WHERE (b.irb_number= $ITEM_PATH)
      AND b.catalog_cd=oc.catalog_cd
      AND b.active_ind=1)))
    ORDER BY item_keyvalue
    HEAD REPORT
     stat = makedataset(1000)
    HEAD item_keyvalue
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check
   ;end select
  ENDIF
 ELSEIF (( $ITEM_DISPLAY="EXISTING"))
  SELECT INTO "NL:"
   FROM bhs_clinical_trial_meds b,
    order_catalog oc
   PLAN (b
    WHERE (b.irb_number= $ITEM_PATH)
     AND b.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=b.catalog_cd
     AND oc.active_ind=1
     AND oc.catalog_type_cd=2516)
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SELECT INTO "NL:"
    item_display = "No Meds found", item_keyvalue = 999999, item_terminal = 1,
    item_icon_opened = 0, item_icon_closed = 0, item_expand_flag = 0,
    item_meaning = "No Meds found", item_path = "No Meds found"
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    ORDER BY item_keyvalue
    HEAD REPORT
     stat = makedataset(1)
    HEAD item_keyvalue
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check
   ;end select
  ELSE
   SELECT INTO "NL:"
    item_display = oc.primary_mnemonic, item_keyvalue = oc.catalog_cd, item_terminal = 1,
    item_icon_opened = 1, item_icon_closed = 1, item_expand_flag = 1,
    item_meaning = oc.primary_mnemonic, item_path = oc.primary_mnemonic
    FROM bhs_clinical_trial_meds b,
     order_catalog oc
    PLAN (b
     WHERE (b.irb_number= $ITEM_PATH)
      AND b.active_ind=1)
     JOIN (oc
     WHERE oc.catalog_cd=b.catalog_cd
      AND oc.active_ind=1
      AND oc.catalog_type_cd=2516)
    ORDER BY item_keyvalue
    HEAD REPORT
     stat = makedataset(1000)
    HEAD item_keyvalue
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check
   ;end select
  ENDIF
 ELSE
  SELECT INTO "NL:"
   item_display = ocs2.mnemonic, item_keyvalue = ocs2.catalog_cd, item_terminal = 1,
   item_icon_opened = 2, item_icon_closed = 2, item_expand_flag = 0,
   item_meaning = ocs2.mnemonic, item_path = oc.primary_mnemonic
   FROM order_catalog_synonym ocs2,
    order_catalog oc
   PLAN (ocs2
    WHERE ocs2.catalog_cd=cnvtreal( $ITEM_KEYVALUE)
     AND ocs2.catalog_type_cd=2516
     AND ocs2.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=ocs2.catalog_cd
     AND oc.active_ind=1
     AND oc.catalog_type_cd=2516)
   ORDER BY item_keyvalue
   HEAD REPORT
    stat = makedataset(1000)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check
  ;end select
 ENDIF
END GO
