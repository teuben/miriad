c------------------------------------------
c	at_selfcal.h
c------------------------------------------
	include 'maxdim.h'
	include 'mem.h'
	integer maxHash,minSol
	parameter(maxHash=30000,minSol=200)
	integer nants,nBl,nbad,nbstok,maxSol,nsols,TotVis,minants
	integer nHash,Hash(maxHash),Indx(maxHash)
	integer pSumVM,pSumVV,pSumMM,pWeight,pCount,pGains,prTime
        integer pstptim,pstrtim
	logical first
	double precision time0
	common/selfcom/time0,nants,nBl,nbad,nbstok,nsols,maxSol,
     *	  TotVis,minants,nHash,Hash,Indx,pSumVm,pSumVV,pSumMM,pWeight,
     *	  pCount,pGains,prTime,pstptim,pstrtim,first


