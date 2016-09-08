PROGRAM readtraj
 
implicit none
integer, parameter :: memory=15000000
integer :: natom, ngroup1, ngroup2,&
           narg, length, firstframe, lastframe, stride, nclass, &
           nframes, dummyi, ntotat, memframes, ncicles, memlast, &
           iframe, icicle, nfrcicle, iatom, ii, jj, catom, &
           status, keystatus, ndim, iargc, lastatom, ntube, nsm

INTEGER:: i,j,l,np,ntim,m,maxrange,ntorig,k,natoms,n_snap,n_skip,kox,ia,n
INTEGER:: nmol,ntemp,itemp,iw,iw_start,res_prev,res,res_count
INTEGER:: kw,k1,k2,k3,k4

double precision :: side(3), t, sij,&
                    axis(3), mindist, maxdist, cmdist, mass1, mass2,&
                    cm1x, cm1y, cm1z, cm2x, cm2y, cm2z
real :: dummyr, rad, sx, sy, sz, rx,ry,rz
REAL:: POREL2,PORELENGTH
REAL:: temp1,temp2
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
integer, allocatable :: idw(:),id1(:),id2(:),id3(:),id4(:)
double precision, allocatable :: eps(:), sig(:), q(:), e(:), s(:), mass(:)
real, allocatable:: z(:,:),xdcd(:), ydcd(:), zdcd(:),zw(:),xw(:),yw(:),y(:,:),x(:,:)
real, allocatable:: xctr(:,:),yctr(:,:),zctr(:,:),x1(:,:),x2(:,:),y1(:,:),y2(:,:),z1(:,:),z2(:,:)
real, allocatable:: zmsd(:,:),zcoll(:,:)
character(len=4), allocatable :: class(:), segat(:), resat(:),&
                                 typeat(:), classat(:)
  

! 
! Open input file and read parameters
!
!      WRITE(*,*)'Enter the dcd trajectory file name, with the .dcd extension'
!      READ(*,*) name
!      WRITE(*,*)'Enter the pdb coordinate file name (for atom order), with the .pdb extension'
!      READ(*,*) name_pdb
!      WRITE(*,*)'Enter the number of water molecules (not water atoms!) per snapshot'
!      READ(*,*) np
!      WRITE(*,*)'Enter the pore length in A, from its top to its bottom (leave an A or so short of full length)'
!      READ(*,*) PORELENGTH
!      WRITE(*,*)'Enter the number of snapshots in the dcd file for analysis, beyond relaxation'
!      READ(*,*) n_snap
!      WRITE(*,*)'Enter the number of initial equilibration snapshots to be skipped'
!      READ(*,*) n_skip
!      WRITE(*,*)'Enter the number of snapshots for MSD consideration'
!      READ(*,*) ntim
!      WRITE(*,*)'Specify the pore radius (not diameter!)'
!      READ(*,*) rad
!      WRITE(*,*)'Enter the number of collective MSD points to be computed'
!      READ(*,*) nsm


!      WRITE(*,*)'zmin'
!      READ(*,*) z1
!      WRITE(*,*)'zmax'
!      READ(*,*) z2
!

      name_pdb = 'Acuaporin_beta.pdb'
      name = 'zero_300.dcd'
      np = 15104
      PORELENGTH = 25.0
      n_snap = 285
      n_skip = 5 
      ntim = 285
      rad = 2.0
      nsm = 40

      ctmp = TRIM(adjustl(name))
      OPEN(UNIT=1, FILE=TRIM(adjustl(ctmp)), STATUS='OLD', FORM='UNFORMATTED', ACCESS='SEQUENTIAL' )
!
      ctmp = TRIM(adjustl(name_pdb))
      OPEN(UNIT=11, FILE=TRIM(adjustl(ctmp)), STATUS='OLD', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
!
      ctmp_msd = TRIM(adjustl(name))//'_msd1.out'
      OPEN(UNIT=21, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_msd2.out'
      OPEN(UNIT=22, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_msd3.out'
      OPEN(UNIT=23, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
      ctmp_msd = TRIM(adjustl(name))//'_msd4.out'
      OPEN(UNIT=24, FILE=TRIM(adjustl(ctmp_msd)), STATUS='UNKNOWN', FORM='FORMATTED', ACCESS='SEQUENTIAL' )
!
      ALLOCATE ( idw(50000),id1(50000),id2(50000),id3(50000),id4(50000) )
 
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
  READ(11,*)
!write(*,*)'hi'
  DO i=1,natoms


!    READ(11,'(a6,a5,1x,a4,a6,i4)')hetatm,dummy,atomtype,moltype,res
!    write(*,*)hetatm,dummy,atomtype,moltype,res

    READ(11,'(a6,a5,1x,a4,a6,i4,4x,3f8.3,2f6.2,6x,a4,1x,a1)')hetatm,dummy,atomtype,moltype,res,rx, &
                                                              ry,rz,temp1,temp2,atomtype2,atomtype_tmp




    IF(NINT(temp2)==1)THEN
      k1 = k1 + 1
      id1(k1) = i
    ELSEIF(NINT(temp2)==2)THEN
      k2 = k2 + 1
      id2(k2) = i       
    ELSEIF(NINT(temp2)==3)THEN
      k3 = k3 + 1
      id3(k3) = i       
    ELSEIF(NINT(temp2)==4)THEN
      k4 = k4 + 1
      id4(k4) = i       
    ELSEIF(NINT(temp2)==5)THEN
      kw = kw + 1
      idw(kw) = i       
    ENDIF

  END DO   ! Loop to read in pdb file

!
      ALLOCATE ( z(np,n_snap),ka(4,np),xdcd(natoms),ydcd(natoms),zdcd(natoms),zw(3),nt0(4,np),ntmax(4,np) )
      ALLOCATE ( x(np,n_snap),xw(3),yw(3),y(np,n_snap) )
      ALLOCATE ( xctr(4,n_snap),yctr(4,n_snap),zctr(4,n_snap),x1(4,n_snap),x2(4,n_snap),y1(4,n_snap), &
                 y2(4,n_snap),z1(4,n_snap),z2(4,n_snap),nmsd(4,np),msd(4),npart(4),zmsd(4,NTIM),zcoll(4,ntim) )

  do j = 1,n_skip    
    read(1) side(1), t, side(2), t, t, side(3)

!    write(*,*)side(1),side(2),side(3)
!    WRITE(*,*)t

    read(1) (xdcd(k), k = 1, natoms)
    read(1) (ydcd(k), k = 1, natoms)            
    read(1) (zdcd(k), k = 1, natoms)
  end do


  do j = 1,n_snap    
    read(1) side(1), t, side(2), t, t, side(3)

!    write(*,*)side(1),side(2),side(3)
!    WRITE(*,*)t,j

    read(1) (xdcd(k), k = 1, natoms)
    read(1) (ydcd(k), k = 1, natoms)            
    read(1) (zdcd(k), k = 1, natoms)

!    do i=1,natoms-3
!      xdcd(i) = xdcd(i+2)
!      ydcd(i) = ydcd(i+2)
!      zdcd(i) = zdcd(i+2)
!    end do



    do i=1,np
      kox = idw(3*i-2)
      ia = 0
      do k=kox,kox+2
        ia = ia + 1
        xw(ia) = xdcd(k)
        yw(ia) = ydcd(k)
        zw(ia) = zdcd(k)
      end do
      z(i,j) = 0.8881 * zw(1) + 0.055506 * ( zw(2) + zw(3) )    
      x(i,j) = 0.8881 * xw(1) + 0.055506 * ( xw(2) + xw(3) ) 
      y(i,j) = 0.8881 * yw(1) + 0.055506 * ( yw(2) + yw(3) ) 

!      x(i,j) = xw(1)
!      y(i,j) = yw(1)
!      z(i,j) = zw(1) 

!      if((i==1).or.(i==np))then
!        write(*,*)i,j,kox
!        write(*,*)xw(1),xw(2),xw(3),x(i,j)
!        write(*,*)yw(1),yw(2),yw(3),y(i,j) 
!        write(*,*)zw(1),zw(2),zw(3),z(i,j)
!      endif 

!      if((i==3744).or.(i==3806))then
!        write(*,*)i,j,kox
!        write(*,*)xw(1),xw(2),xw(3),x(i,j)
!        write(*,*)yw(1),yw(2),yw(3),y(i,j) 
!        write(*,*)zw(1),zw(2),zw(3),z(i,j)
!      endif

!      if((i==3868).or.(i==3930))then
!        write(*,*)i,j,kox
!        write(*,*)xw(1),xw(2),xw(3),x(i,j)
!        write(*,*)yw(1),yw(2),yw(3),y(i,j) 
!        write(*,*)zw(1),zw(2),zw(3),z(i,j)
!      endif

    end do

!
    sx = 0.0
    sy = 0.0
    sz = 0.0
    do k=1,k1
      sx = sx + xdcd(id1(k))
      sy = sy + ydcd(id1(k))
      sz = sz + zdcd(id1(k))
    end do
    sx = sx / 263.0
    sy = sy / 263.0
    sz = sz / 263.0
    xctr(1,j) = sx
    yctr(1,j) = sy
    zctr(1,j) = sz
    x1(1,j) = sx - rad
    x2(1,j) = sx + rad
    y1(1,j) = sy - rad
    y2(1,j) = sy + rad
    z1(1,j) = sz - POREL2
    z2(1,j) = sz + POREL2
!
    sx = 0.0
    sy = 0.0
    sz = 0.0
    do k=1,k2
      sx = sx + xdcd(id2(k))
      sy = sy + ydcd(id2(k))
      sz = sz + zdcd(id2(k))
    end do
    sx = sx / 263.0
    sy = sy / 263.0
    sz = sz / 263.0
    xctr(2,j) = sx
    yctr(2,j) = sy
    zctr(2,j) = sz
    x1(2,j) = sx - rad
    x2(2,j) = sx + rad
    y1(2,j) = sy - rad
    y2(2,j) = sy + rad
    z1(2,j) = sz - POREL2
    z2(2,j) = sz + POREL2
!
    sx = 0.0
    sy = 0.0
    sz = 0.0
    do k=1,k3
      sx = sx + xdcd(id3(k))
      sy = sy + ydcd(id3(k))
      sz = sz + zdcd(id3(k))
    end do
    sx = sx / 263.0
    sy = sy / 263.0
    sz = sz / 263.0
    xctr(3,j) = sx
    yctr(3,j) = sy
    zctr(3,j) = sz
    x1(3,j) = sx - rad
    x2(3,j) = sx + rad
    y1(3,j) = sy - rad
    y2(3,j) = sy + rad
    z1(3,j) = sz - POREL2
    z2(3,j) = sz + POREL2
!
    sx = 0.0
    sy = 0.0
    sz = 0.0
    do k=1,k4
      sx = sx + xdcd(id4(k))
      sy = sy + ydcd(id4(k))
      sz = sz + zdcd(id4(k))
    end do
    sx = sx / 263.0
    sy = sy / 263.0
    sz = sz / 263.0
    xctr(4,j) = sx
    yctr(4,j) = sy
    zctr(4,j) = sz
    x1(4,j) = sx - rad
    x2(4,j) = sx + rad
    y1(4,j) = sy - rad
    y2(4,j) = sy + rad
    z1(4,j) = sz - POREL2
    z2(4,j) = sz + POREL2
!
!    write(*,*)'x1',x1(1,j),x1(2,j),x1(3,j),x1(4,j)
!    write(*,*)'x2',x2(1,j),x2(2,j),x2(3,j),x2(4,j)
!    write(*,*)'y1',y1(1,j),y1(2,j),y1(3,j),y1(4,j)
!    write(*,*)'y2',y2(1,j),y2(2,j),y2(3,j),y2(4,j)
!    write(*,*)'z1',z1(1,j),z1(2,j),z1(3,j),z1(4,j)  
!    write(*,*)'z2',z2(1,j),z2(2,j),z2(3,j),z2(4,j)
         
  end do   ! j loop over n_snap








!  write(*,*) 'np', np, natoms  

!  do i=1,6
!    WRITE(*,*) xdcd(i),ydcd(i),zdcd(i)
!  end do

!  do i=natoms-5,natoms
!    WRITE(*,*) xdcd(i),ydcd(i),zdcd(i)
!  end do

  ka = 0
  nt0 = 0
  ntmax = 0
  zmsd = 0.0



  do k=1,4   

!  write(*,*)'k',k

       DO J=1,NTIM
         ntube = 0
		 zcoll(k,j) = 0.d0
         DO I=1,NP
!           IF(KA(k,I).EQ.1) GO TO 90 
           if( (x(i,j).gt.x1(k,j)).and.(x(i,j).lt.x2(k,j)) ) then
             if( (y(i,j).gt.y1(k,j)).and.(y(i,j).lt.y2(k,j)) ) then
!write(*,*)'hi',k,i,j,x(i,j),y(i,j),z(i,j),z1(k,j),z2(k,j)
               IF( (Z(I,J).gt.z1(k,j)) .and. (z(i,j).lt.z2(i,j)) ) THEN
!write(*,*)'middle',k,i,j,x(i,j),y(i,j),z(i,j)
                 ntube = ntube + 1  
                 zcoll(k,j) = zcoll(k,j) + z(i,j)
               ENDIF
             endif
           endif 
!90         CONTINUE
         ENDDO
         IF(ntube == 0)THEN
		   WRITE(*,*)'No waters in tube',k,'at snapshot',j,'.... Exiting now'
           STOP
		 ENDIF 
         zcoll(k,j) = zcoll(k,j)/REAL(ntube)
       ENDDO
!
! COMPUTE MSD 

       DO N=1,nsm
         ZMSD(k,N) = 0.0
       ENDDO
!
         DO ia=2,nsm
           NTORIG = ia-1
           DO L=1,nsm
             ZMSD(k,L) = (Zcoll(k,NTORIG+L)-Zcoll(k,NTORIG))**2 + ZMSD(k,L)
           ENDDO
         ENDDO
  end do    ! k loop
!
! AVERAGING
       DO L=1,nsm
         WRITE(21,*) L, ZMSD(1,L)/(real(nsm))
       ENDDO
       DO L=1,nsm
         WRITE(22,*) L, ZMSD(2,L)/(FLOAT(nsm))
       ENDDO
       DO L=1,nsm
         WRITE(23,*) L, ZMSD(3,L)/(FLOAT(nsm))
       ENDDO
       DO L=1,nsm
         WRITE(24,*) L, ZMSD(4,L)/(FLOAT(nsm))
       ENDDO

end program readtraj
