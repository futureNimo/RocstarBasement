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
! Purpose: Write optimal LES integrals in ASCII ROCFLU format.
!
! Description: None.
!
! Input:
!   pRegion     Pointer to region
!
! Output: None.
!
! Notes: None.
!
!******************************************************************************
!
! $Id: RFLU_WriteIntegrals1245OLES.F90,v 1.7 2008/12/06 08:44:30 mtcampbe Exp $
!
! Copyright: (c) 2001 by the University of Illinois
!
!******************************************************************************

SUBROUTINE RFLU_WriteIntegrals1245OLES(pRegion)

  USE ModGlobal, ONLY: t_global
  USE ModDataTypes
  USE ModParameters
  USE ModError
  USE ModBndPatch, ONLY: t_patch
  USE ModGrid, ONLY: t_grid
  USE ModDataStruct, ONLY: t_region    
  USE ModMPI
  
  USE RFLU_ModOLES

  IMPLICIT NONE
  
! ******************************************************************************
! Declarations and definitions
! ******************************************************************************  
   
! ==============================================================================
! Local variables
! ==============================================================================

  INTEGER :: errorFlag,hLoc,i,icmp,ic1l,ic2l,ic3l,ic4l,ifcp,iFile,iFun,j,k, & 
             l,m,nCells,vLoc
  CHARACTER(CHRLEN) :: iFileName,sectionString,RCSIdentString
  TYPE(t_grid), POINTER :: pGrid
  TYPE(t_global), POINTER :: global
  
! ==============================================================================
! Arguments
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion  
  
! ******************************************************************************
! Start, set pointer
! ******************************************************************************

  RCSIdentString = '$RCSfile: RFLU_WriteIntegrals1245OLES.F90,v $ $Revision: 1.7 $'

  pGrid => pRegion%grid

! ******************************************************************************
! Open file
! ******************************************************************************

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_WriteIntegrals1245OLES',&
  'RFLU_WriteIntegrals1245OLES.F90')
  
  nCells = SIZE(pGrid%fsOLES,1)

  IF ( global%myProcid == MASTERPROC .AND. &
       global%verbLevel > VERBOSE_NONE ) THEN 
    WRITE(STDOUT,'(A)') SOLVER_NAME  
    WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Writing optimal LES integrals...'
  END IF ! global%verbLevel

  WRITE(iFileName,'(A,I1)') TRIM(global%outDir)// & 
                            TRIM(global%casename)//'.int_',nCells

  iFile = IF_INTEG_OLES
  OPEN(iFile,FILE=iFileName,FORM="FORMATTED",STATUS="UNKNOWN", & 
       IOSTAT=errorFlag)
  global%error = errorFlag        
  IF ( global%error /= ERR_NONE ) THEN 
    CALL ErrorStop(global,ERR_FILE_OPEN,__LINE__,iFileName)
  END IF ! global%error  
      
! ==============================================================================
! Integral 1
! ==============================================================================

  IF ( global%myProcid == MASTERPROC .AND. &
       global%verbLevel > VERBOSE_LOW ) THEN 
    WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Integral 1...'
  END IF ! global%verbLevel

  sectionString = '# Integral 1'
  WRITE(iFile,'(A)') TRIM(sectionString)
  
!  DO icmp = 1,3
!    DO ifcp = 1,3
!      DO i = 1,3*nCells
!        WRITE(iFile,'(E15.6)') pGrid%int1OLES(icmp,ifcp,i)
!      END DO ! i
!    END DO ! ifcp
!  END DO ! icmp
  
  DO ifcp = 1,3
    DO ic1l = 1,nCells
      DO iFun = 1,9
        CALL RFLU_MapK2IJ(iFun,l,i)
        vLoc = RFLU_GetI1PosOLES(l,ic1l)
        
        WRITE(iFile,'(E15.6,3X,I2,3X,I2,2X,2(1X,I2),3X,I3)') & 
              pGrid%int1OLES(i,ifcp,vLoc),ifcp,ic1l,l,i,vLoc
      END DO ! iFun
    END DO ! ic1l
  END DO ! ifcp
  
! ==============================================================================
! Integral 2
! ==============================================================================

  IF ( global%myProcid == MASTERPROC .AND. &
       global%verbLevel > VERBOSE_LOW ) THEN 
    WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Integral 2...'
  END IF ! global%verbLevel

  sectionString = '# Integral 2'
  WRITE(iFile,'(A)') TRIM(sectionString)
  
!  DO ifcp = 1,3
!    DO i = 1,3*nCells
!      DO j = 1,3*nCells
!        WRITE(iFile,'(2(E15.6,1X))') pGrid%int20OLES(ifcp,i,j), & 
!                                     pGrid%int21OLES(ifcp,i,j)
!      END DO ! j
!    END DO ! i
!  END DO ! ifcp
  
  DO ifcp = 1,3
    DO ic1l = 1,nCells
      DO ic2l = 1,nCells
        DO iFun = 1,9
          CALL RFLU_MapK2IJ(iFun,l,j)   
          vLoc = RFLU_GetI1PosOLES(l,ic1l)
          hLoc = RFLU_GetLPosOLES(j,ic2l)   
          
          WRITE(iFile,1) & 
                pGrid%int20OLES(ifcp,vLoc,hLoc), & 
                pGrid%int21OLES(ifcp,vLoc,hLoc), & 
                ifcp,ic1l,ic2l,l,j,vLoc,hLoc                                  
        END DO ! iFun
      END DO ! ic2l    
    END DO ! ic1l    
  END DO ! ifcp
  
! ==============================================================================
! Integral 4
! ==============================================================================

  IF ( global%myProcid == MASTERPROC .AND. &
       global%verbLevel > VERBOSE_LOW ) THEN 
    WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Integral 4...'
  END IF ! global%verbLevel

  sectionString = '# Integral 4'
  WRITE(iFile,'(A)') TRIM(sectionString)
  
!  DO icmp = 1,3
!    DO ifcp = 1,3
!      DO i = 1,9*nCells*nCells
!        WRITE(iFile,'(3(E15.6,1X))') pGrid%int40OLES(icmp,ifcp,i), & 
!                                     pGrid%int41OLES(icmp,ifcp,i), &
!                                     pGrid%int42OLES(icmp,ifcp,i)
!      END DO ! i
!    END DO ! ifcp
!  END DO ! icmp  
  
  DO ifcp = 1,3
    DO ic1l = 1,nCells
      DO ic2l = 1,nCells
        DO iFun = 1,27
          CALL RFLU_MapL2IJK(iFun,l,m,i)    
          vLoc = RFLU_GetI4PosOLES(l,m,ic1l,ic2l,nCells)   
          
          WRITE(iFile,2) & 
                pGrid%int40OLES(i,ifcp,vLoc), & 
                pGrid%int41OLES(i,ifcp,vLoc), & 
                pGrid%int42OLES(i,ifcp,vLoc), & 
                ifcp,ic1l,ic2l,l,m,i,vLoc                             
        END DO ! iFun
      END DO ! ic2l    
    END DO ! ic1l    
  END DO ! ifcp  
  
! ==============================================================================
! Integral 5
! ==============================================================================

  IF ( global%myProcid == MASTERPROC .AND. &
       global%verbLevel > VERBOSE_LOW ) THEN 
    WRITE(STDOUT,'(A,3X,A)') SOLVER_NAME,'Integral 5...'
  END IF ! global%verbLevel

  sectionString = '# Integral 5'
  WRITE(iFile,'(A)') TRIM(sectionString)
  
!  DO ifcp = 1,3
!    DO i = 1,9*nCells*nCells
!      DO j = 1,9*nCells*nCells
!       WRITE(iFile,'(3(E15.6,1X))') pGrid%int50OLES(ifcp,i,j), & 
!                                    pGrid%int51OLES(ifcp,i,j), &
!                                    pGrid%int52OLES(ifcp,i,j)
!      END DO ! j
!    END DO ! i
!  END DO ! ifcp    

  DO ifcp = 1,3
    DO ic1l = 1,nCells
      DO ic2l = 1,nCells
        DO ic3l = 1,nCells
          DO ic4l = 1,nCells
            DO iFun = 1,81
              CALL RFLU_MapM2IJKL(iFun,l,m,j,k)
              vLoc = RFLU_GetQPosOLES(j,k,ic3l,ic4l,nCells)
              hLoc = RFLU_GetI4PosOLES(l,m,ic1l,ic2l,nCells) 

              WRITE(iFile,3) & 
                    pGrid%int50OLES(ifcp,vLoc,hLoc), & 
                    pGrid%int51OLES(ifcp,vLoc,hLoc), & 
                    pGrid%int52OLES(ifcp,vLoc,hLoc), & 
                    ifcp,ic1l,ic2l,ic3l,ic4l,l,m,j,k,vLoc,hLoc                                       
            END DO ! iFun
          END DO ! ic4l
        END DO ! ic3l
      END DO ! ic2l    
    END DO ! ic1l    
  END DO ! ifcp

! ==============================================================================
! Write footer
! ==============================================================================

  sectionString = '# End'
  WRITE(iFile,'(A)') TRIM(sectionString)  
  
! ==============================================================================
! Close file
! ==============================================================================

  CLOSE(iFile,IOSTAT=errorFlag)
  global%error = errorFlag   
  IF ( global%error /= ERR_NONE ) THEN 
    CALL ErrorStop(global,ERR_FILE_CLOSE,__LINE__,iFileName)
  END IF ! global%error
   
  IF ( global%myProcid == MASTERPROC .AND. &
       global%verbLevel > VERBOSE_NONE ) THEN   
    WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Writing optimal LES integrals done.'
  END IF ! global%verbLevel

  CALL DeregisterFunction(global)
    
1 FORMAT(2(E15.6,1X),2X,I2,2X,2(1X,I2),2X,2(1X,I2),2X,2(1X,I3))
2 FORMAT(3(E15.6,1X),2X,I2,2X,2(1X,I2),2X,3(1X,I2),3X,I3)
3 FORMAT(3(E15.6,1X),2X,I2,2X,4(1X,I2),2X,4(1X,I2),2X,2(1X,I3))        
       
! ******************************************************************************
! End
! ******************************************************************************
 
END SUBROUTINE RFLU_WriteIntegrals1245OLES


! ******************************************************************************
!
! RCS Revision history:
!
!   $Log: RFLU_WriteIntegrals1245OLES.F90,v $
!   Revision 1.7  2008/12/06 08:44:30  mtcampbe
!   Updated license.
!
!   Revision 1.6  2008/11/19 22:17:43  mtcampbe
!   Added Illinois Open Source License/Copyright
!
!   Revision 1.5  2006/12/15 13:27:02  haselbac
!   Fixed bug in format statement, found by ifort
!
!   Revision 1.4  2004/01/22 16:04:34  haselbac
!   Changed declaration to eliminate warning on ALC
!
!   Revision 1.3  2002/10/08 15:49:29  haselbac
!   {IO}STAT=global%error replaced by {IO}STAT=errorFlag - SGI problem
!
!   Revision 1.2  2002/10/05 19:35:41  haselbac
!   GENX integration: added outDir to file name
!
!   Revision 1.1  2002/09/09 16:28:02  haselbac
!   Initial revision
!
! ******************************************************************************







