c************************************************************************
	program bwsel
	implicit none
c
c
c  History:
c    pjt  20nov06   Cloned off uvcat
c  Bugs:
c
c= bwsel - Select records based on their wideband bandwidth
c& pjt 
c: uv analysis
c+
c	BWSEL is a MIRIAD task which copies and catenates multiple MIRIAD
c	uv data sets. Only records are copied of which their bandwidth 
c@ vis
c	The names of the input uv data sets. Multiple names can be given,
c	separated by commas. At least one name must be given.
c@ bw  
c       A set of bandwidths, in MHz, in order for a record to be copied.
c       Use a 0 if no match is needed. Multiple non-zero values need to be
c       all matched. Default
c@ slop
c       Fraction of frequency within which the bandwith should be to be selected.
c       Default: 0.25
c@ out
c	The name of the output uv data set. If none supplied, input dataset
c       is scanned.
c--
c------------------------------------------------------------------------
        include 'maxdim.h'
	character version*(*)
	parameter(version='BWsel: version 21-nov-06 **TEST5**')
c
	integer nchan,vhand,lIn,lOut,nPol,Pol,SnPol,SPol
	integer nwdata,length,nbw,i
	integer nvis0, nvis1
	double precision preamble(5),bw(MAXWIN),slop
	complex data(maxchan),wdata(maxchan)
	logical flags(maxchan),wflags(maxchan)
	logical first,init,new,more,dopol,PolVary,donenpol
	logical dochan,dowide,docopy,updated,dobw
	character out*256,type*1
c
c  Externals.
c
        logical uvVarUpd,uvDatOpn
c
	call output(version)
	call keyini
	call uvDatInp('vis','2')
	call keya('out',out,' ')
	call mkeyd('bw',bw,MAXWIN,nbw)
	call keyd('slop',slop,0.25d0)
	call keyfin

c
c  Check user inputs, allow no output in scanning mode
c
	if(out.eq.' ') then
           call bug('w','Output file name is missing, scanning mode')
	   lOut = -1
	else
	   call uvopen(lOut,out,'new')
	endif
c
c  Other initialisation.
c
	first = .true.
	init = .false.
	new = .true.
	SnPol = 0
	SPol = 0
	PolVary = .false.
	dobw = .false.
	nvis1 = 0
	nvis0 = 0
	do i=nbw+1,MAXWIN
	   bw(i) = 0.0
	enddo
c
c  Loop the loop. Open a file, process it, copy it, etc.
c
	more = uvDatOpn(lIn)
	dowhile(more)
	  if(new)then
	    call SetUp(lIn,dochan,dowide,dopol,vhand)
	    if(dowide.and..not.dochan)
     *	      call uvset(lOut,'data','wide',0,1.,1.,1.)
	    npol = 0
	    donenpol = .false.
	    new = .false.
	  endif
c
c  Copy the history the first time, and set the form of the output
c  correlations the first time we are to copy some.
c
	  if(first)then
	    call hdcopy(lIn,lOut,'history')
	    first = .false.
	  endif
	  if(.not.init.and.dochan)then
	    call uvprobvr(lIn,'corr',type,length,updated)
	    call uvset(lOut,'corr',type,0,0.,0.,0.)
	    init = .true.
	  endif
c
c  Read in the data.
c
	  call uvDatRd(preamble,data,flags,maxchan,nchan)
c
c  Case of end-of-file. Close the old file, and open the new.
c
	  if(nchan.eq.0)then
	    call uvDatCls
	    more = uvDatOpn(lIn)
	    new = .true.
c
c  Case of still more data. Copy across any variables that we want,
c  and write out the data.
c
	  else
	    if(npol.eq.0)then
	      call uvDatGti('npol',npol)
	      if(npol.le.0)call bug('f',
     *		'Could not determine number of polarizations present')
	      donenpol = .false.
	    endif
c
c  Update the window parameters if needed.
c
	    if(dochan) then
	       if (uvVarUpd(vhand)) then
		  call WindUpd(lIn,lOut,
     *                    bw,nbw,slop,dobw)
		  nvis0 = nvis0 + 1
		  if (dobw) nvis1 = nvis1 + 1
	       endif
	    else
	       call bug('f','no channel data??, code not ready')
	    endif
c
c  Check if this data is wanted.
c
	    docopy = donenpol
	    docopy = dobw
c
c  Copy the variables we are interested in.
c
	    if(docopy)then
	      if(.not.donenpol)then
	        if(nPol.ne.SnPol)then
		  call uvputvri(lOut,'npol',nPol,1)
		  PolVary = SnPol.ne.0
		  SnPol = nPol
	        endif
		donenpol = .true.
	      endif
	      call uvDatGti('pol',Pol)
	      if(Pol.ne.SPol)then
		call uvputvri(lOut,'pol',Pol,1)
		SPol = Pol
	      endif
	      call VarCopy(lIn,lOut)
	      if(dowide.and.dochan)then
	        call uvDatWRd(wdata,wflags,maxchan,nwdata)
	        call uvwwrite(lOut,wdata,wflags,nwdata)
	      endif
	      call uvwrite(lOut,preamble,data,flags,nchan)
	    endif
	    npol = npol - 1
	  endif
	enddo
c
c  Write out the "npol" parameter, if it did not vary.
c
	if(.not.PolVary) call wrhdi(lOut,'npol',Snpol)
c
c  Finish up the history, and close up shop.
c
        call hisopen(lOut,'append')
        call hiswrite(lOut,'BWSEL: Miriad '//version)
	call hisinput(lOut,'BWSEL')
        call hisclose (lOut)
	call uvclose(lOut)

	write(*,*) 'Copied ',nvis1,'/',nvis0,' records'

	end
c************************************************************************
	subroutine SetUp(lIn,dochan,dowide,dopol,vhand)
c
	implicit none
	logical dopol,dochan,dowide
	integer lIn,vhand
c
c  Input:
c    lIn	Handle of the uv dataset.
c  Output:
c    dochan	Copy "corr" data across.
c    dowide	Copy "wcorr" data across.
c    dopol	True if the file contains polarisation information.
c    vhand	Handle pointing to all the windowing variables.
c------------------------------------------------------------------------
	character type*1
	integer length,j
	logical updated
c
	integer nwin
	parameter(nwin=9)
	character windpar(nwin)*8
c
	data windpar/ 'ischan  ','nschan  ','nspect  ','restfreq',
     *	   'sdf     ','sfreq   ','systemp ' , 'xtsys' , 'ytsys'/
c
c  Check if "wcorr" and "corr" are present, and determine which ones we
c  want to write out.
c
	call uvprobvr(lIn,'wcorr',type,length,updated)
	dowide = type.eq.'c'
	call uvprobvr(lIn,'corr',type,length,updated)
	dochan = (type.eq.'r'.or.type.eq.'j'.or.type.eq.'c')
c
	if(.not.dochan.and..not.dowide)
     *	  call bug('f','No corr or wcorr data to copy')
c
c  Mark the variables according to what we need.
c
	call VarInit(lIn,' ')
c
	if(dochan)then
	  call uvvarini(lIn,vhand)
	  do j=1,nwin
	    call uvvarset(vhand,windpar(j))
	  enddo
	endif
c
	if(dowide)then
	  call VarWInit(lIn)
	  if(.not.dochan)call uvset(lIn,'data','wide',0,1.,1.,1.)
	endif
c
	call uvprobvr(lIn,'npol',type,length,updated)
	dopol = type.eq.'i'

	end
c************************************************************************
	subroutine WindUpd(lIn,lOut,bw,nbw,slop,dobw)
c
	implicit none
	integer lIn,lOut,nbw
	double precision bw(nbw),slop
	logical dobw
c
c  This updates uv variables that are affected if we remove channels.
c  These variables are:
c    nspect
c    nschan
c    ischan
c    sdf
c    sfreq
c    restfreq
c    systemp
c    xtsys
c    ytsys
c
c  It also returns a description used by a later routine to extract the
c  useful channels.
c
c  Input:
c    lIn	Handle of the input uv data file.
c    lOut	Handle of the output uv data file.
c    nbw        number of BW's given
c    bw         array is BW's
c    slop       slop value
c  Output:
c    dobw       is this record good to copy?
c------------------------------------------------------------------------
	include 'maxdim.h'
	integer nschan(MAXWIN),ischan(MAXWIN),nants
	integer length,nspect,nout,i,nsystemp,nxyph
	integer nxtsys,nytsys
	double precision sdf(MAXWIN),sfreq(MAXWIN),restfreq(MAXWIN)
	double precision mbw(MAXWIN)
	real systemp(MAXANT*MAXWIN),xyphase(MAXANT*MAXWIN)
	real xtsys(MAXANT*MAXWIN),ytsys(MAXANT*MAXWIN)
	character type*1
	logical unspect,unschan,uischan,usdf,usfreq,urest,usyst
	logical uxtsys,uytsys
	logical uxyph
c
c  Get the dimensioning info.
c
	call uvgetvri(lIn,'nants',nants,1)
	call uvprobvr(lIn,'nspect',type,length,unspect)
	call uvgetvri(lIn,'nspect',nspect,1)
	if(nspect.le.0)
     *	  call bug('f','Bad value for uv variable nspect')

c
c  Get all the goodies, noting whether they are being updated.
c
	call uvprobvr(lIn,'nschan',type,length,unschan)
	call uvgetvri(lIn,'nschan',nschan,nspect)
	call uvprobvr(lIn,'ischan',type,length,uischan)
	call uvgetvri(lIn,'ischan',ischan,nspect)
	call uvprobvr(lIn,'sdf',type,length,usdf)
	call uvgetvrd(lIn,'sdf',sdf,nspect)	
        call uvprobvr(lIn,'sfreq',type,length,usfreq)
	call uvgetvrd(lIn,'sfreq',sfreq,nspect)
	call uvprobvr(lIn,'restfreq',type,length,urest)
	call uvgetvrd(lIn,'restfreq',restfreq,nspect)
c
c       System Temperature
c
	call uvprobvr(lIn,'systemp',type,nsystemp,usyst)
	usyst = type.eq.'r'.and.nsystemp.le.MAXANT*MAXWIN.and.
     *				nsystemp.gt.0
	if(usyst)call uvgetvrr(lIn,'systemp',systemp,nsystemp)
c
c       x-feed system temperature
c
	call uvprobvr(lIn,'xtsys',type,nxtsys,uxtsys)
	uxtsys = type.eq.'r'.and.nxtsys.le.MAXANT*MAXWIN.and.
     *				nxtsys.gt.0
	if(uxtsys)call uvgetvrr(lIn,'xtsys',xtsys,nxtsys)

c
c       y-feed system temperature
c
	call uvprobvr(lIn,'ytsys',type,nytsys,uytsys)
	uytsys = type.eq.'r'.and.nytsys.le.MAXANT*MAXWIN.and.
     *				nytsys.gt.0
	if(uytsys)call uvgetvrr(lIn,'ytsys',ytsys,nytsys)

	call uvprobvr(lIn,'xyphase',type,nxyph,uxyph)
	uxyph = type.eq.'r'.and.nxyph.le.MAXANT*MAXWIN.and.
     *				nxyph.gt.0
	if(uxyph)call uvgetvrr(lIn,'xyphase',xyphase,nxyph)

	nout = nspect
c
c  Write all the goodies out.
c
	if (lout.gt.0) then
	   call uvputvri(lOut,'nspect',nout,1)
	   call uvputvri(lOut,'nschan',nschan,nout)
	   call uvputvri(lOut,'ischan',ischan,nout)
	   call uvputvrd(lOut,'sdf',sdf,nout)
           call uvputvrd(lOut,'sfreq',sfreq,nspect)
	   call uvputvrd(lOut,'restfreq',restfreq,nspect)
	   if(nsystemp.ge.nspect*nants)nsystemp = nout*nants
	   if(usyst)call uvputvrr(lOut,'systemp',systemp,nsystemp)
	   if(nxtsys.ge.nspect*nants) nxtsys = nout*nants
	   if(uxtsys) call uvputvrr(lOut,'xtsys',xtsys,nxtsys)
	   if(nytsys.ge.nspect*nants) nytsys = nout*nants
	   if(uytsys) call uvputvrr(lOut,'ytsys',ytsys,nytsys)
	   if(uxyph)call uvputvrr(lOut,'xyphase',xyphase,nxyph)
	endif

	
c
c  The data is assumed to have an LSB and USB, with nspec/2 windows in each side
c
	if (mod(nspect,2).ne.0) call bug('f',
     *       'Odd number of nspect, no USB/LSB?')
	do i=nbw+1,nspect/2
	   bw(i) = 0.0d0
	enddo
	dobw = .TRUE.
	do i=1,nspect/2
	   mbw(i) = abs(sdf(i)*nschan(i)*1000.0d0)
	   if (bw(i).ne.0.0d0) then
	      dobw = dobw .and. bw(i)*(1-slop).lt.mbw(i) .and.
     *                          bw(i)*(1+slop).gt.mbw(i)
	   endif
	enddo
	write(*,'(3F7.1)') mbw(1),mbw(2),mbw(3)

	end
