
module ModGITM

  use ModSizeGitm
  use ModPlanet

  implicit none

  real :: dt = 0.0

  integer :: iCommGITM, iProc, nProcs

  real, allocatable :: dLonDist_GB(:,:,:,:)
  real, allocatable :: InvDLonDist_GB(:,:,:,:)
  real, allocatable :: dLonDist_FB(:,:,:,:)
  real, allocatable :: InvDLonDist_FB(:,:,:,:)
  real, allocatable :: dLatDist_GB(:,:,:,:)
  real, allocatable :: InvDLatDist_GB(:,:,:,:)
  real, allocatable :: dLatDist_FB(:,:,:,:)
  real, allocatable :: InvDLatDist_FB(:,:,:,:)
  real, allocatable :: Altitude_GB(:,:,:,:)
  real, allocatable :: dAlt_GB(:,:,:,:)
  real, allocatable :: RadialDistance_GB(:,:,:,:)
  real, allocatable :: InvRadialDistance_GB(:,:,:,:)
  real, allocatable :: Gravity_GB(:,:,:,:)
  real, allocatable :: CellVolume(:,:,:,:)

  ! Topography
  real, allocatable :: dAltDLon_CB(:,:,:,:)
  real, allocatable :: dAltDLat_CB(:,:,:,:)

  real, dimension(-1:nLons+2, nBlocksMax) :: Longitude
  real, dimension(-1:nLats+2, nBlocksMax) :: Latitude, TanLatitude, CosLatitude

  real, dimension(nLons, nBlocksMax) :: GradLonM_CB, GradLon0_CB, GradLonP_CB
  real, dimension(nLats, nBlocksMax) :: GradLatM_CB, GradLat0_CB, GradLatP_CB
  real, dimension(nLons,nLats,nBlocksMax) :: Altzero

  real, allocatable :: Rho(:,:,:,:)
  real, allocatable :: Temperature(:,:,:,:)
  real, allocatable :: InvScaleHeight(:,:,:,:)
  real, allocatable :: Pressure(:,:,:,:)
  real, allocatable :: NDensity(:,:,:,:)
  real, allocatable :: eTemperature(:,:,:,:)
  real, allocatable :: ITemperature(:,:,:,:)
  real, allocatable :: IPressure(:,:,:,:)
  real, allocatable :: ePressure(:,:,:,:)

real, allocatable :: SpeciesDensity(:,:,:,:,:)
real, allocatable :: SpeciesDensityOld(:,:,:,:,:)
  
  real, allocatable :: LogRhoS(:,:,:,:,:)
  real, allocatable :: LogNS(:,:,:,:,:)
  real, allocatable :: VerticalVelocity(:,:,:,:,:)

  real, allocatable :: NDensityS(:,:,:,:,:)

  real, allocatable :: IDensityS(:,:,:,:,:)
  real, allocatable :: IRIDensity(:,:,:,:,:)

  real, allocatable :: Gamma(:,:,:,:)

  real, allocatable :: KappaTemp(:,:,:,:)
  real, allocatable :: Ke(:,:,:,:)
  real, allocatable :: dKe(:,:,:,:)

  real, dimension(nLons, nLats, nBlocksMax) :: &
       SurfaceAlbedo, SurfaceTemp,SubsurfaceTemp, tinertia, &
       dSubsurfaceTemp, dSurfaceTemp

  real, allocatable :: cp(:,:,:,:)
  real :: ViscCoef(0:nLons+1,0:nLats+1, 0:nAlts+1)

  real, dimension(-1:nLons+2, -1:nLats+2, -1:nAlts+2) :: &
       MeanIonMass, MeanMajorMass

  real, dimension(-1:nLons+2, -1:nLats+2, -1:nAlts+2) :: &
       e_gyro, i_gyro

  real, dimension(-1:nLons+2, -1:nLats+2, -1:nAlts+2, 3) :: Collisions, &
       Collisions1 ! qingyu, 03/02/2020

  ! Add the ioncollisions1, qingyu, 03/02/2020
  real, dimension(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nIons) :: &
       IonCollisions1

  real, dimension(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nIonsAdvect, nSpecies) :: &
       IonCollisions

  real, allocatable :: B0(:,:,:,:,:)
  real, allocatable :: MLatitude(:,:,:,:)
  real :: MLT(-1:nLons+2, -1:nLats+2, -1:nAlts+2)
  real, allocatable :: MLongitude(:,:,:,:)
  real, allocatable :: DipAngle(:,:,:,:)
  real, allocatable :: DecAngle(:,:,:,:)

  real, allocatable :: b0_d1(:,:,:,:,:)
  real, allocatable :: b0_d2(:,:,:,:,:)
  real, allocatable :: b0_d3(:,:,:,:,:)
  real, allocatable :: b0_e1(:,:,:,:,:)
  real, allocatable :: b0_e2(:,:,:,:,:)
  real, allocatable :: b0_e3(:,:,:,:,:)
  real, allocatable :: b0_cD(:,:,:,:)
  real, allocatable :: b0_Be3(:,:,:,:)

  real, allocatable :: cMax_GDB(:,:,:,:,:)

  real, dimension(1:nLons, 1:nLats, 1:nAlts, 3) :: &
       IonDrag, Viscosity
  !! similarly, define PresGrad & Corilis, yuhong, 01/10/2025
  real, dimension(1:nLons, 1:nLats, 1:nAlts, 3) :: &
       PresGrad, CoriolisF4

  real, dimension(1:nLons, 1:nLats, 1:nAlts, nSpecies) :: &
       VerticalIonDrag

  real, allocatable :: Potential(:,:,:,:)

  real, dimension(-1:nLons+2, -1:nLats+2, -1:nAlts+2, 3) :: &
       ExB, EField

  real, dimension(-1:nLons+2, -1:nLats+2) :: &
       ElectronEnergyFlux, ElectronAverageEnergy, &
       ElectronEnergyFluxMono, ElectronNumberFluxMono, &
       ElectronEnergyFluxWave, ElectronNumberFluxWave

  real, allocatable :: Velocity(:,:,:,:,:)
  real, allocatable :: IVelocity(:,:,:,:,:)

  logical            :: isFirstGlow = .True.  
  logical            :: isInitialGlow 

  real, allocatable :: Emissions(:,:,:,:,:)

  real, allocatable :: vEmissionRate(:,:,:,:,:)
  
  real, allocatable :: PhotoElectronDensity(:,:,:,:,:)
  real, allocatable :: PhotoElectronRate(:,:,:,:,:)
  real, allocatable :: PhotoEFluxU(:,:,:,:,:)
  real, allocatable :: PhotoEFluxD(:,:,:,:,:)
  
  real, allocatable :: PhotoEFluxTotal(:,:,:,:,:)
  
  real, dimension(nPhotoBins)                 :: PhotoEBins
  real, dimension(-1:nLons+2, -1:nLats+2, -1:nAlts+2) :: TempUnit

  real :: LocalTime(-1:nLons+2)

  real :: SubsolarLatitude, SubsolarLongitude 
  real :: MagneticPoleColat, MagneticPoleLon
  real :: HemisphericPowerNorth, HemisphericPowerSouth

  integer, parameter :: iEast_ = 1, iNorth_ = 2, iUp_ = 3, iMag_ = 4
  integer, parameter :: iVIN_ = 1, iVEN_ = 2, iVEI_ = 3

  ! Gedy Parameters, qingyu, 03/02/2020
  logical            :: isFirstGedy = .True.

  real, allocatable :: Gedy_pot_root(:,:,:,:), Gedy_pot(:,:,:), &
       Gedy_ed1_root(:,:,:,:), Gedy_ed1(:,:,:), &
       Gedy_ed2_root(:,:,:,:), Gedy_ed2(:,:,:), &
       Gedy_Efield(:,:,:,:), Gedy_fac(:,:,:), &
       Gedy_fac1(:,:,:), Gedy_dfac(:,:,:), Gedy_pot1(:,:,:), &
       Gedy_jwd(:,:,:)

  ! AEPM parameters, qingyu, 10/15/2020
  real, dimension(-1:nLons+2, -1:nLats+2, 19) :: EleDiffEFlux, &
       EleDiffNFlux 

  ! EPM parameters, qingyu, 10/15/2020
  real, dimension(-1:nLons+2, -1:nLats+2, -1:nAlts+2) :: EPM_Potential
  real, dimension(-1:nLons+2, -1:nLats+2, -1:nAlts+2) :: AMIE_Potential

  ! EFVM parameters, qingyu, 10/15/2020
  real, dimension(-1:nLons+2, -1:nLats+2, -1:nAlts+2) :: dEd1_gitm, dEd2_gitm  
  real, dimension(-1:nLons+2, -1:nLats+2, -1:nAlts+2, 3) :: dEfield,&          
       EFVM_Efield                                                             
  real :: d1_dir = 1., d2_dir = 1. 

  ! Height-integrated JH and TEC
  real, dimension(nLons,nLats) :: HeightIntegratedJH, scTEC, on2ratio
  
contains
  !=========================================================================
  subroutine init_mod_gitm

    if(allocated(dLonDist_GB)) return
    allocate(dLonDist_GB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(InvDLonDist_GB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(dLonDist_FB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(InvDLonDist_FB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(dLatDist_GB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(InvDLatDist_GB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(dLatDist_FB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(InvDLatDist_FB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(Altitude_GB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(dAlt_GB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(RadialDistance_GB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(InvRadialDistance_GB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(Gravity_GB(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(CellVolume(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(dAltDLon_CB(nLons,nLats,nAlts,nBlocks))
    allocate(dAltDLat_CB(nLons,nLats,nAlts,nBlocks))
    allocate(Rho(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nBlocks))
    allocate(Temperature(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nBlocks))
    allocate(InvScaleHeight(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nBlocks))
    allocate(Pressure(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nBlocks))
    allocate(NDensity(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nBlocks))
    allocate(eTemperature(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nBlocks))
    allocate(ITemperature(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nBlocks))
    allocate(IPressure(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nBlocks))
    allocate(ePressure(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nBlocks))
    allocate(SpeciesDensity(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nSpeciesAll, nBlocks))
    allocate(SpeciesDensityOld(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nSpeciesAll, nBlocks))
    allocate(LogRhoS(-1:nLons+2, -1:nLats+2, -1:nAlts+2, &
       nSpecies, nBlocksMax))
    allocate(LogNS(-1:nLons+2, -1:nLats+2, -1:nAlts+2, &
       nSpecies, nBlocksMax))
    allocate(VerticalVelocity(-1:nLons+2, -1:nLats+2, -1:nAlts+2, &
       nSpecies, nBlocksMax))
    allocate(NDensityS(-1:nLons+2, -1:nLats+2, -1:nAlts+2, &
       nSpeciesTotal, nBlocksMax))
    allocate(IDensityS(-1:nLons+2, -1:nLats+2, -1:nAlts+2, &
       nIons, nBlocksMax))
    allocate(IRIDensity(-1:nLons+2, -1:nLats+2, -1:nAlts+2, &
       nIons, nBlocksMax))
    allocate(Gamma(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(KappaTemp(nLons, nLats, 0:nAlts+1, nBlocks))
    allocate(Ke(nLons, nLats, 0:nAlts+1, nBlocks))
    allocate(dKe(nLons, nLats, 0:nAlts+1, nBlocks))
    allocate(cp(nLons,nLats,0:nAlts+1,nBlocks))
    allocate(B0(-1:nLons+2,-1:nLats+2,-1:nAlts+2,4,nBlocks))
    allocate(MLatitude(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(MLongitude(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(DipAngle(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(DecAngle(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(b0_d1(-1:nLons+2,-1:nLats+2,-1:nAlts+2,3,nBlocks))
    allocate(b0_d2(-1:nLons+2,-1:nLats+2,-1:nAlts+2,3,nBlocks))
    allocate(b0_d3(-1:nLons+2,-1:nLats+2,-1:nAlts+2,3,nBlocks))
    allocate(b0_e1(-1:nLons+2,-1:nLats+2,-1:nAlts+2,3,nBlocks))
    allocate(b0_e2(-1:nLons+2,-1:nLats+2,-1:nAlts+2,3,nBlocks))
    allocate(b0_e3(-1:nLons+2,-1:nLats+2,-1:nAlts+2,3,nBlocks))
    allocate(b0_cD(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(b0_Be3(-1:nLons+2,-1:nLats+2,-1:nAlts+2,nBlocks))
    allocate(cMax_GDB(0:nLons+1,0:nLats+1,0:nAlts+1,3,nBlocks))
    allocate(Potential(-1:nLons+2, -1:nLats+2, -1:nAlts+2, nBlocks))
    allocate(Velocity(-1:nLons+2, -1:nLats+2, -1:nAlts+2, 3, nBlocks))
    allocate(IVelocity(-1:nLons+2, -1:nLats+2, -1:nAlts+2, 3, nBlocks))
    allocate(Emissions(nLons,nLats,nAlts,nEmissions,nBlocks))
    allocate(vEmissionRate(nLons,nLats,nAlts,nEmissionWavelengths,nBlocks))
    allocate(PhotoElectronDensity(nLons,nLats,nAlts,nPhotoBins,nBlocks))
    allocate(PhotoElectronRate(nLons,nLats,nAlts,nPhotoBins,nBlocks))
    allocate(PhotoEFluxU(nLons,nLats,nAlts,nPhotoBins,nBlocks))
    allocate(PhotoEFluxD(nLons,nLats,nAlts,nPhotoBins,nBlocks))
    allocate(PhotoEFluxTotal(nLons,nLats,nAlts,nBlocks,2))

    ! Allocate Gedy Parameters, qingyu, 03/02/2020
    allocate(Gedy_pot_root(-1:nLons+2, -1:nLats+2, -1:nAlts+2,0:nProcs-1))
    allocate(Gedy_pot(-1:nLons+2, -1:nLats+2, -1:nAlts+2))
    allocate(Gedy_ed1_root(-1:nLons+2, -1:nLats+2, -1:nAlts+2,0:nProcs-1))
    allocate(Gedy_ed1(-1:nLons+2, -1:nLats+2, -1:nAlts+2))
    allocate(Gedy_ed2_root(-1:nLons+2, -1:nLats+2, -1:nAlts+2,0:nProcs-1))
    allocate(Gedy_ed2(-1:nLons+2, -1:nLats+2, -1:nAlts+2))
    allocate(Gedy_Efield(-1:nLons+2, -1:nLats+2, -1:nAlts+2, 3))
    allocate(Gedy_fac(-1:nLons+2, -1:nLats+2, -1:nAlts+2))
    allocate(Gedy_fac1(-1:nLons+2, -1:nLats+2, -1:nAlts+2))
    allocate(Gedy_dfac(-1:nLons+2, -1:nLats+2, -1:nAlts+2))
    allocate(Gedy_pot1(-1:nLons+2, -1:nLats+2, -1:nAlts+2))
    allocate(Gedy_jwd(-1:nLons+2, -1:nLats+2, -1:nAlts+2))

  end subroutine init_mod_gitm
  !=========================================================================
  subroutine clean_mod_gitm

    if(.not.allocated(dLonDist_GB)) return
    deallocate(dLonDist_GB)
    deallocate(InvDLonDist_GB)
    deallocate(dLonDist_FB)
    deallocate(InvDLonDist_FB)
    deallocate(dLatDist_GB)
    deallocate(InvDLatDist_GB)
    deallocate(dLatDist_FB)
    deallocate(InvDLatDist_FB)
    deallocate(Altitude_GB)
    deallocate(dAlt_GB)
    deallocate(RadialDistance_GB)
    deallocate(InvRadialDistance_GB)
    deallocate(Gravity_GB)
    deallocate(CellVolume)
    deallocate(dAltDLon_CB)
    deallocate(dAltDLat_CB)
    deallocate(Rho)
    deallocate(Temperature)
    deallocate(InvScaleHeight)
    deallocate(Pressure)
    deallocate(NDensity)
    deallocate(eTemperature)
    deallocate(ITemperature)
    deallocate(IPressure)
    deallocate(ePressure)
    deallocate(SpeciesDensity)
    deallocate(SpeciesDensityOld)
    deallocate(LogRhoS)
    deallocate(LogNS)
    deallocate(VerticalVelocity)
    deallocate(NDensityS)
    deallocate(IDensityS)
    deallocate(IRIDensity)
    deallocate(Gamma)
    deallocate(KappaTemp)
    deallocate(Ke)
    deallocate(dKe)
    deallocate(cp)
    deallocate(B0)
    deallocate(MLatitude)
    deallocate(MLongitude)
    deallocate(DipAngle)
    deallocate(DecAngle)
    deallocate(b0_d1)
    deallocate(b0_d2)
    deallocate(b0_d3)
    deallocate(b0_e1)
    deallocate(b0_e2)
    deallocate(b0_e3)
    deallocate(b0_cD)
    deallocate(b0_Be3)
    deallocate(cMax_GDB)
    deallocate(Potential)
    deallocate(Velocity)
    deallocate(IVelocity)
    deallocate(Emissions)
    deallocate(vEmissionRate)
    deallocate(PhotoElectronDensity)
    deallocate(PhotoElectronRate)
    deallocate(PhotoEFluxU)
    deallocate(PhotoEFluxD)
    deallocate(PhotoEFluxTotal)
    ! qingyu, 03/02/2020   
    deallocate(Gedy_pot_root)
    deallocate(Gedy_ed1_root)
    deallocate(Gedy_ed2_root)
    deallocate(Gedy_pot)
    deallocate(Gedy_ed1)
    deallocate(Gedy_ed2)
    deallocate(Gedy_Efield)

  end subroutine clean_mod_gitm
  !=========================================================================
end module ModGITM
