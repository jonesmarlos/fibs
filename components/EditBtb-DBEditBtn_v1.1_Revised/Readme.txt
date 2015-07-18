

        MM   MM  BBBB   SSSS
        MMM MMM  Bb  B SS   
        MM M MM  BBBB   SSS
        MM   MM  Bb  B    SS
        MM   MM  BBBB  SSSS

      -- MindBlast Software --

 ---------------------------------------------------
 >>>>>>>   				    <<<<<<<<
 >>>>>>>  http://www.gcs.co.za/mbs/mbs.htm  <<<<<<<<
 >>>>>>>   				    <<<<<<<<
 >>>>>>>  louw@gcs.co.za		    <<<<<<<<
 >>>>>>>   				    <<<<<<<<
 ---------------------------------------------------

- EditBtn
  This component works as a normal TEdit, but inside the editing area is a button that can be clicked.
  This is vey usefull for activating any sort of dialog from which data must be obtained.
  (Look at the Demo and see what I mean) 
- TDBEditBtn
  Data-aware version


Contents:

 (1) Installing
 (2) Using the components
 (3) MindBlast Software and the Website
 (4) Disclaimer and Copyright


(1) Installing
--------------

Add both DBEditBtn.pas and EditBtn.pas as you would normally install a component.

(2) Using the components
------------------------

At design-time simply specify the the Glyph and NumberOfGlyphs properies as you would do for a normal TSpeedbutton.
The "OnBtnClick" event gets called wheneverthe Button is clicked.

Notice that in Design-Time you can see the SpeedButton but not at RunTime...
Only if the EditControl is focussed will the speedbutton be displayed.
The reason for this is that these components was created for an application where this behaviour was needed. To override this behaviour you simply need to change two lines of code in the source code. 
(Everywhere where the speedbutton is set to visible=false)


Button is a public property. With this you can access every property and method of the speedbutton.
(Like enable, visible, width, etc.

(3) MindBlast Software and the Website
--------------------------------------

MindBlast Software has been developing components for a long time now.
Components like 
 * TEZLabel - Fast, 3D, AutoSizing with built in editor label
 * MP3Remote - Control Winamp to play MP3 files the way you want it to!
 * AnyShape Transparent Form component pack
   - Creates Transparent forms without any programming!
 * FliPlayer - Plays Autodesks FLI/FLC animation files without any DLL's
has become very popular under the Delphi (and VB) community.

Visit our website for lots more great stuff and updates:
 ---------------------------------------------------
 >>>>>>>   				    <<<<<<<<
 >>>>>>>  http://www.gcs.co.za/mbs/mbs.htm  <<<<<<<<
 >>>>>>>   				    <<<<<<<<
 >>>>>>>  louw@gcs.co.za		    <<<<<<<<
 >>>>>>>   				    <<<<<<<<
 ---------------------------------------------------
  


(4) Disclaimer and Copyright
----------------------------

These components are FREEWARE. You may do with these components as you wish. (Ass long as you don't sell them!) 

You use these components at your own and exclusive risk.



