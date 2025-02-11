*=======================================================================
*
* WCSLIB 4.18 - an implementation of the FITS WCS standard.
* Copyright (C) 1995-2013, Mark Calabretta
*
* This file is part of WCSLIB.
*
* WCSLIB is free software: you can redistribute it and/or modify it
* under the terms of the GNU Lesser General Public License as published
* by the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* WCSLIB is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
* FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
* License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with WCSLIB.  If not, see http://www.gnu.org/licenses.
*
* Direct correspondence concerning WCSLIB to mark@calabretta.id.au
*
* Author: Mark Calabretta, Australia Telescope National Facility, CSIRO.
* http://www.atnf.csiro.au/people/Mark.Calabretta
* $Id$
*=======================================================================

*     Functions.
      EXTERNAL  WCSERR_ENABLE, WCSERR_GET, WCSERR_GTC, WCSERR_GTI,
     :          WCSERR_PRT
      INTEGER   WCSERR_ENABLE, WCSERR_GET, WCSERR_GTC, WCSERR_GTI,
     :          WCSERR_PRT

*     Length of the WCSERR data structure (INTEGER array) on 64-bit
*     machines.  Only needs to be 44 on 32-bit machines.
      INTEGER   ERRLEN
      PARAMETER (ERRLEN = 46)

*     Codes for WCSERR data structure elements used by WCSERR_GET.
      INTEGER   WCSERR_FILE, WCSERR_FUNCTION, WCSERR_LINE_NO,
     :          WCSERR_MSG, WCSERR_STATUS

      PARAMETER (WCSERR_STATUS   = 200)
      PARAMETER (WCSERR_LINE_NO  = 201)
      PARAMETER (WCSERR_FUNCTION = 202)
      PARAMETER (WCSERR_FILE     = 203)
      PARAMETER (WCSERR_MSG      = 204)

*     WCSERR message length.
      INTEGER   WCSERR_MSG_LENGTH
      PARAMETER (WCSERR_MSG_LENGTH = 160)
