Rem
Rem    NAME
Rem      ashrptinoop.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    akini       09/11/08 - ash report do nothing script
Rem    akini       09/11/08 - Created
Rem

Rem
Rem Copyright (c) 2008, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      ashrptistd.sql - SQL*Plus helper script for obtaining user input
Rem                       when ASH report is run on standby instance
Rem
Rem    DESCRIPTION
Rem
Rem
Rem    NOTES
Rem      This script expects a variable stdby_flag to be already declared.
Rem      The user choice (standby/primary) is stored in this variable
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    akini       09/11/08 - ash report script for user input on standby
Rem                           instance
Rem    akini       09/11/08 - Created
Rem

Rem
Rem    NAME
Rem      awrblmig.sql - AWR Baseline Migrate
Rem
Rem    DESCRIPTION
Rem      This script is used to migrate the AWR Baseline data from
Rem      the renamed BL tables back to the base tables.  This script is
Rem      needed because the way the baselines are stored have been changed
Rem      in 11g.  This script will
Rem
Rem    NOTES
Rem      Run this script if you have AWR Baselines prior to the 11g release
Rem      and have upgraded to the 11g release.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      11/16/06 - modify set statements
Rem    mlfeng      06/18/06 - Script to migrate the AWR Baseline data
Rem    mlfeng      06/18/06 - Created
Rem