CREATE PROGRAM cv_get_prefs_request:dba
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 IF ( NOT (validate(request)))
  FREE RECORD request
  RECORD request(
    1 debugind = i2
    1 context[*]
      2 name = vc
      2 id = vc
    1 sectionname = vc
    1 sectionid = vc
    1 grouppath[*]
      2 name = vc
    1 entry[*]
      2 name = vc
    1 recurse = i2
  ) WITH persistscript
 ENDIF
 SET last_mod = "000"
END GO
