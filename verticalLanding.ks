///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// KSP kOS Vertical Landing v1.0.0
// Copyright (C) 2020 AligatorBkmz@gmail.com
// Distributed under the GPL Licence
//
// Description: Causes your vessel to hold your current heading and pitch while landing in atmosphere .
//
// Instructions: 
//		1) Copy this script to your [KSP\Ships\Script] Folder
//
//		2) Build a ship with a kOS processor on-board. At lease one processor is required,
//		   multiple if needing additional systems.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SET MINVERTSPEED TO 3.//Minimal landing speed
SET SMOOTHNESS TO 0.05.//How fast you want land
SET MAXVERTICALSPEED TO -300+5. //Must be <0
SET THRUST TO 1. 
//LANDING COORDINATES - NOT USED YET
SET LAT  TO -0.0972. 
SET LONG TO -74.57.           

SET STARTINHEGHT TO 36000. //Start landing when height < 36000m
SET STG TO 1.
SET Q TO QUEUE().
SET QLeng TO 0.

SET speedEast TO 0.
SET speedNorth TO 0.

FUNCTION PrintINFO{
 CLEARSCREEN.
PRINT "==========RELAX - JAST DO IT=========".
PRINT "ALTITUDE      = " + SHIP:ALTITUDE.
PRINT "VERTICALSPEED = " + SHIP:VERTICALSPEED.
PRINT "GROUNDSPEED = "   + SHIP:GROUNDSPEED.
PRINT "LATITUDE      = " + SHIP:LATITUDE.
PRINT "LONGITUDE     = " + SHIP:LONGITUDE.
PRINT "LAT-LATITUDE  = " + (LAT-SHIP:LATITUDE).
PRINT "LONG-LONGITUDE = " + (LONG-SHIP:LONGITUDE).
PRINT "TERRAINHEIGHT     = " + SHIP:geoposition:TERRAINHEIGHT.
PRINT "THRUST        = " + THRUST.
PRINT "MAXSPEED      = " + MAXVERTICALSPEED.
PRINT "speedEast        = " + speedEast.
PRINT "speedNorth      = " + speedNorth.
PRINT "===============STAGE " +(STG)+"===============".
}

FUNCTION CalcSmooth {
	SET RES TO 0.05.
	SET MIN TO 9999.
	SET MAX TO 0.
	Q:PUSH(THRUST).
	IF QLeng<10 {SET QLeng TO QLeng+1.}
	IF QLeng=10 {
	 SET Q1 TO Q:COPY.	
	 Q:POP.
	 
	 SET i TO 0.
	 SET VAL TO 0.
	 UNTIL i=10 {
	  SET VAL TO Q1:POP. 
	  IF MIN>VAL {SET MIN TO VAL.}
	  IF MAX<VAL {SET MAX TO VAL.}
      SET i TO i+1.
	 }
	 SET RES TO MAX-MIN.
	}
	return RES.
}
FUNCTION VerticalBraking {
 
 SET ABOVEGROUND TO SHIP:ALTITUDE-SHIP:geoposition:TERRAINHEIGHT.
 IF (ABOVEGROUND <70000) {SET MAXVERTICALSPEED TO -500. SET STG TO 5.}
 IF (ABOVEGROUND <36000) {SET MAXVERTICALSPEED TO -350. SET STG TO 4.}
 IF (ABOVEGROUND < 6000) {SET MAXVERTICALSPEED TO -200. SET STG TO 3.}
 IF (ABOVEGROUND < 3000) {SET MAXVERTICALSPEED TO -100. SET STG TO 2.}
 IF (ABOVEGROUND < 1000) {SET MAXVERTICALSPEED TO  0-((ABOVEGROUND*0.05)+MINVERTSPEED). SET STG TO CalcSmooth.}//smooth landing

IF SHIP:VERTICALSPEED>MAXVERTICALSPEED {SET THRUST TO THRUST-(THRUST/2).} 
IF SHIP:VERTICALSPEED<MAXVERTICALSPEED {SET THRUST TO THRUST+((THRUST/2)+0.1).}
 
 IF THRUST>0{  
  SET SHIP:CONTROL:PILOTMAINTHROTTLE TO THRUST.
 } else
 {
  SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
 }
}

FUNCTION HorizontalBraking {
  SET sinYaw TO sin(ship:up:yaw).
  SET cosYaw TO cos(ship:up:yaw).
  SET sinPitch TO sin(ship:up:pitch).
  SET cosPitch TO cos(ship:up:pitch).
	
  SET unitVectorEast TO V(-cosYaw, 0, sinYaw).
  SET unitVectorNorth TO V(-sinYaw*sinPitch, cosPitch, -cosYaw*sinPitch).
	
  SET shipVelocitySurface TO ship:velocity:surface.
  SET speedEast TO vdot(shipVelocitySurface, unitVectorEast).
  SET speedNorth TO vdot(shipVelocitySurface, unitVectorNorth).
}

FUNCTION tick {
 PARAMETER key.
 PrintINFO.
 VerticalBraking.
 HorizontalBraking.
}

UNTIL 0 {
 SET key TO " ".
 if terminal:input:haschar {
  set key to terminal:input:getchar(). 
  if key = "x" {BREAK.}
 }
 tick(key).
}
