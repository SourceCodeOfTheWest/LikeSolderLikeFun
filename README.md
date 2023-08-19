# selective ReRouting
 --for Flatcam  files to run on Candle or OpenCNCPilot.
(I tried the latter once, seems OK.)
 Compiles with Delphi Community edition 10.2 
or above, maybe even below.
  
   Not for .drd files.
   
   To repeat and re-emphasize the obvious, boards to be re-routed
must be in their exact position when they first routed.
   Candle  or OpenCNCPilot must know the original x0,y0 & z0.
  
    Current .exe file in Win32/Debug directory. 
   There is also a sample .nc file to play around with there.
The 'cutrecs.dat' file stores the selected rectangle positions.

   When defining a rectangle for routing, 
left-click on the white background and drag down to the right.

   A record of chosen rectangles is maintained. To zoom on any,
right-click on its dotted black border. You may have to 
zoom close to with the mouse wheel or zoom around it first.
	From there it can be removed with the 'remove selected rect' 
button.

   Clicking on a red track will throw
an 'onclickseries' event causing the Gcode for that track to be displayed
in the left window so click on the white background for selecting a window.
  
   A triangle mark at the beginning of the segment is shown in the 
graphic window which BTW is not shown to scale.
   You can step thru the marks with the 'prev' and 'next' buttons at the 
top. The GCode line is shown in black at the upper left,
to the left of the '<-click 2 clipboard' lable.
    You can click on the black text itself if you want to 
search for it in an editor.
    It's mainly for debugging purposes and has not been removed.
   'Copy Selected' button refers to highlighted text in the 
window above.

   If a you have trouble zooming, select farther out then work your way in
or use mouse wheel.
   Remember, left click and drag down to the right. All the tracks
appearing within the visible window will be routed.   

     Right Click to drag & pan, use mouse wheel also 
for zooming in & out.


   A few rough edges still, but I've salvaged several boards with it 
instead of adding them to my coaster collection.

   Please watch  rather jerky tutorial at
   https://www.brighteon.com/9b4a5293-d6a0-4e86-85a8-078b56a42560 

   Huge thanks to Mr. Xander Luciano wherever you are, It would have been
much more difficult to visualize the Gcode and write the app
without NCviewer. Candle's visualizer is kind of difficult to use
for that purpose.
  Hope you don't mind my 'Shellexecute'-ing your app, Sr. Luciano.
Russ
