c***********************************************************************
c  Routines to deal with the  baseline <-> antennae pair   translations
c  
c  basants     baseline -> antennae pair, with or without checking
c  basant      strict check, will warn if ant1 > ant2 is used etc.
c  basanta     liberal, user must decide what to do with bad ant#'s
c  antbas      antenna pair -> baseline
c
c  History:
c    jm    05dec90    Initial version.
c    jm    21sep92    Modified to call BUG if ant1>ant2.
c    pjt    8mar95    &!@$*(*& when ant1||ant2 out of range 1..256
c    rjs   27oct00    New baseline numbering convention.
c    pjt   12may03    documented some thoughts on allowing MAXANT 32768
c                     and included maxdim.h
c    pjt   17oct03    return 0's if record has invalid baseline
c    pjt    6jan05    provide a less strict version that allows ant1 > ant2
c***********************************************************************

      subroutine basant(baseline, ant1, ant2)
      implicit none
      integer ant1, ant2
      double precision baseline
      call basants(baseline,ant1,ant2,.TRUE.)
      end

      subroutine basanta(baseline, ant1, ant2)
      implicit none
      integer ant1, ant2
      double precision baseline
      call basants(baseline,ant1,ant2,.FALSE.)
      end

c* BasAnt - determine antennas from baseline number
c& pjt
c: calibration, uv-i/o, uv-data, utilities
c+
      subroutine basants(baseline, ant1, ant2, check)
      implicit none
      integer ant1, ant2
      double precision baseline
      logical check
c
c  BasAnt is a Miriad routine that returns the antenna numbers that are
c  required to produce the input baseline number.  According to the
c  Miriad programming manual, the relationship between the baseline
c  and the antenna numbers is defined as either
c    baseline = (Ant1 * 256) + Ant2.
c  or
c    baseline = (Ant1 * 2048) + Ant2 + 65536.
c
c  Note:  Because Ant1 is ALWAYS suppose to be less than Ant2,
c         it is considered a fatal error if Ant2 is larger than
c         Ant1.  (No restriction is placed on the condition Ant1
c         equal to Ant2 to allow for autocorrelation data)
c
c  Note2: the largest possible size we could use with this encoding
c         is 32675, viz.
c     baseline = (Ant1 * 32768) + Ant2 + 65536.
c         before running into the sign/end bit of an integer*4 type.
c         HOWEVER, since UVFITS (random groups) stores the baseline
c         in a float, where not all bits are equal, the maxant=2048 
c         is the practical limit.
c
c     MAXIANT = 2048 for import/export purposes, 32768 for internal
c     (see maxdim.h)
c
c  Input:
c    baseline The baseline number.  This value is usually obtained
c             as the fourth or fifth element in the double precision array
c             PREAMBLE (for example, see UVREAD).
c             It is the fifth element if 
c               call uvset(tvis,'preamble','uvw/time/baseline',0,0.,0.,0.)
c             was used.
c
c  Output:
c    ant1     The first antenna number. Numbered 1...maxant
c    ant2     The second antenna number. Numbered 1...maxant
c
c  NOTE::::   For GILDAS it can now reteurn ant1=ant2=0 if the record
c             is invalid and should be skipped.
c
c--
c-----------------------------------------------------------------------
      include 'maxdim.h'
      integer mant
c
      ant2 = nint(baseline)
      if(ant2.gt.65536)then
	ant2 = ant2 - 65536
	mant = MAXIANT
      else
	mant = 256
      endif
      ant1 = ant2 / mant
      ant2 = ant2 - (ant1 * mant)
      if (max(ant1,ant2).ge. mant) call bug('f', 
     *  'BASANT: possibly a bad baseline number!')
      if (check) then
         if (ant1 .gt. ant2) then
            call bug('f','BASANT: a1>a2: bad baseline #!')
         endif
         if (ant1 .lt. 1) then
            call bug('f','BASANT: ant1<1: bad baseline #!')
         endif
         if (ant2 .lt. 1) then
            call bug('f','BASANT: ant2<1: bad baseline #!')
         endif
      endif
      end
c************************************************************************
c* AntBas - determine baseline from antenna numbers
c& pjt
c: calibration, uv-i/o, uv-data, utilities
c+
	double precision function antbas(i1,i2)
c
	implicit none
	integer i1,i2
c
c  Determine the baseline number of a pair of antennas.
c
c  Note: i1 <= i2.
c  See also MAXANT in maxant.h and maxantc.h on limits on i2.
c
c------------------------------------------------------------------------
        include 'maxdim.h'
	if(i1.gt.i2) then
           call bug('f','Illegal baseline number in antbas')
        endif
	if(i2.gt.255)then
	  antbas = MAXIANT*i1 + i2 + 65536
	else
	  antbas =  256*i1 + i2
	endif
	end
