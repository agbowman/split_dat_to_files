CREATE PROGRAM ams_ld_check_and_set:dba
 EXECUTE ams_define_toolkit_common
 FREE RECORD temp
 RECORD temp(
   1 list[*]
     2 username = vc
     2 ld_key = vc
 )
 DECLARE script_name = vc WITH protect, constant("AMS_LD_CHECK_AND_SET")
 SELECT DISTINCT INTO "nl"
  p.name_full_formatted, p.username, p.active_ind,
  p.logical_domain_id, p_position_disp = uar_get_code_display(p.position_cd), p.beg_effective_dt_tm,
  p.end_effective_dt_tm, l.logical_domain_id, l.mnemonic_key,
  assign_ld = trim(substring((findstring("#",p.username,1,1)+ 1),10,p.username))
  FROM prsnl p,
   logical_domain l,
   dummyt d1
  PLAN (p
   WHERE p.username="*#*")
   JOIN (l
   WHERE p.logical_domain_id=l.logical_domain_id)
   JOIN (d1
   WHERE l.mnemonic_key != trim(substring((findstring("#",p.username,1,1)+ 1),10,p.username)))
  ORDER BY p.username
  HEAD REPORT
   cnt = 0, stat = alterlist(temp->list,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(temp->list,(cnt+ 9))
   ENDIF
   temp->list[cnt].username = p.username, temp->list[cnt].ld_key = assign_ld
  FOOT REPORT
   stat = alterlist(temp->list,cnt)
  WITH nocounter
 ;end select
 SET rec_size = size(temp->list,5)
 FOR (x = 1 TO value(rec_size))
  UPDATE  FROM prsnl p
   SET p.logical_domain_id =
    (SELECT
     logical_domain_id
     FROM logical_domain
     WHERE (mnemonic_key=temp->list[x].ld_key)), p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    p.updt_id = 0
   WHERE (p.username=temp->list[x].username)
  ;end update
  IF (mod(x,100)=0)
   COMMIT
  ENDIF
 ENDFOR
 COMMIT
 CALL updtdminfo(script_name,cnvtreal(rec_size))
#exit_script
 SET script_ver = "003  10/04/16  Shawn Blue   Changed from @ to #	"
END GO
