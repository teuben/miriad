c  NOTE!!!
c  this is really mfcal.h, since xyauto is just a clone
c  from the 2012 version (mfcal.h  CVS r1.3   mfcal.for r1.21)
c
	include 'maxdim.h'
c
	integer MAXDATA,MAXPOL
	parameter(MAXDATA=20000,MAXPOL=2)
c
	complex Vis(MAXDATA),Model(MAXDATA)
	integer b1(MAXDATA),b2(MAXDATA),t1(MAXDATA),t2(MAXDATA)
	integer zerovar(MAXPOL+1),nzero
	real angfreq(MAXDATA)
	common/mfcalcm1/vis,model,angfreq,b1,b2,t1,t2,zerovar,nzero
c
	integer MAXHASH
	parameter(MAXHASH=16*MAXCHAN*MAXANT)
	integer hash(2,MAXHASH),nhash
	common/mfcalcm2/hash,nhash
