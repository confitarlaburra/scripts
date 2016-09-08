PROGRAM readtraj
 
implicit none
integer, parameter :: memory=15000000
integer :: natom, ngroup1, ngroup2,&
           narg, length, firstframe, lastframe, stride, nclass, &
           nframes, dummyi, ntotat, memframes, ncicles, memlast, &
           iframe, icicle, nfrcicle, iatom, ii, jj, catom, &
           status, keystatus, ndim, iargc, lastatom

INTEGER:: i,j,l,np,ntim,m,maxrange,ntorig,k,natoms,n_snap,n_skip,kox,ia,n
INTEGER:: nmol,ntemp,itemp,iw,iw_start,res_prev,res,res_count
INTEGER:: kw,k1,k2,k3,k4,nres

double precision :: side(3), t, sij,&
                    axis(3), mindist, maxdist, cmdist, mass1, mass2,&
                    cm1x, cm1y, cm1z, cm2x, cm2y, cm2z
real :: dummyr, rad, sx, sy, sz
REAL:: POREL2,PORELENGTH
REAL:: temp1,temp2,convdip
character(len=200) :: groupfile, line, record, value, keyword,&
                      dcdfile, file, inputfile, output, psffile

	CHARACTER (LEN = 1):: atomtype_tmp
	CHARACTER (LEN = 6):: moltype
    CHARACTER (LEN = 6):: hetatm
	CHARACTER (LEN = 4):: atomtype
	CHARACTER (LEN = 5):: dummy
	CHARACTER (LEN = 8):: atemp
	CHARACTER (LEN = 4):: atomtype2
	CHARACTER (LEN = 2):: atype_dl(3,16)
CHARACTER (LEN = 60):: name,ctmp,ctmp_name,ctmp_name_tmp,name_top,ctmp_msd,name_pdb
CHARACTER (LEN = 12):: ctmp1,zero

character(len=4) :: dummyc
logical :: periodic, readfromdcd, dcdaxis, centeratom      

! Allocatable arrays

integer, allocatable :: group1(:), group2(:), ka(:,:), nt0(:,:), ntmax(:,:), nmsd(:,:),msd(:),npart(:)
integer, allocatable :: idw(:),id1(:),id2(:),id3(:),id4(:),nra(:),idr(:,:,:)
double precision, allocatable :: eps(:), sig(:), q(:), e(:), s(:), mass(:)
real, allocatable:: z(:,:),xdcd(:), ydcd(:), zdcd(:),zw(:),xw(:),yw(:),y(:,:),x(:,:)
real, allocatable:: xctr(:,:),yctr(:,:),zctr(:,:),x1(:,:),x2(:,:),y1(:,:),y2(:,:),z1(:,:),z2(:,:)
real, allocatable:: zmsd(:,:),mr(:,:),qr(:,:),mrtot(:),xcm(:,:),ycm(:,:),zcm(:,:),rx(:,:,:),ry(:,:,:),rz(:,:,:)
real, allocatable:: xu(:,:),yu(:,:),zu(:,:),utot(:,:),uzcos(:,:),uycos(:,:)
character(len=4), allocatable :: class(:), segat(:), resat(:),&
                                 typeat(:), classat(:)
  

! 
! Open input file and read parameters
!
      WRITE(*,*)'Enter the dcd trajectory file name, with the .dcd extension'
      READ(*,*) name
      WRITE(*,*)'Enter the pdb coordinate file name (for atom order), with the .pdb extension'
      READ(*,*) name_pdb
      WRITE(*,*)'Enter the number of water molecules (not water atoms!) per snapshot'
      READ(*,*) np
      WRITE(*,*)'Enter the pore length in A, from its top to its bottom'
      READ(*,*) PORELENGTH
      WRITE(*,*)'Enter the number of snapshots in the dcd file for analysis, beyond relaxation'
      READ(*,*) n_snap
      WRITE(*,*)'Enter the number of initial equilibration snapshots to be skipped'
      READ(*,*) n_skip
      WRITE(*,*)'Enter the number of snapshots for MSD consideration'
      READ(*,*) ntim
      WRITE(*,*)'Specify the pore radius (not diameter!)'
      READ(*,*) rad


!      WRITE(*,*)'zmin'
!      READ(*,*) z1
!      WRITE(*,*)'zmax'
!      READ(*,*) z2
!

!      name_pdb = 'Acuaporin_beta.pdb'
!      name = 'AQP4_zero.dcd'
!      np = 15104
!      PORELENGTH = 25.0
!      n_snap = 95000
!      n_skip = 5000 
!      ntim = 95000
!      rad = 2.0

      nres = 15
      convdip = 4.78

      ctmp = TRIM(adjustl(name))
      OPEN(UNIT=1, FILE=TRIM(adjustl(ctmp)), STATUS='OLD', FORM='UNFORMATTED', ACCESS='SEQUENTIAL' )
!
      ctmp = TRIM(adjustl(name_pdb))
      OPEN(UNIT=11, FILE=TRIM(adjustl(ctmp)), STATUS='OLD', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
!
      OPEN(UNIT=12, FILE='id_pore_A.out', STATUS='OLD', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      OPEN(UNIT=13, FILE='id_pore_B.out', STATUS='OLD', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      OPEN(UNIT=14, FILE='id_pore_C.out', STATUS='OLD', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      OPEN(UNIT=15, FILE='id_pore_D.out', STATUS='OLD', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      OPEN(UNIT=16, FILE='charge_pore.out', STATUS='OLD', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      OPEN(UNIT=17, FILE='mass_pore.out', STATUS='OLD', FORM='FORMATTED', ACCESS='SEQUENTIAL' )

!
      ctmp_msd = TRIM(adjustl(name))//'_utot_A.out'
      OPEN(UNIT=21, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_utot_B.out'
      OPEN(UNIT=22, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_utot_C.out'
      OPEN(UNIT=23, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_utot_D.out'
      OPEN(UNIT=24, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
!
      ctmp_msd = TRIM(adjustl(name))//'_ux_A.out'
      OPEN(UNIT=31, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_ux_B.out'
      OPEN(UNIT=32, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_ux_C.out'
      OPEN(UNIT=33, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_ux_D.out'
      OPEN(UNIT=34, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
!
      ctmp_msd = TRIM(adjustl(name))//'_uy_A.out'
      OPEN(UNIT=41, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_uy_B.out'
      OPEN(UNIT=42, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_uy_C.out'
      OPEN(UNIT=43, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_uy_D.out'
      OPEN(UNIT=44, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
!
      ctmp_msd = TRIM(adjustl(name))//'_uz_A.out'
      OPEN(UNIT=51, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_uz_B.out'
      OPEN(UNIT=52, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_uz_C.out'
      OPEN(UNIT=53, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_uz_D.out'
      OPEN(UNIT=54, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
!
      ctmp_msd = TRIM(adjustl(name))//'_uzcos_A.out'
      OPEN(UNIT=61, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_uzcos_B.out'
      OPEN(UNIT=62, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_uzcos_C.out'
      OPEN(UNIT=63, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_uzcos_D.out'
      OPEN(UNIT=64, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
!
      ctmp_msd = TRIM(adjustl(name))//'_uycos_A.out'
      OPEN(UNIT=71, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_uycos_B.out'
      OPEN(UNIT=72, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_uycos_C.out'
      OPEN(UNIT=73, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_uycos_D.out'
      OPEN(UNIT=74, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
!
      ALLOCATE ( idw(50000),id1(50000),id2(50000),id3(50000),id4(50000),nra(nres),mr(nres,25),qr(nres,25) )
      ALLOCATE( idr(4,nres,25),mrtot(nres) )
 
!  write(*,*)n_snap,natoms

read(1) dummyc, nframes, (dummyi,i=1,8), dummyr, (dummyi,i=1,9)

write(*,*)dummyc, nframes

read(1) dummyi, dummyr

write(*,*)dummyc, dummyr

read(1) ntotat

write(*,*)ntotat
  natoms = ntotat

  POREL2 = PORELENGTH/2.0
!
  kw = 0
  k1 = 0
  k2 = 0
  k3 = 0
  k4 = 0
!
  mrtot = 0.d0

  DO i=1,nres
    READ(17,*)nra(i)
    DO j=1,nra(i)
      READ(17,*) mr(i,j)
      mrtot(i) = mrtot(i)+mr(i,j)
!write(*,*)i,j,mr(i,j)
    END DO
!write(*,*)i,mrtot(i)
  END DO


  DO i=1,nres
    READ(16,*)
    read(16,*) (qr(i,j), j = 1, nra(i))
!    DO j=1,nra(i)
!write(*,*)i,j,qr(i,j)
!    END DO
  END DO


  DO i=1,nres
    READ(12,*)
    read(12,*) (idr(1,i,j), j = 1, nra(i))
!    DO j=1,nra(i)
!write(*,*)1,i,j,idr(1,i,j)
!    END DO
  END DO

  DO i=1,nres
    READ(13,*)
    read(13,*) (idr(2,i,j), j = 1, nra(i))
!    DO j=1,nra(i)
!write(*,*)2,i,j,idr(2,i,j)
!    END DO
  END DO

  DO i=1,nres
    READ(14,*)
    read(14,*) (idr(3,i,j), j = 1, nra(i))
!    DO j=1,nra(i)
!write(*,*)3,i,j,idr(3,i,j)
!    END DO
  END DO

  DO i=1,nres
    READ(15,*)
    read(15,*) (idr(4,i,j), j = 1, nra(i))
!    DO j=1,nra(i)
!write(*,*)4,i,j,idr(4,i,j)
!    END DO
  END DO

!
      ALLOCATE ( rz(4,nres,25),ry(4,nres,25),rx(4,nres,25),xdcd(natoms),ydcd(natoms),zdcd(natoms),zw(3),nt0(4,np),ntmax(4,np) )
      ALLOCATE ( x(np,n_snap),xw(3),yw(3),y(np,n_snap),xcm(4,nres),ycm(4,nres),zcm(4,nres) )
      ALLOCATE ( xctr(4,n_snap),yctr(4,n_snap),zctr(4,n_snap),x1(4,n_snap),x2(4,n_snap),y1(4,n_snap), &
                 y2(4,n_snap),z1(4,n_snap),z2(4,n_snap),nmsd(4,np),msd(4),npart(4),zmsd(4,NTIM), &
                 xu(4,nres),yu(4,nres),zu(4,nres),utot(4,nres),uzcos(4,nres),uycos(4,nres) )

  do j = 1,n_skip    
    read(1) side(1), t, side(2), t, t, side(3)

!    write(*,*)side(1),side(2),side(3)
!    WRITE(*,*)t

    read(1) (xdcd(k), k = 1, natoms)
    read(1) (ydcd(k), k = 1, natoms)            
    read(1) (zdcd(k), k = 1, natoms)
  end do


  do ia = 1,n_snap    
    read(1) side(1), t, side(2), t, t, side(3)

    write(*,*)side(1),side(2),side(3)
    WRITE(*,*)t,j

    read(1) (xdcd(k), k = 1, natoms)
    read(1) (ydcd(k), k = 1, natoms)            
    read(1) (zdcd(k), k = 1, natoms)

!    do i=1,natoms-3
!      xdcd(i) = xdcd(i+2)
!      ydcd(i) = ydcd(i+2)
!      zdcd(i) = zdcd(i+2)
!    end do

!    write(*,*)xdcd(1),ydcd(1),zdcd(1)
!    write(*,*)xdcd(natoms),ydcd(natoms),zdcd(natoms)

    xcm = 0.d0
    ycm = 0.d0
    zcm = 0.d0
    xu = 0.d0
    yu = 0.d0
    zu = 0.d0

    do k=1,4
      DO i=1,nres
        DO j=1,nra(i)
          rx(k,i,j) = xdcd(idr(k,i,j))
          ry(k,i,j) = ydcd(idr(k,i,j))
          rz(k,i,j) = zdcd(idr(k,i,j))
          xcm(k,i) = xcm(k,i) + mr(i,j)*rx(k,i,j)
          ycm(k,i) = ycm(k,i) + mr(i,j)*ry(k,i,j)
          zcm(k,i) = zcm(k,i) + mr(i,j)*rz(k,i,j)
!write(*,*)k,i,j,rx(k,i,j),ry(k,i,j),rz(k,i,j),mr(i,j)
        END DO
        xcm(k,i) = xcm(k,i)/mrtot(i)
        ycm(k,i) = ycm(k,i)/mrtot(i)
        zcm(k,i) = zcm(k,i)/mrtot(i)
!write(*,*)'com',k,i,xcm(k,i),ycm(k,i),zcm(k,i)
        DO j=1,nra(i)
          rx(k,i,j) = xdcd(idr(k,i,j))
          ry(k,i,j) = ydcd(idr(k,i,j))
          rz(k,i,j) = zdcd(idr(k,i,j))
          xu(k,i) = xu(k,i) + qr(i,j)*(rx(k,i,j)-xcm(k,i))
          yu(k,i) = yu(k,i) + qr(i,j)*(ry(k,i,j)-ycm(k,i))
          zu(k,i) = zu(k,i) + qr(i,j)*(rz(k,i,j)-zcm(k,i))
        END DO
        xu(k,i) = convdip * xu(k,i)
        yu(k,i) = convdip * yu(k,i)
        zu(k,i) = convdip * zu(k,i)
        utot(k,i) = sqrt(xu(k,i)**2+yu(k,i)**2+zu(k,i)**2)
        uzcos(k,i) = zu(k,i)/utot(k,i)
        uycos(k,i) = yu(k,i)/utot(k,i)        
!write(*,*)k,i,xu(k,i),yu(k,i),zu(k,i),utot(k,i),ucos(k,i)
      END DO
    END DO
!
    WRITE(21,'(i7,15(1x,g10.5))')ia,utot(1,1),utot(1,2),utot(1,3), &
       utot(1,4),utot(1,5),utot(1,6),utot(1,7),utot(1,8),utot(1,9), &
       utot(1,10),utot(1,11),utot(1,12),utot(1,13),utot(1,14),utot(1,15)
    WRITE(22,'(i7,15(1x,g10.5))')ia,utot(2,1),utot(2,2),utot(2,3), &
       utot(2,4),utot(2,5),utot(2,6),utot(2,7),utot(2,8),utot(2,9), &
       utot(2,10),utot(2,11),utot(2,12),utot(2,13),utot(2,14),utot(2,15)
    WRITE(23,'(i7,15(1x,g10.5))')ia,utot(3,1),utot(3,2),utot(3,3), &
       utot(3,4),utot(3,5),utot(3,6),utot(3,7),utot(3,8),utot(3,9), &
       utot(3,10),utot(3,11),utot(3,12),utot(3,13),utot(3,14),utot(3,15)
    WRITE(24,'(i7,15(1x,g10.5))')ia,utot(4,1),utot(4,2),utot(4,3), &
       utot(4,4),utot(4,5),utot(4,6),utot(4,7),utot(4,8),utot(4,9), &
       utot(4,10),utot(4,11),utot(4,12),utot(4,13),utot(4,14),utot(4,15)
!
    WRITE(31,'(i7,15(1x,g12.6))')ia,xu(1,1),xu(1,2),xu(1,3), &
       xu(1,4),xu(1,5),xu(1,6),xu(1,7),xu(1,8),xu(1,9), &
       xu(1,10),xu(1,11),xu(1,12),xu(1,13),xu(1,14),xu(1,15)
    WRITE(32,'(i7,15(1x,g12.6))')ia,xu(2,1),xu(2,2),xu(2,3), &
       xu(2,4),xu(2,5),xu(2,6),xu(2,7),xu(2,8),xu(2,9), &
       xu(2,10),xu(2,11),xu(2,12),xu(2,13),xu(2,14),xu(2,15)
    WRITE(33,'(i7,15(1x,g12.6))')ia,xu(3,1),xu(3,2),xu(3,3), &
       xu(3,4),xu(3,5),xu(3,6),xu(3,7),xu(3,8),xu(3,9), &
       xu(3,10),xu(3,11),xu(3,12),xu(3,13),xu(3,14),xu(3,15)
    WRITE(34,'(i7,15(1x,g12.6))')ia,xu(4,1),xu(4,2),xu(4,3), &
       xu(4,4),xu(4,5),xu(4,6),xu(4,7),xu(4,8),xu(4,9), &
       xu(4,10),xu(4,11),xu(4,12),xu(4,13),xu(4,14),xu(4,15)
!
    WRITE(41,'(i7,15(1x,g12.6))')ia,yu(1,1),yu(1,2),yu(1,3), &
       yu(1,4),yu(1,5),yu(1,6),yu(1,7),yu(1,8),yu(1,9), &
       yu(1,10),yu(1,11),yu(1,12),yu(1,13),yu(1,14),yu(1,15)
    WRITE(42,'(i7,15(1x,g12.6))')ia,yu(2,1),yu(2,2),yu(2,3), &
       yu(2,4),yu(2,5),yu(2,6),yu(2,7),yu(2,8),yu(2,9), &
       yu(2,10),yu(2,11),yu(2,12),yu(2,13),yu(2,14),yu(2,15)
    WRITE(43,'(i7,15(1x,g12.6))')ia,yu(3,1),yu(3,2),yu(3,3), &
       yu(3,4),yu(3,5),yu(3,6),yu(3,7),yu(3,8),yu(3,9), &
       yu(3,10),yu(3,11),yu(3,12),yu(3,13),yu(3,14),yu(3,15)
    WRITE(44,'(i7,15(1x,g12.6))')ia,yu(4,1),yu(4,2),yu(4,3), &
       yu(4,4),yu(4,5),yu(4,6),yu(4,7),yu(4,8),yu(4,9), &
       yu(4,10),yu(4,11),yu(4,12),yu(4,13),yu(4,14),yu(4,15)
!
    WRITE(51,'(i7,15(1x,g12.6))')ia,zu(1,1),zu(1,2),zu(1,3), &
       zu(1,4),zu(1,5),zu(1,6),zu(1,7),zu(1,8),zu(1,9), &
       zu(1,10),zu(1,11),zu(1,12),zu(1,13),zu(1,14),zu(1,15)
    WRITE(52,'(i7,15(1x,g12.6))')ia,zu(2,1),zu(2,2),zu(2,3), &
       zu(2,4),zu(2,5),zu(2,6),zu(2,7),zu(2,8),zu(2,9), &
       zu(2,10),zu(2,11),zu(2,12),zu(2,13),zu(2,14),zu(2,15)
    WRITE(53,'(i7,15(1x,g12.6))')ia,zu(3,1),zu(3,2),zu(3,3), &
       zu(3,4),zu(3,5),zu(3,6),zu(3,7),zu(3,8),zu(3,9), &
       zu(3,10),zu(3,11),zu(3,12),zu(3,13),zu(3,14),zu(3,15)
    WRITE(54,'(i7,15(1x,g12.6))')ia,zu(4,1),zu(4,2),zu(4,3), &
       zu(4,4),zu(4,5),zu(4,6),zu(4,7),zu(4,8),zu(4,9), &
       zu(4,10),zu(4,11),zu(4,12),zu(4,13),zu(4,14),zu(4,15)
!
    WRITE(61,'(i7,15(1x,g12.6))')ia,uzcos(1,1),uzcos(1,2),uzcos(1,3), &
       uzcos(1,4),uzcos(1,5),uzcos(1,6),uzcos(1,7),uzcos(1,8),uzcos(1,9), &
       uzcos(1,10),uzcos(1,11),uzcos(1,12),uzcos(1,13),uzcos(1,14),uzcos(1,15)
    WRITE(62,'(i7,15(1x,g12.6))')ia,uzcos(2,1),uzcos(2,2),uzcos(2,3), &
       uzcos(2,4),uzcos(2,5),uzcos(2,6),uzcos(2,7),uzcos(2,8),uzcos(2,9), &
       uzcos(2,10),uzcos(2,11),uzcos(2,12),uzcos(2,13),uzcos(2,14),uzcos(2,15)
    WRITE(63,'(i7,15(1x,g12.6))')ia,uzcos(3,1),uzcos(3,2),uzcos(3,3), &
       uzcos(3,4),uzcos(3,5),uzcos(3,6),uzcos(3,7),uzcos(3,8),uzcos(3,9), &
       uzcos(3,10),uzcos(3,11),uzcos(3,12),uzcos(3,13),uzcos(3,14),uzcos(3,15)
    WRITE(64,'(i7,15(1x,g12.6))')ia,uzcos(4,1),uzcos(4,2),uzcos(4,3), &
       uzcos(4,4),uzcos(4,5),uzcos(4,6),uzcos(4,7),uzcos(4,8),uzcos(4,9), &
       uzcos(4,10),uzcos(4,11),uzcos(4,12),uzcos(4,13),uzcos(4,14),uzcos(4,15)
!
    WRITE(71,'(i7,15(1x,g12.6))')ia,uycos(1,1),uycos(1,2),uycos(1,3), &
       uycos(1,4),uycos(1,5),uycos(1,6),uycos(1,7),uycos(1,8),uycos(1,9), &
       uycos(1,10),uycos(1,11),uycos(1,12),uycos(1,13),uycos(1,14),uycos(1,15)
    WRITE(72,'(i7,15(1x,g12.6))')ia,uycos(2,1),uycos(2,2),uycos(2,3), &
       uycos(2,4),uycos(2,5),uycos(2,6),uycos(2,7),uycos(2,8),uycos(2,9), &
       uycos(2,10),uycos(2,11),uycos(2,12),uycos(2,13),uycos(2,14),uycos(2,15)
    WRITE(73,'(i7,15(1x,g12.6))')ia,uycos(3,1),uycos(3,2),uycos(3,3), &
       uycos(3,4),uycos(3,5),uycos(3,6),uycos(3,7),uycos(3,8),uycos(3,9), &
       uycos(3,10),uycos(3,11),uycos(3,12),uycos(3,13),uycos(3,14),uycos(3,15)
    WRITE(74,'(i7,15(1x,g12.6))')ia,uycos(4,1),uycos(4,2),uycos(4,3), &
       uycos(4,4),uycos(4,5),uycos(4,6),uycos(4,7),uycos(4,8),uycos(4,9), &
       uycos(4,10),uycos(4,11),uycos(4,12),uycos(4,13),uycos(4,14),uycos(4,15)
!
  end do   ! j loop over n_snap

end program readtraj
