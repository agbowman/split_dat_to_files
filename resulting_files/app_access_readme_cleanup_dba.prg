CREATE PROGRAM app_access_readme_cleanup:dba
 PAINT
 RECORD appaccessdata(
   1 totalcnt = i4
   1 reportrun = i2
   1 begindttm = dq8
   1 enddttm = dq8
   1 appgrouplist[*]
     2 appgroupcd = f8
     2 appgroup = vc
     2 applist[*]
       3 appaccessid = f8
       3 appnumber = i4
       3 appdesc = vc
 )
 DECLARE appgroupcnt = i4 WITH noconstant(0)
 DECLARE appcnt = i4 WITH noconstant(0)
 SUBROUTINE runreport(void)
   IF ((appaccessdata->reportrun=1))
    RETURN(0)
   ENDIF
   CALL text(14,10,"Running Report...please wait.")
   DECLARE installdttmfound = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    da.end_dt_tm
    FROM dm_info di,
     dm_environment de,
     dm_ocd_log da
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
     AND de.environment_id=di.info_number
     AND da.environment_id=de.environment_id
     AND da.project_type="README"
     AND da.project_name="2096"
     AND da.project_instance=2
    ORDER BY da.end_dt_tm
    DETAIL
     installdttmfound = 1, appaccessdata->begindttm = cnvtdate(da.end_dt_tm), appaccessdata->enddttm
      = cnvtdate(datetimeadd(appaccessdata->begindttm,1))
    WITH nocounter
   ;end select
   IF (installdttmfound=0)
    CALL text(16,10,"Error retrieving appropriate installation date.  Exiting.")
    RETURN(1)
   ENDIF
   DECLARE dbaappgroup = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=500
     AND cv.cki="CKI.CODEVALUE!2987"
     AND cv.active_ind=1
    DETAIL
     dbaappgroup = cv.code_value
    WITH nocounter
   ;end select
   IF (dbaappgroup=0)
    CALL text(16,10,"Error retrieving dba application group code.  Exiting.")
    RETURN(1)
   ENDIF
   DECLARE systemprsnlid = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl p
    WHERE p.username="SYSTEM"
    DETAIL
     systemprsnlid = p.person_id
    WITH nocounter
   ;end select
   IF (systemprsnlid=0)
    CALL text(16,10,"Error retrieving SYSTEM prsnl id.  Exiting.")
    RETURN(1)
   ENDIF
   SET appaccessdata->totalcnt = 0
   SELECT INTO "nl:"
    a.application_number, a.app_group_cd
    FROM application_access aa,
     application a
    WHERE aa.updt_dt_tm >= cnvtdatetime(appaccessdata->begindttm)
     AND aa.updt_dt_tm <= cnvtdatetime(appaccessdata->enddttm)
     AND aa.app_group_cd != dbaappgroup
     AND aa.updt_id=systemprsnlid
     AND a.application_number=aa.application_number
    ORDER BY aa.app_group_cd, aa.application_number
    HEAD aa.app_group_cd
     appgroupcnt = (appgroupcnt+ 1), stat = alterlist(appaccessdata->appgrouplist,appgroupcnt),
     appaccessdata->appgrouplist[appgroupcnt].appgroupcd = aa.app_group_cd,
     appaccessdata->appgrouplist[appgroupcnt].appgroup = uar_get_code_display(aa.app_group_cd),
     appcnt = 0
    DETAIL
     appaccessdata->totalcnt = (appaccessdata->totalcnt+ 1), appcnt = (appcnt+ 1), stat = alterlist(
      appaccessdata->appgrouplist[appgroupcnt].applist,appcnt),
     appaccessdata->appgrouplist[appgroupcnt].applist[appcnt].appnumber = aa.application_number,
     appaccessdata->appgrouplist[appgroupcnt].applist[appcnt].appaccessid = aa.application_access_id,
     appaccessdata->appgrouplist[appgroupcnt].applist[appcnt].appdesc = a.description
    WITH nocounter
   ;end select
   IF (appgroupcnt <= 0)
    CALL text(16,10,"No items found.  Nothing to cleanup.  Exiting.")
    RETURN(1)
   ENDIF
   SET tmpcnt = cnvtstring(appaccessdata->totalcnt)
   SELECT
    FROM (dummyt d  WITH seq = value(appgroupcnt))
    HEAD REPORT
     col 00,
     "---------------------------------------------------------------------------------------", row
      + 1,
     col 00,
     "The following is a list of application groups that were granted access to the specified", row
      + 1,
     col 00, "applications when on the day that readme 2096 was executed.  It is important to note",
     row + 1,
     col 00, "that this is a potential list of items that need to be cleaned up, but the list needs",
     row + 1,
     col 00,
     "to be reviewed to determine what, if any changes need to be made.  After reviewing this", row
      + 1,
     col 00, "exiting this screen, you have the option to delete all records displayed here.", row +
     2,
     col 00, "It is highly recommended that you print this report for future reference before", row
      + 1,
     col 00, "proceeding.", col 00,
     "---------------------------------------------------------------------------------------", row
      + 2, "The report is going to determine rows that were installed by Readme 2096, instance 2 on",
     row + 1, "Date: ", appaccessdata->begindttm"DD-MMM-YYYY;;d",
     row + 1, "Number of rows that were inserted into Application Access are: ", tmpcnt,
     row + 2
    DETAIL
     col 00,
     "=======================================================================================", row
      + 1,
     col 00, "Application Group:  ", appaccessdata->appgrouplist[d.seq].appgroup,
     row + 1, col 00, "Applications:"
     FOR (appcnt = 1 TO size(appaccessdata->appgrouplist[d.seq].applist,5))
       col 20, appaccessdata->appgrouplist[d.seq].applist[appcnt].appnumber"##########;L", col 30,
       appaccessdata->appgrouplist[d.seq].applist[appcnt].appdesc, row + 1
     ENDFOR
     row + 1, col 00,
     "======================================================================================="
    WITH nocounter, format = stream, maxrow = 1
   ;end select
   SET appaccessdata->reportrun = 1
   RETURN(0)
 END ;Subroutine
 SUBROUTINE rundelete(void)
   IF ((appaccessdata->reportrun=0))
    CALL text(14,10,"You must run the report first.")
    RETURN
   ENDIF
   CALL text(16,10,"Are you sure you want to delete everything from the report, Y/N?")
   CALL accept(16,75,"P(1);CU")
   SET choice = curaccept
   IF (choice != "Y")
    CALL clear(16,10,70)
    RETURN
   ENDIF
   CALL clear(16,10,70)
   CALL text(13,10,"Deleting rows for application group: ")
   DECLARE item = i4 WITH noconstant(0)
   FOR (item = 1 TO appgroupcnt)
     CALL clear(14,15,64)
     CALL text(14,15,appaccessdata->appgrouplist[item].appgroup)
     DELETE  FROM application_access aa,
       (dummyt d  WITH seq = value(size(appaccessdata->appgrouplist[item].applist,5)))
      SET aa.seq = 1
      PLAN (d)
       JOIN (aa
       WHERE (aa.application_access_id=appaccessdata->appgrouplist[item].applist[d.seq].appaccessid))
      WITH nocounter
     ;end delete
     COMMIT
   ENDFOR
   CALL clear(13,10,64)
   CALL clear(14,10,64)
   CALL text(14,10,"Finished")
 END ;Subroutine
 DECLARE stat = i2 WITH noconstant(0)
 SET appaccessdata->reportrun = 0
 DECLARE menuchoice = i2 WITH noconstant(0)
 WHILE (menuchoice != 3)
   CALL box(5,5,15,80)
   CALL text(7,10,"1) RUN REPORT")
   CALL text(9,10,"2) DELETE ITEMS FROM REPORT")
   CALL text(11,10,"3) EXIT")
   CALL text(16,10,"SELECT OPTION (1,2,3)")
   CALL accept(16,32,"9;",1
    WHERE curaccept IN (1, 2, 3))
   SET menuchoice = curaccept
   CASE (menuchoice)
    OF 1:
     SET stat = runreport(0)
    OF 2:
     CALL rundelete(0)
     SET stat = 1
   ENDCASE
   IF (stat=1)
    SET menuchoice = 3
   ENDIF
 ENDWHILE
END GO
