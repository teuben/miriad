c********1*********2*********3*********4*********5*********6*********7*c
c		pnt.h
c	include file for pnt program
c  History:
c       	mchw Jan 1985
c    17aug94 mchw Added common phfit.
c    20jun95 added MAXFIT pointing parameters.
c     8jul05 proper ansi fortran declaration order/style  (pjt)
c    12sep05 equ and ant are now integers!
c    11apr06 save fits in /pntfit/ for printing summary
c
c********1*********2*********3*********4*********5*********6*********7*c
      INTEGER NPMAX,NSMAX,MAXANT,MAXFIT
      PARAMETER(NPMAX=2000,NSMAX=1000,MAXANT=15,MAXFIT=9)

      INTEGER np,is(NPMAX)
      REAL ut(NPMAX),az(NPMAX),el(NPMAX),daz(NPMAX),del(NPMAX),
     *     tilt(NPMAX),t1(NPMAX),t2(NPMAX)
      COMMON /base/np,is,ut,az,el,daz,del,tilt,t1,t2

      INTEGER nph
      REAL    wph(NPMAX),xph(NPMAX),yph(NPMAX),zph(NPMAX)
      COMMON /phfit/ nph,wph,xph,yph,zph

      INTEGER ns
      LOGICAL stf(NSMAX)
      COMMON /slist/ ns,stf

      INTEGER ant
      REAL          xmin,xmax,ymin,ymax
      COMMON /plot/ xmin,xmax,ymin,ymax,ant

      INTEGER equ
      REAL apc(MAXFIT),epc(MAXFIT),apcs(MAXFIT),epcs(MAXFIT),
     *     azfit(MAXFIT,MAXANT),elfit(MAXFIT,MAXANT),
     *     azrms(MAXANT),azrmsfit(MAXANT),aznp(MAXANT),
     *     elrms(MAXANT),elrmsfit(MAXANT),elnp(MAXANT)
      COMMON /answer/ apc,epc,apcs,epcs,equ
      COMMON /pntfit/ azfit, elfit,
     *     azrms, azrmsfit, aznp, elrms, elrmsfit, elnp

      CHARACTER file*80, pntfile*80,dat*24,pdevice*80,tdevice*20
      CHARACTER*8 sname(NSMAX)
      COMMON /pntchar/ pntfile,file,dat,pdevice,tdevice,sname

c********1*********2*********3*********4*********5*********6*********7*c
