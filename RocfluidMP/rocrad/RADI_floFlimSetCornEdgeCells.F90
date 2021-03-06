! *********************************************************************
! * Rocstar Simulation Suite                                          *
! * Copyright@2015, Illinois Rocstar LLC. All rights reserved.        *
! *                                                                   *
! * Illinois Rocstar LLC                                              *
! * Champaign, IL                                                     *
! * www.illinoisrocstar.com                                           *
! * sales@illinoisrocstar.com                                         *
! *                                                                   *
! * License: See LICENSE file in top level of distribution package or *
! * http://opensource.org/licenses/NCSA                               *
! *********************************************************************
! *********************************************************************
! * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,   *
! * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES   *
! * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND          *
! * NONINFRINGEMENT.  IN NO EVENT SHALL THE CONTRIBUTORS OR           *
! * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       *
! * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   *
! * Arising FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE    *
! * USE OR OTHER DEALINGS WITH THE SOFTWARE.                          *
! *********************************************************************
!******************************************************************************
!
! Purpose: set values in edge and corner cells of a region.
!
! Description: this is for the case if the cells are not located
!              within another region.
!
! Input: region = region data.
!
! Output: new values of FLD radiation variables.
!
! Notes: values in ALL edge and corner cells are averaged from neighboring
!        cells. Hence, this routine should be called first, before values
!        from adjacent regions are copied.
!
!******************************************************************************
!
! $Id: RADI_floFlimSetCornEdgeCells.F90,v 1.4 2008/12/06 08:44:38 mtcampbe Exp $
!
! Copyright: (c) 2001 by the University of Illinois
!
!******************************************************************************

SUBROUTINE RADI_FloFlimSetCornEdgeCells( region )

  USE ModDataTypes
  USE ModDataStruct, ONLY : t_region
  USE ModInterfaces, ONLY : RFLO_GetDimensDummy, RFLO_GetDimensPhys, &
                            RFLO_GetCellOffset
  USE ModError
  IMPLICIT NONE

#include "Indexing.h"

! ... parameters
  TYPE(t_region) :: region

! ... loop variables
  INTEGER :: i, j, k

! ... local variables
  INTEGER :: idcbeg, idcend, jdcbeg, jdcend, kdcbeg, kdcend
  INTEGER :: ipcbeg, ipcend, jpcbeg, jpcend, kpcbeg, kpcend
  INTEGER :: iLev, nCv, gasModel, iCOff, ijCOff, ijkD, ijkC1, ijkC2

  REAL(RFREAL), POINTER :: rcv(:,:)

!******************************************************************************

  CALL RegisterFunction( region%global,'RADI_FloFlimSetCornEdgeCells', &
                         'RADI_floFlimSetCornEdgeCells.F90' )

! get dimensions and pointers -------------------------------------------------

  iLev = region%currLevel

  CALL RFLO_GetDimensDummy( region,iLev,idcbeg,idcend, &
                            jdcbeg,jdcend,kdcbeg,kdcend )
  CALL RFLO_GetDimensPhys( region,iLev,ipcbeg,ipcend, &
                           jpcbeg,jpcend,kpcbeg,kpcend )
  CALL RFLO_GetCellOffset( region,iLev,iCOff,ijCOff )

  nCv =  region%radiInput%nCv

  rcv => region%levels(iLev)%radi%cv

! edges 9, 10, 11, 12 ---------------------------------------------------------

  DO i=ipcbeg,ipcend
    DO j=jpcbeg-1,jdcbeg,-1         ! edges 9, 10
      DO k=kpcbeg-1,kdcbeg,-1
        ijkD  = IndIJK(i,j  ,k  ,iCOff,ijCOff)
        ijkC1 = IndIJK(i,j+1,k  ,iCOff,ijCOff)
        ijkC2 = IndIJK(i,j  ,k+1,iCOff,ijCOff)
        CALL AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,rcv )
      ENDDO
      DO k=kpcend+1,kdcend
        ijkD  = IndIJK(i,j,k,iCOff,ijCOff)
        ijkC1 = IndIJK(i,j+1,k  ,iCOff,ijCOff)
        ijkC2 = IndIJK(i,j  ,k-1,iCOff,ijCOff)
        CALL AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,rcv )
      ENDDO
    ENDDO

    DO j=jpcend+1,jdcend           ! edges 11, 12
      DO k=kpcbeg-1,kdcbeg,-1
        ijkD  = IndIJK(i,j,k,iCOff,ijCOff)
        ijkC1 = IndIJK(i,j-1,k  ,iCOff,ijCOff)
        ijkC2 = IndIJK(i,j  ,k+1,iCOff,ijCOff)
        CALL AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,rcv )
      ENDDO
      DO k=kpcend+1,kdcend
        ijkD  = IndIJK(i,j,k,iCOff,ijCOff)
        ijkC1 = IndIJK(i,j-1,k  ,iCOff,ijCOff)
        ijkC2 = IndIJK(i,j  ,k-1,iCOff,ijCOff)
        CALL AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,rcv )
      ENDDO
    ENDDO
  ENDDO

! edges 2, 4, 6, 8 ------------------------------------------------------------

  DO j=jpcbeg,jpcend
    DO i=ipcbeg-1,idcbeg,-1        ! edges 2, 4
      DO k=kpcend+1,kdcend
        ijkD  = IndIJK(i  ,j,k  ,iCOff,ijCOff)
        ijkC1 = IndIJK(i+1,j,k  ,iCOff,ijCOff)
        ijkC2 = IndIJK(i  ,j,k-1,iCOff,ijCOff)
        CALL AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,rcv )
      ENDDO
      DO k=kpcbeg-1,kdcbeg,-1
        ijkD  = IndIJK(i  ,j,k  ,iCOff,ijCOff)
        ijkC1 = IndIJK(i+1,j,k  ,iCOff,ijCOff)
        ijkC2 = IndIJK(i  ,j,k+1,iCOff,ijCOff)
        CALL AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,rcv )
      ENDDO
    ENDDO

    DO i=ipcend+1,idcend           ! edges 6, 8
      DO k=kpcend+1,kdcend
        ijkD  = IndIJK(i  ,j,k  ,iCOff,ijCOff)
        ijkC1 = IndIJK(i-1,j,k  ,iCOff,ijCOff)
        ijkC2 = IndIJK(i  ,j,k-1,iCOff,ijCOff)
        CALL AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,rcv )
      ENDDO
      DO k=kpcbeg-1,kdcbeg,-1
        ijkD  = IndIJK(i  ,j,k  ,iCOff,ijCOff)
        ijkC1 = IndIJK(i-1,j,k  ,iCOff,ijCOff)
        ijkC2 = IndIJK(i  ,j,k+1,iCOff,ijCOff)
        CALL AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,rcv )
      ENDDO
    ENDDO
  ENDDO

! edges 1, 3, 5, 7 ------------------------------------------------------------

  DO k=kdcbeg,kdcend
    DO i=ipcbeg-1,idcbeg,-1        ! edges 1, 3
      DO j=jpcbeg-1,jdcbeg,-1
        ijkD  = IndIJK(i  ,j  ,k,iCOff,ijCOff)
        ijkC1 = IndIJK(i+1,j  ,k,iCOff,ijCOff)
        ijkC2 = IndIJK(i  ,j+1,k,iCOff,ijCOff)
        CALL AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,rcv )
      ENDDO
      DO j=jpcend+1,jdcend
        ijkD  = IndIJK(i  ,j  ,k,iCOff,ijCOff)
        ijkC1 = IndIJK(i+1,j  ,k,iCOff,ijCOff)
        ijkC2 = IndIJK(i  ,j-1,k,iCOff,ijCOff)
        CALL AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,rcv )
      ENDDO
    ENDDO

    DO i=ipcend+1,idcend           ! edges 5, 7
      DO j=jpcbeg-1,jdcbeg,-1
        ijkD  = IndIJK(i  ,j  ,k,iCOff,ijCOff)
        ijkC1 = IndIJK(i-1,j  ,k,iCOff,ijCOff)
        ijkC2 = IndIJK(i  ,j+1,k,iCOff,ijCOff)
        CALL AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,rcv )
      ENDDO
      DO j=jpcend+1,jdcend
        ijkD  = IndIJK(i  ,j  ,k,iCOff,ijCOff)
        ijkC1 = IndIJK(i-1,j  ,k,iCOff,ijCOff)
        ijkC2 = IndIJK(i  ,j-1,k,iCOff,ijCOff)
        CALL AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,rcv )
      ENDDO
    ENDDO
  ENDDO

! finalize --------------------------------------------------------------------

  CALL DeregisterFunction( region%global )

! =============================================================================
!   Averaging subroutine
! =============================================================================

  CONTAINS

    SUBROUTINE AverageEdgeCells( ijkD,ijkC1,ijkC2,nCv,tcv )
      USE ModDataTypes
      IMPLICIT NONE

      INTEGER               :: l
      INTEGER               :: ijkD, ijkC1, ijkC2, nCv
      REAL(RFREAL), POINTER :: tcv(:,:)

      DO l=1,nCv
        tcv(l,ijkD) = 0.5_RFREAL*(tcv(l,ijkC1)+ tcv(l,ijkC2))
      ENDDO

    END SUBROUTINE AverageEdgeCells

END SUBROUTINE RADI_FloFlimSetCornEdgeCells

!******************************************************************************
!
! RCS Revision history:
!
! $Log: RADI_floFlimSetCornEdgeCells.F90,v $
! Revision 1.4  2008/12/06 08:44:38  mtcampbe
! Updated license.
!
! Revision 1.3  2008/11/19 22:17:50  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.2  2005/10/31 21:09:37  haselbac
! Changed specModel and SPEC_MODEL_NONE
!
! Revision 1.1  2004/09/30 17:49:10  wasistho
! prepared for full FLD radiation model
!
!
!
!******************************************************************************







