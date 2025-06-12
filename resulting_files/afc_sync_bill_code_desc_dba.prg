CREATE PROGRAM afc_sync_bill_code_desc:dba
 PAINT
 SET width = 132
 SET modify = system
 SET endeffectivedatetime = fillstring(20," ")
#accept_dates
 CALL clear(1,1)
 CALL video(n)
 CALL video(n)
 CALL text(10,1,"Enter activity type: ")
 CALL accept(10,21,"9999999999")
 SET activitytype = 0.0
 SET activitytype = curaccept
 CALL text(12,1,"Updating bill code descriptions...")
 RECORD billitem(
   1 bill_item_qual = i2
   1 bill_item[*]
     2 bill_item_id = f8
     2 ext_description = vc
 )
 SET billcodetypecd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13019
   AND cv.cdf_meaning="BILL CODE"
   AND cv.active_ind=1
  DETAIL
   billcodetypecd = cv.code_value
  WITH nocounter
 ;end select
 SET count1 = 0
 SET stat = alterlist(billitem->bill_item,count1)
 SELECT INTO "nl:"
  FROM bill_item b
  WHERE b.active_ind=1
   AND b.ext_owner_cd=activitytype
  DETAIL
   count1 = (count1+ 1), stat = alterlist(billitem->bill_item,count1), billitem->bill_item[count1].
   ext_description = b.ext_description,
   billitem->bill_item[count1].bill_item_id = b.bill_item_id
  WITH nocounter
 ;end select
 SET billitem->bill_item_qual = count1
 CALL echo("Updating CDM_SCHED")
 FOR (x = 1 TO billitem->bill_item_qual)
  UPDATE  FROM bill_item_modifier bm
   SET bm.key7 = billitem->bill_item[x].ext_description
   WHERE (bm.bill_item_id=billitem->bill_item[x].bill_item_id)
    AND bm.bill_item_type_cd=billcodetypecd
    AND bm.key1_id IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=14002
     AND cv.cdf_meaning="CDM_SCHED"
     AND cv.active_ind=1))
    AND bm.active_ind=1
  ;end update
  COMMIT
 ENDFOR
 CALL echo("Updating CPT-4")
 FOR (x = 1 TO billitem->bill_item_qual)
  UPDATE  FROM bill_item_modifier bm
   SET bm.key7 = billitem->bill_item[x].ext_description
   WHERE (bm.bill_item_id=billitem->bill_item[x].bill_item_id)
    AND bm.bill_item_type_cd=billcodetypecd
    AND bm.key1_id IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=14002
     AND cv.cdf_meaning="CPT4"
     AND cv.active_ind=1))
    AND bm.active_ind=1
  ;end update
  COMMIT
 ENDFOR
 CALL echo("Updating ICD-9")
 FOR (x = 1 TO billitem->bill_item_qual)
  UPDATE  FROM bill_item_modifier bm
   SET bm.key7 = billitem->bill_item[x].ext_description
   WHERE (bm.bill_item_id=billitem->bill_item[x].bill_item_id)
    AND bm.bill_item_type_cd=billcodetypecd
    AND bm.key1_id IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=14002
     AND cv.cdf_meaning="ICD9"
     AND cv.active_ind=1))
    AND bm.active_ind=1
  ;end update
  COMMIT
 ENDFOR
 CALL echo("Updating SNMI95")
 FOR (x = 1 TO billitem->bill_item_qual)
  UPDATE  FROM bill_item_modifier bm
   SET bm.key7 = billitem->bill_item[x].ext_description
   WHERE (bm.bill_item_id=billitem->bill_item[x].bill_item_id)
    AND bm.bill_item_type_cd=billcodetypecd
    AND bm.key1_id IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=14002
     AND cv.cdf_meaning="SNMI95"
     AND cv.active_ind=1))
    AND bm.active_ind=1
  ;end update
  COMMIT
 ENDFOR
 CALL echo(
  "**********NOTE: You will have to cycle the cpm script servers for the changes to take affect")
 CALL echo("")
 CALL echo("")
END GO
