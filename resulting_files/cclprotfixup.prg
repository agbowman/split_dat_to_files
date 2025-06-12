CREATE PROGRAM cclprotfixup
 RANGE OF d IS dprotect
 SET stat = validate(d.prcname)
 FREE RANGE d
 IF (stat=1)
  UPDATE  FROM dprotect d
   SET d.updt_id = 0, d.updt_task = 0, d.updt_applctx = 0,
    d.prcname = " "
   WHERE ((d.ccl_version=1) OR (d.ccl_version=2
    AND check(d.prcname) != trim(check(d.prcname),8)))
   WITH counter
  ;end update
  UPDATE  FROM dprotect d
   SET d.updt_id = 0
   WHERE d.ccl_version=2
   WITH counter
  ;end update
 ENDIF
END GO
